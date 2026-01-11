
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart' as intl;
// import 'package:supabase_flutter/supabase_flutter.dart';

// class SalesInvoiceReportScreen extends StatefulWidget {
//   const SalesInvoiceReportScreen({super.key});

//   @override
//   State<SalesInvoiceReportScreen> createState() => _FarzaReportScreenState();
// }

// class _FarzaReportScreenState extends State<SalesInvoiceReportScreen> {
//   final supabase = Supabase.instance.client;

//   DateTime fromDate = DateTime(2025, 12, 1);
//   DateTime toDate = DateTime.now();
//   String? selectedCrop;
//   String? selectedClass;

//   // الخرائط لربط الاسم الإنجليزي (قاعدة البيانات) بالاسم العربي (العرض)
//   final Map<String, String> textColumnsMap = {
    
//     'Invoice_Date': 'التاريخ',
//     'Count':'الحجم',
//     'CTNType':'نوع الكرتون',
//     'CTNWeight': 'وزن الكرتون',
//     'Brand': 'الماركه',
//     'CustomerName':'العميل',
//   };

//   final Map<String, String> numericColumnsMap = {
//      'GrossWeight': 'الوزن القائم',
//     'CTNCountInPallets': 'عدد الكرتون',
//     'Pallet_Count':'عدد البالتات'
//   };

//   List<String> selectedTextCols = [];
//   List<String> selectedNumCols = [];

//   List reportData = [];
//   bool loading = false;
//   List<String> cropList = [];
//   List<String> classList = [];

//   @override
//   void initState() {
//     super.initState();
//     loadCropNames();
//     loadClass();
//     loadReport();
//   }

//   String formatNum(dynamic v, {bool isMoney = true}) {
//     if (v == null) return isMoney ? '0.00' : '0';
//     final formatter = intl.NumberFormat.decimalPattern();
//     if (isMoney) {
//       formatter.minimumFractionDigits = 2;
//       formatter.maximumFractionDigits = 2;
//     }
//     return formatter.format(v is num ? v : double.tryParse(v.toString()) ?? 0);
//   }

//   Future<void> loadCropNames() async {
//     try {
//       final res = await supabase.from('Stations_SalesInvoice').select('Items');
//       final set = <String>{};
//       for (final e in res) {
//         if (e['Items'] != null) set.add(e['Items']);
//       }
//       setState(() => cropList = set.toList()..sort());
//     } catch (e) {
//       debugPrint('Error: $e');
//     }
//   }
//  Future<void> loadClass() async {
//     try {
//       final res = await supabase.from('Stations_SalesInvoice').select('Class');
//       final set = <String>{};
//       for (final e in res) {
//         if (e['Class'] != null) set.add(e['Class']);
//       }
//       setState(() => classList = set.toList()..sort());
//     } catch (e) {
//       debugPrint('Error: $e');
//     }
//   }

//   Future<void> loadReport() async {
//     setState(() => loading = true);
//     try {
//       final res = await supabase.rpc(
//         'get_salesinvoice_report',
//         params: {
//           'p_date_from': intl.DateFormat('yyyy-MM-dd').format(fromDate),
//           'p_date_to': intl.DateFormat('yyyy-MM-dd').format(toDate),
//           'p_crop_name': selectedCrop,
//           'p_crop_class': selectedClass,
//           'p_group_columns': selectedTextCols,
//           'p_sum_columns': selectedNumCols,
//         },
//       );
//       setState(() {
//         reportData = List.from(res);
//         loading = false;
//       });
//     } catch (e) {
//       setState(() => loading = false);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('خطأ في تحميل التقرير: $e')),
//         );
//       }
//     }
//   }

//   num get totalNetWeight => reportData.fold(0, (s, e) => s + (e['net_weight'] ?? 0));
//   num get totalValue => reportData.fold(0, (s, e) => s + (e['total_value'] ?? 0));
//   num get totalcontainer => reportData.fold(0, (s, e) => s + (e['container_count'] ?? 0));

