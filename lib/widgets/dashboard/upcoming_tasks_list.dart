import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manageon/models/task_model.dart';
import 'package:manageon/screens/tasks/task_detail_screen.dart';

class UpcomingTasksList extends StatelessWidget {
  final List<Task> tasks;
  const UpcomingTasksList({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final upcoming = tasks.where((t) => t.deadline.isAfter(DateTime.now()) && t.statusId != 4).toList();
    upcoming.sort((a, b) => a.deadline.compareTo(b.deadline));

    if (upcoming.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('لا توجد مهام قادمة'),
      ));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: upcoming.length > 5 ? 5 : upcoming.length, // Show top 5
      itemBuilder: (context, index) {
        final task = upcoming[index];
        return ListTile(
          title: Text(task.title),
          subtitle: Text('المسؤول: ${task.assistantName ?? 'غير محدد'}'),
          trailing: Text(DateFormat('yyyy-MM-dd').format(task.deadline)),
          onTap: () {
             Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
            );
          },
        );
      },
    );
  }
}