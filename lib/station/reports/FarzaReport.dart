
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'show DateFormat;
// import 'package:manageon/global.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class FarzaReportScreen extends StatefulWidget {
//   const FarzaReportScreen({super.key});

//   @override
//   State<FarzaReportScreen> createState() => _FarzaReportScreenState();
// }

// class _FarzaReportScreenState extends State<FarzaReportScreen> {
//   final supabase = Supabase.instance.client;

//   // DateTime fromDate = DateTime.now().subtract(const Duration(days: 30));
//   DateTime fromDate = DateTime(2025, 12, 1);
//   DateTime toDate = DateTime.now();
//   String? selectedCrop;

//   /// الأعمدة
//   final List<String> allColumns = ['Date', 'CarNumber', 'Company'];
//   List<String> selectedColumns = [];

//   /// نسخ مؤقتة للحوار
//   List<String> tempSelectedColumns = [];

//   /// الأصناف
//   List<String> cropList = [];

//   /// البيانات
//   List reportData = [];
//   bool loading = false;



//   @override
//   void initState() {
//     super.initState();
//     loadCropNames();
//     loadReport();
//   }

//   // ===================== تحميل الأصناف =====================
//   Future<void> loadCropNames() async {
//     final res = await supabase
//         .from('Stations_FarzaTable')
//         .select('CropName');

//     final set = <String>{};
//     for (final e in res) {
//       if (e['CropName'] != null) {
//         set.add(e['CropName']);
//       }
//     }

//     setState(() {
//       cropList = set.toList()..sort();
//     });
//   }

//   // ===================== تحميل التقرير =====================
//   Future<void> loadReport() async {
//     setState(() => loading = true);

//     final res = await supabase.rpc(
//       'get_farza_report',
//       params: {
//         'p_date_from': DateFormat('yyyy-MM-dd').format(fromDate),
//         'p_date_to': DateFormat('yyyy-MM-dd').format(toDate),
//         'p_crop_name': selectedCrop,
//         'p_columns': selectedColumns,
//       },
//     );

//     setState(() {
//       reportData = List.from(res);
//       loading = false;
//     });
//   }

//   // ===================== تنسيق الأرقام =====================
//   String formatNum(dynamic v) {
//     if (v == null) return '0.00';
//    return (v as num).toStringAsFixed(2);
//   }

//   num get totalNetWeight =>
//       reportData.fold(0, (s, e) => s + (e['NetWeight'] ?? 0));

//   num get totalValue =>
//       reportData.fold(0, (s, e) => s + (e['TotalValue'] ?? 0));

//   // ===================== UI =====================
//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         appBar: AppBar(title: const Text('تقرير الفرزة')),
//         body: Column(
//           children: [
//             _filters(),
//             Expanded(
//               child: loading
//                   ? const Center(child: CircularProgressIndicator())
//                   : _table(),
//             ),
//             _footer(),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: loadReport,
//           child: const Icon(Icons.search),
//         ),
//       ),
//     );
//   }

//   // ===================== الفلاتر =====================
//   Widget _filters() {
//     return Card(
//       margin: const EdgeInsets.all(8),
//       child: Padding(
//         padding: const EdgeInsets.all(8),
//         child: Wrap(
//           spacing: 12,
//           runSpacing: 8,
//           children: [
//               // الأصناف من قاعدة البيانات
//             DropdownButton<String?>(
//               hint: const Text('الصنف'),
//               value: selectedCrop,
//               items: [
//                 const DropdownMenuItem(
//                   value: null,
//                   child: Text('كل الأصناف'),
//                 ),
//                 ...cropList.map(
//                   (c) => DropdownMenuItem(
//                     value: c,
//                     child: Text(c),
//                   ),
//                 ),
//               ],
//               onChanged: (v) => setState(() => selectedCrop = v),
//             ),
//             _datePicker('من', fromDate, (d) => setState(() => fromDate = d)),
//             SizedBox(width: 10,),
//             _datePicker('إلى', toDate, (d) => setState(() => toDate = d)),

          

//             OutlinedButton.icon(
//               icon: const Icon(Icons.view_column),
//               label: const Text('اختيار الأعمدة'),
//               onPressed: _showColumnsDialog,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ===================== حوار الأعمدة =====================
//   void _showColumnsDialog() {
//     tempSelectedColumns = List.from(selectedColumns);

//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setLocal) {
//             return AlertDialog(
//               title: const Text('اختيار الأعمدة'),
//               content: SizedBox(
//                 width: 300,
//                 child: ListView(
//                   shrinkWrap: true,
//                   children: allColumns.map((c) {
//                     return CheckboxListTile(
//                       title: Text(c),
//                       value: tempSelectedColumns.contains(c),
//                       onChanged: (v) {
//                         setLocal(() {
//                           v!
//                               ? tempSelectedColumns.add(c)
//                               : tempSelectedColumns.remove(c);
//                         });
//                       },
//                     );
//                   }).toList(),
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   child: const Text('تم'),
//                   onPressed: () {
//                     setState(() {
//                       selectedColumns = List.from(tempSelectedColumns);
//                     });
//                     Navigator.pop(context);
//                     loadReport();
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }


