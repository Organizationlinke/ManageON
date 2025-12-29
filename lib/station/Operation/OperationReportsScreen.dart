

// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:intl/intl.dart';

// class ReportsScreen extends StatefulWidget {
//   const ReportsScreen({super.key});

//   @override
//   State<ReportsScreen> createState() => _ReportsScreenState();
// }

// class _ReportsScreenState extends State<ReportsScreen> {
//   final SupabaseClient supabase = Supabase.instance.client;
//   List<Map<String, dynamic>> _allRawData = [];
//   List<Map<String, dynamic>> _filteredData = [];
//   bool _isLoading = false;

//   // فلاتر البحث
//   String _selectedLine = 'الكل';
//   DateTime _selectedDate = DateTime.now();
//   final List<String> _lines = ['الكل', 'دمج الخطين', 'الخط الأول', 'الخط الثاني'];

//   @override
//   void initState() {
//     super.initState();
//     _fetchDailyReport();
//   }

//   Future<void> _fetchDailyReport() async {
//     if (!mounted) return;
//     setState(() => _isLoading = true);
//     try {
//       final operations = await supabase
//           .from('Operation')
//           .select('*, Operation_Sub(*)')
//           .order('created_at', ascending: false);

//       List<Map<String, dynamic>> processedData = [];

//       for (var op in operations) {
//         final subs = List<Map<String, dynamic>>.from(op['Operation_Sub'] ?? []);
//         if (subs.isEmpty) continue;

//         // ترتيب الفترات الفرعية وتحديد البداية والنهاية
//         subs.sort((a, b) => DateTime.parse(a['Operation_start']).compareTo(DateTime.parse(b['Operation_start'])));
//         DateTime firstStart = DateTime.parse(subs.first['Operation_start']).toLocal();
        
//         DateTime? lastEnd;
//         try {
//           var lastSubWithEnd = subs.lastWhere((s) => s['Operation_end'] != null);
//           lastEnd = DateTime.parse(lastSubWithEnd['Operation_end']).toLocal();
//         } catch (_) {
//           lastEnd = null;
//         }

//         if (lastEnd == null) continue; 

//         // المدة الإجمالية من بداية أول تشغيل لنهاية آخر تشغيل
//         int totalDuration = lastEnd.difference(firstStart).inMinutes;

//         // جلب الأعطال التي حدثت خلال هذه الفترة وكانت تسبب توقف
//         final faults = await supabase
//             .from('Fault_Logging')
//             .select()
//             .eq('is_stop', true)
//             .gte('fault_time', firstStart.toUtc().toIso8601String())
//             .lte('fix_time', lastEnd.toUtc().toIso8601String());

//         int rawFaultMinutes = 0;
//         for (var f in faults) {
//           if (f['fault_time'] != null && f['fix_time'] != null) {
//             DateTime fS = DateTime.parse(f['fault_time']).toLocal();
//             DateTime fE = DateTime.parse(f['fix_time']).toLocal();
//             rawFaultMinutes += fE.difference(fS).inMinutes;
//           }
//         }

//         // --- التعديل المطلوب: إذا كان الخط "دمج الخطين" نقسم الأعطال على 2 ---
//         String lineName = subs.first['Line'] ?? 'غير محدد';
//         int finalFaultMinutes = rawFaultMinutes;
//         if (lineName == 'دمج الخطين') {
//           finalFaultMinutes = rawFaultMinutes ~/ 2; // قسمة صحيحة
//         }
//         // ------------------------------------------------------------------

//         int netDuration = totalDuration - finalFaultMinutes;
//         int totalBoxes = op['Boxs_Count'] ?? 0;
        
//         double totalWeightedSpeed = 0;
//         int totalOperatingMinutes = 0;
        
//         for (var sub in subs) {
//           if (sub['Operation_end'] != null) {
//             DateTime s = DateTime.parse(sub['Operation_start']).toLocal();
//             DateTime e = DateTime.parse(sub['Operation_end']).toLocal();
//             int dur = e.difference(s).inMinutes;
//             totalWeightedSpeed += ((sub['Boxs_Count_in_minute'] as int) * dur);
//             totalOperatingMinutes += dur;
//           }
//         }
        
