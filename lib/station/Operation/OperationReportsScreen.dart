
// // import 'package:flutter/material.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import 'package:intl/intl.dart';

// // class ReportsScreen extends StatefulWidget {
// //   const ReportsScreen({super.key});

// //   @override
// //   State<ReportsScreen> createState() => _ReportsScreenState();
// // }

// // class _ReportsScreenState extends State<ReportsScreen> {
// //   final SupabaseClient supabase = Supabase.instance.client;
// //   List<Map<String, dynamic>> _allRawData = [];
// //   List<Map<String, dynamic>> _filteredData = [];
// //   bool _isLoading = false;

// //   // فلاتر البحث
// //   String _selectedLine = 'الكل';
// //   DateTime _selectedDate = DateTime.now();
// //   final List<String> _lines = ['الكل', 'دمج الخطين', 'الخط الأول', 'الخط الثاني'];

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchDailyReport();
// //   }

// //   Future<void> _fetchDailyReport() async {
// //     if (!mounted) return;
// //     setState(() => _isLoading = true);
// //     try {
// //       final operations = await supabase
// //           .from('Operation')
// //           .select('*, Operation_Sub(*)')
// //           .order('created_at', ascending: false);

// //       List<Map<String, dynamic>> processedData = [];

// //       for (var op in operations) {
// //         final subs = List<Map<String, dynamic>>.from(op['Operation_Sub'] ?? []);
// //         if (subs.isEmpty) continue;

// //         // ترتيب الفترات الفرعية وتحديد البداية والنهاية
// //         subs.sort((a, b) => DateTime.parse(a['Operation_start']).compareTo(DateTime.parse(b['Operation_start'])));
// //         DateTime firstStart = DateTime.parse(subs.first['Operation_start']).toLocal();
        
// //         DateTime? lastEnd;
// //         try {
// //           var lastSubWithEnd = subs.lastWhere((s) => s['Operation_end'] != null);
// //           lastEnd = DateTime.parse(lastSubWithEnd['Operation_end']).toLocal();
// //         } catch (_) {
// //           lastEnd = null;
// //         }

// //         if (lastEnd == null) continue; 

// //         // المدة الإجمالية
// //         int totalDuration = lastEnd.difference(firstStart).inMinutes;

// //         // تحديد اسم الخط المسجل في العملية
// //         String lineName = subs.first['Line'] ?? 'غير محدد';

// //         // --- التعديل البرمجي لجلب الأعطال حسب الخط ---
// //         List<dynamic> faults = [];
// //         int rawFaultMinutes = 0;

// //         if (lineName == 'دمج الخطين') {
// //           // في حالة دمج الخطين، نجلب أعطال "الخط الأول" و "الخط الثاني" معاً خلال الفترة
// //           faults = await supabase
// //               .from('Fault_Logging')
// //               .select()
// //               .eq('is_stop', true)
// //               .inFilter('line', ['الخط الأول', 'الخط الثاني'])
// //               .gte('fault_time', firstStart.toUtc().toIso8601String())
// //               .lte('fix_time', lastEnd.toUtc().toIso8601String());
// //         } else {
// //           // في حالة الخط الأول أو الثاني، نجلب أعطال الخط المحدد فقط
// //           faults = await supabase
// //               .from('Fault_Logging')
// //               .select()
// //               .eq('is_stop', true)
// //               .eq('line', lineName)
// //               .gte('fault_time', firstStart.toUtc().toIso8601String())
// //               .lte('fix_time', lastEnd.toUtc().toIso8601String());
// //         }

// //         for (var f in faults) {
// //           if (f['fault_time'] != null && f['fix_time'] != null) {
// //             DateTime fS = DateTime.parse(f['fault_time']).toLocal();
// //             DateTime fE = DateTime.parse(f['fix_time']).toLocal();
// //             rawFaultMinutes += fE.difference(fS).inMinutes;
// //           }
// //         }

// //         // تطبيق منطق القسمة إذا كان الخط "دمج الخطين"
// //         int finalFaultMinutes = (lineName == 'دمج الخطين') 
// //             ? (rawFaultMinutes / 2).round() 
// //             : rawFaultMinutes;
// //         // ------------------------------------------------

// //         int netDuration = totalDuration - finalFaultMinutes;
// //         int totalBoxes = op['Boxs_Count'] ?? 0;
        
// //         double totalWeightedSpeed = 0;
// //         int totalOperatingMinutes = 0;
        
