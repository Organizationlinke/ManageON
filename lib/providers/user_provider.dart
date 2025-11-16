import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageon/constants.dart';
import 'package:manageon/models/user_model.dart';

// Provider to fetch all users with their related data
final allUsersProvider = FutureProvider<List<AppUser>>((ref) async {
  final response = await supabase
      .from('usersin')
      .select('*, departments:department(*)');
      
  final List<AppUser> users = (response as List)
      .map((item) => AppUser.fromJson(item))
      .toList();
      
  return users;
});
