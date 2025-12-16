class AppUser {
  final int id;
  final String fullName;
  final String? userName;
  final String? jobTitle;
  final String? departmentName;
  final String? photoUrl;
  final DateTime joinedDate;

  AppUser({
    required this.id,
    required this.fullName,
    this.userName,
    this.jobTitle,
    this.departmentName,
    this.photoUrl,
    required this.joinedDate,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      fullName: json['full_name'] ?? 'مستخدم غير معروف',
      userName: json['user_name'],
      jobTitle: json['jobe'],
      departmentName: json['departments']?['department_name'] ?? 'غير محدد',
      photoUrl: json['photo_url'],
      joinedDate: DateTime.parse(json['created_at']), // Using created_at as joined date
    );
  }
}