import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo_app_debi/cubit/todo_cubit.dart';
import 'package:todo_app_debi/cubit/todo_state.dart';
import 'package:todo_app_debi/pages/details_page.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});
  static String id = "/todo";

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  Map<int, bool> _todoCheckedState = {};

  @override
  void initState() {
    super.initState();
    // CRITICAL: Load todos when page starts
    context.read<TodoCubit>().loadTodos();
  }

  void _showDeleteConfirmation(String todoTitle, VoidCallback onPressed) {
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
            onPressed: onPressed,
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodoCubit, TodoState>(
      builder: (context, state) {
        final todos = context.read<TodoCubit>().todos;

        // Update checkbox states for new/removed todos
        for (final todo in todos) {
          if (!_todoCheckedState.containsKey(todo.id)) {
            _todoCheckedState[todo.id] = false;
          }
        }
        _todoCheckedState.removeWhere(
          (todoId, _) => !todos.any((todo) => todo.id == todoId),
        );

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
            actions: const [
              Icon(Icons.search, color: Colors.black),
              SizedBox(width: 16),
            ],
          ),
          body: _buildBody(state, todos),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              // Wait for the result and reload if needed
              await Navigator.pushNamed(context, DetailsPage.id);
              // Optionally reload todos after returning from details page
              // context.read<TodoCubit>().loadTodos();
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
      listener: (context, state) {
        // More specific state handling
        if (state is LoadedState) {
          // You might want to create a specific state for "TodoAdded"
          // For now, let's not show toast on every LoadedState
        } else if (state is TodoDeletedSuccessfully) {
          Fluttertoast.showToast(
            msg: "Todo deleted successfully",
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 14,
            gravity: ToastGravity.BOTTOM,
          );
        }
      },
    );
  }

  Widget _buildBody(TodoState state, List todos) {
    if (state is LoadingTodos) {
      return const Center(child: CircularProgressIndicator());
    }

    if (todos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checklist_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No todos yet",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Tap the + button to add your first todo",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        final isChecked = _todoCheckedState[todo.id] ?? false;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            title: Text(
              todo.title,
              style: TextStyle(
                color: isChecked ? Colors.grey : Colors.black,
                decoration: isChecked ? TextDecoration.lineThrough : null,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: todo.desc.isNotEmpty
                ? Text(
                    todo.desc,
                    style: TextStyle(
                      color: isChecked ? Colors.grey : Colors.grey[600],
                      fontSize: 14,
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                    ),
                  )
                : null,
            leading: Checkbox(
              activeColor: Colors.green,
              value: isChecked,
              onChanged: (bool? check) {
                setState(() {
                  _todoCheckedState[todo.id] = check ?? false;
                });
              },
            ),
            trailing: IconButton(
              onPressed: () => _showDeleteConfirmation(todo.title, () {
                context.read<TodoCubit>().deleteTodo(todo.id);
                Navigator.of(context).pop();
              }),
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ),
        );
      },
    );
  }
}
