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
    // Load todos for the current logged-in user
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

  Widget? _buildSubtitle(dynamic todo, bool isChecked) {
    // Debug prints to check the data
    print("DEBUG: Todo title: ${todo.title}");
    print("DEBUG: Todo desc: '${todo.desc}' (length: ${todo.desc.length})");
    print(
      "DEBUG: Todo deadLine: '${todo.deadLine}' (length: ${todo.deadLine.length})",
    );

    // Check if both desc and deadline are empty
    if (todo.desc.isEmpty && todo.deadLine.isEmpty) {
      return null; // No subtitle needed
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description
        if (todo.desc.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            todo.desc,
            style: TextStyle(
              color: isChecked ? Colors.grey : Colors.grey[600],
              fontSize: 14,
              decoration: isChecked ? TextDecoration.lineThrough : null,
            ),
          ),
        ],

        // Deadline
        if (todo.deadLine.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: isChecked ? Colors.grey : Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                todo.deadLine,
                style: TextStyle(
                  color: isChecked ? Colors.grey : Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await context.read<TodoCubit>().logout();
              if (mounted) {
                // Navigate back to login - adjust route as needed
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showUserMenu() {
    final todoCubit = context.read<TodoCubit>();
    final currentUser = todoCubit.email ?? 'User';

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: Text('Logged in as: $currentUser'),
              subtitle: Text('${todoCubit.todos.length} todos'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.green),
              title: const Text('Refresh Todos'),
              onTap: () {
                Navigator.pop(context);
                context.read<TodoCubit>().loadTodos();
                Fluttertoast.showToast(
                  msg: "Todos refreshed",
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep, color: Colors.red),
              title: const Text('Clear All My Todos'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Todos'),
                    content: const Text(
                      'This will delete all your todos. This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await context.read<TodoCubit>().clearUserTodos();
                          Fluttertoast.showToast(
                            msg: "All todos cleared",
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.orange),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _showLogoutConfirmation();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodoCubit, TodoState>(
      builder: (context, state) {
        final todoCubit = context.read<TodoCubit>();
        final todos = todoCubit.todos;
        final currentUser = todoCubit.email ?? 'User';

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
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Todos',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currentUser,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  // Implement search functionality if needed
                  Fluttertoast.showToast(
                    msg: "Search feature coming soon!",
                    backgroundColor: Colors.blue,
                    textColor: Colors.white,
                  );
                },
                icon: const Icon(Icons.search, color: Colors.black),
              ),
              IconButton(
                onPressed: _showUserMenu,
                icon: const Icon(Icons.account_circle, color: Colors.black),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: _buildBody(state, todos),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              // Navigate to add todo page
              final result = await Navigator.pushNamed(context, DetailsPage.id);

              // Reload todos if a new todo was added
              if (result == true) {
                context.read<TodoCubit>().loadTodos();
              }
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
      listener: (context, state) {
        // Handle different states
        if (state is TodoDeletedSuccessfully) {
          Fluttertoast.showToast(
            msg: "Todo deleted successfully",
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 14,
            gravity: ToastGravity.BOTTOM,
          );
        } else if (state is ErrorState) {
          Fluttertoast.showToast(
            msg: state.message,
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              "Loading your todos...",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (state is ErrorState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              "Error: ${state.message}",
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<TodoCubit>().loadTodos(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
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

    return RefreshIndicator(
      onRefresh: () async {
        context.read<TodoCubit>().loadTodos();
      },
      child: ListView.builder(
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
              subtitle: _buildSubtitle(todo, isChecked),
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
      ),
    );
  }
}
