

// // // // // import 'dart:async';
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:manageon/station/Operation/OperationReportsScreen.dart';
// // // // // import 'package:supabase_flutter/supabase_flutter.dart';
// // // // // import 'package:intl/intl.dart' as intl;

// // // // // class OperationApp extends StatefulWidget {
// // // // //   const OperationApp({super.key});

// // // // //   @override
// // // // //   State<OperationApp> createState() => _OperationAppState();
// // // // // }

// // // // // class _OperationAppState extends State<OperationApp> {
// // // // //   int _currentIndex = 0;

// // // // //   final List<Widget> _pages = [
// // // // //     const OperationScreen(),
// // // // //     const ReportsScreen(),
// // // // //   ];

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Directionality(
// // // // //       textDirection: TextDirection.rtl,
// // // // //       child: Scaffold(
// // // // //         body: _pages[_currentIndex],
// // // // //         bottomNavigationBar: BottomNavigationBar(
// // // // //           currentIndex: _currentIndex,
// // // // //           onTap: (index) => setState(() => _currentIndex = index),
// // // // //           items: const [
// // // // //             BottomNavigationBarItem(icon: Icon(Icons.play_arrow), label: 'التشغيل'),
// // // // //             BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'التقارير'),
// // // // //           ],
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // // class OperationScreen extends StatefulWidget {
// // // // //   const OperationScreen({super.key});

// // // // //   @override
// // // // //   State<OperationScreen> createState() => _OperationScreenState();
// // // // // }

// // // // // class _OperationScreenState extends State<OperationScreen> {
// // // // //   bool isLine1Active = false;
// // // // //   bool isLine2Active = false;
// // // // //   bool isTotalActive = false;

// // // // //   void updateLineStatus(String lineName, bool isActive) {
// // // // //     setState(() {
// // // // //       if (lineName == 'الخط الأول') isLine1Active = isActive;
// // // // //       if (lineName == 'الخط الثاني') isLine2Active = isActive;
// // // // //       if (lineName == 'دمج الخطين') isTotalActive = isActive;
// // // // //     });
// // // // //   }

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     bool disableIndividualLines = isTotalActive;
// // // // //     bool disableTotalLine = isLine1Active || isLine2Active;

// // // // //     return DefaultTabController(
// // // // //       length: 3,
// // // // //       child: Scaffold(
// // // // //         appBar: AppBar(
// // // // //   title: const Text('لوحة تشغيل الخطوط'),
// // // // //   bottom: const TabBar(
// // // // //     labelColor: Colors.white,              // لون النص المختار
// // // // //     unselectedLabelColor: Colors.white70,  // لون النص غير المختار
// // // // //     indicatorColor: Colors.white,          // لون خط التحديد تحت التاب
// // // // //     tabs: [
// // // // //       Tab(text: 'الخط الأول'),
// // // // //       Tab(text: 'الخط الثاني'),
// // // // //       Tab(text: 'دمج الخطين'),
// // // // //     ],
// // // // //   ),
// // // // // ),

       
// // // // //         body: TabBarView(
// // // // //           children: [
// // // // //             LineForm(
// // // // //               lineName: 'الخط الأول', 
// // // // //               isDisabledBySystem: disableIndividualLines,
// // // // //               onStatusChanged: (active) => updateLineStatus('الخط الأول', active),
// // // // //             ),
// // // // //             LineForm(
// // // // //               lineName: 'الخط الثاني', 
// // // // //               isDisabledBySystem: disableIndividualLines,
// // // // //               onStatusChanged: (active) => updateLineStatus('الخط الثاني', active),
// // // // //             ),
// // // // //             LineForm(
// // // // //               lineName: 'دمج الخطين', 
// // // // //               isDisabledBySystem: disableTotalLine,
// // // // //               onStatusChanged: (active) => updateLineStatus('دمج الخطين', active),
// // // // //             ),
// // // // //           ],
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // // class LineForm extends StatefulWidget {
// // // // //   final String lineName;
// // // // //   final bool isDisabledBySystem;
// // // // //   final Function(bool) onStatusChanged;

// // // // //   const LineForm({
// // // // //     super.key, 
// // // // //     required this.lineName, 
// // // // //     required this.isDisabledBySystem,
// // // // //     required this.onStatusChanged,
// // // // //   });

// // // // //   @override
// // // // //   State<LineForm> createState() => _LineFormState();
// // // // // }

// // // // // class _LineFormState extends State<LineForm> {
// // // // //   final _serialController = TextEditingController();
// // // // //   final _boxCountController = TextEditingController();
// // // // //   final _boxInMinuteController = TextEditingController();
  
// // // // //   bool _isLoading = false;
// // // // //   bool _isActive = false; 
// // // // //   bool _speedChanged = false; 
  
// // // // //   int? _currentOperationId;
// // // // //   int? _currentSubId;
// // // // //   DateTime? _startTime;      
// // // // //   DateTime? _totalStartTime; 
// // // // //   DateTime? _expectedEndTime; // وقت الانتهاء المتوقع
  
// // // // //   Timer? _timer;
// // // // //   Duration _elapsed = Duration.zero;
// // // // //   int _totalStopMinutes = 0; 
// // // // //   List<dynamic> _speedHistory = [];

// // // // //   final SupabaseClient supabase = Supabase.instance.client;

// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();
// // // // //     _checkActiveOperation();
    
// // // // //     _boxInMinuteController.addListener(() {
// // // // //       if (_isActive && !_isLoading) {
// // // // //         setState(() => _speedChanged = true);
// // // // //       }
// // // // //     });
// // // // //   }

// // // // //   // حساب الأعطال + تحديث وقت الانتهاء المتوقع
// // // // //   Future<void> _calculateFaultsAndPredict() async {
// // // // //     if (_totalStartTime == null || !_isActive) return;
    
// // // // //     try {
// // // // //       List<String> targetLines = [];
// // // // //       if (widget.lineName == 'دمج الخطين') {
// // // // //         targetLines = ['الخط الأول', 'الخط الثاني'];
// // // // //       } else {
// // // // //         targetLines = [widget.lineName];
// // // // //       }

// // // // //       final faults = await supabase
// // // // //           .from('Fault_Logging')
// // // // //           .select()
// // // // //           .inFilter('line', targetLines)
// // // // //           .eq('is_stop', true)
// // // // //           .gte('fault_time', _totalStartTime!.toUtc().toIso8601String());

// // // // //       int totalMinutes = 0;
// // // // //       for (var f in faults) {
// // // // //         if (f['fault_time'] != null && f['fix_time'] != null) {
// // // // //           DateTime faultStart = DateTime.parse(f['fault_time']).toLocal();
// // // // //           DateTime fixEnd = DateTime.parse(f['fix_time']).toLocal();
// // // // //           int duration = fixEnd.difference(faultStart).inMinutes;
// // // // //           if (duration > 0) totalMinutes += duration;
// // // // //         }
// // // // //       }

// // // // //       if (mounted) {
// // // // //         setState(() => _totalStopMinutes = totalMinutes);
// // // // //         _calculateExpectedEndTime(); // تحديث التوقعات بعد جلب الأعطال
// // // // //       }
// // // // //     } catch (e) {
// // // // //       debugPrint('Error calculating faults/prediction: $e');
// // // // //     }
// // // // //   }

// // // // //   // المعادلة "الفنية" لحساب وقت الانتهاء المتوقع
// // // // //   void _calculateExpectedEndTime() {
// // // // //     if (!_isActive || _totalStartTime == null || _boxCountController.text.isEmpty || _boxInMinuteController.text.isEmpty) return;

// // // // //     try {
// // // // //       int totalBoxesRequired = int.parse(_boxCountController.text);
// // // // //       int currentSpeed = int.parse(_boxInMinuteController.text);
// // // // //       if (currentSpeed <= 0) return;

// // // // //       double boxesProcessed = 0;

// // // // //       // 1. حساب ما تم إنجازه في السرعات السابقة المنتهية
// // // // //       for (var session in _speedHistory) {
// // // // //         if (session['Operation_end'] != null) {
// // // // //           DateTime start = DateTime.parse(session['Operation_start']).toLocal();
// // // // //           DateTime end = DateTime.parse(session['Operation_end']).toLocal();
// // // // //           int speed = session['Boxs_Count_in_minute'];
          
// // // // //           // ملاحظة: مدة الجلسة بالدقائق (نطرح منها الأعطال التي حدثت في تلك الفترة لو أردت دقة مطلقة، 
// // // // //           // ولكن حسب مثالك نحسب الوقت الكلي لكل جلسة مضروب في سرعتها)
// // // // //           int durationMinutes = end.difference(start).inMinutes;
// // // // //           boxesProcessed += (durationMinutes * speed);
// // // // //         }
// // // // //       }

// // // // //       // 2. حساب ما تم إنجازه في السرعة الحالية النشطة (منذ بدايتها وحتى الآن)
// // // // //       if (_startTime != null) {
// // // // //         int currentSessionMinutes = DateTime.now().difference(_startTime!).inMinutes;
// // // // //         boxesProcessed += (currentSessionMinutes * currentSpeed);
// // // // //       }

// // // // //       // 3. المتبقي
// // // // //       double remainingBoxes = totalBoxesRequired - boxesProcessed;
// // // // //       if (remainingBoxes < 0) remainingBoxes = 0;

// // // // //       // 4. الوقت المتبقي (بالدقائق) المطلوب لإنهاء الصناديق المتبقية بالسرعة الحالية
// // // // //       int remainingMinutesToFinish = (remainingBoxes / currentSpeed).ceil();

// // // // //       // 5. وقت الانتهاء = الوقت الحالي + الدقائق المتبقية لإنهاء الصناديق
// // // // //       // الأعطال مأخوذة في الاعتبار لأن boxesProcessed تعتمد على الوقت الفعلي المنقضي، 
// // // // //       // فإذا حدث عطل، سيتأخر الوقت ويقل المنجز، مما يرحل وقت الانتهاء تلقائياً.
// // // // //       // ولكن لإضافة "تأثير الأعطال المباشر" كما في مثالك:
      
// // // // //       DateTime predicted = DateTime.now().add(Duration(minutes: remainingMinutesToFinish));
      
// // // // //       setState(() {
// // // // //         _expectedEndTime = predicted;
// // // // //       });
// // // // //     } catch (e) {
// // // // //       debugPrint('Prediction Error: $e');
// // // // //     }
// // // // //   }

// // // // //   Future<void> _checkActiveOperation() async {
// // // // //     if (!mounted) return;
// // // // //     setState(() => _isLoading = true);
// // // // //     try {
// // // // //       final activeSub = await supabase
// // // // //           .from('Operation_Sub')
// // // // //           .select('*, Operation(*)')
// // // // //           .eq('Line', widget.lineName)
// // // // //           .isFilter('Operation_end', null)
// // // // //           .order('Operation_start', ascending: false)
// // // // //           .limit(1)
// // // // //           .maybeSingle();

// // // // //       if (activeSub != null && mounted) {
// // // // //         final operationData = activeSub['Operation'];
// // // // //         _currentOperationId = activeSub['Operation_id'];
// // // // //         _currentSubId = activeSub['id'];

// // // // //         final firstSub = await supabase
// // // // //             .from('Operation_Sub')
// // // // //             .select('Operation_start')
// // // // //             .eq('Operation_id', _currentOperationId!)
// // // // //             .order('Operation_start', ascending: true)
// // // // //             .limit(1)
// // // // //             .single();

// // // // //         setState(() {
// // // // //           _isActive = true;
// // // // //           _startTime = DateTime.parse(activeSub['Operation_start']).toLocal();
// // // // //           _totalStartTime = DateTime.parse(firstSub['Operation_start']).toLocal();

// // // // //           _serialController.text = operationData['Serial'].toString();
// // // // //           _boxCountController.text = operationData['Boxs_Count'].toString();
// // // // //           _boxInMinuteController.text = activeSub['Boxs_Count_in_minute'].toString();
          
// // // // //           _elapsed = DateTime.now().difference(_totalStartTime!);
// // // // //         });
        
// // // // //         widget.onStatusChanged(true);
// // // // //         _startTimer();
// // // // //         await _fetchSpeedHistory(); // جلب التاريخ أولاً للحساب
// // // // //         _calculateFaultsAndPredict(); 
// // // // //       }
// // // // //     } catch (e) {
// // // // //       debugPrint('Error fetching active op: $e');
// // // // //     } finally {
// // // // //       if (mounted) setState(() => _isLoading = false);
// // // // //     }
// // // // //   }

// // // // //   Future<void> _fetchSpeedHistory() async {
// // // // //     if (_currentOperationId == null) return;
// // // // //     try {
// // // // //       final history = await supabase
// // // // //           .from('Operation_Sub')
// // // // //           .select('Boxs_Count_in_minute, Operation_start, Operation_end')
// // // // //           .eq('Operation_id', _currentOperationId!)
// // // // //           .order('Operation_start', ascending: false);
      
// // // // //       if (mounted) setState(() => _speedHistory = history);
// // // // //     } catch (e) {
// // // // //       debugPrint('Error history: $e');
// // // // //     }
// // // // //   }

// // // // //   void _startTimer() {
// // // // //     _timer?.cancel();
// // // // //     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
// // // // //       if (_totalStartTime != null && mounted) {
// // // // //         setState(() {
// // // // //           _elapsed = DateTime.now().difference(_totalStartTime!);
// // // // //         });
// // // // //         // تحديث الأعطال والتوقعات كل 30 ثانية
// // // // //         if (_elapsed.inSeconds % 30 == 0) _calculateFaultsAndPredict();
// // // // //       }
// // // // //     });
// // // // //   }

// // // // //   Future<void> _handleStartOperation() async {
// // // // //     if (_serialController.text.isEmpty || _boxCountController.text.isEmpty || _boxInMinuteController.text.isEmpty) {
// // // // //       _showMsg('الرجاء إكمال كافة الحقول قبل البدء');
// // // // //       return;
// // // // //     }

// // // // //     setState(() => _isLoading = true);
// // // // //     try {
// // // // //       final opRes = await supabase.from('Operation').insert({
// // // // //         'Serial': int.parse(_serialController.text),
// // // // //         'Boxs_Count': int.parse(_boxCountController.text),
// // // // //       }).select().single();

// // // // //       _currentOperationId = opRes['id'];
// // // // //       _totalStartTime = DateTime.now(); 
// // // // //       _startTime = _totalStartTime;

// // // // //       final subRes = await supabase.from('Operation_Sub').insert({
// // // // //         'Operation_id': _currentOperationId,
// // // // //         'Operation_start': _startTime!.toUtc().toIso8601String(),
// // // // //         'Line': widget.lineName,
// // // // //         'Boxs_Count_in_minute': int.parse(_boxInMinuteController.text),
// // // // //       }).select().single();

// // // // //       _currentSubId = subRes['id'];

// // // // //       setState(() {
// // // // //         _isActive = true;
// // // // //         _speedChanged = false;
// // // // //         _totalStopMinutes = 0;
// // // // //         _elapsed = Duration.zero;
// // // // //       });
// // // // //       widget.onStatusChanged(true);
// // // // //       _startTimer();
// // // // //       _fetchSpeedHistory();
// // // // //       _calculateExpectedEndTime(); // حساب أولي
// // // // //       _showMsg('تم بدء تشغيل السيارة بنجاح');
// // // // //     } catch (e) {
// // // // //       _showMsg('خطأ: $e', isError: true);
// // // // //     } finally {
// // // // //       if (mounted) setState(() => _isLoading = false);
// // // // //     }
// // // // //   }

// // // // //   Future<void> _handleEndOperation() async {
// // // // //     setState(() => _isLoading = true);
// // // // //     try {
// // // // //       if (_currentSubId != null) {
// // // // //         await supabase.from('Operation_Sub').update({
// // // // //           'Operation_end': DateTime.now().toUtc().toIso8601String(),
// // // // //         }).eq('id', _currentSubId!);
// // // // //       }

// // // // //       _timer?.cancel();
// // // // //       setState(() {
// // // // //         _isActive = false;
// // // // //         _currentOperationId = null;
// // // // //         _currentSubId = null;
// // // // //         _startTime = null;
// // // // //         _totalStartTime = null;
// // // // //         _expectedEndTime = null;
// // // // //         _elapsed = Duration.zero;
// // // // //         _totalStopMinutes = 0;
// // // // //         _speedChanged = false;
// // // // //         _speedHistory = [];
// // // // //         _serialController.clear();
// // // // //         _boxCountController.clear();
// // // // //         _boxInMinuteController.clear();
// // // // //       });
// // // // //       widget.onStatusChanged(false);
// // // // //       _showMsg('تم إنهاء تشغيل السيارة');
// // // // //     } catch (e) {
// // // // //       _showMsg('خطأ أثناء الإنهاء: $e', isError: true);
// // // // //     } finally {
// // // // //       if (mounted) setState(() => _isLoading = false);
// // // // //     }
// // // // //   }

// // // // //   Future<void> _updateSpeed() async {
// // // // //     if (!_isActive || _currentOperationId == null) return;

// // // // //     setState(() => _isLoading = true);
// // // // //     try {
// // // // //       final now = DateTime.now();
// // // // //       if (_currentSubId != null) {
// // // // //         await supabase.from('Operation_Sub').update({
// // // // //           'Operation_end': now.toUtc().toIso8601String(),
// // // // //         }).eq('id', _currentSubId!);
// // // // //       }

// // // // //       final newSub = await supabase.from('Operation_Sub').insert({
// // // // //         'Operation_id': _currentOperationId,
// // // // //         'Operation_start': now.toUtc().toIso8601String(),
// // // // //         'Line': widget.lineName,
// // // // //         'Boxs_Count_in_minute': int.parse(_boxInMinuteController.text),
// // // // //       }).select().single();

// // // // //       _currentSubId = newSub['id'];
// // // // //       _startTime = now; 
// // // // //       setState(() => _speedChanged = false);
// // // // //       await _fetchSpeedHistory();
// // // // //       _calculateExpectedEndTime(); // إعادة الحساب بناءً على السرعة الجديدة
// // // // //       _showMsg('تم تحديث السرعة');
// // // // //     } catch (e) {
// // // // //       _showMsg('خطأ في التحديث: $e', isError: true);
// // // // //     } finally {
// // // // //       if (mounted) setState(() => _isLoading = false);
// // // // //     }
// // // // //   }

// // // // //   void _showMsg(String msg, {bool isError = false}) {
// // // // //     if (!mounted) return;
// // // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // // //       SnackBar(content: Text(msg), backgroundColor: isError ? Colors.red : Colors.green),
// // // // //     );
// // // // //   }

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     if (widget.isDisabledBySystem && !_isActive) {
// // // // //       return Center(
// // // // //         child: Column(
// // // // //           mainAxisAlignment: MainAxisAlignment.center,
// // // // //           children: [
// // // // //             const Icon(Icons.block, size: 60, color: Colors.grey),
// // // // //             const SizedBox(height: 16),
// // // // //             Text('هذا الخط غير متاح حالياً', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
// // // // //           ],
// // // // //         ),
// // // // //       );
// // // // //     }

// // // // //     return SingleChildScrollView(
// // // // //       padding: const EdgeInsets.all(20),
// // // // //       child: Column(
// // // // //         children: [
// // // // //           if (_isActive) _buildStatusCard(),
// // // // //           const SizedBox(height: 20),
// // // // //           _buildTextField(_serialController, 'علم الوزن (Serial)', Icons.numbers, enabled: !_isActive),
// // // // //           const SizedBox(height: 15),
// // // // //           _buildTextField(_boxCountController, 'إجمالي الصناديق', Icons.inventory, enabled: !_isActive),
// // // // //           const SizedBox(height: 15),
// // // // //           _buildTextField(_boxInMinuteController, 'سرعة الدنبر الحالية', Icons.speed),
// // // // //           const SizedBox(height: 25),
// // // // //           if (_speedChanged && _isActive)
// // // // //             Padding(
// // // // //               padding: const EdgeInsets.only(bottom: 12),
// // // // //               child: _buildButton('تحديث السرعة فقط', Colors.orange, Icons.speed, _updateSpeed),
// // // // //             ),
// // // // //           if (!_isActive)
// // // // //             _buildButton('بدء التشغيل الآن', Colors.blueAccent, Icons.play_arrow, _handleStartOperation)
// // // // //           else
// // // // //             _buildButton('إنهاء السيارة الحالية', Colors.redAccent, Icons.stop, _handleEndOperation),
// // // // //           if (_speedHistory.isNotEmpty) ...[
// // // // //             const SizedBox(height: 30),
// // // // //             _buildSpeedHistoryList(),
// // // // //           ]
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   Widget _buildSpeedHistoryList() {
// // // // //     return Column(
// // // // //       crossAxisAlignment: CrossAxisAlignment.start,
// // // // //       children: [
// // // // //         const Text('سجل تغيير السرعات للعملية الحالية:', style: TextStyle(fontWeight: FontWeight.bold)),
// // // // //         const SizedBox(height: 10),
// // // // //         ListView.separated(
// // // // //           shrinkWrap: true,
// // // // //           physics: const NeverScrollableScrollPhysics(),
// // // // //           itemCount: _speedHistory.length,
// // // // //           separatorBuilder: (_, __) => const Divider(height: 1),
// // // // //           itemBuilder: (context, index) {
// // // // //             final item = _speedHistory[index];
// // // // //             final start = DateTime.parse(item['Operation_start']).toLocal();
// // // // //             final endStr = item['Operation_end'];
// // // // //             DateTime? end = endStr != null ? DateTime.parse(endStr).toLocal() : null;
// // // // //             final duration = end != null ? end.difference(start).inMinutes : DateTime.now().difference(start).inMinutes;
// // // // //             return ListTile(
// // // // //               dense: true,
// // // // //               leading: Icon(end == null ? Icons.play_circle_fill : Icons.history, 
// // // // //                           color: end == null ? Colors.green : Colors.blueGrey, size: 20),
// // // // //               title: Text('السرعة: ${item['Boxs_Count_in_minute']} صندوق/د'),
// // // // //               subtitle: Text('البدء: ${intl.DateFormat('hh:mm a').format(start)} | المدة: $duration دقيقة'),
// // // // //             );
// // // // //           },
// // // // //         ),
// // // // //       ],
// // // // //     );
// // // // //   }

// // // // //   Widget _buildStatusCard() {
// // // // //     String hours = _elapsed.inHours.toString().padLeft(2, '0');
// // // // //     String minutes = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
// // // // //     String seconds = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');

// // // // //     return Card(
// // // // //       color: Colors.blue[50],
// // // // //       elevation: 2,
// // // // //       shape: RoundedRectangleBorder(side: BorderSide(color: Colors.blue.shade200), borderRadius: BorderRadius.circular(15)),
// // // // //       child: Padding(
// // // // //         padding: const EdgeInsets.all(16.0),
// // // // //         child: Column(
// // // // //           children: [
// // // // //             Row(
// // // // //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // // //               children: [
// // // // //                 const Row(
// // // // //                   children: [
// // // // //                     Icon(Icons.circle, color: Colors.green, size: 12),
// // // // //                     SizedBox(width: 8),
// // // // //                     Text('سيارة نشطة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
// // // // //                   ],
// // // // //                 ),
// // // // //                 Text('بداية: ${intl.DateFormat('hh:mm a').format(_totalStartTime!)}', style: const TextStyle(fontSize: 10, color: Colors.blueGrey)),
// // // // //               ],
// // // // //             ),
// // // // //             const Divider(),
// // // // //             Row(
// // // // //               mainAxisAlignment: MainAxisAlignment.spaceAround,
// // // // //               children: [
// // // // //                 _statusItem('وقت التشغيل', '$hours:$minutes:$seconds', Icons.timer),
// // // // //                 _statusItem('توقف', '$_totalStopMinutes د', Icons.report_problem, color: Colors.red),
// // // // //                 if (_expectedEndTime != null)
// // // // //                   _statusItem('الانتهاء المتوقع', intl.DateFormat('hh:mm a').format(_expectedEndTime!), Icons.event_available, color: Colors.green[800]),
// // // // //               ],
// // // // //             ),
// // // // //             if (_expectedEndTime != null) ...[
// // // // //                const SizedBox(height: 8),
// // // // //                Text(
// // // // //                  'سيتم الانتهاء خلال ${(_expectedEndTime!.difference(DateTime.now()).inMinutes)} دقيقة تقريباً',
// // // // //                  style: TextStyle(fontSize: 10, color: Colors.green[700], fontStyle: FontStyle.italic),
// // // // //                ),
// // // // //             ]
// // // // //           ],
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   Widget _statusItem(String label, String value, IconData icon, {Color? color}) {
// // // // //     return Column(
// // // // //       children: [
// // // // //         Icon(icon, color: color ?? Colors.blueGrey, size: 20),
// // // // //         const SizedBox(height: 4),
// // // // //         Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
// // // // //         Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
// // // // //       ],
// // // // //     );
// // // // //   }

// // // // //   Widget _buildButton(String label, Color color, IconData icon, VoidCallback onPressed) {
// // // // //     return SizedBox(
// // // // //       width: double.infinity,
// // // // //       height: 55,
// // // // //       child: ElevatedButton.icon(
// // // // //         onPressed: _isLoading ? null : onPressed,
// // // // //         icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icon(icon),
// // // // //         label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
// // // // //         style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool enabled = true}) {
// // // // //     return TextField(
// // // // //       controller: controller,
// // // // //       enabled: enabled,
// // // // //       keyboardType: TextInputType.number,
// // // // //       decoration: InputDecoration(
// // // // //         labelText: label,
// // // // //         prefixIcon: Icon(icon),
// // // // //         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
// // // // //         filled: true,
// // // // //         fillColor: enabled ? Colors.grey[50] : Colors.grey[200],
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // import 'dart:async';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:manageon/station/Operation/OperationReportsScreen.dart';
// // // // // ملاحظة: تأكد من صحة مسار الاستيراد في مشروعك الفعلي
// // // // // import 'package:manageon/station/Operation/OperationReportsScreen.dart'; 
// // // // import 'package:supabase_flutter/supabase_flutter.dart';
// // // // import 'package:intl/intl.dart' as intl;

// // // // class OperationApp extends StatefulWidget {
// // // //   const OperationApp({super.key});

// // // //   @override
// // // //   State<OperationApp> createState() => _OperationAppState();
// // // // }

// // // // class _OperationAppState extends State<OperationApp> {
// // // //   int _currentIndex = 0;

// // // //   // استبدال الشاشات للعمل في بيئة معزولة للتجربة
// // // //   final List<Widget> _pages = [
// // // //     const OperationScreen(),
// // // //     const ReportsScreen(),
// // // //   ];

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Directionality(
// // // //       textDirection: TextDirection.rtl,
// // // //       child: Scaffold(
// // // //         body: _pages[_currentIndex],
// // // //         bottomNavigationBar: BottomNavigationBar(
// // // //           currentIndex: _currentIndex,
// // // //           onTap: (index) => setState(() => _currentIndex = index),
// // // //           items: const [
// // // //             BottomNavigationBarItem(icon: Icon(Icons.play_arrow), label: 'التشغيل'),
// // // //             BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'التقارير'),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // class OperationScreen extends StatefulWidget {
// // // //   const OperationScreen({super.key});

// // // //   @override
// // // //   State<OperationScreen> createState() => _OperationScreenState();
// // // // }

// // // // class _OperationScreenState extends State<OperationScreen> {
// // // //   bool isLine1Active = false;
// // // //   bool isLine2Active = false;
// // // //   bool isTotalActive = false;

// // // //   void updateLineStatus(String lineName, bool isActive) {
// // // //     setState(() {
// // // //       if (lineName == 'الخط الأول') isLine1Active = isActive;
// // // //       if (lineName == 'الخط الثاني') isLine2Active = isActive;
// // // //       if (lineName == 'دمج الخطين') isTotalActive = isActive;
// // // //     });
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     bool disableIndividualLines = isTotalActive;
// // // //     bool disableTotalLine = isLine1Active || isLine2Active;

// // // //     return DefaultTabController(
// // // //       length: 3,
// // // //       child: Scaffold(
// // // //         appBar: AppBar(
// // // //           title: const Text('لوحة تشغيل الخطوط'),
// // // //           bottom: const TabBar(
// // // //             labelColor: Colors.white,
// // // //             unselectedLabelColor: Colors.white70,
// // // //             indicatorColor: Colors.white,
// // // //             tabs: [
// // // //               Tab(text: 'الخط الأول'),
// // // //               Tab(text: 'الخط الثاني'),
// // // //               Tab(text: 'دمج الخطين'),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //         body: TabBarView(
// // // //           children: [
// // // //             LineForm(
// // // //               lineName: 'الخط الأول',
// // // //               isDisabledBySystem: disableIndividualLines,
// // // //               onStatusChanged: (active) => updateLineStatus('الخط الأول', active),
// // // //             ),
// // // //             LineForm(
// // // //               lineName: 'الخط الثاني',
// // // //               isDisabledBySystem: disableIndividualLines,
// // // //               onStatusChanged: (active) => updateLineStatus('الخط الثاني', active),
// // // //             ),
// // // //             LineForm(
// // // //               lineName: 'دمج الخطين',
// // // //               isDisabledBySystem: disableTotalLine,
// // // //               onStatusChanged: (active) => updateLineStatus('دمج الخطين', active),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // class LineForm extends StatefulWidget {
// // // //   final String lineName;
// // // //   final bool isDisabledBySystem;
// // // //   final Function(bool) onStatusChanged;

// // // //   const LineForm({
// // // //     super.key,
// // // //     required this.lineName,
// // // //     required this.isDisabledBySystem,
// // // //     required this.onStatusChanged,
// // // //   });

// // // //   @override
// // // //   State<LineForm> createState() => _LineFormState();
// // // // }

// // // // class _LineFormState extends State<LineForm> {
// // // //   final _serialController = TextEditingController();
// // // //   final _boxCountController = TextEditingController();
// // // //   final _boxInMinuteController = TextEditingController();

// // // //   bool _isLoading = false;
// // // //   bool _isActive = false;
// // // //   bool _speedChanged = false;

// // // //   int? _currentOperationId;
// // // //   int? _currentSubId;
// // // //   DateTime? _startTime;
// // // //   DateTime? _totalStartTime;
// // // //   DateTime? _expectedEndTime;

// // // //   Timer? _timer;
// // // //   Duration _elapsed = Duration.zero;
// // // //   int _totalStopMinutes = 0;
// // // //   List<dynamic> _speedHistory = [];

// // // //   final SupabaseClient supabase = Supabase.instance.client;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _checkActiveOperation();

// // // //     _boxInMinuteController.addListener(() {
// // // //       if (_isActive && !_isLoading) {
// // // //         setState(() => _speedChanged = true);
// // // //       }
// // // //     });
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _timer?.cancel();
// // // //     _serialController.dispose();
// // // //     _boxCountController.dispose();
// // // //     _boxInMinuteController.dispose();
// // // //     super.dispose();
// // // //   }

// // // //   // --- دوال التأكيد الجديدة ---

// // // //   Future<bool> _showConfirmDialog({
// // // //     required String title,
// // // //     required String content,
// // // //     required Color confirmColor,
// // // //   }) async {
// // // //     return await showDialog<bool>(
// // // //           context: context,
// // // //           builder: (context) => AlertDialog(
// // // //             title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
// // // //             content: Text(content),
// // // //             actions: [
// // // //               TextButton(
// // // //                 onPressed: () => Navigator.pop(context, false),
// // // //                 child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
// // // //               ),
// // // //               ElevatedButton(
// // // //                 onPressed: () => Navigator.pop(context, true),
// // // //                 style: ElevatedButton.styleFrom(backgroundColor: confirmColor, foregroundColor: Colors.white),
// // // //                 child: const Text('تأكيد'),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ) ??
// // // //         false;
// // // //   }

// // // //   // -------------------------

// // // //   Future<void> _calculateFaultsAndPredict() async {
// // // //     if (_totalStartTime == null || !_isActive) return;

// // // //     try {
// // // //       List<String> targetLines = [];
// // // //       if (widget.lineName == 'دمج الخطين') {
// // // //         targetLines = ['الخط الأول', 'الخط الثاني'];
// // // //       } else {
// // // //         targetLines = [widget.lineName];
// // // //       }

// // // //       final faults = await supabase
// // // //           .from('Fault_Logging')
// // // //           .select()
// // // //           .inFilter('line', targetLines)
// // // //           .eq('is_stop', true)
// // // //           .gte('fault_time', _totalStartTime!.toUtc().toIso8601String());

// // // //       int totalMinutes = 0;
// // // //       for (var f in faults) {
// // // //         if (f['fault_time'] != null && f['fix_time'] != null) {
// // // //           DateTime faultStart = DateTime.parse(f['fault_time']).toLocal();
// // // //           DateTime fixEnd = DateTime.parse(f['fix_time']).toLocal();
// // // //           int duration = fixEnd.difference(faultStart).inMinutes;
// // // //           if (duration > 0) totalMinutes += duration;
// // // //         }
// // // //       }

// // // //       if (mounted) {
// // // //         setState(() => _totalStopMinutes = totalMinutes);
// // // //         _calculateExpectedEndTime();
// // // //       }
// // // //     } catch (e) {
// // // //       debugPrint('Error calculating faults/prediction: $e');
// // // //     }
// // // //   }

// // // //   void _calculateExpectedEndTime() {
// // // //     if (!_isActive || _totalStartTime == null || _boxCountController.text.isEmpty || _boxInMinuteController.text.isEmpty) return;

// // // //     try {
// // // //       int totalBoxesRequired = int.parse(_boxCountController.text);
// // // //       int currentSpeed = int.parse(_boxInMinuteController.text);
// // // //       if (currentSpeed <= 0) return;

// // // //       double boxesProcessed = 0;

// // // //       for (var session in _speedHistory) {
// // // //         if (session['Operation_end'] != null) {
// // // //           DateTime start = DateTime.parse(session['Operation_start']).toLocal();
// // // //           DateTime end = DateTime.parse(session['Operation_end']).toLocal();
// // // //           int speed = session['Boxs_Count_in_minute'];
// // // //           int durationMinutes = end.difference(start).inMinutes;
// // // //           boxesProcessed += (durationMinutes * speed);
// // // //         }
// // // //       }

// // // //       if (_startTime != null) {
// // // //         int currentSessionMinutes = DateTime.now().difference(_startTime!).inMinutes;
// // // //         boxesProcessed += (currentSessionMinutes * currentSpeed);
// // // //       }

// // // //       double remainingBoxes = totalBoxesRequired - boxesProcessed;
// // // //       if (remainingBoxes < 0) remainingBoxes = 0;

// // // //       int remainingMinutesToFinish = (remainingBoxes / currentSpeed).ceil();
// // // //       DateTime predicted = DateTime.now().add(Duration(minutes: remainingMinutesToFinish));

// // // //       setState(() {
// // // //         _expectedEndTime = predicted;
// // // //       });
// // // //     } catch (e) {
// // // //       debugPrint('Prediction Error: $e');
// // // //     }
// // // //   }

// // // //   Future<void> _checkActiveOperation() async {
// // // //     if (!mounted) return;
// // // //     setState(() => _isLoading = true);
// // // //     try {
// // // //       final activeSub = await supabase
// // // //           .from('Operation_Sub')
// // // //           .select('*, Operation(*)')
// // // //           .eq('Line', widget.lineName)
// // // //           .isFilter('Operation_end', null)
// // // //           .order('Operation_start', ascending: false)
// // // //           .limit(1)
// // // //           .maybeSingle();

// // // //       if (activeSub != null && mounted) {
// // // //         final operationData = activeSub['Operation'];
// // // //         _currentOperationId = activeSub['Operation_id'];
// // // //         _currentSubId = activeSub['id'];

// // // //         final firstSub = await supabase
// // // //             .from('Operation_Sub')
// // // //             .select('Operation_start')
// // // //             .eq('Operation_id', _currentOperationId!)
// // // //             .order('Operation_start', ascending: true)
// // // //             .limit(1)
// // // //             .single();

// // // //         setState(() {
// // // //           _isActive = true;
// // // //           _startTime = DateTime.parse(activeSub['Operation_start']).toLocal();
// // // //           _totalStartTime = DateTime.parse(firstSub['Operation_start']).toLocal();

// // // //           _serialController.text = operationData['Serial'].toString();
// // // //           _boxCountController.text = operationData['Boxs_Count'].toString();
// // // //           _boxInMinuteController.text = activeSub['Boxs_Count_in_minute'].toString();

// // // //           _elapsed = DateTime.now().difference(_totalStartTime!);
// // // //         });

// // // //         widget.onStatusChanged(true);
// // // //         _startTimer();
// // // //         await _fetchSpeedHistory();
// // // //         _calculateFaultsAndPredict();
// // // //       }
// // // //     } catch (e) {
// // // //       debugPrint('Error fetching active op: $e');
// // // //     } finally {
// // // //       if (mounted) setState(() => _isLoading = false);
// // // //     }
// // // //   }

// // // //   Future<void> _fetchSpeedHistory() async {
// // // //     if (_currentOperationId == null) return;
// // // //     try {
// // // //       final history = await supabase
// // // //           .from('Operation_Sub')
// // // //           .select('Boxs_Count_in_minute, Operation_start, Operation_end')
// // // //           .eq('Operation_id', _currentOperationId!)
// // // //           .order('Operation_start', ascending: false);

// // // //       if (mounted) setState(() => _speedHistory = history);
// // // //     } catch (e) {
// // // //       debugPrint('Error history: $e');
// // // //     }
// // // //   }

// // // //   void _startTimer() {
// // // //     _timer?.cancel();
// // // //     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
// // // //       if (_totalStartTime != null && mounted) {
// // // //         setState(() {
// // // //           _elapsed = DateTime.now().difference(_totalStartTime!);
// // // //         });
// // // //         if (_elapsed.inSeconds % 30 == 0) _calculateFaultsAndPredict();
// // // //       }
// // // //     });
// // // //   }

// // // //   // --- المعالجات المحدثة مع رسائل التأكيد ---

// // // //   Future<void> _handleStartOperation() async {
// // // //     if (_serialController.text.isEmpty || _boxCountController.text.isEmpty || _boxInMinuteController.text.isEmpty) {
// // // //       _showMsg('الرجاء إكمال كافة الحقول قبل البدء');
// // // //       return;
// // // //     }

// // // //     // رسالة تأكيد البدء
// // // //     bool confirm = await _showConfirmDialog(
// // // //       title: 'تأكيد بدء التشغيل',
// // // //       content: 'هل أنت متأكد من رغبتك في بدء عملية تشغيل جديدة لهذا الخط؟',
// // // //       confirmColor: Colors.blueAccent,
// // // //     );
// // // //     if (!confirm) return;

// // // //     setState(() => _isLoading = true);
// // // //     try {
// // // //       final opRes = await supabase.from('Operation').insert({
// // // //         'Serial': int.parse(_serialController.text),
// // // //         'Boxs_Count': int.parse(_boxCountController.text),
// // // //       }).select().single();

// // // //       _currentOperationId = opRes['id'];
// // // //       _totalStartTime = DateTime.now();
// // // //       _startTime = _totalStartTime;

// // // //       final subRes = await supabase.from('Operation_Sub').insert({
// // // //         'Operation_id': _currentOperationId,
// // // //         'Operation_start': _startTime!.toUtc().toIso8601String(),
// // // //         'Line': widget.lineName,
// // // //         'Boxs_Count_in_minute': int.parse(_boxInMinuteController.text),
// // // //       }).select().single();

// // // //       _currentSubId = subRes['id'];

// // // //       setState(() {
// // // //         _isActive = true;
// // // //         _speedChanged = false;
// // // //         _totalStopMinutes = 0;
// // // //         _elapsed = Duration.zero;
// // // //       });
// // // //       widget.onStatusChanged(true);
// // // //       _startTimer();
// // // //       _fetchSpeedHistory();
// // // //       _calculateExpectedEndTime();
// // // //       _showMsg('تم بدء تشغيل السيارة بنجاح');
// // // //     } catch (e) {
// // // //       _showMsg('خطأ: $e', isError: true);
// // // //     } finally {
// // // //       if (mounted) setState(() => _isLoading = false);
// // // //     }
// // // //   }

// // // //   Future<void> _handleEndOperation() async {
// // // //     // رسالة تأكيد الإنهاء
// // // //     bool confirm = await _showConfirmDialog(
// // // //       title: 'تأكيد إنهاء التشغيل',
// // // //       content: 'سيتم إغلاق العملية الحالية وحفظ البيانات. هل تود الاستمرار؟',
// // // //       confirmColor: Colors.redAccent,
// // // //     );
// // // //     if (!confirm) return;

// // // //     setState(() => _isLoading = true);
// // // //     try {
// // // //       if (_currentSubId != null) {
// // // //         await supabase.from('Operation_Sub').update({
// // // //           'Operation_end': DateTime.now().toUtc().toIso8601String(),
// // // //         }).eq('id', _currentSubId!);
// // // //       }

// // // //       _timer?.cancel();
// // // //       setState(() {
// // // //         _isActive = false;
// // // //         _currentOperationId = null;
// // // //         _currentSubId = null;
// // // //         _startTime = null;
// // // //         _totalStartTime = null;
// // // //         _expectedEndTime = null;
// // // //         _elapsed = Duration.zero;
// // // //         _totalStopMinutes = 0;
// // // //         _speedChanged = false;
// // // //         _speedHistory = [];
// // // //         _serialController.clear();
// // // //         _boxCountController.clear();
// // // //         _boxInMinuteController.clear();
// // // //       });
// // // //       widget.onStatusChanged(false);
// // // //       _showMsg('تم إنهاء تشغيل السيارة');
// // // //     } catch (e) {
// // // //       _showMsg('خطأ أثناء الإنهاء: $e', isError: true);
// // // //     } finally {
// // // //       if (mounted) setState(() => _isLoading = false);
// // // //     }
// // // //   }

// // // //   Future<void> _updateSpeed() async {
// // // //     if (!_isActive || _currentOperationId == null) return;

// // // //     // رسالة تأكيد تحديث السرعة
// // // //     bool confirm = await _showConfirmDialog(
// // // //       title: 'تأكيد تحديث السرعة',
// // // //       content: 'هل تود تغيير سرعة الدنبر إلى ${_boxInMinuteController.text} صندوق/دقيقة؟',
// // // //       confirmColor: Colors.orange,
// // // //     );
// // // //     if (!confirm) return;

// // // //     setState(() => _isLoading = true);
// // // //     try {
// // // //       final now = DateTime.now();
// // // //       if (_currentSubId != null) {
// // // //         await supabase.from('Operation_Sub').update({
// // // //           'Operation_end': now.toUtc().toIso8601String(),
// // // //         }).eq('id', _currentSubId!);
// // // //       }

// // // //       final newSub = await supabase.from('Operation_Sub').insert({
// // // //         'Operation_id': _currentOperationId,
// // // //         'Operation_start': now.toUtc().toIso8601String(),
// // // //         'Line': widget.lineName,
// // // //         'Boxs_Count_in_minute': int.parse(_boxInMinuteController.text),
// // // //       }).select().single();

// // // //       _currentSubId = newSub['id'];
// // // //       _startTime = now;
// // // //       setState(() => _speedChanged = false);
// // // //       await _fetchSpeedHistory();
// // // //       _calculateExpectedEndTime();
// // // //       _showMsg('تم تحديث السرعة');
// // // //     } catch (e) {
// // // //       _showMsg('خطأ في التحديث: $e', isError: true);
// // // //     } finally {
// // // //       if (mounted) setState(() => _isLoading = false);
// // // //     }
// // // //   }

// // // //   void _showMsg(String msg, {bool isError = false}) {
// // // //     if (!mounted) return;
// // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // //       SnackBar(
// // // //         content: Text(msg),
// // // //         backgroundColor: isError ? Colors.red : Colors.green,
// // // //         behavior: SnackBarBehavior.floating,
// // // //       ),
// // // //     );
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     if (widget.isDisabledBySystem && !_isActive) {
// // // //       return Center(
// // // //         child: Column(
// // // //           mainAxisAlignment: MainAxisAlignment.center,
// // // //           children: [
// // // //             const Icon(Icons.block, size: 60, color: Colors.grey),
// // // //             const SizedBox(height: 16),
// // // //             Text('هذا الخط غير متاح حالياً', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
// // // //           ],
// // // //         ),
// // // //       );
// // // //     }

// // // //     return SingleChildScrollView(
// // // //       padding: const EdgeInsets.all(20),
// // // //       child: Column(
// // // //         children: [
// // // //           if (_isActive) _buildStatusCard(),
// // // //           const SizedBox(height: 20),
// // // //           _buildTextField(_serialController, 'علم الوزن (Serial)', Icons.numbers, enabled: !_isActive),
// // // //           const SizedBox(height: 15),
// // // //           _buildTextField(_boxCountController, 'إجمالي الصناديق', Icons.inventory, enabled: !_isActive),
// // // //           const SizedBox(height: 15),
// // // //           _buildTextField(_boxInMinuteController, 'سرعة الدنبر الحالية', Icons.speed),
// // // //           const SizedBox(height: 25),
// // // //           if (_speedChanged && _isActive)
// // // //             Padding(
// // // //               padding: const EdgeInsets.only(bottom: 12),
// // // //               child: _buildButton('تحديث السرعة فقط', Colors.orange, Icons.speed, _updateSpeed),
// // // //             ),
// // // //           if (!_isActive)
// // // //             _buildButton('بدء التشغيل الآن', Colors.blueAccent, Icons.play_arrow, _handleStartOperation)
// // // //           else
// // // //             _buildButton('إنهاء السيارة الحالية', Colors.redAccent, Icons.stop, _handleEndOperation),
// // // //           if (_speedHistory.isNotEmpty) ...[
// // // //             const SizedBox(height: 30),
// // // //             _buildSpeedHistoryList(),
// // // //           ]
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _buildSpeedHistoryList() {
// // // //     return Column(
// // // //       crossAxisAlignment: CrossAxisAlignment.start,
// // // //       children: [
// // // //         const Text('سجل تغيير السرعات للعملية الحالية:', style: TextStyle(fontWeight: FontWeight.bold)),
// // // //         const SizedBox(height: 10),
// // // //         ListView.separated(
// // // //           shrinkWrap: true,
// // // //           physics: const NeverScrollableScrollPhysics(),
// // // //           itemCount: _speedHistory.length,
// // // //           separatorBuilder: (_, __) => const Divider(height: 1),
// // // //           itemBuilder: (context, index) {
// // // //             final item = _speedHistory[index];
// // // //             final start = DateTime.parse(item['Operation_start']).toLocal();
// // // //             final endStr = item['Operation_end'];
// // // //             DateTime? end = endStr != null ? DateTime.parse(endStr).toLocal() : null;
// // // //             final duration = end != null ? end.difference(start).inMinutes : DateTime.now().difference(start).inMinutes;
// // // //             return ListTile(
// // // //               dense: true,
// // // //               leading: Icon(end == null ? Icons.play_circle_fill : Icons.history, color: end == null ? Colors.green : Colors.blueGrey, size: 20),
// // // //               title: Text('السرعة: ${item['Boxs_Count_in_minute']} صندوق/د'),
// // // //               subtitle: Text('البدء: ${intl.DateFormat('hh:mm a').format(start)} | المدة: $duration دقيقة'),
// // // //             );
// // // //           },
// // // //         ),
// // // //       ],
// // // //     );
// // // //   }

// // // //   Widget _buildStatusCard() {
// // // //     String hours = _elapsed.inHours.toString().padLeft(2, '0');
// // // //     String minutes = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
// // // //     String seconds = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');

// // // //     return Card(
// // // //       color: Colors.blue[50],
// // // //       elevation: 2,
// // // //       shape: RoundedRectangleBorder(side: BorderSide(color: Colors.blue.shade200), borderRadius: BorderRadius.circular(15)),
// // // //       child: Padding(
// // // //         padding: const EdgeInsets.all(16.0),
// // // //         child: Column(
// // // //           children: [
// // // //             Row(
// // // //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //               children: [
// // // //                 const Row(
// // // //                   children: [
// // // //                     Icon(Icons.circle, color: Colors.green, size: 12),
// // // //                     SizedBox(width: 8),
// // // //                     Text('سيارة نشطة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
// // // //                   ],
// // // //                 ),
// // // //                 Text('بداية: ${intl.DateFormat('hh:mm a').format(_totalStartTime!)}', style: const TextStyle(fontSize: 10, color: Colors.blueGrey)),
// // // //               ],
// // // //             ),
// // // //             const Divider(),
// // // //             Row(
// // // //               mainAxisAlignment: MainAxisAlignment.spaceAround,
// // // //               children: [
// // // //                 _statusItem('وقت التشغيل', '$hours:$minutes:$seconds', Icons.timer),
// // // //                 _statusItem('توقف', '$_totalStopMinutes د', Icons.report_problem, color: Colors.red),
// // // //                 if (_expectedEndTime != null) _statusItem('الانتهاء المتوقع', intl.DateFormat('hh:mm a').format(_expectedEndTime!), Icons.event_available, color: Colors.green[800]),
// // // //               ],
// // // //             ),
// // // //             if (_expectedEndTime != null) ...[
// // // //               const SizedBox(height: 8),
// // // //               Text(
// // // //                 'سيتم الانتهاء خلال ${(_expectedEndTime!.difference(DateTime.now()).inMinutes)} دقيقة تقريباً',
// // // //                 style: TextStyle(fontSize: 10, color: Colors.green[700], fontStyle: FontStyle.italic),
// // // //               ),
// // // //             ]
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _statusItem(String label, String value, IconData icon, {Color? color}) {
// // // //     return Column(
// // // //       children: [
// // // //         Icon(icon, color: color ?? Colors.blueGrey, size: 20),
// // // //         const SizedBox(height: 4),
// // // //         Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
// // // //         Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
// // // //       ],
// // // //     );
// // // //   }

// // // //   Widget _buildButton(String label, Color color, IconData icon, VoidCallback onPressed) {
// // // //     return SizedBox(
// // // //       width: double.infinity,
// // // //       height: 55,
// // // //       child: ElevatedButton.icon(
// // // //         onPressed: _isLoading ? null : onPressed,
// // // //         icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icon(icon),
// // // //         label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
// // // //         style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool enabled = true}) {
// // // //     return TextField(
// // // //       controller: controller,
// // // //       enabled: enabled,
// // // //       keyboardType: TextInputType.number,
// // // //       decoration: InputDecoration(
// // // //         labelText: label,
// // // //         prefixIcon: Icon(icon),
// // // //         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
// // // //         filled: true,
// // // //         fillColor: enabled ? Colors.grey[50] : Colors.grey[200],
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // import 'dart:async';
// // // import 'package:flutter/material.dart';
// // // import 'package:supabase_flutter/supabase_flutter.dart';
// // // import 'package:intl/intl.dart' as intl;

// // // // ملاحظة: افترضنا وجود الشاشات المستوردة أو استبدالها بـ Placeholders للتشغيل
// // // class OperationApp extends StatefulWidget {
// // //   const OperationApp({super.key});

// // //   @override
// // //   State<OperationApp> createState() => _OperationAppState();
// // // }

// // // class _OperationAppState extends State<OperationApp> {
// // //   int _currentIndex = 0;
// // //   final List<Widget> _pages = [
// // //     const OperationScreen(),
// // //     const Center(child: Text('شاشة التقارير')),
// // //   ];

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Directionality(
// // //       textDirection: TextDirection.rtl,
// // //       child: Scaffold(
// // //         body: _pages[_currentIndex],
// // //         bottomNavigationBar: BottomNavigationBar(
// // //           currentIndex: _currentIndex,
// // //           onTap: (index) => setState(() => _currentIndex = index),
// // //           items: const [
// // //             BottomNavigationBarItem(icon: Icon(Icons.play_arrow), label: 'التشغيل'),
// // //             BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'التقارير'),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }

// // // class OperationScreen extends StatefulWidget {
// // //   const OperationScreen({super.key});

// // //   @override
// // //   State<OperationScreen> createState() => _OperationScreenState();
// // // }

// // // class _OperationScreenState extends State<OperationScreen> {
// // //   bool isLine1Active = false;
// // //   bool isLine2Active = false;
// // //   bool isTotalActive = false;

// // //   void updateLineStatus(String lineName, bool isActive) {
// // //     setState(() {
// // //       if (lineName == 'الخط الأول') isLine1Active = isActive;
// // //       if (lineName == 'الخط الثاني') isLine2Active = isActive;
// // //       if (lineName == 'دمج الخطين') isTotalActive = isActive;
// // //     });
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     bool disableIndividualLines = isTotalActive;
// // //     bool disableTotalLine = isLine1Active || isLine2Active;

// // //     return DefaultTabController(
// // //       length: 3,
// // //       child: Scaffold(
// // //         appBar: AppBar(
// // //           title: const Text('لوحة تشغيل الخطوط'),
// // //           bottom: const TabBar(
// // //             tabs: [
// // //               Tab(text: 'الخط الأول'),
// // //               Tab(text: 'الخط الثاني'),
// // //               Tab(text: 'دمج الخطين'),
// // //             ],
// // //           ),
// // //         ),
// // //         body: TabBarView(
// // //           children: [
// // //             LineForm(
// // //               lineName: 'الخط الأول',
// // //               isDisabledBySystem: disableIndividualLines,
// // //               onStatusChanged: (active) => updateLineStatus('الخط الأول', active),
// // //             ),
// // //             LineForm(
// // //               lineName: 'الخط الثاني',
// // //               isDisabledBySystem: disableIndividualLines,
// // //               onStatusChanged: (active) => updateLineStatus('الخط الثاني', active),
// // //             ),
// // //             LineForm(
// // //               lineName: 'دمج الخطين',
// // //               isDisabledBySystem: disableTotalLine,
// // //               onStatusChanged: (active) => updateLineStatus('دمج الخطين', active),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }

// // // class LineForm extends StatefulWidget {
// // //   final String lineName;
// // //   final bool isDisabledBySystem;
// // //   final Function(bool) onStatusChanged;

// // //   const LineForm({
// // //     super.key,
// // //     required this.lineName,
// // //     required this.isDisabledBySystem,
// // //     required this.onStatusChanged,
// // //   });

// // //   @override
// // //   State<LineForm> createState() => _LineFormState();
// // // }

// // // class _LineFormState extends State<LineForm> {
// // //   final _serialController = TextEditingController();
// // //   final _boxCountController = TextEditingController();
// // //   final _boxInMinuteController = TextEditingController();
// // //   final _faultReasonController = TextEditingController(); // كنترولر سبب العطل

// // //   bool _isLoading = false;
// // //   bool _isActive = false;
// // //   bool _speedChanged = false;
// // //   bool _isFaultActive = false; // هل يوجد عطل حالي؟

// // //   int? _currentOperationId;
// // //   int? _currentSubId;
// // //   int? _currentFaultId; // لتخزين ID العطل الحالي لتحديثه عند الإصلاح
  
// // //   DateTime? _startTime;
// // //   DateTime? _totalStartTime;
// // //   DateTime? _expectedEndTime;

// // //   Timer? _timer;
// // //   Duration _elapsed = Duration.zero;
// // //   int _totalStopMinutes = 0;
// // //   List<dynamic> _speedHistory = [];

// // //   final SupabaseClient supabase = Supabase.instance.client;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _checkActiveOperation();
// // //     _boxInMinuteController.addListener(() {
// // //       if (_isActive && !_isLoading) {
// // //         setState(() => _speedChanged = true);
// // //       }
// // //     });
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _timer?.cancel();
// // //     _serialController.dispose();
// // //     _boxCountController.dispose();
// // //     _boxInMinuteController.dispose();
// // //     _faultReasonController.dispose();
// // //     super.dispose();
// // //   }

// // //   // --- دالة التأكيد ---
// // //   Future<bool> _showConfirmDialog({
// // //     required String title,
// // //     required String content,
// // //     required Color confirmColor,
// // //   }) async {
// // //     return await showDialog<bool>(
// // //           context: context,
// // //           builder: (context) => AlertDialog(
// // //             title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
// // //             content: Text(content),
// // //             actions: [
// // //               TextButton(
// // //                 onPressed: () => Navigator.pop(context, false),
// // //                 child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
// // //               ),
// // //               ElevatedButton(
// // //                 onPressed: () => Navigator.pop(context, true),
// // //                 style: ElevatedButton.styleFrom(backgroundColor: confirmColor, foregroundColor: Colors.white),
// // //                 child: const Text('تأكيد'),
// // //               ),
// // //             ],
// // //           ),
// // //         ) ??
// // //         false;
// // //   }

// // //   // --- منطق العطال الجديد ---

// // //   Future<void> _handleFaultToggle() async {
// // //     if (_isFaultActive) {
// // //       // حالة "إصلاح العطل"
// // //       bool confirm = await _showConfirmDialog(
// // //         title: 'تأكيد إصلاح العطل',
// // //         content: 'هل تم الانتهاء من إصلاح العطل وإعادة التشغيل؟',
// // //         confirmColor: Colors.green,
// // //       );
// // //       if (!confirm) return;

// // //       setState(() => _isLoading = true);
// // //       try {
// // //         await supabase.from('Operation_fault').update({
// // //           'End__fault': DateTime.now().toUtc().toIso8601String(),
// // //           'Reason': _faultReasonController.text.isEmpty ? 'لا يوجد سبب محدد' : _faultReasonController.text,
// // //         }).eq('id', _currentFaultId!);

// // //         setState(() {
// // //           _isFaultActive = false;
// // //           _currentFaultId = null;
// // //           _faultReasonController.clear();
// // //         });
// // //         _calculateFaultsAndPredict(); // تحديث التوقعات بعد الإصلاح
// // //         _showMsg('تم تسجيل إصلاح العطل بنجاح');
// // //       } catch (e) {
// // //         _showMsg('خطأ في تحديث العطل: $e', isError: true);
// // //       } finally {
// // //         setState(() => _isLoading = false);
// // //       }
// // //     } else {
// // //       // حالة "تسجيل عطل"
// // //       bool confirm = await _showConfirmDialog(
// // //         title: 'تسجيل عطل جديد',
// // //         content: 'هل أنت متأكد من وجود عطل يتطلب إيقاف التشغيل الآن؟',
// // //         confirmColor: Colors.orange,
// // //       );
// // //       if (!confirm) return;

// // //       setState(() => _isLoading = true);
// // //       try {
// // //         final res = await supabase.from('Operation_fault').insert({
// // //           'Operation_id': _currentOperationId,
// // //           'Start_fault': DateTime.now().toUtc().toIso8601String(),
// // //         }).select().single();

// // //         setState(() {
// // //           _isFaultActive = true;
// // //           _currentFaultId = res['id'];
// // //         });
// // //         _showMsg('تم تسجيل بدء العطل. يرجى كتابة السبب إن أمكن');
// // //       } catch (e) {
// // //         _showMsg('خطأ في تسجيل العطل: $e', isError: true);
// // //       } finally {
// // //         setState(() => _isLoading = false);
// // //       }
// // //     }
// // //   }

// // //   // --- الدوال الأساسية المستمدة من كودك السابق ---

// // //   Future<void> _checkActiveOperation() async {
// // //     setState(() => _isLoading = true);
// // //     try {
// // //       final activeSub = await supabase
// // //           .from('Operation_Sub')
// // //           .select('*, Operation(*)')
// // //           .eq('Line', widget.lineName)
// // //           .isFilter('Operation_end', null)
// // //           .maybeSingle();

// // //       if (activeSub != null && mounted) {
// // //         _currentOperationId = activeSub['Operation_id'];
// // //         _currentSubId = activeSub['id'];
        
// // //         setState(() {
// // //           _isActive = true;
// // //           _startTime = DateTime.parse(activeSub['Operation_start']).toLocal();
// // //           _totalStartTime = _startTime; // تبسيط للنموذج
// // //           _serialController.text = activeSub['Operation']['Serial'].toString();
// // //           _boxCountController.text = activeSub['Operation']['Boxs_Count'].toString();
// // //           _boxInMinuteController.text = activeSub['Boxs_Count_in_minute'].toString();
// // //         });

// // //         // التحقق إذا كان هناك عطل مفتوح لهذه العملية
// // //         final activeFault = await supabase
// // //             .from('Operation_fault')
// // //             .select()
// // //             .eq('Operation_id', _currentOperationId!)
// // //             .isFilter('End__fault', null)
// // //             .maybeSingle();

// // //         if (activeFault != null) {
// // //           setState(() {
// // //             _isFaultActive = true;
// // //             _currentFaultId = activeFault['id'];
// // //             _faultReasonController.text = activeFault['Reason'] ?? '';
// // //           });
// // //         }

// // //         widget.onStatusChanged(true);
// // //         _startTimer();
// // //         _fetchSpeedHistory();
// // //       }
// // //     } catch (e) {
// // //       debugPrint('Error: $e');
// // //     } finally {
// // //       if (mounted) setState(() => _isLoading = false);
// // //     }
// // //   }

// // //   // (بقية الدوال: _calculateFaultsAndPredict, _startTimer, _handleStartOperation و غيرها تبقى كما هي مع دمج زر العطل)

// // //   Future<void> _calculateFaultsAndPredict() async {
// // //     if (_currentOperationId == null) return;
// // //     try {
// // //       final faults = await supabase
// // //           .from('Operation_fault')
// // //           .select()
// // //           .eq('Operation_id', _currentOperationId!)
// // //           .not('End__fault', 'is', null);

// // //       int totalMinutes = 0;
// // //       for (var f in faults) {
// // //         DateTime start = DateTime.parse(f['Start_fault']).toLocal();
// // //         DateTime end = DateTime.parse(f['End__fault']).toLocal();
// // //         totalMinutes += end.difference(start).inMinutes;
// // //       }

// // //       setState(() => _totalStopMinutes = totalMinutes);
// // //       // استدعاء دالة التوقع هنا بناءً على السرعة المتبقية
// // //     } catch (e) {
// // //       debugPrint('Fault Calc Error: $e');
// // //     }
// // //   }

// // //   void _startTimer() {
// // //     _timer?.cancel();
// // //     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
// // //       if (_startTime != null && mounted) {
// // //         setState(() {
// // //           _elapsed = DateTime.now().difference(_startTime!);
// // //         });
// // //       }
// // //     });
// // //   }

// // //   Future<void> _handleStartOperation() async {
// // //     if (_serialController.text.isEmpty || _boxCountController.text.isEmpty || _boxInMinuteController.text.isEmpty) {
// // //       _showMsg('الرجاء إكمال كافة الحقول', isError: true);
// // //       return;
// // //     }

// // //     bool confirm = await _showConfirmDialog(
// // //       title: 'بدء التشغيل',
// // //       content: 'هل تود بدء دورة تشغيل جديدة؟',
// // //       confirmColor: Colors.blue,
// // //     );
// // //     if (!confirm) return;

// // //     setState(() => _isLoading = true);
// // //     try {
// // //       final op = await supabase.from('Operation').insert({
// // //         'Serial': int.parse(_serialController.text),
// // //         'Boxs_Count': int.parse(_boxCountController.text),
// // //       }).select().single();

// // //       _currentOperationId = op['id'];
// // //       final now = DateTime.now();
      
// // //       final sub = await supabase.from('Operation_Sub').insert({
// // //         'Operation_id': _currentOperationId,
// // //         'Operation_start': now.toUtc().toIso8601String(),
// // //         'Line': widget.lineName,
// // //         'Boxs_Count_in_minute': int.parse(_boxInMinuteController.text),
// // //       }).select().single();

// // //       _currentSubId = sub['id'];
// // //       setState(() {
// // //         _isActive = true;
// // //         _startTime = now;
// // //         _totalStartTime = now;
// // //       });
// // //       widget.onStatusChanged(true);
// // //       _startTimer();
// // //       _showMsg('تم البدء بنجاح');
// // //     } catch (e) {
// // //       _showMsg('خطأ: $e', isError: true);
// // //     } finally {
// // //       setState(() => _isLoading = false);
// // //     }
// // //   }

// // //   void _showMsg(String msg, {bool isError = false}) {
// // //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
// // //       content: Text(msg),
// // //       backgroundColor: isError ? Colors.red : Colors.green,
// // //     ));
// // //   }

// // //   Future<void> _fetchSpeedHistory() async {
// // //     if (_currentOperationId == null) return;
// // //     final history = await supabase
// // //         .from('Operation_Sub')
// // //         .select()
// // //         .eq('Operation_id', _currentOperationId!)
// // //         .order('Operation_start', ascending: false);
// // //     setState(() => _speedHistory = history);
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     if (widget.isDisabledBySystem && !_isActive) {
// // //       return const Center(child: Text('هذا الخط غير متاح حالياً'));
// // //     }

// // //     return SingleChildScrollView(
// // //       padding: const EdgeInsets.all(20),
// // //       child: Column(
// // //         children: [
// // //           if (_isActive) _buildStatusCard(),
// // //           const SizedBox(height: 20),
// // //           _buildTextField(_serialController, 'علم الوزن (Serial)', Icons.numbers, enabled: !_isActive),
// // //           const SizedBox(height: 15),
// // //           _buildTextField(_boxCountController, 'إجمالي الصناديق', Icons.inventory, enabled: !_isActive),
// // //           const SizedBox(height: 15),
// // //           _buildTextField(_boxInMinuteController, 'سرعة الدنبر الحالية', Icons.speed),
          
// // //           // --- قسم تسجيل العطل الجديد ---
// // //           if (_isActive) ...[
// // //             const SizedBox(height: 20),
// // //             const Divider(),
// // //             if (_isFaultActive)
// // //               Padding(
// // //                 padding: const EdgeInsets.symmetric(vertical: 10),
// // //                 child: TextField(
// // //                   controller: _faultReasonController,
// // //                   decoration: InputDecoration(
// // //                     labelText: 'سبب العطل (اختياري)',
// // //                     hintText: 'اكتب سبب التوقف هنا...',
// // //                     prefixIcon: const Icon(Icons.edit_note, color: Colors.orange),
// // //                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
// // //                   ),
// // //                 ),
// // //               ),
// // //             _buildButton(
// // //               _isFaultActive ? 'إصلاح العطل وإعادة التشغيل' : 'تسجيل عطل مفاجئ',
// // //               _isFaultActive ? Colors.green : Colors.orange,
// // //               _isFaultActive ? Icons.build_circle : Icons.warning_amber_rounded,
// // //               _handleFaultToggle,
// // //             ),
// // //             const Divider(),
// // //           ],

// // //           const SizedBox(height: 20),
// // //           if (!_isActive)
// // //             _buildButton('بدء التشغيل الآن', Colors.blueAccent, Icons.play_arrow, _handleStartOperation)
// // //           else
// // //             _buildButton('إنهاء السيارة الحالية', Colors.redAccent, Icons.stop, () async {
// // //                bool confirm = await _showConfirmDialog(title: 'إنهاء', content: 'هل تريد الإنهاء؟', confirmColor: Colors.red);
// // //                if(confirm) { /* تنفيذ إنهاء من كودك الأصلي */ }
// // //             }),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   // دوال الـ UI المساعدة كما هي في كودك
// // //   Widget _buildStatusCard() {
// // //     return Card(
// // //       color: _isFaultActive ? Colors.red[50] : Colors.blue[50],
// // //       shape: RoundedRectangleBorder(
// // //         borderRadius: BorderRadius.circular(15),
// // //         side: BorderSide(color: _isFaultActive ? Colors.red : Colors.blue.shade200),
// // //       ),
// // //       child: Padding(
// // //         padding: const EdgeInsets.all(16),
// // //         child: Column(
// // //           children: [
// // //             Row(
// // //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //               children: [
// // //                 Row(
// // //                   children: [
// // //                     Icon(Icons.circle, color: _isFaultActive ? Colors.red : Colors.green, size: 12),
// // //                     const SizedBox(width: 8),
// // //                     Text(
// // //                       _isFaultActive ? 'عطل متوقف' : 'سيارة نشطة',
// // //                       style: TextStyle(fontWeight: FontWeight.bold, color: _isFaultActive ? Colors.red : Colors.blue),
// // //                     ),
// // //                   ],
// // //                 ),
// // //                 Text('توقف كلي: $_totalStopMinutes دقيقة', style: const TextStyle(fontSize: 12)),
// // //               ],
// // //             ),
// // //             const Divider(),
// // //             Text('وقت التشغيل المنقضي: ${_elapsed.inHours}:${(_elapsed.inMinutes % 60).toString().padLeft(2, '0')}:${(_elapsed.inSeconds % 60).toString().padLeft(2, '0')}'),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildButton(String label, Color color, IconData icon, VoidCallback onPressed) {
// // //     return SizedBox(
// // //       width: double.infinity,
// // //       height: 55,
// // //       child: ElevatedButton.icon(
// // //         onPressed: _isLoading ? null : onPressed,
// // //         icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icon(icon),
// // //         label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
// // //         style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool enabled = true}) {
// // //     return TextField(
// // //       controller: controller,
// // //       enabled: enabled,
// // //       keyboardType: TextInputType.number,
// // //       decoration: InputDecoration(
// // //         labelText: label,
// // //         prefixIcon: Icon(icon),
// // //         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
// // //         filled: true,
// // //         fillColor: enabled ? Colors.grey[50] : Colors.grey[200],
// // //       ),
// // //     );
// // //   }
// // // }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:manageon/station/Operation/OperationFaultsLogScreen.dart';
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
    const FaultsLogScreen(),
   
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
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'الاعطال'),
          ],
        ),
      ),
    );
  }
}

// --- شاشة التشغيل الرئيسية ---
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
          title: const Text('لوحة تشغيل الخطوط'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'الخط الأول'),
              Tab(text: 'الخط الثاني'),
              Tab(text: 'دمج الخطين'),
            ],
          ),
        ),
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

