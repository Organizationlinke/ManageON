import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageon/providers/user_provider.dart';
import 'package:manageon/widgets/team/team_member_card.dart';

class TeamScreen extends ConsumerWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);

    return usersAsync.when(
      data: (users) {
        return RefreshIndicator(
          onRefresh: () => ref.refresh(allUsersProvider.future),
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              return TeamMemberCard(user: users[index]);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('خطأ في تحميل الفريق: $e')),
    );
  }
}