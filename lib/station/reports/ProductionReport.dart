
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart' as intl;
// // import 'package:supabase_flutter/supabase_flutter.dart';

// // class ProductionReportScreen extends StatefulWidget {
// //   const ProductionReportScreen({super.key});

// //   @override
// //   State<ProductionReportScreen> createState() => _FarzaReportScreenState();
// // }

// // class _FarzaReportScreenState extends State<ProductionReportScreen> {
// //   final supabase = Supabase.instance.client;

// //   DateTime fromDate = DateTime(2025, 12, 1);
// //   DateTime toDate = DateTime.now();
// //   String? selectedCrop;
// //   String? selectedClass;

// //   // الخرائط لربط الاسم الإنجليزي (قاعدة البيانات) بالاسم العربي (العرض)
// //   final Map<String, String> textColumnsMap = {
    
// //     'ProductionDate': 'التاريخ',
// //      'ItemsCount':'الحجم',
// //     'CTNType':'نوع الكرتون',
// //     'CTNWeight': 'وزن الكرتون',
// //     'Brand': 'الماركه',
// //     'CustomerName': 'العميل',
// //     'Order_Number': 'رقم الاوردر'
// //   };

// //   final Map<String, String> numericColumnsMap = {
// //     'PalletCount': 'عدد البالتات',
// //     // 'EmpetyWeight': 'الوزن الفارغ',
// //   };

// //   List<String> selectedTextCols = [];
// //   List<String> selectedNumCols = [];

// //   List reportData = [];
// //   bool loading = false;
// //   List<String> cropList = [];
// //   List<String> classList = [];

// //   @override
// //   void initState() {
// //     super.initState();
// //     loadCropNames();
// //     loadClass();
// //     loadReport();
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

// //   Future<void> loadCropNames() async {
// //     try {
// //       final res = await supabase.from('Stations_ProductionCost').select('Items');
// //       final set = <String>{};
// //       for (final e in res) {
// //         if (e['Items'] != null) set.add(e['Items']);
// //       }
// //       setState(() => cropList = set.toList()..sort());
// //     } catch (e) {
// //       debugPrint('Error: $e');
// //     }
// //   }
// //  Future<void> loadClass() async {
// //     try {
// //       final res = await supabase.from('Stations_ProductionCost').select('Class');
// //       final set = <String>{};
// //       for (final e in res) {
// //         if (e['Class'] != null) set.add(e['Class']);
// //       }
// //       setState(() => classList = set.toList()..sort());
// //     } catch (e) {
// //       debugPrint('Error: $e');
// //     }
// //   }

// //   Future<void> loadReport() async {
// //     setState(() => loading = true);
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
// //       print(e);
// //       setState(() => loading = false);
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('خطأ في تحميل التقرير: $e')),
// //         );
// //       }
// //     }
// //   }

// //   num get totalNetWeight => reportData.fold(0, (s, e) => s + (e['net_weight'] ?? 0));
// //   num get totalValue => reportData.fold(0, (s, e) => s + (e['total_value'] ?? 0));

// //   num sumNumericColumn(String columnName) {
// //     if (reportData.isEmpty) return 0;
// //     return reportData.fold(0, (s, e) {
// //       final extra = e['extra_columns'] as Map<String, dynamic>? ?? {};
// //       final val = extra[columnName];
// //       return s + (val is num ? val : (double.tryParse(val?.toString() ?? '0') ?? 0));
// //     });
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
// //               child: loading
// //                   ? const Center(child: CircularProgressIndicator())
// //                   : _tableSection(),
// //             ),
// //           ],
// //         ),
// //         floatingActionButton: FloatingActionButton(
// //           onPressed: loadReport,
// //           child: const Icon(Icons.search),
// //         ),
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
// //                     items: [
// //                       const DropdownMenuItem(value: null, child: Text('الكل')),
// //                       ...cropList.map((c) => DropdownMenuItem(value: c, child: Text(c))),
// //                     ],
// //                     onChanged: (v) => setState(() => selectedCrop = v),
// //                   ),
// //                 ),
// //                   Expanded(
// //                   child: DropdownButtonFormField<String?>(
// //                     decoration: const InputDecoration(labelText: 'الدرجة', border: OutlineInputBorder()),
// //                     value: selectedClass,
// //                     items: [
// //                       const DropdownMenuItem(value: null, child: Text('الكل')),
// //                       ...classList.map((c) => DropdownMenuItem(value: c, child: Text(c))),
// //                     ],
// //                     onChanged: (v) => setState(() => selectedClass = v),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 8),
// //                 IconButton.filledTonal(
// //                   onPressed: _showColumnsOptions,
// //                   icon: const Icon(Icons.settings),
// //                   tooltip: 'إعدادات الأعمدة',
// //                 ),
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
// //         child: Padding(
// //           padding: const EdgeInsets.all(12),
// //           child: Column(
// //             children: [
// //               Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
// //               Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _tableSection() {
// //     if (reportData.isEmpty) return const Center(child: Text('لا توجد بيانات متاحة'));
// //     final avgPrice = totalNetWeight == 0 ? 0 : totalValue / totalNetWeight;

