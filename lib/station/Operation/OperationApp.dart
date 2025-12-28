

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:manageon/global.dart';
import 'package:manageon/station/Operation/OperationReportsScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart' as intl;

class OperationApp extends StatefulWidget {
  const OperationApp({super.key});

  @override
  State<OperationApp> createState() => _OperationAppState();
}

class _OperationAppState extends State<OperationApp> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const OperationScreen(),
    const ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.play_arrow), label: 'التشغيل'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'التقارير'),
          ],
        ),
      ),
    );
  }
}

class OperationScreen extends StatefulWidget {
  const OperationScreen({super.key});

  @override
  State<OperationScreen> createState() => _OperationScreenState();
}

class _OperationScreenState extends State<OperationScreen> {
  bool isLine1Active = false;
  bool isLine2Active = false;
  bool isTotalActive = false;

  void updateLineStatus(String lineName, bool isActive) {
    setState(() {
      if (lineName == 'الخط الأول') isLine1Active = isActive;
      if (lineName == 'الخط الثاني') isLine2Active = isActive;
      if (lineName == 'دمج الخطين') isTotalActive = isActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool disableIndividualLines = isTotalActive;
    bool disableTotalLine = isLine1Active || isLine2Active;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
  // backgroundColor: Colors.indigo, // لون الخلفية (اختياري)
  // foregroundColor: Colors.white, // يخلي عنوان الـ AppBar أبيض
  title: const Text('لوحة تشغيل الخطوط'),
  bottom: const TabBar(
    labelColor: Colors.white,              // لون النص المختار
    unselectedLabelColor: Colors.white70,  // لون النص غير المختار
    indicatorColor: Colors.white,          // لون خط التحديد تحت التاب
    tabs: [
      Tab(text: 'الخط الأول'),
      Tab(text: 'الخط الثاني'),
      Tab(text: 'دمج الخطين'),
    ],
  ),
),

        // appBar: AppBar(
        //   foregroundColor: colorbar_bottom,
        //   title: const Text('لوحة تشغيل الخطوط'),
        //   bottom: const TabBar(
        //     tabs: [
        //       Tab(text: 'الخط الأول',),
        //       Tab(text: 'الخط الثاني'),
        //       Tab(text: 'دمج الخطين'),
        //     ],
        //   ),
        // ),
        body: TabBarView(
          children: [
            LineForm(
              lineName: 'الخط الأول', 
              isDisabledBySystem: disableIndividualLines,
              onStatusChanged: (active) => updateLineStatus('الخط الأول', active),
            ),
            LineForm(
              lineName: 'الخط الثاني', 
              isDisabledBySystem: disableIndividualLines,
              onStatusChanged: (active) => updateLineStatus('الخط الثاني', active),
            ),
            LineForm(
              lineName: 'دمج الخطين', 
              isDisabledBySystem: disableTotalLine,
              onStatusChanged: (active) => updateLineStatus('دمج الخطين', active),
            ),
          ],
        ),
      ),
    );
  }
}

class LineForm extends StatefulWidget {
  final String lineName;
  final bool isDisabledBySystem;
  final Function(bool) onStatusChanged;

  const LineForm({
    super.key, 
    required this.lineName, 
    required this.isDisabledBySystem,
    required this.onStatusChanged,
  });

  @override
  State<LineForm> createState() => _LineFormState();
}

class _LineFormState extends State<LineForm> {
  final _serialController = TextEditingController();
  final _boxCountController = TextEditingController();
  final _boxInMinuteController = TextEditingController();
  
  bool _isLoading = false;
  bool _isActive = false; 
  bool _speedChanged = false; 
  
  int? _currentOperationId;
  int? _currentSubId;
  DateTime? _startTime;      
  DateTime? _totalStartTime; 
  DateTime? _expectedEndTime; // وقت الانتهاء المتوقع
  
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  int _totalStopMinutes = 0; 
  List<dynamic> _speedHistory = [];

  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _checkActiveOperation();
    