// --- نموذج الخط المنفرد ---
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
  final _faultReasonController = TextEditingController();

  bool _isLoading = false;
  bool _isActive = false;
  bool _speedChanged = false;
  bool _isFaultActive = false;

  int? _currentOperationId;
  int? _currentSubId;
  int? _currentFaultId;
  
  DateTime? _startTime;
  DateTime? _totalStartTime;
  DateTime? _expectedEndTime;

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

  @override
  void dispose() {
    _timer?.cancel();
    _serialController.dispose();
    _boxCountController.dispose();
    _boxInMinuteController.dispose();
    _faultReasonController.dispose();
    super.dispose();
  }

  // --- التحقق من وجود عملية نشطة عند الفتح ---
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

        // الحصول على وقت البداية الحقيقي (أول سجل فرعي)
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
        });

        // التحقق من وجود عطل نشط
        final activeFault = await supabase
            .from('Operation_fault')
            .select()
            .eq('Operation_id', _currentOperationId!)
            .isFilter('End__fault', null)
            .maybeSingle();

        if (activeFault != null) {
          setState(() {
            _isFaultActive = true;
            _currentFaultId = activeFault['id'];
          });
        }

        widget.onStatusChanged(true);
        _startTimer();
        await _fetchSpeedHistory();
        _calculateFaultsAndPredict();
      }
    } catch (e) {
      debugPrint('Error fetching active op: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- منطق العطال المتكامل ---
  Future<void> _handleFaultToggle() async {
    if (_isFaultActive) {
      bool confirm = await _showConfirmDialog(
        title: 'تأكيد الإصلاح',
        content: 'هل تم الانتهاء من إصلاح العطل؟',
        confirmColor: Colors.green,
      );
      if (!confirm) return;

      setState(() => _isLoading = true);
      try {
        await supabase.from('Operation_fault').update({
          'End__fault': DateTime.now().toUtc().toIso8601String(),
          'Reason': _faultReasonController.text,
        }).eq('id', _currentFaultId!);

        setState(() {
          _isFaultActive = false;
          _currentFaultId = null;
          _faultReasonController.clear();
        });
        _calculateFaultsAndPredict();
        _showMsg('تم تسجيل الإصلاح بنجاح');
      } catch (e) {
        _showMsg('خطأ: $e', isError: true);
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      bool confirm = await _showConfirmDialog(
        title: 'تسجيل عطل',
        content: 'هل تريد تسجيل توقف عطل الآن؟',
        confirmColor: Colors.orange,
      );
      if (!confirm) return;

      setState(() => _isLoading = true);
      try {
        final res = await supabase.from('Operation_fault').insert({
          'Operation_id': _currentOperationId,
          'Start_fault': DateTime.now().toUtc().toIso8601String(),
        }).select().single();

        setState(() {
          _isFaultActive = true;
          _currentFaultId = res['id'];
        });
        _showMsg('تم تسجيل بدء العطل');
      } catch (e) {
        _showMsg('خطأ: $e', isError: true);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- حساب التوقفات والتوقعات ---
  Future<void> _calculateFaultsAndPredict() async {
    if (_currentOperationId == null) return;
    try {
      final faults = await supabase
          .from('Operation_fault')
          .select()
          .eq('Operation_id', _currentOperationId!)
          .not('End__fault', 'is', null);

      int totalMinutes = 0;
      for (var f in faults) {
        DateTime start = DateTime.parse(f['Start_fault']).toLocal();
        DateTime end = DateTime.parse(f['End__fault']).toLocal();
        totalMinutes += end.difference(start).inMinutes;
      }

      setState(() => _totalStopMinutes = totalMinutes);
      _calculateExpectedEndTime();
    } catch (e) {
      debugPrint('Fault calculation error: $e');
    }
  }

  void _calculateExpectedEndTime() {
    if (!_isActive || _totalStartTime == null || _boxCountController.text.isEmpty || _boxInMinuteController.text.isEmpty) return;
    try {
      int totalRequired = int.parse(_boxCountController.text);
      int speed = int.parse(_boxInMinuteController.text);
      if (speed <= 0) return;

      double processed = 0;
      // حساب ما تم إنجازه في الجلسات السابقة
      for (var s in _speedHistory) {
        if (s['Operation_end'] != null) {
          int dur = DateTime.parse(s['Operation_end']).difference(DateTime.parse(s['Operation_start'])).inMinutes;
          processed += (dur * s['Boxs_Count_in_minute']);
        }
      }
      // إضافة الجلسة الحالية
      if (_startTime != null) {
        processed += (DateTime.now().difference(_startTime!).inMinutes * speed);
      }

      double remaining = totalRequired - processed;
      if (remaining < 0) remaining = 0;
      int remainingMin = (remaining / speed).ceil();
      
      setState(() {
        _expectedEndTime = DateTime.now().add(Duration(minutes: remainingMin + _totalStopMinutes));
      });
    } catch (_) {}
  }

  // --- إدارة بدء وإنهاء التشغيل ---
  Future<void> _handleStartOperation() async {
    if (_serialController.text.isEmpty || _boxCountController.text.isEmpty || _boxInMinuteController.text.isEmpty) {
      _showMsg('أكمل البيانات أولاً', isError: true);
      return;
    }

    bool confirm = await _showConfirmDialog(
      title: 'بدء التشغيل',
      content: 'تأكيد بدء تشغيل السيارة رقم ${_serialController.text}؟',
      confirmColor: Colors.blueAccent,
    );
    if (!confirm) return;

    setState(() => _isLoading = true);
    try {
      final op = await supabase.from('Operation').insert({
        'Serial': int.parse(_serialController.text),
        'Boxs_Count': int.parse(_boxCountController.text),
      }).select().single();

      _currentOperationId = op['id'];
      _totalStartTime = DateTime.now();
      _startTime = _totalStartTime;

      final sub = await supabase.from('Operation_Sub').insert({
        'Operation_id': _currentOperationId,
        'Operation_start': _startTime!.toUtc().toIso8601String(),
        'Line': widget.lineName,
        'Boxs_Count_in_minute': int.parse(_boxInMinuteController.text),
      }).select().single();

      _currentSubId = sub['id'];
      setState(() => _isActive = true);
      widget.onStatusChanged(true);
      _startTimer();
      _fetchSpeedHistory();
      _showMsg('بدأ التشغيل');
    } catch (e) {
      _showMsg('خطأ البدء: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEndOperation() async {
    if (_isFaultActive) {
      _showMsg('يرجى إصلاح العطل أولاً قبل الإنهاء', isError: true);
      return;
    }

    bool confirm = await _showConfirmDialog(
      title: 'إنهاء التشغيل',
      content: 'هل اكتملت السيارة وتريد إغلاق التقرير؟',
      confirmColor: Colors.redAccent,
    );
    if (!confirm) return;

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
      _showMsg('تم إنهاء السيارة وحفظ البيانات');
    } catch (e) {
      _showMsg('خطأ في الإنهاء: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateSpeed() async {
    bool confirm = await _showConfirmDialog(
      title: 'تحديث السرعة',
      content: 'تغيير السرعة إلى ${_boxInMinuteController.text}؟',
      confirmColor: Colors.orange,
    );
    if (!confirm) return;

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
      _calculateExpectedEndTime();
      _showMsg('تم تحديث السرعة');
    } catch (e) {
      _showMsg('خطأ التحديث: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchSpeedHistory() async {
    if (_currentOperationId == null) return;
    final history = await supabase
        .from('Operation_Sub')
        .select()
        .eq('Operation_id', _currentOperationId!)
        .order('Operation_start', ascending: false);
    setState(() => _speedHistory = history);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalStartTime != null && mounted) {
        setState(() => _elapsed = DateTime.now().difference(_totalStartTime!));
        if (_elapsed.inSeconds % 30 == 0) _calculateFaultsAndPredict();
      }
    });
  }

  Future<bool> _showConfirmDialog({required String title, required String content, required Color confirmColor}) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor, foregroundColor: Colors.white),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showMsg(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: isError ? Colors.red : Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDisabledBySystem && !_isActive) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.block, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text('هذا الخط مشغول بعملية دمج', style: TextStyle(color: Colors.grey[600])),
        ],
      ));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (_isActive) _buildStatusCard(),
          const SizedBox(height: 20),
          _buildTextField(_serialController, 'رقم السيارة (Serial)', Icons.numbers, enabled: !_isActive),
          const SizedBox(height: 15),
          _buildTextField(_boxCountController, 'إجمالي الصناديق المطلوبة', Icons.inventory, enabled: !_isActive),
          const SizedBox(height: 15),
          _buildTextField(_boxInMinuteController, 'سرعة العمل (صندوق/د)', Icons.speed),
          
          if (_isActive) ...[
            const SizedBox(height: 20),
            if (_isFaultActive) 
              _buildTextField(_faultReasonController, 'سبب العطل المكتشف', Icons.edit_note, keyboardType: TextInputType.text),
            const SizedBox(height: 10),
            _buildButton(
              _isFaultActive ? 'إصلاح العطل وإعادة التشغيل' : 'تسجيل عطل مفاجئ', 
              _isFaultActive ? Colors.green : Colors.orange, 
              _isFaultActive ? Icons.build : Icons.warning, 
              _handleFaultToggle
            ),
          ],

          const SizedBox(height: 20),
          if (_speedChanged && _isActive)
            Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildButton('تحديث السرعة', Colors.blue, Icons.update, _updateSpeed)),
          
          if (!_isActive)
            _buildButton('بدء تشغيل السيارة', Colors.blueAccent, Icons.play_arrow, _handleStartOperation)
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

  Widget _buildStatusCard() {
    String h = _elapsed.inHours.toString().padLeft(2,'0');
    String m = (_elapsed.inMinutes%60).toString().padLeft(2,'0');
    String s = (_elapsed.inSeconds%60).toString().padLeft(2,'0');
    return Card(
      color: _isFaultActive ? Colors.red[50] : Colors.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: _isFaultActive ? Colors.red : Colors.blue)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(Icons.circle, color: _isFaultActive ? Colors.red : Colors.green, size: 12),
                  const SizedBox(width: 8),
                  Text(_isFaultActive ? 'حالة عطل' : 'قيد التشغيل', style: const TextStyle(fontWeight: FontWeight.bold)),
                ]),
                Text(intl.DateFormat('hh:mm a').format(_totalStartTime!)),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statusItem('مدة العمل', '$h:$m:$s', Icons.timer),
                _statusItem('توقفات', '$_totalStopMinutes د', Icons.error_outline, color: Colors.red),
                if (_expectedEndTime != null) _statusItem('توقع الانتهاء', intl.DateFormat('hh:mm a').format(_expectedEndTime!), Icons.event_available, color: Colors.green),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _statusItem(String l, String v, IconData i, {Color? color}) {
    return Column(children: [
      Icon(i, color: color ?? Colors.blueGrey, size: 18),
      Text(l, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      Text(v, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
    ]);
  }

  Widget _buildButton(String label, Color color, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity, height: 50,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool enabled = true, TextInputType keyboardType = TextInputType.number}) {
    return TextField(
      controller: controller, enabled: enabled, keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label, prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true, fillColor: enabled ? Colors.white : Colors.grey[100],
      ),
    );
  }

  Widget _buildSpeedHistoryList() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('سجل تغيير السرعات:', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      ..._speedHistory.map((item) => ListTile(
        dense: true,
        title: Text('سرعة: ${item['Boxs_Count_in_minute']}'),
        subtitle: Text('بدأ: ${intl.DateFormat('hh:mm a').format(DateTime.parse(item['Operation_start']).toLocal())}'),
      )).toList(),
    ]);
  }
}






// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:manageon/station/Operation/OperationFaultsLogScreen.dart';
// import 'package:manageon/station/Operation/OperationReportsScreen.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// // --- التطبيق الرئيسي مع نظام التنقل ---
// class OperationApp extends StatefulWidget {
//   const OperationApp({super.key});

//   @override
//   State<OperationApp> createState() => _OperationAppState();
// }

// class _OperationAppState extends State<OperationApp> {
//   int _currentIndex = 0;

//   final List<Widget> _pages = [
//     const OperationScreen(),
//     const ReportsScreen(), // تقرير الأداء اليومي
//     const FaultsLogScreen(), // التابة الجديدة: تقرير الأعطال
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         body: _pages[_currentIndex],
//         bottomNavigationBar: BottomNavigationBar(
//           currentIndex: _currentIndex,
//           type: BottomNavigationBarType.fixed,
//           onTap: (index) => setState(() => _currentIndex = index),
//           items: const [
//             BottomNavigationBarItem(icon: Icon(Icons.play_arrow), label: 'التشغيل'),
//             BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'الأداء'),
//             BottomNavigationBarItem(icon: Icon(Icons.history_toggle_off), label: 'سجل الأعطال'),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // --- شاشة التشغيل والتحكم ---
// class OperationScreen extends StatefulWidget {
//   const OperationScreen({super.key});

