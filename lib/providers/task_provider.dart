import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageon/constants.dart';
import 'package:manageon/models/task_model.dart';

// Provider to fetch all tasks with their related data
final tasksProvider = FutureProvider<List<Task>>((ref) async {
  final response = await supabase
      .from('tasks')
      .select('*, status_table:status(*), usersin:assistant(*)');
      
  final List<Task> tasks = (response as List)
      .map((item) => Task.fromJson(item))
      .toList();
      
  return tasks;
});
// Provider to fetch all statuses
final statusesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await supabase.from('status').select();
  return List<Map<String, dynamic>>.from(response);
});