// //     return Card(
// //       margin: const EdgeInsets.all(12),
// //       child: Scrollbar(
// //         child: SingleChildScrollView(
// //           scrollDirection: Axis.vertical,
// //           child: SingleChildScrollView(
// //             scrollDirection: Axis.horizontal,
// //             child: DataTable(
// //               headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
// //               columns: [
// //                 const DataColumn(label: Text('الصنف')),
// //                 const DataColumn(label: Text('الدرجة')),
// //                 const DataColumn(label: Text('الكمية')),
// //                 const DataColumn(label: Text('متوسط السعر')),
// //                 const DataColumn(label: Text('القيمة')),
// //                 // جلب الاسم العربي للأعمدة النصية المختارة
// //                 ...selectedTextCols.map((c) => DataColumn(label: Text(textColumnsMap[c] ?? c))),
// //                 // جلب الاسم العربي للأعمدة الرقمية المختارة
// //                 ...selectedNumCols.map((c) => DataColumn(label: Text(numericColumnsMap[c] ?? c))),
// //               ],
// //               rows: [
// //                 ...reportData.map((row) {
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
// //   color: MaterialStateProperty.all(Colors.amber[50]),
// //   cells: [
// //     const DataCell(Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold))),
// //     const DataCell(Text('-')), // ← الدرجة
// //     DataCell(Text(formatNum(totalNetWeight), style: const TextStyle(fontWeight: FontWeight.bold))),
// //     DataCell(Text(formatNum(avgPrice), style: const TextStyle(fontWeight: FontWeight.bold))),
// //     DataCell(Text(formatNum(totalValue), style: const TextStyle(fontWeight: FontWeight.bold))),
// //     ...selectedTextCols.map((_) => const DataCell(Text(''))),
// //     ...selectedNumCols.map((c) => DataCell(
// //           Text(formatNum(sumNumericColumn(c)),
// //           style: const TextStyle(fontWeight: FontWeight.bold)),
// //         )),
// //   ],
// // ),

          
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
// //                 const Text('أعمدة النصوص (تفصيلية):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
// //                 // استخدام الخريطة لعرض الاسم العربي
// //                 ...textColumnsMap.entries.map((entry) => CheckboxListTile(
// //                   title: Text(entry.value), // الاسم العربي
// //                   value: selectedTextCols.contains(entry.key),
// //                   onChanged: (v) => setLocal(() => v! ? selectedTextCols.add(entry.key) : selectedTextCols.remove(entry.key)),
// //                 )),
// //                 const Divider(),
// //                 const Text('أعمدة الأرقام (مجاميع):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
// //                 // استخدام الخريطة لعرض الاسم العربي
// //                 ...numericColumnsMap.entries.map((entry) => CheckboxListTile(
// //                   title: Text(entry.value), // الاسم العربي
// //                   value: selectedNumCols.contains(entry.key),
// //                   onChanged: (v) => setLocal(() => v! ? selectedNumCols.add(entry.key) : selectedNumCols.remove(entry.key)),
// //                 )),
// //               ],
// //             ),
// //           ),
// //           actions: [
// //             TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
// //             ElevatedButton(onPressed: () {
// //               Navigator.pop(context);
// //               loadReport();
// //             }, child: const Text('تطبيق')),
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
// //       child: Column(
// //         children: [
// //           Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
// //           Text(intl.DateFormat('yyyy-MM-dd').format(value), style: const TextStyle(fontWeight: FontWeight.bold)),
// //         ],
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart' as intl;
// import 'package:supabase_flutter/supabase_flutter.dart';