//   @override
//   State<OperationScreen> createState() => _OperationScreenState();
// }

// class _OperationScreenState extends State<OperationScreen> {
//   bool isLine1Active = false;
//   bool isLine2Active = false;
//   bool isTotalActive = false;

//   void updateLineStatus(String lineName, bool isActive) {
//     if (!mounted) return;
//     setState(() {
//       if (lineName == 'الخط الأول') isLine1Active = isActive;
//       if (lineName == 'الخط الثاني') isLine2Active = isActive;
//       if (lineName == 'دمج الخطين') isTotalActive = isActive;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool disableIndividualLines = isTotalActive;
//     bool disableTotalLine = isLine1Active || isLine2Active;

//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('لوحة التشغيل'),
//           bottom: const TabBar(
//             tabs: [
//               Tab(text: 'الخط الأول'),
//               Tab(text: 'الخط الثاني'),
//               Tab(text: 'دمج الخطين'),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             LineForm(lineName: 'الخط الأول', isDisabledBySystem: disableIndividualLines, onStatusChanged: (a) => updateLineStatus('الخط الأول', a)),
//             LineForm(lineName: 'الخط الثاني', isDisabledBySystem: disableIndividualLines, onStatusChanged: (a) => updateLineStatus('الخط الثاني', a)),
//             LineForm(lineName: 'دمج الخطين', isDisabledBySystem: disableTotalLine, onStatusChanged: (a) => updateLineStatus('دمج الخطين', a)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // --- نموذج الخط (مع حماية setState وإدارة الأعطال) ---
// class LineForm extends StatefulWidget {
//   final String lineName;
//   final bool isDisabledBySystem;
//   final Function(bool) onStatusChanged;

