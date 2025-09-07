import 'package:todo_app_debi/model/todo_model.dart';

abstract class TodoState {}

class IntitialState extends TodoState {}

class LoadedState extends TodoState {
  final List<TodoModel> todos;
  LoadedState({required this.todos});
}

class ErrorState extends TodoState {
  String message;
  ErrorState({required this.message});
}

class TodoDeletedSuccessfully extends TodoState {}

class LoadingTodos extends TodoState {}