// class ProductionReportScreen extends StatefulWidget {
//   const ProductionReportScreen({super.key});

//   @override
//   State<ProductionReportScreen> createState() => _ProductionReportScreenState();
// }

// class _ProductionReportScreenState extends State<ProductionReportScreen> {
//   final supabase = Supabase.instance.client;

//   DateTime fromDate = DateTime(2025, 1, 1);
//   DateTime toDate = DateTime.now();
//   String? selectedCrop;
//   String? selectedClass;

//   final Map<String, String> textColumnsMap = {
//     'ProductionDate': 'التاريخ',
//     'ItemsCount': 'الحجم',
//     'CTNType': 'نوع الكرتون',
//     'CTNWeight': 'وزن الكرتون',
//     'Brand': 'الماركه',
//     'CustomerName': 'العميل',
//     'Order_Number': 'رقم الاوردر'
//   };

//   final Map<String, String> numericColumnsMap = {
//     'PalletCount': 'عدد البالتات',
//   };

//   List<String> selectedTextCols = [];
//   List<String> selectedNumCols = [];

//   List reportData = [];
//   bool loading = false;
//   List<String> cropList = [];
//   List<String> classList = [];

//   // --- خريطة لتخزين القيم المختارة للفلترة (قائمة من القيم لكل عمود) ---
//   Map<String, List<String>> columnFilters = {};

//   @override
//   void initState() {
//     super.initState();
//     loadCropNames();
//     loadClass();
//     loadReport();
//   }

//   // --- وظيفة للحصول على البيانات المصفاة بناءً على القائمة المختارة ---
//   List get filteredData {
//     if (columnFilters.isEmpty) return reportData;
//     return reportData.where((row) {
//       bool match = true;
//       final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};

//       columnFilters.forEach((key, selectedValues) {
//         if (selectedValues.isEmpty) return;
        
//         String cellValue = '';
//         if (key == 'crop_name') cellValue = row['crop_name']?.toString() ?? '';
//         else if (key == 'class') cellValue = row['class']?.toString() ?? '';
//         else if (key == 'net_weight') cellValue = row['net_weight']?.toString() ?? '';
//         else if (key == 'avg_price') cellValue = row['avg_price']?.toString() ?? '';
//         else if (key == 'total_value') cellValue = row['total_value']?.toString() ?? '';
//         else cellValue = extra[key]?.toString() ?? '';

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

//   num get totalNetWeight => filteredData.fold(0, (s, e) => s + (e['net_weight'] ?? 0));
//   num get totalValue => filteredData.fold(0, (s, e) => s + (e['total_value'] ?? 0));

//   num sumNumericColumn(String columnName) {
//     return filteredData.fold(0, (s, e) {
//       final extra = e['extra_columns'] as Map<String, dynamic>? ?? {};
//       final val = extra[columnName];
//       return s + (val is num ? val : (double.tryParse(val?.toString() ?? '0') ?? 0));
//     });
//   }

//   Future<void> loadCropNames() async {
//     try {
//       final res = await supabase.from('Stations_ProductionCost').select('Items');
//       final set = <String>{};
//       for (final e in res) {
//         if (e['Items'] != null) set.add(e['Items']);
//       }
//       setState(() => cropList = set.toList()..sort());
//     } catch (e) {
//       debugPrint('Error: $e');
//     }
//   }

//   Future<void> loadClass() async {
//     try {
//       final res = await supabase.from('Stations_ProductionCost').select('Class');
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
//     setState(() {
//       loading = true;
//       columnFilters.clear();
//     });
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
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('خطأ في تحميل التقرير: $e')),
//         );
//       }
//     }
//   }

