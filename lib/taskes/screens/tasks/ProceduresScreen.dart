import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:manageon/global.dart';
import 'package:manageon/constants.dart';
import 'package:intl/date_symbol_data_local.dart';

class ProceduresScreen extends ConsumerStatefulWidget {
  final int taskId;
  final int type;
  const ProceduresScreen({super.key, required this.taskId, required this.type});

  @override
  ConsumerState<ProceduresScreen> createState() => _ProceduresScreenState();
}

class _ProceduresScreenState extends ConsumerState<ProceduresScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _loading = false;
  @override
  void initState() {
    super.initState();

    // تهيئة بيانات اللغة العربية
    initializeDateFormatting('ar_EG', null).then((_) {
      setState(() {}); // إعادة البناء بعد التهيئة
    });

    // باقي initState
    _commentController.text = '';
  }

  Future<void> _addProcedure() async {
    if (_commentController.text.trim().isEmpty) {
      showSnackBar(context, widget.type == 1 ? "أدخل الإجراء" : "أدخل المتابعه",
          isError: true);
      return;
    }

    setState(() => _loading = true);

    try {
      final userId = supabase.auth.currentUser?.id;

      await supabase.from('procedures').insert({
        'tasks_id': widget.taskId,
        'user_id': userId,
        'comment': _commentController.text.trim(),
        'type': widget.type,
      });

      _commentController.clear();
      setState(() {});

      showSnackBar(
          context, widget.type == 1 ? "تم إضافة الإجراء" : "تم إضافة متابعه");
    } catch (e) {
      showSnackBar(context, "خطأ: $e", isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _loadProcedures() async {
    final data = await supabase
        .from('procedures')
        .select("id, comment, created_at, user_id")
        .eq('tasks_id', widget.taskId)
        .eq('is_delete', 0)
        .eq('type', widget.type)
        .order('id', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  String _formatEgyptTime(dynamic timestamp) {
    // تحويل نص Supabase إلى DateTime
    final dt = DateTime.parse(timestamp).toLocal();

    // تحويل لمنطقة مصر
    final egypt = dt.add(const Duration(hours: 0)); // UTC+2

    final formatted = DateFormat('yyyy-MM-dd  hh:mm a', 'ar_EG').format(egypt);

    // تحويل AM/PM إلى صباحًا/مساءً يدويًا
    return formatted.replaceAll("AM", "صباحًا").replaceAll("PM", "مساءً");
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: widget.type == 1 ? Text("الإجراءات") : Text("المتابعات"),
        ),
        body: Column(
          children: [
            // إدخال إجراء جديد
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        labelText:
                            widget.type == 1 ? "إضافة إجراء" : "إضافة متابعه",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async{
                   print('aaaaaaaa');
                      if (user_level == 2 && widget.type == 2) {
                      await  _addProcedure();
                      }
                      if (user_level == 1 && widget.type == 1) {
                      await  _addProcedure();
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: colorbar),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text("حفظ",
                            style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),

            const Divider(),

            // عرض الإجراءات
            Expanded(
              child: FutureBuilder(
                future: _loadProcedures(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final list = snapshot.data!;

                  if (list.isEmpty) {
                    return Center(
                        child: widget.type == 1
                            ? Text("لا توجد إجراءات مسجلة")
                            : Text("لا توجد متابعات مسجلة"));
                  }

                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final p = list[i];
                      return Card(
                        child: ListTile(
                          title: Text(p['comment'] ?? ''),
                          // subtitle: Text("تاريخ: ${p['created_at'].toString().substring(0, 16)}"),
                          subtitle: Text(
                            "التاريخ: ${_formatEgyptTime(p['created_at'])}",
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
