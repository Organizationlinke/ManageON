
// // import 'package:flutter/material.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import 'dart:async';
// // import 'package:intl/intl.dart' as intl;



// // class FaultLoggingApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'نظام تسجيل الأعطال',
// //       theme: ThemeData(
// //         useMaterial3: true,
// //         primarySwatch: Colors.indigo,
// //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
// //         fontFamily: 'Roboto',
// //       ),
// //       debugShowCheckedModeBanner: false,
// //       home: MainNavigationScreen(),
// //       locale: const Locale('ar', 'AE'),
// //     );
// //   }
// // }

// // class MainNavigationScreen extends StatefulWidget {
// //   @override
// //   _MainNavigationScreenState createState() => _MainNavigationScreenState();
// // }

// // class _MainNavigationScreenState extends State<MainNavigationScreen> {
// //   int _selectedIndex = 0;
  
// //   final List<Widget> _pages = [
// //     FaultDashboard(),
// //     FaultReportPage(),
// //   ];

// //   @override
// //   Widget build(BuildContext context) {
// //     return Directionality(
// //       textDirection: TextDirection.rtl,
// //       child: Scaffold(
// //         body: _pages[_selectedIndex],
// //         bottomNavigationBar: BottomNavigationBar(
// //           currentIndex: _selectedIndex,
// //           onTap: (index) => setState(() => _selectedIndex = index),
// //           items: const [
// //             BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'تسجيل الأعطال'),
// //             BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'التقارير'),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class FaultDashboard extends StatefulWidget {
// //   @override
// //   _FaultDashboardState createState() => _FaultDashboardState();
// // }

// // class _FaultDashboardState extends State<FaultDashboard> with SingleTickerProviderStateMixin {
// //   late TabController _tabController;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _tabController = TabController(length: 2, vsync: this);
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('إدارة أعطال الخطوط'),
// //         bottom: TabBar(
// //           controller: _tabController,
// //           tabs: const [
// //             Tab(text: 'الخط الأول'),
// //             Tab(text: 'الخط الثاني'),
// //           ],
// //         ),
// //       ),
// //       body: TabBarView(
// //         controller: _tabController,
// //         children: [
// //           FaultLineView(lineName: 'الخط الأول'),
// //           FaultLineView(lineName: 'الخط الثاني'),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class FaultLineView extends StatefulWidget {
// //   final String lineName;
// //   FaultLineView({required this.lineName});

// //   @override
// //   _FaultLineViewState createState() => _FaultLineViewState();
// // }

// // class _FaultLineViewState extends State<FaultLineView> {
// //   final SupabaseClient supabase = Supabase.instance.client;
// //   List<dynamic> activeFaults = [];
// //   bool isLoading = true;
// //   bool isStopLine = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchActiveFaults();
// //   }

// //   Future<void> _fetchActiveFaults() async {
// //     try {
// //       final response = await supabase
// //           .from('Fault_Logging')
// //           .select()
// //           .eq('line', widget.lineName)
// //           .isFilter('fix_time', null)
// //           .order('fault_time', ascending: false);
      
// //       setState(() {
// //         activeFaults = response;
// //         isLoading = false;
// //       });
// //     } catch (e) {
// //       debugPrint('Error: $e');
// //       setState(() => isLoading = false);
// //     }
// //   }

// //   bool _hasBlockingFault() {
// //     return activeFaults.any((f) => f['is_stop'] == true);
// //   }

// //   Future<void> _quickRegisterFault() async {
// //     if (isStopLine && _hasBlockingFault()) {
// //       _showSimpleDialog('تنبيه', 'لا يمكن تسجيل عطل موقف جديد وهناك عطل موقف نشط حالياً على هذا الخط.');
// //       return;
// //     }

// //     bool? confirm = await showDialog<bool>(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: const Text('تسجيل عطل فوري'),
// //         content: Text('سيتم تسجيل عطل الآن لـ ${widget.lineName}. هل أنت متأكد؟'),
// //         actions: [
// //           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
// //           TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('تأكيد التسجيل')),
// //         ],
// //       ),
// //     );

// //     if (confirm == true) {
// //       try {
// //         await supabase.from('Fault_Logging').insert({
// //           'line': widget.lineName,
// //           'is_stop': isStopLine,
// //           'fault_time': DateTime.now().toUtc().toIso8601String(),
// //         });
// //         _fetchActiveFaults();
// //       } catch (e) {
// //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطأ في الاتصال')));
// //       }
// //     }
// //   }