// //         for (var sub in subs) {
// //           if (sub['Operation_end'] != null) {
// //             DateTime s = DateTime.parse(sub['Operation_start']).toLocal();
// //             DateTime e = DateTime.parse(sub['Operation_end']).toLocal();
// //             int dur = e.difference(s).inMinutes;
// //             totalWeightedSpeed += ((sub['Boxs_Count_in_minute'] as int) * dur);
// //             totalOperatingMinutes += dur;
// //           }
// //         }
        
// //         double avgSpeed = totalOperatingMinutes > 0 
// //             ? totalWeightedSpeed / totalOperatingMinutes 
// //             : (subs.first['Boxs_Count_in_minute']?.toDouble() ?? 1.0);
            
// //         double theoreticalMinutes = totalBoxes / avgSpeed;
// //         int expectedDuration = theoreticalMinutes.round();
        
// //         int diff = expectedDuration - netDuration; 

// //         processedData.add({
// //           'id': op['id'],
// //           'serial': op['Serial'],
// //           'line': lineName,
// //           'boxes': totalBoxes,
// //           'start': firstStart,
// //           'end': lastEnd,
// //           'total_dur': totalDuration,
// //           'faults': finalFaultMinutes, 
// //           'net_dur': netDuration,
// //           'expected': expectedDuration,
// //           'diff': diff,
// //           'created_at': DateTime.parse(op['created_at']).toLocal(),
// //         });
// //       }

// //       if (mounted) {
// //         setState(() {
// //           _allRawData = processedData;
// //           _applyFilters();
// //           _isLoading = false;
// //         });
// //       }
// //     } catch (e) {
// //       debugPrint("Report Error: $e");
// //       if (mounted) setState(() => _isLoading = false);
// //     }
// //   }

// //   void _applyFilters() {
// //     setState(() {
// //       _filteredData = _allRawData.where((item) {
// //         bool lineMatch = _selectedLine == 'الكل' || item['line'] == _selectedLine;
// //         DateTime itemDate = DateTime(item['created_at'].year, item['created_at'].month, item['created_at'].day);
// //         DateTime filterDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
// //         bool dateMatch = itemDate.isAtSameMomentAs(filterDate);
// //         return lineMatch && dateMatch;
// //       }).toList();
// //     });
// //   }

// //   Map<String, dynamic> _calculateTotals() {
// //     int boxes = 0, totalDur = 0, faults = 0, netDur = 0, expected = 0, diff = 0;
// //     for (var d in _filteredData) {
// //       boxes += (d['boxes'] as int);
// //       totalDur += (d['total_dur'] as int);
// //       faults += (d['faults'] as int);
// //       netDur += (d['net_dur'] as int);
// //       expected += (d['expected'] as int);
// //       diff += (d['diff'] as int);
// //     }
// //     return {
// //       'boxes': boxes,
// //       'total_dur': totalDur,
// //       'faults': faults,
// //       'net_dur': netDur,
// //       'expected': expected,
// //       'diff': diff,
// //     };
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final totals = _calculateTotals();
    
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('تقرير الأداء والتحليل'),
// //         centerTitle: true,
// //       ),
// //       body: Column(
// //         children: [
// //           // فلاتر البحث
// //           Container(
// //             padding: const EdgeInsets.all(12),
// //             color: Colors.blueGrey[50],
// //             child: Row(
// //               children: [
// //                 Expanded(
// //                   child: DropdownButtonFormField<String>(
// //                     value: _selectedLine,
// //                     decoration: const InputDecoration(
// //                       labelText: 'فلترة حسب الخط', 
// //                       border: OutlineInputBorder(),
// //                       contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
// //                     ),
// //                     items: _lines.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
// //                     onChanged: (val) {
// //                       setState(() {
// //                         _selectedLine = val!;
// //                         _applyFilters();
// //                       });
// //                     },
// //                   ),
// //                 ),
// //                 const SizedBox(width: 10),
// //                 Container(
// //                   decoration: BoxDecoration(
// //                     border: Border.all(color: Colors.grey),
// //                     borderRadius: BorderRadius.circular(4)
// //                   ),
// //                   child: IconButton(
// //                     icon: const Icon(Icons.event),
// //                     onPressed: () async {
// //                       final picked = await showDatePicker(
// //                         context: context,
// //                         initialDate: _selectedDate,
// //                         firstDate: DateTime(2022),
// //                         lastDate: DateTime.now(),
// //                       );
// //                       if (picked != null) {
// //                         setState(() {
// //                           _selectedDate = picked;
// //                           _applyFilters();
// //                         });
// //                       }
// //                     },
// //                   ),
// //                 )
// //               ],
// //             ),
// //           ),
          
