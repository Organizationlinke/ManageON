

// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart' as intl;
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import 'package:shared_preferences/shared_preferences.dart';

// // class ProductionReportScreen extends StatefulWidget {
// //   const ProductionReportScreen({super.key});

// //   @override
// //   State<ProductionReportScreen> createState() => _ProductionReportScreenState();
// // }

// // class _ProductionReportScreenState extends State<ProductionReportScreen> {
// //   final supabase = Supabase.instance.client;

// //   DateTime fromDate = DateTime(2025, 12, 1);
// //   DateTime toDate = DateTime.now();
// //   String? selectedCrop;
// //   String? selectedClass;

// //   final Map<String, String> textColumnsMap = {
// //     'ProductionDate': 'التاريخ',
// //     'ItemsCount': 'الحجم',
// //     'CTNType': 'نوع الكرتون',
// //     'CTNWeight': 'وزن الكرتون',
// //     'Brand': 'الماركه',
// //     'Country':'الدولة',
// //     'CustomerName': 'العميل',
// //     'Order_Number': 'رقم الاوردر'
// //   };

// //   final Map<String, String> numericColumnsMap = {
// //     'PalletCount': 'عدد البالتات',
// //     'CTNCountInPallets':'عدد الكرتون'
// //   };

// //   List<String> selectedTextCols = [];
// //   List<String> selectedNumCols = [];

// //   List reportData = [];
// //   bool loading = false;
// //   List<String> cropList = [];
// //   List<String> classList = [];

// //   // خريطة لتخزين القيم المختارة للفلترة
// //   Map<String, List<String>> columnFilters = {};

// //   @override
// //   void initState() {
// //     super.initState();
// //     _initData();
// //   }

// //   Future<void> _initData() async {
// //     await _loadSavedSettings();
// //     loadCropNames();
// //     loadClass();
// //     loadReport();
// //   }

// //   // تحميل الإعدادات المحفوظة للأعمدة
// //   Future<void> _loadSavedSettings() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     setState(() {
// //       selectedTextCols = prefs.getStringList('prod_selectedTextCols') ?? [];
// //       selectedNumCols = prefs.getStringList('prod_selectedNumCols') ?? [];
// //     });
// //   }

// //   // حفظ إعدادات الأعمدة
// //   Future<void> _saveSettings() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     await prefs.setStringList('prod_selectedTextCols', selectedTextCols);
// //     await prefs.setStringList('prod_selectedNumCols', selectedNumCols);
// //   }

// //   // تصفية البيانات محلياً بناءً على الفلاتر المختارة
// //   List get filteredData {
// //     if (columnFilters.isEmpty) return reportData;
// //     return reportData.where((row) {
// //       bool match = true;
// //       final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};

// //       columnFilters.forEach((key, selectedValues) {
// //         if (selectedValues.isEmpty) return;
        
// //         String cellValue = '';
// //         if (key == 'crop_name') {
// //           cellValue = row['crop_name']?.toString() ?? '';
// //         } else if (key == 'class') {
// //           cellValue = row['class']?.toString() ?? '';
// //         } else {
// //           cellValue = extra[key]?.toString() ?? '';
// //         }

// //         if (!selectedValues.contains(cellValue)) {
// //           match = false;
// //         }
// //       });
// //       return match;
// //     }).toList();
// //   }

// //   String formatNum(dynamic v, {bool isMoney = true}) {
// //     if (v == null) return isMoney ? '0.00' : '0';
// //     final formatter = intl.NumberFormat.decimalPattern();
// //     if (isMoney) {
// //       formatter.minimumFractionDigits = 2;
// //       formatter.maximumFractionDigits = 2;
// //     }
// //     return formatter.format(v is num ? v : double.tryParse(v.toString()) ?? 0);
// //   }

// //   // تحسين الدوال الحسابية لتجنب خطأ الأنواع
// //   num get totalNetWeight => filteredData.fold<num>(0.0, (s, e) => s + (e['net_weight'] ?? 0));
// //   num get totalValue => filteredData.fold<num>(0.0, (s, e) => s + (e['total_value'] ?? 0));

// //   num sumNumericColumn(String columnName) {
// //     return filteredData.fold<num>(0.0, (s, e) {
// //       final extra = e['extra_columns'] as Map<String, dynamic>? ?? {};
// //       final val = extra[columnName];
// //       return s + (val is num ? val : (double.tryParse(val?.toString() ?? '0') ?? 0));
// //     });
// //   }

// //   Future<void> loadCropNames() async {
// //     try {
// //       final res = await supabase.from('Stations_ProductionCost').select('Items');
// //       final set = <String>{};
// //       for (final e in res) if (e['Items'] != null) set.add(e['Items']);
// //       setState(() => cropList = set.toList()..sort());
// //     } catch (e) { debugPrint('Error: $e'); }
// //   }

// //   Future<void> loadClass() async {
// //     try {
// //       final res = await supabase.from('Stations_ProductionCost').select('Class');
// //       final set = <String>{};
// //       for (final e in res) if (e['Class'] != null) set.add(e['Class']);
// //       setState(() => classList = set.toList()..sort());
// //     } catch (e) { debugPrint('Error: $e'); }
// //   }

// //   Future<void> loadReport() async {
// //     setState(() => loading = true);
// //     // تم حذف columnFilters.clear() لضمان بقاء الفلتر عند التحديث
// //     try {
// //       final res = await supabase.rpc(
// //         'get_production_report',
// //         params: {
// //           'p_date_from': intl.DateFormat('yyyy-MM-dd').format(fromDate),
// //           'p_date_to': intl.DateFormat('yyyy-MM-dd').format(toDate),
// //           'p_crop_name': selectedCrop,
// //           'p_crop_class': selectedClass,
// //           'p_group_columns': selectedTextCols,
// //           'p_sum_columns': selectedNumCols,
// //         },
// //       );
// //       setState(() {
// //         reportData = List.from(res);
// //         loading = false;
// //       });
// //     } catch (e) {
// //       setState(() => loading = false);
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
// //       }
// //     }
// //   }

