import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:manageon/models/task_model.dart';
import 'package:manageon/models/user_model.dart';

class TeamWorkloadChart extends StatelessWidget {
  final List<Task> tasks;
  final List<AppUser> users;
  const TeamWorkloadChart({super.key, required this.tasks, required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return const Center(child: Text('لا يوجد مستخدمين لعرضهم'));

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: users.map((user) {
          final taskCount = tasks.where((task) => task.assistantId == user.id).length;
          final userIndex = users.indexOf(user);
          return BarChartGroupData(
            x: userIndex,
            barRods: [
              BarChartRodData(
                toY: taskCount.toDouble(),
                color: Colors.deepOrangeAccent,
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