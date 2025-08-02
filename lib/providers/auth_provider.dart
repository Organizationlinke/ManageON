import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authProvider = Provider((ref) => Supabase.instance.client.auth);

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authProvider).onAuthStateChange;
});

final userProvider = StateProvider<User?>((ref) {
  return ref.watch(authProvider).currentUser;
});