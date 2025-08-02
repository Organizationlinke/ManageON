import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageon/models/user_model.dart';

// Provider to hold the state of the currently logged-in user
final loggedInUserProvider = StateProvider<AppUser?>((ref) => null);