//   num sumNumericColumn(String columnName) {
//     if (reportData.isEmpty) return 0;
//     return reportData.fold(0, (s, e) {
//       final extra = e['extra_columns'] as Map<String, dynamic>? ?? {};
//       final val = extra[columnName];
//       return s + (val is num ? val : (double.tryParse(val?.toString() ?? '0') ?? 0));
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         backgroundColor: Colors.grey[100],
//         appBar: AppBar(title: const Text('تقرير المبيعات'), centerTitle: true),
//         body: Column(
//           children: [
//             _filtersSection(),
//             _summaryCards(),
//             Expanded(
//               child: loading
//                   ? const Center(child: CircularProgressIndicator())
//                   : _tableSection(),
//             ),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: loadReport,
//           child: const Icon(Icons.search),
//         ),
//       ),
//     );
//   }

//   Widget _filtersSection() {
//     return Card(
//       margin: const EdgeInsets.all(12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: DropdownButtonFormField<String?>(
//                     decoration: const InputDecoration(labelText: 'الصنف', border: OutlineInputBorder()),
//                     value: selectedCrop,
//                     items: [
//                       const DropdownMenuItem(value: null, child: Text('الكل')),
//                       ...cropList.map((c) => DropdownMenuItem(value: c, child: Text(c))),
//                     ],
//                     onChanged: (v) => setState(() => selectedCrop = v),
//                   ),
//                 ),
//                   Expanded(
//                   child: DropdownButtonFormField<String?>(
//                     decoration: const InputDecoration(labelText: 'الدرجة', border: OutlineInputBorder()),
//                     value: selectedClass,
//                     items: [
//                       const DropdownMenuItem(value: null, child: Text('الكل')),
//                       ...classList.map((c) => DropdownMenuItem(value: c, child: Text(c))),
//                     ],
//                     onChanged: (v) => setState(() => selectedClass = v),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton.filledTonal(
//                   onPressed: _showColumnsOptions,
//                   icon: const Icon(Icons.settings),
//                   tooltip: 'إعدادات الأعمدة',
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _dateItem('من', fromDate, (d) => setState(() => fromDate = d)),
//                 _dateItem('إلى', toDate, (d) => setState(() => toDate = d)),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _summaryCards() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       child: Row(
//         children: [
//           _cardInfo('إجمالي الكمية', formatNum(totalNetWeight), Colors.blue),
//           const SizedBox(width: 8),
//           _cardInfo('إجمالي القيمة', formatNum(totalValue), Colors.green),
//            const SizedBox(width: 8),
//           _cardInfo('إجمالي الحاويات', formatNum(totalcontainer), Colors.green),
//         ],
//       ),
//     );
//   }