// //           Expanded(
// //             child: _isLoading 
// //               ? const Center(child: CircularProgressIndicator())
// //               : _filteredData.isEmpty 
// //                 ? const Center(child: Text('لا توجد بيانات متاحة حالياً'))
// //                 : RefreshIndicator(
// //                     onRefresh: _fetchDailyReport,
// //                     child: SingleChildScrollView(
// //                       padding: const EdgeInsets.all(8),
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.stretch,
// //                         children: [
// //                           SingleChildScrollView(
// //                             scrollDirection: Axis.horizontal,
// //                             child: DataTable(
// //                               headingRowColor: WidgetStateProperty.all(Colors.blueGrey[100]),
// //                               columnSpacing: 20,
// //                               columns: const [
// //                                 DataColumn(label: Text('السيريال')),
// //                                 DataColumn(label: Text('الخط')),
// //                                 DataColumn(label: Text('الصناديق')),
// //                                 DataColumn(label: Text('البدء')),
// //                                 DataColumn(label: Text('الانتهاء')),
// //                                 DataColumn(label: Text('إجمالي المدة')),
// //                                 DataColumn(label: Text('الأعطال')),
// //                                 DataColumn(label: Text('صافي المدة')),
// //                                 DataColumn(label: Text('المتوقع')),
// //                                 DataColumn(label: Text('الفرق')),
// //                               ],
// //                               rows: [
// //                                 ..._filteredData.map((data) {
// //                                   int diffValue = data['diff'];
// //                                   String startTime = DateFormat.jm().format(data['start']);
// //                                   String endTime = DateFormat.jm().format(data['end']);

// //                                   return DataRow(cells: [
// //                                     DataCell(Text(data['serial'].toString())),
// //                                     DataCell(Text(data['line'])),
// //                                     DataCell(Text(data['boxes'].toString())),
// //                                     DataCell(Text(startTime)),
// //                                     DataCell(Text(endTime)),
// //                                     DataCell(Text('${data['total_dur']} د')),
// //                                     DataCell(Text('${data['faults']} د', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
// //                                     DataCell(Text('${data['net_dur']} د')),
// //                                     DataCell(Text('${data['expected']} د')),
// //                                     DataCell(Container(
// //                                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //                                       decoration: BoxDecoration(
// //                                         color: diffValue < 0 ? Colors.red[50] : Colors.green[50],
// //                                         borderRadius: BorderRadius.circular(5)
// //                                       ),
// //                                       child: Text(
// //                                         '${diffValue > 0 ? "+" : ""}$diffValue د', 
// //                                         style: TextStyle(
// //                                           fontWeight: FontWeight.bold, 
// //                                           color: diffValue < 0 ? Colors.red[900] : Colors.green[900]
// //                                         ),
// //                                       ),
// //                                     )),
// //                                   ]);
// //                                 }),
// //                                 // صف الإجماليات
// //                                 DataRow(
// //                                   color: WidgetStateProperty.all(Colors.blueGrey[50]),
// //                                   cells: [
// //                                     const DataCell(Text('المجموع', style: TextStyle(fontWeight: FontWeight.bold))),
// //                                     const DataCell(Text('-')),
// //                                     DataCell(Text(totals['boxes'].toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
// //                                     const DataCell(Text('-')),
// //                                     const DataCell(Text('-')),
// //                                     DataCell(Text('${totals['total_dur']} د', style: const TextStyle(fontWeight: FontWeight.bold))),
// //                                     DataCell(Text('${totals['faults']} د', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
// //                                     DataCell(Text('${totals['net_dur']} د', style: const TextStyle(fontWeight: FontWeight.bold))),
// //                                     DataCell(Text('${totals['expected']} د', style: const TextStyle(fontWeight: FontWeight.bold))),
// //                                     DataCell(Text(
// //                                       '${totals['diff']} د', 
// //                                       style: TextStyle(
// //                                         fontWeight: FontWeight.bold, 
// //                                         color: (totals['diff'] as int) < 0 ? Colors.red : Colors.green[800]
// //                                       )
// //                                     )),
// //                                   ]
// //                                 )
// //                               ],
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
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

//   // دالة جلب البيانات مع فلترة من طرف السيرفر لتحسين السرعة
//   Future<void> _fetchDailyReport() async {
//     if (!mounted) return;
//     setState(() => _isLoading = true);
    
