import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app_debi/cubit/todo_state.dart';
import 'package:todo_app_debi/model/todo_model.dart';
import 'package:todo_app_debi/utils/constants.dart';

class TodoCubit extends Cubit<TodoState> {
  TodoCubit() : super(IntitialState());
  List<TodoModel> todos = [];
  String? _currentUserEmail;
  String? _desc;
  String? _deadLine;

  // Fixed setters
  set email(TextEditingController emailController) {
    _currentUserEmail = emailController.text;
  }

  set desc(TextEditingController descController) {
    _desc = descController.text; 
  }

  set deadLine(TextEditingController deadLineController) {
    _deadLine = deadLineController.text; 
  }

  String? get email => _currentUserEmail;
  String? get desc => _desc;
  String? get deadLine => _deadLine;

  // Set current user and load their todos
  Future<void> setCurrentUser(String userEmail) async {
    print("DEBUG: Setting current user: $userEmail");
    _currentUserEmail = userEmail;
    
    // Save current user email to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_email', userEmail);
    
    // Load todos for this user
    await loadTodos();
  }

  // Get current user from preferences (for app restart)
  Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserEmail = prefs.getString('current_user_email');
    return _currentUserEmail;
  }

  // Generate user-specific key for SharedPreferences
  String _getUserTodosKey(String userEmail) {
    return '${Constants.perKey}_$userEmail';
  }

  Future<void> addTodo(String title, {String? description, String? deadline}) async {
    print("DEBUG: addTodo called with title: $title");
    print("DEBUG: addTodo description parameter: '$description'");
    print("DEBUG: addTodo deadline parameter: '$deadline'");
    
    if (_currentUserEmail == null) {
      emit(ErrorState(message: "No user logged in"));
      return;
    }
    
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final random = Random().nextInt(100000);
      
      // Use passed parameters first, then fall back to internal setters
      final todoDescription = description ?? _desc ?? '';
      final todoDeadline = deadline ?? _deadLine ?? '';
      
      print("DEBUG: Final desc to save: '$todoDescription'");
      print("DEBUG: Final deadline to save: '$todoDeadline'");
      
      final newTodo = TodoModel(
        id: random, 
        title: title, 
        email: _currentUserEmail!, 
        desc: todoDescription, 
        deadLine: todoDeadline
      );
      
      todos.add(newTodo);
      print("DEBUG: Todo added to list. Total todos: ${todos.length}");
      
      // Save to user-specific key
      final userKey = _getUserTodosKey(_currentUserEmail!);
      final list = todos.map((element) => jsonEncode(element.toJson())).toList();
      await prefs.setStringList(userKey, list);
      print("DEBUG: Saved to SharedPreferences with key: $userKey");
      
      emit(LoadedState(todos: todos));
    } catch (e) {
      print("DEBUG: Error in addTodo: $e");
      emit(ErrorState(message: "Failed to add todo: $e"));
    }
  }

  Future<void> deleteTodo(int id) async {
    print("DEBUG: deleteTodo called with id: $id");
    
    if (_currentUserEmail == null) {
      emit(ErrorState(message: "No user logged in"));
      return;
    }
    
    try {
      todos.removeWhere((element) => element.id == id);
      
      final prefs = await SharedPreferences.getInstance();
      final userKey = _getUserTodosKey(_currentUserEmail!);
      final list = todos.map((element) => jsonEncode(element.toJson())).toList();
      await prefs.setStringList(userKey, list);
      
      print("DEBUG: Todo deleted. Remaining todos: ${todos.length}");
      
      if (todos.isEmpty) {
        emit(IntitialState());
      } else {
        emit(LoadedState(todos: todos));
      }
      
      emit(TodoDeletedSuccessfully());
    } catch (e) {
      print("DEBUG: Error in deleteTodo: $e");
      emit(ErrorState(message: "Failed to delete todo: $e"));
    }
  }

  Future<void> loadTodos() async {
    print("DEBUG: loadTodos called for user: $_currentUserEmail");
    
    if (_currentUserEmail == null) {
      emit(IntitialState());
      return;
    }
    
    try {
      emit(LoadingTodos());
      
      final prefs = await SharedPreferences.getInstance();
      final userKey = _getUserTodosKey(_currentUserEmail!);
      final stringList = prefs.getStringList(userKey) ?? [];
      print("DEBUG: Loaded from SharedPreferences: ${stringList.length} items for user: $_currentUserEmail");
      
      todos = stringList.map((element) {
        final map = jsonDecode(element);
        return TodoModel.fromJson(map);
      }).toList();
      
      // Additional filter to ensure only current user's todos (safety check)
      todos = todos.where((todo) => todo.email == _currentUserEmail).toList();
      
      print("DEBUG: Parsed todos count: ${todos.length}");
      
      if (todos.isEmpty) {
        emit(IntitialState());
      } else {
        emit(LoadedState(todos: todos));
      }
    } catch (e) {
      print("DEBUG: Error in loadTodos: $e");
      emit(ErrorState(message: "Failed to load todos: $e"));
    }
  }

  // Clear current user's todos
  Future<void> clearUserTodos() async {
    if (_currentUserEmail == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final userKey = _getUserTodosKey(_currentUserEmail!);
    await prefs.remove(userKey);
    todos.clear();
    emit(IntitialState());
  }

  // Clear all app data (for complete reset)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    todos.clear();
    _currentUserEmail = null;
    emit(IntitialState());
  }

  // Logout current user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_email');
    todos.clear();
    _currentUserEmail = null;
    emit(IntitialState());
  }

  // Check if user is logged in
  bool get isUserLoggedIn => _currentUserEmail != null;

  // Get all users who have todos (useful for user management)
  Future<List<String>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    return keys
        .where((key) => key.startsWith('${Constants.perKey}_'))
        .map((key) => key.replaceFirst('${Constants.perKey}_', ''))
        .toList();
  }

  // Set user email (call this after login) - Updated method
  void setUserEmail(String email) {
    setCurrentUser(email);
  }
}