//   const LineForm({super.key, required this.lineName, required this.isDisabledBySystem, required this.onStatusChanged});

//   @override
//   State<LineForm> createState() => _LineFormState();
// }

// class _LineFormState extends State<LineForm> {
//   final _serialController = TextEditingController();
//   final _boxCountController = TextEditingController();
//   final _boxInMinuteController = TextEditingController();
//   final _faultReasonController = TextEditingController();

//   bool _isLoading = false;
//   bool _isActive = false;
//   bool _isFaultActive = false;
  
//   int? _currentOperationId;
//   int? _currentSubId;
//   int? _currentFaultId;
//   DateTime? _totalStartTime;
//   Timer? _timer;
//   Duration _elapsed = Duration.zero;
//   int _totalStopMinutes = 0;

//   final SupabaseClient supabase = Supabase.instance.client;

//   @override
//   void initState() {
//     super.initState();
//     _checkActiveOperation();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _serialController.dispose();
//     _boxCountController.dispose();
//     _boxInMinuteController.dispose();
//     _faultReasonController.dispose();
//     super.dispose();
//   }

//   void safeSetState(VoidCallback fn) {
//     if (mounted) setState(fn);
//   }

//   Future<void> _checkActiveOperation() async {
//     try {
//       final activeSub = await supabase.from('Operation_Sub').select('*, Operation(*)').eq('Line', widget.lineName).isFilter('Operation_end', null).maybeSingle();
//       if (activeSub != null && mounted) {
//         safeSetState(() {
//           _isActive = true;
//           _currentOperationId = activeSub['Operation_id'];
//           _currentSubId = activeSub['id'];
//           _serialController.text = activeSub['Operation']['Serial'].toString();
//           _boxCountController.text = activeSub['Operation']['Boxs_Count'].toString();
//           _boxInMinuteController.text = activeSub['Boxs_Count_in_minute'].toString();
//         });
        
