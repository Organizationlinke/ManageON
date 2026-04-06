// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:intl/intl.dart' as intl;
// // --- التابة الجديدة: شاشة سجل الأعطال التفصيلي ---
// class FaultsLogScreen extends StatefulWidget {
//   const FaultsLogScreen({super.key});
//   @override
//   State<FaultsLogScreen> createState() => _FaultsLogScreenState();
// }

// class _FaultsLogScreenState extends State<FaultsLogScreen> {
//   final SupabaseClient supabase = Supabase.instance.client;
//   List<Map<String, dynamic>> _allFaults = [];
//   List<Map<String, dynamic>> _filteredFaults = [];
//   bool _loading = false;
//   String _selectedLine = 'الكل';
//   final List<String> _lines = ['الكل', 'الخط الأول', 'الخط الثاني', 'دمج الخطين'];
//   DateTime _selectedDate = DateTime.now();

//   @override
//   void initState() { super.initState(); _fetchFaults(); }

//   Future<void> _fetchFaults() async {
//     if (!mounted) return;
//     setState(() => _loading = true);
//     try {
//       final start = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day).toUtc().toIso8601String();
//       final end = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59).toUtc().toIso8601String();

//       // جلب الأعطال مع بيانات الخط من جدول Operation_Sub
//       final res = await supabase.from('Operation_fault')
//           .select('*, Operation(Serial, Operation_Sub(Line))')
//           .gte('Start_fault', start)
//           .lte('Start_fault', end)
//           .order('Start_fault', ascending: false);

//       List<Map<String, dynamic>> processed = [];
//       for (var f in res) {
//         final subs = f['Operation']?['Operation_Sub'] as List?;
//         String line = (subs != null && subs.isNotEmpty) ? subs.first['Line'] : 'غير معروف';
        
//         DateTime s = DateTime.parse(f['Start_fault']).toLocal();
//         DateTime? e = f['End__fault'] != null ? DateTime.parse(f['End__fault']).toLocal() : null;
//         int duration = e != null ? e.difference(s).inMinutes : 0;

//         processed.add({
//           'line': line,
//           'serial': f['Operation']?['Serial'] ?? '-',
//           'start': s,
//           'end': e,
//           'duration': duration,
//           'reason': f['Reason'] ?? 'لم يذكر'
//         });
//       }