// //   void _showSimpleDialog(String title, String msg) {
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: Text(title),
// //         content: Text(msg),
// //         actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً'))],
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       children: [
// //         Container(
// //           padding: const EdgeInsets.all(16),
// //           decoration: const BoxDecoration(
// //             color: Colors.white,
// //             boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
// //           ),
// //           child: Row(
// //             children: [
// //               Expanded(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text('تسجيل عطل جديد لـ ${widget.lineName}', style: const TextStyle(fontWeight: FontWeight.bold)),
// //                     Row(
// //                       children: [
// //                         const Text('يوقف الخط؟'),
// //                         Switch(
// //                           value: isStopLine,
// //                           activeColor: Colors.red,
// //                           onChanged: (val) => setState(() => isStopLine = val),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               ElevatedButton.icon(
// //                 icon: const Icon(Icons.play_arrow),
// //                 label: const Text('سجل العطل الآن'),
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: isStopLine ? Colors.red : Colors.orange,
// //                   foregroundColor: Colors.white,
// //                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)
// //                 ),
// //                 onPressed: _quickRegisterFault,
// //               ),
// //             ],
// //           ),
// //         ),
// //         Expanded(
// //           child: isLoading 
// //             ? const Center(child: CircularProgressIndicator())
// //             : activeFaults.isEmpty 
// //               ? const Center(child: Text('لا توجد أعطال نشطة'))
// //               : ListView.builder(
// //                   padding: const EdgeInsets.only(top: 8),
// //                   itemCount: activeFaults.length,
// //                   itemBuilder: (context, index) {
// //                     final fault = activeFaults[index];
// //                     return FaultCard(
// //                       fault: fault,
// //                       onRepair: () => _fetchActiveFaults(),
// //                       onUpdate: _fetchActiveFaults,
// //                     );
// //                   },
// //                 ),
// //         ),
// //       ],
// //     );
// //   }
// // }

// // class FaultCard extends StatefulWidget {
// //   final dynamic fault;
// //   final VoidCallback onRepair;
// //   final VoidCallback onUpdate;

// //   FaultCard({required this.fault, required this.onRepair, required this.onUpdate});

// //   @override
// //   _FaultCardState createState() => _FaultCardState();
// // }

// // class _FaultCardState extends State<FaultCard> {
// //   late Timer _timer;
// //   String _durationString = "00:00:00";
// //   bool isEditing = false;
  
// //   String? tempDept;
// //   final TextEditingController tempReasonController = TextEditingController();

// //   @override
// //   void initState() {
// //     super.initState();
// //     tempDept = widget.fault['department'];
// //     tempReasonController.text = widget.fault['reason'] ?? "";
// //     // إذا كانت البيانات ناقصة، اجعل الكارت في وضع التعديل تلقائياً
// //     isEditing = (tempDept == null || tempReasonController.text.isEmpty);
// //     _startTimer();
// //   }

// //   void _startTimer() {
// //     _updateTime();
// //     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
// //       if (mounted) _updateTime();
// //     });
// //   }

// //   void _updateTime() {
// //     try {
// //       final startTime = DateTime.parse(widget.fault['fault_time']).toUtc();
// //       final now = DateTime.now().toUtc();
// //       final diff = now.difference(startTime);
// //       if (mounted) {
// //         setState(() {
// //           _durationString = _formatDuration(diff.isNegative ? Duration.zero : diff);
// //         });
// //       }
// //     } catch (e) {
// //       debugPrint("Timer Error: $e");
// //     }
// //   }

// //   String _formatDuration(Duration d) {
// //     String twoDigits(int n) => n.toString().padLeft(2, "0");
// //     return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
// //   }

// //   // الوظيفة الأساسية المعدلة بناءً على طلبك
// //   Future<void> _handleRepairRequest() async {
// //     // 1. التحقق من البيانات أولاً
// //     if (tempDept == null || tempReasonController.text.trim().isEmpty) {
// //       setState(() => isEditing = true); // فتح وضع التعديل لإجبار المستخدم
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //           content: Text('⚠️ يرجى تسجيل الإدارة والسبب أولاً قبل إغلاق البلاغ'),
// //           backgroundColor: Colors.redAccent,
// //         ),
// //       );
// //       return;
// //     }

// //     // 2. إذا كانت البيانات مكتملة، اطلب تأكيد الإصلاح
// //     bool? confirm = await showDialog<bool>(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: const Text('تأكيد الإصلاح'),
// //         content: const Text('هل تم التأكد من حل المشكلة وإعادة الخط للعمل؟'),
// //         actions: [
// //           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('لا')),
// //           TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('نعم، تم')),
// //         ],
// //       ),
// //     );

// //     if (confirm == true) {
// //       await Supabase.instance.client.from('Fault_Logging').update({
// //         'fix_time': DateTime.now().toUtc().toIso8601String(),
// //         // نضمن تحديث البيانات في نفس لحظة الإغلاق للتأكيد
// //         'department': tempDept,
// //         'reason': tempReasonController.text.trim(),
// //       }).eq('id', widget.fault['id']);
// //       widget.onRepair();
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _timer.cancel();
// //     tempReasonController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     bool isStop = widget.fault['is_stop'] ?? false;
    
// //     return Card(
// //       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.circular(12),
// //         side: BorderSide(color: isStop ? Colors.red.withOpacity(0.5) : Colors.orange.withOpacity(0.5), width: 1.5)
// //       ),
// //       child: Padding(
// //         padding: const EdgeInsets.all(12.0),
// //         child: Column(
// //           children: [
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Text(isStop ? 'عطل موقف للخط 🛑' : 'عطل غير موقف ⚠️', 
// //                      style: TextStyle(fontWeight: FontWeight.bold, color: isStop ? Colors.red : Colors.orange)),
// //                 Text(_durationString, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)),
// //               ],
// //             ),
// //             const Divider(),
// //             if (isEditing) ...[
// //               DropdownButtonFormField<String>(
// //                 value: tempDept,
// //                 decoration: const InputDecoration(labelText: 'الإدارة المسئولة *', isDense: true),
// //                 items: ['الإنتاج', 'الصيانة', 'الجودة'].map((String value) {
// //                   return DropdownMenuItem<String>(value: value, child: Text(value));
// //                 }).toList(),
// //                 onChanged: (val) => setState(() => tempDept = val),
// //               ),
// //               TextField(
// //                 controller: tempReasonController,
// //                 maxLines: 3,
// //                 decoration: const InputDecoration(labelText: 'سبب العطل التفصيلي *', isDense: true),
// //               ),
// //               const SizedBox(height: 12),
// //               ElevatedButton(
// //                 onPressed: () async {
// //                   if (tempDept != null && tempReasonController.text.trim().isNotEmpty) {
// //                     await Supabase.instance.client.from('Fault_Logging').update({
// //                       'department': tempDept,
// //                       'reason': tempReasonController.text.trim(),
// //                     }).eq('id', widget.fault['id']);
// //                     setState(() => isEditing = false);
// //                     widget.onUpdate();
// //                   } else {
// //                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى ملء الحقول الإجبارية')));
// //                   }
// //                 },
// //                 style: ElevatedButton.styleFrom(
// //                   minimumSize: const Size(double.infinity, 35),
// //                   backgroundColor: Colors.indigo.shade50
// //                 ),
// //                 child: const Text('حفظ البيانات فقط'),
// //               ),
// //             ] else ...[
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Expanded(
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text('الإدارة: ${widget.fault['department']}', style: const TextStyle(fontWeight: FontWeight.bold)),
// //                         Text('السبب: ${widget.fault['reason']}'),
// //                       ],
// //                     ),
// //                   ),
// //                   IconButton(
// //                     icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
// //                     onPressed: () => setState(() => isEditing = true),
// //                   )
// //                 ],
// //               ),
// //             ],
// //             const Divider(),
// //             SizedBox(
// //               width: double.infinity,
// //               child: ElevatedButton.icon(
// //                 icon: const Icon(Icons.check_circle_outline),
// //                 onPressed: _handleRepairRequest,
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.green, 
// //                   foregroundColor: Colors.white,
// //                   padding: const EdgeInsets.symmetric(vertical: 12)
// //                 ),
// //                 label: const Text('إصلاح وإغلاق البلاغ', style: TextStyle(fontWeight: FontWeight.bold)),
// //               ),
// //             )
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class FaultReportPage extends StatefulWidget {
// //   @override
// //   _FaultReportPageState createState() => _FaultReportPageState();
// // }

// // class _FaultReportPageState extends State<FaultReportPage> {
// //   final SupabaseClient supabase = Supabase.instance.client;
// //   DateTime selectedDate = DateTime.now();
// //   List<dynamic> reportData = [];
// //   bool loading = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchReport();
// //   }

// //   Future<void> _fetchReport() async {
// //     setState(() => loading = true);
// //     final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day).toUtc();
// //     final endOfDay = startOfDay.add(const Duration(days: 1));

// //     try {
// //       final response = await supabase
// //           .from('Fault_Logging')
// //           .select()
// //           .gte('fault_time', startOfDay.toIso8601String())
// //           .lt('fault_time', endOfDay.toIso8601String())
// //           .order('fault_time', ascending: false);
      
// //       setState(() {
// //         reportData = response;
// //         loading = false;
// //       });
// //     } catch (e) {
// //       setState(() => loading = false);
// //     }
// //   }

// //   Duration _getTotalStopTime() {
// //     int totalMinutes = 0;
// //     for (var f in reportData) {
// //       if (f['is_stop'] == true && f['fix_time'] != null) {
// //         final start = DateTime.parse(f['fault_time']);
// //         final end = DateTime.parse(f['fix_time']);
// //         totalMinutes += end.difference(start).inMinutes;
// //       }
// //     }
// //     return Duration(minutes: totalMinutes);
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final totalStop = _getTotalStopTime();
    
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('تقارير الأعطال اليومية'),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.event),
// //             onPressed: () async {
// //               final picked = await showDatePicker(
// //                 context: context,
// //                 initialDate: selectedDate,
// //                 firstDate: DateTime(2022),
// //                 lastDate: DateTime.now(),
// //               );
// //               if (picked != null) {
// //                 setState(() => selectedDate = picked);
// //                 _fetchReport();
// //               }
// //             },
// //           )
// //         ],
// //       ),
// //       body: Column(
// //         children: [
// //           Container(
// //             padding: const EdgeInsets.all(16),
// //             width: double.infinity,
// //             color: Colors.red.shade50,
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 const Icon(Icons.timer_off, color: Colors.red),
// //                 const SizedBox(width: 8),
// //                 Text(
// //                   'إجمالي وقت توقف الخطوط: ${totalStop.inHours}س ${totalStop.inMinutes.remainder(60)}د',
// //                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red.shade900),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           Expanded(
// //             child: loading 
// //               ? const Center(child: CircularProgressIndicator())
// //               : reportData.isEmpty
// //                 ? const Center(child: Text('لا توجد بيانات لهذا اليوم'))
// //                 : SingleChildScrollView(
// //                     scrollDirection: Axis.horizontal,
// //                     child: DataTable(
// //                       headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
// //                       columns: const [
// //                         DataColumn(label: Text('الخط')),
// //                         DataColumn(label: Text('نوع العطل')),
// //                         DataColumn(label: Text('البداية')),
// //                         DataColumn(label: Text('الإصلاح')),
// //                         DataColumn(label: Text('المدة')),
// //                         DataColumn(label: Text('الإدارة')),
// //                         DataColumn(label: Text('السبب')),
// //                       ],
// //                       rows: reportData.map((f) => DataRow(cells: [
// //                         DataCell(Text(f['line'] ?? '-')),
// //                         DataCell(
// //                           Container(
// //                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //                             decoration: BoxDecoration(
// //                               color: f['is_stop'] == true ? Colors.red.shade100 : Colors.orange.shade100,
// //                               borderRadius: BorderRadius.circular(8),
// //                             ),
// //                             child: Text(
// //                               f['is_stop'] == true ? 'موقف للخط' : 'لا يوقف',
// //                               style: TextStyle(color: f['is_stop'] == true ? Colors.red.shade900 : Colors.orange.shade900, fontSize: 12),
// //                             ),
// //                           )
// //                         ),
// //                         DataCell(Text(intl.DateFormat('HH:mm').format(DateTime.parse(f['fault_time']).toLocal()))),
// //                         DataCell(Text(f['fix_time'] != null ? intl.DateFormat('HH:mm').format(DateTime.parse(f['fix_time']).toLocal()) : 'نشط')),
// //                         DataCell(Text(_calculateDuration(f))),
// //                         DataCell(Text(f['department'] ?? '-')),
// //                         DataCell(Text(f['reason'] ?? '-')),
// //                       ])).toList(),
// //                     ),
// //                   ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   String _calculateDuration(dynamic fault) {
// //     if (fault['fix_time'] == null) return "مستمر";
// //     final start = DateTime.parse(fault['fault_time']);
// //     final end = DateTime.parse(fault['fix_time']);
// //     final diff = end.difference(start);
// //     return "${diff.inHours}س ${diff.inMinutes.remainder(60)}د";
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'dart:async';
// import 'package:intl/intl.dart' as intl;

// class FaultLoggingApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'نظام تسجيل الأعطال',
//       theme: ThemeData(
//         useMaterial3: true,
//         primarySwatch: Colors.indigo,
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
//         fontFamily: 'Roboto',
//       ),
//       debugShowCheckedModeBanner: false,
//       home: MainNavigationScreen(),
//       locale: const Locale('ar', 'AE'),
//     );
//   }
// }

// class MainNavigationScreen extends StatefulWidget {
//   @override
//   _MainNavigationScreenState createState() => _MainNavigationScreenState();
// }

// class _MainNavigationScreenState extends State<MainNavigationScreen> {
//   int _selectedIndex = 0;

//   final List<Widget> _pages = [
//     FaultDashboard(),
//     FaultReportPage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         body: _pages[_selectedIndex],
//         bottomNavigationBar: BottomNavigationBar(
//           currentIndex: _selectedIndex,
//           onTap: (index) => setState(() => _selectedIndex = index),
//           items: const [
//             BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'تسجيل الأعطال'),
//             BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'التقارير'),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class FaultDashboard extends StatefulWidget {
//   @override
//   _FaultDashboardState createState() => _FaultDashboardState();
// }

// class _FaultDashboardState extends State<FaultDashboard> with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('إدارة أعطال الخطوط'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'الخط الأول'),
//             Tab(text: 'الخط الثاني'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           FaultLineView(lineName: 'الخط الأول'),
//           FaultLineView(lineName: 'الخط الثاني'),
//         ],
//       ),
//     );
//   }
// }

// class FaultLineView extends StatefulWidget {
//   final String lineName;
//   FaultLineView({required this.lineName});

//   @override
//   _FaultLineViewState createState() => _FaultLineViewState();
// }

// class _FaultLineViewState extends State<FaultLineView> {
//   final SupabaseClient supabase = Supabase.instance.client;
//   List<dynamic> activeFaults = [];
//   bool isLoading = true;
//   bool isStopLine = true;
//   String selectedFaultType = 'عطل'; // القيمة الافتراضية للعمود الجديد

//   @override
//   void initState() {
//     super.initState();
//     _fetchActiveFaults();
//   }

//   Future<void> _fetchActiveFaults() async {
//     try {
//       final response = await supabase
//           .from('Fault_Logging')
//           .select()
//           .eq('line', widget.lineName)
//           .isFilter('fix_time', null)
//           .order('fault_time', ascending: false);

//       setState(() {
//         activeFaults = response;
//         isLoading = false;
//       });
//     } catch (e) {
//       debugPrint('Error: $e');
//       setState(() => isLoading = false);
//     }
//   }

//   bool _hasBlockingFault() {
//     return activeFaults.any((f) => f['is_stop'] == true);
//   }

//   Future<void> _quickRegisterFault() async {
//     if (isStopLine && _hasBlockingFault()) {
//       _showSimpleDialog('تنبيه', 'لا يمكن تسجيل عطل موقف جديد وهناك عطل موقف نشط حالياً على هذا الخط.');
//       return;
//     }

//     bool? confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('تسجيل عطل فوري'),
//         content: Text('سيتم تسجيل ($selectedFaultType) الآن لـ ${widget.lineName}. هل أنت متأكد؟'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
//           TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('تأكيد التسجيل')),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       try {
//         await supabase.from('Fault_Logging').insert({
//           'line': widget.lineName,
//           'is_stop': isStopLine,
//           'fault_type': selectedFaultType, // حفظ القيمة الجديدة
//           'fault_time': DateTime.now().toUtc().toIso8601String(),
//         });

//         _fetchActiveFaults();
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطأ في الاتصال')));
//       }
//     }
//   }

//   void _showSimpleDialog(String title, String msg) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(title),
//         content: Text(msg),
//         actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً'))],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
//           ),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('تسجيل بلاغ لـ ${widget.lineName}', style: const TextStyle(fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 8),
//                         DropdownButtonFormField<String>(
//                           value: selectedFaultType,
//                           decoration: const InputDecoration(labelText: 'نوع البلاغ', isDense: true, border: OutlineInputBorder()),
//                           items: ['عطل', 'توقف', 'راحة'].map((String val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
//                           onChanged: (val) => setState(() => selectedFaultType = val!),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 15),
//                   Column(
//                     children: [
//                       const Text('يوقف الخط؟', style: TextStyle(fontSize: 12)),
//                       Switch(
//                         value: isStopLine,
//                         activeColor: Colors.red,
//                         onChanged: (val) => setState(() => isStopLine = val),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//               const SizedBox(height: 10),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   icon: const Icon(Icons.play_arrow),
//                   label: Text('تسجيل $selectedFaultType الآن'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: isStopLine ? Colors.red : Colors.orange,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 12)
//                   ),
//                   onPressed: _quickRegisterFault,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : activeFaults.isEmpty
//                   ? const Center(child: Text('لا توجد أعطال نشطة'))
//                   : ListView.builder(
//                       padding: const EdgeInsets.only(top: 8),
//                       itemCount: activeFaults.length,
//                       itemBuilder: (context, index) {
//                         final fault = activeFaults[index];
//                         return FaultCard(
//                           fault: fault,
//                           onRepair: () => _fetchActiveFaults(),
//                           onUpdate: _fetchActiveFaults,
//                         );
//                       },
//                     ),
//         ),
//       ],
//     );
//   }
// }

// class FaultCard extends StatefulWidget {
//   final dynamic fault;
//   final VoidCallback onRepair;
//   final VoidCallback onUpdate;

//   FaultCard({required this.fault, required this.onRepair, required this.onUpdate});

//   @override
//   _FaultCardState createState() => _FaultCardState();
// }

// class _FaultCardState extends State<FaultCard> {
//   late Timer _timer;
//   String _durationString = "00:00:00";
//   bool isEditing = false;

//   String? tempDept;
//   final TextEditingController tempReasonController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     tempDept = widget.fault['department'];
//     tempReasonController.text = widget.fault['reason'] ?? "";
//     isEditing = (tempDept == null || tempReasonController.text.isEmpty);
//     _startTimer();
//   }

//   void _startTimer() {
//     _updateTime();
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (mounted) _updateTime();
//     });
//   }

//   void _updateTime() {
//     try {
//       final startTime = DateTime.parse(widget.fault['fault_time']).toUtc();
//       final now = DateTime.now().toUtc();
//       final diff = now.difference(startTime);
//       if (mounted) {
//         setState(() {
//           _durationString = _formatDuration(diff.isNegative ? Duration.zero : diff);
//         });
//       }
//     } catch (e) {
//       debugPrint("Timer Error: $e");
//     }
//   }

//   String _formatDuration(Duration d) {
//     String twoDigits(int n) => n.toString().padLeft(2, "0");
//     return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
//   }

//   Future<void> _handleRepairRequest() async {
//     if (tempDept == null || tempReasonController.text.trim().isEmpty) {
//       setState(() => isEditing = true);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('⚠️ يرجى تسجيل الإدارة والسبب أولاً'), backgroundColor: Colors.redAccent),
//       );
//       return;
//     }

//     bool? confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('تأكيد الإصلاح'),
//         content: const Text('هل تم التأكد من حل المشكلة وإعادة الخط للعمل؟'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('لا')),
//           TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('نعم، تم')),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       await Supabase.instance.client.from('Fault_Logging').update({
//         'fix_time': DateTime.now().toUtc().toIso8601String(),
//         'department': tempDept,
//         'reason': tempReasonController.text.trim(),
//       }).eq('id', widget.fault['id']);
//       widget.onRepair();
//     }
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     tempReasonController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isStop = widget.fault['is_stop'] ?? false;
//     String fType = widget.fault['fault_type'] ?? 'عطل';

//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//           side: BorderSide(color: isStop ? Colors.red.withOpacity(0.5) : Colors.orange.withOpacity(0.5), width: 1.5)),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(isStop ? '$fType موقف 🛑' : '$fType غير موقف ⚠️',
//                         style: TextStyle(fontWeight: FontWeight.bold, color: isStop ? Colors.red : Colors.orange)),
//                     Text('الخط: ${widget.fault['line']}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
//                   ],
//                 ),
//                 Text(_durationString, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)),
//               ],
//             ),
//             const Divider(),
//             if (isEditing) ...[
//               DropdownButtonFormField<String>(
//                 value: tempDept,
//                 decoration: const InputDecoration(labelText: 'الإدارة المسئولة *', isDense: true),
//                 items: ['الإنتاج', 'الصيانة', 'الجودة'].map((String value) {
//                   return DropdownMenuItem<String>(value: value, child: Text(value));
//                 }).toList(),
//                 onChanged: (val) => setState(() => tempDept = val),
//               ),
//               TextField(
//                 controller: tempReasonController,
//                 maxLines: 2,
//                 decoration: const InputDecoration(labelText: 'السبب التفصيلي *', isDense: true),
//               ),
//               const SizedBox(height: 8),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (tempDept != null && tempReasonController.text.trim().isNotEmpty) {
//                     await Supabase.instance.client.from('Fault_Logging').update({
//                       'department': tempDept,
//                       'reason': tempReasonController.text.trim(),
//                     }).eq('id', widget.fault['id']);
//                     setState(() => isEditing = false);
//                     widget.onUpdate();
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 30)),
//                 child: const Text('حفظ البيانات فقط'),
//               ),
//             ] else ...[
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('الإدارة: ${widget.fault['department']}', style: const TextStyle(fontWeight: FontWeight.bold)),
//                         Text('السبب: ${widget.fault['reason']}'),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
//                     onPressed: () => setState(() => isEditing = true),
//                   )
//                 ],
//               ),
//             ],
//             const Divider(),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 icon: const Icon(Icons.check_circle_outline),
//                 onPressed: _handleRepairRequest,
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
//                 label: const Text('إصلاح وإغلاق البلاغ'),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// class FaultReportPage extends StatefulWidget {
//   @override
//   _FaultReportPageState createState() => _FaultReportPageState();
// }

// class _FaultReportPageState extends State<FaultReportPage> {
//   final SupabaseClient supabase = Supabase.instance.client;
//   DateTime selectedDate = DateTime.now();
//   List<dynamic> reportData = [];
//   bool loading = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchReport();
//   }

//   Future<void> _fetchReport() async {
//     setState(() => loading = true);
//     final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day).toUtc();
//     final endOfDay = startOfDay.add(const Duration(days: 1));

//     try {
//       final response = await supabase
//           .from('Fault_Logging')
//           .select()
//           .gte('fault_time', startOfDay.toIso8601String())
//           .lt('fault_time', endOfDay.toIso8601String())
//           .order('fault_time', ascending: false);

//       setState(() {
//         reportData = response;
//         loading = false;
//       });
//     } catch (e) {
//       setState(() => loading = false);
//     }
//   }

//   // حساب وقت التوقف لكل خط على حدة
//   Duration _getLineStopTime(String lineName) {
//     int totalMinutes = 0;
//     for (var f in reportData) {
//       if (f['line'] == lineName && f['is_stop'] == true && f['fix_time'] != null) {
//         final start = DateTime.parse(f['fault_time']);
//         final end = DateTime.parse(f['fix_time']);
//         totalMinutes += end.difference(start).inMinutes;
//       }
//     }
//     return Duration(minutes: totalMinutes);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final stopLine1 = _getLineStopTime('الخط الأول');
//     final stopLine2 = _getLineStopTime('الخط الثاني');

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('تقارير الأعطال اليومية'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.event),
//             onPressed: () async {
//               final picked = await showDatePicker(
//                 context: context,
//                 initialDate: selectedDate,
//                 firstDate: DateTime(2022),
//                 lastDate: DateTime.now(),
//               );
//               if (picked != null) {
//                 setState(() => selectedDate = picked);
//                 _fetchReport();
//               }
//             },
//           )
//         ],
//       ),
//       body: Column(
//         children: [
//           // عرض تفصيلي لإجمالي التوقف لكل خط في أعلى التقرير
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(color: Colors.red.shade50, border: Border(bottom: BorderSide(color: Colors.red.shade100))),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: _SummaryBox(
//                     title: 'الخط الأول',
//                     duration: stopLine1,
//                     color: Colors.red.shade900,
//                   ),
//                 ),
//                 Container(width: 1, height: 40, color: Colors.red.shade200),
//                 Expanded(
//                   child: _SummaryBox(
//                     title: 'الخط الثاني',
//                     duration: stopLine2,
//                     color: Colors.red.shade900,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: loading
//                 ? const Center(child: CircularProgressIndicator())
//                 : reportData.isEmpty
//                     ? const Center(child: Text('لا توجد بيانات لهذا اليوم'))
//                     : SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: DataTable(
//                           headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
//                           columns: const [
//                             DataColumn(label: Text('الخط')),
//                             DataColumn(label: Text('التصنيف')),
//                             DataColumn(label: Text('الحالة')),
//                             DataColumn(label: Text('البداية')),
//                             DataColumn(label: Text('الإصلاح')),
//                             DataColumn(label: Text('المدة')),
//                             DataColumn(label: Text('الإدارة')),
//                             DataColumn(label: Text('السبب')),
//                           ],
//                           rows: reportData.map((f) => DataRow(cells: [
//                                 DataCell(Text(f['line'] ?? '-')),
//                                 DataCell(Text(f['fault_type'] ?? 'عطل')),
//                                 DataCell(
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                                     decoration: BoxDecoration(
//                                       color: f['is_stop'] == true ? Colors.red.shade100 : Colors.orange.shade100,
//                                       borderRadius: BorderRadius.circular(4),
//                                     ),
//                                     child: Text(f['is_stop'] == true ? 'موقف' : 'لا يوقف',
//                                         style: TextStyle(color: f['is_stop'] == true ? Colors.red.shade900 : Colors.orange.shade900, fontSize: 11)),
//                                   ),
//                                 ),
//                                 DataCell(Text(intl.DateFormat('HH:mm').format(DateTime.parse(f['fault_time']).toLocal()))),
//                                 DataCell(Text(f['fix_time'] != null ? intl.DateFormat('HH:mm').format(DateTime.parse(f['fix_time']).toLocal()) : 'نشط')),
//                                 DataCell(Text(_calculateDuration(f))),
//                                 DataCell(Text(f['department'] ?? '-')),
//                                 DataCell(Text(f['reason'] ?? '-')),
//                               ])).toList(),
//                         ),
//                       ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _calculateDuration(dynamic fault) {
//     if (fault['fix_time'] == null) return "مستمر";
//     final start = DateTime.parse(fault['fault_time']);
//     final end = DateTime.parse(fault['fix_time']);
//     final diff = end.difference(start);
//     return "${diff.inHours}س ${diff.inMinutes.remainder(60)}د";
//   }
// }

// class _SummaryBox extends StatelessWidget {
//   final String title;
//   final Duration duration;
//   final Color color;

//   const _SummaryBox({required this.title, required this.duration, required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//         Text(
//           '${duration.inHours}س ${duration.inMinutes.remainder(60)}د',
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:intl/intl.dart' as intl;

class FaultLoggingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام تسجيل الأعطال',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.indigo,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: MainNavigationScreen(),
      locale: const Locale('ar', 'AE'),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    FaultDashboard(),
    FaultReportPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'تسجيل الأعطال'),
            BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'التقارير'),
          ],
        ),
      ),
    );
  }
}