//     try {
//       // تحديد بداية ونهاية اليوم المختار بدقة
//       final DateTime startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 0, 0, 0);
//       final DateTime endOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);

//       // جلب العمليات التي تمت في هذا اليوم فقط
//       final operations = await supabase
//           .from('Operation')
//           .select('*, Operation_Sub(*)')
//           .gte('created_at', startOfDay.toUtc().toIso8601String())
//           .lte('created_at', endOfDay.toUtc().toIso8601String())
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

//         int totalDuration = lastEnd.difference(firstStart).inMinutes;
//         String lineName = subs.first['Line'] ?? 'غير محدد';

//         // جلب الأعطال لنفس الفترة الزمنية للعملية
//         List<dynamic> faults = [];
//         int rawFaultMinutes = 0;

//         var faultQuery = supabase.from('Fault_Logging').select().eq('is_stop', true);
        
//         if (lineName == 'دمج الخطين') {
//           faults = await faultQuery
//               .inFilter('line', ['الخط الأول', 'الخط الثاني'])
//               .gte('fault_time', firstStart.toUtc().toIso8601String())
//               .lte('fix_time', lastEnd.toUtc().toIso8601String());
//         } else {
//           faults = await faultQuery
//               .eq('line', lineName)
//               .gte('fault_time', firstStart.toUtc().toIso8601String())
//               .lte('fix_time', lastEnd.toUtc().toIso8601String());
//         }

//         for (var f in faults) {
//           if (f['fault_time'] != null && f['fix_time'] != null) {
//             DateTime fS = DateTime.parse(f['fault_time']).toLocal();
//             DateTime fE = DateTime.parse(f['fix_time']).toLocal();
//             rawFaultMinutes += fE.difference(fS).inMinutes;
//           }
//         }

//         int finalFaultMinutes = (lineName == 'دمج الخطين') ? (rawFaultMinutes / 2).round() : rawFaultMinutes;
//         int netDuration = totalDuration - finalFaultMinutes;
//         int totalBoxes = op['Boxs_Count'] ?? 0;
        
//         // حساب متوسط السرعة الفعلية (الصناديق / صافي المدة)
//         double realAvgSpeed = netDuration > 0 ? (totalBoxes / netDuration) : 0.0;
        
//         // حساب التوقعات بناءً على السرعات المسجلة في Operation_Sub
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
        
//         double theoreticalAvgSpeed = totalOperatingMinutes > 0 
//             ? totalWeightedSpeed / totalOperatingMinutes 
//             : (subs.first['Boxs_Count_in_minute']?.toDouble() ?? 1.0);
            
//         int expectedDuration = theoreticalAvgSpeed > 0 ? (totalBoxes / theoreticalAvgSpeed).round() : 0;
//         int diff = expectedDuration - netDuration;

//         processedData.add({
//           'id': op['id'],
//           'serial': op['Serial'],
//           'line': lineName,
//           'boxes': totalBoxes,
//           'start': firstStart,
//           'end': lastEnd,
//           'total_dur': totalDuration,
//           'faults': finalFaultMinutes,
//           'net_dur': netDuration,
//           'avg_speed': realAvgSpeed, // القيمة الجديدة
//           'expected': expectedDuration,
//           'diff': diff,
//           'created_at': DateTime.parse(op['created_at']).toLocal(),
//         });
//       }

//       if (mounted) {
//         setState(() {
//           // فلترة محلية فقط للخط لأننا جلبنا تاريخ اليوم بالفعل
//           _filteredData = _selectedLine == 'الكل' 
//               ? processedData 
//               : processedData.where((item) => item['line'] == _selectedLine).toList();
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       debugPrint("Report Error: $e");
//       if (mounted) setState(() => _isLoading = false);
//     }
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
//     double totalAvgSpeed = netDur > 0 ? (boxes / netDur) : 0.0;
//     return {
//       'boxes': boxes,
//       'total_dur': totalDur,
//       'faults': faults,
//       'net_dur': netDur,
//       'expected': expected,
//       'diff': diff,
//       'avg_speed': totalAvgSpeed,
//     };
//   }