//   // --- وظيفة لاستخراج القيم الفريدة من كل عمود لعرضها في قائمة الفلتر ---
//   List<String> _getUniqueValuesForColumn(String key) {
//     final set = <String>{};
//     for (var row in reportData) {
//       final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
//       String val = '';
//       if (key == 'crop_name') val = row['crop_name']?.toString() ?? '';
//       else if (key == 'class') val = row['class']?.toString() ?? '';
//       else if (key == 'net_weight') val = row['net_weight']?.toString() ?? '';
//       else if (key == 'avg_price') val = row['avg_price']?.toString() ?? '';
//       else if (key == 'total_value') val = row['total_value']?.toString() ?? '';
//       else val = extra[key]?.toString() ?? '';
      
//       if (val.isNotEmpty) set.add(val);
//     }
//     return set.toList()..sort();
//   }

//   // --- إظهار نافذة منبثقة لاختيار القيم المراد فلترتها ---
//   void _showFilterDialog(String label, String filterKey) {
//     final uniqueValues = _getUniqueValuesForColumn(filterKey);
//     List<String> tempSelected = List.from(columnFilters[filterKey] ?? []);

//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setLocalState) => AlertDialog(
//           title: Text('تصفية: $label'),
//           content: SizedBox(
//             width: double.maxFinite,
//             child: uniqueValues.isEmpty 
//               ? const Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: Text('لا توجد قيم متاح تصفيتها'),
//                 )
//               : ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: uniqueValues.length,
//                   itemBuilder: (context, index) {
//                     final val = uniqueValues[index];
//                     return CheckboxListTile(
//                       title: Text(val),
//                       value: tempSelected.contains(val),
//                       onChanged: (bool? checked) {
//                         setLocalState(() {
//                           if (checked == true) {
//                             tempSelected.add(val);
//                           } else {
//                             tempSelected.remove(val);
//                           }
//                         });
//                       },
//                     );
//                   },
//                 ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 setState(() => columnFilters.remove(filterKey));
//                 Navigator.pop(context);
//               },
//               child: const Text('إعادة ضبط'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   if (tempSelected.isEmpty) {
//                     columnFilters.remove(filterKey);
//                   } else {
//                     columnFilters[filterKey] = tempSelected;
//                   }
//                 });
//                 Navigator.pop(context);
//               },
//               child: const Text('تطبيق'),
//             ),
//           ],
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
//                 const SizedBox(width: 8),
//                 Expanded(
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

//   // --- تحديث: رأس العمود يحتوي الآن على أيقونة فلتر ---
//   DataColumn _filterColumn(String label, String filterKey) {
//     final bool isFiltered = columnFilters.containsKey(filterKey);
//     return DataColumn(
//       label: Row(
//         children: [
//           Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
//           IconButton(
//             icon: Icon(
//               Icons.filter_alt_outlined,
//               size: 18,
//               color: isFiltered ? Colors.blue : Colors.grey,
//             ),
//             onPressed: () => _showFilterDialog(label, filterKey),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _tableSection() {
//     final data = filteredData;
//     if (data.isEmpty && reportData.isNotEmpty) {
//       return const Center(child: Text('لا توجد بيانات تطابق الفلاتر المختارة'));
//     }
//     if (data.isEmpty) return const Center(child: Text('لا توجد بيانات متاحة'));
    
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
//               headingRowHeight: 60,
//               headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
//               columns: [
//                 _filterColumn('الصنف', 'crop_name'),
//                 _filterColumn('الدرجة', 'class'),
//                 _filterColumn('الكمية', 'net_weight'),
//                 _filterColumn('متوسط السعر', 'avg_price'),
//                 _filterColumn('القيمة', 'total_value'),
//                 ...selectedTextCols.map((c) => _filterColumn(textColumnsMap[c] ?? c, c)),
//                 ...selectedNumCols.map((c) => _filterColumn(numericColumnsMap[c] ?? c, c)),
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
//                     ...selectedNumCols.map((c) => DataCell(Text(formatNum(extra[c])))),
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
//                           Text(formatNum(sumNumericColumn(c)), style: const TextStyle(fontWeight: FontWeight.bold)),
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
//                 const Text('أعمدة النصوص (تفصيلية):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
//                 ...textColumnsMap.entries.map((entry) => CheckboxListTile(
//                       title: Text(entry.value),
//                       value: selectedTextCols.contains(entry.key),
//                       onChanged: (v) => setLocal(() => v! ? selectedTextCols.add(entry.key) : selectedTextCols.remove(entry.key)),
//                     )),
//                 const Divider(),
//                 const Text('أعمدة الأرقام (مجاميع):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
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
//                 onPressed: () {
//                   Navigator.pop(context);
//                   loadReport();
//                 },
//                 child: const Text('تطبيق')),
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

