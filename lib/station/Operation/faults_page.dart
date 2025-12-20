// // // // import 'package:flutter/material.dart';
// // // // import 'package:supabase_flutter/supabase_flutter.dart';
// // // // import 'dart:async';
// // // // import 'package:intl/intl.dart'as intl;

// // // // class FaultLoggingApp extends StatelessWidget {
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return MaterialApp(
// // // //       title: 'نظام تسجيل الأعطال',
// // // //       theme: ThemeData(
// // // //         primarySwatch: Colors.indigo,
// // // //         fontFamily: 'Roboto', // تأكد من إضافة خط يدعم العربية في مشروعك
// // // //       ),
// // // //       home: FaultDashboard(),
// // // //       // locale: Locale('ar', 'AE'),
// // // //     );
// // // //   }
// // // // }

// // // // class FaultDashboard extends StatefulWidget {
// // // //   @override
// // // //   _FaultDashboardState createState() => _FaultDashboardState();
// // // // }

// // // // class _FaultDashboardState extends State<FaultDashboard> with SingleTickerProviderStateMixin {
// // // //   late TabController _tabController;
// // // //   final SupabaseClient supabase = Supabase.instance.client;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _tabController = TabController(length: 2, vsync: this);
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Directionality(
// // // //       textDirection: TextDirection.rtl,
// // // //       child: Scaffold(
// // // //         appBar: AppBar(
// // // //           title: Text('نظام إدارة الأعطال'),
// // // //           bottom: TabBar(
// // // //             controller: _tabController,
// // // //             tabs: [
// // // //               Tab(text: 'الخط الأول', icon: Icon(Icons.settings_input_component)),
// // // //               Tab(text: 'الخط الثاني', icon: Icon(Icons.settings_input_component)),
// // // //             ],
// // // //           ),
// // // //           actions: [
// // // //             IconButton(
// // // //               icon: Icon(Icons.bar_chart),
// // // //               onPressed: () => _showReportsSheet(context),
// // // //               tooltip: 'التقارير',
// // // //             )
// // // //           ],
// // // //         ),
// // // //         body: TabBarView(
// // // //           controller: _tabController,
// // // //           children: [
// // // //             FaultLineView(lineName: 'الخط الأول'),
// // // //             FaultLineView(lineName: 'الخط الثاني'),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   void _showReportsSheet(BuildContext context) {
// // // //     showModalBottomSheet(
// // // //       context: context,
// // // //       isScrollControlled: true,
// // // //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
// // // //       builder: (context) => FaultReportSheet(),
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
// // // //       print('Error fetching faults: $e');
// // // //     }
// // // //   }

// // // //   Future<void> _registerFault() async {
// // // //     String? selectedDept;
// // // //     TextEditingController reasonController = TextEditingController();

// // // //     await showDialog(
// // // //       context: context,
// // // //       builder: (context) => StatefulBuilder(
// // // //         builder: (context, setDialogState) => AlertDialog(
// // // //           title: Text('تسجيل عطل جديد - ${widget.lineName}'),
// // // //           content: Column(
// // // //             mainAxisSize: MainAxisSize.min,
// // // //             children: [
// // // //               DropdownButtonFormField<String>(
// // // //                 decoration: InputDecoration(labelText: 'الإدارة المسئولة'),
// // // //                 items: ['الإنتاج', 'الصيانة', 'الجودة'].map((String value) {
// // // //                   return DropdownMenuItem<String>(value: value, child: Text(value));
// // // //                 }).toList(),
// // // //                 onChanged: (val) => setDialogState(() => selectedDept = val),
// // // //               ),
// // // //               TextField(
// // // //                 controller: reasonController,
// // // //                 decoration: InputDecoration(labelText: 'سبب العطل'),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //           actions: [
// // // //             TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
// // // //             ElevatedButton(
// // // //               onPressed: () async {
// // // //                 if (selectedDept != null && reasonController.text.isNotEmpty) {
// // // //                   Navigator.pop(context);
// // // //                   _confirmAndSave(selectedDept!, reasonController.text);
// // // //                 }
// // // //               },
// // // //               child: Text('تسجيل'),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   void _confirmAndSave(String dept, String reason) async {
// // // //     bool? confirm = await showDialog<bool>(
// // // //       context: context,
// // // //       builder: (context) => AlertDialog(
// // // //         title: Text('تأكيد'),
// // // //         content: Text('هل أنت متأكد من تسجيل العطل؟'),
// // // //         actions: [
// // // //           TextButton(onPressed: () => Navigator.pop(context, false), child: Text('لا')),
// // // //           TextButton(onPressed: () => Navigator.pop(context, true), child: Text('نعم')),
// // // //         ],
// // // //       ),
// // // //     );

// // // //     if (confirm == true) {
// // // //       await supabase.from('Fault_Logging').insert({
// // // //         'line': widget.lineName,
// // // //         'department': dept,
// // // //         'reason': reason,
// // // //         'fault_time': DateTime.now().toIso8601String(),
// // // //       });
// // // //       _fetchActiveFaults();
// // // //     }
// // // //   }

// // // //   Future<void> _repairFault(int id) async {
// // // //     bool? confirm = await showDialog<bool>(
// // // //       context: context,
// // // //       builder: (context) => AlertDialog(
// // // //         title: Text('تأكيد الإصلاح'),
// // // //         content: Text('هل أنت متأكد من إصلاح العطل؟'),
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
// // // //         Padding(
// // // //           padding: const EdgeInsets.all(16.0),
// // // //           child: ElevatedButton.icon(
// // // //             icon: Icon(Icons.report_problem),
// // // //             label: Text('تسجيل عطل جديد', style: TextStyle(fontSize: 18)),
// // // //             style: ElevatedButton.styleFrom(
// // // //               minimumSize: Size(double.infinity, 50),
// // // //               backgroundColor: Colors.redAccent,
// // // //               foregroundColor: Colors.white,
// // // //             ),
// // // //             onPressed: _registerFault,
// // // //           ),
// // // //         ),
// // // //         Expanded(
// // // //           child: isLoading 
// // // //             ? Center(child: CircularProgressIndicator())
// // // //             : activeFaults.isEmpty 
// // // //               ? Center(child: Text('لا توجد أعطال حالية'))
// // // //               : ListView.builder(
// // // //                   itemCount: activeFaults.length,
// // // //                   itemBuilder: (context, index) {
// // // //                     final fault = activeFaults[index];
// // // //                     return FaultCard(
// // // //                       fault: fault,
// // // //                       onRepair: () => _repairFault(fault['id']),
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

// // // //   FaultCard({required this.fault, required this.onRepair});

// // // //   @override
// // // //   _FaultCardState createState() => _FaultCardState();
// // // // }

// // // // class _FaultCardState extends State<FaultCard> {
// // // //   late Timer _timer;
// // // //   String _durationString = "00:00:00";

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _startTimer();
// // // //   }

// // // //   void _startTimer() {
// // // //     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
// // // //       if (mounted) {
// // // //         final startTime = DateTime.parse(widget.fault['fault_time']);
// // // //         final diff = DateTime.now().difference(startTime);
// // // //         setState(() {
// // // //           _durationString = _formatDuration(diff);
// // // //         });
// // // //       }
// // // //     });
// // // //   }

// // // //   String _formatDuration(Duration duration) {
// // // //     String twoDigits(int n) => n.toString().padLeft(2, "0");
// // // //     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
// // // //     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
// // // //     return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _timer.cancel();
// // // //     super.dispose();
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Card(
// // // //       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // // //       elevation: 4,
// // // //       child: Padding(
// // // //         padding: const EdgeInsets.all(16.0),
// // // //         child: Column(
// // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // //           children: [
// // // //             Row(
// // // //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //               children: [
// // // //                 Chip(label: Text(widget.fault['department']), backgroundColor: Colors.blue.shade100),
// // // //                 Text(_durationString, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
// // // //               ],
// // // //             ),
// // // //             SizedBox(height: 10),
// // // //             Text('السبب: ${widget.fault['reason']}', style: TextStyle(fontSize: 16)),
// // // //             Text('وقت البداية: ${intl.DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(widget.fault['fault_time']))}'),
// // // //             Divider(),
// // // //             Align(
// // // //               alignment: Alignment.centerLeft,
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

// // // // class FaultReportSheet extends StatefulWidget {
// // // //   @override
// // // //   _FaultReportSheetState createState() => _FaultReportSheetState();
// // // // }

// // // // class _FaultReportSheetState extends State<FaultReportSheet> {
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
// // // //       print(e);
// // // //       setState(() => loading = false);
// // // //     }
// // // //   }

// // // //   String _calculateDuration(dynamic fault) {
// // // //     if (fault['fix_time'] == null) return "قيد الإصلاح";
// // // //     final start = DateTime.parse(fault['fault_time']);
// // // //     final end = DateTime.parse(fault['fix_time']);
// // // //     final diff = end.difference(start);
// // // //     return "${diff.inHours}س ${diff.inMinutes.remainder(60)}د";
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Container(
// // // //       height: MediaQuery.of(context).size.height * 0.85,
// // // //       padding: EdgeInsets.all(16),
// // // //       child: Column(
// // // //         children: [
// // // //           Row(
// // // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //             children: [
// // // //               Text('تقارير الأعطال', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
// // // //               IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
// // // //             ],
// // // //           ),
// // // //           Row(
// // // //             children: [
// // // //               Text('التاريخ: ${intl.DateFormat('yyyy-MM-dd').format(selectedDate)}'),
// // // //               IconButton(
// // // //                 icon: Icon(Icons.calendar_today),
// // // //                 onPressed: () async {
// // // //                   final picked = await showDatePicker(
// // // //                     context: context,
// // // //                     initialDate: selectedDate,
// // // //                     firstDate: DateTime(2020),
// // // //                     lastDate: DateTime.now(),
// // // //                   );
// // // //                   if (picked != null) {
// // // //                     setState(() => selectedDate = picked);
// // // //                     _fetchReport();
// // // //                   }
// // // //                 },
// // // //               ),
// // // //             ],
// // // //           ),
// // // //           Expanded(
// // // //             child: loading 
// // // //               ? Center(child: CircularProgressIndicator())
// // // //               : SingleChildScrollView(
// // // //                   scrollDirection: Axis.horizontal,
// // // //                   child: DataTable(
// // // //                     columns: [
// // // //                       DataColumn(label: Text('الخط')),
// // // //                       DataColumn(label: Text('البداية')),
// // // //                       DataColumn(label: Text('الإصلاح')),
// // // //                       DataColumn(label: Text('المدة')),
// // // //                       DataColumn(label: Text('الإدارة')),
// // // //                       DataColumn(label: Text('السبب')),
// // // //                     ],
// // // //                     rows: reportData.map((f) => DataRow(cells: [
// // // //                       DataCell(Text(f['line'] ?? '-')),
// // // //                       DataCell(Text(intl.DateFormat('HH:mm').format(DateTime.parse(f['fault_time'])))),
// // // //                       DataCell(Text(f['fix_time'] != null ? intl.DateFormat('HH:mm').format(DateTime.parse(f['fix_time'])) : '-')),
// // // //                       DataCell(Text(_calculateDuration(f))),
// // // //                       DataCell(Text(f['department'] ?? '-')),
// // // //                       DataCell(Text(f['reason'] ?? '-')),
// // // //                     ])).toList(),
// // // //                   ),
// // // //                 ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // import 'package:flutter/material.dart';
// // // import 'package:supabase_flutter/supabase_flutter.dart';
// // // import 'dart:async';
// // // import 'package:intl/intl.dart'as intl;

// // // class FaultLoggingApp extends StatelessWidget {
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return MaterialApp(
// // //       title: 'نظام تسجيل الأعطال',
// // //       theme: ThemeData(
// // //         primarySwatch: Colors.indigo,
// // //         fontFamily: 'Roboto',
// // //       ),
// // //       home: MainNavigationScreen(),
// // //       locale: Locale('ar', 'AE'),
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
// // //         bottomNavigationBar: BottomNavigationBar(
// // //           currentIndex: _selectedIndex,
// // //           onTap: (index) => setState(() => _selectedIndex = index),
// // //           items: [
// // //             BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'تسجيل الأعطال'),
// // //             BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'التقارير'),
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
// // //         title: Text('تسجيل الأعطال الحالية'),
// // //         bottom: TabBar(
// // //           controller: _tabController,
// // //           tabs: [
// // //             Tab(text: 'الخط الأول'),
// // //             Tab(text: 'الخط الثاني'),
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
// // //       print('Error: $e');
// // //     }
// // //   }

// // //   Future<void> _initiateFaultRegistration() async {
// // //     bool? confirm = await showDialog<bool>(
// // //       context: context,
// // //       builder: (context) => AlertDialog(
// // //         title: Text('تأكيد'),
// // //         content: Text('هل أنت متأكد من تسجيل عطل الآن؟'),
// // //         actions: [
// // //           TextButton(onPressed: () => Navigator.pop(context, false), child: Text('إلغاء')),
// // //           TextButton(onPressed: () => Navigator.pop(context, true), child: Text('نعم، سجل الآن')),
// // //         ],
// // //       ),
// // //     );

// // //     if (confirm == true) {
// // //       try {
// // //         // الخطوة 1: تسجيل العطل بالوقت الحالي فوراً
// // //         final response = await supabase.from('Fault_Logging').insert({
// // //           'line': widget.lineName,
// // //           'fault_time': DateTime.now().toIso8601String(),
// // //         }).select().single();

// // //         // الخطوة 2: طلب تحديث البيانات (الإدارة والسبب)
// // //         _showUpdateDetailsDialog(response['id']);
// // //       } catch (e) {
// // //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في التسجيل')));
// // //       }
// // //     }
// // //   }

// // //   Future<void> _showUpdateDetailsDialog(dynamic faultId) async {
// // //     String? selectedDept;
// // //     TextEditingController reasonController = TextEditingController();

// // //     await showDialog(
// // //       context: context,
// // //       barrierDismissible: false,
// // //       builder: (context) => StatefulBuilder(
// // //         builder: (context, setDialogState) => AlertDialog(
// // //           title: Text('تكملة بيانات العطل'),
// // //           content: Column(
// // //             mainAxisSize: MainAxisSize.min,
// // //             children: [
// // //               DropdownButtonFormField<String>(
// // //                 decoration: InputDecoration(labelText: 'الإدارة المسئولة'),
// // //                 items: ['الإنتاج', 'الصيانة', 'الجودة'].map((String value) {
// // //                   return DropdownMenuItem<String>(value: value, child: Text(value));
// // //                 }).toList(),
// // //                 onChanged: (val) => setDialogState(() => selectedDept = val),
// // //               ),
// // //               TextField(
// // //                 controller: reasonController,
// // //                 decoration: InputDecoration(labelText: 'سبب العطل'),
// // //               ),
// // //             ],
// // //           ),
// // //           actions: [
// // //             ElevatedButton(
// // //               onPressed: () async {
// // //                 if (selectedDept != null && reasonController.text.isNotEmpty) {
// // //                   await supabase.from('Fault_Logging').update({
// // //                     'department': selectedDept,
// // //                     'reason': reasonController.text,
// // //                   }).eq('id', faultId);
// // //                   Navigator.pop(context);
// // //                   _fetchActiveFaults();
// // //                 }
// // //               },
// // //               child: Text('تحديث البيانات'),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Future<void> _repairFault(int id) async {
// // //     bool? confirm = await showDialog<bool>(
// // //       context: context,
// // //       builder: (context) => AlertDialog(
// // //         title: Text('تأكيد الإصلاح'),
// // //         content: Text('هل أنت متأكد من إصلاح العطل؟'),
// // //         actions: [
// // //           TextButton(onPressed: () => Navigator.pop(context, false), child: Text('لا')),
// // //           TextButton(onPressed: () => Navigator.pop(context, true), child: Text('نعم')),
// // //         ],
// // //       ),
// // //     );

// // //     if (confirm == true) {
// // //       await supabase.from('Fault_Logging').update({
// // //         'fix_time': DateTime.now().toIso8601String(),
// // //       }).eq('id', id);
// // //       _fetchActiveFaults();
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Column(
// // //       children: [
// // //         Padding(
// // //           padding: const EdgeInsets.all(16.0),
// // //           child: ElevatedButton.icon(
// // //             icon: Icon(Icons.flash_on),
// // //             label: Text('تسجيل عطل مفاجئ', style: TextStyle(fontSize: 18)),
// // //             style: ElevatedButton.styleFrom(
// // //               minimumSize: Size(double.infinity, 60),
// // //               backgroundColor: Colors.red.shade700,
// // //               foregroundColor: Colors.white,
// // //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // //             ),
// // //             onPressed: _initiateFaultRegistration,
// // //           ),
// // //         ),
// // //         Expanded(
// // //           child: isLoading 
// // //             ? Center(child: CircularProgressIndicator())
// // //             : activeFaults.isEmpty 
// // //               ? Center(child: Text('لا توجد أعطال مسجلة حالياً'))
// // //               : ListView.builder(
// // //                   itemCount: activeFaults.length,
// // //                   itemBuilder: (context, index) {
// // //                     final fault = activeFaults[index];
// // //                     return FaultCard(
// // //                       fault: fault,
// // //                       onRepair: () => _repairFault(fault['id']),
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

// // //   FaultCard({required this.fault, required this.onRepair});

// // //   @override
// // //   _FaultCardState createState() => _FaultCardState();
// // // }

// // // class _FaultCardState extends State<FaultCard> {
// // //   late Timer _timer;
// // //   String _durationString = "00:00:00";

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _startTimer();
// // //   }

// // //   void _startTimer() {
// // //     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
// // //       if (mounted) {
// // //         final startTime = DateTime.parse(widget.fault['fault_time']);
// // //         final diff = DateTime.now().difference(startTime);
// // //         setState(() {
// // //           _durationString = _formatDuration(diff);
// // //         });
// // //       }
// // //     });
// // //   }

// // //   String _formatDuration(Duration duration) {
// // //     String twoDigits(int n) => n.toString().padLeft(2, "0");
// // //     return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _timer.cancel();
// // //     super.dispose();
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Card(
// // //       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
// // //       elevation: 3,
// // //       child: Padding(
// // //         padding: const EdgeInsets.all(16.0),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             Row(
// // //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //               children: [
// // //                 if (widget.fault['department'] != null)
// // //                   Chip(label: Text(widget.fault['department']), backgroundColor: Colors.amber.shade100)
// // //                 else
// // //                   Chip(label: Text('لم يحدد بعد'), backgroundColor: Colors.grey.shade200),
// // //                 Text(_durationString, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
// // //               ],
// // //             ),
// // //             SizedBox(height: 10),
// // //             Text('السبب: ${widget.fault['reason'] ?? 'جاري الإدخال...'}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
// // //             Text('وقت البداية: ${intl.DateFormat('HH:mm:ss').format(DateTime.parse(widget.fault['fault_time']))}', style: TextStyle(color: Colors.grey.shade600)),
// // //             Divider(height: 25),
// // //             SizedBox(
// // //               width: double.infinity,
// // //               child: ElevatedButton(
// // //                 onPressed: widget.onRepair,
// // //                 child: Text('إصلاح العطل الآن'),
// // //                 style: ElevatedButton.styleFrom(
// // //                   backgroundColor: Colors.green.shade600, 
// // //                   foregroundColor: Colors.white,
// // //                   padding: EdgeInsets.symmetric(vertical: 12)
// // //                 ),
// // //               ),
// // //             )
// // //           ],
// // //         ),
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
// // //     final endOfDay = startOfDay.add(Duration(days: 1));

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
// // //         title: Text('تقرير الأعطال اليومي'),
// // //         actions: [
// // //           IconButton(
// // //             icon: Icon(Icons.calendar_month),
// // //             onPressed: () async {
// // //               final picked = await showDatePicker(
// // //                 context: context,
// // //                 initialDate: selectedDate,
// // //                 firstDate: DateTime(2022),
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
// // //       body: Column(
// // //         children: [
// // //           Container(
// // //             padding: EdgeInsets.all(12),
// // //             color: Colors.indigo.shade50,
// // //             width: double.infinity,
// // //             child: Text(
// // //               'أعطال تاريخ: ${intl.DateFormat('yyyy-MM-dd').format(selectedDate)}',
// // //               textAlign: TextAlign.center,
// // //               style: TextStyle(fontWeight: FontWeight.bold),
// // //             ),
// // //           ),
// // //           Expanded(
// // //             child: loading 
// // //               ? Center(child: CircularProgressIndicator())
// // //               : reportData.isEmpty
// // //                 ? Center(child: Text('لا توجد سجلات لهذا التاريخ'))
// // //                 : SingleChildScrollView(
// // //                     scrollDirection: Axis.horizontal,
// // //                     child: DataTable(
// // //                       headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
// // //                       columns: [
// // //                         DataColumn(label: Text('الخط')),
// // //                         DataColumn(label: Text('البداية')),
// // //                         DataColumn(label: Text('الإصلاح')),
// // //                         DataColumn(label: Text('المدة')),
// // //                         DataColumn(label: Text('الإدارة')),
// // //                         DataColumn(label: Text('السبب')),
// // //                       ],
// // //                       rows: reportData.map((f) => DataRow(cells: [
// // //                         DataCell(Text(f['line'] ?? '-')),
// // //                         DataCell(Text(intl.DateFormat('HH:mm').format(DateTime.parse(f['fault_time'])))),
// // //                         DataCell(Text(f['fix_time'] != null ? intl.DateFormat('HH:mm').format(DateTime.parse(f['fix_time'])) : '-')),
// // //                         DataCell(Text(_calculateDuration(f))),
// // //                         DataCell(Text(f['department'] ?? '-')),
// // //                         DataCell(Text(f['reason'] ?? '-')),
// // //                       ])).toList(),
// // //                     ),
// // //                   ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   String _calculateDuration(dynamic fault) {
// // //     if (fault['fix_time'] == null) return "مستمر";
// // //     final start = DateTime.parse(fault['fault_time']);
// // //     final end = DateTime.parse(fault['fix_time']);
// // //     final diff = end.difference(start);
// // //     return "${diff.inHours}س ${diff.inMinutes.remainder(60)}د";
// // //   }
// // // }
// // import 'package:flutter/material.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import 'dart:async';
// // import 'package:intl/intl.dart'as intl;

// // class FaultLoggingApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'نظام تسجيل الأعطال',
// //       theme: ThemeData(
// //         primarySwatch: Colors.indigo,
// //         fontFamily: 'Roboto',
// //       ),
// //       home: MainNavigationScreen(),
// //       locale: Locale('ar', 'AE'),
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
// //           items: [
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
// //         title: Text('إدارة أعطال الخطوط'),
// //         bottom: TabBar(
// //           controller: _tabController,
// //           tabs: [
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

// //   // حقول الإدخال في الشاشة
// //   String? selectedDept;
// //   bool isStopLine = true;
// //   final TextEditingController reasonController = TextEditingController();

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
// //     }
// //   }

// //   bool _hasBlockingFault() {
// //     return activeFaults.any((f) => f['is_stop'] == true);
// //   }

// //   Future<void> _submitFault() async {
// //     // التحقق من وجود عطل موقف للخط حالياً
// //     if (isStopLine && _hasBlockingFault()) {
// //       _showErrorDialog('لا يمكن تسجيل عطل موقف جديد وهناك عطل موقف نشط حالياً على هذا الخط.');
// //       return;
// //     }

// //     if (selectedDept == null || reasonController.text.isEmpty) {
// //       _showErrorDialog('يرجى اختيار الإدارة وكتابة سبب العطل.');
// //       return;
// //     }

// //     bool? confirm = await showDialog<bool>(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: Text('تأكيد التسجيل'),
// //         content: Text('هل أنت متأكد من تسجيل العطل بالبيانات المدخلة؟'),
// //         actions: [
// //           TextButton(onPressed: () => Navigator.pop(context, false), child: Text('إلغاء')),
// //           TextButton(onPressed: () => Navigator.pop(context, true), child: Text('نعم، سجل')),
// //         ],
// //       ),
// //     );

// //     if (confirm == true) {
// //       try {
// //         await supabase.from('Fault_Logging').insert({
// //           'line': widget.lineName,
// //           'department': selectedDept,
// //           'reason': reasonController.text,
// //           'is_stop': isStopLine,
// //           'fault_time': DateTime.now().toIso8601String(),
// //         });

// //         // ريست للحقول بعد النجاح
// //         setState(() {
// //           reasonController.clear();
// //           selectedDept = null;
// //           isStopLine = true;
// //         });
        
// //         _fetchActiveFaults();
// //       } catch (e) {
// //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في الاتصال بقاعدة البيانات')));
// //       }
// //     }
// //   }

// //   void _showErrorDialog(String msg) {
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: Row(children: [Icon(Icons.warning, color: Colors.orange), SizedBox(width: 8), Text('تنبيه')]),
// //         content: Text(msg),
// //         actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('حسناً'))],
// //       ),
// //     );
// //   }

// //   Future<void> _repairFault(int id) async {
// //     bool? confirm = await showDialog<bool>(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: Text('تأكيد الإصلاح'),
// //         content: Text('هل تم الانتهاء من إصلاح هذا العطل؟'),
// //         actions: [
// //           TextButton(onPressed: () => Navigator.pop(context, false), child: Text('لا')),
// //           TextButton(onPressed: () => Navigator.pop(context, true), child: Text('نعم')),
// //         ],
// //       ),
// //     );

// //     if (confirm == true) {
// //       await supabase.from('Fault_Logging').update({
// //         'fix_time': DateTime.now().toIso8601String(),
// //       }).eq('id', id);
// //       _fetchActiveFaults();
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       children: [
// //         // قسم تسجيل العطل المباشر في الشاشة
// //         Container(
// //           padding: EdgeInsets.all(16),
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
// //           ),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text('تسجيل عطل جديد لـ ${widget.lineName}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
// //               SizedBox(height: 12),
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     child: DropdownButtonFormField<String>(
// //                       value: selectedDept,
// //                       decoration: InputDecoration(labelText: 'الإدارة المسئولة', border: OutlineInputBorder()),
// //                       items: ['الإنتاج', 'الصيانة', 'الجودة'].map((String value) {
// //                         return DropdownMenuItem<String>(value: value, child: Text(value));
// //                       }).toList(),
// //                       onChanged: (val) => setState(() => selectedDept = val),
// //                     ),
// //                   ),
// //                   SizedBox(width: 12),
// //                   Column(
// //                     children: [
// //                       Text('يوقف الخط؟', style: TextStyle(fontSize: 12)),
// //                       Switch(
// //                         value: isStopLine,
// //                         activeColor: Colors.red,
// //                         onChanged: (val) => setState(() => isStopLine = val),
// //                       ),
// //                     ],
// //                   )
// //                 ],
// //               ),
// //               SizedBox(height: 12),
// //               TextField(
// //                 controller: reasonController,
// //                 decoration: InputDecoration(
// //                   labelText: 'سبب العطل التفصيلي',
// //                   border: OutlineInputBorder(),
// //                   hintText: 'اكتب سبب العطل هنا...',
// //                 ),
// //               ),
// //               SizedBox(height: 12),
// //               ElevatedButton.icon(
// //                 icon: Icon(Icons.save),
// //                 label: Text('تسجيل العطل الآن'),
// //                 style: ElevatedButton.styleFrom(
// //                   minimumSize: Size(double.infinity, 50),
// //                   backgroundColor: isStopLine ? Colors.red.shade700 : Colors.orange.shade700,
// //                   foregroundColor: Colors.white,
// //                 ),
// //                 onPressed: _submitFault,
// //               ),
// //             ],
// //           ),
// //         ),
        
// //         // قسم الأعطال الحالية
// //         Expanded(
// //           child: isLoading 
// //             ? Center(child: CircularProgressIndicator())
// //             : activeFaults.isEmpty 
// //               ? Center(child: Text('لا توجد أعطال نشطة'))
// //               : ListView.builder(
// //                   padding: EdgeInsets.only(top: 8),
// //                   itemCount: activeFaults.length,
// //                   itemBuilder: (context, index) {
// //                     final fault = activeFaults[index];
// //                     return FaultCard(
// //                       fault: fault,
// //                       onRepair: () => _repairFault(fault['id']),
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

// //   FaultCard({required this.fault, required this.onRepair});

// //   @override
// //   _FaultCardState createState() => _FaultCardState();
// // }

// // class _FaultCardState extends State<FaultCard> {
// //   late Timer _timer;
// //   String _durationString = "00:00:00";

// //   @override
// //   void initState() {
// //     super.initState();
// //     _startTimer();
// //   }

// //   void _startTimer() {
// //     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
// //       if (mounted) {
// //         final startTime = DateTime.parse(widget.fault['fault_time']);
// //         final diff = DateTime.now().difference(startTime);
// //         setState(() {
// //           _durationString = _formatDuration(diff);
// //         });
// //       }
// //     });
// //   }

// //   String _formatDuration(Duration duration) {
// //     String twoDigits(int n) => n.toString().padLeft(2, "0");
// //     return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
// //   }

// //   @override
// //   void dispose() {
// //     _timer.cancel();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     bool isStop = widget.fault['is_stop'] ?? false;
    
// //     return Card(
// //       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Row(
// //                       children: [
// //                         Icon(isStop ? Icons.block : Icons.warning_amber, size: 16, color: isStop ? Colors.red : Colors.orange),
// //                         SizedBox(width: 4),
// //                         Text(isStop ? 'عطل موقف للخط' : 'عطل غير موقف', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isStop ? Colors.red : Colors.orange)),
// //                       ],
// //                     ),
// //                     SizedBox(height: 4),
// //                     Text(widget.fault['department'] ?? 'بدون إدارة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
// //                   ],
// //                 ),
// //                 Text(_durationString, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800)),
// //               ],
// //             ),
// //             Divider(),
// //             Row(
// //               children: [
// //                 Expanded(child: Text('السبب: ${widget.fault['reason']}', style: TextStyle(fontSize: 14))),
// //                 ElevatedButton(
// //                   onPressed: widget.onRepair,
// //                   child: Text('إصلاح'),
// //                   style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 20)),
// //                 ),
// //               ],
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
// //     final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
// //     final endOfDay = startOfDay.add(Duration(days: 1));

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
// //         title: Text('تقارير الأعطال اليومية'),
// //         actions: [
// //           IconButton(
// //             icon: Icon(Icons.event),
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
// //           Expanded(
// //             child: loading 
// //               ? Center(child: CircularProgressIndicator())
// //               : reportData.isEmpty
// //                 ? Center(child: Text('لا توجد بيانات لهذا اليوم'))
// //                 : SingleChildScrollView(
// //                     scrollDirection: Axis.horizontal,
// //                     child: DataTable(
// //                       headingTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
// //                       columns: [
// //                         DataColumn(label: Text('الخط')),
// //                         DataColumn(label: Text('النوع')),
// //                         DataColumn(label: Text('البداية')),
// //                         DataColumn(label: Text('الإصلاح')),
// //                         DataColumn(label: Text('المدة')),
// //                         DataColumn(label: Text('الإدارة')),
// //                         DataColumn(label: Text('السبب')),
// //                       ],
// //                       rows: reportData.map((f) => DataRow(cells: [
// //                         DataCell(Text(f['line'] ?? '-')),
// //                         DataCell(Text(f['is_stop'] == true ? 'موقف' : 'لا يوقف')),
// //                         DataCell(Text(intl.DateFormat('HH:mm').format(DateTime.parse(f['fault_time'])))),
// //                         DataCell(Text(f['fix_time'] != null ? intl.DateFormat('HH:mm').format(DateTime.parse(f['fix_time'])) : 'نشط')),
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
//         primarySwatch: Colors.indigo,
//         fontFamily: 'Roboto',
//       ),
//       home: MainNavigationScreen(),
//       locale: Locale('ar', 'AE'),
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
//           items: [
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
//         title: Text('إدارة أعطال الخطوط'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: [
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
//     }
//   }

//   bool _hasBlockingFault() {
//     return activeFaults.any((f) => f['is_stop'] == true);
//   }

//   Future<void> _quickRegisterFault() async {
//     // التحقق من وجود عطل موقف للخط حالياً
//     if (isStopLine && _hasBlockingFault()) {
//       _showErrorDialog('لا يمكن تسجيل عطل موقف جديد وهناك عطل موقف نشط حالياً على هذا الخط.');
//       return;
//     }

//     bool? confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('تسجيل عطل فوري'),
//         content: Text('سيتم تسجيل عطل الآن لـ ${widget.lineName} بتاريخ ووقت اللحظة الحالية. هل أنت متأكد؟'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context, false), child: Text('إلغاء')),
//           TextButton(onPressed: () => Navigator.pop(context, true), child: Text('تأكيد التسجيل')),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       try {
//         await supabase.from('Fault_Logging').insert({
//           'line': widget.lineName,
//           'is_stop': isStopLine,
//           'fault_time': DateTime.now().toIso8601String(),
//           // الإدارة والسبب يبقون null ليتم تعديلهم لاحقاً
//         });
        
//         _fetchActiveFaults();
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في الاتصال')));
//       }
//     }
//   }

//   void _showErrorDialog(String msg) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Row(children: [Icon(Icons.warning, color: Colors.orange), SizedBox(width: 8), Text('تنبيه')]),
//         content: Text(msg),
//         actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('حسناً'))],
//       ),
//     );
//   }

//   Future<void> _repairFault(int id) async {
//     bool? confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('تأكيد الإصلاح'),
//         content: Text('هل تم الانتهاء من إصلاح هذا العطل؟'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context, false), child: Text('لا')),
//           TextButton(onPressed: () => Navigator.pop(context, true), child: Text('نعم')),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       await supabase.from('Fault_Logging').update({
//         'fix_time': DateTime.now().toIso8601String(),
//       }).eq('id', id);
//       _fetchActiveFaults();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // قسم التسجيل السريع (فقط تحديد نوع العطل)
//         Container(
//           padding: EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
//           ),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('تسجيل عطل جديد لـ ${widget.lineName}', style: TextStyle(fontWeight: FontWeight.bold)),
//                     Row(
//                       children: [
//                         Text('يوقف الخط؟'),
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
//                 icon: Icon(Icons.timer_sharp),
//                 label: Text('سجل العطل الآن'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: isStopLine ? Colors.red : Colors.orange,
//                   foregroundColor: Colors.white,
//                   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15)
//                 ),
//                 onPressed: _quickRegisterFault,
//               ),
//             ],
//           ),
//         ),
        
//         Expanded(
//           child: isLoading 
//             ? Center(child: CircularProgressIndicator())
//             : activeFaults.isEmpty 
//               ? Center(child: Text('لا توجد أعطال نشطة'))
//               : ListView.builder(
//                   padding: EdgeInsets.only(top: 8),
//                   itemCount: activeFaults.length,
//                   itemBuilder: (context, index) {
//                     final fault = activeFaults[index];
//                     return FaultCard(
//                       fault: fault,
//                       onRepair: () => _repairFault(fault['id']),
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
  
//   // حقول لتعديل البيانات داخل الكارت
//   String? tempDept;
//   final TextEditingController tempReasonController = TextEditingController();
//   bool isEditing = false;

//   @override
//   void initState() {
//     super.initState();
//     tempDept = widget.fault['department'];
//     tempReasonController.text = widget.fault['reason'] ?? "";
//     isEditing = (tempDept == null || tempReasonController.text.isEmpty);
//     _startTimer();
//   }

//   void _startTimer() {
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       if (mounted) {
//         final startTime = DateTime.parse(widget.fault['fault_time']);
//         final diff = DateTime.now().difference(startTime);
//         setState(() {
//           _durationString = _formatDuration(diff);
//         });
//       }
//     });
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, "0");
//     return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
//   }

//   Future<void> _updateFaultInfo() async {
//     if (tempDept == null || tempReasonController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('يرجى إكمال جميع البيانات')));
//       return;
//     }
    
//     await Supabase.instance.client.from('Fault_Logging').update({
//       'department': tempDept,
//       'reason': tempReasonController.text,
//     }).eq('id', widget.fault['id']);
    
//     setState(() => isEditing = false);
//     widget.onUpdate();
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
//       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
//                 Text(_durationString, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//               ],
//             ),
//             Divider(),
            
//             if (isEditing) ...[
//               // واجهة إدخال البيانات داخل الكارت
//               DropdownButtonFormField<String>(
//                 value: tempDept,
//                 decoration: InputDecoration(labelText: 'الإدارة المسئولة', isDense: true),
//                 items: ['الإنتاج', 'الصيانة', 'الجودة'].map((String value) {
//                   return DropdownMenuItem<String>(value: value, child: Text(value));
//                 }).toList(),
//                 onChanged: (val) => setState(() => tempDept = val),
//               ),
//               TextField(
//                 controller: tempReasonController,
//                 decoration: InputDecoration(labelText: 'سبب العطل', isDense: true),
//               ),
//               SizedBox(height: 8),
//               ElevatedButton(
//                 onPressed: _updateFaultInfo,
//                 child: Text('حفظ بيانات العطل'),
//                 style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 35)),
//               ),
//             ] else ...[
//               // واجهة عرض البيانات مع إمكانية التعديل
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('الإدارة: ${widget.fault['department']}', style: TextStyle(fontWeight: FontWeight.bold)),
//                         Text('السبب: ${widget.fault['reason']}'),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.edit, size: 20, color: Colors.blue),
//                     onPressed: () => setState(() => isEditing = true),
//                   )
//                 ],
//               ),
//             ],
            
//             Divider(),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: widget.onRepair,
//                 child: Text('تم الإصلاح'),
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
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
//     final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
//     final endOfDay = startOfDay.add(Duration(days: 1));

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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('تقارير الأعطال اليومية'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.event),
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
//           Expanded(
//             child: loading 
//               ? Center(child: CircularProgressIndicator())
//               : reportData.isEmpty
//                 ? Center(child: Text('لا توجد بيانات لهذا اليوم'))
//                 : SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: DataTable(
//                       headingTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
//                       columns: [
//                         DataColumn(label: Text('الخط')),
//                         DataColumn(label: Text('النوع')),
//                         DataColumn(label: Text('البداية')),
//                         DataColumn(label: Text('الإصلاح')),
//                         DataColumn(label: Text('المدة')),
//                         DataColumn(label: Text('الإدارة')),
//                         DataColumn(label: Text('السبب')),
//                       ],
//                       rows: reportData.map((f) => DataRow(cells: [
//                         DataCell(Text(f['line'] ?? '-')),
//                         DataCell(Text(f['is_stop'] == true ? 'موقف' : 'لا يوقف')),
//                         DataCell(Text(intl.DateFormat('HH:mm').format(DateTime.parse(f['fault_time'])))),
//                         DataCell(Text(f['fix_time'] != null ? intl.DateFormat('HH:mm').format(DateTime.parse(f['fix_time'])) : 'نشط')),
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
        primarySwatch: Colors.indigo,
        fontFamily: 'Roboto',
      ),
      home: MainNavigationScreen(),
      locale: Locale('ar', 'AE'),
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
          items: [
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
        title: Text('إدارة أعطال الخطوط'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
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
    }
  }

  bool _hasBlockingFault() {
    return activeFaults.any((f) => f['is_stop'] == true);
  }

  Future<void> _quickRegisterFault() async {
    if (isStopLine && _hasBlockingFault()) {
      _showErrorDialog('لا يمكن تسجيل عطل موقف جديد وهناك عطل موقف نشط حالياً على هذا الخط.');
      return;
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تسجيل عطل فوري'),
        content: Text('سيتم تسجيل عطل الآن لـ ${widget.lineName} بتاريخ ووقت اللحظة الحالية. هل أنت متأكد؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('تأكيد التسجيل')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await supabase.from('Fault_Logging').insert({
          'line': widget.lineName,
          'is_stop': isStopLine,
          'fault_time': DateTime.now().toIso8601String(),
        });
        
        _fetchActiveFaults();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في الاتصال')));
      }
    }
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(children: [Icon(Icons.warning, color: Colors.orange), SizedBox(width: 8), Text('تنبيه')]),
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('حسناً'))],
      ),
    );
  }

  Future<void> _repairFault(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الإصلاح'),
        content: Text('هل تم الانتهاء من إصلاح هذا العطل؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('لا')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('نعم')),
        ],
      ),
    );

    if (confirm == true) {
      await supabase.from('Fault_Logging').update({
        'fix_time': DateTime.now().toIso8601String(),
      }).eq('id', id);
      _fetchActiveFaults();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('تسجيل عطل جديد لـ ${widget.lineName}', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Text('يوقف الخط؟'),
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
                icon: Icon(Icons.play_arrow),
                label: Text('سجل العطل الآن'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isStopLine ? Colors.red : Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15)
                ),
                onPressed: _quickRegisterFault,
              ),
            ],
          ),
        ),
        
        Expanded(
          child: isLoading 
            ? Center(child: CircularProgressIndicator())
            : activeFaults.isEmpty 
              ? Center(child: Text('لا توجد أعطال نشطة'))
              : ListView.builder(
                  padding: EdgeInsets.only(top: 8),
                  itemCount: activeFaults.length,
                  itemBuilder: (context, index) {
                    final fault = activeFaults[index];
                    return FaultCard(
                      fault: fault,
                      onRepair: () => _repairFault(fault['id']),
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
  
  String? tempDept;
  final TextEditingController tempReasonController = TextEditingController();
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    tempDept = widget.fault['department'];
    tempReasonController.text = widget.fault['reason'] ?? "";
    isEditing = (tempDept == null || tempReasonController.text.isEmpty);
    _startTimer();
  }

  void _startTimer() {
    // تحديث فوري عند التشغيل
    _updateTime();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateTime();
      }
    });
  }

  void _updateTime() {
    final startTime = DateTime.parse(widget.fault['fault_time']);
    final diff = DateTime.now().difference(startTime);
    setState(() {
      _durationString = _formatDuration(diff);
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    // العداد يبدأ من الصفر ويتصاعد
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  Future<void> _updateFaultInfo() async {
    if (tempDept == null || tempReasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('يرجى إكمال جميع البيانات')));
      return;
    }
    
    await Supabase.instance.client.from('Fault_Logging').update({
      'department': tempDept,
      'reason': tempReasonController.text,
    }).eq('id', widget.fault['id']);
    
    setState(() => isEditing = false);
    widget.onUpdate();
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
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                Text(_durationString, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)),
              ],
            ),
            Divider(),
            
            if (isEditing) ...[
              DropdownButtonFormField<String>(
                value: tempDept,
                decoration: InputDecoration(labelText: 'الإدارة المسئولة', isDense: true),
                items: ['الإنتاج', 'الصيانة', 'الجودة'].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (val) => setState(() => tempDept = val),
              ),
              TextField(
                controller: tempReasonController,
                decoration: InputDecoration(labelText: 'سبب العطل', isDense: true),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _updateFaultInfo,
                child: Text('حفظ بيانات العطل'),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 35)),
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الإدارة: ${widget.fault['department']}', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('السبب: ${widget.fault['reason']}'),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, size: 20, color: Colors.blue),
                    onPressed: () => setState(() => isEditing = true),
                  )
                ],
              ),
            ],
            
            Divider(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onRepair,
                child: Text('تم الإصلاح'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
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
    final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

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
        title: Text('تقارير الأعطال اليومية'),
        actions: [
          IconButton(
            icon: Icon(Icons.event),
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
          // ملخص إجمالي وقت التوقف
          Container(
            padding: EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.red.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_off, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'إجمالي وقت توقف الخطوط: ${totalStop.inHours}س ${totalStop.inMinutes.remainder(60)}د',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red.shade900),
                ),
              ],
            ),
          ),
          Expanded(
            child: loading 
              ? Center(child: CircularProgressIndicator())
              : reportData.isEmpty
                ? Center(child: Text('لا توجد بيانات لهذا اليوم'))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                      columns: [
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
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        DataCell(Text(intl.DateFormat('HH:mm').format(DateTime.parse(f['fault_time'])))),
                        DataCell(Text(f['fix_time'] != null ? intl.DateFormat('HH:mm').format(DateTime.parse(f['fix_time'])) : 'نشط')),
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