//         double avgSpeed = totalOperatingMinutes > 0 
//             ? totalWeightedSpeed / totalOperatingMinutes 
//             : (subs.first['Boxs_Count_in_minute']?.toDouble() ?? 1.0);
            
//         double theoreticalMinutes = totalBoxes / avgSpeed;
//         int expectedDuration = theoreticalMinutes.round();
        
//         // حساب الفرق (المتوقع - الصافي)
//         int diff = expectedDuration - netDuration; 

//         processedData.add({
//           'id': op['id'],
//           'serial': op['Serial'],
//           'line': lineName,
//           'boxes': totalBoxes,
//           'start': firstStart,
//           'end': lastEnd,
//           'total_dur': totalDuration,
//           'faults': finalFaultMinutes, // القيمة بعد المعالجة (القسمة)
//           'net_dur': netDuration,
//           'expected': expectedDuration,
//           'diff': diff,
//           'created_at': DateTime.parse(op['created_at']).toLocal(),
//         });
//       }

//       if (mounted) {
//         setState(() {
//           _allRawData = processedData;
//           _applyFilters();
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       debugPrint("Report Error: $e");
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   void _applyFilters() {
//     setState(() {
//       _filteredData = _allRawData.where((item) {
//         bool lineMatch = _selectedLine == 'الكل' || item['line'] == _selectedLine;
        
//         DateTime itemDate = DateTime(item['created_at'].year, item['created_at'].month, item['created_at'].day);
//         DateTime filterDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
        
//         bool dateMatch = itemDate.isAtSameMomentAs(filterDate);
        
//         return lineMatch && dateMatch;
//       }).toList();
//     });
//   }

//   Map<String, dynamic> _calculateTotals() {
//     int boxes = 0, totalDur = 0, faults = 0, netDur = 0, expected = 0, diff = 0;
//     for (var d in _filteredData) {
//       boxes += (d['boxes'] as int);
//       totalDur += (d['total_dur'] as int);
//       faults += (d['faults'] as int);
//       netDur += (d['net_dur'] as int);
//       expected += (d['expected'] as int);
//       diff += (d['diff'] as int);
//     }
//     return {
//       'boxes': boxes,
//       'total_dur': totalDur,
//       'faults': faults,
//       'net_dur': netDur,
//       'expected': expected,
//       'diff': diff,
//     };
//   }

//   @override
//   Widget build(BuildContext context) {
//     final totals = _calculateTotals();
    
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('تقرير الأداء والتحليل'),
//       ),
//       body: Column(
//         children: [
//           // قسم الفلاتر
//           Container(
//             padding: const EdgeInsets.all(12),
//             color: Colors.blueGrey[50],
//             child: Row(
//               children: [
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     value: _selectedLine,
//                     decoration: const InputDecoration(
//                       labelText: 'الخط', 
//                       border: OutlineInputBorder(),
//                       contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                     ),
//                     items: _lines.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
//                     onChanged: (val) {
//                       setState(() {
//                         _selectedLine = val!;
//                         _applyFilters();
//                       });
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey),
//                     borderRadius: BorderRadius.circular(4)
//                   ),
//                   child: IconButton(
//                     icon: const Icon(Icons.event),
//                     onPressed: () async {
//                       final picked = await showDatePicker(
//                         context: context,
//                         initialDate: _selectedDate,
//                         firstDate: DateTime(2022),
//                         lastDate: DateTime.now(),
//                       );
//                       if (picked != null) {
//                         setState(() {
//                           _selectedDate = picked;
//                           _applyFilters();
//                         });
//                       }
//                     },
//                   ),
//                 )
//               ],
//             ),
//           ),
          
