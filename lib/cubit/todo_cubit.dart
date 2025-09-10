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

  Future<void> setCurrentUser(String userEmail) async {
    print("DEBUG: Setting current user: $userEmail");
    _currentUserEmail = userEmail;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.currentUser, userEmail);

    await loadTodos();
  }

  Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserEmail = prefs.getString(Constants.currentUser);
    return _currentUserEmail;
  }

  String _getUserTodosKey(String userEmail) {
    return '${Constants.perKey}_$userEmail';
  }

  Future<void> addTodo(
    String title, {
    String? description,
    String? deadline,
  }) async {
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

      final todoDescription = description ?? _desc ?? '';
      final todoDeadline = deadline ?? _deadLine ?? '';

      print("DEBUG: Final desc to save: '$todoDescription'");
      print("DEBUG: Final deadline to save: '$todoDeadline'");

      final TodoModel newTodo = TodoModel(
        id: random,
        title: title,
        email: _currentUserEmail!,
        desc: todoDescription,
        deadLine: todoDeadline,
      );

      todos.add(newTodo);
      print("DEBUG: Todo added to list. Total todos: ${todos.length}");

      // Save to user-specific key
      final userKey = _getUserTodosKey(_currentUserEmail!);
      final list = todos
          .map((element) => jsonEncode(element.toJson()))
          .toList();
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
      final list = todos
          .map((element) => jsonEncode(element.toJson()))
          .toList();
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
      print(
        "DEBUG: Loaded from SharedPreferences: ${stringList.length} items for user: $_currentUserEmail",
      );

      todos = stringList.map((element) {
        final map = jsonDecode(element);
        return TodoModel.fromJson(map);
      }).toList();

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

  Future<void> clearUserTodos() async {
    if (_currentUserEmail == null) return;

    final prefs = await SharedPreferences.getInstance();
    final userKey = _getUserTodosKey(_currentUserEmail!);
    await prefs.remove(userKey);
    todos.clear();
    emit(IntitialState());
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    todos.clear();
    _currentUserEmail = null;
    emit(IntitialState());
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${Constants.currentUser}');
    todos.clear();
    _currentUserEmail = null;
    emit(IntitialState());
  }

  bool get isUserLoggedIn => _currentUserEmail != null;

  Future<List<String>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    return keys
        .where((key) => key.startsWith('${Constants.perKey}_'))
        .map((key) => key.replaceFirst('${Constants.perKey}_', ''))
        .toList();
  }

  // Add this method inside your TodoCubit class
  // It updates an existing todo in the list and in SharedPreferences.
  Future<void> updateTodo(TodoModel updatedTodo) async {
    if (_currentUserEmail == null) {
      emit(ErrorState(message: "No user logged in"));
      return;
    }

    try {
      // Find the index of the todo to update
      final int index = todos.indexWhere((t) => t.id == updatedTodo.id);
      if (index != -1) {
        // Replace the old todo with the updated one
        todos[index] = updatedTodo;

        // Save the updated list to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final userKey = _getUserTodosKey(_currentUserEmail!);
        final list = todos
            .map((element) => jsonEncode(element.toJson()))
            .toList();
        await prefs.setStringList(userKey, list);

        // Emit the new state with the updated list
        emit(LoadedState(todos: todos));
      } else {
        emit(ErrorState(message: "Todo not found"));
      }
    } catch (e) {
      emit(ErrorState(message: "Failed to update todo: $e"));
    }
  }

  // Add this method inside your TodoCubit class
  // It toggles the `isCompleted` status of a todo and saves the change.
  Future<void> updateTodoStatus(int id, bool isCompleted) async {
    if (_currentUserEmail == null) {
      emit(ErrorState(message: "No user logged in"));
      return;
    }

    try {
      // Find the todo by its ID
      final int index = todos.indexWhere((t) => t.id == id);
      if (index != -1) {
        // Get the existing todo and create a new copy with the updated status
        final todoToUpdate = todos[index];
        final updatedTodo = todoToUpdate.copyWith(isCompleted: isCompleted);

        // Update the todo in the list
        todos[index] = updatedTodo;

        // Save the changes to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final userKey = _getUserTodosKey(_currentUserEmail!);
        final list = todos
            .map((element) => jsonEncode(element.toJson()))
            .toList();
        await prefs.setStringList(userKey, list);

        // Emit the new state to refresh the UI
        emit(LoadedState(todos: todos));
      } else {
        emit(ErrorState(message: "Todo not found"));
      }
    } catch (e) {
      emit(ErrorState(message: "Failed to update todo status: $e"));
    }
  }

  Future<void> toggleTodoStatus(int id) async {
    if (_currentUserEmail == null) {
      emit(ErrorState(message: "No user logged in"));
      return;
    }

    try {
      final int index = todos.indexWhere((t) => t.id == id);
      if (index != -1) {
        final todoToUpdate = todos[index];
        final updatedTodo = todoToUpdate.copyWith(
          isCompleted: !todoToUpdate.isCompleted,
        );
        todos[index] = updatedTodo;

        final prefs = await SharedPreferences.getInstance();
        final userKey = _getUserTodosKey(_currentUserEmail!);
        final list = todos
            .map((element) => jsonEncode(element.toJson()))
            .toList();
        await prefs.setStringList(userKey, list);

        emit(LoadedState(todos: todos));
      } else {
        emit(ErrorState(message: "Todo not found"));
      }
    } catch (e) {
      emit(ErrorState(message: "Failed to toggle todo status: $e"));
    }
  }

  void setUserEmail(String email) {
    setCurrentUser(email);
  }
}