    _boxInMinuteController.addListener(() {
      if (_isActive && !_isLoading) {
        setState(() => _speedChanged = true);
      }
    });
  }

  // حساب الأعطال + تحديث وقت الانتهاء المتوقع
  Future<void> _calculateFaultsAndPredict() async {
    if (_totalStartTime == null || !_isActive) return;
    
    try {
      List<String> targetLines = [];
      if (widget.lineName == 'دمج الخطين') {
        targetLines = ['الخط الأول', 'الخط الثاني'];
      } else {
        targetLines = [widget.lineName];
      }

      final faults = await supabase
          .from('Fault_Logging')
          .select()
          .inFilter('line', targetLines)
          .eq('is_stop', true)
          .gte('fault_time', _totalStartTime!.toUtc().toIso8601String());

      int totalMinutes = 0;
      for (var f in faults) {
        if (f['fault_time'] != null && f['fix_time'] != null) {
          DateTime faultStart = DateTime.parse(f['fault_time']).toLocal();
          DateTime fixEnd = DateTime.parse(f['fix_time']).toLocal();
          int duration = fixEnd.difference(faultStart).inMinutes;
          if (duration > 0) totalMinutes += duration;
        }
      }

      if (mounted) {
        setState(() => _totalStopMinutes = totalMinutes);
        _calculateExpectedEndTime(); // تحديث التوقعات بعد جلب الأعطال
      }
    } catch (e) {
      debugPrint('Error calculating faults/prediction: $e');
    }
  }

  // المعادلة "الفنية" لحساب وقت الانتهاء المتوقع
  void _calculateExpectedEndTime() {
    if (!_isActive || _totalStartTime == null || _boxCountController.text.isEmpty || _boxInMinuteController.text.isEmpty) return;

    try {
      int totalBoxesRequired = int.parse(_boxCountController.text);
      int currentSpeed = int.parse(_boxInMinuteController.text);
      if (currentSpeed <= 0) return;

      double boxesProcessed = 0;

      // 1. حساب ما تم إنجازه في السرعات السابقة المنتهية
      for (var session in _speedHistory) {
        if (session['Operation_end'] != null) {
          DateTime start = DateTime.parse(session['Operation_start']).toLocal();
          DateTime end = DateTime.parse(session['Operation_end']).toLocal();
          int speed = session['Boxs_Count_in_minute'];
          
          // ملاحظة: مدة الجلسة بالدقائق (نطرح منها الأعطال التي حدثت في تلك الفترة لو أردت دقة مطلقة، 
          // ولكن حسب مثالك نحسب الوقت الكلي لكل جلسة مضروب في سرعتها)
          int durationMinutes = end.difference(start).inMinutes;
          boxesProcessed += (durationMinutes * speed);
        }
      }

      // 2. حساب ما تم إنجازه في السرعة الحالية النشطة (منذ بدايتها وحتى الآن)
      if (_startTime != null) {
        int currentSessionMinutes = DateTime.now().difference(_startTime!).inMinutes;
        boxesProcessed += (currentSessionMinutes * currentSpeed);
      }

      // 3. المتبقي
      double remainingBoxes = totalBoxesRequired - boxesProcessed;
      if (remainingBoxes < 0) remainingBoxes = 0;

      // 4. الوقت المتبقي (بالدقائق) المطلوب لإنهاء الصناديق المتبقية بالسرعة الحالية
      int remainingMinutesToFinish = (remainingBoxes / currentSpeed).ceil();

      // 5. وقت الانتهاء = الوقت الحالي + الدقائق المتبقية لإنهاء الصناديق
      // الأعطال مأخوذة في الاعتبار لأن boxesProcessed تعتمد على الوقت الفعلي المنقضي، 
      // فإذا حدث عطل، سيتأخر الوقت ويقل المنجز، مما يرحل وقت الانتهاء تلقائياً.
      // ولكن لإضافة "تأثير الأعطال المباشر" كما في مثالك:
      
      DateTime predicted = DateTime.now().add(Duration(minutes: remainingMinutesToFinish));
      
      setState(() {
        _expectedEndTime = predicted;
      });
    } catch (e) {
      debugPrint('Prediction Error: $e');
    }
  }

  Future<void> _checkActiveOperation() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final activeSub = await supabase
          .from('Operation_Sub')
          .select('*, Operation(*)')
          .eq('Line', widget.lineName)
          .isFilter('Operation_end', null)
          .order('Operation_start', ascending: false)
          .limit(1)
          .maybeSingle();

      if (activeSub != null && mounted) {
        final operationData = activeSub['Operation'];
        _currentOperationId = activeSub['Operation_id'];
        _currentSubId = activeSub['id'];

        final firstSub = await supabase
            .from('Operation_Sub')
            .select('Operation_start')
            .eq('Operation_id', _currentOperationId!)
            .order('Operation_start', ascending: true)
            .limit(1)
            .single();

        setState(() {
          _isActive = true;
          _startTime = DateTime.parse(activeSub['Operation_start']).toLocal();
          _totalStartTime = DateTime.parse(firstSub['Operation_start']).toLocal();

          _serialController.text = operationData['Serial'].toString();
          _boxCountController.text = operationData['Boxs_Count'].toString();
          _boxInMinuteController.text = activeSub['Boxs_Count_in_minute'].toString();
          
          _elapsed = DateTime.now().difference(_totalStartTime!);
        });
        
        widget.onStatusChanged(true);
        _startTimer();
        await _fetchSpeedHistory(); // جلب التاريخ أولاً للحساب
        _calculateFaultsAndPredict(); 
      }
    } catch (e) {
      debugPrint('Error fetching active op: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchSpeedHistory() async {
    if (_currentOperationId == null) return;
    try {
      final history = await supabase
          .from('Operation_Sub')
          .select('Boxs_Count_in_minute, Operation_start, Operation_end')
          .eq('Operation_id', _currentOperationId!)
          .order('Operation_start', ascending: false);
      
      if (mounted) setState(() => _speedHistory = history);
    } catch (e) {
      debugPrint('Error history: $e');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalStartTime != null && mounted) {
        setState(() {
          _elapsed = DateTime.now().difference(_totalStartTime!);
        });
        // تحديث الأعطال والتوقعات كل 30 ثانية
        if (_elapsed.inSeconds % 30 == 0) _calculateFaultsAndPredict();
      }
    });
  }

  Future<void> _handleStartOperation() async {
    if (_serialController.text.isEmpty || _boxCountController.text.isEmpty || _boxInMinuteController.text.isEmpty) {
      _showMsg('الرجاء إكمال كافة الحقول قبل البدء');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final opRes = await supabase.from('Operation').insert({
        'Serial': int.parse(_serialController.text),
        'Boxs_Count': int.parse(_boxCountController.text),
      }).select().single();

      _currentOperationId = opRes['id'];
      _totalStartTime = DateTime.now(); 
      _startTime = _totalStartTime;

      final subRes = await supabase.from('Operation_Sub').insert({
        'Operation_id': _currentOperationId,
        'Operation_start': _startTime!.toUtc().toIso8601String(),
        'Line': widget.lineName,
        'Boxs_Count_in_minute': int.parse(_boxInMinuteController.text),
      }).select().single();

      _currentSubId = subRes['id'];

      setState(() {
        _isActive = true;
        _speedChanged = false;
        _totalStopMinutes = 0;
        _elapsed = Duration.zero;
      });
      widget.onStatusChanged(true);
      _startTimer();
      _fetchSpeedHistory();
      _calculateExpectedEndTime(); // حساب أولي
      _showMsg('تم بدء تشغيل السيارة بنجاح');
    } catch (e) {
      _showMsg('خطأ: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEndOperation() async {
    setState(() => _isLoading = true);
    try {
      if (_currentSubId != null) {
        await supabase.from('Operation_Sub').update({
          'Operation_end': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', _currentSubId!);
      }

      _timer?.cancel();
      setState(() {
        _isActive = false;
        _currentOperationId = null;
        _currentSubId = null;
        _startTime = null;
        _totalStartTime = null;
        _expectedEndTime = null;
        _elapsed = Duration.zero;
        _totalStopMinutes = 0;
        _speedChanged = false;
        _speedHistory = [];
        _serialController.clear();
        _boxCountController.clear();
        _boxInMinuteController.clear();
      });
      widget.onStatusChanged(false);
      _showMsg('تم إنهاء تشغيل السيارة');
    } catch (e) {
      _showMsg('خطأ أثناء الإنهاء: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateSpeed() async {
    if (!_isActive || _currentOperationId == null) return;

    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      if (_currentSubId != null) {
        await supabase.from('Operation_Sub').update({
          'Operation_end': now.toUtc().toIso8601String(),
        }).eq('id', _currentSubId!);
      }

      final newSub = await supabase.from('Operation_Sub').insert({
        'Operation_id': _currentOperationId,
        'Operation_start': now.toUtc().toIso8601String(),
        'Line': widget.lineName,
        'Boxs_Count_in_minute': int.parse(_boxInMinuteController.text),
      }).select().single();

      _currentSubId = newSub['id'];
      _startTime = now; 
      setState(() => _speedChanged = false);
      await _fetchSpeedHistory();
      _calculateExpectedEndTime(); // إعادة الحساب بناءً على السرعة الجديدة
      _showMsg('تم تحديث السرعة');
    } catch (e) {
      _showMsg('خطأ في التحديث: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMsg(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? Colors.red : Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDisabledBySystem && !_isActive) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.block, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text('هذا الخط غير متاح حالياً', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (_isActive) _buildStatusCard(),
          const SizedBox(height: 20),
          _buildTextField(_serialController, 'علم الوزن (Serial)', Icons.numbers, enabled: !_isActive),
          const SizedBox(height: 15),
          _buildTextField(_boxCountController, 'إجمالي الصناديق', Icons.inventory, enabled: !_isActive),
          const SizedBox(height: 15),
          _buildTextField(_boxInMinuteController, 'سرعة الدنبر الحالية', Icons.speed),
          const SizedBox(height: 25),
          if (_speedChanged && _isActive)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildButton('تحديث السرعة فقط', Colors.orange, Icons.speed, _updateSpeed),
            ),
          if (!_isActive)
            _buildButton('بدء التشغيل الآن', Colors.blueAccent, Icons.play_arrow, _handleStartOperation)
          else
            _buildButton('إنهاء السيارة الحالية', Colors.redAccent, Icons.stop, _handleEndOperation),
          if (_speedHistory.isNotEmpty) ...[
            const SizedBox(height: 30),
            _buildSpeedHistoryList(),
          ]
        ],
      ),
    );
  }

  Widget _buildSpeedHistoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('سجل تغيير السرعات للعملية الحالية:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _speedHistory.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = _speedHistory[index];
            final start = DateTime.parse(item['Operation_start']).toLocal();
            final endStr = item['Operation_end'];
            DateTime? end = endStr != null ? DateTime.parse(endStr).toLocal() : null;
            final duration = end != null ? end.difference(start).inMinutes : DateTime.now().difference(start).inMinutes;
            return ListTile(
              dense: true,
              leading: Icon(end == null ? Icons.play_circle_fill : Icons.history, 
                          color: end == null ? Colors.green : Colors.blueGrey, size: 20),
              title: Text('السرعة: ${item['Boxs_Count_in_minute']} صندوق/د'),
              subtitle: Text('البدء: ${intl.DateFormat('hh:mm a').format(start)} | المدة: $duration دقيقة'),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    String hours = _elapsed.inHours.toString().padLeft(2, '0');
    String minutes = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');

    return Card(
      color: Colors.blue[50],
      elevation: 2,
      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.blue.shade200), borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.circle, color: Colors.green, size: 12),
                    SizedBox(width: 8),
                    Text('سيارة نشطة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
                Text('بداية: ${intl.DateFormat('hh:mm a').format(_totalStartTime!)}', style: const TextStyle(fontSize: 10, color: Colors.blueGrey)),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statusItem('وقت التشغيل', '$hours:$minutes:$seconds', Icons.timer),
                _statusItem('توقف', '$_totalStopMinutes د', Icons.report_problem, color: Colors.red),
                if (_expectedEndTime != null)
                  _statusItem('الانتهاء المتوقع', intl.DateFormat('hh:mm a').format(_expectedEndTime!), Icons.event_available, color: Colors.green[800]),
              ],
            ),
            if (_expectedEndTime != null) ...[
               const SizedBox(height: 8),
               Text(
                 'سيتم الانتهاء خلال ${(_expectedEndTime!.difference(DateTime.now()).inMinutes)} دقيقة تقريباً',
                 style: TextStyle(fontSize: 10, color: Colors.green[700], fontStyle: FontStyle.italic),
               ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _statusItem(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.blueGrey, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildButton(String label, Color color, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icon(icon),
        label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: enabled ? Colors.grey[50] : Colors.grey[200],
      ),
    );
  }
}