// --- شاشة لوحة التحكم وتسجيل الأعطال (بدون تغيير كبير عن النسخة السابقة) ---
class FaultDashboard extends StatefulWidget {
  @override
  _FaultDashboardState createState() => _FaultDashboardState();
}

class _FaultDashboardState extends State<FaultDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة أعطال الخطوط'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الخط الأول'),
            Tab(text: 'الخط الثاني'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FaultLineView(lineName: 'الخط الأول'),
          FaultLineView(lineName: 'الخط الثاني'),
        ],
      ),
    );
  }
}

class FaultLineView extends StatefulWidget {
  final String lineName;
  FaultLineView({required this.lineName});

  @override
  _FaultLineViewState createState() => _FaultLineViewState();
}

class _FaultLineViewState extends State<FaultLineView> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> activeFaults = [];
  bool isLoading = true;
  bool isStopLine = true;
  String selectedFaultType = 'عطل'; 

  @override
  void initState() {
    super.initState();
    _fetchActiveFaults();
  }

  Future<void> _fetchActiveFaults() async {
    try {
      final response = await supabase
          .from('Fault_Logging')
          .select()
          .eq('line', widget.lineName)
          .isFilter('fix_time', null)
          .order('fault_time', ascending: false);

      setState(() {
        activeFaults = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _quickRegisterFault() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد التسجيل'),
        content: Text('سيتم تسجيل ($selectedFaultType) للـ ${widget.lineName}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('تأكيد')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await supabase.from('Fault_Logging').insert({
          'line': widget.lineName,
          'is_stop': isStopLine,
          'fault_type': selectedFaultType,
          'fault_time': DateTime.now().toUtc().toIso8601String(),
        });
        _fetchActiveFaults();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطأ في الاتصال')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedFaultType,
                      decoration: const InputDecoration(labelText: 'نوع البلاغ', border: OutlineInputBorder()),
                      items: ['عطل', 'توقف', 'راحة'].map((String val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                      onChanged: (val) => setState(() => selectedFaultType = val!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      const Text('توقف؟', style: TextStyle(fontSize: 10)),
                      Switch(value: isStopLine, activeColor: Colors.red, onChanged: (val) => setState(() => isStopLine = val)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: isStopLine ? Colors.red : Colors.orange, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 45)),
                onPressed: _quickRegisterFault,
                child: Text('تسجيل $selectedFaultType الآن'),
              ),
            ],
          ),
        ),
        Expanded(
          child: isLoading 
            ? const Center(child: CircularProgressIndicator()) 
            : ListView.builder(
                itemCount: activeFaults.length,
                itemBuilder: (context, index) => FaultCard(
                  fault: activeFaults[index],
                  onRepair: _fetchActiveFaults,
                  onUpdate: _fetchActiveFaults,
                ),
              ),
        ),
      ],
    );
  }
}

