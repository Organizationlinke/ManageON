class Task {
  final int id;
  final String title;
  final String? description;
  final DateTime deadline;
  final int statusId;
  final String statusName; // من جدول status
  final int? assistantId;
  final String? assistantName; // من جدول usersin
  final String? assistantAvatar; // من جدول usersin
  final String priority;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.deadline,
    required this.statusId,
    required this.statusName,
    this.assistantId,
    this.assistantName,
    this.assistantAvatar,
    required this.priority,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'] ?? 'مهمة بدون عنوان',
      description: json['sub_title'],
      deadline: DateTime.parse(json['deadline']),
      statusId: json['status_id'],
      statusName: json['status_table']?['status_name'] ?? 'غير محدد',
      assistantId: json['assistant'],
      assistantName: json['usersin']?['full_name'] ?? 'غير معين',
      assistantAvatar: json['usersin']?['photo_url'],
      priority: json['priority'] ?? 'Medium',
    );
  }
}