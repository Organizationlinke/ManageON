// هذا الملف يحتوي على الشاشات الأساسية لتطبيق إدارة المهام
// باستخدام Flutter و Supabase

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _description;
  int? _userId;
  int? _assistantId;
  int? _statusId = 1; // Default: انتظار
  DateTime? _deadline;

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _statuses = [];

  @override
  void initState() {
    super.initState();
    _fetchUsersAndStatuses();
  }

  Future<void> _fetchUsersAndStatuses() async {
    final users = await Supabase.instance.client.from('usertable').select();
    final statuses = await Supabase.instance.client.from('status').select();
    setState(() {
      _users = List<Map<String, dynamic>>.from(users);
      _statuses = List<Map<String, dynamic>>.from(statuses);
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await Supabase.instance.client.from('tasks').insert({
        'title': _title,
        'sub_title': _description,
        'user_id': _userId,
        'assistant': _assistantId,
        'status_id': _statusId,
        'deadline': _deadline?.toIso8601String(),
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة مهمة جديدة')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'عنوان المهمة'),
                onSaved: (value) => _title = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'وصف المهمة'),
                onSaved: (value) => _description = value,
              ),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'المسؤول'),
                items: _users
                    .map((user) => DropdownMenuItem<int>(
                          value: user['id'],
                          child: Text(user['full_name']),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _userId = value),
              ),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'المتابع (اختياري)'),
                items: _users
                    .map((user) => DropdownMenuItem<int>(
                          value: user['id'],
                          child: Text(user['full_name']),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _assistantId = value),
              ),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'الحالة'),
                value: _statusId,
                items: _statuses
                    .map((status) => DropdownMenuItem<int>(
                          value: status['id'],
                          child: Text(status['status_name']),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _statusId = value),
              ),
              ListTile(
                title: Text(_deadline == null
                    ? 'اختر تاريخ الانتهاء'
                    : _deadline.toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => _deadline = date);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('حفظ المهمة'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المهام'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'انتظار'),
            Tab(text: 'قيد التنفيذ'),
            Tab(text: 'مكتملة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TaskListView(statusId: 1),
          TaskListView(statusId: 2),
          TaskListView(statusId: 3),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTaskPage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskListView extends StatelessWidget {
  final int statusId;

  const TaskListView({super.key, required this.statusId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Supabase.instance.client
          .from('tasks')
          .select('*, usertable!inner(full_name)')
          .eq('status_id', statusId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final tasks = snapshot.data!;
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return ListTile(
              title: Text(task['title'] ?? ''),
              subtitle: Text('المسؤول: ${task['usertable']['full_name']}'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: الانتقال لصفحة تفاصيل المهمة
              },
            );
          },
        );
      },
    );
  }
}