//       if (mounted) {
//         setState(() {
//           _allFaults = processed;
//           _applyFilter();
//           _loading = false;
//         });
//       }
//     } catch (e) { 
//       debugPrint("FaultLogErr: $e");
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   void _applyFilter() {
//     setState(() {
//       if (_selectedLine == 'الكل') {
//         _filteredFaults = _allFaults;
//       } else {
//         _filteredFaults = _allFaults.where((f) => f['line'] == _selectedLine).toList();
//       }
//     });
//   }

//   int _calculateTotalDuration() {
//     return _filteredFaults.fold(0, (sum, item) => sum + (item['duration'] as int));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('سجل الأعطال التفصيلي')),
//       body: Column(
//         children: [
//           _buildFilterBar(),
//           Expanded(
//             child: _loading 
//               ? const Center(child: CircularProgressIndicator())
//               : _filteredFaults.isEmpty 
//                 ? const Center(child: Text("لا توجد أعطال مسجلة لهذا اليوم"))
//                 : _buildFaultsTable(),
//           ),
//           _buildTotalFooter(),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterBar() {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       color: Colors.blueGrey[50],
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(child: DropdownButtonFormField<String>(
//                 value: _selectedLine,
//                 decoration: const InputDecoration(labelText: 'فلترة حسب الخط', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10)),
//                 items: _lines.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
//                 onChanged: (v) { setState(() => _selectedLine = v!); _applyFilter(); },
//               )),
//               const SizedBox(width: 10),
//               ElevatedButton.icon(
//                 onPressed: () async {
//                   final d = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2023), lastDate: DateTime.now());
//                   if (d != null) { setState(() => _selectedDate = d); _fetchFaults(); }
//                 },
//                 icon: const Icon(Icons.calendar_today),
//                 label: Text(intl.DateFormat('MM/dd').format(_selectedDate)),
//               )
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFaultsTable() {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: SingleChildScrollView(
//         child: DataTable(
//           headingRowColor: WidgetStateProperty.all(Colors.red[100]),
//           columns: const [
//             DataColumn(label: Text('الخط')),
//             DataColumn(label: Text('بداية العطل')),
//             DataColumn(label: Text('نهاية العطل')),
//             DataColumn(label: Text('المدة')),
//             DataColumn(label: Text('السبب')),
//           ],
//           rows: _filteredFaults.map((f) => DataRow(cells: [
//             DataCell(Text(f['line'])),
//             DataCell(Text(intl.DateFormat('HH:mm').format(f['start']))),
//             DataCell(Text(f['end'] != null ? intl.DateFormat('HH:mm').format(f['end']) : 'مفتوح')),
//             DataCell(Text("${f['duration']} د")),
//             DataCell(SizedBox(width: 100, child: Text(f['reason'], overflow: TextOverflow.ellipsis))),
//           ])).toList(),
//         ),
//       ),
//     );
//   }

//   Widget _buildTotalFooter() {
//     return Container(
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(color: Colors.red[900], borderRadius: const BorderRadius.vertical(top: Radius.circular(15))),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Text("إجمالي وقت الأعطال:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
//           Text("${_calculateTotalDuration()} دقيقة", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart' as intl;

// --- التابة الجديدة: شاشة سجل الأعطال التفصيلي ---
class FaultsLogScreen extends StatefulWidget {
  const FaultsLogScreen({super.key});
  @override
  State<FaultsLogScreen> createState() => _FaultsLogScreenState();
}

class _FaultsLogScreenState extends State<FaultsLogScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _allFaults = [];
  List<Map<String, dynamic>> _filteredFaults = [];
  bool _loading = false;
  String _selectedLine = 'الكل';
  final List<String> _lines = ['الكل', 'الخط الأول', 'الخط الثاني', 'دمج الخطين'];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchFaults();
  }

  Future<void> _fetchFaults() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final start = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day).toUtc().toIso8601String();
      final end = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59).toUtc().toIso8601String();

      // جلب الأعطال مع بيانات الخط من جدول Operation_Sub
      final res = await supabase
          .from('Operation_fault')
          .select('*, Operation(Serial, Operation_Sub(Line))')
          .gte('Start_fault', start)
          .lte('Start_fault', end)
          .order('Start_fault', ascending: false);

      List<Map<String, dynamic>> processed = [];
      for (var f in res) {
        final subs = f['Operation']?['Operation_Sub'] as List?;
        String line = (subs != null && subs.isNotEmpty) ? subs.first['Line'] : 'غير معروف';

        DateTime s = DateTime.parse(f['Start_fault']).toLocal();
        DateTime? e = f['End__fault'] != null ? DateTime.parse(f['End__fault']).toLocal() : null;
        int duration = e != null ? e.difference(s).inMinutes : 0;

        processed.add({
          'line': line,
          'serial': f['Operation']?['Serial'] ?? '-',
          'start': s,
          'end': e,
          'duration': duration,
          'reason': f['Reason'] ?? 'لم يذكر'
        });
      }

      if (mounted) {
        setState(() {
          _allFaults = processed;
          _applyFilter();
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("FaultLogErr: $e");
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      if (_selectedLine == 'الكل') {
        _filteredFaults = _allFaults;
      } else {
        _filteredFaults = _allFaults.where((f) => f['line'] == _selectedLine).toList();
      }
    });
  }

  int _calculateTotalDuration() {
    return _filteredFaults.fold(0, (sum, item) => sum + (item['duration'] as int));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سجل الأعطال التفصيلي')),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredFaults.isEmpty
                    ? const Center(child: Text("لا توجد أعطال مسجلة لهذا اليوم"))
                    : _buildFaultsTable(),
          ),
          _buildTotalFooter(),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.blueGrey[50],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: DropdownButtonFormField<String>(
                value: _selectedLine,
                decoration: const InputDecoration(labelText: 'فلترة حسب الخط', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                items: _lines.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                onChanged: (v) {
                  setState(() => _selectedLine = v!);
                  _applyFilter();
                },
              )),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  final d = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2023), lastDate: DateTime.now());
                  if (d != null) {
                    setState(() => _selectedDate = d);
                    _fetchFaults();
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(intl.DateFormat('MM/dd').format(_selectedDate)),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFaultsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.red[100]),
          columns: const [
            DataColumn(label: Text('الخط')),
            DataColumn(label: Text('بداية العطل')),
            DataColumn(label: Text('نهاية العطل')),
            DataColumn(label: Text('المدة')),
            DataColumn(label: Text('السبب')),
          ],
          rows: _filteredFaults.map((f) => DataRow(cells: [
                DataCell(Text(f['line'])),
                // عرض التوقيت بنظام 12 ساعة
                DataCell(Text(intl.DateFormat('hh:mm a').format(f['start']))),
                DataCell(Text(f['end'] != null ? intl.DateFormat('hh:mm a').format(f['end']) : 'مفتوح')),
                DataCell(Text("${f['duration']} د")),
                DataCell(SizedBox(width: 100, child: Text(f['reason'], overflow: TextOverflow.ellipsis))),
              ])).toList(),
        ),
      ),
    );
  }

  Widget _buildTotalFooter() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.red[900], borderRadius: const BorderRadius.vertical(top: Radius.circular(15))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("إجمالي وقت الأعطال:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          Text("${_calculateTotalDuration()} دقيقة", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }
}