class ProductionReportScreen extends StatefulWidget {
  const ProductionReportScreen({super.key});

  @override
  State<ProductionReportScreen> createState() => _ProductionReportScreenState();
}

class _ProductionReportScreenState extends State<ProductionReportScreen> {
  final supabase = Supabase.instance.client;

  DateTime fromDate = DateTime(2025, 1, 1);
  DateTime toDate = DateTime.now();
  String? selectedCrop;
  String? selectedClass;

  final Map<String, String> textColumnsMap = {
    'ProductionDate': 'التاريخ',
    'ItemsCount': 'الحجم',
    'CTNType': 'نوع الكرتون',
    'CTNWeight': 'وزن الكرتون',
    'Brand': 'الماركه',
    'CustomerName': 'العميل',
    'Order_Number': 'رقم الاوردر'
  };

  final Map<String, String> numericColumnsMap = {
    'PalletCount': 'عدد البالتات',
  };

  List<String> selectedTextCols = [];
  List<String> selectedNumCols = [];

  List reportData = [];
  bool loading = false;
  List<String> cropList = [];
  List<String> classList = [];

  // --- خريطة لتخزين القيم المختارة للفلترة (للأعمدة النصية فقط) ---
  Map<String, List<String>> columnFilters = {};

  @override
  void initState() {
    super.initState();
    loadCropNames();
    loadClass();
    loadReport();
  }

