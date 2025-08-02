// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:manageon/models/task_model.dart';

// class TasksByStatusChart extends StatelessWidget {
//   final List<Task> tasks;
//   const TasksByStatusChart({super.key, required this.tasks});

//   @override
//   Widget build(BuildContext context) {
//     Map<String, int> statusCounts = {};
//     for (var task in tasks) {
//       statusCounts[task.statusName] = (statusCounts[task.statusName] ?? 0) + 1;
//     }
    
//     if (tasks.isEmpty) return const Center(child: Text('لا توجد بيانات'));

//     return BarChart(
//       BarChartData(
//         alignment: BarChartAlignment.spaceAround,
//         barGroups: statusCounts.entries.map((entry) {
//           return BarChartGroupData(
//             x: statusCounts.keys.toList().indexOf(entry.key),
//             barRods: [
//               BarChartRodData(toY: entry.value.toDouble(), color: Colors.amber, width: 15, borderRadius: BorderRadius.zero)
//             ],
//           );
//         }).toList(),
//         titlesData: FlTitlesData(
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 if (value.toInt() >= statusCounts.keys.length) return const Text('');
//                 return Text(
//                   statusCounts.keys.toList()[value.toInt()].substring(0,3),
//                   style: const TextStyle(fontSize: 10),
//                 );
//               },
//               reservedSize: 30,
//             ),
//           ),
//           leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//         ),
//       ),
//     );
//   }
// }
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:manageon/models/task_model.dart';

class TasksByStatusChart extends StatelessWidget {
  final List<Task> tasks;
  const TasksByStatusChart({super.key, required this.tasks});

  // قائمة بالألوان التي ستُستخدم لكل عمود
  static const List<Color> barColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber, // يمكنك إضافة المزيد من الألوان حسب الحاجة
  ];

  @override
  Widget build(BuildContext context) {
    Map<String, int> statusCounts = {};
    for (var task in tasks) {
      statusCounts[task.statusName] = (statusCounts[task.statusName] ?? 0) + 1;
    }

    if (tasks.isEmpty) return const Center(child: Text('لا توجد بيانات'));

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: statusCounts.entries.map((entry) {
          int index = statusCounts.keys.toList().indexOf(entry.key);
          // استخدم اللون من قائمة barColors بناءً على الفهرس
          Color barColor = barColors[index % barColors.length];

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                color: barColor, // هنا يتم تعيين اللون المختلف
                width: 50,
                borderRadius: BorderRadius.zero,
              )
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= statusCounts.keys.length) return const Text('');
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    statusCounts.keys.toList()[value.toInt()],
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }
}