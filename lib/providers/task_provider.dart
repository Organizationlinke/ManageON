import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageon/constants.dart';
import 'package:manageon/global.dart';
import 'package:manageon/models/task_model.dart';

// فلتر القسم المختار
final departmentFilterProvider = StateProvider<String?>((ref) => null);

// جلب الأقسام
final departmentsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await supabase.from('departments').select();
  return List<Map<String, dynamic>>.from(response);
});
// Provider to fetch all tasks with their related data
final tasksProvider = FutureProvider<List<Task>>((ref) async {
  final response;
  user_level == 0
      ? response = await supabase
          .from('tasks')
          .select('*, status_table:status(*), usersin:assistant(*,department:departments(*))')
      :user_level == 1? response = await supabase
          .from('tasks')
          .select('*, status_table:status(*), usersin:assistant(*,department:departments(*))')
          .eq('assistant', user_id)
          :response = await supabase
          .from('tasks')
          .select('*, status_table:status(*), usersin:assistant(*,department:departments(*))')
          .eq('isfollow', true);

  final List<Task> tasks =
      (response as List).map((item) => Task.fromJson(item)).toList();

  return tasks;
});

// Provider to fetch all statuses
final statusesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response =user_level == 0?
  await supabase.from('status').select().lte('id', 4).order('id', ascending: true)
  : await supabase.from('status').select().lte('id', 3).order('id', ascending: true);
  return List<Map<String, dynamic>>.from(response);
});
