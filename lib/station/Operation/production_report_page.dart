import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductionReportPage extends StatelessWidget {
  const ProductionReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return FutureBuilder(
      future: supabase
          .from('tractor_logs')
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
                title: Text('جرار #${row['id']}'),
                subtitle: Text('الخط: ${row['production_lines']['name']}'),
                trailing: Text('${row['actual_duration_minutes'] ?? 0} د'),
              ),
            );
          },
        );
      },
    );
  }
}
