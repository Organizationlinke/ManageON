import 'package:flutter/material.dart';
import 'package:manageon/taskes/models/user_model.dart';

class TeamMemberCard extends StatelessWidget {
  final AppUser user;
  const TeamMemberCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
              ? NetworkImage(user.photoUrl!)
              : null,
          child: user.photoUrl == null || user.photoUrl!.isEmpty
              ? Text(user.fullName.substring(0, 1))
              : null,
        ),
        title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${user.jobTitle ?? 'غير محدد'} - ${user.departmentName ?? 'غير محدد'}'),
        // You can add more info or actions here
      ),
    );
  }
}