//   @override
//   Widget build(BuildContext context) {
//     final totals = _calculateTotals();
    
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('تقرير الأداء اليومي الذكي'),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           // فلاتر البحث
//           Container(
//             padding: const EdgeInsets.all(12),
//             color: Colors.blueGrey[50],
//             child: Row(
//               children: [
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     value: _selectedLine,
//                     decoration: const InputDecoration(
//                       labelText: 'فلترة حسب الخط',
//                       border: OutlineInputBorder(),
//                       contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                     ),
//                     items: _lines.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
//                     onChanged: (val) {
//                       setState(() => _selectedLine = val!);
//                       _fetchDailyReport(); // إعادة الجلب عند تغيير الخط لضمان الدقة أو الفلترة محلياً
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 // زر اختيار التاريخ (الكالندر)
//                 InkWell(
//                   onTap: () async {
//                     final picked = await showDatePicker(
//                       context: context,
//                       initialDate: _selectedDate,
//                       firstDate: DateTime(2022),
//                       lastDate: DateTime.now(),
//                     );
//                     if (picked != null) {
//                       setState(() => _selectedDate = picked);
//                       _fetchDailyReport(); // جلب بيانات اليوم الجديد فقط
//                     }
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                       borderRadius: BorderRadius.circular(4),
//                       color: Colors.white
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.calendar_today, size: 18),
//                         const SizedBox(width: 8),
//                         Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
//                       ],
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
          