//           Expanded(
//             child: _isLoading 
//               ? const Center(child: CircularProgressIndicator())
//               : _filteredData.isEmpty 
//                 ? const Center(child: Text('لا توجد بيانات لهذا الفلتر'))
//                 : RefreshIndicator(
//                     onRefresh: _fetchDailyReport,
//                     child: SingleChildScrollView(
//                       padding: const EdgeInsets.all(8),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           SingleChildScrollView(
//                             scrollDirection: Axis.horizontal,
//                             child: DataTable(
//                               headingRowColor: WidgetStateProperty.all(Colors.blueGrey[100]),
//                               columnSpacing: 20,
//                               columns: const [
//                                 DataColumn(label: Text('السيريال')),
//                                 DataColumn(label: Text('الخط')),
//                                 DataColumn(label: Text('الصناديق')),
//                                 DataColumn(label: Text('البدء')),
//                                 DataColumn(label: Text('الانتهاء')),
//                                 DataColumn(label: Text('إجمالي المدة')),
//                                 DataColumn(label: Text('الأعطال')),
//                                 DataColumn(label: Text('صافي المدة')),
//                                 DataColumn(label: Text('المتوقع')),
//                                 DataColumn(label: Text('الفرق (الناتج)')),
//                               ],
//                               rows: [
//                                 ..._filteredData.map((data) {
//                                   int diffValue = data['diff'];
//                                   String startTime = DateFormat.jm().format(data['start']);
//                                   String endTime = DateFormat.jm().format(data['end']);