  // --- وظيفة للحصول على البيانات المصفاة بناءً على القائمة المختارة ---
  List get filteredData {
    if (columnFilters.isEmpty) return reportData;
    return reportData.where((row) {
      bool match = true;
      final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};

      columnFilters.forEach((key, selectedValues) {
        if (selectedValues.isEmpty) return;
        
        String cellValue = '';
        if (key == 'crop_name') cellValue = row['crop_name']?.toString() ?? '';
        else if (key == 'class') cellValue = row['class']?.toString() ?? '';
        else cellValue = extra[key]?.toString() ?? '';

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

  num get totalNetWeight => filteredData.fold(0, (s, e) => s + (e['net_weight'] ?? 0));
  num get totalValue => filteredData.fold(0, (s, e) => s + (e['total_value'] ?? 0));

  num sumNumericColumn(String columnName) {
    return filteredData.fold(0, (s, e) {
      final extra = e['extra_columns'] as Map<String, dynamic>? ?? {};
      final val = extra[columnName];
      return s + (val is num ? val : (double.tryParse(val?.toString() ?? '0') ?? 0));
    });
  }

  Future<void> loadCropNames() async {
    try {
      final res = await supabase.from('Stations_ProductionCost').select('Items');
      final set = <String>{};
      for (final e in res) {
        if (e['Items'] != null) set.add(e['Items']);
      }
      setState(() => cropList = set.toList()..sort());
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> loadClass() async {
    try {
      final res = await supabase.from('Stations_ProductionCost').select('Class');
      final set = <String>{};
      for (final e in res) {
        if (e['Class'] != null) set.add(e['Class']);
      }
      setState(() => classList = set.toList()..sort());
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> loadReport() async {
    setState(() {
      loading = true;
      columnFilters.clear();
    });
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل التقرير: $e')),
        );
      }
    }
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

  void _showFilterDialog(String label, String filterKey) {
    final uniqueValues = _getUniqueValuesForColumn(filterKey);
    List<String> tempSelected = List.from(columnFilters[filterKey] ?? []);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: Text('تصفية: $label'),
          content: SizedBox(
            width: double.maxFinite,
            child: uniqueValues.isEmpty 
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('لا توجد قيم متاح تصفيتها'),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: uniqueValues.length,
                  itemBuilder: (context, index) {
                    final val = uniqueValues[index];
                    return CheckboxListTile(
                      title: Text(val),
                      value: tempSelected.contains(val),
                      onChanged: (bool? checked) {
                        setLocalState(() {
                          if (checked == true) {
                            tempSelected.add(val);
                          } else {
                            tempSelected.remove(val);
                          }
                        });
                      },
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
              child: const Text('إعادة ضبط'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (tempSelected.isEmpty) {
                    columnFilters.remove(filterKey);
                  } else {
                    columnFilters[filterKey] = tempSelected;
                  }
                });
                Navigator.pop(context);
              },
              child: const Text('تطبيق'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(title: const Text('تقرير الانتاج'), centerTitle: true),
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
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    decoration: const InputDecoration(labelText: 'الدرجة', border: OutlineInputBorder()),
                    value: selectedClass,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('الكل')),
                      ...classList.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                    ],
                    onChanged: (v) => setState(() => selectedClass = v),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: _showColumnsOptions,
                  icon: const Icon(Icons.settings),
                  tooltip: 'إعدادات الأعمدة',
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
          _cardInfo('إجمالي الكمية', formatNum(totalNetWeight), Colors.blue),
          const SizedBox(width: 8),
          _cardInfo('إجمالي القيمة', formatNum(totalValue), Colors.green),
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
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  // --- دالة لرأس العمود للأعمدة النصية (تحتوي على فلتر) ---
  DataColumn _textColumn(String label, String filterKey) {
    final bool isFiltered = columnFilters.containsKey(filterKey);
    return DataColumn(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => _showFilterDialog(label, filterKey),
            child: Icon(
              Icons.filter_alt_outlined,
              size: 16,
              color: isFiltered ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // --- دالة لرأس العمود للأعمدة الرقمية (لا تحتوي على فلتر) ---
  DataColumn _numericColumn(String label) {
    return DataColumn(
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _tableSection() {
    final data = filteredData;
    if (data.isEmpty && reportData.isNotEmpty) {
      return const Center(child: Text('لا توجد بيانات تطابق الفلاتر المختارة'));
    }
    if (data.isEmpty) return const Center(child: Text('لا توجد بيانات متاحة'));
    
    final avgPrice = totalNetWeight == 0 ? 0 : totalValue / totalNetWeight;

    return Card(
      margin: const EdgeInsets.all(12),
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 50,
              columnSpacing: 20,
              headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
              columns: [
                _textColumn('الصنف', 'crop_name'),
                _textColumn('الدرجة', 'class'),
                _numericColumn('الكمية'),
                _numericColumn('متوسط السعر'),
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
                    ...selectedNumCols.map((c) => DataCell(Text(formatNum(extra[c])))),
                  ]);
                }),
                DataRow(
                  color: MaterialStateProperty.all(Colors.amber[50]),
                  cells: [
                    const DataCell(Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataCell(Text('-')),
                    DataCell(Text(formatNum(totalNetWeight), style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(formatNum(avgPrice), style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(formatNum(totalValue), style: const TextStyle(fontWeight: FontWeight.bold))),
                    ...selectedTextCols.map((_) => const DataCell(Text(''))),
                    ...selectedNumCols.map((c) => DataCell(
                          Text(formatNum(sumNumericColumn(c)), style: const TextStyle(fontWeight: FontWeight.bold)),
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

  void _showColumnsOptions() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('إعدادات الأعمدة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('أعمدة النصوص (تفصيلية):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                ...textColumnsMap.entries.map((entry) => CheckboxListTile(
                      title: Text(entry.value),
                      value: selectedTextCols.contains(entry.key),
                      onChanged: (v) => setLocal(() => v! ? selectedTextCols.add(entry.key) : selectedTextCols.remove(entry.key)),
                    )),
                const Divider(),
                const Text('أعمدة الأرقام (مجاميع):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
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
                  Navigator.pop(context);
                  loadReport();
                },
                child: const Text('تطبيق')),
          ],
        ),
      ),
    );
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
          Text(intl.DateFormat('yyyy-MM-dd').format(value), style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}