// --- شاشة التقارير المعدلة بفلتر النوع والسكرول ---
class FaultReportPage extends StatefulWidget {
  @override
  _FaultReportPageState createState() => _FaultReportPageState();
}

class _FaultReportPageState extends State<FaultReportPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  DateTime selectedDate = DateTime.now();
  List<dynamic> allReportData = []; // البيانات الكاملة لليوم
  bool loading = false;
  
  String typeFilter = 'الكل'; // فلتر النوع: الكل، عطل، توقف، راحة

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    setState(() => loading = true);
    final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day).toUtc();
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      final response = await supabase
          .from('Fault_Logging')
          .select()
          .gte('fault_time', startOfDay.toIso8601String())
          .lt('fault_time', endOfDay.toIso8601String())
          .order('fault_time', ascending: false);

      setState(() {
        allReportData = response;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  // تصفية البيانات محلياً بناءً على الفلتر المختار
  List<dynamic> get filteredData {
    if (typeFilter == 'الكل') return allReportData;
    return allReportData.where((f) => f['fault_type'] == typeFilter).toList();
  }

  // حساب وقت التوقف لخط معين مع مراعاة الفلتر الحالي
  Duration _getLineStopTime(String lineName) {
    int totalMinutes = 0;
    for (var f in filteredData) {
      if (f['line'] == lineName && f['is_stop'] == true && f['fix_time'] != null) {
        final start = DateTime.parse(f['fault_time']);
        final end = DateTime.parse(f['fix_time']);
        totalMinutes += end.difference(start).inMinutes;
      }
    }
    return Duration(minutes: totalMinutes);
  }

  @override
  Widget build(BuildContext context) {
    final stopLine1 = _getLineStopTime('الخط الأول');
    final stopLine2 = _getLineStopTime('الخط الثاني');

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقارير الأعطال اليومية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.event),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2022),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => selectedDate = picked);
                _fetchReport();
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          // 1. فلتر النوع العلوي
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.indigo.shade50,
            child: Row(
              children: [
                const Text('فلتر النوع:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'الكل', label: Text('الكل', style: TextStyle(fontSize: 12))),
                      ButtonSegment(value: 'عطل', label: Text('عطل', style: TextStyle(fontSize: 12))),
                      ButtonSegment(value: 'توقف', label: Text('توقف', style: TextStyle(fontSize: 12))),
                      ButtonSegment(value: 'راحة', label: Text('راحة', style: TextStyle(fontSize: 12))),
                    ],
                    selected: {typeFilter},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() => typeFilter = newSelection.first);
                    },
                    style: SegmentedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      selectedBackgroundColor: Colors.indigo,
                      selectedForegroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 2. إجمالي الوقت لكل خط (يتأثر بالفلتر)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
            child: Row(
              children: [
                Expanded(child: _SummaryBox(title: 'الخط الأول (توقف)', duration: stopLine1, color: Colors.red.shade700)),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                Expanded(child: _SummaryBox(title: 'الخط الثاني (توقف)', duration: stopLine2, color: Colors.red.shade700)),
              ],
            ),
          ),

          // 3. جدول البيانات مع سكرول رأسي وأفقي
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : filteredData.isEmpty
                    ? const Center(child: Text('لا توجد بيانات تطابق الفلتر'))
                    : Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.grey.shade200),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical, // سكرول رأسي
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal, // سكرول أفقي
                            child: DataTable(
                              columnSpacing: 20,
                              headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
                              columns: const [
                                DataColumn(label: Text('الخط')),
                                DataColumn(label: Text('النوع')),
                                DataColumn(label: Text('الحالة')),
                                DataColumn(label: Text('البداية')),
                                DataColumn(label: Text('الإصلاح')),
                                DataColumn(label: Text('المدة')),
                                DataColumn(label: Text('الإدارة')),
                                DataColumn(label: Text('السبب')),
                              ],
                              rows: filteredData.map((f) => DataRow(cells: [
                                DataCell(Text(f['line'] ?? '-')),
                                DataCell(Text(f['fault_type'] ?? '-')),
                                DataCell(Text(f['is_stop'] == true ? 'موقف' : 'لا يوقف')),
                                DataCell(Text(intl.DateFormat('HH:mm').format(DateTime.parse(f['fault_time']).toLocal()))),
                                DataCell(Text(f['fix_time'] != null ? intl.DateFormat('HH:mm').format(DateTime.parse(f['fix_time']).toLocal()) : 'نشط')),
                                DataCell(Text(_calculateDuration(f))),
                                DataCell(Text(f['department'] ?? '-')),
                                DataCell(Text(f['reason'] ?? '-')),
                              ])).toList(),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  String _calculateDuration(dynamic fault) {
    if (fault['fix_time'] == null) return "مستمر";
    final start = DateTime.parse(fault['fault_time']);
    final end = DateTime.parse(fault['fix_time']);
    final diff = end.difference(start);
    return "${diff.inHours}س ${diff.inMinutes.remainder(60)}د";
  }
}

