import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageon/providers/task_provider.dart';
import 'package:manageon/providers/user_provider.dart';
import 'package:manageon/widgets/charts/tasks_by_priority_chart.dart';
import 'package:manageon/widgets/charts/tasks_by_status_chart.dart';
import 'package:manageon/widgets/charts/team_performance_chart.dart';
import 'package:manageon/widgets/charts/team_workload_chart.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  Widget _buildChartCard(BuildContext context, {required String title, required Widget chart}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            SizedBox(height: 250, child: chart),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      body: tasksAsync.when(
        data: (tasks) {
          return usersAsync.when(
            data: (users) {
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(tasksProvider);
                  ref.invalidate(allUsersProvider);
                },
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildChartCard(
                      context,
                      title: 'توزيع المهام حسب الحالة',
                      chart: TasksByStatusChart(tasks: tasks),
                    ),
                    const SizedBox(height: 16),
                    _buildChartCard(
                      context,
                      title: 'أعباء عمل الفريق',
                      chart: TeamWorkloadChart(tasks: tasks, users: users),
                    ),
                    const SizedBox(height: 16),
                    _buildChartCard(
                      context,
                      title: 'أداء الفريق (مكتمل مقابل متأخر)',
                      chart: TeamPerformanceChart(tasks: tasks, users: users),
                    ),
                    const SizedBox(height: 16),
                     _buildChartCard(
                      context,
                      title: 'المهام حسب الأولوية',
                      chart: TasksByPriorityChart(tasks: tasks),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('خطأ في تحميل المستخدمين: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('خطأ في تحميل المهام: $e')),
      ),
    );
  }
}
