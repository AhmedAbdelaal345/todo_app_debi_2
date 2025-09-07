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
  String? _email;
  String? _desc;
  String? _deadLine;

  // Fixed setters
  set email(TextEditingController emailController) {
    _email = emailController.text;
  }

  set desc(TextEditingController descController) {
    _desc = descController.text;  // ✅ Fixed: was setting _email
  }

  set deadLine(TextEditingController deadLineController) {
    _deadLine = deadLineController.text;  // ✅ Fixed: was setting _email
  }

  // Getters
  String? get email => _email;
  String? get desc => _desc;
  String? get deadLine => _deadLine;

  // Better approach: Accept parameters directly
  Future<void> addTodo(String title, {String? description, String? deadline}) async {
    print("DEBUG: addTodo called with title: $title"); // Debug
    
    try {
      SharedPreferences per = await SharedPreferences.getInstance();
      final random = Random().nextInt(100000);
      
      final newTodo = TodoModel(
        id: random, 
        title: title, 
        email: _email ?? '', 
        desc: description ?? _desc ?? '', 
        deadLine: deadline ?? _deadLine ?? ''
      );
      
      todos.add(newTodo);
      print("DEBUG: Todo added to list. Total todos: ${todos.length}"); // Debug
      
      final list = todos.map((element) => jsonEncode(element.toJson())).toList();
      await per.setStringList(Constants.perKey, list);
      print("DEBUG: Saved to SharedPreferences"); // Debug
      
      emit(LoadedState(todos: todos));
    } catch (e) {
      print("DEBUG: Error in addTodo: $e"); // Debug
      emit(ErrorState(message: "Failed to add todo: $e"));
    }
  }

  Future<void> deleteTodo(int id) async {
    print("DEBUG: deleteTodo called with id: $id"); // Debug
    
    try {
      todos.removeWhere((element) => element.id == id);
      
      final prefs = await SharedPreferences.getInstance();
      // ✅ Fixed: Save updated list instead of removing wrong key
      final list = todos.map((element) => jsonEncode(element.toJson())).toList();
      await prefs.setStringList(Constants.perKey, list);
      
      print("DEBUG: Todo deleted. Remaining todos: ${todos.length}"); // Debug
      
      if (todos.isEmpty) {
        emit(IntitialState());
      } else {
        emit(LoadedState(todos: todos));
      }
      
      // Emit specific delete success state
      emit(TodoDeletedSuccessfully());
    } catch (e) {
      print("DEBUG: Error in deleteTodo: $e"); // Debug
      emit(ErrorState(message: "Failed to delete todo: $e"));
    }
  }

  Future<void> loadTodos() async {
    print("DEBUG: loadTodos called"); // Debug
    
    try {
      emit(LoadingTodos()); // Show loading state
      
      final prefs = await SharedPreferences.getInstance();
      final stringList = prefs.getStringList(Constants.perKey) ?? [];
      print("DEBUG: Loaded from SharedPreferences: ${stringList.length} items"); // Debug
      
      todos = stringList.map((element) {
        final map = jsonDecode(element);
        return TodoModel.fromJson(map);
      }).toList();
      
      print("DEBUG: Parsed todos count: ${todos.length}"); // Debug
      
      if (todos.isEmpty) {
        emit(IntitialState());
      } else {
        emit(LoadedState(todos: todos));
      }
    } catch (e) {
      print("DEBUG: Error in loadTodos: $e"); // Debug
      emit(ErrorState(message: "Failed to load todos: $e"));
    }
  }

  // Clear all data (useful for logout)
  Future<void> clearTodos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.perKey);
    todos.clear();
    emit(IntitialState());
  }

  // Set user email (call this after login)
  void setUserEmail(String email) {
    _email = email;
  }
}