class _SummaryBox extends StatelessWidget {
  final String title;
  final Duration duration;
  final Color color;
  const _SummaryBox({required this.title, required this.duration, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text('${duration.inHours}س ${duration.inMinutes.remainder(60)}د',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

// --- كارت العطل النشط (بدون تغييرات جوهرية) ---
class FaultCard extends StatefulWidget {
  final dynamic fault;
  final VoidCallback onRepair;
  final VoidCallback onUpdate;
  FaultCard({required this.fault, required this.onRepair, required this.onUpdate});

  @override
  _FaultCardState createState() => _FaultCardState();
}

class _FaultCardState extends State<FaultCard> {
  late Timer _timer;
  String _durationString = "00:00:00";
  bool isEditing = false;
  String? tempDept;
  final TextEditingController tempReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tempDept = widget.fault['department'];
    tempReasonController.text = widget.fault['reason'] ?? "";
    isEditing = (tempDept == null || tempReasonController.text.isEmpty);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) => _updateTime());
  }

  void _updateTime() {
    if (!mounted) return;
    final start = DateTime.parse(widget.fault['fault_time']).toUtc();
    final diff = DateTime.now().toUtc().difference(start);
    setState(() {
      String two(int n) => n.toString().padLeft(2, '0');
      _durationString = "${two(diff.inHours)}:${two(diff.inMinutes.remainder(60))}:${two(diff.inSeconds.remainder(60))}";
    });
  }

  @override
  void dispose() { _timer.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${widget.fault['fault_type']} - ${widget.fault['line']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(_durationString, style: const TextStyle(fontSize: 18, color: Colors.indigo, fontWeight: FontWeight.bold)),
              ],
            ),
            if (isEditing) ...[
              DropdownButtonFormField<String>(
                value: tempDept,
                items: ['الإنتاج', 'الصيانة', 'الجودة'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => tempDept = v,
                decoration: const InputDecoration(labelText: 'الإدارة'),
              ),
              TextField(controller: tempReasonController, decoration: const InputDecoration(labelText: 'السبب')),
              TextButton(onPressed: () async {
                await Supabase.instance.client.from('Fault_Logging').update({
                  'department': tempDept,
                  'reason': tempReasonController.text,
                }).eq('id', widget.fault['id']);
                setState(() => isEditing = false);
                widget.onUpdate();
              }, child: const Text('حفظ مؤقت'))
            ] else 
              ListTile(
                title: Text("الإدارة: ${widget.fault['department']}"),
                subtitle: Text("السبب: ${widget.fault['reason']}"),
                trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => setState(() => isEditing = true)),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 35)),
              onPressed: () async {
                if (tempDept == null || tempReasonController.text.isEmpty) return;
                await Supabase.instance.client.from('Fault_Logging').update({
                  'fix_time': DateTime.now().toUtc().toIso8601String(),
                  'department': tempDept,
                  'reason': tempReasonController.text,
                }).eq('id', widget.fault['id']);
                widget.onRepair();
              },
              child: const Text('إصلاح وإغلاق'),
            )
          ],
        ),
      ),
    );
  }
}