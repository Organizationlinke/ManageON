import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:manageon/models/task_model.dart';
import 'package:manageon/models/user_model.dart';

class TeamPerformanceChart extends StatelessWidget {
  final List<Task> tasks;
  final List<AppUser> users;
  const TeamPerformanceChart({super.key, required this.tasks, required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return const Center(child: Text('لا يوجد مستخدمين لعرضهم'));

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: users.map((user) {
          final completedCount = tasks.where((t) => t.assistantId == user.id && t.statusId == 4).length; // Assuming 4 is 'Completed'
          final overdueCount = tasks.where((t) => t.assistantId == user.id && t.deadline.isBefore(DateTime.now()) && t.statusId != 4).length;
          final userIndex = users.indexOf(user);

          return BarChartGroupData(
            x: userIndex,
            barRods: [
              BarChartRodData(
                toY: (completedCount + overdueCount).toDouble(),
                rodStackItems: [
                  BarChartRodStackItem(0, completedCount.toDouble(), Colors.green),
                  BarChartRodStackItem(completedCount.toDouble(), (completedCount + overdueCount).toDouble(), Colors.red),
                ],
                width: 50,
                borderRadius: BorderRadius.zero,
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= users.length) return const Text('');
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4,
                  child: Text(
                    users[value.toInt()].fullName.split(' ').first, // Show first name
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 32,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }
}
