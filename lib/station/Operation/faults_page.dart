
// // // // import 'package:flutter/material.dart';
// // // // import 'package:supabase_flutter/supabase_flutter.dart';
// // // // import 'dart:async';
// // // // import 'package:intl/intl.dart' as intl;

// // // // class FaultLoggingApp extends StatelessWidget {
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return MaterialApp(
// // // //       title: 'نظام تسجيل الأعطال',
// // // //       theme: ThemeData(
// // // //         primarySwatch: Colors.indigo,
// // // //         fontFamily: 'Roboto',
// // // //       ),
// // // //       debugShowCheckedModeBanner: false,
// // // //       home: MainNavigationScreen(),
// // // //       locale: Locale('ar', 'AE'),
// // // //     );
// // // //   }
// // // // }

// // // // class MainNavigationScreen extends StatefulWidget {
// // // //   @override
// // // //   _MainNavigationScreenState createState() => _MainNavigationScreenState();
// // // // }

// // // // class _MainNavigationScreenState extends State<MainNavigationScreen> {
// // // //   int _selectedIndex = 0;
  
// // // //   final List<Widget> _pages = [
// // // //     FaultDashboard(),
// // // //     FaultReportPage(),
// // // //   ];

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Directionality(
// // // //       textDirection: TextDirection.rtl,
// // // //       child: Scaffold(
// // // //         body: _pages[_selectedIndex],
// // // //         bottomNavigationBar: BottomNavigationBar(
// // // //           currentIndex: _selectedIndex,
// // // //           onTap: (index) => setState(() => _selectedIndex = index),
// // // //           items: [
// // // //             BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'تسجيل الأعطال'),
// // // //             BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'التقارير'),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // class FaultDashboard extends StatefulWidget {
// // // //   @override
// // // //   _FaultDashboardState createState() => _FaultDashboardState();
// // // // }

// // // // class _FaultDashboardState extends State<FaultDashboard> with SingleTickerProviderStateMixin {
// // // //   late TabController _tabController;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _tabController = TabController(length: 2, vsync: this);
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       appBar: AppBar(
// // // //         title: Text('إدارة أعطال الخطوط'),
// // // //         bottom: TabBar(
// // // //           controller: _tabController,
// // // //           tabs: [
// // // //             Tab(text: 'الخط الأول'),
// // // //             Tab(text: 'الخط الثاني'),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //       body: TabBarView(
// // // //         controller: _tabController,
// // // //         children: [
// // // //           FaultLineView(lineName: 'الخط الأول'),
// // // //           FaultLineView(lineName: 'الخط الثاني'),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // class FaultLineView extends StatefulWidget {
// // // //   final String lineName;
// // // //   FaultLineView({required this.lineName});

// // // //   @override
// // // //   _FaultLineViewState createState() => _FaultLineViewState();
// // // // }

// // // // class _FaultLineViewState extends State<FaultLineView> {
// // // //   final SupabaseClient supabase = Supabase.instance.client;
// // // //   List<dynamic> activeFaults = [];
// // // //   bool isLoading = true;
// // // //   bool isStopLine = true;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _fetchActiveFaults();
// // // //   }

// // // //   Future<void> _fetchActiveFaults() async {
// // // //     try {
// // // //       final response = await supabase
// // // //           .from('Fault_Logging')
// // // //           .select()
// // // //           .eq('line', widget.lineName)
// // // //           .isFilter('fix_time', null)
// // // //           .order('fault_time', ascending: false);
      
// // // //       setState(() {
// // // //         activeFaults = response;
// // // //         isLoading = false;
// // // //       });
// // // //     } catch (e) {
// // // //       debugPrint('Error: $e');
// // // //     }
// // // //   }

// // // //   bool _hasBlockingFault() {
// // // //     return activeFaults.any((f) => f['is_stop'] == true);
// // // //   }

// // // //   Future<void> _quickRegisterFault() async {
// // // //     if (isStopLine && _hasBlockingFault()) {
// // // //       _showErrorDialog('لا يمكن تسجيل عطل موقف جديد وهناك عطل موقف نشط حالياً على هذا الخط.');
// // // //       return;
// // // //     }

// // // //     bool? confirm = await showDialog<bool>(
// // // //       context: context,
// // // //       builder: (context) => AlertDialog(
// // // //         title: Text('تسجيل عطل فوري'),
// // // //         content: Text('سيتم تسجيل عطل الآن لـ ${widget.lineName} بتاريخ ووقت اللحظة الحالية. هل أنت متأكد؟'),
// // // //         actions: [
// // // //           TextButton(onPressed: () => Navigator.pop(context, false), child: Text('إلغاء')),
// // // //           TextButton(onPressed: () => Navigator.pop(context, true), child: Text('تأكيد التسجيل')),
// // // //         ],
// // // //       ),
// // // //     );

// // // //     if (confirm == true) {
// // // //       try {
// // // //         await supabase.from('Fault_Logging').insert({
// // // //           'line': widget.lineName,
// // // //           'is_stop': isStopLine,
// // // //           'fault_time': DateTime.now().toIso8601String(),
// // // //         });
        
// // // //         _fetchActiveFaults();
// // // //       } catch (e) {
// // // //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في الاتصال')));
// // // //       }
// // // //     }
// // // //   }

// // // //   void _showErrorDialog(String msg) {
// // // //     showDialog(
// // // //       context: context,
// // // //       builder: (context) => AlertDialog(
// // // //         title: Row(children: [Icon(Icons.warning, color: Colors.orange), SizedBox(width: 8), Text('تنبيه')]),
// // // //         content: Text(msg),
// // // //         actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('حسناً'))],
// // // //       ),
// // // //     );
// // // //   }

// // // //   Future<void> _repairFault(int id) async {
// // // //     bool? confirm = await showDialog<bool>(
// // // //       context: context,
// // // //       builder: (context) => AlertDialog(
// // // //         title: Text('تأكيد الإصلاح'),
// // // //         content: Text('هل تم الانتهاء من إصلاح هذا العطل؟'),
// // // //         actions: [
// // // //           TextButton(onPressed: () => Navigator.pop(context, false), child: Text('لا')),
// // // //           TextButton(onPressed: () => Navigator.pop(context, true), child: Text('نعم')),
// // // //         ],
// // // //       ),
// // // //     );

// // // //     if (confirm == true) {
// // // //       await supabase.from('Fault_Logging').update({
// // // //         'fix_time': DateTime.now().toIso8601String(),
// // // //       }).eq('id', id);
// // // //       _fetchActiveFaults();
// // // //     }
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Column(
// // // //       children: [
// // // //         Container(
// // // //           padding: EdgeInsets.all(16),
// // // //           decoration: BoxDecoration(
// // // //             color: Colors.white,
// // // //             boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
// // // //           ),
// // // //           child: Row(
// // // //             children: [
// // // //               Expanded(
// // // //                 child: Column(
// // // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // // //                   children: [
// // // //                     Text('تسجيل عطل جديد لـ ${widget.lineName}', style: TextStyle(fontWeight: FontWeight.bold)),
// // // //                     Row(
// // // //                       children: [
// // // //                         Text('يوقف الخط؟'),
// // // //                         Switch(
// // // //                           value: isStopLine,
// // // //                           activeColor: Colors.red,
// // // //                           onChanged: (val) => setState(() => isStopLine = val),
// // // //                         ),
// // // //                       ],
// // // //                     ),
// // // //                   ],
// // // //                 ),
// // // //               ),
// // // //               ElevatedButton.icon(
// // // //                 icon: Icon(Icons.play_arrow),
// // // //                 label: Text('سجل العطل الآن'),
// // // //                 style: ElevatedButton.styleFrom(
// // // //                   backgroundColor: isStopLine ? Colors.red : Colors.orange,
// // // //                   foregroundColor: Colors.white,
// // // //                   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15)
// // // //                 ),
// // // //                 onPressed: _quickRegisterFault,
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
        
// // // //         Expanded(
// // // //           child: isLoading 
// // // //             ? Center(child: CircularProgressIndicator())
// // // //             : activeFaults.isEmpty 
// // // //               ? Center(child: Text('لا توجد أعطال نشطة'))
// // // //               : ListView.builder(
// // // //                   padding: EdgeInsets.only(top: 8),
// // // //                   itemCount: activeFaults.length,
// // // //                   itemBuilder: (context, index) {
// // // //                     final fault = activeFaults[index];
// // // //                     return FaultCard(
// // // //                       fault: fault,
// // // //                       onRepair: () => _repairFault(fault['id']),
// // // //                       onUpdate: _fetchActiveFaults,
// // // //                     );
// // // //                   },
// // // //                 ),
// // // //         ),
// // // //       ],
// // // //     );
// // // //   }
// // // // }

// // // // class FaultCard extends StatefulWidget {
// // // //   final dynamic fault;
// // // //   final VoidCallback onRepair;
// // // //   final VoidCallback onUpdate;

// // // //   FaultCard({required this.fault, required this.onRepair, required this.onUpdate});

// // // //   @override
// // // //   _FaultCardState createState() => _FaultCardState();
// // // // }

// // // // class _FaultCardState extends State<FaultCard> {
// // // //   late Timer _timer;
// // // //   String _durationString = "00:00:00";
  
// // // //   String? tempDept;
// // // //   final TextEditingController tempReasonController = TextEditingController();
// // // //   bool isEditing = false;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     tempDept = widget.fault['department'];
// // // //     tempReasonController.text = widget.fault['reason'] ?? "";
// // // //     isEditing = (tempDept == null || tempReasonController.text.isEmpty);
// // // //     _startTimer();
// // // //   }

// // // //   void _startTimer() {
// // // //     // تحديث فوري عند التشغيل
// // // //     _updateTime();
// // // //     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
// // // //       if (mounted) {
// // // //         _updateTime();
// // // //       }
// // // //     });
// // // //   }

// // // //   void _updateTime() {
// // // //     final startTime = DateTime.parse(widget.fault['fault_time']);
// // // //     final diff = DateTime.now().difference(startTime);
// // // //     setState(() {
// // // //       _durationString = _formatDuration(diff);
// // // //     });
// // // //   }

// // // //   String _formatDuration(Duration duration) {
// // // //     String twoDigits(int n) => n.toString().padLeft(2, "0");
// // // //     // العداد يبدأ من الصفر ويتصاعد
// // // //     return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
// // // //   }

// // // //   Future<void> _updateFaultInfo() async {
// // // //     if (tempDept == null || tempReasonController.text.isEmpty) {
// // // //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('يرجى إكمال جميع البيانات')));
// // // //       return;
// // // //     }
    
// // // //     await Supabase.instance.client.from('Fault_Logging').update({
// // // //       'department': tempDept,
// // // //       'reason': tempReasonController.text,
// // // //     }).eq('id', widget.fault['id']);
    
// // // //     setState(() => isEditing = false);
// // // //     widget.onUpdate();
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _timer.cancel();
// // // //     tempReasonController.dispose();
// // // //     super.dispose();
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     bool isStop = widget.fault['is_stop'] ?? false;
    
// // // //     return Card(
// // // //       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // // //       shape: RoundedRectangleBorder(
// // // //         borderRadius: BorderRadius.circular(12),
// // // //         side: BorderSide(color: isStop ? Colors.red.withOpacity(0.5) : Colors.orange.withOpacity(0.5), width: 1.5)
// // // //       ),
// // // //       child: Padding(
// // // //         padding: const EdgeInsets.all(12.0),
// // // //         child: Column(
// // // //           children: [
// // // //             Row(
// // // //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //               children: [
// // // //                 Text(isStop ? 'عطل موقف للخط 🛑' : 'عطل غير موقف ⚠️', 
// // // //                      style: TextStyle(fontWeight: FontWeight.bold, color: isStop ? Colors.red : Colors.orange)),
// // // //                 Text(_durationString, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)),
// // // //               ],
// // // //             ),
// // // //             Divider(),
            
// // // //             if (isEditing) ...[
// // // //               DropdownButtonFormField<String>(
// // // //                 value: tempDept,
// // // //                 decoration: InputDecoration(labelText: 'الإدارة المسئولة', isDense: true),
// // // //                 items: ['الإنتاج', 'الصيانة', 'الجودة'].map((String value) {
// // // //                   return DropdownMenuItem<String>(value: value, child: Text(value));
// // // //                 }).toList(),
// // // //                 onChanged: (val) => setState(() => tempDept = val),
// // // //               ),
// // // //               TextField(
// // // //                 controller: tempReasonController,
// // // //                 decoration: InputDecoration(labelText: 'سبب العطل', isDense: true),
// // // //               ),
// // // //               SizedBox(height: 8),
// // // //               ElevatedButton(
// // // //                 onPressed: _updateFaultInfo,
// // // //                 child: Text('حفظ بيانات العطل'),
// // // //                 style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 35)),
// // // //               ),
// // // //             ] else ...[
// // // //               Row(
// // // //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //                 children: [
// // // //                   Expanded(
// // // //                     child: Column(
// // // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // // //                       children: [
// // // //                         Text('الإدارة: ${widget.fault['department']}', style: TextStyle(fontWeight: FontWeight.bold)),
// // // //                         Text('السبب: ${widget.fault['reason']}'),
// // // //                       ],
// // // //                     ),
// // // //                   ),
// // // //                   IconButton(
// // // //                     icon: Icon(Icons.edit, size: 20, color: Colors.blue),
// // // //                     onPressed: () => setState(() => isEditing = true),
// // // //                   )
// // // //                 ],
// // // //               ),
// // // //             ],
            
// // // //             Divider(),
// // // //             SizedBox(
// // // //               width: double.infinity,
// // // //               child: ElevatedButton(
// // // //                 onPressed: widget.onRepair,
// // // //                 child: Text('تم الإصلاح'),
// // // //                 style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
// // // //               ),
// // // //             )
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // class FaultReportPage extends StatefulWidget {
// // // //   @override
// // // //   _FaultReportPageState createState() => _FaultReportPageState();
// // // // }

// // // // class _FaultReportPageState extends State<FaultReportPage> {
// // // //   final SupabaseClient supabase = Supabase.instance.client;
// // // //   DateTime selectedDate = DateTime.now();
// // // //   List<dynamic> reportData = [];
// // // //   bool loading = false;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _fetchReport();
// // // //   }

// // // //   Future<void> _fetchReport() async {
// // // //     setState(() => loading = true);
// // // //     final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
// // // //     final endOfDay = startOfDay.add(Duration(days: 1));

// // // //     try {
// // // //       final response = await supabase
// // // //           .from('Fault_Logging')
// // // //           .select()
// // // //           .gte('fault_time', startOfDay.toIso8601String())
// // // //           .lt('fault_time', endOfDay.toIso8601String())
// // // //           .order('fault_time', ascending: false);
      
// // // //       setState(() {
// // // //         reportData = response;
// // // //         loading = false;
// // // //       });
// // // //     } catch (e) {
// // // //       setState(() => loading = false);
// // // //     }
// // // //   }

// // // //   Duration _getTotalStopTime() {
// // // //     int totalMinutes = 0;
// // // //     for (var f in reportData) {
// // // //       if (f['is_stop'] == true && f['fix_time'] != null) {
// // // //         final start = DateTime.parse(f['fault_time']);
// // // //         final end = DateTime.parse(f['fix_time']);
// // // //         totalMinutes += end.difference(start).inMinutes;
// // // //       }
// // // //     }
// // // //     return Duration(minutes: totalMinutes);
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final totalStop = _getTotalStopTime();
    
// // // //     return Scaffold(
// // // //       appBar: AppBar(
// // // //         title: Text('تقارير الأعطال اليومية'),
// // // //         actions: [
// // // //           IconButton(
// // // //             icon: Icon(Icons.event),
// // // //             onPressed: () async {
// // // //               final picked = await showDatePicker(
// // // //                 context: context,
// // // //                 initialDate: selectedDate,
// // // //                 firstDate: DateTime(2022),
// // // //                 lastDate: DateTime.now(),
// // // //               );
// // // //               if (picked != null) {
// // // //                 setState(() => selectedDate = picked);
// // // //                 _fetchReport();
// // // //               }
// // // //             },
// // // //           )
// // // //         ],
// // // //       ),
// // // //       body: Column(
// // // //         children: [
// // // //           // ملخص إجمالي وقت التوقف
// // // //           Container(
// // // //             padding: EdgeInsets.all(16),
// // // //             width: double.infinity,
// // // //             color: Colors.red.shade50,
// // // //             child: Row(
// // // //               mainAxisAlignment: MainAxisAlignment.center,
// // // //               children: [
// // // //                 Icon(Icons.timer_off, color: Colors.red),
// // // //                 SizedBox(width: 8),
// // // //                 Text(
// // // //                   'إجمالي وقت توقف الخطوط: ${totalStop.inHours}س ${totalStop.inMinutes.remainder(60)}د',
// // // //                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red.shade900),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //           Expanded(
// // // //             child: loading 
// // // //               ? Center(child: CircularProgressIndicator())
// // // //               : reportData.isEmpty
// // // //                 ? Center(child: Text('لا توجد بيانات لهذا اليوم'))
// // // //                 : SingleChildScrollView(
// // // //                     scrollDirection: Axis.horizontal,
// // // //                     child: DataTable(
// // // //                       headingTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
// // // //                       columns: [
// // // //                         DataColumn(label: Text('الخط')),
// // // //                         DataColumn(label: Text('نوع العطل')),
// // // //                         DataColumn(label: Text('البداية')),
// // // //                         DataColumn(label: Text('الإصلاح')),
// // // //                         DataColumn(label: Text('المدة')),
// // // //                         DataColumn(label: Text('الإدارة')),
// // // //                         DataColumn(label: Text('السبب')),
// // // //                       ],
// // // //                       rows: reportData.map((f) => DataRow(cells: [
// // // //                         DataCell(Text(f['line'] ?? '-')),
// // // //                         DataCell(
// // // //                           Container(
// // // //                             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// // // //                             decoration: BoxDecoration(
// // // //                               color: f['is_stop'] == true ? Colors.red.shade100 : Colors.orange.shade100,
// // // //                               borderRadius: BorderRadius.circular(8),
// // // //                             ),
// // // //                             child: Text(
// // // //                               f['is_stop'] == true ? 'موقف للخط' : 'لا يوقف',
// // // //                               style: TextStyle(color: f['is_stop'] == true ? Colors.red.shade900 : Colors.orange.shade900, fontSize: 12),
// // // //                             ),
// // // //                           )
// // // //                         ),
// // // //                         DataCell(Text(intl.DateFormat('HH:mm').format(DateTime.parse(f['fault_time'])))),
// // // //                         DataCell(Text(f['fix_time'] != null ? intl.DateFormat('HH:mm').format(DateTime.parse(f['fix_time'])) : 'نشط')),
// // // //                         DataCell(Text(_calculateDuration(f))),
// // // //                         DataCell(Text(f['department'] ?? '-')),
// // // //                         DataCell(Text(f['reason'] ?? '-')),
// // // //                       ])).toList(),
// // // //                     ),
// // // //                   ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   String _calculateDuration(dynamic fault) {
// // // //     if (fault['fix_time'] == null) return "مستمر";
// // // //     final start = DateTime.parse(fault['fault_time']);
// // // //     final end = DateTime.parse(fault['fix_time']);
// // // //     final diff = end.difference(start);
// // // //     return "${diff.inHours}س ${diff.inMinutes.remainder(60)}د";
// // // //   }
// // // // }
// // // import 'package:flutter/material.dart';
// // // import 'package:supabase_flutter/supabase_flutter.dart';
// // // import 'dart:async';
// // // import 'package:intl/intl.dart' as intl;

// // // void main() async {
// // //   // تأكد من تهيئة Supabase هنا قبل تشغيل التطبيق
// // //   // await Supabase.initialize(url: 'YOUR_URL', anonKey: 'YOUR_KEY');
// // //   runApp(FaultLoggingApp());
// // // }

// // // class FaultLoggingApp extends StatelessWidget {
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return MaterialApp(
// // //       title: 'نظام تسجيل الأعطال الذكي',
// // //       theme: ThemeData(
// // //         useMaterial3: true,
// // //         primaryColor: const Color(0xFF1A237E),
// // //         colorScheme: ColorScheme.fromSeed(
// // //           seedColor: const Color(0xFF1A237E),
// // //           primary: const Color(0xFF1A237E),
// // //           secondary: const Color(0xFF00BFA5),
// // //         ),
// // //         fontFamily: 'Roboto',
// // //       ),
// // //       debugShowCheckedModeBanner: false,
// // //       home: MainNavigationScreen(),
// // //       locale: const Locale('ar', 'AE'),
// // //     );
// // //   }
// // // }

// // // class MainNavigationScreen extends StatefulWidget {
// // //   @override
// // //   _MainNavigationScreenState createState() => _MainNavigationScreenState();
// // // }

// // // class _MainNavigationScreenState extends State<MainNavigationScreen> {
// // //   int _selectedIndex = 0;
  
// // //   final List<Widget> _pages = [
// // //     FaultDashboard(),
// // //     FaultReportPage(),
// // //   ];

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Directionality(
// // //       textDirection: TextDirection.rtl,
// // //       child: Scaffold(
// // //         body: _pages[_selectedIndex],
// // //         bottomNavigationBar: NavigationBar(
// // //           selectedIndex: _selectedIndex,
// // //           onDestinationSelected: (index) => setState(() => _selectedIndex = index),
// // //           destinations: const [
// // //             NavigationDestination(icon: Icon(Icons.dashboard_customize), label: 'لوحة التحكم'),
// // //             NavigationDestination(icon: Icon(Icons.analytics_outlined), label: 'التقارير'),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }

// // // class FaultDashboard extends StatefulWidget {
// // //   @override
// // //   _FaultDashboardState createState() => _FaultDashboardState();
// // // }

// // // class _FaultDashboardState extends State<FaultDashboard> with SingleTickerProviderStateMixin {
// // //   late TabController _tabController;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _tabController = TabController(length: 2, vsync: this);
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: const Text('إدارة أعطال الخطوط التشغيلية', style: TextStyle(fontWeight: FontWeight.bold)),
// // //         centerTitle: true,
// // //         backgroundColor: Colors.white,
// // //         elevation: 0,
// // //         bottom: TabBar(
// // //           controller: _tabController,
// // //           labelColor: const Color(0xFF1A237E),
// // //           unselectedLabelColor: Colors.grey,
// // //           indicatorColor: const Color(0xFF1A237E),
// // //           indicatorWeight: 3,
// // //           tabs: const [
// // //             Tab(child: Text('الخط الأول', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
// // //             Tab(child: Text('الخط الثاني', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
// // //           ],
// // //         ),
// // //       ),
// // //       body: TabBarView(
// // //         controller: _tabController,
// // //         children: [
// // //           FaultLineView(lineName: 'الخط الأول'),
// // //           FaultLineView(lineName: 'الخط الثاني'),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }

// // // class FaultLineView extends StatefulWidget {
// // //   final String lineName;
// // //   FaultLineView({required this.lineName});

// // //   @override
// // //   _FaultLineViewState createState() => _FaultLineViewState();
// // // }

// // // class _FaultLineViewState extends State<FaultLineView> {
// // //   final SupabaseClient supabase = Supabase.instance.client;
// // //   List<dynamic> activeFaults = [];
// // //   bool isLoading = true;
// // //   bool isStopLine = true;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _fetchActiveFaults();
// // //   }

// // //   Future<void> _fetchActiveFaults() async {
// // //     try {
// // //       final response = await supabase
// // //           .from('Fault_Logging')
// // //           .select()
// // //           .eq('line', widget.lineName)
// // //           .isFilter('fix_time', null)
// // //           .order('fault_time', ascending: false);
      
// // //       setState(() {
// // //         activeFaults = response;
// // //         isLoading = false;
// // //       });
// // //     } catch (e) {
// // //       debugPrint('Error: $e');
// // //       setState(() => isLoading = false);
// // //     }
// // //   }

// // //   bool _hasBlockingFault() {
// // //     return activeFaults.any((f) => f['is_stop'] == true);
// // //   }

// // //   Future<void> _quickRegisterFault() async {
// // //     if (isStopLine && _hasBlockingFault()) {
// // //       _showErrorDialog('تنبيه: يوجد عطل موقف نشط حالياً على هذا الخط. يرجى إنهاء العطل الحالي أولاً.');
// // //       return;
// // //     }

// // //     bool? confirm = await showDialog<bool>(
// // //       context: context,
// // //       builder: (context) => AlertDialog(
// // //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
// // //         title: const Text('تأكيد تسجيل عطل'),
// // //         content: Text('هل تريد تسجيل عطل ${isStopLine ? "موقف" : "بسيط"} للخط الآن؟'),
// // //         actions: [
// // //           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
// // //           ElevatedButton(
// // //             onPressed: () => Navigator.pop(context, true),
// // //             style: ElevatedButton.styleFrom(backgroundColor: isStopLine ? Colors.red : Colors.orange),
// // //             child: const Text('تأكيد وتسجيل', style: TextStyle(color: Colors.white)),
// // //           ),
// // //         ],
// // //       ),
// // //     );

// // //     if (confirm == true) {
// // //       try {
// // //         await supabase.from('Fault_Logging').insert({
// // //           'line': widget.lineName,
// // //           'is_stop': isStopLine,
// // //           'fault_time': DateTime.now().toIso8601String(),
// // //         });
// // //         _fetchActiveFaults();
// // //       } catch (e) {
// // //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطأ في الاتصال بالخادم')));
// // //       }
// // //     }
// // //   }

// // //   void _showErrorDialog(String msg) {
// // //     showDialog(
// // //       context: context,
// // //       builder: (context) => AlertDialog(
// // //         icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 40),
// // //         content: Text(msg, textAlign: TextAlign.center),
// // //         actions: [Center(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('فهمت')))],
// // //       ),
// // //     );
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Column(
// // //       children: [
// // //         Container(
// // //           margin: const EdgeInsets.all(16),
// // //           padding: const EdgeInsets.all(20),
// // //           decoration: BoxDecoration(
// // //             gradient: LinearGradient(
// // //               colors: isStopLine ? [Colors.red.shade700, Colors.red.shade400] : [Colors.orange.shade700, Colors.orange.shade400],
// // //             ),
// // //             borderRadius: BorderRadius.circular(24),
// // //             boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))],
// // //           ),
// // //           child: Column(
// // //             children: [
// // //               Row(
// // //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                 children: [
// // //                   const Text('نوع العطل الجديد:', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
// // //                   Container(
// // //                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
// // //                     decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
// // //                     child: Row(
// // //                       children: [
// // //                         const Text('موقف', style: TextStyle(color: Colors.white)),
// // //                         Switch(
// // //                           value: isStopLine,
// // //                           activeColor: Colors.white,
// // //                           activeTrackColor: Colors.white38,
// // //                           onChanged: (val) => setState(() => isStopLine = val),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   )
// // //                 ],
// // //               ),
// // //               const SizedBox(height: 15),
// // //               ElevatedButton.icon(
// // //                 icon: const Icon(Icons.add_alert, size: 28),
// // //                 label: const Text('تسجيل العطل وتفعيل العداد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // //                 style: ElevatedButton.styleFrom(
// // //                   backgroundColor: Colors.white,
// // //                   foregroundColor: isStopLine ? Colors.red.shade700 : Colors.orange.shade700,
// // //                   minimumSize: const Size(double.infinity, 55),
// // //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
// // //                 ),
// // //                 onPressed: _quickRegisterFault,
// // //               ),
// // //             ],
// // //           ),
// // //         ),
        
// // //         Expanded(
// // //           child: isLoading 
// // //             ? const Center(child: CircularProgressIndicator())
// // //             : activeFaults.isEmpty 
// // //               ? Center(
// // //                   child: Column(
// // //                     mainAxisAlignment: MainAxisAlignment.center,
// // //                     children: [
// // //                       Icon(Icons.check_circle_outline, size: 80, color: Colors.green.shade200),
// // //                       const SizedBox(height: 10),
// // //                       const Text('الخط يعمل بكفاءة - لا توجد أعطال', style: TextStyle(color: Colors.grey, fontSize: 16)),
// // //                     ],
// // //                   ),
// // //                 )
// // //               : ListView.builder(
// // //                   padding: const EdgeInsets.symmetric(horizontal: 16),
// // //                   itemCount: activeFaults.length,
// // //                   itemBuilder: (context, index) {
// // //                     return FaultCard(
// // //                       fault: activeFaults[index],
// // //                       onRepair: () => _fetchActiveFaults(),
// // //                       onUpdate: _fetchActiveFaults,
// // //                     );
// // //                   },
// // //                 ),
// // //         ),
// // //       ],
// // //     );
// // //   }
// // // }

// // // class FaultCard extends StatefulWidget {
// // //   final dynamic fault;
// // //   final VoidCallback onRepair;
// // //   final VoidCallback onUpdate;

// // //   FaultCard({required this.fault, required this.onRepair, required this.onUpdate});

// // //   @override
// // //   _FaultCardState createState() => _FaultCardState();
// // // }

// // // class _FaultCardState extends State<FaultCard> {
// // //   late Timer _timer;
// // //   String _durationString = "00:00:00";
// // //   bool isEditing = false;
  
// // //   String? tempDept;
// // //   final TextEditingController tempReasonController = TextEditingController();

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     tempDept = widget.fault['department'];
// // //     tempReasonController.text = widget.fault['reason'] ?? "";
// // //     isEditing = (tempDept == null || tempReasonController.text.isEmpty);
// // //     _startTimer();
// // //   }

// // //   void _startTimer() {
// // //     _updateTime();
// // //     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
// // //       if (mounted) _updateTime();
// // //     });
// // //   }

// // //   void _updateTime() {
// // //     final startTime = DateTime.parse(widget.fault['fault_time']);
// // //     final diff = DateTime.now().difference(startTime);
// // //     if (mounted) {
// // //       setState(() {
// // //         _durationString = _formatDuration(diff);
// // //       });
// // //     }
// // //   }

// // //   String _formatDuration(Duration d) {
// // //     String twoDigits(int n) => n.toString().padLeft(2, "0");
// // //     return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
// // //   }

// // //   Future<void> _repairFault() async {
// // //     bool? confirm = await showDialog<bool>(
// // //       context: context,
// // //       builder: (context) => AlertDialog(
// // //         title: const Text('تأكيد الإصلاح'),
// // //         content: const Text('هل تم حل المشكلة وإعادة الخط للعمل؟'),
// // //         actions: [
// // //           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('لا')),
// // //           ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('نعم، تم')),
// // //         ],
// // //       ),
// // //     );

// // //     if (confirm == true) {
// // //       await Supabase.instance.client.from('Fault_Logging').update({
// // //         'fix_time': DateTime.now().toIso8601String(),
// // //       }).eq('id', widget.fault['id']);
// // //       widget.onRepair();
// // //     }
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _timer.cancel();
// // //     tempReasonController.dispose();
// // //     super.dispose();
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     bool isStop = widget.fault['is_stop'] ?? false;
// // //     Color accentColor = isStop ? Colors.red : Colors.orange;

// // //     return Container(
// // //       margin: const EdgeInsets.only(bottom: 16),
// // //       decoration: BoxDecoration(
// // //         color: Colors.white,
// // //         borderRadius: BorderRadius.circular(20),
// // //         boxShadow: [BoxShadow(color: accentColor.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
// // //         border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
// // //       ),
// // //       child: Column(
// // //         children: [
// // //           // رأس البطاقة مع العداد
// // //           Container(
// // //             padding: const EdgeInsets.all(16),
// // //             decoration: BoxDecoration(
// // //               color: accentColor.withOpacity(0.05),
// // //               borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
// // //             ),
// // //             child: Row(
// // //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //               children: [
// // //                 Column(
// // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // //                   children: [
// // //                     Text(isStop ? 'عطل موقف 🛑' : 'عطل بسيط ⚠️', 
// // //                         style: TextStyle(fontWeight: FontWeight.bold, color: accentColor, fontSize: 16)),
// // //                     Text(intl.DateFormat('HH:mm a').format(DateTime.parse(widget.fault['fault_time'])), 
// // //                         style: const TextStyle(color: Colors.grey, fontSize: 12)),
// // //                   ],
// // //                 ),
// // //                 Container(
// // //                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // //                   decoration: BoxDecoration(
// // //                     color: accentColor,
// // //                     borderRadius: BorderRadius.circular(30),
// // //                   ),
// // //                   child: Text(_durationString, 
// // //                       style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
          
// // //           Padding(
// // //             padding: const EdgeInsets.all(16),
// // //             child: isEditing 
// // //             ? Column(
// // //                 children: [
// // //                   DropdownButtonFormField<String>(
// // //                     value: tempDept,
// // //                     decoration: const InputDecoration(labelText: 'الإدارة المسئولة', border: OutlineInputBorder()),
// // //                     items: ['الإنتاج', 'الصيانة', 'الجودة'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
// // //                     onChanged: (val) => setState(() => tempDept = val),
// // //                   ),
// // //                   const SizedBox(height: 12),
// // //                   TextField(
// // //                     controller: tempReasonController,
// // //                     decoration: const InputDecoration(labelText: 'سبب التوقف بالتفصيل', border: OutlineInputBorder()),
// // //                   ),
// // //                   const SizedBox(height: 12),
// // //                   ElevatedButton(
// // //                     onPressed: () async {
// // //                       if (tempDept != null && tempReasonController.text.isNotEmpty) {
// // //                         await Supabase.instance.client.from('Fault_Logging').update({
// // //                           'department': tempDept,
// // //                           'reason': tempReasonController.text,
// // //                         }).eq('id', widget.fault['id']);
// // //                         setState(() => isEditing = false);
// // //                         widget.onUpdate();
// // //                       }
// // //                     },
// // //                     style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
// // //                     child: const Text('حفظ البيانات'),
// // //                   ),
// // //                 ],
// // //               )
// // //             : Column(
// // //                 children: [
// // //                   Row(
// // //                     children: [
// // //                       const Icon(Icons.business_center, size: 18, color: Colors.indigo),
// // //                       const SizedBox(width: 8),
// // //                       Text('المسئول: ${widget.fault['department'] ?? "قيد التحديد"}', style: const TextStyle(fontWeight: FontWeight.bold)),
// // //                       const Spacer(),
// // //                       IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => setState(() => isEditing = true)),
// // //                     ],
// // //                   ),
// // //                   Row(
// // //                     children: [
// // //                       const Icon(Icons.info_outline, size: 18, color: Colors.indigo),
// // //                       const SizedBox(width: 8),
// // //                       Expanded(child: Text('السبب: ${widget.fault['reason'] ?? "لم يذكر بعد"}')),
// // //                     ],
// // //                   ),
// // //                   const Divider(height: 24),
// // //                   ElevatedButton.icon(
// // //                     onPressed: _repairFault,
// // //                     icon: const Icon(Icons.check_circle),
// // //                     label: const Text('إغلاق البلاغ وتم الإصلاح', style: TextStyle(fontWeight: FontWeight.bold)),
// // //                     style: ElevatedButton.styleFrom(
// // //                       backgroundColor: Colors.green.shade600,
// // //                       foregroundColor: Colors.white,
// // //                       minimumSize: const Size(double.infinity, 50),
// // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // //                     ),
// // //                   )
// // //                 ],
// // //               ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }

// // // class FaultReportPage extends StatefulWidget {
// // //   @override
// // //   _FaultReportPageState createState() => _FaultReportPageState();
// // // }

// // // class _FaultReportPageState extends State<FaultReportPage> {
// // //   final SupabaseClient supabase = Supabase.instance.client;
// // //   DateTime selectedDate = DateTime.now();
// // //   List<dynamic> reportData = [];
// // //   bool loading = false;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _fetchReport();
// // //   }

// // //   Future<void> _fetchReport() async {
// // //     setState(() => loading = true);
// // //     final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
// // //     final endOfDay = startOfDay.add(const Duration(days: 1));

// // //     try {
// // //       final response = await supabase
// // //           .from('Fault_Logging')
// // //           .select()
// // //           .gte('fault_time', startOfDay.toIso8601String())
// // //           .lt('fault_time', endOfDay.toIso8601String())
// // //           .order('fault_time', ascending: false);
      
// // //       setState(() {
// // //         reportData = response;
// // //         loading = false;
// // //       });
// // //     } catch (e) {
// // //       setState(() => loading = false);
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: const Text('سجل الأعطال التاريخي'),
// // //         actions: [
// // //           IconButton(
// // //             icon: const Icon(Icons.calendar_month),
// // //             onPressed: () async {
// // //               final picked = await showDatePicker(
// // //                 context: context,
// // //                 initialDate: selectedDate,
// // //                 firstDate: DateTime(2023),
// // //                 lastDate: DateTime.now(),
// // //               );
// // //               if (picked != null) {
// // //                 setState(() => selectedDate = picked);
// // //                 _fetchReport();
// // //               }
// // //             },
// // //           )
// // //         ],
// // //       ),
// // //       body: loading 
// // //       ? const Center(child: CircularProgressIndicator())
// // //       : Column(
// // //           children: [
// // //             Container(
// // //               padding: const EdgeInsets.all(16),
// // //               margin: const EdgeInsets.all(16),
// // //               decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(15)),
// // //               child: Row(
// // //                 mainAxisAlignment: MainAxisAlignment.center,
// // //                 children: [
// // //                   const Icon(Icons.history_toggle_off, color: Colors.indigo),
// // //                   const SizedBox(width: 8),
// // //                   Text('تاريخ التقرير: ${intl.DateFormat('yyyy-MM-dd').format(selectedDate)}', 
// // //                       style: const TextStyle(fontWeight: FontWeight.bold)),
// // //                 ],
// // //               ),
// // //             ),
// // //             Expanded(
// // //               child: ListView.builder(
// // //                 itemCount: reportData.length,
// // //                 padding: const EdgeInsets.symmetric(horizontal: 16),
// // //                 itemBuilder: (context, index) {
// // //                   final f = reportData[index];
// // //                   final isStop = f['is_stop'] == true;
// // //                   return Card(
// // //                     child: ListTile(
// // //                       leading: CircleAvatar(
// // //                         backgroundColor: isStop ? Colors.red.shade100 : Colors.orange.shade100,
// // //                         child: Icon(isStop ? Icons.stop : Icons.warning, color: isStop ? Colors.red : Colors.orange),
// // //                       ),
// // //                       title: Text('${f['line']} - ${f['department'] ?? "بدون إدارة"}'),
// // //                       subtitle: Text('المدة: ${_calcDuration(f)}'),
// // //                       trailing: Text(intl.DateFormat('HH:mm').format(DateTime.parse(f['fault_time']))),
// // //                     ),
// // //                   );
// // //                 },
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //     );
// // //   }

// // //   String _calcDuration(dynamic f) {
// // //     if (f['fix_time'] == null) return "لم يصلح";
// // //     final diff = DateTime.parse(f['fix_time']).difference(DateTime.parse(f['fault_time']));
// // //     return "${diff.inHours}س ${diff.inMinutes.remainder(60)}د";
// // //   }
// // // }

// // import 'package:flutter/material.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import 'dart:async';
// // import 'package:intl/intl.dart' as intl;

// // void main() async {
// //   // تأكد من تهيئة Supabase هنا قبل تشغيل التطبيق
// //   // await Supabase.initialize(url: 'YOUR_URL', anonKey: 'YOUR_KEY');
// //   runApp(FaultLoggingApp());
// // }

// // class FaultLoggingApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'نظام تسجيل الأعطال الذكي',
// //       theme: ThemeData(
// //         useMaterial3: true,
// //         primaryColor: const Color(0xFF1A237E),
// //         colorScheme: ColorScheme.fromSeed(
// //           seedColor: const Color(0xFF1A237E),
// //           primary: const Color(0xFF1A237E),
// //           secondary: const Color(0xFF00BFA5),
// //         ),
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
// //         bottomNavigationBar: NavigationBar(
// //           selectedIndex: _selectedIndex,
// //           onDestinationSelected: (index) => setState(() => _selectedIndex = index),
// //           destinations: const [
// //             NavigationDestination(icon: Icon(Icons.dashboard_customize), label: 'لوحة التحكم'),
// //             NavigationDestination(icon: Icon(Icons.analytics_outlined), label: 'التقارير'),
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
// //         title: const Text('إدارة أعطال الخطوط التشغيلية', style: TextStyle(fontWeight: FontWeight.bold)),
// //         centerTitle: true,
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         bottom: TabBar(
// //           controller: _tabController,
// //           labelColor: const Color(0xFF1A237E),
// //           unselectedLabelColor: Colors.grey,
// //           indicatorColor: const Color(0xFF1A237E),
// //           indicatorWeight: 3,
// //           tabs: const [
// //             Tab(child: Text('الخط الأول', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
// //             Tab(child: Text('الخط الثاني', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
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
// //       _showErrorDialog('تنبيه: يوجد عطل موقف نشط حالياً على هذا الخط. يرجى إنهاء العطل الحالي أولاً.');
// //       return;
// //     }

// //     bool? confirm = await showDialog<bool>(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
// //         title: const Text('تأكيد تسجيل عطل'),
// //         content: Text('هل تريد تسجيل عطل ${isStopLine ? "موقف" : "بسيط"} للخط الآن؟'),
// //         actions: [
// //           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
// //           ElevatedButton(
// //             onPressed: () => Navigator.pop(context, true),
// //             style: ElevatedButton.styleFrom(backgroundColor: isStopLine ? Colors.red : Colors.orange),
// //             child: const Text('تأكيد وتسجيل', style: TextStyle(color: Colors.white)),
// //           ),
// //         ],
// //       ),
// //     );

// //     if (confirm == true) {
// //       try {
// //         await supabase.from('Fault_Logging').insert({
// //           'line': widget.lineName,
// //           'is_stop': isStopLine,
// //           'fault_time': DateTime.now().toUtc().toIso8601String(), // استخدام UTC لتجنب تضارب المناطق الزمنية
// //         });
// //         _fetchActiveFaults();
// //       } catch (e) {
// //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطأ في الاتصال بالخادم')));
// //       }
// //     }
// //   }

// //   void _showErrorDialog(String msg) {
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 40),
// //         content: Text(msg, textAlign: TextAlign.center),
// //         actions: [Center(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('فهمت')))],
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       children: [
// //         Container(
// //           margin: const EdgeInsets.all(16),
// //           padding: const EdgeInsets.all(20),
// //           decoration: BoxDecoration(
// //             gradient: LinearGradient(
// //               colors: isStopLine ? [Colors.red.shade700, Colors.red.shade400] : [Colors.orange.shade700, Colors.orange.shade400],
// //             ),
// //             borderRadius: BorderRadius.circular(24),
// //             boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))],
// //           ),
// //           child: Column(
// //             children: [
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   const Text('نوع العطل الجديد:', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
// //                     decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
// //                     child: Row(
// //                       children: [
// //                         const Text('موقف', style: TextStyle(color: Colors.white)),
// //                         Switch(
// //                           value: isStopLine,
// //                           activeColor: Colors.white,
// //                           activeTrackColor: Colors.white38,
// //                           onChanged: (val) => setState(() => isStopLine = val),
// //                         ),
// //                       ],
// //                     ),
// //                   )
// //                 ],
// //               ),
// //               const SizedBox(height: 15),
// //               ElevatedButton.icon(
// //                 icon: const Icon(Icons.add_alert, size: 28),
// //                 label: const Text('تسجيل العطل وتفعيل العداد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.white,
// //                   foregroundColor: isStopLine ? Colors.red.shade700 : Colors.orange.shade700,
// //                   minimumSize: const Size(double.infinity, 55),
// //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
// //               ? Center(
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Icon(Icons.check_circle_outline, size: 80, color: Colors.green.shade200),
// //                       const SizedBox(height: 10),
// //                       const Text('الخط يعمل بكفاءة - لا توجد أعطال', style: TextStyle(color: Colors.grey, fontSize: 16)),
// //                     ],
// //                   ),
// //                 )
// //               : ListView.builder(
// //                   padding: const EdgeInsets.symmetric(horizontal: 16),
// //                   itemCount: activeFaults.length,
// //                   itemBuilder: (context, index) {
// //                     return FaultCard(
// //                       fault: activeFaults[index],
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
// //       // تحويل وقت البداية إلى UTC لضمان التوافق
// //       final startTime = DateTime.parse(widget.fault['fault_time']).toUtc();
// //       final now = DateTime.now().toUtc();
      
// //       // حساب الفرق
// //       final diff = now.difference(startTime);
      
// //       if (mounted) {
// //         setState(() {
// //           // إذا كان الفرق سالباً (بسبب فرق توقيت بسيط بين الجهاز والسيرفر)، نجبره على الصفر
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

// //   Future<void> _repairFault() async {
// //     bool? confirm = await showDialog<bool>(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: const Text('تأكيد الإصلاح'),
// //         content: const Text('هل تم حل المشكلة وإعادة الخط للعمل؟'),
// //         actions: [
// //           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('لا')),
// //           ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('نعم، تم')),
// //         ],
// //       ),
// //     );

// //     if (confirm == true) {
// //       await Supabase.instance.client.from('Fault_Logging').update({
// //         'fix_time': DateTime.now().toUtc().toIso8601String(),
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
// //     Color accentColor = isStop ? Colors.red : Colors.orange;

// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 16),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(20),
// //         boxShadow: [BoxShadow(color: accentColor.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
// //         border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
// //       ),
// //       child: Column(
// //         children: [
// //           Container(
// //             padding: const EdgeInsets.all(16),
// //             decoration: BoxDecoration(
// //               color: accentColor.withOpacity(0.05),
// //               borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
// //             ),
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(isStop ? 'عطل موقف 🛑' : 'عطل بسيط ⚠️', 
// //                         style: TextStyle(fontWeight: FontWeight.bold, color: accentColor, fontSize: 16)),
// //                     Text(intl.DateFormat('HH:mm a').format(DateTime.parse(widget.fault['fault_time']).toLocal()), 
// //                         style: const TextStyle(color: Colors.grey, fontSize: 12)),
// //                   ],
// //                 ),
// //                 Container(
// //                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //                   decoration: BoxDecoration(
// //                     color: accentColor,
// //                     borderRadius: BorderRadius.circular(30),
// //                   ),
// //                   child: Text(_durationString, 
// //                       style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
// //                 ),
// //               ],
// //             ),
// //           ),
          
// //           Padding(
// //             padding: const EdgeInsets.all(16),
// //             child: isEditing 
// //             ? Column(
// //                 children: [
// //                   DropdownButtonFormField<String>(
// //                     value: tempDept,
// //                     decoration: const InputDecoration(labelText: 'الإدارة المسئولة', border: OutlineInputBorder()),
// //                     items: ['الإنتاج', 'الصيانة', 'الجودة'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
// //                     onChanged: (val) => setState(() => tempDept = val),
// //                   ),
// //                   const SizedBox(height: 12),
// //                   TextField(
// //                     controller: tempReasonController,
// //                     decoration: const InputDecoration(labelText: 'سبب التوقف بالتفصيل', border: OutlineInputBorder()),
// //                   ),
// //                   const SizedBox(height: 12),
// //                   ElevatedButton(
// //                     onPressed: () async {
// //                       if (tempDept != null && tempReasonController.text.isNotEmpty) {
// //                         await Supabase.instance.client.from('Fault_Logging').update({
// //                           'department': tempDept,
// //                           'reason': tempReasonController.text,
// //                         }).eq('id', widget.fault['id']);
// //                         setState(() => isEditing = false);
// //                         widget.onUpdate();
// //                       }
// //                     },
// //                     style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
// //                     child: const Text('حفظ البيانات'),
// //                   ),
// //                 ],
// //               )
// //             : Column(
// //                 children: [
// //                   Row(
// //                     children: [
// //                       const Icon(Icons.business_center, size: 18, color: Colors.indigo),
// //                       const SizedBox(width: 8),
// //                       Text('المسئول: ${widget.fault['department'] ?? "قيد التحديد"}', style: const TextStyle(fontWeight: FontWeight.bold)),
// //                       const Spacer(),
// //                       IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => setState(() => isEditing = true)),
// //                     ],
// //                   ),
// //                   Row(
// //                     children: [
// //                       const Icon(Icons.info_outline, size: 18, color: Colors.indigo),
// //                       const SizedBox(width: 8),
// //                       Expanded(child: Text('السبب: ${widget.fault['reason'] ?? "لم يذكر بعد"}')),
// //                     ],
// //                   ),
// //                   const Divider(height: 24),
// //                   ElevatedButton.icon(
// //                     onPressed: _repairFault,
// //                     icon: const Icon(Icons.check_circle),
// //                     label: const Text('إغلاق البلاغ وتم الإصلاح', style: TextStyle(fontWeight: FontWeight.bold)),
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: Colors.green.shade600,
// //                       foregroundColor: Colors.white,
// //                       minimumSize: const Size(double.infinity, 50),
// //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //                     ),
// //                   )
// //                 ],
// //               ),
// //           ),
// //         ],
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

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('سجل الأعطال التاريخي'),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.calendar_month),
// //             onPressed: () async {
// //               final picked = await showDatePicker(
// //                 context: context,
// //                 initialDate: selectedDate,
// //                 firstDate: DateTime(2023),
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
// //       body: loading 
// //       ? const Center(child: CircularProgressIndicator())
// //       : Column(
// //           children: [
// //             Container(
// //               padding: const EdgeInsets.all(16),
// //               margin: const EdgeInsets.all(16),
// //               decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(15)),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   const Icon(Icons.history_toggle_off, color: Colors.indigo),
// //                   const SizedBox(width: 8),
// //                   Text('تاريخ التقرير: ${intl.DateFormat('yyyy-MM-dd').format(selectedDate)}', 
// //                       style: const TextStyle(fontWeight: FontWeight.bold)),
// //                 ],
// //               ),
// //             ),
// //             Expanded(
// //               child: ListView.builder(
// //                 itemCount: reportData.length,
// //                 padding: const EdgeInsets.symmetric(horizontal: 16),
// //                 itemBuilder: (context, index) {
// //                   final f = reportData[index];
// //                   final isStop = f['is_stop'] == true;
// //                   return Card(
// //                     child: ListTile(
// //                       leading: CircleAvatar(
// //                         backgroundColor: isStop ? Colors.red.shade100 : Colors.orange.shade100,
// //                         child: Icon(isStop ? Icons.stop : Icons.warning, color: isStop ? Colors.red : Colors.orange),
// //                       ),
// //                       title: Text('${f['line']} - ${f['department'] ?? "بدون إدارة"}'),
// //                       subtitle: Text('المدة: ${_calcDuration(f)}'),
// //                       trailing: Text(intl.DateFormat('HH:mm').format(DateTime.parse(f['fault_time']).toLocal())),
// //                     ),
// //                   );
// //                 },
// //               ),
// //             ),
// //           ],
// //         ),
// //     );
// //   }

// //   String _calcDuration(dynamic f) {
// //     if (f['fix_time'] == null) return "لم يصلح";
// //     final diff = DateTime.parse(f['fix_time']).difference(DateTime.parse(f['fault_time']));
// //     return "${diff.inHours}س ${diff.inMinutes.remainder(60)}د";
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'dart:async';
// import 'package:intl/intl.dart' as intl;

// void main() async {
//   // تأكد من تهيئة Supabase هنا قبل تشغيل التطبيق
//   // await Supabase.initialize(url: 'YOUR_URL', anonKey: 'YOUR_KEY');
//   runApp(FaultLoggingApp());
// }

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
//       _showErrorDialog('لا يمكن تسجيل عطل موقف جديد وهناك عطل موقف نشط حالياً على هذا الخط.');
//       return;
//     }

//     bool? confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('تسجيل عطل فوري'),
//         content: Text('سيتم تسجيل عطل الآن لـ ${widget.lineName} بتاريخ ووقت اللحظة الحالية. هل أنت متأكد؟'),
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
//           'fault_time': DateTime.now().toUtc().toIso8601String(), // حفظ بتوقيت UTC لمنع الأرقام السالبة
//         });
//         _fetchActiveFaults();
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطأ في الاتصال')));
//       }
//     }
//   }

//   void _showErrorDialog(String msg) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Row(children: [Icon(Icons.warning, color: Colors.orange), SizedBox(width: 8), Text('تنبيه')]),
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
//           child: Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('تسجيل عطل جديد لـ ${widget.lineName}', style: const TextStyle(fontWeight: FontWeight.bold)),
//                     Row(
//                       children: [
//                         const Text('يوقف الخط؟'),
//                         Switch(
//                           value: isStopLine,
//                           activeColor: Colors.red,
//                           onChanged: (val) => setState(() => isStopLine = val),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.play_arrow),
//                 label: const Text('سجل العطل الآن'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: isStopLine ? Colors.red : Colors.orange,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)
//                 ),
//                 onPressed: _quickRegisterFault,
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: isLoading 
//             ? const Center(child: CircularProgressIndicator())
//             : activeFaults.isEmpty 
//               ? const Center(child: Text('لا توجد أعطال نشطة'))
//               : ListView.builder(
//                   padding: const EdgeInsets.only(top: 8),
//                   itemCount: activeFaults.length,
//                   itemBuilder: (context, index) {
//                     final fault = activeFaults[index];
//                     return FaultCard(
//                       fault: fault,
//                       onRepair: () => _fetchActiveFaults(),
//                       onUpdate: _fetchActiveFaults,
//                     );
//                   },
//                 ),
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
//           // علاج مشكلة الأرقام السالبة: إذا كان الفرق أقل من صفر، يعرض 00:00:00
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

//   Future<void> _repairFault() async {
//     bool? confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('تأكيد الإصلاح'),
//         content: const Text('هل تم الانتهاء من إصلاح هذا العطل؟'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('لا')),
//           TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('نعم')),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       await Supabase.instance.client.from('Fault_Logging').update({
//         'fix_time': DateTime.now().toUtc().toIso8601String(),
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
    
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: isStop ? Colors.red.withOpacity(0.5) : Colors.orange.withOpacity(0.5), width: 1.5)
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(isStop ? 'عطل موقف للخط 🛑' : 'عطل غير موقف ⚠️', 
//                      style: TextStyle(fontWeight: FontWeight.bold, color: isStop ? Colors.red : Colors.orange)),
//                 Text(_durationString, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)),
//               ],
//             ),
//             const Divider(),
//             if (isEditing) ...[
//               DropdownButtonFormField<String>(
//                 value: tempDept,
//                 decoration: const InputDecoration(labelText: 'الإدارة المسئولة', isDense: true),
//                 items: ['الإنتاج', 'الصيانة', 'الجودة'].map((String value) {
//                   return DropdownMenuItem<String>(value: value, child: Text(value));
//                 }).toList(),
//                 onChanged: (val) => setState(() => tempDept = val),
//               ),
//               TextField(
//                 controller: tempReasonController,
//                 decoration: const InputDecoration(labelText: 'سبب العطل', isDense: true),
//               ),
//               const SizedBox(height: 8),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (tempDept != null && tempReasonController.text.isNotEmpty) {
//                     await Supabase.instance.client.from('Fault_Logging').update({
//                       'department': tempDept,
//                       'reason': tempReasonController.text,
//                     }).eq('id', widget.fault['id']);
//                     setState(() => isEditing = false);
//                     widget.onUpdate();
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 35)),
//                 child: const Text('حفظ بيانات العطل'),
//               ),
//             ] else ...[
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('الإدارة: ${widget.fault['department'] ?? "قيد التحديد"}', style: const TextStyle(fontWeight: FontWeight.bold)),
//                         Text('السبب: ${widget.fault['reason'] ?? "لم يذكر"}'),
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
//               child: ElevatedButton(
//                 onPressed: _repairFault,
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
//                 child: const Text('تم الإصلاح'),
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

//   Duration _getTotalStopTime() {
//     int totalMinutes = 0;
//     for (var f in reportData) {
//       if (f['is_stop'] == true && f['fix_time'] != null) {
//         final start = DateTime.parse(f['fault_time']);
//         final end = DateTime.parse(f['fix_time']);
//         totalMinutes += end.difference(start).inMinutes;
//       }
//     }
//     return Duration(minutes: totalMinutes);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final totalStop = _getTotalStopTime();
    
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
//           Container(
//             padding: const EdgeInsets.all(16),
//             width: double.infinity,
//             color: Colors.red.shade50,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.timer_off, color: Colors.red),
//                 const SizedBox(width: 8),
//                 Text(
//                   'إجمالي وقت توقف الخطوط: ${totalStop.inHours}س ${totalStop.inMinutes.remainder(60)}د',
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red.shade900),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: loading 
//               ? const Center(child: CircularProgressIndicator())
//               : reportData.isEmpty
//                 ? const Center(child: Text('لا توجد بيانات لهذا اليوم'))
//                 : SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: DataTable(
//                       headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
//                       columns: const [
//                         DataColumn(label: Text('الخط')),
//                         DataColumn(label: Text('نوع العطل')),
//                         DataColumn(label: Text('البداية')),
//                         DataColumn(label: Text('الإصلاح')),
//                         DataColumn(label: Text('المدة')),
//                         DataColumn(label: Text('الإدارة')),
//                         DataColumn(label: Text('السبب')),
//                       ],
//                       rows: reportData.map((f) => DataRow(cells: [
//                         DataCell(Text(f['line'] ?? '-')),
//                         DataCell(
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: f['is_stop'] == true ? Colors.red.shade100 : Colors.orange.shade100,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               f['is_stop'] == true ? 'موقف للخط' : 'لا يوقف',
//                               style: TextStyle(color: f['is_stop'] == true ? Colors.red.shade900 : Colors.orange.shade900, fontSize: 12),
//                             ),
//                           )
//                         ),
//                         DataCell(Text(intl.DateFormat('HH:mm').format(DateTime.parse(f['fault_time']).toLocal()))),
//                         DataCell(Text(f['fix_time'] != null ? intl.DateFormat('HH:mm').format(DateTime.parse(f['fix_time']).toLocal()) : 'نشط')),
//                         DataCell(Text(_calculateDuration(f))),
//                         DataCell(Text(f['department'] ?? '-')),
//                         DataCell(Text(f['reason'] ?? '-')),
//                       ])).toList(),
//                     ),
//                   ),
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
      debugPrint('Error: $e');
      setState(() => isLoading = false);
    }
  }

  bool _hasBlockingFault() {
    return activeFaults.any((f) => f['is_stop'] == true);
  }

  Future<void> _quickRegisterFault() async {
    if (isStopLine && _hasBlockingFault()) {
      _showSimpleDialog('تنبيه', 'لا يمكن تسجيل عطل موقف جديد وهناك عطل موقف نشط حالياً على هذا الخط.');
      return;
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل عطل فوري'),
        content: Text('سيتم تسجيل عطل الآن لـ ${widget.lineName}. هل أنت متأكد؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('تأكيد التسجيل')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await supabase.from('Fault_Logging').insert({
          'line': widget.lineName,
          'is_stop': isStopLine,
          'fault_time': DateTime.now().toUtc().toIso8601String(),
        });
        _fetchActiveFaults();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطأ في الاتصال')));
      }
    }
  }

  void _showSimpleDialog(String title, String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('تسجيل عطل جديد لـ ${widget.lineName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        const Text('يوقف الخط؟'),
                        Switch(
                          value: isStopLine,
                          activeColor: Colors.red,
                          onChanged: (val) => setState(() => isStopLine = val),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('سجل العطل الآن'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isStopLine ? Colors.red : Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)
                ),
                onPressed: _quickRegisterFault,
              ),
            ],
          ),
        ),
        Expanded(
          child: isLoading 
            ? const Center(child: CircularProgressIndicator())
            : activeFaults.isEmpty 
              ? const Center(child: Text('لا توجد أعطال نشطة'))
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: activeFaults.length,
                  itemBuilder: (context, index) {
                    final fault = activeFaults[index];
                    return FaultCard(
                      fault: fault,
                      onRepair: () => _fetchActiveFaults(),
                      onUpdate: _fetchActiveFaults,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

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
    // إذا كانت البيانات ناقصة، اجعل الكارت في وضع التعديل تلقائياً
    isEditing = (tempDept == null || tempReasonController.text.isEmpty);
    _startTimer();
  }

  void _startTimer() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) _updateTime();
    });
  }

  void _updateTime() {
    try {
      final startTime = DateTime.parse(widget.fault['fault_time']).toUtc();
      final now = DateTime.now().toUtc();
      final diff = now.difference(startTime);
      if (mounted) {
        setState(() {
          _durationString = _formatDuration(diff.isNegative ? Duration.zero : diff);
        });
      }
    } catch (e) {
      debugPrint("Timer Error: $e");
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  // الوظيفة الأساسية المعدلة بناءً على طلبك
  Future<void> _handleRepairRequest() async {
    // 1. التحقق من البيانات أولاً
    if (tempDept == null || tempReasonController.text.trim().isEmpty) {
      setState(() => isEditing = true); // فتح وضع التعديل لإجبار المستخدم
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ يرجى تسجيل الإدارة والسبب أولاً قبل إغلاق البلاغ'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 2. إذا كانت البيانات مكتملة، اطلب تأكيد الإصلاح
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الإصلاح'),
        content: const Text('هل تم التأكد من حل المشكلة وإعادة الخط للعمل؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('لا')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('نعم، تم')),
        ],
      ),
    );

    if (confirm == true) {
      await Supabase.instance.client.from('Fault_Logging').update({
        'fix_time': DateTime.now().toUtc().toIso8601String(),
        // نضمن تحديث البيانات في نفس لحظة الإغلاق للتأكيد
        'department': tempDept,
        'reason': tempReasonController.text.trim(),
      }).eq('id', widget.fault['id']);
      widget.onRepair();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    tempReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isStop = widget.fault['is_stop'] ?? false;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isStop ? Colors.red.withOpacity(0.5) : Colors.orange.withOpacity(0.5), width: 1.5)
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isStop ? 'عطل موقف للخط 🛑' : 'عطل غير موقف ⚠️', 
                     style: TextStyle(fontWeight: FontWeight.bold, color: isStop ? Colors.red : Colors.orange)),
                Text(_durationString, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)),
              ],
            ),
            const Divider(),
            if (isEditing) ...[
              DropdownButtonFormField<String>(
                value: tempDept,
                decoration: const InputDecoration(labelText: 'الإدارة المسئولة *', isDense: true),
                items: ['الإنتاج', 'الصيانة', 'الجودة'].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (val) => setState(() => tempDept = val),
              ),
              TextField(
                controller: tempReasonController,
                decoration: const InputDecoration(labelText: 'سبب العطل التفصيلي *', isDense: true),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  if (tempDept != null && tempReasonController.text.trim().isNotEmpty) {
                    await Supabase.instance.client.from('Fault_Logging').update({
                      'department': tempDept,
                      'reason': tempReasonController.text.trim(),
                    }).eq('id', widget.fault['id']);
                    setState(() => isEditing = false);
                    widget.onUpdate();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى ملء الحقول الإجبارية')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 35),
                  backgroundColor: Colors.indigo.shade50
                ),
                child: const Text('حفظ البيانات فقط'),
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الإدارة: ${widget.fault['department']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('السبب: ${widget.fault['reason']}'),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                    onPressed: () => setState(() => isEditing = true),
                  )
                ],
              ),
            ],
            const Divider(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: _handleRepairRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, 
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12)
                ),
                label: const Text('إصلاح وإغلاق البلاغ', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FaultReportPage extends StatefulWidget {
  @override
  _FaultReportPageState createState() => _FaultReportPageState();
}

class _FaultReportPageState extends State<FaultReportPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  DateTime selectedDate = DateTime.now();
  List<dynamic> reportData = [];
  bool loading = false;

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
        reportData = response;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Duration _getTotalStopTime() {
    int totalMinutes = 0;
    for (var f in reportData) {
      if (f['is_stop'] == true && f['fix_time'] != null) {
        final start = DateTime.parse(f['fault_time']);
        final end = DateTime.parse(f['fix_time']);
        totalMinutes += end.difference(start).inMinutes;
      }
    }
    return Duration(minutes: totalMinutes);
  }

  @override
  Widget build(BuildContext context) {
    final totalStop = _getTotalStopTime();
    
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
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.red.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer_off, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'إجمالي وقت توقف الخطوط: ${totalStop.inHours}س ${totalStop.inMinutes.remainder(60)}د',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red.shade900),
                ),
              ],
            ),
          ),
          Expanded(
            child: loading 
              ? const Center(child: CircularProgressIndicator())
              : reportData.isEmpty
                ? const Center(child: Text('لا توجد بيانات لهذا اليوم'))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                      columns: const [
                        DataColumn(label: Text('الخط')),
                        DataColumn(label: Text('نوع العطل')),
                        DataColumn(label: Text('البداية')),
                        DataColumn(label: Text('الإصلاح')),
                        DataColumn(label: Text('المدة')),
                        DataColumn(label: Text('الإدارة')),
                        DataColumn(label: Text('السبب')),
                      ],
                      rows: reportData.map((f) => DataRow(cells: [
                        DataCell(Text(f['line'] ?? '-')),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: f['is_stop'] == true ? Colors.red.shade100 : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              f['is_stop'] == true ? 'موقف للخط' : 'لا يوقف',
                              style: TextStyle(color: f['is_stop'] == true ? Colors.red.shade900 : Colors.orange.shade900, fontSize: 12),
                            ),
                          )
                        ),
                        DataCell(Text(intl.DateFormat('HH:mm').format(DateTime.parse(f['fault_time']).toLocal()))),
                        DataCell(Text(f['fix_time'] != null ? intl.DateFormat('HH:mm').format(DateTime.parse(f['fix_time']).toLocal()) : 'نشط')),
                        DataCell(Text(_calculateDuration(f))),
                        DataCell(Text(f['department'] ?? '-')),
                        DataCell(Text(f['reason'] ?? '-')),
                      ])).toList(),
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