// Widget _table() {
//   if (reportData.isEmpty) {
//     return const Center(child: Text('لا توجد بيانات'));
//   }

//   final avgPrice =
//       totalNetWeight == 0 ? 0 : totalValue / totalNetWeight;

//   return Scrollbar(
//     thumbVisibility: true,
//     child: SingleChildScrollView(
//       scrollDirection: Axis.vertical, // ⬇️ رأسي
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal, // ⬅️ أفقي
//         child: DataTable(
//           headingRowColor:
//               MaterialStateProperty.all( const Color.fromARGB(255, 172, 186, 193)),
//           columns: [
//             const DataColumn(label: Text('الصنف',style: const TextStyle(fontWeight: FontWeight.bold))),
//             const DataColumn(label: Text('الكمية',style: const TextStyle(fontWeight: FontWeight.bold))),
//             const DataColumn(label: Text('متوسط السعر',style: const TextStyle(fontWeight: FontWeight.bold))),
//             const DataColumn(label: Text('القيمة',style: const TextStyle(fontWeight: FontWeight.bold))),
//             ...selectedColumns.map(
//               (c) => DataColumn(label: Text(c)),
//             ),
//           ],
//           rows: [
//             ...reportData.map<DataRow>((row) {
//               final Map<String, dynamic> extra =
//                   (row['extra_columns'] ?? {}) as Map<String, dynamic>;

//               return DataRow(
//                 cells: [
//                   DataCell(Text(row['CropName'] ?? '')),
//                   DataCell(Text(formatNum(row['NetWeight']))),
//                   DataCell(Text(formatNum(row['AvgPrice']))),
//                   DataCell(Text(formatNum(row['TotalValue']))),
//                   ...selectedColumns.map(
//                     (c) => DataCell(Text(extra[c]?.toString() ?? '')),
//                   ),
//                 ],
//               );
//             }),

//             // صف الإجمالي
//             DataRow(
//               color: MaterialStateProperty.all(
//                 const Color.fromARGB(255, 172, 186, 193),
//               ),
//               cells: [
//                 const DataCell(
//                   Text('الإجمالي',
//                       style: TextStyle(fontWeight: FontWeight.bold)),
//                 ),
//                 DataCell(Text(formatNum(totalNetWeight),
//                     style: const TextStyle(fontWeight: FontWeight.bold))),
//                 DataCell(Text(formatNum(avgPrice),
//                     style: const TextStyle(fontWeight: FontWeight.bold))),
//                 DataCell(Text(formatNum(totalValue),
//                     style: const TextStyle(fontWeight: FontWeight.bold))),
//                 ...selectedColumns.map((_) => const DataCell(Text(''))),
//               ],
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }

//   // ===================== الفوتر =====================
//   Widget _footer() {
//     return Container(
//       color: Colors.grey.shade300,
//       padding: const EdgeInsets.all(12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Text('الإجمالي',
//               style: TextStyle(fontWeight: FontWeight.bold)),
//           Text('الكمية: ${formatNum(totalNetWeight)}'),
//           Text('القيمة: ${formatNum(totalValue)}'),
//         ],
//       ),
//     );
//   }

//   // ===================== Date Picker =====================

// Widget _datePicker(String label, DateTime value, Function(DateTime) onPick) {
//   return InkWell(
//     onTap: () async {
//       final d = await showDatePicker(
//         context: context,
//         firstDate: DateTime(2020),
//         lastDate: DateTime(2030),
//         initialDate: value,
//       );
//       if (d != null) {
//         onPick(d);
//         loadReport(); // 👈 الحل هنا
//       }
//     },
//     child: Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text('$label: ${DateFormat('yyyy-MM-dd').format(value)}'),
//         const SizedBox(width: 4),
//         const Icon(Icons.calendar_today, size: 16),
//       ],
//     ),
//   );
// }
// }
import 'package:flutter/material.dart';
// نستخدم 'as intl' لتجنب التضارب مع TextDirection الخاص بـ Flutter
import 'package:intl/intl.dart' as intl;
import 'package:supabase_flutter/supabase_flutter.dart';

class FarzaReportScreen extends StatefulWidget {
  const FarzaReportScreen({super.key});

  @override
  State<FarzaReportScreen> createState() => _FarzaReportScreenState();
}

class _FarzaReportScreenState extends State<FarzaReportScreen> {
  final supabase = Supabase.instance.client;

  DateTime fromDate = DateTime(2025, 1, 1);
  DateTime toDate = DateTime.now();
  String? selectedCrop;

