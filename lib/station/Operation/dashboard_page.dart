// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class DashboardPage extends StatefulWidget {
//   const DashboardPage({super.key});

//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }

// class _DashboardPageState extends State<DashboardPage> {
//   final supabase = Supabase.instance.client;
//   Map<String, dynamic>? tractor;

//   @override
//   void initState() {
//     super.initState();
//     loadActiveTractor();
//   }

//   Future<void> loadActiveTractor() async {
//     try {
//       final list = await supabase
//     .from('tractor_logs')
//     .select('*, production_lines(name,current_speed)')
//     .eq('status', 'active')
//     .limit(1);

// if (list.isEmpty) {
//   // مفيش جرار نشط
// } else {
//   final tractor = list.first;
// }

//     //     final response = await supabase
//     //     .from('tractor_logs')
//     //     .select('*, production_lines(name,current_speed)')
//     //     .eq('status', 'active')
//     //     .limit(1)
//     //     .single();

//     // setState(() => tractor = response);
//     } catch (e) {
//       print('error:$e');
//     }
  
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (tractor == null) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'جرار #${tractor!['id']}',
//                 style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 10),
//               Text('الخط: ${tractor!['production_lines']['name']}'),
//               Text('السرعة: ${tractor!['production_lines']['current_speed']}'),
//               const SizedBox(height: 20),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.stop),
//                 label: const Text('إنهاء التشغيل'),
//                 onPressed: finishTractor,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> finishTractor() async {
//     await supabase
//         .from('tractor_logs')
//         .update({
//           'status': 'finished',
//           'end_time': DateTime.now().toIso8601String(),
//         })
//         .eq('id', tractor!['id']);

//     loadActiveTractor();
//   }
// }
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  Map<String, dynamic>? tractor;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadActiveTractor();
  }

  Future<void> loadActiveTractor() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final List data = await supabase
          .from('tractor_logs')
          .select('*, production_lines(name,current_speed)')
          .eq('status', 'active')
          .order('start_time', ascending: false)
          .limit(1);

      if (data.isEmpty) {
        tractor = null;
      } else {
        tractor = Map<String, dynamic>.from(data.first);
      }
    } catch (e) {
      errorMessage = e.toString();
      tractor = null;
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          'خطأ في تحميل البيانات\n$errorMessage',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (tractor == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pause_circle_outline, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'لا يوجد جرار يعمل حاليًا',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('تحديث'),
              onPressed: loadActiveTractor,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'جرار #${tractor!['id']}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'الخط: ${tractor!['production_lines']['name']}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'السرعة الحالية: ${tractor!['production_lines']['current_speed']}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.stop_circle),
                  label: const Text('إنهاء التشغيل'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: finishTractor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> finishTractor() async {
    try {
      await supabase
          .from('tractor_logs')
          .update({
            'status': 'finished',
            'end_time': DateTime.now().toIso8601String(),
          })
          .eq('id', tractor!['id']);

      await loadActiveTractor();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ أثناء إنهاء التشغيل: $e')),
      );
    }
  }
}