//         final firstSub = await supabase.from('Operation_Sub').select().eq('Operation_id', _currentOperationId!).order('Operation_start', ascending: true).limit(1).single();
//         _totalStartTime = DateTime.parse(firstSub['Operation_start']).toLocal();
        
//         final fault = await supabase.from('Operation_fault').select().eq('Operation_id', _currentOperationId!).isFilter('End__fault', null).maybeSingle();
//         if (fault != null) safeSetState(() { _isFaultActive = true; _currentFaultId = fault['id']; });

//         widget.onStatusChanged(true);
//         _startTimer();
//         _calculateStats();
//       }
//     } catch (e) { debugPrint("CheckError: $e"); }
//   }

//   void _startTimer() {
//     _timer?.cancel();
//     _timer = Timer.periodic(const Duration(seconds: 1), (t) {
//       if (_totalStartTime != null && mounted) {
//         setState(() => _elapsed = DateTime.now().difference(_totalStartTime!));
//       } else if (!mounted) {
//         t.cancel();
//       }
//     });
//   }

//   Future<void> _calculateStats() async {
//     if (_currentOperationId == null) return;
//     final faults = await supabase.from('Operation_fault').select().eq('Operation_id', _currentOperationId!).not('End__fault', 'is', null);
//     int total = 0;
//     for (var f in faults) {
//       total += DateTime.parse(f['End__fault']).difference(DateTime.parse(f['Start_fault'])).inMinutes;
//     }
//     safeSetState(() => _totalStopMinutes = total);
//   }