//           Expanded(
//             child: _isLoading 
//               ? const Center(child: CircularProgressIndicator())
//               : _filteredData.isEmpty 
//                 ? const Center(child: Text('لا توجد بيانات لهذا اليوم'))
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
//                               columnSpacing: 15,
//                               columns: const [
//                                 DataColumn(label: Text('السيريال')),
//                                 DataColumn(label: Text('الخط')),
//                                 DataColumn(label: Text('الصناديق')),
//                                 DataColumn(label: Text('صافي المدة')),
//                                 DataColumn(label: Text('م. السرعة')), // العمود الجديد
//                                 DataColumn(label: Text('الأعطال')),
//                                 DataColumn(label: Text('المتوقع')),
//                                 DataColumn(label: Text('الفرق')),
//                                 DataColumn(label: Text('البدء')),
//                                 DataColumn(label: Text('الانتهاء')),
//                               ],
//                               rows: [
//                                 ..._filteredData.map((data) {
//                                   int diffValue = data['diff'];
//                                   return DataRow(cells: [
//                                     DataCell(Text(data['serial'].toString())),
//                                     DataCell(Text(data['line'])),
//                                     DataCell(Text(data['boxes'].toString())),
//                                     DataCell(Text('${data['net_dur']} د')),
//                                     // عرض متوسط السرعة مع تقريب لرقمين عشريين
//                                     DataCell(Text(data['avg_speed'].toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
//                                     DataCell(Text('${data['faults']} د', style: const TextStyle(color: Colors.red))),
//                                     DataCell(Text('${data['expected']} د')),
//                                     DataCell(Container(
//                                       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                                       decoration: BoxDecoration(
//                                         color: diffValue < 0 ? Colors.red[50] : Colors.green[50],
//                                         borderRadius: BorderRadius.circular(4)
//                                       ),
//                                       child: Text(
//                                         '${diffValue > 0 ? "+" : ""}$diffValue د', 
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold, 
//                                           color: diffValue < 0 ? Colors.red[900] : Colors.green[900]
//                                         ),
//                                       ),
//                                     )),
//                                     DataCell(Text(DateFormat.jm().format(data['start']))),
//                                     DataCell(Text(DateFormat.jm().format(data['end']))),
//                                   ]);
//                                 }),
//                                 // صف الإجماليات
//                                 DataRow(
//                                   color: WidgetStateProperty.all(Colors.blueGrey[50]),
//                                   cells: [
//                                     const DataCell(Text('المجموع', style: TextStyle(fontWeight: FontWeight.bold))),
//                                     const DataCell(Text('-')),
//                                     DataCell(Text(totals['boxes'].toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
//                                     DataCell(Text('${totals['net_dur']} د', style: const TextStyle(fontWeight: FontWeight.bold))),
//                                     DataCell(Text(totals['avg_speed'].toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
//                                     DataCell(Text('${totals['faults']} د', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
//                                     DataCell(Text('${totals['expected']} د', style: const TextStyle(fontWeight: FontWeight.bold))),
//                                     DataCell(Text(
//                                       '${totals['diff']} د', 
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold, 
//                                         color: (totals['diff'] as int) < 0 ? Colors.red : Colors.green[800]
//                                       )
//                                     )),
//                                     const DataCell(Text('-')),
//                                     const DataCell(Text('-')),
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
import 'package:intl/intl.dart' as intl;

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
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

  // دالة جلب البيانات مع فلترة من طرف السيرفر لتحسين السرعة
  Future<void> _fetchDailyReport() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      // تحديد بداية ونهاية اليوم المختار بدقة
      final DateTime startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 0, 0, 0);
      final DateTime endOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);

      // جلب العمليات التي تمت في هذا اليوم فقط
      final operations = await supabase
          .from('Operation')
          .select('*, Operation_Sub(*)')
          .gte('created_at', startOfDay.toUtc().toIso8601String())
          .lte('created_at', endOfDay.toUtc().toIso8601String())
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

        int totalDuration = lastEnd.difference(firstStart).inMinutes;
        String lineName = subs.first['Line'] ?? 'غير محدد';

        // جلب الأعطال لنفس الفترة الزمنية للعملية
        List<dynamic> faults = [];
        int rawFaultMinutes = 0;

        var faultQuery = supabase.from('Fault_Logging').select().eq('is_stop', true);
        
        if (lineName == 'دمج الخطين') {
          faults = await faultQuery
              .inFilter('line', ['الخط الأول', 'الخط الثاني'])
              .gte('fault_time', firstStart.toUtc().toIso8601String())
              .lte('fix_time', lastEnd.toUtc().toIso8601String());
        } else {
          faults = await faultQuery
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

        int finalFaultMinutes = (lineName == 'دمج الخطين') ? (rawFaultMinutes / 2).round() : rawFaultMinutes;
        int netDuration = totalDuration - finalFaultMinutes;
        int totalBoxes = op['Boxs_Count'] ?? 0;
        
        // حساب متوسط السرعة الفعلية (الصناديق / صافي المدة)
        double realAvgSpeed = netDuration > 0 ? (totalBoxes / netDuration) : 0.0;
        
        // حساب التوقعات بناءً على السرعات المسجلة في Operation_Sub
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
        
        double theoreticalAvgSpeed = totalOperatingMinutes > 0 
            ? totalWeightedSpeed / totalOperatingMinutes 
            : (subs.first['Boxs_Count_in_minute']?.toDouble() ?? 1.0);
            
        int expectedDuration = theoreticalAvgSpeed > 0 ? (totalBoxes / theoreticalAvgSpeed).round() : 0;
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
          'avg_speed': realAvgSpeed, 
          'expected': expectedDuration,
          'diff': diff,
          'created_at': DateTime.parse(op['created_at']).toLocal(),
        });
      }

      if (mounted) {
        setState(() {
          _filteredData = _selectedLine == 'الكل' 
              ? processedData 
              : processedData.where((item) => item['line'] == _selectedLine).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Report Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
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
    double totalAvgSpeed = netDur > 0 ? (boxes / netDur) : 0.0;
    return {
      'boxes': boxes,
      'total_dur': totalDur,
      'faults': faults,
      'net_dur': netDur,
      'expected': expected,
      'diff': diff,
      'avg_speed': totalAvgSpeed,
    };
  }

  @override
  Widget build(BuildContext context) {
    final totals = _calculateTotals();
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تقرير الأداء اليومي الذكي'),
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
                          // فلترة البيانات الموجودة بالفعل لتحسين السرعة عند تغيير الخط
                          _fetchDailyReport(); 
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2022),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                        _fetchDailyReport();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18),
                          const SizedBox(width: 8),
                          Text(intl.DateFormat('yyyy-MM-dd').format(_selectedDate)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _filteredData.isEmpty 
                  ? const Center(child: Text('لا توجد بيانات لهذا اليوم'))
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
                                  DataColumn(label: Text('م. السرعة')), // مضاف في مكانه المنطقي
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
                                    return DataRow(cells: [
                                      DataCell(Text(data['serial'].toString())),
                                      DataCell(Text(data['line'])),
                                      DataCell(Text(data['boxes'].toString())),
                                      // عمود متوسط السرعة المضاف حديثاً
                                      DataCell(Text(data['avg_speed'].toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                                      DataCell(Text(intl.DateFormat.jm().format(data['start']))),
                                      DataCell(Text(intl.DateFormat.jm().format(data['end']))),
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
                                  // صف الإجماليات بنفس الترتيب
                                  DataRow(
                                    color: WidgetStateProperty.all(Colors.blueGrey[50]),
                                    cells: [
                                      const DataCell(Text('المجموع', style: TextStyle(fontWeight: FontWeight.bold))),
                                      const DataCell(Text('-')),
                                      DataCell(Text(totals['boxes'].toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                                      DataCell(Text(totals['avg_speed'].toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
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
      ),
    );
  }
}