// //   List<String> _getUniqueValuesForColumn(String key) {
// //     final set = <String>{};
// //     for (var row in reportData) {
// //       final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
// //       String val = '';
// //       if (key == 'crop_name') val = row['crop_name']?.toString() ?? '';
// //       else if (key == 'class') val = row['class']?.toString() ?? '';
// //       else val = extra[key]?.toString() ?? '';
// //       if (val.isNotEmpty) set.add(val);
// //     }
// //     return set.toList()..sort();
// //   }

// //   void _showFilterDialog(String label, String filterKey) {
// //     final uniqueValues = _getUniqueValuesForColumn(filterKey);
// //     List<String> tempSelected = List.from(columnFilters[filterKey] ?? []);

// //     showDialog(
// //       context: context,
// //       builder: (context) => StatefulBuilder(
// //         builder: (context, setLocalState) => AlertDialog(
// //           title: Text('تصفية: $label'),
// //           content: SizedBox(
// //             width: 300,
// //             child: uniqueValues.isEmpty 
// //               ? const Padding(padding: EdgeInsets.all(16.0), child: Text('لا توجد قيم'))
// //               : ListView.builder(
// //                   shrinkWrap: true,
// //                   itemCount: uniqueValues.length,
// //                   itemBuilder: (context, index) {
// //                     final val = uniqueValues[index];
// //                     return CheckboxListTile(
// //                       title: Text(val),
// //                       value: tempSelected.contains(val),
// //                       onChanged: (bool? checked) => setLocalState(() => checked! ? tempSelected.add(val) : tempSelected.remove(val)),
// //                     );
// //                   },
// //                 ),
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () {
// //                 setState(() => columnFilters.remove(filterKey));
// //                 Navigator.pop(context);
// //               },
// //               child: const Text('مسح'),
// //             ),
// //             ElevatedButton(
// //               onPressed: () {
// //                 setState(() => tempSelected.isEmpty ? columnFilters.remove(filterKey) : columnFilters[filterKey] = tempSelected);
// //                 Navigator.pop(context);
// //               },
// //               child: const Text('تطبيق'),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Directionality(
// //       textDirection: TextDirection.rtl,
// //       child: Scaffold(
// //         backgroundColor: Colors.grey[100],
// //         appBar: AppBar(title: const Text('تقرير الانتاج'), centerTitle: true),
// //         body: Column(
// //           children: [
// //             _filtersSection(),
// //             _summaryCards(),
// //             Expanded(
// //               child: loading ? const Center(child: CircularProgressIndicator()) : _tableSection(),
// //             ),
// //           ],
// //         ),
// //         floatingActionButton: FloatingActionButton(onPressed: loadReport, child: const Icon(Icons.search)),
// //       ),
// //     );
// //   }

// //   Widget _filtersSection() {
// //     return Card(
// //       margin: const EdgeInsets.all(12),
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           children: [
// //             Row(
// //               children: [
// //                 Expanded(
// //                   child: DropdownButtonFormField<String?>(
// //                     decoration: const InputDecoration(labelText: 'الصنف', border: OutlineInputBorder()),
// //                     value: selectedCrop,
// //                     items: [const DropdownMenuItem(value: null, child: Text('الكل')), ...cropList.map((c) => DropdownMenuItem(value: c, child: Text(c)))],
// //                     onChanged: (v) => setState(() => selectedCrop = v),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 8),
// //                 Expanded(
// //                   child: DropdownButtonFormField<String?>(
// //                     decoration: const InputDecoration(labelText: 'الدرجة', border: OutlineInputBorder()),
// //                     value: selectedClass,
// //                     items: [const DropdownMenuItem(value: null, child: Text('الكل')), ...classList.map((c) => DropdownMenuItem(value: c, child: Text(c)))],
// //                     onChanged: (v) => setState(() => selectedClass = v),
// //                   ),
// //                 ),
// //                 IconButton.filledTonal(onPressed: _showColumnsOptions, icon: const Icon(Icons.settings)),
// //               ],
// //             ),
// //             const SizedBox(height: 12),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceAround,
// //               children: [
// //                 _dateItem('من', fromDate, (d) => setState(() => fromDate = d)),
// //                 _dateItem('إلى', toDate, (d) => setState(() => toDate = d)),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _summaryCards() {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 12),
// //       child: Row(
// //         children: [
// //           _cardInfo('إجمالي الكمية', formatNum(totalNetWeight), Colors.blue),
// //           const SizedBox(width: 8),
// //           _cardInfo('إجمالي القيمة', formatNum(totalValue), Colors.green),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _cardInfo(String title, String value, Color color) {
// //     return Expanded(
// //       child: Card(
// //         color: color.withOpacity(0.1),
// //         elevation: 0,
// //         shape: RoundedRectangleBorder(side: BorderSide(color: color.withOpacity(0.2)), borderRadius: BorderRadius.circular(10)),
// //         child: Padding(
// //           padding: const EdgeInsets.all(12),
// //           child: Column(
// //             children: [
// //               Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
// //               Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   DataColumn _textColumn(String label, String filterKey) {
// //     final bool isFiltered = columnFilters.containsKey(filterKey);
// //     return DataColumn(
// //       label: Row(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
// //           const SizedBox(width: 4),
// //           InkWell(
// //             onTap: () => _showFilterDialog(label, filterKey),
// //             child: Icon(Icons.filter_alt, size: 14, color: isFiltered ? Colors.blue : Colors.grey),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   DataColumn _numericColumn(String label) => DataColumn(label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)));

// //   Widget _tableSection() {
// //     final data = filteredData;
// //     if (data.isEmpty && reportData.isNotEmpty) return const Center(child: Text('لا توجد نتائج تطابق الفلتر'));
// //     if (data.isEmpty) return const Center(child: Text('لا توجد بيانات'));
    
// //     final avgPrice = totalNetWeight == 0 ? 0 : totalValue / totalNetWeight;

// //     return Card(
// //       margin: const EdgeInsets.all(12),
// //       child: Scrollbar(
// //         thumbVisibility: true,
// //         child: SingleChildScrollView(
// //           scrollDirection: Axis.vertical,
// //           child: SingleChildScrollView(
// //             scrollDirection: Axis.horizontal,
// //             child: DataTable(
// //               headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
// //               columns: [
// //                 _textColumn('الصنف', 'crop_name'),
// //                 _textColumn('الدرجة', 'class'),
// //                 _numericColumn('الكمية'),
// //                 _numericColumn('م. السعر'),
// //                 _numericColumn('القيمة'),
// //                 ...selectedTextCols.map((c) => _textColumn(textColumnsMap[c] ?? c, c)),
// //                 ...selectedNumCols.map((c) => _numericColumn(numericColumnsMap[c] ?? c)),
// //               ],
// //               rows: [
// //                 ...data.map((row) {
// //                   final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
// //                   return DataRow(cells: [
// //                     DataCell(Text(row['crop_name'] ?? '')),
// //                     DataCell(Text(row['class'] ?? '')),
// //                     DataCell(Text(formatNum(row['net_weight']))),
// //                     DataCell(Text(formatNum(row['avg_price']))),
// //                     DataCell(Text(formatNum(row['total_value']))),
// //                     ...selectedTextCols.map((c) => DataCell(Text(extra[c]?.toString() ?? '-'))),
// //                     ...selectedNumCols.map((c) => DataCell(Text(formatNum(extra[c])))),
// //                   ]);
// //                 }),
// //                 DataRow(
// //                   color: WidgetStateProperty.all(Colors.amber[50]),
// //                   cells: [
// //                     const DataCell(Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold))),
// //                     const DataCell(Text('')),
// //                     DataCell(Text(formatNum(totalNetWeight), style: const TextStyle(fontWeight: FontWeight.bold))),
// //                     DataCell(Text(formatNum(avgPrice), style: const TextStyle(fontWeight: FontWeight.bold))),
// //                     DataCell(Text(formatNum(totalValue), style: const TextStyle(fontWeight: FontWeight.bold))),
// //                     ...selectedTextCols.map((_) => const DataCell(Text(''))),
// //                     ...selectedNumCols.map((c) => DataCell(Text(formatNum(sumNumericColumn(c)), style: const TextStyle(fontWeight: FontWeight.bold)))),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   void _showColumnsOptions() {
// //     showDialog(
// //       context: context,
// //       builder: (context) => StatefulBuilder(
// //         builder: (context, setLocal) => AlertDialog(
// //           title: const Text('إعدادات الأعمدة'),
// //           content: SingleChildScrollView(
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 const Text('أعمدة النصوص:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
// //                 ...textColumnsMap.entries.map((entry) => CheckboxListTile(title: Text(entry.value), value: selectedTextCols.contains(entry.key), onChanged: (v) => setLocal(() => v! ? selectedTextCols.add(entry.key) : selectedTextCols.remove(entry.key)))),
// //                 const Divider(),
// //                 const Text('أعمدة الأرقام:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
// //                 ...numericColumnsMap.entries.map((entry) => CheckboxListTile(title: Text(entry.value), value: selectedNumCols.contains(entry.key), onChanged: (v) => setLocal(() => v! ? selectedNumCols.add(entry.key) : selectedNumCols.remove(entry.key)))),
// //               ],
// //             ),
// //           ),
// //           actions: [
// //             TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
// //             ElevatedButton(onPressed: () { _saveSettings(); Navigator.pop(context); loadReport(); }, child: const Text('حفظ وتطبيق')),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _dateItem(String label, DateTime value, Function(DateTime) onPick) {
// //     return InkWell(
// //       onTap: () async {
// //         final d = await showDatePicker(context: context, initialDate: value, firstDate: DateTime(2020), lastDate: DateTime(2030));
// //         if (d != null) { onPick(d); loadReport(); }
// //       },
// //       child: Column(children: [Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)), Text(intl.DateFormat('yyyy-MM-dd').format(value), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))]),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart' as intl;
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ProductionReportScreen extends StatefulWidget {
//   const ProductionReportScreen({super.key});

//   @override
//   State<ProductionReportScreen> createState() => _ProductionReportScreenState();
// }

// class _ProductionReportScreenState extends State<ProductionReportScreen> {
//   final supabase = Supabase.instance.client;

//   DateTime fromDate = DateTime(2025, 12, 1);
//   DateTime toDate = DateTime.now();
//   String? selectedCrop;
//   String? selectedClass;

//   final Map<String, String> textColumnsMap = {
//     'ProductionDate': 'التاريخ',
//     'ItemsCount': 'الحجم',
//     'CTNType': 'نوع الكرتون',
//     'CTNWeight': 'وزن الكرتون',
//     'Brand': 'الماركه',
//     'Country': 'الدولة',
//     'CustomerName': 'العميل',
//     'Order_Number': 'رقم الاوردر'
//   };

//   final Map<String, String> numericColumnsMap = {
//     'PalletCount': 'عدد البالتات',
//     'CTNCountInPallets': 'عدد الكرتون'
//   };

//   List<String> selectedTextCols = [];
//   List<String> selectedNumCols = [];

//   List reportData = [];
//   bool loading = false;
//   List<String> cropList = [];
//   List<String> classList = [];

//   Map<String, List<String>> columnFilters = {};

//   @override
//   void initState() {
//     super.initState();
//     _initData();
//   }

//   Future<void> _initData() async {
//     await _loadSavedSettings();
//     loadCropNames();
//     loadClass();
//     loadReport();
//   }

//   Future<void> _loadSavedSettings() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       selectedTextCols = prefs.getStringList('prod_selectedTextCols') ?? [];
//       selectedNumCols = prefs.getStringList('prod_selectedNumCols') ?? [];
//     });
//   }

//   Future<void> _saveSettings() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setStringList('prod_selectedTextCols', selectedTextCols);
//     await prefs.setStringList('prod_selectedNumCols', selectedNumCols);
//   }

//   List get filteredData {
//     if (columnFilters.isEmpty) return reportData;
//     return reportData.where((row) {
//       bool match = true;
//       final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};

//       columnFilters.forEach((key, selectedValues) {
//         if (selectedValues.isEmpty) return;

//         String cellValue = '';
//         if (key == 'crop_name') {
//           cellValue = row['crop_name']?.toString() ?? '';
//         } else if (key == 'class') {
//           cellValue = row['class']?.toString() ?? '';
//         } else {
//           cellValue = extra[key]?.toString() ?? '';
//         }

//         if (!selectedValues.contains(cellValue)) {
//           match = false;
//         }
//       });
//       return match;
//     }).toList();
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

//   num get totalNetWeight => filteredData.fold<num>(0.0, (s, e) => s + (e['net_weight'] ?? 0));
//   num get totalValue => filteredData.fold<num>(0.0, (s, e) => s + (e['total_value'] ?? 0));

//   num sumNumericColumn(String columnName) {
//     return filteredData.fold<num>(0.0, (s, e) {
//       final extra = e['extra_columns'] as Map<String, dynamic>? ?? {};
//       final val = extra[columnName];
//       return s + (val is num ? val : (double.tryParse(val?.toString() ?? '0') ?? 0));
//     });
//   }

//   Future<void> loadCropNames() async {
//     try {
//       final res = await supabase.from('Stations_ProductionView').select('Items');
//       final set = <String>{};
//       for (final e in res) if (e['Items'] != null) set.add(e['Items']);
//       setState(() => cropList = set.toList()..sort());
//     } catch (e) {
//       debugPrint('Error: $e');
//     }
//   }

//   Future<void> loadClass() async {
//     try {
//       final res = await supabase.from('Stations_ProductionView').select('Class');
//       final set = <String>{};
//       for (final e in res) if (e['Class'] != null) set.add(e['Class']);
//       setState(() => classList = set.toList()..sort());
//     } catch (e) {
//       debugPrint('Error: $e');
//     }
//   }

//   Future<void> loadReport() async {
//     setState(() => loading = true);
//     try {
//       final res = await supabase.rpc(
//         'get_production_report',
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
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
//       }
//     }
//   }

//   List<String> _getUniqueValuesForColumn(String key) {
//     final set = <String>{};
//     for (var row in reportData) {
//       final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
//       String val = '';
//       if (key == 'crop_name')
//         val = row['crop_name']?.toString() ?? '';
//       else if (key == 'class')
//         val = row['class']?.toString() ?? '';
//       else
//         val = extra[key]?.toString() ?? '';
//       if (val.isNotEmpty) set.add(val);
//     }
//     return set.toList()..sort();
//   }

//   void _showFilterDialog(String label, String filterKey) {
//     final uniqueValues = _getUniqueValuesForColumn(filterKey);
//     List<String> tempSelected = List.from(columnFilters[filterKey] ?? []);

//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setLocalState) => AlertDialog(
//           title: Text('تصفية: $label'),
//           content: SizedBox(
//             width: 300,
//             child: uniqueValues.isEmpty
//                 ? const Padding(padding: EdgeInsets.all(16.0), child: Text('لا توجد قيم'))
//                 : ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: uniqueValues.length,
//                     itemBuilder: (context, index) {
//                       final val = uniqueValues[index];
//                       return CheckboxListTile(
//                         title: Text(val),
//                         value: tempSelected.contains(val),
//                         onChanged: (bool? checked) => setLocalState(() => checked! ? tempSelected.add(val) : tempSelected.remove(val)),
//                       );
//                     },
//                   ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 setState(() => columnFilters.remove(filterKey));
//                 Navigator.pop(context);
//               },
//               child: const Text('مسح'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() => tempSelected.isEmpty ? columnFilters.remove(filterKey) : columnFilters[filterKey] = tempSelected);
//                 Navigator.pop(context);
//               },
//               child: const Text('تطبيق'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // --- وظيفة عرض الرسم البياني للدولة والكمية ---
//   void _showCountryChart() {
//     Map<String, double> countryData = {};
//     for (var row in filteredData) {
//       final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
//       String country = extra['Country']?.toString() ?? 'غير محدد';
//       double weight = (row['net_weight'] ?? 0).toDouble();
//       countryData[country] = (countryData[country] ?? 0) + weight;
//     }

//     if (countryData.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا توجد بيانات لعرضها')));
//       return;
//     }

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(20),
//         height: MediaQuery.of(context).size.height * 0.6,
//         child: Directionality(
//           textDirection: TextDirection.rtl,
//           child: Column(
//             children: [
//               const Text('توزيع الكمية حسب الدولة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               const Divider(),
//               Expanded(
//                 child: ListView(
//                   children: countryData.entries.map((e) {
//                     double percent = totalNetWeight == 0 ? 0 : e.value / totalNetWeight;
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600)),
//                               Text(formatNum(e.value, isMoney: false)),
//                             ],
//                           ),
//                           const SizedBox(height: 4),
//                           LinearProgressIndicator(
//                             value: percent,
//                             backgroundColor: Colors.grey[200],
//                             color: Colors.blue,
//                             minHeight: 10,
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),
//               ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق'))
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         backgroundColor: Colors.grey[100],
//         appBar: AppBar(title: const Text('تقرير الانتاج'), centerTitle: true),
//         body: Column(
//           children: [
//             _filtersSection(),
//             _summaryCards(),
//             Expanded(
//               child: loading ? const Center(child: CircularProgressIndicator()) : _tableSection(),
//             ),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton(onPressed: loadReport, child: const Icon(Icons.search)),
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
//                     items: [const DropdownMenuItem(value: null, child: Text('الكل')), ...cropList.map((c) => DropdownMenuItem(value: c, child: Text(c)))],
//                     onChanged: (v) => setState(() => selectedCrop = v),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: DropdownButtonFormField<String?>(
//                     decoration: const InputDecoration(labelText: 'الدرجة', border: OutlineInputBorder()),
//                     value: selectedClass,
//                     items: [const DropdownMenuItem(value: null, child: Text('الكل')), ...classList.map((c) => DropdownMenuItem(value: c, child: Text(c)))],
//                     onChanged: (v) => setState(() => selectedClass = v),
//                   ),
//                 ),
//                 IconButton.filledTonal(onPressed: _showColumnsOptions, icon: const Icon(Icons.settings)),
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
//           const SizedBox(width: 4),
//           _cardInfo('إجمالي القيمة', formatNum(totalValue), Colors.green),
//           const SizedBox(width: 4),
//           // الزر المطلوب لإظهار الرسم البياني
//           InkWell(
//             onTap: _showCountryChart,
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.orange.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: Colors.orange.withOpacity(0.5)),
//               ),
//               child: const Icon(Icons.bar_chart, color: Colors.orange, size: 30),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _cardInfo(String title, String value, Color color) {
//     return Expanded(
//       child: Card(
//         color: color.withOpacity(0.1),
//         elevation: 0,
//         shape: RoundedRectangleBorder(side: BorderSide(color: color.withOpacity(0.2)), borderRadius: BorderRadius.circular(10)),
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             children: [
//               Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
//               Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   DataColumn _textColumn(String label, String filterKey) {
//     final bool isFiltered = columnFilters.containsKey(filterKey);
//     return DataColumn(
//       label: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
//           const SizedBox(width: 4),
//           InkWell(
//             onTap: () => _showFilterDialog(label, filterKey),
//             child: Icon(Icons.filter_alt, size: 14, color: isFiltered ? Colors.blue : Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }

//   DataColumn _numericColumn(String label) => DataColumn(label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)));

//   Widget _tableSection() {
//     final data = filteredData;
//     if (data.isEmpty && reportData.isNotEmpty) return const Center(child: Text('لا توجد نتائج تطابق الفلتر'));
//     if (data.isEmpty) return const Center(child: Text('لا توجد بيانات'));

//     final avgPrice = totalNetWeight == 0 ? 0 : totalValue / totalNetWeight;

//     return Card(
//       margin: const EdgeInsets.all(12),
//       child: Scrollbar(
//         thumbVisibility: true,
//         child: SingleChildScrollView(
//           scrollDirection: Axis.vertical,
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: DataTable(
//               headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
//               columns: [
//                 _textColumn('الصنف', 'crop_name'),
//                 _textColumn('الدرجة', 'class'),
//                 _numericColumn('الكمية'),
//                 _numericColumn('م. السعر'),
//                 _numericColumn('القيمة'),
//                 ...selectedTextCols.map((c) => _textColumn(textColumnsMap[c] ?? c, c)),
//                 ...selectedNumCols.map((c) => _numericColumn(numericColumnsMap[c] ?? c)),
//               ],
//               rows: [
//                 ...data.map((row) {
//                   final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
//                   return DataRow(cells: [
//                     DataCell(Text(row['crop_name'] ?? '')),
//                     DataCell(Text(row['class'] ?? '')),
//                     DataCell(Text(formatNum(row['net_weight']))),
//                     DataCell(Text(formatNum(row['avg_price']))),
//                     DataCell(Text(formatNum(row['total_value']))),
//                     ...selectedTextCols.map((c) => DataCell(Text(extra[c]?.toString() ?? '-'))),
//                     ...selectedNumCols.map((c) => DataCell(Text(formatNum(extra[c], isMoney: false)))),
//                   ]);
//                 }),
//                 DataRow(
//                   color: MaterialStateProperty.all(Colors.amber[50]),
//                   cells: [
//                     const DataCell(Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold))),
//                     const DataCell(Text('-')),
//                     DataCell(Text(formatNum(totalNetWeight), style: const TextStyle(fontWeight: FontWeight.bold))),
//                     DataCell(Text(formatNum(avgPrice), style: const TextStyle(fontWeight: FontWeight.bold))),
//                     DataCell(Text(formatNum(totalValue), style: const TextStyle(fontWeight: FontWeight.bold))),
//                     ...selectedTextCols.map((_) => const DataCell(Text(''))),
//                     ...selectedNumCols.map((c) => DataCell(
//                           Text(formatNum(sumNumericColumn(c), isMoney: false), style: const TextStyle(fontWeight: FontWeight.bold)),
//                         )),
//                   ],
//                 ),
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
//                 const Text('أعمدة النصوص:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
//                 ...textColumnsMap.entries.map((entry) => CheckboxListTile(
//                       title: Text(entry.value),
//                       value: selectedTextCols.contains(entry.key),
//                       onChanged: (v) => setLocal(() => v! ? selectedTextCols.add(entry.key) : selectedTextCols.remove(entry.key)),
//                     )),
//                 const Divider(),
//                 const Text('أعمدة الأرقام:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
//                 ...numericColumnsMap.entries.map((entry) => CheckboxListTile(
//                       title: Text(entry.value),
//                       value: selectedNumCols.contains(entry.key),
//                       onChanged: (v) => setLocal(() => v! ? selectedNumCols.add(entry.key) : selectedNumCols.remove(entry.key)),
//                     )),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
//             ElevatedButton(
//               onPressed: () {
//                 _saveSettings();
//                 Navigator.pop(context);
//                 loadReport();
//               },
//               child: const Text('تطبيق'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _dateItem(String label, DateTime value, Function(DateTime) onPick) {
//     return InkWell(
//       onTap: () async {
//         final d = await showDatePicker(context: context, initialDate: value, firstDate: DateTime(2020), lastDate: DateTime(2030));
//         if (d != null) {
//           onPick(d);
//           loadReport();
//         }
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
import 'package:fl_chart/fl_chart.dart'; // تأكد من إضافة fl_chart في pubspec.yaml

class ProductionReportScreen extends StatefulWidget {
  const ProductionReportScreen({super.key});

  @override
  State<ProductionReportScreen> createState() => _ProductionReportScreenState();
}

class _ProductionReportScreenState extends State<ProductionReportScreen> {
  final supabase = Supabase.instance.client;

  DateTime fromDate = DateTime(2025, 12, 1);
  DateTime toDate = DateTime.now();
  String? selectedCrop;
  String? selectedClass;

  final Map<String, String> textColumnsMap = {
    'ProductionDate': 'التاريخ',
    'ItemsCount': 'الحجم',
    'CTNType': 'نوع الكرتون',
    'CTNWeight': 'وزن الكرتون',
    'Brand': 'الماركه',
    'Country': 'الدولة',
    'CustomerName': 'العميل',
    'Order_Number': 'رقم الاوردر'
  };

  final Map<String, String> numericColumnsMap = {
    'PalletCount': 'عدد البالتات',
    'CTNCountInPallets': 'عدد الكرتون'
  };

  List<String> selectedTextCols = [];
  List<String> selectedNumCols = [];

  List reportData = [];
  bool loading = false;
  List<String> cropList = [];
  List<String> classList = [];

  Map<String, List<String>> columnFilters = {};

  // بيانات خاصة للرسم البياني يتم جلبها عند الحاجة
  Map<String, double> countryChartData = {};
  bool chartLoading = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _loadSavedSettings();
    loadCropNames();
    loadClass();
    loadReport();
  }

  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedTextCols = prefs.getStringList('prod_selectedTextCols') ?? [];
      selectedNumCols = prefs.getStringList('prod_selectedNumCols') ?? [];
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('prod_selectedTextCols', selectedTextCols);
    await prefs.setStringList('prod_selectedNumCols', selectedNumCols);
  }

  List get filteredData {
    if (columnFilters.isEmpty) return reportData;
    return reportData.where((row) {
      bool match = true;
      final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};

      columnFilters.forEach((key, selectedValues) {
        if (selectedValues.isEmpty) return;

        String cellValue = '';
        if (key == 'crop_name') {
          cellValue = row['crop_name']?.toString() ?? '';
        } else if (key == 'class') {
          cellValue = row['class']?.toString() ?? '';
        } else {
          cellValue = extra[key]?.toString() ?? '';
        }

        if (!selectedValues.contains(cellValue)) {
          match = false;
        }
      });
      return match;
    }).toList();
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

  num get totalNetWeight => filteredData.fold<num>(0.0, (s, e) => s + (e['net_weight'] ?? 0));
  num get totalValue => filteredData.fold<num>(0.0, (s, e) => s + (e['total_value'] ?? 0));

  num sumNumericColumn(String columnName) {
    return filteredData.fold<num>(0.0, (s, e) {
      final extra = e['extra_columns'] as Map<String, dynamic>? ?? {};
      final val = extra[columnName];
      return s + (val is num ? val : (double.tryParse(val?.toString() ?? '0') ?? 0));
    });
  }

  Future<void> loadCropNames() async {
    try {
      final res = await supabase.from('Stations_ProductionView').select('Items');
      final set = <String>{};
      for (final e in res) if (e['Items'] != null) set.add(e['Items']);
      setState(() => cropList = set.toList()..sort());
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> loadClass() async {
    try {
      final res = await supabase.from('Stations_ProductionView').select('Class');
      final set = <String>{};
      for (final e in res) if (e['Class'] != null) set.add(e['Class']);
      setState(() => classList = set.toList()..sort());
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> loadReport() async {
    setState(() => loading = true);
    try {
      final res = await supabase.rpc(
        'get_production_report',
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
        reportData = List.from(res);
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
      }
    }
  }

  // --- جلب بيانات مخصصة للرسم البياني فقط في حال لم تكن "الدولة" موجودة في التقرير الحالي ---
  Future<void> _fetchChartDataIfNeeded() async {
    // إذا كان عمود الدولة مختاراً بالفعل في التقرير، سنعتمد على filteredData
    if (selectedTextCols.contains('Country')) {
      countryChartData.clear();
      for (var row in filteredData) {
        final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
        String country = extra['Country']?.toString() ?? 'غير محدد';
        double weight = (row['net_weight'] ?? 0).toDouble();
        countryChartData[country] = (countryChartData[country] ?? 0) + weight;
      }
      return;
    }

    // إذا لم يكن عمود الدولة مختاراً، نسحب بيانات مخصوصة من قاعدة البيانات
    setState(() => chartLoading = true);
    try {
      // هنا نقوم باستدعاء الـ RPC ولكن نطلب مجموعة "الدولة" فقط للرسم البياني
      final res = await supabase.rpc(
        'get_production_report',
        params: {
          'p_date_from': intl.DateFormat('yyyy-MM-dd').format(fromDate),
          'p_date_to': intl.DateFormat('yyyy-MM-dd').format(toDate),
          'p_crop_name': selectedCrop,
          'p_crop_class': selectedClass,
          'p_group_columns': ['Country'], // نطلب عمود الدولة إجبارياً هنا
          'p_sum_columns': [],
        },
      );

      Map<String, double> tempMap = {};
      for (var row in res) {
        final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
        String country = extra['Country']?.toString() ?? 'غير محدد';
        double weight = (row['net_weight'] ?? 0).toDouble();
        tempMap[country] = (tempMap[country] ?? 0) + weight;
      }
      
      setState(() {
        countryChartData = tempMap;
        chartLoading = false;
      });
    } catch (e) {
      setState(() => chartLoading = false);
      debugPrint('Chart Data Error: $e');
    }
  }

  void _showCountryChart() async {
    await _fetchChartDataIfNeeded();

    if (countryChartData.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا توجد بيانات دولة للرسم البياني')));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.75,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: chartLoading 
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  const Text('تحليل توزيع الكميات حسب الدولة', 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const SizedBox(height: 10),
                  const Text('رسم بياني دائري يوضح نسب كل دولة من إجمالي الإنتاج', 
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const Divider(height: 30),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // محاكاة تأثير الـ 3D عبر ظلال وتدرجات في الـ PieChart
                        PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 50,
                            startDegreeOffset: -90,
                            sections: _buildChartSections(),
                          ),
                        ),
                        // النص المركزي في الدائرة
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('الإجمالي', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(formatNum(countryChartData.values.reduce((a, b) => a + b), isMoney: false), 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // دليل الألوان (Legend)
                  SizedBox(
                    height: 100,
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 15,
                        runSpacing: 10,
                        children: _buildChartLegend(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      onPressed: () => Navigator.pop(context), 
                      child: const Text('إغلاق', style: TextStyle(color: Colors.white))
                    ),
                  )
                ],
              ),
          ),
        ),
      ),
    );
  }

  // List<PieChartSectionData> _buildChartSections() {
  //   final List<Color> colors = [
  //     Colors.blue, Colors.red, Colors.green, Colors.orange, 
  //     Colors.purple, Colors.teal, Colors.amber, Colors.indigo
  //   ];
    
  //   double total = countryChartData.values.reduce((a, b) => a + b);
  //   int index = 0;
    
  //   return countryChartData.entries.map((e) {
  //     final color = colors[index % colors.length];
  //     final double percentage = (e.value / total) * 100;
  //     index++;
      
  //     return PieChartSectionData(
  //       color: color,
  //       value: e.value,
  //       title: '${percentage.toStringAsFixed(1)}%',
  //       radius: 80, // نصف القطر لإعطاء مظهر عريض
  //       titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
  //       // إضافة تدرج لوني خفيف لمحاكاة الأبعاد
  //       badgeWidget: _badge(color),
  //       badgePositionPercentageOffset: 0.98,
  //     );
  //   }).toList();
  // }
  List<PieChartSectionData> _buildChartSections() {
    final List<Color> colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange,
      Colors.purple, Colors.teal, Colors.amber, Colors.indigo
    ];

    double total = countryChartData.values.reduce((a, b) => a + b);
    int index = 0;

    // حساب الزوايا التراكمية لوضع النص في منتصف كل قسم
    double cumulativeValue = 0;

    return countryChartData.entries.map((e) {
      final color = colors[index % colors.length];
      final double percentage = (e.value / total) * 100;
      
      // حساب زاوية منتصف القسم الحالي (بالدرجات)
      // نبدأ من -90 (أعلى الدائرة) كما هو محدد في startDegreeOffset
      final double sectionCenterValue = cumulativeValue + (e.value / 2);
      final double sectionCenterDegrees = (sectionCenterValue / total) * 360 - 90;
      
      cumulativeValue += e.value;
      index++;

      return PieChartSectionData(
        color: color,
        value: e.value,
        title: '', // نترك العنوان فارغاً لأننا سنستخدم badgeWidget للتحكم الكامل
        radius: 70,
        badgeWidget: _buildRotatedLabel(e.key, percentage, sectionCenterDegrees, color),
        badgePositionPercentageOffset: 1.2, // وضع النص خارج حدود الدائرة قليلاً لمنع التداخل
      );
    }).toList();
  }

  // دالة لبناء الملصق المائل بزاوية 90 درجة عمودياً على قطر الدائرة
  Widget _buildRotatedLabel(String country, double percentage, double angleDegrees, Color color) {
    // الزاوية هنا تجعل النص "عمودياً" بالنسبة لمركز الدائرة
    // نحول الدرجات إلى راديان
    final double angleRadian = (angleDegrees * 3.1415926535897932) / 180;

    return Transform.rotate(
      angle: angleRadian + (3.1415926535897932 / 2), // إضافة 90 درجة ليكون عمودياً على القطر
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              country,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.amber, // جعل لون النص أغمق قليلاً من القسم ليكون واضحاً
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4, spreadRadius: 1)]
      ),
    );
  }

  List<Widget> _buildChartLegend() {
    final List<Color> colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, 
      Colors.purple, Colors.teal, Colors.amber, Colors.indigo
    ];
    int index = 0;
    return countryChartData.entries.map((e) {
      final color = colors[index % colors.length];
      index++;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text('${e.key}: ${formatNum(e.value, isMoney: false)}', style: const TextStyle(fontSize: 11)),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('تقرير الانتاج', style: TextStyle(fontWeight: FontWeight.bold)), 
          centerTitle: true,
          elevation: 0,
          // backgroundColor: Colors.white,
          // foregroundColor: Colors.black,
        ),
        body: Column(
          children: [
            _filtersSection(),
            _summaryCards(),
            Expanded(
              child: loading ? const Center(child: CircularProgressIndicator()) : _tableSection(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: loadReport, 
          label: const Text('تحديث البيانات'),
          icon: const Icon(Icons.refresh),
        ),
      ),
    );
  }

  Widget _filtersSection() {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    decoration: const InputDecoration(labelText: 'الصنف', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                    value: selectedCrop,
                    items: [const DropdownMenuItem(value: null, child: Text('الكل')), ...cropList.map((c) => DropdownMenuItem(value: c, child: Text(c)))],
                    onChanged: (v) => setState(() => selectedCrop = v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    decoration: const InputDecoration(labelText: 'الدرجة', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                    value: selectedClass,
                    items: [const DropdownMenuItem(value: null, child: Text('الكل')), ...classList.map((c) => DropdownMenuItem(value: c, child: Text(c)))],
                    onChanged: (v) => setState(() => selectedClass = v),
                  ),
                ),
                IconButton.filledTonal(onPressed: _showColumnsOptions, icon: const Icon(Icons.view_column_rounded)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _dateItem('تاريخ البداية', fromDate, (d) => setState(() => fromDate = d)),
                _dateItem('تاريخ النهاية', toDate, (d) => setState(() => toDate = d)),
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
          _cardInfo('إجمالي الكمية', formatNum(totalNetWeight), Colors.blue),
          const SizedBox(width: 8),
          _cardInfo('إجمالي القيمة', formatNum(totalValue), Colors.green),
          const SizedBox(width: 8),
          // الزر المطور للرسم البياني
          InkWell(
            onTap: _showCountryChart,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.orange.shade400, Colors.orange.shade700]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: const Column(
                children: [
                  Icon(Icons.pie_chart_outline, color: Colors.white, size: 24),
                  Text('الرسم', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _cardInfo(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  DataColumn _textColumn(String label, String filterKey) {
    final bool isFiltered = columnFilters.containsKey(filterKey);
    return DataColumn(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => _showFilterDialog(label, filterKey),
            child: Icon(Icons.filter_alt, size: 14, color: isFiltered ? Colors.blue : Colors.grey),
          ),
        ],
      ),
    );
  }

  DataColumn _numericColumn(String label) => DataColumn(label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)));

  Widget _tableSection() {
    final data = filteredData;
    if (data.isEmpty && reportData.isNotEmpty) return const Center(child: Text('لا توجد نتائج تطابق الفلتر'));
    if (data.isEmpty) return const Center(child: Text('لا توجد بيانات متاحة'));

    final avgPrice = totalNetWeight == 0 ? 0 : totalValue / totalNetWeight;

    return Card(
      margin: const EdgeInsets.all(12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.blueGrey[50]),
              columnSpacing: 20,
              columns: [
                _textColumn('الصنف', 'crop_name'),
                _textColumn('الدرجة', 'class'),
                _numericColumn('الكمية'),
                _numericColumn('م. السعر'),
                _numericColumn('القيمة'),
                ...selectedTextCols.map((c) => _textColumn(textColumnsMap[c] ?? c, c)),
                ...selectedNumCols.map((c) => _numericColumn(numericColumnsMap[c] ?? c)),
              ],
              rows: [
                ...data.map((row) {
                  final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
                  return DataRow(cells: [
                    DataCell(Text(row['crop_name'] ?? '')),
                    DataCell(Text(row['class'] ?? '')),
                    DataCell(Text(formatNum(row['net_weight']))),
                    DataCell(Text(formatNum(row['avg_price']))),
                    DataCell(Text(formatNum(row['total_value']))),
                    ...selectedTextCols.map((c) => DataCell(Text(extra[c]?.toString() ?? '-'))),
                    ...selectedNumCols.map((c) => DataCell(Text(formatNum(extra[c], isMoney: false)))),
                  ]);
                }),
                DataRow(
                  color: MaterialStateProperty.all(Colors.amber[100]),
                  cells: [
                    const DataCell(Text('الإجمالي العام', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataCell(Text('-')),
                    DataCell(Text(formatNum(totalNetWeight), style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(formatNum(avgPrice), style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(formatNum(totalValue), style: const TextStyle(fontWeight: FontWeight.bold))),
                    ...selectedTextCols.map((_) => const DataCell(Text(''))),
                    ...selectedNumCols.map((c) => DataCell(
                          Text(formatNum(sumNumericColumn(c), isMoney: false), style: const TextStyle(fontWeight: FontWeight.bold)),
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

  // نفس دوال تصفية الأعمدة والتاريخ بدون تغيير جوهري
  void _showColumnsOptions() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('اختيار الأعمدة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('أعمدة النصوص:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                ...textColumnsMap.entries.map((entry) => CheckboxListTile(
                      title: Text(entry.value),
                      value: selectedTextCols.contains(entry.key),
                      onChanged: (v) => setLocal(() => v! ? selectedTextCols.add(entry.key) : selectedTextCols.remove(entry.key)),
                    )),
                const Divider(),
                const Text('أعمدة الأرقام:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ...numericColumnsMap.entries.map((entry) => CheckboxListTile(
                      title: Text(entry.value),
                      value: selectedNumCols.contains(entry.key),
                      onChanged: (v) => setLocal(() => v! ? selectedNumCols.add(entry.key) : selectedNumCols.remove(entry.key)),
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                _saveSettings();
                Navigator.pop(context);
                loadReport();
              },
              child: const Text('تطبيق التعديلات'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(String label, String filterKey) {
    final uniqueValues = _getUniqueValuesForColumn(filterKey);
    List<String> tempSelected = List.from(columnFilters[filterKey] ?? []);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: Text('تصفية: $label'),
          content: SizedBox(
            width: 300,
            child: uniqueValues.isEmpty
                ? const Padding(padding: EdgeInsets.all(16.0), child: Text('لا توجد قيم متاحة'))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: uniqueValues.length,
                    itemBuilder: (context, index) {
                      final val = uniqueValues[index];
                      return CheckboxListTile(
                        title: Text(val),
                        value: tempSelected.contains(val),
                        onChanged: (bool? checked) => setLocalState(() => checked! ? tempSelected.add(val) : tempSelected.remove(val)),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => columnFilters.remove(filterKey));
                Navigator.pop(context);
              },
              child: const Text('إعادة تعيين'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => tempSelected.isEmpty ? columnFilters.remove(filterKey) : columnFilters[filterKey] = tempSelected);
                Navigator.pop(context);
              },
              child: const Text('تطبيق الفلتر'),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getUniqueValuesForColumn(String key) {
    final set = <String>{};
    for (var row in reportData) {
      final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
      String val = '';
      if (key == 'crop_name') val = row['crop_name']?.toString() ?? '';
      else if (key == 'class') val = row['class']?.toString() ?? '';
      else val = extra[key]?.toString() ?? '';
      if (val.isNotEmpty) set.add(val);
    }
    return set.toList()..sort();
  }

  Widget _dateItem(String label, DateTime value, Function(DateTime) onPick) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(context: context, initialDate: value, firstDate: DateTime(2020), lastDate: DateTime(2030));
        if (d != null) {
          onPick(d);
          loadReport();
        }
      },
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(intl.DateFormat('yyyy-MM-dd').format(value), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}