//   Future<void> _handleStart() async {
//     if (_serialController.text.isEmpty || _boxCountController.text.isEmpty || _boxInMinuteController.text.isEmpty) return;
//     safeSetState(() => _isLoading = true);
//     try {
//       final op = await supabase.from('Operation').insert({'Serial': int.parse(_serialController.text), 'Boxs_Count': int.parse(_boxCountController.text)}).select().single();
//       _currentOperationId = op['id'];
//       _totalStartTime = DateTime.now();
//       final sub = await supabase.from('Operation_Sub').insert({
//         'Operation_id': _currentOperationId,
//         'Operation_start': _totalStartTime!.toUtc().toIso8601String(),
//         'Line': widget.lineName,
//         'Boxs_Count_in_minute': int.parse(_boxInMinuteController.text)
//       }).select().single();
//       _currentSubId = sub['id'];
//       safeSetState(() => _isActive = true);
//       widget.onStatusChanged(true);
//       _startTimer();
//     } catch (e) { _showMsg("Error: $e", true); }
//     finally { safeSetState(() => _isLoading = false); }
//   }

//   Future<void> _handleEnd() async {
//     if (_isFaultActive) { _showMsg("Fix fault first!", true); return; }
//     safeSetState(() => _isLoading = true);
//     try {
//       await supabase.from('Operation_Sub').update({'Operation_end': DateTime.now().toUtc().toIso8601String()}).eq('id', _currentSubId!);
//       _timer?.cancel();
//       safeSetState(() {
//         _isActive = false; _currentOperationId = null; _currentSubId = null;
//         _serialController.clear(); _boxCountController.clear(); _boxInMinuteController.clear();
//       });
//       widget.onStatusChanged(false);
//       _showMsg("Operation completed successfully");
//     } catch (e) { _showMsg("Error: $e", true); }
//     finally { safeSetState(() => _isLoading = false); }
//   }