//   Widget _cardInfo(String title, String value, Color color) {
//     return Expanded(
//       child: Card(
//         color: color.withOpacity(0.1),
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             children: [
//               Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
//               Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _tableSection() {
//     if (reportData.isEmpty) return const Center(child: Text('لا توجد بيانات متاحة'));
//     final avgPrice = totalNetWeight == 0 ? 0 : totalValue / totalNetWeight;

//     return Card(
//       margin: const EdgeInsets.all(12),
//       child: Scrollbar(
//         child: SingleChildScrollView(
//           scrollDirection: Axis.vertical,
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: DataTable(
//               headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
//               columns: [
//                 const DataColumn(label: Text('الصنف')),
//                 const DataColumn(label: Text('الدرجة')),
//                 const DataColumn(label: Text('الكمية')),
//                 const DataColumn(label: Text('متوسط السعر')),
//                 const DataColumn(label: Text('القيمة')),
//                 const DataColumn(label: Text('عدد الحاويات')),
//                 // جلب الاسم العربي للأعمدة النصية المختارة
//                 ...selectedTextCols.map((c) => DataColumn(label: Text(textColumnsMap[c] ?? c))),
//                 // جلب الاسم العربي للأعمدة الرقمية المختارة
//                 ...selectedNumCols.map((c) => DataColumn(label: Text(numericColumnsMap[c] ?? c))),
//               ],
//               rows: [
//                 ...reportData.map((row) {
//                   final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
//                   return DataRow(cells: [
//                     DataCell(Text(row['crop_name'] ?? '')),
//                     DataCell(Text(row['class'] ?? '')),
//                     DataCell(Text(formatNum(row['net_weight']))),
//                     DataCell(Text(formatNum(row['avg_price']))),
//                     DataCell(Text(formatNum(row['total_value']))),
//                     DataCell(Text(formatNum(row['container_count']))),
//                     ...selectedTextCols.map((c) => DataCell(Text(extra[c]?.toString() ?? '-'))),
//                     ...selectedNumCols.map((c) => DataCell(Text(formatNum(extra[c])))),
//                   ]);
//                 }),
//                 DataRow(
//   color: MaterialStateProperty.all(Colors.amber[50]),
//   cells: [
//     const DataCell(Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold))),
//     const DataCell(Text('-')), // ← الدرجة
//     DataCell(Text(formatNum(totalNetWeight), style: const TextStyle(fontWeight: FontWeight.bold))),
//     DataCell(Text(formatNum(avgPrice), style: const TextStyle(fontWeight: FontWeight.bold))),
//     DataCell(Text(formatNum(totalValue), style: const TextStyle(fontWeight: FontWeight.bold))),
//     DataCell(Text(formatNum(totalcontainer), style: const TextStyle(fontWeight: FontWeight.bold))),
//     ...selectedTextCols.map((_) => const DataCell(Text(''))),
//     ...selectedNumCols.map((c) => DataCell(
//           Text(formatNum(sumNumericColumn(c)),
//           style: const TextStyle(fontWeight: FontWeight.bold)),
//         )),
//   ],
// ),

          
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showColumnsOptions() {
//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setLocal) => AlertDialog(
//           title: const Text('إعدادات الأعمدة'),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('أعمدة النصوص (تفصيلية):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
//                 // استخدام الخريطة لعرض الاسم العربي
//                 ...textColumnsMap.entries.map((entry) => CheckboxListTile(
//                   title: Text(entry.value), // الاسم العربي
//                   value: selectedTextCols.contains(entry.key),
//                   onChanged: (v) => setLocal(() => v! ? selectedTextCols.add(entry.key) : selectedTextCols.remove(entry.key)),
//                 )),
//                 const Divider(),
//                 const Text('أعمدة الأرقام (مجاميع):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
//                 // استخدام الخريطة لعرض الاسم العربي
//                 ...numericColumnsMap.entries.map((entry) => CheckboxListTile(
//                   title: Text(entry.value), // الاسم العربي
//                   value: selectedNumCols.contains(entry.key),
//                   onChanged: (v) => setLocal(() => v! ? selectedNumCols.add(entry.key) : selectedNumCols.remove(entry.key)),
//                 )),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
//             ElevatedButton(onPressed: () {
//               Navigator.pop(context);
//               loadReport();
//             }, child: const Text('تطبيق')),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _dateItem(String label, DateTime value, Function(DateTime) onPick) {
//     return InkWell(
//       onTap: () async {
//         final d = await showDatePicker(context: context, initialDate: value, firstDate: DateTime(2020), lastDate: DateTime(2030));
//         if (d != null) { onPick(d); loadReport(); }
//       },
//       child: Column(
//         children: [
//           Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
//           Text(intl.DateFormat('yyyy-MM-dd').format(value), style: const TextStyle(fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesInvoiceReportScreen extends StatefulWidget {
  const SalesInvoiceReportScreen({super.key});

  @override
  State<SalesInvoiceReportScreen> createState() => _SalesInvoiceReportScreenState();
}

class _SalesInvoiceReportScreenState extends State<SalesInvoiceReportScreen> {
  final supabase = Supabase.instance.client;

  DateTime fromDate = DateTime(2025, 12, 1);
  DateTime toDate = DateTime.now();
  String? selectedCrop;
  String? selectedClass;

  final Map<String, String> textColumnsMap = {
    'Invoice_Date': 'التاريخ',
    'Count': 'الحجم',
    'CTNType': 'نوع الكرتون',
    'CTNWeight': 'وزن الكرتون',
    'Brand': 'الماركه',
    'CustomerName': 'العميل',
  };

  final Map<String, String> numericColumnsMap = {
    'GrossWeight': 'الوزن القائم',
    'CTNCountInPallets': 'عدد الكرتون',
    'Pallet_Count': 'عدد البالتات'
  };

  List<String> selectedTextCols = [];
  List<String> selectedNumCols = [];

  List rawData = [];
  List mergedData = [];
  List filteredData = [];
  bool loading = false;
  List<String> cropList = [];
  List<String> classList = [];

  Map<String, List<String>> activeFilters = {};

  @override
  void initState() {
    super.initState();
    _loadSavedSettings().then((_) {
      loadCropNames();
      loadClass();
      loadReport();
    });
  }

  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedTextCols = prefs.getStringList('sales_selectedTextCols') ?? [];
      selectedNumCols = prefs.getStringList('sales_selectedNumCols') ?? [];
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('sales_selectedTextCols', selectedTextCols);
    await prefs.setStringList('sales_selectedNumCols', selectedNumCols);
  }

  String formatNum(dynamic v, {bool isMoney = true}) {
    if (v == null) return isMoney ? '0.00' : '0';
    final formatter = intl.NumberFormat.decimalPattern();
    if (isMoney) {
      formatter.minimumFractionDigits = 2;
      formatter.maximumFractionDigits = 2;
    }
    return formatter.format(v is num ? v : double.tryParse(v.toString()) ?? 0);
  }

  Future<void> loadCropNames() async {
    try {
      final res = await supabase.from('Stations_SalesInvoice').select('Items');
      final set = <String>{};
      for (final e in res) if (e['Items'] != null) set.add(e['Items']);
      setState(() => cropList = set.toList()..sort());
    } catch (e) { debugPrint('Error: $e'); }
  }

  Future<void> loadClass() async {
    try {
      final res = await supabase.from('Stations_SalesInvoice').select('Class');
      final set = <String>{};
      for (final e in res) if (e['Class'] != null) set.add(e['Class']);
      setState(() => classList = set.toList()..sort());
    } catch (e) { debugPrint('Error: $e'); }
  }

  Future<void> loadReport() async {
    setState(() => loading = true);
    try {
      final res = await supabase.rpc(
        'get_salesinvoice_report',
        params: {
          'p_date_from': intl.DateFormat('yyyy-MM-dd').format(fromDate),
          'p_date_to': intl.DateFormat('yyyy-MM-dd').format(toDate),
          'p_crop_name': selectedCrop,
          'p_crop_class': selectedClass,
          'p_group_columns': selectedTextCols,
          'p_sum_columns': selectedNumCols,
        },
      );
      setState(() {
        rawData = List.from(res);
        _processAndMergeData();
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    }
  }

  void _processAndMergeData() {
    Map<String, Map<String, dynamic>> grouped = {};

    for (var row in rawData) {
      final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
      String groupKey = "${row['crop_name']}_${row['class']}";
      for (var col in selectedTextCols) groupKey += "_${extra[col] ?? ''}";

      if (!grouped.containsKey(groupKey)) {
        grouped[groupKey] = {
          'crop_name': row['crop_name'],
          'class': row['class'],
          'net_weight': (row['net_weight'] ?? 0) as num,
          'total_value': (row['total_value'] ?? 0) as num,
          'container_count': (row['container_count'] ?? 0) as num,
          'extra_columns': Map<String, dynamic>.from(extra),
        };
      } else {
        grouped[groupKey]!['net_weight'] += (row['net_weight'] ?? 0) as num;
        grouped[groupKey]!['total_value'] += (row['total_value'] ?? 0) as num;
        grouped[groupKey]!['container_count'] += (row['container_count'] ?? 0) as num;

        Map<String, dynamic> existingExtra = grouped[groupKey]!['extra_columns'];
        for (var numCol in selectedNumCols) {
          num val = num.tryParse(extra[numCol]?.toString() ?? '0') ?? 0;
          num current = num.tryParse(existingExtra[numCol]?.toString() ?? '0') ?? 0;
          existingExtra[numCol] = current + val;
        }
      }
    }
    mergedData = grouped.values.toList();
    _applyLocalFilters();
  }

  void _applyLocalFilters() {
    setState(() {
      filteredData = mergedData.where((row) {
        bool match = true;
        final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
        activeFilters.forEach((colKey, selectedValues) {
          if (selectedValues.isNotEmpty) {
            String rowValue = (colKey == 'crop_name' ? row['crop_name'] : (colKey == 'class' ? row['class'] : extra[colKey]))?.toString() ?? "";
            if (!selectedValues.contains(rowValue)) match = false;
          }
        });
        return match;
      }).toList();
    });
  }

  num get currentNetWeight => filteredData.fold(0.0, (s, e) => s + (e['net_weight'] ?? 0));
  num get currentValue => filteredData.fold(0.0, (s, e) => s + (e['total_value'] ?? 0));
  num get currentContainers => filteredData.fold(0.0, (s, e) => s + (e['container_count'] ?? 0));

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(title: const Text('تقرير المبيعات'), centerTitle: true),
        body: Column(
          children: [
            _filtersSection(),
            _summaryCards(),
            Expanded(
              child: loading ? const Center(child: CircularProgressIndicator()) : _tableSection(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(onPressed: loadReport, child: const Icon(Icons.search)),
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
                    items: [const DropdownMenuItem(value: null, child: Text('الكل')), ...cropList.map((c) => DropdownMenuItem(value: c, child: Text(c)))],
                    onChanged: (v) => setState(() => selectedCrop = v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    decoration: const InputDecoration(labelText: 'الدرجة', border: OutlineInputBorder()),
                    value: selectedClass,
                    items: [const DropdownMenuItem(value: null, child: Text('الكل')), ...classList.map((c) => DropdownMenuItem(value: c, child: Text(c)))],
                    onChanged: (v) => setState(() => selectedClass = v),
                  ),
                ),
                IconButton(onPressed: _showColumnsOptions, icon: const Icon(Icons.view_column_rounded)),
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
          _cardInfo('الوزن', formatNum(currentNetWeight), Colors.blue),
          _cardInfo('القيمة', formatNum(currentValue), Colors.green),
          _cardInfo('الحاويات', formatNum(currentContainers, isMoney: false), Colors.orange),
        ],
      ),
    );
  }

  Widget _cardInfo(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.05),
        elevation: 0,
        shape: RoundedRectangleBorder(side: BorderSide(color: color.withOpacity(0.2)), borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(children: [Text(title, style: TextStyle(color: color, fontSize: 11)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]),
        ),
      ),
    );
  }

  Widget _tableSection() {
    if (filteredData.isEmpty && !loading) return const Center(child: Text('لا توجد بيانات'));
    final avgPrice = currentNetWeight == 0 ? 0 : currentValue / currentNetWeight;

    return Card(
      margin: const EdgeInsets.all(12),
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.blueGrey[50]),
              columns: [
                DataColumn(label: _buildFilterHeader('الصنف', 'crop_name')),
                DataColumn(label: _buildFilterHeader('الدرجة', 'class')),
                const DataColumn(label: Text('الكمية')),
                const DataColumn(label: Text('م. السعر')),
                const DataColumn(label: Text('القيمة')),
                const DataColumn(label: Text('حاويات')),
                ...selectedTextCols.map((c) => DataColumn(label: _buildFilterHeader(textColumnsMap[c] ?? c, c))),
                ...selectedNumCols.map((c) => DataColumn(label: Text(numericColumnsMap[c] ?? c))),
              ],
              rows: [
                ...filteredData.map((row) {
                  final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
                  num rowW = row['net_weight'] ?? 0;
                  num rowV = row['total_value'] ?? 0;
                  return DataRow(cells: [
                    DataCell(Text(row['crop_name'] ?? '')),
                    DataCell(Text(row['class'] ?? '')),
                    DataCell(Text(formatNum(rowW))),
                    DataCell(Text(formatNum(rowW == 0 ? 0 : rowV / rowW))),
                    DataCell(Text(formatNum(rowV))),
                    DataCell(Text(formatNum(row['container_count'], isMoney: false))),
                    ...selectedTextCols.map((c) => DataCell(Text(extra[c]?.toString() ?? '-'))),
                    ...selectedNumCols.map((c) => DataCell(Text(formatNum(extra[c])))),
                  ]);
                }),
                DataRow(
                  color: WidgetStateProperty.all(Colors.amber[50]),
                  cells: [
                    const DataCell(Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataCell(Text('')),
                    DataCell(Text(formatNum(currentNetWeight), style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(formatNum(avgPrice), style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(formatNum(currentValue), style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(formatNum(currentContainers, isMoney: false), style: const TextStyle(fontWeight: FontWeight.bold))),
                    ...selectedTextCols.map((_) => const DataCell(Text(''))),
                    ...selectedNumCols.map((c) => DataCell(
                      Text(
                        formatNum(
                          filteredData.fold<num>(0.0, (s, e) {
                            final val = e['extra_columns'][c];
                            return s + (num.tryParse(val?.toString() ?? '0') ?? 0);
                          })
                        ), 
                        style: const TextStyle(fontWeight: FontWeight.bold)
                      )
                    )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterHeader(String title, String colKey) {
    bool isFiltered = activeFilters[colKey]?.isNotEmpty ?? false;
    return InkWell(
      onTap: () => _showFilterDialog(title, colKey),
      child: Row(children: [Text(title), Icon(Icons.filter_alt, size: 12, color: isFiltered ? Colors.blue : Colors.grey)]),
    );
  }

  void _showFilterDialog(String title, String colKey) {
    Set<String> uniqueVals = {};
    for (var row in mergedData) uniqueVals.add((colKey == 'crop_name' ? row['crop_name'] : (colKey == 'class' ? row['class'] : row['extra_columns'][colKey]))?.toString() ?? "");
    List<String> sortedList = uniqueVals.where((v) => v.isNotEmpty).toList()..sort();
    List<String> tempSelected = List.from(activeFilters[colKey] ?? []);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setD) => AlertDialog(
        title: Text('فلترة $title'),
        content: SizedBox(width: 300, child: ListView(shrinkWrap: true, children: sortedList.map((v) => CheckboxListTile(title: Text(v), value: tempSelected.contains(v), onChanged: (c) => setD(() => c! ? tempSelected.add(v) : tempSelected.remove(v)))).toList())),
        actions: [
          TextButton(onPressed: () { setState(() => activeFilters[colKey] = []); Navigator.pop(context); _applyLocalFilters(); }, child: const Text('مسح')),
          ElevatedButton(onPressed: () { setState(() => activeFilters[colKey] = tempSelected); Navigator.pop(context); _applyLocalFilters(); }, child: const Text('تطبيق')),
        ],
      )),
    );
  }

  void _showColumnsOptions() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setL) => AlertDialog(
        title: const Text('إعدادات الأعمدة'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('نصوص:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...textColumnsMap.entries.map((e) => CheckboxListTile(title: Text(e.value), value: selectedTextCols.contains(e.key), onChanged: (v) => setL(() => v! ? selectedTextCols.add(e.key) : selectedTextCols.remove(e.key)))),
          const Divider(),
          const Text('أرقام:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...numericColumnsMap.entries.map((e) => CheckboxListTile(title: Text(e.value), value: selectedNumCols.contains(e.key), onChanged: (v) => setL(() => v! ? selectedNumCols.add(e.key) : selectedNumCols.remove(e.key)))),
        ])),
        actions: [ElevatedButton(onPressed: () { _saveSettings(); Navigator.pop(context); loadReport(); }, child: const Text('حفظ وتطبيق'))],
      )),
    );
  }

  Widget _dateItem(String label, DateTime value, Function(DateTime) onPick) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(context: context, initialDate: value, firstDate: DateTime(2020), lastDate: DateTime(2030));
        if (d != null) { onPick(d); loadReport(); }
      },
      child: Column(children: [Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)), Text(intl.DateFormat('yyyy-MM-dd').format(value), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))]),
    );
  }
}