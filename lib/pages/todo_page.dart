import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo_app_debi/cubit/todo_cubit.dart';
import 'package:todo_app_debi/cubit/todo_state.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});
  static String id = "/todo";

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  Map<int, bool> _todoCheckedState = {};
  TextEditingController text = TextEditingController();
  void _showDeleteConfirmation(String todoTitle, VoidCallback onpressed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: Text('Are you sure you want to delete "$todoTitle"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: onpressed,

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Now Todo"),
          content: TextField(
            controller: text,
            decoration: const InputDecoration(
              hintText: 'Enter todo title',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                text.clear();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (text.text.trim().isNotEmpty) {
                  context.read<TodoCubit>().addTodo(text.text.trim());
                  Navigator.of(context).pop();
                  text.clear();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodoCubit, TodoState>(
      builder: (context, state) {
        final todos = context.read<TodoCubit>().todos;
        for (final todo in todos) {
          if (!_todoCheckedState.containsKey(todo.id)) {
            _todoCheckedState[todo.id] = false;
          }
          _todoCheckedState.removeWhere(
            (todoId, _) => !todos.any((todo) => todo.id == todoId),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'My Todos',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: const [Icon(Icons.search, color: Colors.black)],
          ),
          body: state is LoadedState
              ? Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: todos.length,
                        itemBuilder: (context, index) {
                          final todo = todos[index];
                          final isChecked = _todoCheckedState[todo.id] ?? false;

                          return ListTile(
                            title: Text(
                              todo.title,
                              style: TextStyle(
                                color: isChecked ? Colors.red : Colors.black,
                                decoration: isChecked
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            leading: Checkbox(
                              activeColor: Colors.green,
                              value: _todoCheckedState[todo.id],
                              onChanged: (bool? check) {
                                setState(() {
                                  _todoCheckedState[todo.id] = check!;
                                });
                              },
                            ),
                            trailing: IconButton(
                              onPressed: () => _showDeleteConfirmation(
                                todo.title,
                                () {
                                  context.read<TodoCubit>().deleteTodo(todo.id);
                                  Navigator.of(context).pop();
                                },
                              ),
                              icon: Icon(Icons.delete, color: Colors.red),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )
              : state is LoadingTodos
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: Text(
                    "No Todo 's yet",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showDialog();
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
      listener: (context, state) {
        if (state is LoadedState) {
          Fluttertoast.showToast(
            msg: "Todo added sucessfuly",
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 14,
            gravity: ToastGravity.SNACKBAR,
          );
        } else if (state is TodoDeletedSuccessfully) {
          Fluttertoast.showToast(
            msg: "Todo deleted Succecfully",
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 14,
            gravity: ToastGravity.SNACKBAR,
          );
        }
      },
    );
  }
}
