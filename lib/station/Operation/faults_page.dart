import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FaultsPage extends StatelessWidget {
  const FaultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return FutureBuilder(
      future: supabase
          .from('fault_logs')
          .select('*, production_lines(name)')
          .order('start_time', ascending: false),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data as List;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: data.length,
          itemBuilder: (context, i) {
            final row = data[i];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.error, color: Colors.red),
                title: Text(row['reason'] ?? 'عطل غير محدد'),
                subtitle: Text('القسم: ${row['dept']}'),
                trailing: Text(row['production_lines']['name']),
              ),
            );
          },
        );
      },
    );
  }
}
