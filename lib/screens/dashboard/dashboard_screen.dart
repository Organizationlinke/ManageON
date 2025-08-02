import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageon/providers/task_provider.dart';
import 'package:manageon/widgets/charts/tasks_by_priority_chart.dart';
import 'package:manageon/widgets/charts/tasks_by_status_chart.dart';
import 'package:manageon/widgets/dashboard/stat_card.dart';
import 'package:manageon/widgets/dashboard/upcoming_tasks_list.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsyncValue = ref.watch(tasksProvider);

    return tasksAsyncValue.when(
      data: (tasks) {
        final inProgress = tasks.where((t) => t.statusId == 2).length; // Assuming 2 is 'In Progress'
        final completed = tasks.where((t) => t.statusId == 3).length; // Assuming 4 is 'Completed'
        final overdue = tasks.where((t) => t.deadline.isBefore(DateTime.now()) && t.statusId != 4).length;

        return RefreshIndicator(
          onRefresh: () => ref.refresh(tasksProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  StatCard(title: 'إجمالي المهام', value: tasks.length.toString(), icon: Icons.list_alt, color: Colors.blue),
                  StatCard(title: 'قيد التنفيذ', value: inProgress.toString(), icon: Icons.sync, color: Colors.orange),
                  StatCard(title: 'مكتملة', value: completed.toString(), icon: Icons.check_circle, color: Colors.green),
                  StatCard(title: 'متأخرة', value: overdue.toString(), icon: Icons.warning, color: Colors.red),
                ],
              ),
              const SizedBox(height: 24),
              const Text('المهام حسب الحالة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(
                height: 200,
                child: TasksByStatusChart(tasks: tasks),
              ),
              const SizedBox(height: 24),
              const Text('المهام حسب الأولوية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(
                height: 200,
                child: TasksByPriorityChart(tasks: tasks),
              ),
              const SizedBox(height: 24),
              const Text('المهام القادمة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              UpcomingTasksList(tasks: tasks),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('خطأ: ${err.toString()}')),
    );
  }
}