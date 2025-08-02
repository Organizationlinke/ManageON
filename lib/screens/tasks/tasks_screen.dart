// This is a simplified version. A full Kanban board with drag-and-drop is more complex.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageon/global.dart';
import 'package:manageon/providers/task_provider.dart';
import 'package:manageon/screens/tasks/task_detail_screen.dart';
import 'package:manageon/widgets/task/task_card.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    final statusesAsync = ref.watch(statusesProvider);

    return Scaffold(
      body: tasksAsync.when(
        data: (tasks) {
          return statusesAsync.when(
            data: (statuses) {
              return DefaultTabController(
                length: statuses.length,
                child: Column(
                  children: [
                    TabBar(
                      isScrollable: true,
                      tabs: statuses.map((s) => Tab(text: s['status_name'])).toList(),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: statuses.map((status) {
                          final filteredTasks = tasks.where((task) => task.statusId == status['id']).toList();
                          return RefreshIndicator(
                            onRefresh: () => ref.refresh(tasksProvider.future),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8.0),
                              itemCount: filteredTasks.length,
                              itemBuilder: (context, index) {
                                return TaskCard(task: filteredTasks[index]);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('خطأ في تحميل الحالات: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('خطأ في تحميل المهام: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const TaskDetailScreen()),
          ).then((_) => ref.refresh(tasksProvider)); // Refresh list after adding/editing
        },
        backgroundColor: colorbar,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}