
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
        print('error :$e');
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
                items: ['الإنتاج', 'الصيانة','المخازن', 'الجودة'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
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