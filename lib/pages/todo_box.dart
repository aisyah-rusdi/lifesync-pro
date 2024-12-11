import 'package:flutter/material.dart';

class TodoBox extends StatelessWidget {
  final String taskName;
  final bool taskCompleted;
  final DateTime taskDateTime;
  final ValueChanged<bool?> onChanged;
  final VoidCallback deleteFunction;
  final VoidCallback editFunction;

  const TodoBox({
    Key? key,
    required this.taskName,
    required this.taskCompleted,
    required this.taskDateTime,
    required this.onChanged,
    required this.deleteFunction,
    required this.editFunction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: taskCompleted,
              onChanged: onChanged,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    taskName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: taskCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Due: ${_formatDateTime(taskDateTime)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: editFunction,
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: deleteFunction,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Formats the DateTime into a readable string.
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} '
        '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
  }

  /// Ensures single-digit numbers are displayed as two digits (e.g., "1" -> "01").
  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }
}
