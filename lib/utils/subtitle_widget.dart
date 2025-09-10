import 'package:flutter/material.dart';
import 'package:todo_app_debi/model/todo_model.dart';

class SubtitleWidget extends StatelessWidget {
  const SubtitleWidget(this.todo, this.isChecked);
  final TodoModel todo;
  final bool isChecked;
  @override
  Widget build(BuildContext context) {
   
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
}
