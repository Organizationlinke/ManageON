// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'show DateFormat;
// import 'package:supabase_flutter/supabase_flutter.dart';

// class FarzaReportScreen extends StatefulWidget {
//   const FarzaReportScreen({super.key});

//   @override
//   State<FarzaReportScreen> createState() => _FarzaReportScreenState();
// }

// class _FarzaReportScreenState extends State<FarzaReportScreen> {
//   final supabase = Supabase.instance.client;

//   DateTime fromDate = DateTime.now().subtract(const Duration(days: 30));
//   DateTime toDate = DateTime.now();
//   String? selectedCrop;

//   List<String> allColumns = ['Date', 'CarNumber', 'Company'];
//   List<String> selectedColumns = ['Date'];

//   List reportData = [];
//   bool loading = false;

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

//   num get totalNetWeight =>
//       reportData.fold(0, (s, e) => s + (e['NetWeight'] ?? 0));

//   num get totalValue =>
//       reportData.fold(0, (s, e) => s + (e['TotalValue'] ?? 0));

//   String formatNum(dynamic v) {
//     if (v == null) return '0.00';
//     return (v as num).toStringAsFixed(2);
//   }

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
//                 child: loading
//                     ? const Center(child: CircularProgressIndicator())
//                     : _table()),
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

//   Widget _filters() {
//     return Card(
//       margin: const EdgeInsets.all(8),
//       child: Padding(
//         padding: const EdgeInsets.all(8),
//         child: Wrap(
//           spacing: 12,
//           runSpacing: 8,
//           children: [
//             _datePicker('من', fromDate, (d) => setState(() => fromDate = d)),
//             _datePicker('إلى', toDate, (d) => setState(() => toDate = d)),
//             DropdownButton<String?>(
//               hint: const Text('الصنف'),
//               value: selectedCrop,
//               items: const [
//                 DropdownMenuItem(value: null, child: Text('كل الأصناف')),
//                 DropdownMenuItem(value: 'بطاطس', child: Text('بطاطس')),
//                 DropdownMenuItem(value: 'طماطم', child: Text('طماطم')),
//               ],
//               onChanged: (v) => setState(() => selectedCrop = v),
//             ),
//             // _columnSelector(),
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

//   void _showColumnsDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('اختيار الأعمدة'),
//           content: SizedBox(
//             width: 300,
//             child: ListView(
//               shrinkWrap: true,
//               children: allColumns.map((c) {
//                 return CheckboxListTile(
//                   title: Text(c),
//                   value: selectedColumns.contains(c),
//                   onChanged: (v) {
//                     setState(() {
//                       v! ? selectedColumns.add(c) : selectedColumns.remove(c);
//                     });
//                   },
//                 );
//               }).toList(),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('تم'),
//             ),
//           ],
//         );
//       },
//     );
//   }



//   Widget _table() {
//   if (reportData.isEmpty) {
//     return const Center(child: Text('لا توجد بيانات'));
//   }

//   // حساب الإجماليات
//   final totalNetWeight = reportData.fold<num>(
//     0,
//     (sum, e) => sum + ((e['NetWeight'] ?? 0) as num),
//   );

//   final totalValue = reportData.fold<num>(
//     0,
//     (sum, e) => sum + ((e['TotalValue'] ?? 0) as num),
//   );

//   final avgPrice =
//       totalNetWeight == 0 ? 0 : totalValue / totalNetWeight;

//   return SingleChildScrollView(
//     scrollDirection: Axis.horizontal,
//     child: DataTable(
//       headingRowColor: MaterialStateProperty.all(
//         Colors.grey.shade200,
//       ),
//       columns: [
//         const DataColumn(label: Text('الصنف')),
//         const DataColumn(label: Text('الكمية')),
//         const DataColumn(label: Text('متوسط السعر')),
//         const DataColumn(label: Text('القيمة')),
//         ...selectedColumns.map(
//           (c) => DataColumn(label: Text(c)),
//         ),
//       ],
//       rows: [
//         // صفوف البيانات
//         ...reportData.map<DataRow>((row) {
//           final Map<String, dynamic> extra =
//               (row['extra_columns'] ?? {}) as Map<String, dynamic>;

