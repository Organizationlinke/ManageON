import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:manageon/models/task_model.dart';

class TasksByPriorityChart extends StatelessWidget {
  final List<Task> tasks;
  const TasksByPriorityChart({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final high = tasks.where((t) => t.priority == 'High').length;
    final medium = tasks.where((t) => t.priority == 'Medium').length;
    final low = tasks.where((t) => t.priority == 'Low').length;
    
    if (tasks.isEmpty) return const Center(child: Text('لا توجد بيانات'));

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(value: high.toDouble(), title: '$high', color: Colors.red, radius: 50, titleStyle: const TextStyle(color: Colors.white)),
          PieChartSectionData(value: medium.toDouble(), title: '$medium', color: Colors.orange, radius: 50, titleStyle: const TextStyle(color: Colors.white)),
          PieChartSectionData(value: low.toDouble(), title: '$low', color: Colors.green, radius: 50, titleStyle: const TextStyle(color: Colors.white)),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
}