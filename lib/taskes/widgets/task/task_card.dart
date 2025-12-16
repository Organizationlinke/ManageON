import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manageon/taskes/models/task_model.dart';
import 'package:manageon/taskes/providers/task_provider.dart';
import 'package:manageon/taskes/screens/tasks/task_detail_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskCard extends ConsumerWidget {
  final Task task;
  const TaskCard({super.key, required this.task});

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High': return Colors.red;
      case 'Medium': return Colors.orange;
      case 'Low': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: task.assistantAvatar != null && task.assistantAvatar!.isNotEmpty
              ? NetworkImage(task.assistantAvatar!)
              : null,
          child: task.assistantAvatar == null || task.assistantAvatar!.isEmpty
              ? Text(task.assistantName?.substring(0, 1) ?? '?')
              : null,
        ),
        title: Text(task.title),
        subtitle: Text('تنتهي في: ${DateFormat('yyyy-MM-dd').format(task.deadline)}'),
        trailing: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: _getPriorityColor(task.priority),
            shape: BoxShape.circle,
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
          ).then((_) => ref.invalidate(tasksProvider)); // Refresh list after editing
        },
      ),
    );
  }
}