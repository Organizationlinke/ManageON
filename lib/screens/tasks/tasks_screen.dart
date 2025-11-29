import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageon/global.dart';
import 'package:manageon/providers/task_provider.dart';
import 'package:manageon/screens/tasks/task_detail_screen.dart';
import 'package:manageon/widgets/task/task_card.dart';
import 'package:manageon/models/task_model.dart';

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
                    // 🔵 فلتر الأقسام أعلى الشاشة
                    if (user_level == 0) _buildDepartmentFilter(ref),

                    // 🔵 TabBar للحالات
                    // TabBar(
                    //   isScrollable: false,
                    //   labelPadding: EdgeInsets.zero,
                    //   tabs: statuses.map((s) => Tab(text: s['status_name'])).toList(),
                    // ),
                    TabBar(
                      isScrollable: false,
                      labelPadding: EdgeInsets.zero,
                      tabs: statuses.map((s) {
                        final statusId = s['id'];

                        // عدد المهام بعد الفلترة (القسم + الحالة)
                        final count = tasks.where((task) {
                          final byStatus = task.statusId == statusId;

                          final selectedDept =
                              ref.watch(departmentFilterProvider);
                          final byDept = selectedDept == null ||
                              task.departmentName == selectedDept;

                          return byStatus && byDept;
                        }).length;

                        return Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(s['status_name']),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  count.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    Expanded(
                      child: TabBarView(
                        children: statuses.map((status) {
                          return _buildTaskList(
                            ref,
                            tasks,
                            status['id'],
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

      // 🔵 زر إضافة مهمة
      floatingActionButton:user_level==0? FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                    builder: (context) => const TaskDetailScreen()),
              )
              .then((_) => ref.refresh(tasksProvider));
        },
        backgroundColor: colorbar,
        child: const Icon(Icons.add, color: Colors.white),
      ):null,
    );
  }

  // ---------------------------------------------------------
  // 🔵 ويدجيت فلتر الأقسام
  // ---------------------------------------------------------
  Widget _buildDepartmentFilter(WidgetRef ref) {
    final departmentsAsync = ref.watch(departmentsProvider);
    final selectedDept = ref.watch(departmentFilterProvider);

    return departmentsAsync.when(
      data: (departments) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              // زر "كل الأقسام"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: const Text("كل الأقسام"),
                  selected: selectedDept == null,
                  onSelected: (_) {
                    ref.read(departmentFilterProvider.notifier).state = null;
                  },
                ),
              ),
              // أزرار كل قسم
              ...departments.map((d) {
                final deptName = d['department_name'] as String?;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(deptName ?? ''),
                    selected: selectedDept == deptName,
                    onSelected: (_) {
                      ref.read(departmentFilterProvider.notifier).state =
                          deptName;
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(),
      ),
      error: (e, s) => const Text("خطأ في تحميل الأقسام"),
    );
  }

  // ---------------------------------------------------------
  // 🔵 ويدجيت قائمة المهام داخل TabBarView
  // ---------------------------------------------------------
  Widget _buildTaskList(WidgetRef ref, List<Task> tasks, int statusId) {
    final selectedDept = ref.watch(departmentFilterProvider);

    // فلترة حسب الحالة + القسم
    final filteredTasks = tasks.where((task) {
      final byStatus = task.statusId == statusId;

      final byDept = selectedDept == null ||
          // (task.user?.department?.department_name == selectedDept);
          (task.departmentName == selectedDept);

      return byStatus && byDept;
    }).toList();

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
  }
}
