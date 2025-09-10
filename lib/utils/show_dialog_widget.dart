import 'package:flutter/material.dart';

class ShowDialogWidget extends StatelessWidget {
  const ShowDialogWidget(this.todoTitle, this.onPressed, {super.key});

  final String todoTitle;
  final VoidCallback onPressed;
  Widget build(BuildContext context) {
    return Builder(
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
}