  final List<String> allColumns = ['Date', 'CarNumber', 'Company'];
  List<String> selectedColumns = [];
  List<String> tempSelectedColumns = [];
  List<String> cropList = [];
  List reportData = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadCropNames();
    loadReport();
  }

  // ===================== تنسيق الأرقام بالفواصل (باستخدام intl الملقب) =====================
  String formatNum(dynamic v) {
    if (v == null) return '0.00';
    // نستخدم intl.NumberFormat بدلاً من NumberFormat مباشرة لتجنب الأخطاء
    final formatter = intl.NumberFormat.decimalPattern();
    formatter.minimumFractionDigits = 2;
    formatter.maximumFractionDigits = 2;
    return formatter.format(v is num ? v : double.tryParse(v.toString()) ?? 0);
  }

  // ===================== تحميل البيانات =====================
  Future<void> loadCropNames() async {
    try {
      final res = await supabase.from('Stations_FarzaTable').select('CropName');
      final set = <String>{};
      for (final e in res) {
        if (e['CropName'] != null) set.add(e['CropName']);
      }
      setState(() {
        cropList = set.toList()..sort();
      });
    } catch (e) {
      debugPrint('Error loading crops: $e');
    }
  }

  Future<void> loadReport() async {
    setState(() => loading = true);
    try {
      final res = await supabase.rpc(
        'get_farza_report',
        params: {
          // نستخدم intl.DateFormat
          'p_date_from': intl.DateFormat('yyyy-MM-dd').format(fromDate),
          'p_date_to': intl.DateFormat('yyyy-MM-dd').format(toDate),
          'p_crop_name': selectedCrop,
          'p_columns': selectedColumns,
        },
      );
      setState(() {
        reportData = List.from(res);
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    }
  }

  num get totalNetWeight => reportData.fold(0, (s, e) => s + (e['NetWeight'] ?? 0));
  num get totalValue => reportData.fold(0, (s, e) => s + (e['TotalValue'] ?? 0));

  @override
  Widget build(BuildContext context) {
    return Directionality(
      // الآن TextDirection.rtl ستعمل بشكل صحيح لأننا عزلنا مكتبة intl
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('تقرير الفرزة'),
          elevation: 0,
          centerTitle: true,
        ),
        body: Column(
          children: [
            _filtersSection(),
            _summaryCards(),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : _tableSection(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: loadReport,
          child: const Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _filtersSection() {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    decoration: const InputDecoration(labelText: 'الصنف', border: OutlineInputBorder()),
                    value: selectedCrop,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('الكل')),
                      ...cropList.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                    ],
                    onChanged: (v) => setState(() => selectedCrop = v),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: _showColumnsDialog,
                  icon: const Icon(Icons.view_column),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _dateItem('من', fromDate, (d) => setState(() => fromDate = d)),
                _dateItem('إلى', toDate, (d) => setState(() => toDate = d)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _cardInfo('الكمية', formatNum(totalNetWeight), Colors.blue),
          const SizedBox(width: 8),
          _cardInfo('القيمة', formatNum(totalValue), Colors.green),
        ],
      ),
    );
  }

  Widget _cardInfo(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tableSection() {
    if (reportData.isEmpty) return const Center(child: Text('لا توجد بيانات'));
    final avgPrice = totalNetWeight == 0 ? 0 : totalValue / totalNetWeight;

    return Card(
      margin: const EdgeInsets.all(12),
      child: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
              columns: [
                const DataColumn(label: Text('الصنف')),
                const DataColumn(label: Text('الكمية')),
                const DataColumn(label: Text('متوسط السعر')),
                const DataColumn(label: Text('القيمة')),
                ...selectedColumns.map((c) => DataColumn(label: Text(c))),
              ],
              rows: [
                ...reportData.map((row) {
                  final Map<String, dynamic> extra = (row['extra_columns'] ?? {}) as Map<String, dynamic>;
                  return DataRow(cells: [
                    DataCell(Text(row['CropName'] ?? '')),
                    DataCell(Text(formatNum(row['NetWeight']))),
                    DataCell(Text(formatNum(row['AvgPrice']))),
                    DataCell(Text(formatNum(row['TotalValue']))),
                    ...selectedColumns.map((c) => DataCell(Text(extra[c]?.toString() ?? '-'))),
                  ]);
                }),
                DataRow(
                  color: MaterialStateProperty.all(Colors.amber[50]),
                  cells: [
                    const DataCell(Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(formatNum(totalNetWeight), style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(formatNum(avgPrice), style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(formatNum(totalValue), style: const TextStyle(fontWeight: FontWeight.bold))),
                    ...selectedColumns.map((_) => const DataCell(Text(''))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showColumnsDialog() {
    tempSelectedColumns = List.from(selectedColumns);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('الأعمدة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: allColumns.map((c) => CheckboxListTile(
              title: Text(c),
              value: tempSelectedColumns.contains(c),
              onChanged: (v) => setLocal(() => v! ? tempSelectedColumns.add(c) : tempSelectedColumns.remove(c)),
            )).toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(onPressed: () {
              setState(() => selectedColumns = List.from(tempSelectedColumns));
              Navigator.pop(context);
              loadReport();
            }, child: const Text('تطبيق')),
          ],
        ),
      ),
    );
  }

  Widget _dateItem(String label, DateTime value, Function(DateTime) onPick) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(context: context, initialDate: value, firstDate: DateTime(2020), lastDate: DateTime(2030));
        if (d != null) { onPick(d); loadReport(); }
      },
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          // نستخدم intl.DateFormat
          Text(intl.DateFormat('yyyy-MM-dd').format(value), style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}