//           return DataRow(
//             cells: [
//               DataCell(Text(row['CropName']?.toString() ?? '')),
//               DataCell(Text(formatNum(row['NetWeight']))),
//               DataCell(Text(formatNum(row['AvgPrice']))),
//               DataCell(Text(formatNum(row['TotalValue']))),
//               ...selectedColumns.map(
//                 (c) => DataCell(
//                   Text(extra[c]?.toString() ?? ''),
//                 ),
//               ),
//             ],
//           );
//         }),

//         // صف الإجمالي
//         DataRow(
//           color: MaterialStateProperty.all(
//             Colors.lightBlue.shade50,
//           ),
//           cells: [
//             const DataCell(
//               Text(
//                 'الإجمالي',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//             DataCell(
//               Text(
//                 formatNum(totalNetWeight),
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//             DataCell(
//               Text(
//                 formatNum(avgPrice),
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//             DataCell(
//               Text(
//                 formatNum(totalValue),
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//             ...selectedColumns.map(
//               (_) => const DataCell(Text('')),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }


//   Widget _footer() {
//     return Container(
//       color: Colors.grey.shade300,
//       padding: const EdgeInsets.all(12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold)),
//           Text('الكمية: $totalNetWeight'),
//           Text('القيمة: $totalValue'),
//         ],
//       ),
//     );
//   }

//   Widget _datePicker(String label, DateTime value, Function(DateTime) onPick) {
//     return InkWell(
//       onTap: () async {
//         final d = await showDatePicker(
//           context: context,
//           firstDate: DateTime(2020),
//           lastDate: DateTime(2030),
//           initialDate: value,
//         );
//         if (d != null) onPick(d);
//       },
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text('$label: ${DateFormat('yyyy-MM-dd').format(value)}'),
//           const Icon(Icons.calendar_today, size: 16),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'show DateFormat;
import 'package:supabase_flutter/supabase_flutter.dart';

class FarzaReportScreen extends StatefulWidget {
  const FarzaReportScreen({super.key});

  @override
  State<FarzaReportScreen> createState() => _FarzaReportScreenState();
}

class _FarzaReportScreenState extends State<FarzaReportScreen> {
  final supabase = Supabase.instance.client;

  DateTime fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime toDate = DateTime.now();
  String? selectedCrop;

  /// الأعمدة
  final List<String> allColumns = ['Date', 'CarNumber', 'Company'];
  List<String> selectedColumns = [];

  /// نسخ مؤقتة للحوار
  List<String> tempSelectedColumns = [];

  /// الأصناف
  List<String> cropList = [];

  /// البيانات
  List reportData = [];
  bool loading = false;

  // final NumberFormat numFormat = NumberFormat('#,##0.00');
  // final NumberFormat numFormat = NumberFormat('#,##0.00');



// String formatNum(dynamic v) {
//   if (v == null) return '0.00';
//   return (v as num).toStringAsFixed(2);
// }




  @override
  void initState() {
    super.initState();
    loadCropNames();
    loadReport();
  }

  // ===================== تحميل الأصناف =====================
  Future<void> loadCropNames() async {
    final res = await supabase
        .from('Stations_FarzaTable')
        .select('CropName');

    final set = <String>{};
    for (final e in res) {
      if (e['CropName'] != null) {
        set.add(e['CropName']);
      }
    }

    setState(() {
      cropList = set.toList()..sort();
    });
  }

  // ===================== تحميل التقرير =====================
  Future<void> loadReport() async {
    setState(() => loading = true);

    final res = await supabase.rpc(
      'get_farza_report',
      params: {
        'p_date_from': DateFormat('yyyy-MM-dd').format(fromDate),
        'p_date_to': DateFormat('yyyy-MM-dd').format(toDate),
        'p_crop_name': selectedCrop,
        'p_columns': selectedColumns,
      },
    );

    setState(() {
      reportData = List.from(res);
      loading = false;
    });
  }

  // ===================== تنسيق الأرقام =====================
  String formatNum(dynamic v) {
    if (v == null) return '0.00';
   return (v as num).toStringAsFixed(2);
  }

  num get totalNetWeight =>
      reportData.fold(0, (s, e) => s + (e['NetWeight'] ?? 0));

