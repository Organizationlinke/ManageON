import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:manageon/constants.dart';
import 'package:manageon/global.dart';
import 'package:manageon/models/task_model.dart';
import 'package:manageon/providers/task_provider.dart';
import 'package:manageon/providers/user_provider.dart';
import 'package:manageon/screens/tasks/ProceduresScreen.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final Task? task;
  const TaskDetailScreen({super.key, this.task});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _deadline;
  int? _selectedStatusId;
  int? _selectedAssistantId;
  String _selectedPriority = 'Medium';
  bool _isLoading = false;
  bool isadmin = user_level == 0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title);
    _descriptionController =
        TextEditingController(text: widget.task?.description);
    _deadline = widget.task?.deadline;
    _selectedStatusId = widget.task?.statusId ?? 1;
    _selectedAssistantId = widget.task?.assistantId;
    _selectedPriority = widget.task?.priority ?? 'Medium';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null && picked != _deadline) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      if (_deadline == null) {
        showSnackBar(context, 'الرجاء تحديد تاريخ الانتهاء', isError: true);
        return;
      }

      setState(() => _isLoading = true);

      final taskData = {
        'title': _titleController.text,
        'sub_title': _descriptionController.text,
        'deadline': _deadline!.toIso8601String(),
        'status_id': _selectedStatusId,
        'assistant': _selectedAssistantId,
        'priority': _selectedPriority,
      };

      try {
        if (widget.task == null) {
          // New Task
          await supabase.from('tasks').insert(taskData);
        } else {
          // Update Task
          await supabase
              .from('tasks')
              .update(taskData)
              .eq('id', widget.task!.id);
        }
        ref.invalidate(tasksProvider); // Invalidate provider to force a refresh
        if (mounted) {
          showSnackBar(context, 'تم حفظ المهمة بنجاح');
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          showSnackBar(context, 'فشل حفظ المهمة: $e', isError: true);
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusesAsync = ref.watch(statusesProvider);
    final usersAsync = ref.watch(allUsersProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(12.0),
          child: 
        Row(
  children: [
    Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorbar,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () {
          if (widget.task == null) {
            showSnackBar(context, "يجب حفظ المهمة أولاً قبل تسجيل الإجراءات",
                isError: true);
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProceduresScreen(
                taskId: widget.task!.id,
                type: 1,
              ),
            ),
          );
        },
        child: const Text(
          "الإجراءات",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    ),

    const SizedBox(width: 12),

    Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorbar,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () {
          if (widget.task == null) {
            showSnackBar(context, "يجب حفظ المهمة أولاً قبل تسجيل المتابعات",
                isError: true);
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProceduresScreen(
                taskId: widget.task!.id,
                type: 2,
              ),
            ),
          );
        },
        child: const Text(
          "المتابعات",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    ),
  ],
)

        ),
        appBar: AppBar(
          title: Text(widget.task == null ? 'مهمة جديدة' : 'تعديل المهمة'),
          actions: [
            if (widget.task != null && isadmin)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () async {
                  // Add confirmation dialog
                  await supabase
                      .from('tasks')
                      .delete()
                      .eq('id', widget.task!.id);
                  ref.invalidate(tasksProvider);
                  if (mounted) {
                    showSnackBar(context, 'تم حذف المهمة');
                    Navigator.of(context).pop();
                  }
                },
              )
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    TextFormField(
                      controller: _titleController,
                      enabled: isadmin,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          labelText: 'عنوان المهمة'),
                      validator: (value) =>
                          value!.isEmpty ? 'هذا الحقل مطلوب' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      enabled: isadmin,
                      decoration: InputDecoration(
                        labelText: 'الوصف',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    // Deadline
                    Card(
                      child: ListTile(
                        title: Text(
                            'تاريخ الانتهاء: ${_deadline == null ? 'غير محدد' : DateFormat('yyyy-MM-dd').format(_deadline!)}'),
                        trailing: const Icon(
                          Icons.calendar_today,
                          color: colorbar,
                        ),
                        onTap: isadmin ? _selectDate : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Priority
                    DropdownButtonFormField<String>(
                      value: _selectedPriority,

                      decoration: InputDecoration(
                        labelText: 'الأولوية',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      items: ['Low', 'Medium', 'High'].map((p) {
                        return DropdownMenuItem(value: p, child: Text(p));
                      }).toList(),
                      onChanged: isadmin
                          ? (value) {
                              setState(() => _selectedPriority = value!);
                            }
                          : null, // <<< تعطيل
                    ),
                    const SizedBox(height: 16),
                    // Status
                    statusesAsync.when(
                      data: (statuses) => DropdownButtonFormField<int>(
                        value: _selectedStatusId,
                        decoration: InputDecoration(
                          labelText: 'الحالة',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        items: statuses.map((s) {
                          return DropdownMenuItem(
                              value: s['id'] as int,
                              child: Text(s['status_name']));
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedStatusId = value),
                        validator: (value) =>
                            value == null ? 'اختر حالة' : null,
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Text('خطأ: $e'),
                    ),
                    const SizedBox(height: 16),
                    // Assistant
                    usersAsync.when(
                      data: (users) => DropdownButtonFormField<int>(
                        value: _selectedAssistantId,
                        decoration: InputDecoration(
                          labelText: 'المسؤول',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        items: users.map((u) {
                          return DropdownMenuItem(
                              value: u.id, child: Text(u.fullName));
                        }).toList(),
                        onChanged: isadmin
                            ? (value) =>
                                setState(() => _selectedAssistantId = value)
                            : null,
                        validator: (value) =>
                            value == null ? 'اختر مسؤول' : null,
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Text('خطأ: $e'),
                    ),
                  ],
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _isLoading ? null : _saveTask,
          backgroundColor: colorbar,
          child: const Icon(Icons.save, color: Colors.white),
        ),
      ),
    );
  }
}