//   Future<void> _toggleFault() async {
//     safeSetState(() => _isLoading = true);
//     try {
//       if (_isFaultActive) {
//         await supabase.from('Operation_fault').update({
//           'End__fault': DateTime.now().toUtc().toIso8601String(),
//           'Reason': _faultReasonController.text
//         }).eq('id', _currentFaultId!);
//         safeSetState(() { _isFaultActive = false; _currentFaultId = null; _faultReasonController.clear(); });
//         _calculateStats();
//       } else {
//         final f = await supabase.from('Operation_fault').insert({
//           'Operation_id': _currentOperationId,
//           'Start_fault': DateTime.now().toUtc().toIso8601String()
//         }).select().single();
//         safeSetState(() { _isFaultActive = true; _currentFaultId = f['id']; });
//       }
//     } catch (e) { _showMsg("Fault Error: $e", true); }
//     finally { safeSetState(() => _isLoading = false); }
//   }

//   void _showMsg(String m, [bool err = false]) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: err?Colors.red:Colors.green));

//   @override
//   Widget build(BuildContext context) {
//     if (widget.isDisabledBySystem && !_isActive) return const Center(child: Text("هذا الخط غير متاح"));
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         children: [
//           if (_isActive) _buildStatusHeader(),
//           const SizedBox(height: 20),
//           _input(_serialController, "السيريال", Icons.tag, enabled: !_isActive),
//           _input(_boxCountController, "إجمالي الصناديق", Icons.inventory, enabled: !_isActive),
//           _input(_boxInMinuteController, "السرعة المطلوبة", Icons.speed),
//           if (_isActive && _isFaultActive) _input(_faultReasonController, "سبب العطل", Icons.report_problem, type: TextInputType.text),
//           const SizedBox(height: 20),
//           if (_isActive) ...[
//              _btn(_isFaultActive ? "إصلاح العطل" : "تسجيل عطل", _isFaultActive ? Colors.green : Colors.orange, _toggleFault),
//              const SizedBox(height: 10),
//           ],
//           _btn(_isActive ? "إنهاء السيارة" : "بدء التشغيل", _isActive ? Colors.red : Colors.blue, _isActive ? _handleEnd : _handleStart),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusHeader() => Card(color: _isFaultActive ? Colors.red[50] : Colors.blue[50], child: Padding(padding: const EdgeInsets.all(15), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_stat("المنقضي", "${_elapsed.inMinutes} د"), _stat("أعطال", "$_totalStopMinutes د")])));
//   Widget _stat(String l, String v) => Column(children: [Text(l, style: const TextStyle(fontSize: 12)), Text(v, style: const TextStyle(fontWeight: FontWeight.bold))]);
//   Widget _input(TextEditingController c, String l, IconData i, {bool enabled = true, TextInputType type = TextInputType.number}) => Padding(padding: const EdgeInsets.only(bottom: 15), child: TextField(controller: c, enabled: enabled, keyboardType: type, decoration: InputDecoration(labelText: l, prefixIcon: Icon(i), border: const OutlineInputBorder())));
//   Widget _btn(String l, Color c, VoidCallback p) => SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _isLoading ? null : p, style: ElevatedButton.styleFrom(backgroundColor: c, foregroundColor: Colors.white), child: Text(l)));
// }