  num get totalValue =>
      reportData.fold(0, (s, e) => s + (e['TotalValue'] ?? 0));

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تقرير الفرزة')),
        body: Column(
          children: [
            _filters(),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : _table(),
            ),
            _footer(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: loadReport,
          child: const Icon(Icons.search),
        ),
      ),
    );
  }

  // ===================== الفلاتر =====================
  Widget _filters() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _datePicker('من', fromDate, (d) => setState(() => fromDate = d)),
            _datePicker('إلى', toDate, (d) => setState(() => toDate = d)),

            // الأصناف من قاعدة البيانات
            DropdownButton<String?>(
              hint: const Text('الصنف'),
              value: selectedCrop,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('كل الأصناف'),
                ),
                ...cropList.map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(c),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => selectedCrop = v),
            ),

            OutlinedButton.icon(
              icon: const Icon(Icons.view_column),
              label: const Text('اختيار الأعمدة'),
              onPressed: _showColumnsDialog,
            ),
          ],
        ),
      ),
    );
  }

  // ===================== حوار الأعمدة =====================
  void _showColumnsDialog() {
    tempSelectedColumns = List.from(selectedColumns);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: const Text('اختيار الأعمدة'),
              content: SizedBox(
                width: 300,
                child: ListView(
                  shrinkWrap: true,
                  children: allColumns.map((c) {
                    return CheckboxListTile(
                      title: Text(c),
                      value: tempSelectedColumns.contains(c),
                      onChanged: (v) {
                        setLocal(() {
                          v!
                              ? tempSelectedColumns.add(c)
                              : tempSelectedColumns.remove(c);
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('تم'),
                  onPressed: () {
                    setState(() {
                      selectedColumns = List.from(tempSelectedColumns);
                    });
                    Navigator.pop(context);
                    loadReport();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ===================== الجدول =====================
  Widget _table() {
    if (reportData.isEmpty) {
      return const Center(child: Text('لا توجد بيانات'));
    }

    final avgPrice =
        totalNetWeight == 0 ? 0 : totalValue / totalNetWeight;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor:
            MaterialStateProperty.all(Colors.grey.shade200),
        columns: [
          const DataColumn(label: Text('الصنف')),
          const DataColumn(label: Text('الكمية')),
          const DataColumn(label: Text('متوسط السعر')),
          const DataColumn(label: Text('القيمة')),
          ...selectedColumns.map(
            (c) => DataColumn(label: Text(c)),
          ),
        ],
        rows: [
          ...reportData.map<DataRow>((row) {
            final Map<String, dynamic> extra =
                (row['extra_columns'] ?? {}) as Map<String, dynamic>;

            return DataRow(
              cells: [
                DataCell(Text(row['CropName'] ?? '')),
                DataCell(Text(formatNum(row['NetWeight']))),
                DataCell(Text(formatNum(row['AvgPrice']))),
                DataCell(Text(formatNum(row['TotalValue']))),
                ...selectedColumns.map(
                  (c) => DataCell(Text(extra[c]?.toString() ?? '')),
                ),
              ],
            );
          }),

          // صف الإجمالي
          DataRow(
            color: MaterialStateProperty.all(
              Colors.lightBlue.shade50,
            ),
            cells: [
              const DataCell(
                Text('الإجمالي',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataCell(Text(formatNum(totalNetWeight),
                  style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(formatNum(avgPrice),
                  style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(formatNum(totalValue),
                  style: const TextStyle(fontWeight: FontWeight.bold))),
              ...selectedColumns.map((_) => const DataCell(Text(''))),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== الفوتر =====================
  Widget _footer() {
    return Container(
      color: Colors.grey.shade300,
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('الإجمالي',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('الكمية: ${formatNum(totalNetWeight)}'),
          Text('القيمة: ${formatNum(totalValue)}'),
        ],
      ),
    );
  }

  // ===================== Date Picker =====================
  Widget _datePicker(String label, DateTime value, Function(DateTime) onPick) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          initialDate: value,
        );
        if (d != null) onPick(d);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ${DateFormat('yyyy-MM-dd').format(value)}'),
          const SizedBox(width: 4),
          const Icon(Icons.calendar_today, size: 16),
        ],
      ),
    );
  }
}
