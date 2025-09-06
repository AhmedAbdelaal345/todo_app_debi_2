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
  String ?_email;
  set email(TextEditingController emailController) {
    _email = emailController.text;
  }

  get email => _email;
  Future<void> addTodo(String title) async {
    SharedPreferences per = await SharedPreferences.getInstance();
    final random = Random().nextInt(100000);
    todos.add(TodoModel(id: random, title: title, email: email));
    final list = todos.map((element) {
      return jsonEncode(element.toJson());
    }).toList();
    per.setStringList(Constants.perKey, list);
    emit(LoadedState(todos: todos));
  }

  Future<void> deleteTodo(int id) async {
    todos.removeWhere((element) => element.id == id);
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(id.toString());

    if (todos.isEmpty) {
      emit(IntitialState());
    } else {
      emit(LoadedState(todos: todos));
    }
  }

  void loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = prefs.getStringList(Constants.perKey) ?? [];
    todos = stringList.map((element) {
      final map = jsonDecode(element);
      return TodoModel.fromJson(map);
    }).toList();

    if (todos.isEmpty) {
      emit(IntitialState());
    } else {
      emit(LoadedState(todos: todos));
    }
  }
}