//                                   return DataRow(cells: [
//                                     DataCell(Text(data['serial'].toString())),
//                                     DataCell(Text(data['line'])),
//                                     DataCell(Text(data['boxes'].toString())),
//                                     DataCell(Text(startTime)),
//                                     DataCell(Text(endTime)),
//                                     DataCell(Text('${data['total_dur']} د')),
//                                     DataCell(Text('${data['faults']} د', style: const TextStyle(color: Colors.red))),
//                                     DataCell(Text('${data['net_dur']} د')),
//                                     DataCell(Text('${data['expected']} د')),
//                                     DataCell(Container(
//                                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                       decoration: BoxDecoration(
//                                         color: diffValue < 0 ? Colors.red[50] : Colors.green[50],
//                                         borderRadius: BorderRadius.circular(5)
//                                       ),
//                                       child: Text(
//                                         '${diffValue > 0 ? "+" : ""}$diffValue د', 
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold, 
//                                           color: diffValue < 0 ? Colors.red[900] : Colors.green[900]
//                                         ),
//                                       ),
//                                     )),
//                                   ]);
//                                 }),
//                                 // صف الإجماليات
//                                 DataRow(
//                                   color: WidgetStateProperty.all(Colors.blueGrey[50]),
//                                   cells: [
//                                     const DataCell(Text('المجموع', style: TextStyle(fontWeight: FontWeight.bold))),
//                                     const DataCell(Text('-')),
//                                     DataCell(Text(totals['boxes'].toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
//                                     const DataCell(Text('-')),
//                                     const DataCell(Text('-')),
//                                     DataCell(Text('${totals['total_dur']} د', style: const TextStyle(fontWeight: FontWeight.bold))),
//                                     DataCell(Text('${totals['faults']} د', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
//                                     DataCell(Text('${totals['net_dur']} د', style: const TextStyle(fontWeight: FontWeight.bold))),
//                                     DataCell(Text('${totals['expected']} د', style: const TextStyle(fontWeight: FontWeight.bold))),
//                                     DataCell(Text(
//                                       '${totals['diff']} د', 
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold, 
//                                         color: (totals['diff'] as int) < 0 ? Colors.red : Colors.green[800]
//                                       )
//                                     )),
//                                   ]
//                                 )
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _allRawData = [];
  List<Map<String, dynamic>> _filteredData = [];
  bool _isLoading = false;

  // فلاتر البحث
  String _selectedLine = 'الكل';
  DateTime _selectedDate = DateTime.now();
  final List<String> _lines = ['الكل', 'دمج الخطين', 'الخط الأول', 'الخط الثاني'];

  @override
  void initState() {
    super.initState();
    _fetchDailyReport();
  }

  Future<void> _fetchDailyReport() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final operations = await supabase
          .from('Operation')
          .select('*, Operation_Sub(*)')
          .order('created_at', ascending: false);

      List<Map<String, dynamic>> processedData = [];

      for (var op in operations) {
        final subs = List<Map<String, dynamic>>.from(op['Operation_Sub'] ?? []);
        if (subs.isEmpty) continue;

        // ترتيب الفترات الفرعية وتحديد البداية والنهاية
        subs.sort((a, b) => DateTime.parse(a['Operation_start']).compareTo(DateTime.parse(b['Operation_start'])));
        DateTime firstStart = DateTime.parse(subs.first['Operation_start']).toLocal();
        
        DateTime? lastEnd;
        try {
          var lastSubWithEnd = subs.lastWhere((s) => s['Operation_end'] != null);
          lastEnd = DateTime.parse(lastSubWithEnd['Operation_end']).toLocal();
        } catch (_) {
          lastEnd = null;
        }

        if (lastEnd == null) continue; 

        // المدة الإجمالية
        int totalDuration = lastEnd.difference(firstStart).inMinutes;

        // تحديد اسم الخط المسجل في العملية
        String lineName = subs.first['Line'] ?? 'غير محدد';

        // --- التعديل البرمجي لجلب الأعطال حسب الخط ---
        List<dynamic> faults = [];
        int rawFaultMinutes = 0;

        if (lineName == 'دمج الخطين') {
          // في حالة دمج الخطين، نجلب أعطال "الخط الأول" و "الخط الثاني" معاً خلال الفترة
          faults = await supabase
              .from('Fault_Logging')
              .select()
              .eq('is_stop', true)
              .inFilter('line', ['الخط الأول', 'الخط الثاني'])
              .gte('fault_time', firstStart.toUtc().toIso8601String())
              .lte('fix_time', lastEnd.toUtc().toIso8601String());
        } else {
          // في حالة الخط الأول أو الثاني، نجلب أعطال الخط المحدد فقط
          faults = await supabase
              .from('Fault_Logging')
              .select()
              .eq('is_stop', true)
              .eq('line', lineName)
              .gte('fault_time', firstStart.toUtc().toIso8601String())
              .lte('fix_time', lastEnd.toUtc().toIso8601String());
        }

        for (var f in faults) {
          if (f['fault_time'] != null && f['fix_time'] != null) {
            DateTime fS = DateTime.parse(f['fault_time']).toLocal();
            DateTime fE = DateTime.parse(f['fix_time']).toLocal();
            rawFaultMinutes += fE.difference(fS).inMinutes;
          }
        }

        // تطبيق منطق القسمة إذا كان الخط "دمج الخطين"
        int finalFaultMinutes = (lineName == 'دمج الخطين') 
            ? (rawFaultMinutes / 2).round() 
            : rawFaultMinutes;
        // ------------------------------------------------

        int netDuration = totalDuration - finalFaultMinutes;
        int totalBoxes = op['Boxs_Count'] ?? 0;
        
        double totalWeightedSpeed = 0;
        int totalOperatingMinutes = 0;
        
        for (var sub in subs) {
          if (sub['Operation_end'] != null) {
            DateTime s = DateTime.parse(sub['Operation_start']).toLocal();
            DateTime e = DateTime.parse(sub['Operation_end']).toLocal();
            int dur = e.difference(s).inMinutes;
            totalWeightedSpeed += ((sub['Boxs_Count_in_minute'] as int) * dur);
            totalOperatingMinutes += dur;
          }
        }
        
        double avgSpeed = totalOperatingMinutes > 0 
            ? totalWeightedSpeed / totalOperatingMinutes 
            : (subs.first['Boxs_Count_in_minute']?.toDouble() ?? 1.0);
            
        double theoreticalMinutes = totalBoxes / avgSpeed;
        int expectedDuration = theoreticalMinutes.round();
        
        int diff = expectedDuration - netDuration; 

        processedData.add({
          'id': op['id'],
          'serial': op['Serial'],
          'line': lineName,
          'boxes': totalBoxes,
          'start': firstStart,
          'end': lastEnd,
          'total_dur': totalDuration,
          'faults': finalFaultMinutes, 
          'net_dur': netDuration,
          'expected': expectedDuration,
          'diff': diff,
          'created_at': DateTime.parse(op['created_at']).toLocal(),
        });
      }

      if (mounted) {
        setState(() {
          _allRawData = processedData;
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Report Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredData = _allRawData.where((item) {
        bool lineMatch = _selectedLine == 'الكل' || item['line'] == _selectedLine;
        DateTime itemDate = DateTime(item['created_at'].year, item['created_at'].month, item['created_at'].day);
        DateTime filterDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
        bool dateMatch = itemDate.isAtSameMomentAs(filterDate);
        return lineMatch && dateMatch;
      }).toList();
    });
  }

  Map<String, dynamic> _calculateTotals() {
    int boxes = 0, totalDur = 0, faults = 0, netDur = 0, expected = 0, diff = 0;
    for (var d in _filteredData) {
      boxes += (d['boxes'] as int);
      totalDur += (d['total_dur'] as int);
      faults += (d['faults'] as int);
      netDur += (d['net_dur'] as int);
      expected += (d['expected'] as int);
      diff += (d['diff'] as int);
    }
    return {
      'boxes': boxes,
      'total_dur': totalDur,
      'faults': faults,
      'net_dur': netDur,
      'expected': expected,
      'diff': diff,
    };
  }

  @override
  Widget build(BuildContext context) {
    final totals = _calculateTotals();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير الأداء والتحليل'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // فلاتر البحث
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blueGrey[50],
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedLine,
                    decoration: const InputDecoration(
                      labelText: 'فلترة حسب الخط', 
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    items: _lines.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedLine = val!;
                        _applyFilters();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4)
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.event),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2022),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                          _applyFilters();
                        });
                      }
                    },
                  ),
                )
              ],
            ),
          ),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _filteredData.isEmpty 
                ? const Center(child: Text('لا توجد بيانات متاحة حالياً'))
                : RefreshIndicator(
                    onRefresh: _fetchDailyReport,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(Colors.blueGrey[100]),
                              columnSpacing: 20,
                              columns: const [
                                DataColumn(label: Text('السيريال')),
                                DataColumn(label: Text('الخط')),
                                DataColumn(label: Text('الصناديق')),
                                DataColumn(label: Text('البدء')),
                                DataColumn(label: Text('الانتهاء')),
                                DataColumn(label: Text('إجمالي المدة')),
                                DataColumn(label: Text('الأعطال')),
                                DataColumn(label: Text('صافي المدة')),
                                DataColumn(label: Text('المتوقع')),
                                DataColumn(label: Text('الفرق')),
                              ],
                              rows: [
                                ..._filteredData.map((data) {
                                  int diffValue = data['diff'];
                                  String startTime = DateFormat.jm().format(data['start']);
                                  String endTime = DateFormat.jm().format(data['end']);

                                  return DataRow(cells: [
                                    DataCell(Text(data['serial'].toString())),
                                    DataCell(Text(data['line'])),
                                    DataCell(Text(data['boxes'].toString())),
                                    DataCell(Text(startTime)),
                                    DataCell(Text(endTime)),
                                    DataCell(Text('${data['total_dur']} د')),
                                    DataCell(Text('${data['faults']} د', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                                    DataCell(Text('${data['net_dur']} د')),
                                    DataCell(Text('${data['expected']} د')),
                                    DataCell(Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: diffValue < 0 ? Colors.red[50] : Colors.green[50],
                                        borderRadius: BorderRadius.circular(5)
                                      ),
                                      child: Text(
                                        '${diffValue > 0 ? "+" : ""}$diffValue د', 
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold, 
                                          color: diffValue < 0 ? Colors.red[900] : Colors.green[900]
                                        ),
                                      ),
                                    )),
                                  ]);
                                }),
                                // صف الإجماليات
                                DataRow(
                                  color: WidgetStateProperty.all(Colors.blueGrey[50]),
                                  cells: [
                                    const DataCell(Text('المجموع', style: TextStyle(fontWeight: FontWeight.bold))),
                                    const DataCell(Text('-')),
                                    DataCell(Text(totals['boxes'].toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                                    const DataCell(Text('-')),
                                    const DataCell(Text('-')),
                                    DataCell(Text('${totals['total_dur']} د', style: const TextStyle(fontWeight: FontWeight.bold))),
                                    DataCell(Text('${totals['faults']} د', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
                                    DataCell(Text('${totals['net_dur']} د', style: const TextStyle(fontWeight: FontWeight.bold))),
                                    DataCell(Text('${totals['expected']} د', style: const TextStyle(fontWeight: FontWeight.bold))),
                                    DataCell(Text(
                                      '${totals['diff']} د', 
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold, 
                                        color: (totals['diff'] as int) < 0 ? Colors.red : Colors.green[800]
                                      )
                                    )),
                                  ]
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}