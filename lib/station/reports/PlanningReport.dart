

// // // // // // // // // import 'package:flutter/material.dart';
// // // // // // // // // import 'package:intl/intl.dart' as intl;
// // // // // // // // // import 'package:supabase_flutter/supabase_flutter.dart';
// // // // // // // // // import 'package:shared_preferences/shared_preferences.dart';

// // // // // // // // // class PlanninReportScreen extends StatefulWidget {
// // // // // // // // //   const PlanninReportScreen({super.key});

// // // // // // // // //   @override
// // // // // // // // //   State<PlanninReportScreen> createState() => _FarzaReportScreenState();
// // // // // // // // // }

// // // // // // // // // class _FarzaReportScreenState extends State<PlanninReportScreen> {
// // // // // // // // //   final supabase = Supabase.instance.client;

// // // // // // // // //   DateTime fromDate = DateTime(2025, 12, 1);
// // // // // // // // //   DateTime toDate = DateTime.now();
// // // // // // // // //   String? selectedCrop;
// // // // // // // // //   String? selectedClass;

// // // // // // // // //   final Map<String, String> textColumnsMap = {
// // // // // // // // //     'Date': 'التاريخ',
// // // // // // // // //     'ShippingDate': 'تاريخ الشحن',
// // // // // // // // //     'Country': 'الدولة',
// // // // // // // // //     'Count': 'الحجم',
// // // // // // // // //     'CTNType': 'نوع الكرتون',
// // // // // // // // //     'CTNWeight': 'وزن الكرتون',
// // // // // // // // //     'Brand': 'الماركه',
// // // // // // // // //     'Serial': 'رقم الطلبية',
// // // // // // // // //   };

// // // // // // // // //   final Map<String, String> numericColumnsMap = {
// // // // // // // // //     'PalletsCount': 'كمية الطلبية',
// // // // // // // // //     'Production_Pallet': 'كمية الانتاج',
// // // // // // // // //     'Shipping_Pallet': 'كمية المشحون',
// // // // // // // // //     'balance': 'مطلوب انتاجه',
// // // // // // // // //   };

// // // // // // // // //   List<String> selectedTextCols = [];
// // // // // // // // //   List<String> selectedNumCols = [];

// // // // // // // // //   List reportData = []; // البيانات الخام من السيرفر
// // // // // // // // //   List filteredData = []; // البيانات بعد الفلترة المحلية
// // // // // // // // //   bool loading = false;
// // // // // // // // //   List<String> cropList = [];
// // // // // // // // //   List<String> classList = [];

// // // // // // // // //   // خريطة لتخزين الفلاتر النشطة (اسم العمود -> القيمة المختارة)
// // // // // // // // //   Map<String, String?> activeFilters = {};

// // // // // // // // //   @override
// // // // // // // // //   void initState() {
// // // // // // // // //     super.initState();
// // // // // // // // //     _loadSavedColumns().then((_) {
// // // // // // // // //       loadCropNames();
// // // // // // // // //       loadClass();
// // // // // // // // //       loadReport();
// // // // // // // // //     });
// // // // // // // // //   }

// // // // // // // // //   // --- 1. حفظ واسترجاع الأعمدة المختارة ---
// // // // // // // // //   Future<void> _loadSavedColumns() async {
// // // // // // // // //     final prefs = await SharedPreferences.getInstance();
// // // // // // // // //     setState(() {
// // // // // // // // //       selectedTextCols = prefs.getStringList('selectedTextCols') ?? [];
// // // // // // // // //       selectedNumCols = prefs.getStringList('selectedNumCols') ?? [];
// // // // // // // // //     });
// // // // // // // // //   }

// // // // // // // // //   Future<void> _saveColumns() async {
// // // // // // // // //     final prefs = await SharedPreferences.getInstance();
// // // // // // // // //     await prefs.setStringList('selectedTextCols', selectedTextCols);
// // // // // // // // //     await prefs.setStringList('selectedNumCols', selectedNumCols);
// // // // // // // // //   }

// // // // // // // // //   String formatNum(dynamic v, {bool isMoney = true}) {
// // // // // // // // //     if (v == null) return isMoney ? '0.00' : '0';
// // // // // // // // //     final formatter = intl.NumberFormat.decimalPattern();
// // // // // // // // //     if (isMoney) {
// // // // // // // // //       formatter.minimumFractionDigits = 2;
// // // // // // // // //       formatter.maximumFractionDigits = 2;
// // // // // // // // //     }
// // // // // // // // //     return formatter.format(v is num ? v : double.tryParse(v.toString()) ?? 0);
// // // // // // // // //   }

// // // // // // // // //   Future<void> loadCropNames() async {
// // // // // // // // //     try {
// // // // // // // // //       final res = await supabase.from('view8').select('Items');
// // // // // // // // //       final set = <String>{};
// // // // // // // // //       for (final e in res) {
// // // // // // // // //         if (e['Items'] != null) set.add(e['Items']);
// // // // // // // // //       }
// // // // // // // // //       setState(() => cropList = set.toList()..sort());
// // // // // // // // //     } catch (e) {
// // // // // // // // //       debugPrint('Error: $e');
// // // // // // // // //     }
// // // // // // // // //   }

// // // // // // // // //   Future<void> loadClass() async {
// // // // // // // // //     try {
// // // // // // // // //       final res = await supabase.from('view8').select('Class');
// // // // // // // // //       final set = <String>{};
// // // // // // // // //       for (final e in res) {
// // // // // // // // //         if (e['Class'] != null) set.add(e['Class']);
// // // // // // // // //       }
// // // // // // // // //       setState(() => classList = set.toList()..sort());
// // // // // // // // //     } catch (e) {
// // // // // // // // //       debugPrint('Error: $e');
// // // // // // // // //     }
// // // // // // // // //   }

// // // // // // // // //   Future<void> loadReport() async {
// // // // // // // // //     setState(() {
// // // // // // // // //       loading = true;
// // // // // // // // //       activeFilters.clear(); // مسح الفلاتر عند تحميل بيانات جديدة
// // // // // // // // //     });
// // // // // // // // //     try {
// // // // // // // // //       final res = await supabase.rpc(
// // // // // // // // //         'get_planning_report',
// // // // // // // // //         params: {
// // // // // // // // //           'p_date_from': intl.DateFormat('yyyy-MM-dd').format(fromDate),
// // // // // // // // //           'p_date_to': intl.DateFormat('yyyy-MM-dd').format(toDate),
// // // // // // // // //           'p_crop_name': selectedCrop,
// // // // // // // // //           'p_crop_class': selectedClass,
// // // // // // // // //           'p_group_columns': selectedTextCols,
// // // // // // // // //           'p_sum_columns': selectedNumCols,
// // // // // // // // //         },
// // // // // // // // //       );
// // // // // // // // //       setState(() {
// // // // // // // // //         reportData = List.from(res);
// // // // // // // // //         filteredData = List.from(res);
// // // // // // // // //         loading = false;
// // // // // // // // //       });
// // // // // // // // //     } catch (e) {
// // // // // // // // //       setState(() => loading = false);
// // // // // // // // //       if (mounted) {
// // // // // // // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // // // // // // //           SnackBar(content: Text('خطأ في تحميل التقرير: $e')),
// // // // // // // // //         );
// // // // // // // // //       }
// // // // // // // // //     }
// // // // // // // // //   }

// // // // // // // // //   // --- 2. منطق الفلترة المحلية داخل الجدول ---
// // // // // // // // //   void _applyLocalFilters() {
// // // // // // // // //     setState(() {
// // // // // // // // //       filteredData = reportData.where((row) {
// // // // // // // // //         bool match = true;
// // // // // // // // //         activeFilters.forEach((colKey, filterValue) {
// // // // // // // // //           if (filterValue != null) {
// // // // // // // // //             String rowValue = "";
// // // // // // // // //             if (colKey == 'crop_name') rowValue = row['crop_name']?.toString() ?? "";
// // // // // // // // //             else if (colKey == 'class') rowValue = row['class']?.toString() ?? "";
// // // // // // // // //             else {
// // // // // // // // //               final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
// // // // // // // // //               rowValue = extra[colKey]?.toString() ?? "";
// // // // // // // // //             }
// // // // // // // // //             if (rowValue != filterValue) match = false;
// // // // // // // // //           }
// // // // // // // // //         });
// // // // // // // // //         return match;
// // // // // // // // //       }).toList();
// // // // // // // // //     });
// // // // // // // // //   }

// // // // // // // // //   num get totalNetWeight => filteredData.fold(0, (s, e) => s + (e['net_weight'] ?? 0));

// // // // // // // // //   num sumNumericColumn(String columnName) {
// // // // // // // // //     if (filteredData.isEmpty) return 0;
// // // // // // // // //     return filteredData.fold(0, (s, e) {
// // // // // // // // //       final extra = e['extra_columns'] as Map<String, dynamic>? ?? {};
// // // // // // // // //       final val = extra[columnName];
// // // // // // // // //       return s + (val is num ? val : (double.tryParse(val?.toString() ?? '0') ?? 0));
// // // // // // // // //     });
// // // // // // // // //   }

// // // // // // // // //   @override
// // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // //     return Directionality(
// // // // // // // // //       textDirection: TextDirection.rtl,
// // // // // // // // //       child: Scaffold(
// // // // // // // // //         backgroundColor: Colors.grey[100],
// // // // // // // // //         appBar: AppBar(title: const Text('تقرير التخطيط'), centerTitle: true),
// // // // // // // // //         body: Column(
// // // // // // // // //           children: [
// // // // // // // // //             _filtersSection(),
// // // // // // // // //             _summaryCards(),
// // // // // // // // //             Expanded(
// // // // // // // // //               child: loading
// // // // // // // // //                   ? const Center(child: CircularProgressIndicator())
// // // // // // // // //                   : _tableSection(),
// // // // // // // // //             ),
// // // // // // // // //           ],
// // // // // // // // //         ),
// // // // // // // // //         floatingActionButton: FloatingActionButton(
// // // // // // // // //           onPressed: loadReport,
// // // // // // // // //           child: const Icon(Icons.search),
// // // // // // // // //         ),
// // // // // // // // //       ),
// // // // // // // // //     );
// // // // // // // // //   }

// // // // // // // // //   Widget _filtersSection() {
// // // // // // // // //     return Card(
// // // // // // // // //       margin: const EdgeInsets.all(12),
// // // // // // // // //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
// // // // // // // // //       child: Padding(
// // // // // // // // //         padding: const EdgeInsets.all(16),
// // // // // // // // //         child: Column(
// // // // // // // // //           children: [
// // // // // // // // //             Row(
// // // // // // // // //               children: [
// // // // // // // // //                 Expanded(
// // // // // // // // //                   child: DropdownButtonFormField<String?>(
// // // // // // // // //                     decoration: const InputDecoration(labelText: 'الصنف', border: OutlineInputBorder()),
// // // // // // // // //                     value: selectedCrop,
// // // // // // // // //                     items: [
// // // // // // // // //                       const DropdownMenuItem(value: null, child: Text('الكل')),
// // // // // // // // //                       ...cropList.map((c) => DropdownMenuItem(value: c, child: Text(c))),
// // // // // // // // //                     ],
// // // // // // // // //                     onChanged: (v) => setState(() => selectedCrop = v),
// // // // // // // // //                   ),
// // // // // // // // //                 ),
// // // // // // // // //                 const SizedBox(width: 10),
// // // // // // // // //                 Expanded(
// // // // // // // // //                   child: DropdownButtonFormField<String?>(
// // // // // // // // //                     decoration: const InputDecoration(labelText: 'الدرجة', border: OutlineInputBorder()),
// // // // // // // // //                     value: selectedClass,
// // // // // // // // //                     items: [
// // // // // // // // //                       const DropdownMenuItem(value: null, child: Text('الكل')),
// // // // // // // // //                       ...classList.map((c) => DropdownMenuItem(value: c, child: Text(c))),
// // // // // // // // //                     ],
// // // // // // // // //                     onChanged: (v) => setState(() => selectedClass = v),
// // // // // // // // //                   ),
// // // // // // // // //                 ),
// // // // // // // // //                 const SizedBox(width: 8),
// // // // // // // // //                 IconButton.filledTonal(
// // // // // // // // //                   onPressed: _showColumnsOptions,
// // // // // // // // //                   icon: const Icon(Icons.settings),
// // // // // // // // //                   tooltip: 'إعدادات الأعمدة',
// // // // // // // // //                 ),
// // // // // // // // //               ],
// // // // // // // // //             ),
// // // // // // // // //             const SizedBox(height: 12),
// // // // // // // // //             Row(
// // // // // // // // //               mainAxisAlignment: MainAxisAlignment.spaceAround,
// // // // // // // // //               children: [
// // // // // // // // //                 _dateItem('من', fromDate, (d) => setState(() => fromDate = d)),
// // // // // // // // //                 _dateItem('إلى', toDate, (d) => setState(() => toDate = d)),
// // // // // // // // //               ],
// // // // // // // // //             ),
// // // // // // // // //           ],
// // // // // // // // //         ),
// // // // // // // // //       ),
// // // // // // // // //     );
// // // // // // // // //   }

// // // // // // // // //   Widget _summaryCards() {
// // // // // // // // //     return Padding(
// // // // // // // // //       padding: const EdgeInsets.symmetric(horizontal: 12),
// // // // // // // // //       child: Row(
// // // // // // // // //         children: [
// // // // // // // // //           _cardInfo('إجمالي الكمية (المصفاة)', formatNum(totalNetWeight), Colors.blue),
// // // // // // // // //         ],
// // // // // // // // //       ),
// // // // // // // // //     );
// // // // // // // // //   }

// // // // // // // // //   Widget _cardInfo(String title, String value, Color color) {
// // // // // // // // //     return Expanded(
// // // // // // // // //       child: Card(
// // // // // // // // //         color: color.withOpacity(0.1),
// // // // // // // // //         child: Padding(
// // // // // // // // //           padding: const EdgeInsets.all(12),
// // // // // // // // //           child: Column(
// // // // // // // // //             children: [
// // // // // // // // //               Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
// // // // // // // // //               Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
// // // // // // // // //             ],
// // // // // // // // //           ),
// // // // // // // // //         ),
// // // // // // // // //       ),
// // // // // // // // //     );
// // // // // // // // //   }

// // // // // // // // //   // --- زر الفلترة في رأس العمود ---
// // // // // // // // //   Widget _buildFilterHeader(String title, String colKey) {
// // // // // // // // //     return Row(
// // // // // // // // //       mainAxisSize: MainAxisSize.min,
// // // // // // // // //       children: [
// // // // // // // // //         Text(title),
// // // // // // // // //         PopupMenuButton<String>(
// // // // // // // // //           icon: Icon(
// // // // // // // // //             Icons.filter_list,
// // // // // // // // //             size: 18,
// // // // // // // // //             color: activeFilters[colKey] != null ? Colors.red : Colors.grey,
// // // // // // // // //           ),
// // // // // // // // //           onSelected: (value) {
// // // // // // // // //             setState(() {
// // // // // // // // //               activeFilters[colKey] = (value == "CLEAR") ? null : value;
// // // // // // // // //               _applyLocalFilters();
// // // // // // // // //             });
// // // // // // // // //           },
// // // // // // // // //           itemBuilder: (context) {
// // // // // // // // //             // استخراج القيم الفريدة من البيانات الخام لهذا العمود
// // // // // // // // //             Set<String> uniqueValues = {};
// // // // // // // // //             for (var row in reportData) {
// // // // // // // // //               if (colKey == 'crop_name') uniqueValues.add(row['crop_name']?.toString() ?? "");
// // // // // // // // //               else if (colKey == 'class') uniqueValues.add(row['class']?.toString() ?? "");
// // // // // // // // //               else {
// // // // // // // // //                 final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
// // // // // // // // //                 uniqueValues.add(extra[colKey]?.toString() ?? "");
// // // // // // // // //               }
// // // // // // // // //             }
            
// // // // // // // // //             return [
// // // // // // // // //               const PopupMenuItem(value: "CLEAR", child: Text("إلغاء الفلتر", style: TextStyle(color: Colors.blue))),
// // // // // // // // //               ...uniqueValues.where((v) => v.isNotEmpty).map((v) => PopupMenuItem(value: v, child: Text(v))),
// // // // // // // // //             ];
// // // // // // // // //           },
// // // // // // // // //         ),
// // // // // // // // //       ],
// // // // // // // // //     );
// // // // // // // // //   }

// // // // // // // // //   Widget _tableSection() {
// // // // // // // // //     if (filteredData.isEmpty && reportData.isEmpty) return const Center(child: Text('لا توجد بيانات متاحة'));
// // // // // // // // //     if (filteredData.isEmpty) return const Center(child: Text('لا توجد نتائج تطابق الفلتر'));

// // // // // // // // //     return Card(
// // // // // // // // //       margin: const EdgeInsets.all(12),
// // // // // // // // //       child: Scrollbar(
// // // // // // // // //         child: SingleChildScrollView(
// // // // // // // // //           scrollDirection: Axis.vertical,
// // // // // // // // //           child: SingleChildScrollView(
// // // // // // // // //             scrollDirection: Axis.horizontal,
// // // // // // // // //             child: DataTable(
// // // // // // // // //               headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
// // // // // // // // //               columns: [
// // // // // // // // //                 DataColumn(label: _buildFilterHeader('الصنف', 'crop_name')),
// // // // // // // // //                 DataColumn(label: _buildFilterHeader('الدرجة', 'class')),
// // // // // // // // //                 const DataColumn(label: Text('الكمية')),
// // // // // // // // //                 ...selectedTextCols.map((c) => DataColumn(label: _buildFilterHeader(textColumnsMap[c] ?? c, c))),
// // // // // // // // //                 ...selectedNumCols.map((c) => DataColumn(label: Text(numericColumnsMap[c] ?? c))),
// // // // // // // // //               ],
// // // // // // // // //               rows: [
// // // // // // // // //                 ...filteredData.map((row) {
// // // // // // // // //                   final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
// // // // // // // // //                   return DataRow(cells: [
// // // // // // // // //                     DataCell(Text(row['crop_name'] ?? '')),
// // // // // // // // //                     DataCell(Text(row['class'] ?? '')),
// // // // // // // // //                     DataCell(Text(formatNum(row['net_weight']))),
// // // // // // // // //                     ...selectedTextCols.map((c) => DataCell(Text(extra[c]?.toString() ?? '-'))),
// // // // // // // // //                     ...selectedNumCols.map((c) => DataCell(Text(formatNum(extra[c])))),
// // // // // // // // //                   ]);
// // // // // // // // //                 }),
// // // // // // // // //                 DataRow(
// // // // // // // // //                   color: MaterialStateProperty.all(Colors.amber[50]),
// // // // // // // // //                   cells: [
// // // // // // // // //                     const DataCell(Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold))),
// // // // // // // // //                     const DataCell(Text('-')),
// // // // // // // // //                     DataCell(Text(formatNum(totalNetWeight), style: const TextStyle(fontWeight: FontWeight.bold))),
// // // // // // // // //                     ...selectedTextCols.map((_) => const DataCell(Text(''))),
// // // // // // // // //                     ...selectedNumCols.map((c) => DataCell(
// // // // // // // // //                           Text(formatNum(sumNumericColumn(c)), style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // // // // // //                         )),
// // // // // // // // //                   ],
// // // // // // // // //                 ),
// // // // // // // // //               ],
// // // // // // // // //             ),
// // // // // // // // //           ),
// // // // // // // // //         ),
// // // // // // // // //       ),
// // // // // // // // //     );
// // // // // // // // //   }

// // // // // // // // //   void _showColumnsOptions() {
// // // // // // // // //     showDialog(
// // // // // // // // //       context: context,
// // // // // // // // //       builder: (context) => StatefulBuilder(
// // // // // // // // //         builder: (context, setLocal) => AlertDialog(
// // // // // // // // //           title: const Text('إعدادات الأعمدة'),
// // // // // // // // //           content: SingleChildScrollView(
// // // // // // // // //             child: Column(
// // // // // // // // //               mainAxisSize: MainAxisSize.min,
// // // // // // // // //               crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //               children: [
// // // // // // // // //                 const Text('أعمدة النصوص (تفصيلية):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
// // // // // // // // //                 ...textColumnsMap.entries.map((entry) => CheckboxListTile(
// // // // // // // // //                       title: Text(entry.value),
// // // // // // // // //                       value: selectedTextCols.contains(entry.key),
// // // // // // // // //                       onChanged: (v) => setLocal(() => v! ? selectedTextCols.add(entry.key) : selectedTextCols.remove(entry.key)),
// // // // // // // // //                     )),
// // // // // // // // //                 const Divider(),
// // // // // // // // //                 const Text('أعمدة الأرقام (مجاميع):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
// // // // // // // // //                 ...numericColumnsMap.entries.map((entry) => CheckboxListTile(
// // // // // // // // //                       title: Text(entry.value),
// // // // // // // // //                       value: selectedNumCols.contains(entry.key),
// // // // // // // // //                       onChanged: (v) => setLocal(() => v! ? selectedNumCols.add(entry.key) : selectedNumCols.remove(entry.key)),
// // // // // // // // //                     )),
// // // // // // // // //               ],
// // // // // // // // //             ),
// // // // // // // // //           ),
// // // // // // // // //           actions: [
// // // // // // // // //             TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
// // // // // // // // //             ElevatedButton(
// // // // // // // // //                 onPressed: () {
// // // // // // // // //                   _saveColumns(); // حفظ في التخزين المحلي
// // // // // // // // //                   Navigator.pop(context);
// // // // // // // // //                   loadReport();
// // // // // // // // //                 },
// // // // // // // // //                 child: const Text('تطبيق وحفظ')),
// // // // // // // // //           ],
// // // // // // // // //         ),
// // // // // // // // //       ),
// // // // // // // // //     );
// // // // // // // // //   }

// // // // // // // // //   Widget _dateItem(String label, DateTime value, Function(DateTime) onPick) {
// // // // // // // // //     return InkWell(
// // // // // // // // //       onTap: () async {
// // // // // // // // //         final d = await showDatePicker(context: context, initialDate: value, firstDate: DateTime(2020), lastDate: DateTime(2030));
// // // // // // // // //         if (d != null) {
// // // // // // // // //           onPick(d);
// // // // // // // // //           loadReport();
// // // // // // // // //         }
// // // // // // // // //       },
// // // // // // // // //       child: Column(
// // // // // // // // //         children: [
// // // // // // // // //           Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
// // // // // // // // //           Text(intl.DateFormat('yyyy-MM-dd').format(value), style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // // // // // //         ],
// // // // // // // // //       ),
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // // }
// // // // // // // // import 'package:flutter/material.dart';
// // // // // // // // import 'package:intl/intl.dart' as intl;
// // // // // // // // import 'package:supabase_flutter/supabase_flutter.dart';
// // // // // // // // import 'package:shared_preferences/shared_preferences.dart';

// // // // // // // // class PlanninReportScreen extends StatefulWidget {
// // // // // // // //   const PlanninReportScreen({super.key});

// // // // // // // //   @override
// // // // // // // //   State<PlanninReportScreen> createState() => _FarzaReportScreenState();
// // // // // // // // }

// // // // // // // // class _FarzaReportScreenState extends State<PlanninReportScreen> {
// // // // // // // //   final supabase = Supabase.instance.client;

// // // // // // // //   DateTime fromDate = DateTime(2025, 12, 1);
// // // // // // // //   DateTime toDate = DateTime.now();
// // // // // // // //   String? selectedCrop;
// // // // // // // //   String? selectedClass;

// // // // // // // //   final Map<String, String> textColumnsMap = {
// // // // // // // //     'Date': 'التاريخ',
// // // // // // // //     'ShippingDate': 'تاريخ الشحن',
// // // // // // // //     'Country': 'الدولة',
// // // // // // // //     'Count': 'الحجم',
// // // // // // // //     'CTNType': 'نوع الكرتون',
// // // // // // // //     'CTNWeight': 'وزن الكرتون',
// // // // // // // //     'Brand': 'الماركه',
// // // // // // // //     'Serial': 'رقم الطلبية',
// // // // // // // //   };

// // // // // // // //   final Map<String, String> numericColumnsMap = {
// // // // // // // //     'PalletsCount': 'كمية الطلبية',
// // // // // // // //     'Production_Pallet': 'كمية الانتاج',
// // // // // // // //     'Shipping_Pallet': 'كمية المشحون',
// // // // // // // //     'balance': 'مطلوب انتاجه',
// // // // // // // //   };

// // // // // // // //   List<String> selectedTextCols = [];
// // // // // // // //   List<String> selectedNumCols = [];

// // // // // // // //   List reportData = []; // البيانات الخام
// // // // // // // //   List filteredData = []; // البيانات بعد الفلترة
// // // // // // // //   bool loading = false;
// // // // // // // //   List<String> cropList = [];
// // // // // // // //   List<String> classList = [];

// // // // // // // //   // تعديل: خريطة لتخزين الفلاتر المتعددة (اسم العمود -> قائمة القيم المختارة)
// // // // // // // //   Map<String, List<String>> activeFilters = {};

// // // // // // // //   @override
// // // // // // // //   void initState() {
// // // // // // // //     super.initState();
// // // // // // // //     _loadSavedColumns().then((_) {
// // // // // // // //       loadCropNames();
// // // // // // // //       loadClass();
// // // // // // // //       loadReport();
// // // // // // // //     });
// // // // // // // //   }

// // // // // // // //   Future<void> _loadSavedColumns() async {
// // // // // // // //     final prefs = await SharedPreferences.getInstance();
// // // // // // // //     setState(() {
// // // // // // // //       selectedTextCols = prefs.getStringList('selectedTextCols') ?? [];
// // // // // // // //       selectedNumCols = prefs.getStringList('selectedNumCols') ?? [];
// // // // // // // //     });
// // // // // // // //   }

// // // // // // // //   Future<void> _saveColumns() async {
// // // // // // // //     final prefs = await SharedPreferences.getInstance();
// // // // // // // //     await prefs.setStringList('selectedTextCols', selectedTextCols);
// // // // // // // //     await prefs.setStringList('selectedNumCols', selectedNumCols);
// // // // // // // //   }

// // // // // // // //   String formatNum(dynamic v, {bool isMoney = true}) {
// // // // // // // //     if (v == null) return isMoney ? '0.00' : '0';
// // // // // // // //     final formatter = intl.NumberFormat.decimalPattern();
// // // // // // // //     if (isMoney) {
// // // // // // // //       formatter.minimumFractionDigits = 2;
// // // // // // // //       formatter.maximumFractionDigits = 2;
// // // // // // // //     }
// // // // // // // //     return formatter.format(v is num ? v : double.tryParse(v.toString()) ?? 0);
// // // // // // // //   }

// // // // // // // //   Future<void> loadCropNames() async {
// // // // // // // //     try {
// // // // // // // //       final res = await supabase.from('view8').select('Items');
// // // // // // // //       final set = <String>{};
// // // // // // // //       for (final e in res) {
// // // // // // // //         if (e['Items'] != null) set.add(e['Items']);
// // // // // // // //       }
// // // // // // // //       setState(() => cropList = set.toList()..sort());
// // // // // // // //     } catch (e) {
// // // // // // // //       debugPrint('Error: $e');
// // // // // // // //     }
// // // // // // // //   }

// // // // // // // //   Future<void> loadClass() async {
// // // // // // // //     try {
// // // // // // // //       final res = await supabase.from('view8').select('Class');
// // // // // // // //       final set = <String>{};
// // // // // // // //       for (final e in res) {
// // // // // // // //         if (e['Class'] != null) set.add(e['Class']);
// // // // // // // //       }
// // // // // // // //       setState(() => classList = set.toList()..sort());
// // // // // // // //     } catch (e) {
// // // // // // // //       debugPrint('Error: $e');
// // // // // // // //     }
// // // // // // // //   }

// // // // // // // //   Future<void> loadReport() async {
// // // // // // // //     setState(() {
// // // // // // // //       loading = true;
// // // // // // // //       // لم نعد نمسح activeFilters هنا لكي تظل الفلاتر كما هي عند التحديث
// // // // // // // //     });
// // // // // // // //     try {
// // // // // // // //       final res = await supabase.rpc(
// // // // // // // //         'get_planning_report',
// // // // // // // //         params: {
// // // // // // // //           'p_date_from': intl.DateFormat('yyyy-MM-dd').format(fromDate),
// // // // // // // //           'p_date_to': intl.DateFormat('yyyy-MM-dd').format(toDate),
// // // // // // // //           'p_crop_name': selectedCrop,
// // // // // // // //           'p_crop_class': selectedClass,
// // // // // // // //           'p_group_columns': selectedTextCols,
// // // // // // // //           'p_sum_columns': selectedNumCols,
// // // // // // // //         },
// // // // // // // //       );
// // // // // // // //       setState(() {
// // // // // // // //         reportData = List.from(res);
// // // // // // // //         _applyLocalFilters(); // تطبيق الفلاتر الموجودة مسبقاً على البيانات الجديدة
// // // // // // // //         loading = false;
// // // // // // // //       });
// // // // // // // //     } catch (e) {
// // // // // // // //       setState(() => loading = false);
// // // // // // // //       if (mounted) {
// // // // // // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // // // // // //           SnackBar(content: Text('خطأ في تحميل التقرير: $e')),
// // // // // // // //         );
// // // // // // // //       }
// // // // // // // //     }
// // // // // // // //   }

// // // // // // // //   void _applyLocalFilters() {
// // // // // // // //     setState(() {
// // // // // // // //       filteredData = reportData.where((row) {
// // // // // // // //         bool match = true;
// // // // // // // //         activeFilters.forEach((colKey, selectedValues) {
// // // // // // // //           if (selectedValues.isNotEmpty) {
// // // // // // // //             String rowValue = "";
// // // // // // // //             if (colKey == 'crop_name') {
// // // // // // // //               rowValue = row['crop_name']?.toString() ?? "";
// // // // // // // //             } else if (colKey == 'class') {
// // // // // // // //               rowValue = row['class']?.toString() ?? "";
// // // // // // // //             } else {
// // // // // // // //               final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
// // // // // // // //               rowValue = extra[colKey]?.toString() ?? "";
// // // // // // // //             }
// // // // // // // //             if (!selectedValues.contains(rowValue)) match = false;
// // // // // // // //           }
// // // // // // // //         });
// // // // // // // //         return match;
// // // // // // // //       }).toList();
// // // // // // // //     });
// // // // // // // //   }

// // // // // // // //   num get totalNetWeight => filteredData.fold(0, (s, e) => s + (e['net_weight'] ?? 0));

// // // // // // // //   num sumNumericColumn(String columnName) {
// // // // // // // //     if (filteredData.isEmpty) return 0;
// // // // // // // //     return filteredData.fold(0, (s, e) {
// // // // // // // //       final extra = e['extra_columns'] as Map<String, dynamic>? ?? {};
// // // // // // // //       final val = extra[columnName];
// // // // // // // //       return s + (val is num ? val : (double.tryParse(val?.toString() ?? '0') ?? 0));
// // // // // // // //     });
// // // // // // // //   }

// // // // // // // //   // --- دالة لبناء ديالوج الفلترة المتقدم ---
// // // // // // // //   void _showFilterDialog(String title, String colKey) {
// // // // // // // //     // 1. تقليص اللستة بناءً على الفلاتر الأخرى (Cross-filtering)
// // // // // // // //     // نأخذ البيانات المفلترة حالياً *بدون* تأثير فلتر هذا العمود نفسه
// // // // // // // //     List tempFiltered = reportData.where((row) {
// // // // // // // //       bool match = true;
// // // // // // // //       activeFilters.forEach((key, values) {
// // // // // // // //         if (key != colKey && values.isNotEmpty) {
// // // // // // // //           String val = "";
// // // // // // // //           if (key == 'crop_name') val = row['crop_name']?.toString() ?? "";
// // // // // // // //           else if (key == 'class') val = row['class']?.toString() ?? "";
// // // // // // // //           else {
// // // // // // // //             final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
// // // // // // // //             val = extra[key]?.toString() ?? "";
// // // // // // // //           }
// // // // // // // //           if (!values.contains(val)) match = false;
// // // // // // // //         }
// // // // // // // //       });
// // // // // // // //       return match;
// // // // // // // //     }).toList();

// // // // // // // //     Set<String> uniqueValues = {};
// // // // // // // //     for (var row in tempFiltered) {
// // // // // // // //       if (colKey == 'crop_name') uniqueValues.add(row['crop_name']?.toString() ?? "");
// // // // // // // //       else if (colKey == 'class') uniqueValues.add(row['class']?.toString() ?? "");
// // // // // // // //       else {
// // // // // // // //         final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
// // // // // // // //         uniqueValues.add(extra[colKey]?.toString() ?? "");
// // // // // // // //       }
// // // // // // // //     }
// // // // // // // //     List<String> sortedList = uniqueValues.where((v) => v.isNotEmpty).toList()..sort();
    
// // // // // // // //     List<String> tempSelected = List.from(activeFilters[colKey] ?? []);
// // // // // // // //     String searchQuery = "";

// // // // // // // //     showDialog(
// // // // // // // //       context: context,
// // // // // // // //       builder: (context) => StatefulBuilder(
// // // // // // // //         builder: (context, setDialogState) {
// // // // // // // //           List<String> displayList = sortedList
// // // // // // // //               .where((item) => item.toLowerCase().contains(searchQuery.toLowerCase()))
// // // // // // // //               .toList();

// // // // // // // //           return AlertDialog(
// // // // // // // //             title: Text('فلترة $title'),
// // // // // // // //             content: SizedBox(
// // // // // // // //               width: double.maxFinite,
// // // // // // // //               child: Column(
// // // // // // // //                 mainAxisSize: MainAxisSize.min,
// // // // // // // //                 children: [
// // // // // // // //                   TextField(
// // // // // // // //                     decoration: const InputDecoration(
// // // // // // // //                       hintText: 'بحث داخل القائمة...',
// // // // // // // //                       prefixIcon: Icon(Icons.search),
// // // // // // // //                       border: OutlineInputBorder(),
// // // // // // // //                     ),
// // // // // // // //                     onChanged: (v) => setDialogState(() => searchQuery = v),
// // // // // // // //                   ),
// // // // // // // //                   const SizedBox(height: 10),
// // // // // // // //                   ConstrainedBox(
// // // // // // // //                     constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
// // // // // // // //                     child: ListView.builder(
// // // // // // // //                       shrinkWrap: true,
// // // // // // // //                       itemCount: displayList.length,
// // // // // // // //                       itemBuilder: (context, index) {
// // // // // // // //                         final val = displayList[index];
// // // // // // // //                         return CheckboxListTile(
// // // // // // // //                           title: Text(val),
// // // // // // // //                           value: tempSelected.contains(val),
// // // // // // // //                           onChanged: (checked) {
// // // // // // // //                             setDialogState(() {
// // // // // // // //                               if (checked!) tempSelected.add(val);
// // // // // // // //                               else tempSelected.remove(val);
// // // // // // // //                             });
// // // // // // // //                           },
// // // // // // // //                         );
// // // // // // // //                       },
// // // // // // // //                     ),
// // // // // // // //                   ),
// // // // // // // //                 ],
// // // // // // // //               ),
// // // // // // // //             ),
// // // // // // // //             actions: [
// // // // // // // //               TextButton(
// // // // // // // //                 onPressed: () {
// // // // // // // //                   setState(() {
// // // // // // // //                     activeFilters[colKey] = [];
// // // // // // // //                     _applyLocalFilters();
// // // // // // // //                   });
// // // // // // // //                   Navigator.pop(context);
// // // // // // // //                 },
// // // // // // // //                 child: const Text('إلغاء الكل', style: TextStyle(color: Colors.red)),
// // // // // // // //               ),
// // // // // // // //               ElevatedButton(
// // // // // // // //                 onPressed: () {
// // // // // // // //                   setState(() {
// // // // // // // //                     activeFilters[colKey] = tempSelected;
// // // // // // // //                     _applyLocalFilters();
// // // // // // // //                   });
// // // // // // // //                   Navigator.pop(context);
// // // // // // // //                 },
// // // // // // // //                 child: const Text('تطبيق'),
// // // // // // // //               ),
// // // // // // // //             ],
// // // // // // // //           );
// // // // // // // //         },
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //   }

// // // // // // // //   Widget _buildFilterHeader(String title, String colKey) {
// // // // // // // //     bool isFiltered = activeFilters[colKey]?.isNotEmpty ?? false;
// // // // // // // //     return InkWell(
// // // // // // // //       onTap: () => _showFilterDialog(title, colKey),
// // // // // // // //       child: Row(
// // // // // // // //         mainAxisSize: MainAxisSize.min,
// // // // // // // //         children: [
// // // // // // // //           Text(title),
// // // // // // // //           Icon(
// // // // // // // //             Icons.filter_alt,
// // // // // // // //             size: 16,
// // // // // // // //             color: isFiltered ? Colors.blue : Colors.grey[400],
// // // // // // // //           ),
// // // // // // // //         ],
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //   }

// // // // // // // //   @override
// // // // // // // //   Widget build(BuildContext context) {
// // // // // // // //     return Directionality(
// // // // // // // //       textDirection: TextDirection.rtl,
// // // // // // // //       child: Scaffold(
// // // // // // // //         backgroundColor: Colors.grey[100],
// // // // // // // //         appBar: AppBar(
// // // // // // // //           title: const Text('تقرير التخطيط'),
// // // // // // // //           centerTitle: true,
// // // // // // // //           actions: [
// // // // // // // //             IconButton(
// // // // // // // //               icon: const Icon(Icons.refresh),
// // // // // // // //               onPressed: loadReport,
// // // // // // // //               tooltip: 'تحديث البيانات مع بقاء الفلاتر',
// // // // // // // //             )
// // // // // // // //           ],
// // // // // // // //         ),
// // // // // // // //         body: Column(
// // // // // // // //           children: [
// // // // // // // //             _filtersSection(),
// // // // // // // //             _summaryCards(),
// // // // // // // //             Expanded(
// // // // // // // //               child: loading
// // // // // // // //                   ? const Center(child: CircularProgressIndicator())
// // // // // // // //                   : _tableSection(),
// // // // // // // //             ),
// // // // // // // //           ],
// // // // // // // //         ),
// // // // // // // //         floatingActionButton: FloatingActionButton(
// // // // // // // //           onPressed: loadReport,
// // // // // // // //           child: const Icon(Icons.search),
// // // // // // // //         ),
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //   }

// // // // // // // //   Widget _filtersSection() {
// // // // // // // //     return Card(
// // // // // // // //       margin: const EdgeInsets.all(12),
// // // // // // // //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
// // // // // // // //       child: Padding(
// // // // // // // //         padding: const EdgeInsets.all(16),
// // // // // // // //         child: Column(
// // // // // // // //           children: [
// // // // // // // //             Row(
// // // // // // // //               children: [
// // // // // // // //                 Expanded(
// // // // // // // //                   child: DropdownButtonFormField<String?>(
// // // // // // // //                     decoration: const InputDecoration(labelText: 'الصنف الأساسي', border: OutlineInputBorder()),
// // // // // // // //                     value: selectedCrop,
// // // // // // // //                     items: [
// // // // // // // //                       const DropdownMenuItem(value: null, child: Text('الكل')),
// // // // // // // //                       ...cropList.map((c) => DropdownMenuItem(value: c, child: Text(c))),
// // // // // // // //                     ],
// // // // // // // //                     onChanged: (v) => setState(() => selectedCrop = v),
// // // // // // // //                   ),
// // // // // // // //                 ),
// // // // // // // //                 const SizedBox(width: 10),
// // // // // // // //                 Expanded(
// // // // // // // //                   child: DropdownButtonFormField<String?>(
// // // // // // // //                     decoration: const InputDecoration(labelText: 'الدرجة الأساسية', border: OutlineInputBorder()),
// // // // // // // //                     value: selectedClass,
// // // // // // // //                     items: [
// // // // // // // //                       const DropdownMenuItem(value: null, child: Text('الكل')),
// // // // // // // //                       ...classList.map((c) => DropdownMenuItem(value: c, child: Text(c))),
// // // // // // // //                     ],
// // // // // // // //                     onChanged: (v) => setState(() => selectedClass = v),
// // // // // // // //                   ),
// // // // // // // //                 ),
// // // // // // // //                 const SizedBox(width: 8),
// // // // // // // //                 IconButton.filledTonal(
// // // // // // // //                   onPressed: _showColumnsOptions,
// // // // // // // //                   icon: const Icon(Icons.settings),
// // // // // // // //                   tooltip: 'إعدادات الأعمدة',
// // // // // // // //                 ),
// // // // // // // //               ],
// // // // // // // //             ),
// // // // // // // //             const SizedBox(height: 12),
// // // // // // // //             Row(
// // // // // // // //               mainAxisAlignment: MainAxisAlignment.spaceAround,
// // // // // // // //               children: [
// // // // // // // //                 _dateItem('من', fromDate, (d) => setState(() => fromDate = d)),
// // // // // // // //                 _dateItem('إلى', toDate, (d) => setState(() => toDate = d)),
// // // // // // // //                 if (activeFilters.values.any((v) => v.isNotEmpty))
// // // // // // // //                   TextButton.icon(
// // // // // // // //                     onPressed: () => setState(() {
// // // // // // // //                       activeFilters.clear();
// // // // // // // //                       _applyLocalFilters();
// // // // // // // //                     }),
// // // // // // // //                     icon: const Icon(Icons.clear_all, color: Colors.red),
// // // // // // // //                     label: const Text('مسح الفلاتر', style: TextStyle(color: Colors.red)),
// // // // // // // //                   )
// // // // // // // //               ],
// // // // // // // //             ),
// // // // // // // //           ],
// // // // // // // //         ),
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //   }

// // // // // // // //   Widget _summaryCards() {
// // // // // // // //     return Padding(
// // // // // // // //       padding: const EdgeInsets.symmetric(horizontal: 12),
// // // // // // // //       child: Row(
// // // // // // // //         children: [
// // // // // // // //           _cardInfo('إجمالي الكمية (المصفاة)', formatNum(totalNetWeight), Colors.blue),
// // // // // // // //         ],
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //   }

// // // // // // // //   Widget _cardInfo(String title, String value, Color color) {
// // // // // // // //     return Expanded(
// // // // // // // //       child: Card(
// // // // // // // //         color: color.withOpacity(0.1),
// // // // // // // //         child: Padding(
// // // // // // // //           padding: const EdgeInsets.all(12),
// // // // // // // //           child: Column(
// // // // // // // //             children: [
// // // // // // // //               Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
// // // // // // // //               Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
// // // // // // // //             ],
// // // // // // // //           ),
// // // // // // // //         ),
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //   }

// // // // // // // //   Widget _tableSection() {
// // // // // // // //     if (filteredData.isEmpty && reportData.isEmpty) return const Center(child: Text('لا توجد بيانات متاحة'));
    
// // // // // // // //     return Card(
// // // // // // // //       margin: const EdgeInsets.all(12),
// // // // // // // //       child: Scrollbar(
// // // // // // // //         child: SingleChildScrollView(
// // // // // // // //           scrollDirection: Axis.vertical,
// // // // // // // //           child: SingleChildScrollView(
// // // // // // // //             scrollDirection: Axis.horizontal,
// // // // // // // //             child: DataTable(
// // // // // // // //               headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
// // // // // // // //               columns: [
// // // // // // // //                 DataColumn(label: _buildFilterHeader('الصنف', 'crop_name')),
// // // // // // // //                 DataColumn(label: _buildFilterHeader('الدرجة', 'class')),
// // // // // // // //                 const DataColumn(label: Text('الكمية')),
// // // // // // // //                 ...selectedTextCols.map((c) => DataColumn(label: _buildFilterHeader(textColumnsMap[c] ?? c, c))),
// // // // // // // //                 ...selectedNumCols.map((c) => DataColumn(label: Text(numericColumnsMap[c] ?? c))),
// // // // // // // //               ],
// // // // // // // //               rows: [
// // // // // // // //                 if (filteredData.isEmpty)
// // // // // // // //                    const DataRow(cells: [
// // // // // // // //                     DataCell(Text('لا توجد نتائج تطابق الفلتر')),
// // // // // // // //                     DataCell(Text('')), DataCell(Text('')),
// // // // // // // //                     // سنحتاج لإضافة خلايا فارغة هنا بناء على طول الأعمدة لتجنب الأخطاء
// // // // // // // //                   ])
// // // // // // // //                 else
// // // // // // // //                 ...filteredData.map((row) {
// // // // // // // //                   final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
// // // // // // // //                   return DataRow(cells: [
// // // // // // // //                     DataCell(Text(row['crop_name'] ?? '')),
// // // // // // // //                     DataCell(Text(row['class'] ?? '')),
// // // // // // // //                     DataCell(Text(formatNum(row['net_weight']))),
// // // // // // // //                     ...selectedTextCols.map((c) => DataCell(Text(extra[c]?.toString() ?? '-'))),
// // // // // // // //                     ...selectedNumCols.map((c) => DataCell(Text(formatNum(extra[c])))),
// // // // // // // //                   ]);
// // // // // // // //                 }),
// // // // // // // //                 DataRow(
// // // // // // // //                   color: MaterialStateProperty.all(Colors.amber[50]),
// // // // // // // //                   cells: [
// // // // // // // //                     const DataCell(Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold))),
// // // // // // // //                     const DataCell(Text('-')),
// // // // // // // //                     DataCell(Text(formatNum(totalNetWeight), style: const TextStyle(fontWeight: FontWeight.bold))),
// // // // // // // //                     ...selectedTextCols.map((_) => const DataCell(Text(''))),
// // // // // // // //                     ...selectedNumCols.map((c) => DataCell(
// // // // // // // //                           Text(formatNum(sumNumericColumn(c)), style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // // // // //                         )),
// // // // // // // //                   ],
// // // // // // // //                 ),
// // // // // // // //               ],
// // // // // // // //             ),
// // // // // // // //           ),
// // // // // // // //         ),
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //   }

// // // // // // // //   void _showColumnsOptions() {
// // // // // // // //     showDialog(
// // // // // // // //       context: context,
// // // // // // // //       builder: (context) => StatefulBuilder(
// // // // // // // //         builder: (context, setLocal) => AlertDialog(
// // // // // // // //           title: const Text('إعدادات الأعمدة'),
// // // // // // // //           content: SingleChildScrollView(
// // // // // // // //             child: Column(
// // // // // // // //               mainAxisSize: MainAxisSize.min,
// // // // // // // //               crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // //               children: [
// // // // // // // //                 const Text('أعمدة النصوص (تفصيلية):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
// // // // // // // //                 ...textColumnsMap.entries.map((entry) => CheckboxListTile(
// // // // // // // //                       title: Text(entry.value),
// // // // // // // //                       value: selectedTextCols.contains(entry.key),
// // // // // // // //                       onChanged: (v) => setLocal(() => v! ? selectedTextCols.add(entry.key) : selectedTextCols.remove(entry.key)),
// // // // // // // //                     )),
// // // // // // // //                 const Divider(),
// // // // // // // //                 const Text('أعمدة الأرقام (مجاميع):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
// // // // // // // //                 ...numericColumnsMap.entries.map((entry) => CheckboxListTile(
// // // // // // // //                       title: Text(entry.value),
// // // // // // // //                       value: selectedNumCols.contains(entry.key),
// // // // // // // //                       onChanged: (v) => setLocal(() => v! ? selectedNumCols.add(entry.key) : selectedNumCols.remove(entry.key)),
// // // // // // // //                     )),
// // // // // // // //               ],
// // // // // // // //             ),
// // // // // // // //           ),
// // // // // // // //           actions: [
// // // // // // // //             TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
// // // // // // // //             ElevatedButton(
// // // // // // // //                 onPressed: () {
// // // // // // // //                   _saveColumns();
// // // // // // // //                   Navigator.pop(context);
// // // // // // // //                   loadReport();
// // // // // // // //                 },
// // // // // // // //                 child: const Text('تطبيق وحفظ')),
// // // // // // // //           ],
// // // // // // // //         ),
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //   }

// // // // // // // //   Widget _dateItem(String label, DateTime value, Function(DateTime) onPick) {
// // // // // // // //     return InkWell(
// // // // // // // //       onTap: () async {
// // // // // // // //         final d = await showDatePicker(context: context, initialDate: value, firstDate: DateTime(2020), lastDate: DateTime(2030));
// // // // // // // //         if (d != null) {
// // // // // // // //           onPick(d);
// // // // // // // //           loadReport();
// // // // // // // //         }
// // // // // // // //       },
// // // // // // // //       child: Column(
// // // // // // // //         children: [
// // // // // // // //           Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
// // // // // // // //           Text(intl.DateFormat('yyyy-MM-dd').format(value), style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // // // // //         ],
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // // }
// // // // // // // import 'package:flutter/material.dart';
// // // // // // // import 'package:intl/intl.dart' as intl;
// // // // // // // import 'package:supabase_flutter/supabase_flutter.dart';
// // // // // // // import 'package:shared_preferences/shared_preferences.dart';

// // // // // // // class PlanninReportScreen extends StatefulWidget {
// // // // // // //   const PlanninReportScreen({super.key});

// // // // // // //   @override
// // // // // // //   State<PlanninReportScreen> createState() => _FarzaReportScreenState();
// // // // // // // }

// // // // // // // class _FarzaReportScreenState extends State<PlanninReportScreen> {
// // // // // // //   final supabase = Supabase.instance.client;

// // // // // // //   DateTime fromDate = DateTime(2025, 12, 1);
// // // // // // //   DateTime toDate = DateTime.now();
  
// // // // // // //   // الفلاتر البولينية الجديدة
// // // // // // //   bool? filterAcceptedForOperation; 
// // // // // // //   bool? filterIsConvertedIntoInvoice;

// // // // // // //   final Map<String, String> textColumnsMap = {
// // // // // // //     'Date': 'التاريخ',
// // // // // // //     'ShippingDate': 'تاريخ الشحن',
// // // // // // //     'Country': 'الدولة',
// // // // // // //     'Count': 'الحجم',
// // // // // // //     'CTNType': 'نوع الكرتون',
// // // // // // //     'CTNWeight': 'وزن الكرتون',
// // // // // // //     'Brand': 'الماركه',
// // // // // // //     'Serial': 'رقم الطلبية',
// // // // // // //   };

// // // // // // //   final Map<String, String> numericColumnsMap = {
// // // // // // //     'PalletsCount': 'كمية الطلبية',
// // // // // // //     'Production_Pallet': 'كمية الانتاج',
// // // // // // //     'Shipping_Pallet': 'كمية المشحون',
// // // // // // //     'balance': 'مطلوب انتاجه',
// // // // // // //   };

// // // // // // //   List<String> selectedTextCols = [];
// // // // // // //   List<String> selectedNumCols = [];

// // // // // // //   List reportData = []; 
// // // // // // //   List filteredData = []; 
// // // // // // //   bool loading = false;

// // // // // // //   Map<String, List<String>> activeFilters = {};

// // // // // // //   @override
// // // // // // //   void initState() {
// // // // // // //     super.initState();
// // // // // // //     _loadSavedColumns().then((_) {
// // // // // // //       loadReport();
// // // // // // //     });
// // // // // // //   }

// // // // // // //   Future<void> _loadSavedColumns() async {
// // // // // // //     final prefs = await SharedPreferences.getInstance();
// // // // // // //     setState(() {
// // // // // // //       selectedTextCols = prefs.getStringList('selectedTextCols') ?? [];
// // // // // // //       selectedNumCols = prefs.getStringList('selectedNumCols') ?? [];
// // // // // // //     });
// // // // // // //   }

// // // // // // //   Future<void> _saveColumns() async {
// // // // // // //     final prefs = await SharedPreferences.getInstance();
// // // // // // //     await prefs.setStringList('selectedTextCols', selectedTextCols);
// // // // // // //     await prefs.setStringList('selectedNumCols', selectedNumCols);
// // // // // // //   }

// // // // // // //   String formatNum(dynamic v, {bool isMoney = true}) {
// // // // // // //     if (v == null) return isMoney ? '0.00' : '0';
// // // // // // //     final formatter = intl.NumberFormat.decimalPattern();
// // // // // // //     if (isMoney) {
// // // // // // //       formatter.minimumFractionDigits = 2;
// // // // // // //       formatter.maximumFractionDigits = 2;
// // // // // // //     }
// // // // // // //     return formatter.format(v is num ? v : double.tryParse(v.toString()) ?? 0);
// // // // // // //   }

// // // // // // //   Future<void> loadReport() async {
// // // // // // //     setState(() => loading = true);
// // // // // // //     try {
// // // // // // //       final res = await supabase.rpc(
// // // // // // //         'get_planning_report',
// // // // // // //         params: {
// // // // // // //           'p_date_from': intl.DateFormat('yyyy-MM-dd').format(fromDate),
// // // // // // //           'p_date_to': intl.DateFormat('yyyy-MM-dd').format(toDate),
// // // // // // //           'p_crop_name': null, 
// // // // // // //           'p_crop_class': null,
// // // // // // //           'p_group_columns': selectedTextCols,
// // // // // // //           'p_sum_columns': selectedNumCols,
// // // // // // //         },
// // // // // // //       );
// // // // // // //       setState(() {
// // // // // // //         reportData = List.from(res);
// // // // // // //         _applyLocalFilters(); 
// // // // // // //         loading = false;
// // // // // // //       });
// // // // // // //     } catch (e) {
// // // // // // //       setState(() => loading = false);
// // // // // // //       if (mounted) {
// // // // // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // // // // //           SnackBar(content: Text('خطأ في تحميل التقرير: $e')),
// // // // // // //         );
// // // // // // //       }
// // // // // // //     }
// // // // // // //   }

// // // // // // //   void _applyLocalFilters() {
// // // // // // //     setState(() {
// // // // // // //       filteredData = reportData.where((row) {
// // // // // // //         bool match = true;

// // // // // // //         // 1. الفلاتر البولينية الجديدة
// // // // // // //         if (filterAcceptedForOperation != null) {
// // // // // // //           if (row['AcceptedForOperation'] != filterAcceptedForOperation) match = false;
// // // // // // //         }
// // // // // // //         if (filterIsConvertedIntoInvoice != null) {
// // // // // // //           if (row['IsConvertedIntoInvoice'] != filterIsConvertedIntoInvoice) match = false;
// // // // // // //         }

// // // // // // //         // 2. فلاتر الأعمدة الديناميكية
// // // // // // //         activeFilters.forEach((colKey, selectedValues) {
// // // // // // //           if (selectedValues.isNotEmpty) {
// // // // // // //             String rowValue = "";
// // // // // // //             if (colKey == 'crop_name') {
// // // // // // //               rowValue = row['crop_name']?.toString() ?? "";
// // // // // // //             } else if (colKey == 'class') {
// // // // // // //               rowValue = row['class']?.toString() ?? "";
// // // // // // //             } else {
// // // // // // //               final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
// // // // // // //               rowValue = extra[colKey]?.toString() ?? "";
// // // // // // //             }
// // // // // // //             if (!selectedValues.contains(rowValue)) match = false;
// // // // // // //           }
// // // // // // //         });
// // // // // // //         return match;
// // // // // // //       }).toList();
// // // // // // //     });
// // // // // // //   }

// // // // // // //   num get totalNetWeight => filteredData.fold(0, (s, e) => s + (e['net_weight'] ?? 0));

// // // // // // //   num sumNumericColumn(String columnName) {
// // // // // // //     if (filteredData.isEmpty) return 0;
// // // // // // //     return filteredData.fold(0, (s, e) {
// // // // // // //       final extra = e['extra_columns'] as Map<String, dynamic>? ?? {};
// // // // // // //       final val = extra[columnName];
// // // // // // //       return s + (val is num ? val : (double.tryParse(val?.toString() ?? '0') ?? 0));
// // // // // // //     });
// // // // // // //   }

// // // // // // //   void _showFilterDialog(String title, String colKey) {
// // // // // // //     List tempFiltered = reportData.where((row) {
// // // // // // //       bool match = true;
// // // // // // //       if (filterAcceptedForOperation != null && row['AcceptedForOperation'] != filterAcceptedForOperation) match = false;
// // // // // // //       if (filterIsConvertedIntoInvoice != null && row['IsConvertedIntoInvoice'] != filterIsConvertedIntoInvoice) match = false;
      
// // // // // // //       activeFilters.forEach((key, values) {
// // // // // // //         if (key != colKey && values.isNotEmpty) {
// // // // // // //           String val = "";
// // // // // // //           if (key == 'crop_name') val = row['crop_name']?.toString() ?? "";
// // // // // // //           else if (key == 'class') val = row['class']?.toString() ?? "";
// // // // // // //           else {
// // // // // // //             final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
// // // // // // //             val = extra[key]?.toString() ?? "";
// // // // // // //           }
// // // // // // //           if (!values.contains(val)) match = false;
// // // // // // //         }
// // // // // // //       });
// // // // // // //       return match;
// // // // // // //     }).toList();

// // // // // // //     Set<String> uniqueValues = {};
// // // // // // //     for (var row in tempFiltered) {
// // // // // // //       if (colKey == 'crop_name') uniqueValues.add(row['crop_name']?.toString() ?? "");
// // // // // // //       else if (colKey == 'class') uniqueValues.add(row['class']?.toString() ?? "");
// // // // // // //       else {
// // // // // // //         final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
// // // // // // //         uniqueValues.add(extra[colKey]?.toString() ?? "");
// // // // // // //       }
// // // // // // //     }
// // // // // // //     List<String> sortedList = uniqueValues.where((v) => v.isNotEmpty).toList()..sort();
// // // // // // //     List<String> tempSelected = List.from(activeFilters[colKey] ?? []);
// // // // // // //     String searchQuery = "";

// // // // // // //     showDialog(
// // // // // // //       context: context,
// // // // // // //       builder: (context) => StatefulBuilder(
// // // // // // //         builder: (context, setDialogState) {
// // // // // // //           List<String> displayList = sortedList
// // // // // // //               .where((item) => item.toLowerCase().contains(searchQuery.toLowerCase()))
// // // // // // //               .toList();

// // // // // // //           return AlertDialog(
// // // // // // //             title: Text('فلترة $title'),
// // // // // // //             content: SizedBox(
// // // // // // //               width: double.maxFinite,
// // // // // // //               child: Column(
// // // // // // //                 mainAxisSize: MainAxisSize.min,
// // // // // // //                 children: [
// // // // // // //                   TextField(
// // // // // // //                     decoration: const InputDecoration(
// // // // // // //                       hintText: 'بحث داخل القائمة...',
// // // // // // //                       prefixIcon: Icon(Icons.search),
// // // // // // //                       border: OutlineInputBorder(),
// // // // // // //                     ),
// // // // // // //                     onChanged: (v) => setDialogState(() => searchQuery = v),
// // // // // // //                   ),
// // // // // // //                   const SizedBox(height: 10),
// // // // // // //                   ConstrainedBox(
// // // // // // //                     constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
// // // // // // //                     child: ListView.builder(
// // // // // // //                       shrinkWrap: true,
// // // // // // //                       itemCount: displayList.length,
// // // // // // //                       itemBuilder: (context, index) {
// // // // // // //                         final val = displayList[index];
// // // // // // //                         return CheckboxListTile(
// // // // // // //                           title: Text(val),
// // // // // // //                           value: tempSelected.contains(val),
// // // // // // //                           onChanged: (checked) {
// // // // // // //                             setDialogState(() {
// // // // // // //                               if (checked!) tempSelected.add(val);
// // // // // // //                               else tempSelected.remove(val);
// // // // // // //                             });
// // // // // // //                           },
// // // // // // //                         );
// // // // // // //                       },
// // // // // // //                     ),
// // // // // // //                   ),
// // // // // // //                 ],
// // // // // // //               ),
// // // // // // //             ),
// // // // // // //             actions: [
// // // // // // //               TextButton(
// // // // // // //                 onPressed: () {
// // // // // // //                   setState(() {
// // // // // // //                     activeFilters[colKey] = [];
// // // // // // //                     _applyLocalFilters();
// // // // // // //                   });
// // // // // // //                   Navigator.pop(context);
// // // // // // //                 },
// // // // // // //                 child: const Text('إلغاء الكل', style: TextStyle(color: Colors.red)),
// // // // // // //               ),
// // // // // // //               ElevatedButton(
// // // // // // //                 onPressed: () {
// // // // // // //                   setState(() {
// // // // // // //                     activeFilters[colKey] = tempSelected;
// // // // // // //                     _applyLocalFilters();
// // // // // // //                   });
// // // // // // //                   Navigator.pop(context);
// // // // // // //                 },
// // // // // // //                 child: const Text('تطبيق'),
// // // // // // //               ),
// // // // // // //             ],
// // // // // // //           );
// // // // // // //         },
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }

// // // // // // //   Widget _buildFilterHeader(String title, String colKey) {
// // // // // // //     bool isFiltered = activeFilters[colKey]?.isNotEmpty ?? false;
// // // // // // //     return InkWell(
// // // // // // //       onTap: () => _showFilterDialog(title, colKey),
// // // // // // //       child: Row(
// // // // // // //         mainAxisSize: MainAxisSize.min,
// // // // // // //         children: [
// // // // // // //           Text(title),
// // // // // // //           Icon(
// // // // // // //             Icons.filter_alt,
// // // // // // //             size: 16,
// // // // // // //             color: isFiltered ? Colors.blue : Colors.grey[400],
// // // // // // //           ),
// // // // // // //         ],
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }

// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     return Directionality(
// // // // // // //       textDirection: TextDirection.rtl,
// // // // // // //       child: Scaffold(
// // // // // // //         backgroundColor: Colors.grey[100],
// // // // // // //         appBar: AppBar(
// // // // // // //           title: const Text('تقرير التخطيط'),
// // // // // // //           centerTitle: true,
// // // // // // //           actions: [
// // // // // // //             IconButton(
// // // // // // //               icon: const Icon(Icons.refresh),
// // // // // // //               onPressed: loadReport,
// // // // // // //             )
// // // // // // //           ],
// // // // // // //         ),
// // // // // // //         body: Column(
// // // // // // //           children: [
// // // // // // //             _filtersSection(),
// // // // // // //             _summaryCards(),
// // // // // // //             Expanded(
// // // // // // //               child: loading
// // // // // // //                   ? const Center(child: CircularProgressIndicator())
// // // // // // //                   : _tableSection(),
// // // // // // //             ),
// // // // // // //           ],
// // // // // // //         ),
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }

// // // // // // //   Widget _filtersSection() {
// // // // // // //     return Card(
// // // // // // //       margin: const EdgeInsets.all(12),
// // // // // // //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
// // // // // // //       child: Padding(
// // // // // // //         padding: const EdgeInsets.all(12),
// // // // // // //         child: Column(
// // // // // // //           children: [
// // // // // // //             Row(
// // // // // // //               children: [
// // // // // // //                 // فلتر تحت التشغيل
// // // // // // //                 Expanded(
// // // // // // //                   child: CheckboxListTile(
// // // // // // //                     contentPadding: EdgeInsets.zero,
// // // // // // //                     title: const Text('تحت التشغيل', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
// // // // // // //                     value: filterAcceptedForOperation ?? false,
// // // // // // //                     controlAffinity: ListTileControlAffinity.leading,
// // // // // // //                     onChanged: (v) => setState(() {
// // // // // // //                       filterAcceptedForOperation = v == true ? true : null;
// // // // // // //                       _applyLocalFilters();
// // // // // // //                     }),
// // // // // // //                   ),
// // // // // // //                 ),
// // // // // // //                 // فلتر مغلق
// // // // // // //                 Expanded(
// // // // // // //                   child: CheckboxListTile(
// // // // // // //                     contentPadding: EdgeInsets.zero,
// // // // // // //                     title: const Text('مغلق', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
// // // // // // //                     value: filterIsConvertedIntoInvoice ?? false,
// // // // // // //                     controlAffinity: ListTileControlAffinity.leading,
// // // // // // //                     onChanged: (v) => setState(() {
// // // // // // //                       filterIsConvertedIntoInvoice = v == true ? true : null;
// // // // // // //                       _applyLocalFilters();
// // // // // // //                     }),
// // // // // // //                   ),
// // // // // // //                 ),
// // // // // // //                 IconButton.filledTonal(
// // // // // // //                   onPressed: _showColumnsOptions,
// // // // // // //                   icon: const Icon(Icons.settings),
// // // // // // //                 ),
// // // // // // //               ],
// // // // // // //             ),
// // // // // // //             const Divider(height: 10),
// // // // // // //             Row(
// // // // // // //               mainAxisAlignment: MainAxisAlignment.spaceAround,
// // // // // // //               children: [
// // // // // // //                 _dateItem('من', fromDate, () async {
// // // // // // //                   final picked = await showDatePicker(
// // // // // // //                     context: context,
// // // // // // //                     initialDate: fromDate,
// // // // // // //                     firstDate: DateTime(2020),
// // // // // // //                     lastDate: DateTime(2030),
// // // // // // //                   );
// // // // // // //                   if (picked != null) {
// // // // // // //                     setState(() {
// // // // // // //                       fromDate = picked;
// // // // // // //                       loadReport();
// // // // // // //                     });
// // // // // // //                   }
// // // // // // //                 }),
// // // // // // //                 _dateItem('إلى', toDate, () async {
// // // // // // //                   final picked = await showDatePicker(
// // // // // // //                     context: context,
// // // // // // //                     initialDate: toDate,
// // // // // // //                     firstDate: DateTime(2020),
// // // // // // //                     lastDate: DateTime(2030),
// // // // // // //                   );
// // // // // // //                   if (picked != null) {
// // // // // // //                     setState(() {
// // // // // // //                       toDate = picked;
// // // // // // //                       loadReport();
// // // // // // //                     });
// // // // // // //                   }
// // // // // // //                 }),
// // // // // // //                 TextButton(
// // // // // // //                   onPressed: () => setState(() {
// // // // // // //                     activeFilters.clear();
// // // // // // //                     filterAcceptedForOperation = null;
// // // // // // //                     filterIsConvertedIntoInvoice = null;
// // // // // // //                     _applyLocalFilters();
// // // // // // //                   }),
// // // // // // //                   child: const Text('تصفير الفلاتر', style: TextStyle(color: Colors.red, fontSize: 12)),
// // // // // // //                 )
// // // // // // //               ],
// // // // // // //             ),
// // // // // // //           ],
// // // // // // //         ),
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }

// // // // // // //   Widget _summaryCards() {
// // // // // // //     return Padding(
// // // // // // //       padding: const EdgeInsets.symmetric(horizontal: 12),
// // // // // // //       child: Row(
// // // // // // //         children: [
// // // // // // //           _cardInfo('إجمالي الكمية (المصفاة)', formatNum(totalNetWeight), Colors.blue),
// // // // // // //         ],
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }

// // // // // // //   Widget _cardInfo(String title, String value, Color color) {
// // // // // // //     return Expanded(
// // // // // // //       child: Card(
// // // // // // //         color: color.withOpacity(0.1),
// // // // // // //         child: Padding(
// // // // // // //           padding: const EdgeInsets.all(12),
// // // // // // //           child: Column(
// // // // // // //             children: [
// // // // // // //               Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
// // // // // // //               Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
// // // // // // //             ],
// // // // // // //           ),
// // // // // // //         ),
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }

// // // // // // //   Widget _tableSection() {
// // // // // // //     if (filteredData.isEmpty && reportData.isEmpty) return const Center(child: Text('لا توجد بيانات متاحة'));
    
// // // // // // //     return Card(
// // // // // // //       margin: const EdgeInsets.all(12),
// // // // // // //       child: Scrollbar(
// // // // // // //         child: SingleChildScrollView(
// // // // // // //           scrollDirection: Axis.vertical,
// // // // // // //           child: SingleChildScrollView(
// // // // // // //             scrollDirection: Axis.horizontal,
// // // // // // //             child: DataTable(
// // // // // // //               headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
// // // // // // //               columns: [
// // // // // // //                 DataColumn(label: _buildFilterHeader('الصنف', 'crop_name')),
// // // // // // //                 DataColumn(label: _buildFilterHeader('الدرجة', 'class')),
// // // // // // //                 const DataColumn(label: Text('الكمية')),
// // // // // // //                 ...selectedTextCols.map((c) => DataColumn(label: _buildFilterHeader(textColumnsMap[c] ?? c, c))),
// // // // // // //                 ...selectedNumCols.map((c) => DataColumn(label: Text(numericColumnsMap[c] ?? c))),
// // // // // // //               ],
// // // // // // //               rows: [
// // // // // // //                 ...filteredData.map((row) {
// // // // // // //                   final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
// // // // // // //                   return DataRow(cells: [
// // // // // // //                     DataCell(Text(row['crop_name'] ?? '')),
// // // // // // //                     DataCell(Text(row['class'] ?? '')),
// // // // // // //                     DataCell(Text(formatNum(row['net_weight']))),
// // // // // // //                     ...selectedTextCols.map((c) => DataCell(Text(extra[c]?.toString() ?? '-'))),
// // // // // // //                     ...selectedNumCols.map((c) => DataCell(Text(formatNum(extra[c])))),
// // // // // // //                   ]);
// // // // // // //                 }),
// // // // // // //                 DataRow(
// // // // // // //                   color: MaterialStateProperty.all(Colors.amber[50]),
// // // // // // //                   cells: [
// // // // // // //                     const DataCell(Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold))),
// // // // // // //                     const DataCell(Text('-')),
// // // // // // //                     DataCell(Text(formatNum(totalNetWeight), style: const TextStyle(fontWeight: FontWeight.bold))),
// // // // // // //                     ...selectedTextCols.map((_) => const DataCell(Text(''))),
// // // // // // //                     ...selectedNumCols.map((c) => DataCell(
// // // // // // //                           Text(formatNum(sumNumericColumn(c)), style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // // // //                         )),
// // // // // // //                   ],
// // // // // // //                 ),
// // // // // // //               ],
// // // // // // //             ),
// // // // // // //           ),
// // // // // // //         ),
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }

// // // // // // //   void _showColumnsOptions() {
// // // // // // //     showDialog(
// // // // // // //       context: context,
// // // // // // //       builder: (context) => StatefulBuilder(
// // // // // // //         builder: (context, setLocal) => AlertDialog(
// // // // // // //           title: const Text('إعدادات الأعمدة'),
// // // // // // //           content: SingleChildScrollView(
// // // // // // //             child: Column(
// // // // // // //               mainAxisSize: MainAxisSize.min,
// // // // // // //               crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // //               children: [
// // // // // // //                 const Text('أعمدة النصوص:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
// // // // // // //                 ...textColumnsMap.entries.map((entry) => CheckboxListTile(
// // // // // // //                       title: Text(entry.value),
// // // // // // //                       value: selectedTextCols.contains(entry.key),
// // // // // // //                       onChanged: (v) => setLocal(() => v! ? selectedTextCols.add(entry.key) : selectedTextCols.remove(entry.key)),
// // // // // // //                     )),
// // // // // // //                 const Divider(),
// // // // // // //                 const Text('أعمدة الأرقام:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
// // // // // // //                 ...numericColumnsMap.entries.map((entry) => CheckboxListTile(
// // // // // // //                       title: Text(entry.value),
// // // // // // //                       value: selectedNumCols.contains(entry.key),
// // // // // // //                       onChanged: (v) => setLocal(() => v! ? selectedNumCols.add(entry.key) : selectedNumCols.remove(entry.key)),
// // // // // // //                     )),
// // // // // // //               ],
// // // // // // //             ),
// // // // // // //           ),
// // // // // // //           actions: [
// // // // // // //             TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
// // // // // // //             ElevatedButton(
// // // // // // //                 onPressed: () {
// // // // // // //                   _saveColumns();
// // // // // // //                   Navigator.pop(context);
// // // // // // //                   loadReport();
// // // // // // //                 },
// // // // // // //                 child: const Text('تطبيق وحفظ')),
// // // // // // //           ],
// // // // // // //         ),
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }

// // // // // // //   Widget _dateItem(String label, DateTime value, VoidCallback onPick) {
// // // // // // //     return InkWell(
// // // // // // //       onTap: onPick,
// // // // // // //       child: Column(
// // // // // // //         children: [
// // // // // // //           Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
// // // // // // //           Text(intl.DateFormat('yyyy-MM-dd').format(value), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
// // // // // // //         ],
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // // }
// // // // // // import 'package:flutter/material.dart';
// // // // // // import 'package:intl/intl.dart' as intl;
// // // // // // import 'package:supabase_flutter/supabase_flutter.dart';
// // // // // // import 'package:shared_preferences/shared_preferences.dart';

// // // // // // class PlanninReportScreen extends StatefulWidget {
// // // // // //   const PlanninReportScreen({super.key});

// // // // // //   @override
// // // // // //   State<PlanninReportScreen> createState() => _FarzaReportScreenState();
// // // // // // }

// // // // // // class _FarzaReportScreenState extends State<PlanninReportScreen> {
// // // // // //   final supabase = Supabase.instance.client;

// // // // // //   DateTime fromDate = DateTime(2025, 12, 1);
// // // // // //   DateTime toDate = DateTime.now();
  
// // // // // //   // الفلاتر البولينية الجديدة
// // // // // //   bool? filterAcceptedForOperation; 
// // // // // //   bool? filterIsConvertedIntoInvoice;

// // // // // //   final Map<String, String> textColumnsMap = {
// // // // // //     'Date': 'التاريخ',
// // // // // //     'ShippingDate': 'تاريخ الشحن',
// // // // // //     'Country': 'الدولة',
// // // // // //     'Count': 'الحجم',
// // // // // //     'CTNType': 'نوع الكرتون',
// // // // // //     'CTNWeight': 'وزن الكرتون',
// // // // // //     'Brand': 'الماركه',
// // // // // //     'Serial': 'رقم الطلبية',
// // // // // //   };

// // // // // //   final Map<String, String> numericColumnsMap = {
// // // // // //     'PalletsCount': 'كمية الطلبية',
// // // // // //     'Production_Pallet': 'كمية الانتاج',
// // // // // //     'Shipping_Pallet': 'كمية المشحون',
// // // // // //     'balance': 'مطلوب انتاجه',
// // // // // //   };

// // // // // //   List<String> selectedTextCols = [];
// // // // // //   List<String> selectedNumCols = [];

// // // // // //   List reportData = []; 
// // // // // //   List filteredData = []; 
// // // // // //   bool loading = false;

// // // // // //   Map<String, List<String>> activeFilters = {};

// // // // // //   @override
// // // // // //   void initState() {
// // // // // //     super.initState();
// // // // // //     _loadSavedColumns().then((_) {
// // // // // //       loadReport();
// // // // // //     });
// // // // // //   }

// // // // // //   Future<void> _loadSavedColumns() async {
// // // // // //     final prefs = await SharedPreferences.getInstance();
// // // // // //     setState(() {
// // // // // //       selectedTextCols = prefs.getStringList('selectedTextCols') ?? [];
// // // // // //       selectedNumCols = prefs.getStringList('selectedNumCols') ?? [];
// // // // // //     });
// // // // // //   }

// // // // // //   Future<void> _saveColumns() async {
// // // // // //     final prefs = await SharedPreferences.getInstance();
// // // // // //     await prefs.setStringList('selectedTextCols', selectedTextCols);
// // // // // //     await prefs.setStringList('selectedNumCols', selectedNumCols);
// // // // // //   }

// // // // // //   String formatNum(dynamic v, {bool isMoney = true}) {
// // // // // //     if (v == null) return isMoney ? '0.00' : '0';
// // // // // //     final formatter = intl.NumberFormat.decimalPattern();
// // // // // //     if (isMoney) {
// // // // // //       formatter.minimumFractionDigits = 2;
// // // // // //       formatter.maximumFractionDigits = 2;
// // // // // //     }
// // // // // //     return formatter.format(v is num ? v : double.tryParse(v.toString()) ?? 0);
// // // // // //   }

// // // // // //   Future<void> loadReport() async {
// // // // // //     setState(() => loading = true);
// // // // // //     try {
// // // // // //       final res = await supabase.rpc(
// // // // // //         'get_planning_report',
// // // // // //         params: {
// // // // // //           'p_date_from': intl.DateFormat('yyyy-MM-dd').format(fromDate),
// // // // // //           'p_date_to': intl.DateFormat('yyyy-MM-dd').format(toDate),
// // // // // //           'p_crop_name': null, 
// // // // // //           'p_crop_class': null,
// // // // // //           'p_group_columns': selectedTextCols,
// // // // // //           'p_sum_columns': selectedNumCols,
// // // // // //         },
// // // // // //       );
// // // // // //       setState(() {
// // // // // //         reportData = List.from(res);
// // // // // //         _applyLocalFilters(); 
// // // // // //         loading = false;
// // // // // //       });
// // // // // //     } catch (e) {
// // // // // //       setState(() => loading = false);
// // // // // //       if (mounted) {
// // // // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // // // //           SnackBar(content: Text('خطأ في تحميل التقرير: $e')),
// // // // // //         );
// // // // // //       }
// // // // // //     }
// // // // // //   }

// // // // // //   // دالة مساعدة للتأكد من تحويل أي قيمة قادمة من الداتا بيز إلى Bool
// // // // // //   bool _toBool(dynamic val) {
// // // // // //     if (val == null) return false;
// // // // // //     if (val is bool) return val;
// // // // // //     if (val is num) return val == 1;
// // // // // //     if (val is String) {
// // // // // //       final s = val.toLowerCase();
// // // // // //       return s == 'true' || s == '1' || s == 'yes';
// // // // // //     }
// // // // // //     return false;
// // // // // //   }

// // // // // //   void _applyLocalFilters() {
// // // // // //     setState(() {
// // // // // //       filteredData = reportData.where((row) {
// // // // // //         bool match = true;

// // // // // //         // 1. الفلاتر البولينية الجديدة (تم تحسين التحقق باستخدام _toBool)
// // // // // //         if (filterAcceptedForOperation != null) {
// // // // // //           if (_toBool(row['AcceptedForOperation']) != filterAcceptedForOperation) match = false;
// // // // // //         }
// // // // // //         if (filterIsConvertedIntoInvoice != null) {
// // // // // //           if (_toBool(row['IsConvertedIntoInvoice']) != filterIsConvertedIntoInvoice) match = false;
// // // // // //         }

// // // // // //         // 2. فلاتر الأعمدة الديناميكية
// // // // // //         activeFilters.forEach((colKey, selectedValues) {
// // // // // //           if (selectedValues.isNotEmpty) {
// // // // // //             String rowValue = "";
// // // // // //             if (colKey == 'crop_name') {
// // // // // //               rowValue = row['crop_name']?.toString() ?? "";
// // // // // //             } else if (colKey == 'class') {
// // // // // //               rowValue = row['class']?.toString() ?? "";
// // // // // //             } else {
// // // // // //               final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
// // // // // //               rowValue = extra[colKey]?.toString() ?? "";
// // // // // //             }
// // // // // //             if (!selectedValues.contains(rowValue)) match = false;
// // // // // //           }
// // // // // //         });
// // // // // //         return match;
// // // // // //       }).toList();
// // // // // //     });
// // // // // //   }

// // // // // //   num get totalNetWeight => filteredData.fold(0, (s, e) => s + (e['net_weight'] ?? 0));

// // // // // //   num sumNumericColumn(String columnName) {
// // // // // //     if (filteredData.isEmpty) return 0;
// // // // // //     return filteredData.fold(0, (s, e) {
// // // // // //       final extra = e['extra_columns'] as Map<String, dynamic>? ?? {};
// // // // // //       final val = extra[columnName];
// // // // // //       return s + (val is num ? val : (double.tryParse(val?.toString() ?? '0') ?? 0));
// // // // // //     });
// // // // // //   }

// // // // // //   void _showFilterDialog(String title, String colKey) {
// // // // // //     List tempFiltered = reportData.where((row) {
// // // // // //       bool match = true;
// // // // // //       if (filterAcceptedForOperation != null && _toBool(row['AcceptedForOperation']) != filterAcceptedForOperation) match = false;
// // // // // //       if (filterIsConvertedIntoInvoice != null && _toBool(row['IsConvertedIntoInvoice']) != filterIsConvertedIntoInvoice) match = false;
      
// // // // // //       activeFilters.forEach((key, values) {
// // // // // //         if (key != colKey && values.isNotEmpty) {
// // // // // //           String val = "";
// // // // // //           if (key == 'crop_name') val = row['crop_name']?.toString() ?? "";
// // // // // //           else if (key == 'class') val = row['class']?.toString() ?? "";
// // // // // //           else {
// // // // // //             final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
// // // // // //             val = extra[key]?.toString() ?? "";
// // // // // //           }
// // // // // //           if (!values.contains(val)) match = false;
// // // // // //         }
// // // // // //       });
// // // // // //       return match;
// // // // // //     }).toList();

// // // // // //     Set<String> uniqueValues = {};
// // // // // //     for (var row in tempFiltered) {
// // // // // //       if (colKey == 'crop_name') uniqueValues.add(row['crop_name']?.toString() ?? "");
// // // // // //       else if (colKey == 'class') uniqueValues.add(row['class']?.toString() ?? "");
// // // // // //       else {
// // // // // //         final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
// // // // // //         uniqueValues.add(extra[colKey]?.toString() ?? "");
// // // // // //       }
// // // // // //     }
// // // // // //     List<String> sortedList = uniqueValues.where((v) => v.isNotEmpty).toList()..sort();
// // // // // //     List<String> tempSelected = List.from(activeFilters[colKey] ?? []);
// // // // // //     String searchQuery = "";

// // // // // //     showDialog(
// // // // // //       context: context,
// // // // // //       builder: (context) => StatefulBuilder(
// // // // // //         builder: (context, setDialogState) {
// // // // // //           List<String> displayList = sortedList
// // // // // //               .where((item) => item.toLowerCase().contains(searchQuery.toLowerCase()))
// // // // // //               .toList();

// // // // // //           return AlertDialog(
// // // // // //             title: Text('فلترة $title'),
// // // // // //             content: SizedBox(
// // // // // //               width: double.maxFinite,
// // // // // //               child: Column(
// // // // // //                 mainAxisSize: MainAxisSize.min,
// // // // // //                 children: [
// // // // // //                   TextField(
// // // // // //                     decoration: const InputDecoration(
// // // // // //                       hintText: 'بحث داخل القائمة...',
// // // // // //                       prefixIcon: Icon(Icons.search),
// // // // // //                       border: OutlineInputBorder(),
// // // // // //                     ),
// // // // // //                     onChanged: (v) => setDialogState(() => searchQuery = v),
// // // // // //                   ),
// // // // // //                   const SizedBox(height: 10),
// // // // // //                   ConstrainedBox(
// // // // // //                     constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
// // // // // //                     child: ListView.builder(
// // // // // //                       shrinkWrap: true,
// // // // // //                       itemCount: displayList.length,
// // // // // //                       itemBuilder: (context, index) {
// // // // // //                         final val = displayList[index];
// // // // // //                         return CheckboxListTile(
// // // // // //                           title: Text(val),
// // // // // //                           value: tempSelected.contains(val),
// // // // // //                           onChanged: (checked) {
// // // // // //                             setDialogState(() {
// // // // // //                               if (checked!) tempSelected.add(val);
// // // // // //                               else tempSelected.remove(val);
// // // // // //                             });
// // // // // //                           },
// // // // // //                         );
// // // // // //                       },
// // // // // //                     ),
// // // // // //                   ),
// // // // // //                 ],
// // // // // //               ),
// // // // // //             ),
// // // // // //             actions: [
// // // // // //               TextButton(
// // // // // //                 onPressed: () {
// // // // // //                   setState(() {
// // // // // //                     activeFilters[colKey] = [];
// // // // // //                     _applyLocalFilters();
// // // // // //                   });
// // // // // //                   Navigator.pop(context);
// // // // // //                 },
// // // // // //                 child: const Text('إلغاء الكل', style: TextStyle(color: Colors.red)),
// // // // // //               ),
// // // // // //               ElevatedButton(
// // // // // //                 onPressed: () {
// // // // // //                   setState(() {
// // // // // //                     activeFilters[colKey] = tempSelected;
// // // // // //                     _applyLocalFilters();
// // // // // //                   });
// // // // // //                   Navigator.pop(context);
// // // // // //                 },
// // // // // //                 child: const Text('تطبيق'),
// // // // // //               ),
// // // // // //             ],
// // // // // //           );
// // // // // //         },
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   Widget _buildFilterHeader(String title, String colKey) {
// // // // // //     bool isFiltered = activeFilters[colKey]?.isNotEmpty ?? false;
// // // // // //     return InkWell(
// // // // // //       onTap: () => _showFilterDialog(title, colKey),
// // // // // //       child: Row(
// // // // // //         mainAxisSize: MainAxisSize.min,
// // // // // //         children: [
// // // // // //           Text(title),
// // // // // //           Icon(
// // // // // //             Icons.filter_alt,
// // // // // //             size: 16,
// // // // // //             color: isFiltered ? Colors.blue : Colors.grey[400],
// // // // // //           ),
// // // // // //         ],
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return Directionality(
// // // // // //       textDirection: TextDirection.rtl,
// // // // // //       child: Scaffold(
// // // // // //         backgroundColor: Colors.grey[100],
// // // // // //         appBar: AppBar(
// // // // // //           title: const Text('تقرير التخطيط'),
// // // // // //           centerTitle: true,
// // // // // //           actions: [
// // // // // //             IconButton(
// // // // // //               icon: const Icon(Icons.refresh),
// // // // // //               onPressed: loadReport,
// // // // // //             )
// // // // // //           ],
// // // // // //         ),
// // // // // //         body: Column(
// // // // // //           children: [
// // // // // //             _filtersSection(),
// // // // // //             _summaryCards(),
// // // // // //             Expanded(
// // // // // //               child: loading
// // // // // //                   ? const Center(child: CircularProgressIndicator())
// // // // // //                   : _tableSection(),
// // // // // //             ),
// // // // // //           ],
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   Widget _filtersSection() {
// // // // // //     return Card(
// // // // // //       margin: const EdgeInsets.all(12),
// // // // // //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
// // // // // //       child: Padding(
// // // // // //         padding: const EdgeInsets.all(12),
// // // // // //         child: Column(
// // // // // //           children: [
// // // // // //             Row(
// // // // // //               children: [
// // // // // //                 // فلتر تحت التشغيل
// // // // // //                 Expanded(
// // // // // //                   child: CheckboxListTile(
// // // // // //                     contentPadding: EdgeInsets.zero,
// // // // // //                     title: const Text('تحت التشغيل', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
// // // // // //                     value: filterAcceptedForOperation ?? false,
// // // // // //                     controlAffinity: ListTileControlAffinity.leading,
// // // // // //                     onChanged: (v) => setState(() {
// // // // // //                       filterAcceptedForOperation = (v == true) ? true : null;
// // // // // //                       _applyLocalFilters();
// // // // // //                     }),
// // // // // //                   ),
// // // // // //                 ),
// // // // // //                 // فلتر مغلق
// // // // // //                 Expanded(
// // // // // //                   child: CheckboxListTile(
// // // // // //                     contentPadding: EdgeInsets.zero,
// // // // // //                     title: const Text('مغلق', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
// // // // // //                     value: filterIsConvertedIntoInvoice ?? false,
// // // // // //                     controlAffinity: ListTileControlAffinity.leading,
// // // // // //                     onChanged: (v) => setState(() {
// // // // // //                       filterIsConvertedIntoInvoice = (v == true) ? true : null;
// // // // // //                       _applyLocalFilters();
// // // // // //                     }),
// // // // // //                   ),
// // // // // //                 ),
// // // // // //                 IconButton.filledTonal(
// // // // // //                   onPressed: _showColumnsOptions,
// // // // // //                   icon: const Icon(Icons.settings),
// // // // // //                 ),
// // // // // //               ],
// // // // // //             ),
// // // // // //             const Divider(height: 10),
// // // // // //             Row(
// // // // // //               mainAxisAlignment: MainAxisAlignment.spaceAround,
// // // // // //               children: [
// // // // // //                 _dateItem('من', fromDate, () async {
// // // // // //                   final picked = await showDatePicker(
// // // // // //                     context: context,
// // // // // //                     initialDate: fromDate,
// // // // // //                     firstDate: DateTime(2020),
// // // // // //                     lastDate: DateTime(2030),
// // // // // //                   );
// // // // // //                   if (picked != null) {
// // // // // //                     setState(() {
// // // // // //                       fromDate = picked;
// // // // // //                       loadReport();
// // // // // //                     });
// // // // // //                   }
// // // // // //                 }),
// // // // // //                 _dateItem('إلى', toDate, () async {
// // // // // //                   final picked = await showDatePicker(
// // // // // //                     context: context,
// // // // // //                     initialDate: toDate,
// // // // // //                     firstDate: DateTime(2020),
// // // // // //                     lastDate: DateTime(2030),
// // // // // //                   );
// // // // // //                   if (picked != null) {
// // // // // //                     setState(() {
// // // // // //                       toDate = picked;
// // // // // //                       loadReport();
// // // // // //                     });
// // // // // //                   }
// // // // // //                 }),
// // // // // //                 TextButton(
// // // // // //                   onPressed: () => setState(() {
// // // // // //                     activeFilters.clear();
// // // // // //                     filterAcceptedForOperation = null;
// // // // // //                     filterIsConvertedIntoInvoice = null;
// // // // // //                     _applyLocalFilters();
// // // // // //                   }),
// // // // // //                   child: const Text('تصفير الفلاتر', style: TextStyle(color: Colors.red, fontSize: 12)),
// // // // // //                 )
// // // // // //               ],
// // // // // //             ),
// // // // // //           ],
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   Widget _summaryCards() {
// // // // // //     return Padding(
// // // // // //       padding: const EdgeInsets.symmetric(horizontal: 12),
// // // // // //       child: Row(
// // // // // //         children: [
// // // // // //           _cardInfo('إجمالي الكمية (المصفاة)', formatNum(totalNetWeight), Colors.blue),
// // // // // //         ],
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   Widget _cardInfo(String title, String value, Color color) {
// // // // // //     return Expanded(
// // // // // //       child: Card(
// // // // // //         color: color.withOpacity(0.1),
// // // // // //         child: Padding(
// // // // // //           padding: const EdgeInsets.all(12),
// // // // // //           child: Column(
// // // // // //             children: [
// // // // // //               Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
// // // // // //               Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
// // // // // //             ],
// // // // // //           ),
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   Widget _tableSection() {
// // // // // //     if (filteredData.isEmpty && reportData.isEmpty) return const Center(child: Text('لا توجد بيانات متاحة'));
    
// // // // // //     return Card(
// // // // // //       margin: const EdgeInsets.all(12),
// // // // // //       child: Scrollbar(
// // // // // //         child: SingleChildScrollView(
// // // // // //           scrollDirection: Axis.vertical,
// // // // // //           child: SingleChildScrollView(
// // // // // //             scrollDirection: Axis.horizontal,
// // // // // //             child: DataTable(
// // // // // //               headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
// // // // // //               columns: [
// // // // // //                 DataColumn(label: _buildFilterHeader('الصنف', 'crop_name')),
// // // // // //                 DataColumn(label: _buildFilterHeader('الدرجة', 'class')),
// // // // // //                 const DataColumn(label: Text('الكمية')),
// // // // // //                 ...selectedTextCols.map((c) => DataColumn(label: _buildFilterHeader(textColumnsMap[c] ?? c, c))),
// // // // // //                 ...selectedNumCols.map((c) => DataColumn(label: Text(numericColumnsMap[c] ?? c))),
// // // // // //               ],
// // // // // //               rows: [
// // // // // //                 ...filteredData.map((row) {
// // // // // //                   final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
// // // // // //                   return DataRow(cells: [
// // // // // //                     DataCell(Text(row['crop_name'] ?? '')),
// // // // // //                     DataCell(Text(row['class'] ?? '')),
// // // // // //                     DataCell(Text(formatNum(row['net_weight']))),
// // // // // //                     ...selectedTextCols.map((c) => DataCell(Text(extra[c]?.toString() ?? '-'))),
// // // // // //                     ...selectedNumCols.map((c) => DataCell(Text(formatNum(extra[c])))),
// // // // // //                   ]);
// // // // // //                 }),
// // // // // //                 DataRow(
// // // // // //                   color: MaterialStateProperty.all(Colors.amber[50]),
// // // // // //                   cells: [
// // // // // //                     const DataCell(Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold))),
// // // // // //                     const DataCell(Text('-')),
// // // // // //                     DataCell(Text(formatNum(totalNetWeight), style: const TextStyle(fontWeight: FontWeight.bold))),
// // // // // //                     ...selectedTextCols.map((_) => const DataCell(Text(''))),
// // // // // //                     ...selectedNumCols.map((c) => DataCell(
// // // // // //                           Text(formatNum(sumNumericColumn(c)), style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // // //                         )),
// // // // // //                   ],
// // // // // //                 ),
// // // // // //               ],
// // // // // //             ),
// // // // // //           ),
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   void _showColumnsOptions() {
// // // // // //     showDialog(
// // // // // //       context: context,
// // // // // //       builder: (context) => StatefulBuilder(
// // // // // //         builder: (context, setLocal) => AlertDialog(
// // // // // //           title: const Text('إعدادات الأعمدة'),
// // // // // //           content: SingleChildScrollView(
// // // // // //             child: Column(
// // // // // //               mainAxisSize: MainAxisSize.min,
// // // // // //               crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //               children: [
// // // // // //                 const Text('أعمدة النصوص:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
// // // // // //                 ...textColumnsMap.entries.map((entry) => CheckboxListTile(
// // // // // //                       title: Text(entry.value),
// // // // // //                       value: selectedTextCols.contains(entry.key),
// // // // // //                       onChanged: (v) => setLocal(() => v! ? selectedTextCols.add(entry.key) : selectedTextCols.remove(entry.key)),
// // // // // //                     )),
// // // // // //                 const Divider(),
// // // // // //                 const Text('أعمدة الأرقام:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
// // // // // //                 ...numericColumnsMap.entries.map((entry) => CheckboxListTile(
// // // // // //                       title: Text(entry.value),
// // // // // //                       value: selectedNumCols.contains(entry.key),
// // // // // //                       onChanged: (v) => setLocal(() => v! ? selectedNumCols.add(entry.key) : selectedNumCols.remove(entry.key)),
// // // // // //                     )),
// // // // // //               ],
// // // // // //             ),
// // // // // //           ),
// // // // // //           actions: [
// // // // // //             TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
// // // // // //             ElevatedButton(
// // // // // //                 onPressed: () {
// // // // // //                   _saveColumns();
// // // // // //                   Navigator.pop(context);
// // // // // //                   loadReport();
// // // // // //                 },
// // // // // //                 child: const Text('تطبيق وحفظ')),
// // // // // //           ],
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   Widget _dateItem(String label, DateTime value, VoidCallback onPick) {
// // // // // //     return InkWell(
// // // // // //       onTap: onPick,
// // // // // //       child: Column(
// // // // // //         children: [
// // // // // //           Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
// // // // // //           Text(intl.DateFormat('yyyy-MM-dd').format(value), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
// // // // // //         ],
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // // }
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:intl/intl.dart' as intl;
// // // // // import 'package:supabase_flutter/supabase_flutter.dart';
// // // // // import 'package:shared_preferences/shared_preferences.dart';

// // // // // class PlanninReportScreen extends StatefulWidget {
// // // // //   const PlanninReportScreen({super.key});

// // // // //   @override
// // // // //   State<PlanninReportScreen> createState() => _FarzaReportScreenState();
// // // // // }

// // // // // class _FarzaReportScreenState extends State<PlanninReportScreen> {
// // // // //   final supabase = Supabase.instance.client;

// // // // //   DateTime fromDate = DateTime(2025, 12, 1);
// // // // //   DateTime toDate = DateTime.now();
  
// // // // //   // الفلاتر البولينية الجديدة
// // // // //   bool? filterAcceptedForOperation; 
// // // // //   bool? filterIsConvertedIntoInvoice;

// // // // //   final Map<String, String> textColumnsMap = {
// // // // //     'Date': 'التاريخ',
// // // // //     'ShippingDate': 'تاريخ الشحن',
// // // // //     'Country': 'الدولة',
// // // // //     'Count': 'الحجم',
// // // // //     'CTNType': 'نوع الكرتون',
// // // // //     'CTNWeight': 'وزن الكرتون',
// // // // //     'Brand': 'الماركه',
// // // // //     'Serial': 'رقم الطلبية',
// // // // //   };

// // // // //   final Map<String, String> numericColumnsMap = {
// // // // //     'PalletsCount': 'كمية الطلبية',
// // // // //     'Production_Pallet': 'كمية الانتاج',
// // // // //     'Shipping_Pallet': 'كمية المشحون',
// // // // //     'balance': 'مطلوب انتاجه',
// // // // //   };

// // // // //   List<String> selectedTextCols = [];
// // // // //   List<String> selectedNumCols = [];

// // // // //   List reportData = []; 
// // // // //   List filteredData = []; 
// // // // //   bool loading = false;

// // // // //   Map<String, List<String>> activeFilters = {};

// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();
// // // // //     _loadSavedColumns().then((_) {
// // // // //       loadReport();
// // // // //     });
// // // // //   }

// // // // //   Future<void> _loadSavedColumns() async {
// // // // //     final prefs = await SharedPreferences.getInstance();
// // // // //     setState(() {
// // // // //       selectedTextCols = prefs.getStringList('selectedTextCols') ?? [];
// // // // //       selectedNumCols = prefs.getStringList('selectedNumCols') ?? [];
// // // // //     });
// // // // //   }

// // // // //   Future<void> _saveColumns() async {
// // // // //     final prefs = await SharedPreferences.getInstance();
// // // // //     await prefs.setStringList('selectedTextCols', selectedTextCols);
// // // // //     await prefs.setStringList('selectedNumCols', selectedNumCols);
// // // // //   }

// // // // //   String formatNum(dynamic v, {bool isMoney = true}) {
// // // // //     if (v == null) return isMoney ? '0.00' : '0';
// // // // //     final formatter = intl.NumberFormat.decimalPattern();
// // // // //     if (isMoney) {
// // // // //       formatter.minimumFractionDigits = 2;
// // // // //       formatter.maximumFractionDigits = 2;
// // // // //     }
// // // // //     return formatter.format(v is num ? v : double.tryParse(v.toString()) ?? 0);
// // // // //   }

// // // // //   Future<void> loadReport() async {
// // // // //     setState(() => loading = true);
// // // // //     try {
// // // // //       final res = await supabase.rpc(
// // // // //         'get_planning_report',
// // // // //         params: {
// // // // //           'p_date_from': intl.DateFormat('yyyy-MM-dd').format(fromDate),
// // // // //           'p_date_to': intl.DateFormat('yyyy-MM-dd').format(toDate),
// // // // //           'p_crop_name': null, 
// // // // //           'p_crop_class': null,
// // // // //           'p_group_columns': selectedTextCols,
// // // // //           'p_sum_columns': selectedNumCols,
// // // // //         },
// // // // //       );
// // // // //       setState(() {
// // // // //         reportData = List.from(res);
// // // // //         _applyLocalFilters(); 
// // // // //         loading = false;
// // // // //       });
// // // // //     } catch (e) {
// // // // //       setState(() => loading = false);
// // // // //       if (mounted) {
// // // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // // //           SnackBar(content: Text('خطأ في تحميل التقرير: $e')),
// // // // //         );
// // // // //       }
// // // // //     }
// // // // //   }

// // // // //   // دالة مساعدة مطورة للتأكد من تحويل أي قيمة قادمة من الداتا بيز إلى Bool بشكل آمن
// // // // //   bool _toBool(dynamic val) {
// // // // //     if (val == null) return false;
// // // // //     if (val is bool) return val;
// // // // //     if (val is num) return val == 1;
// // // // //     if (val is String) {
// // // // //       final s = val.toLowerCase().trim();
// // // // //       return s == 'true' || s == '1' || s == 'yes' || s == 't';
// // // // //     }
// // // // //     return false;
// // // // //   }

// // // // //   void _applyLocalFilters() {
// // // // //     setState(() {
// // // // //       filteredData = reportData.where((row) {
// // // // //         bool match = true;

// // // // //         final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};

// // // // //         // 1. فحص فلتر "تحت التشغيل" - نبحث في المستوى الأول ثم في extra_columns
// // // // //         if (filterAcceptedForOperation != null) {
// // // // //           dynamic val = row['AcceptedForOperation'] ?? extra['AcceptedForOperation'];
// // // // //           if (_toBool(val) != filterAcceptedForOperation) match = false;
// // // // //         }

// // // // //         // 2. فحص فلتر "مغلق" - نبحث في المستوى الأول ثم في extra_columns
// // // // //         if (filterIsConvertedIntoInvoice != null) {
// // // // //           dynamic val = row['IsConvertedIntoInvoice'] ?? extra['IsConvertedIntoInvoice'];
// // // // //           if (_toBool(val) != filterIsConvertedIntoInvoice) match = false;
// // // // //         }

// // // // //         // 3. فلاتر الأعمدة الديناميكية
// // // // //         if (match) {
// // // // //           activeFilters.forEach((colKey, selectedValues) {
// // // // //             if (selectedValues.isNotEmpty) {
// // // // //               String rowValue = "";
// // // // //               if (colKey == 'crop_name') {
// // // // //                 rowValue = row['crop_name']?.toString() ?? "";
// // // // //               } else if (colKey == 'class') {
// // // // //                 rowValue = row['class']?.toString() ?? "";
// // // // //               } else {
// // // // //                 rowValue = extra[colKey]?.toString() ?? "";
// // // // //               }
// // // // //               if (!selectedValues.contains(rowValue)) match = false;
// // // // //             }
// // // // //           });
// // // // //         }
        
// // // // //         return match;
// // // // //       }).toList();
// // // // //     });
// // // // //   }

// // // // //   num get totalNetWeight => filteredData.fold(0, (s, e) => s + (e['net_weight'] ?? 0));

// // // // //   num sumNumericColumn(String columnName) {
// // // // //     if (filteredData.isEmpty) return 0;
// // // // //     return filteredData.fold(0, (s, e) {
// // // // //       final extra = e['extra_columns'] as Map<String, dynamic>? ?? {};
// // // // //       final val = extra[columnName];
// // // // //       return s + (val is num ? val : (double.tryParse(val?.toString() ?? '0') ?? 0));
// // // // //     });
// // // // //   }

// // // // //   void _showFilterDialog(String title, String colKey) {
// // // // //     List tempFiltered = reportData.where((row) {
// // // // //       bool match = true;
// // // // //       final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};

// // // // //       if (filterAcceptedForOperation != null) {
// // // // //          dynamic val = row['AcceptedForOperation'] ?? extra['AcceptedForOperation'];
// // // // //          if (_toBool(val) != filterAcceptedForOperation) match = false;
// // // // //       }
// // // // //       if (filterIsConvertedIntoInvoice != null) {
// // // // //          dynamic val = row['IsConvertedIntoInvoice'] ?? extra['IsConvertedIntoInvoice'];
// // // // //          if (_toBool(val) != filterIsConvertedIntoInvoice) match = false;
// // // // //       }
      
// // // // //       activeFilters.forEach((key, values) {
// // // // //         if (key != colKey && values.isNotEmpty) {
// // // // //           String val = "";
// // // // //           if (key == 'crop_name') val = row['crop_name']?.toString() ?? "";
// // // // //           else if (key == 'class') val = row['class']?.toString() ?? "";
// // // // //           else {
// // // // //             val = extra[key]?.toString() ?? "";
// // // // //           }
// // // // //           if (!values.contains(val)) match = false;
// // // // //         }
// // // // //       });
// // // // //       return match;
// // // // //     }).toList();

// // // // //     Set<String> uniqueValues = {};
// // // // //     for (var row in tempFiltered) {
// // // // //       if (colKey == 'crop_name') uniqueValues.add(row['crop_name']?.toString() ?? "");
// // // // //       else if (colKey == 'class') uniqueValues.add(row['class']?.toString() ?? "");
// // // // //       else {
// // // // //         final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
// // // // //         uniqueValues.add(extra[colKey]?.toString() ?? "");
// // // // //       }
// // // // //     }
// // // // //     List<String> sortedList = uniqueValues.where((v) => v.isNotEmpty).toList()..sort();
// // // // //     List<String> tempSelected = List.from(activeFilters[colKey] ?? []);
// // // // //     String searchQuery = "";

// // // // //     showDialog(
// // // // //       context: context,
// // // // //       builder: (context) => StatefulBuilder(
// // // // //         builder: (context, setDialogState) {
// // // // //           List<String> displayList = sortedList
// // // // //               .where((item) => item.toLowerCase().contains(searchQuery.toLowerCase()))
// // // // //               .toList();

// // // // //           return AlertDialog(
// // // // //             title: Text('فلترة $title'),
// // // // //             content: SizedBox(
// // // // //               width: double.maxFinite,
// // // // //               child: Column(
// // // // //                 mainAxisSize: MainAxisSize.min,
// // // // //                 children: [
// // // // //                   TextField(
// // // // //                     decoration: const InputDecoration(
// // // // //                       hintText: 'بحث داخل القائمة...',
// // // // //                       prefixIcon: Icon(Icons.search),
// // // // //                       border: OutlineInputBorder(),
// // // // //                     ),
// // // // //                     onChanged: (v) => setDialogState(() => searchQuery = v),
// // // // //                   ),
// // // // //                   const SizedBox(height: 10),
// // // // //                   ConstrainedBox(
// // // // //                     constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
// // // // //                     child: ListView.builder(
// // // // //                       shrinkWrap: true,
// // // // //                       itemCount: displayList.length,
// // // // //                       itemBuilder: (context, index) {
// // // // //                         final val = displayList[index];
// // // // //                         return CheckboxListTile(
// // // // //                           title: Text(val),
// // // // //                           value: tempSelected.contains(val),
// // // // //                           onChanged: (checked) {
// // // // //                             setDialogState(() {
// // // // //                               if (checked!) tempSelected.add(val);
// // // // //                               else tempSelected.remove(val);
// // // // //                             });
// // // // //                           },
// // // // //                         );
// // // // //                       },
// // // // //                     ),
// // // // //                   ),
// // // // //                 ],
// // // // //               ),
// // // // //             ),
// // // // //             actions: [
// // // // //               TextButton(
// // // // //                 onPressed: () {
// // // // //                   setState(() {
// // // // //                     activeFilters[colKey] = [];
// // // // //                     _applyLocalFilters();
// // // // //                   });
// // // // //                   Navigator.pop(context);
// // // // //                 },
// // // // //                 child: const Text('إلغاء الكل', style: TextStyle(color: Colors.red)),
// // // // //               ),
// // // // //               ElevatedButton(
// // // // //                 onPressed: () {
// // // // //                   setState(() {
// // // // //                     activeFilters[colKey] = tempSelected;
// // // // //                     _applyLocalFilters();
// // // // //                   });
// // // // //                   Navigator.pop(context);
// // // // //                 },
// // // // //                 child: const Text('تطبيق'),
// // // // //               ),
// // // // //             ],
// // // // //           );
// // // // //         },
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   Widget _buildFilterHeader(String title, String colKey) {
// // // // //     bool isFiltered = activeFilters[colKey]?.isNotEmpty ?? false;
// // // // //     return InkWell(
// // // // //       onTap: () => _showFilterDialog(title, colKey),
// // // // //       child: Row(
// // // // //         mainAxisSize: MainAxisSize.min,
// // // // //         children: [
// // // // //           Text(title),
// // // // //           Icon(
// // // // //             Icons.filter_alt,
// // // // //             size: 16,
// // // // //             color: isFiltered ? Colors.blue : Colors.grey[400],
// // // // //           ),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Directionality(
// // // // //       textDirection: TextDirection.rtl,
// // // // //       child: Scaffold(
// // // // //         backgroundColor: Colors.grey[100],
// // // // //         appBar: AppBar(
// // // // //           title: const Text('تقرير التخطيط'),
// // // // //           centerTitle: true,
// // // // //           actions: [
// // // // //             IconButton(
// // // // //               icon: const Icon(Icons.refresh),
// // // // //               onPressed: loadReport,
// // // // //             )
// // // // //           ],
// // // // //         ),
// // // // //         body: Column(
// // // // //           children: [
// // // // //             _filtersSection(),
// // // // //             _summaryCards(),
// // // // //             Expanded(
// // // // //               child: loading
// // // // //                   ? const Center(child: CircularProgressIndicator())
// // // // //                   : _tableSection(),
// // // // //             ),
// // // // //           ],
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   Widget _filtersSection() {
// // // // //     return Card(
// // // // //       margin: const EdgeInsets.all(12),
// // // // //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
// // // // //       child: Padding(
// // // // //         padding: const EdgeInsets.all(12),
// // // // //         child: Column(
// // // // //           children: [
// // // // //             Row(
// // // // //               children: [
// // // // //                 // فلتر تحت التشغيل
// // // // //                 Expanded(
// // // // //                   child: CheckboxListTile(
// // // // //                     contentPadding: EdgeInsets.zero,
// // // // //                     title: const Text('تحت التشغيل', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
// // // // //                     value: filterAcceptedForOperation ?? false,
// // // // //                     controlAffinity: ListTileControlAffinity.leading,
// // // // //                     onChanged: (v) => setState(() {
// // // // //                       filterAcceptedForOperation = (v == true) ? true : null;
// // // // //                       _applyLocalFilters();
// // // // //                     }),
// // // // //                   ),
// // // // //                 ),
// // // // //                 // فلتر مغلق
// // // // //                 Expanded(
// // // // //                   child: CheckboxListTile(
// // // // //                     contentPadding: EdgeInsets.zero,
// // // // //                     title: const Text('مغلق', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
// // // // //                     value: filterIsConvertedIntoInvoice ?? false,
// // // // //                     controlAffinity: ListTileControlAffinity.leading,
// // // // //                     onChanged: (v) => setState(() {
// // // // //                       filterIsConvertedIntoInvoice = (v == true) ? true : null;
// // // // //                       _applyLocalFilters();
// // // // //                     }),
// // // // //                   ),
// // // // //                 ),
// // // // //                 IconButton.filledTonal(
// // // // //                   onPressed: _showColumnsOptions,
// // // // //                   icon: const Icon(Icons.settings),
// // // // //                 ),
// // // // //               ],
// // // // //             ),
// // // // //             const Divider(height: 10),
// // // // //             Row(
// // // // //               mainAxisAlignment: MainAxisAlignment.spaceAround,
// // // // //               children: [
// // // // //                 _dateItem('من', fromDate, () async {
// // // // //                   final picked = await showDatePicker(
// // // // //                     context: context,
// // // // //                     initialDate: fromDate,
// // // // //                     firstDate: DateTime(2020),
// // // // //                     lastDate: DateTime(2030),
// // // // //                   );
// // // // //                   if (picked != null) {
// // // // //                     setState(() {
// // // // //                       fromDate = picked;
// // // // //                       loadReport();
// // // // //                     });
// // // // //                   }
// // // // //                 }),
// // // // //                 _dateItem('إلى', toDate, () async {
// // // // //                   final picked = await showDatePicker(
// // // // //                     context: context,
// // // // //                     initialDate: toDate,
// // // // //                     firstDate: DateTime(2020),
// // // // //                     lastDate: DateTime(2030),
// // // // //                   );
// // // // //                   if (picked != null) {
// // // // //                     setState(() {
// // // // //                       toDate = picked;
// // // // //                       loadReport();
// // // // //                     });
// // // // //                   }
// // // // //                 }),
// // // // //                 TextButton(
// // // // //                   onPressed: () => setState(() {
// // // // //                     activeFilters.clear();
// // // // //                     filterAcceptedForOperation = null;
// // // // //                     filterIsConvertedIntoInvoice = null;
// // // // //                     _applyLocalFilters();
// // // // //                   }),
// // // // //                   child: const Text('تصفير الفلاتر', style: TextStyle(color: Colors.red, fontSize: 12)),
// // // // //                 )
// // // // //               ],
// // // // //             ),
// // // // //           ],
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   Widget _summaryCards() {
// // // // //     return Padding(
// // // // //       padding: const EdgeInsets.symmetric(horizontal: 12),
// // // // //       child: Row(
// // // // //         children: [
// // // // //           _cardInfo('إجمالي الكمية (المصفاة)', formatNum(totalNetWeight), Colors.blue),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   Widget _cardInfo(String title, String value, Color color) {
// // // // //     return Expanded(
// // // // //       child: Card(
// // // // //         color: color.withOpacity(0.1),
// // // // //         child: Padding(
// // // // //           padding: const EdgeInsets.all(12),
// // // // //           child: Column(
// // // // //             children: [
// // // // //               Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
// // // // //               Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
// // // // //             ],
// // // // //           ),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   Widget _tableSection() {
// // // // //     if (filteredData.isEmpty && reportData.isEmpty) return const Center(child: Text('لا توجد بيانات متاحة'));
    
// // // // //     return Card(
// // // // //       margin: const EdgeInsets.all(12),
// // // // //       child: Scrollbar(
// // // // //         child: SingleChildScrollView(
// // // // //           scrollDirection: Axis.vertical,
// // // // //           child: SingleChildScrollView(
// // // // //             scrollDirection: Axis.horizontal,
// // // // //             child: DataTable(
// // // // //               headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
// // // // //               columns: [
// // // // //                 DataColumn(label: _buildFilterHeader('الصنف', 'crop_name')),
// // // // //                 DataColumn(label: _buildFilterHeader('الدرجة', 'class')),
// // // // //                 const DataColumn(label: Text('الكمية')),
// // // // //                 ...selectedTextCols.map((c) => DataColumn(label: _buildFilterHeader(textColumnsMap[c] ?? c, c))),
// // // // //                 ...selectedNumCols.map((c) => DataColumn(label: Text(numericColumnsMap[c] ?? c))),
// // // // //               ],
// // // // //               rows: [
// // // // //                 ...filteredData.map((row) {
// // // // //                   final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
// // // // //                   return DataRow(cells: [
// // // // //                     DataCell(Text(row['crop_name'] ?? '')),
// // // // //                     DataCell(Text(row['class'] ?? '')),
// // // // //                     DataCell(Text(formatNum(row['net_weight']))),
// // // // //                     ...selectedTextCols.map((c) => DataCell(Text(extra[c]?.toString() ?? '-'))),
// // // // //                     ...selectedNumCols.map((c) => DataCell(Text(formatNum(extra[c])))),
// // // // //                   ]);
// // // // //                 }),
// // // // //                 DataRow(
// // // // //                   color: MaterialStateProperty.all(Colors.amber[50]),
// // // // //                   cells: [
// // // // //                     const DataCell(Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold))),
// // // // //                     const DataCell(Text('-')),
// // // // //                     DataCell(Text(formatNum(totalNetWeight), style: const TextStyle(fontWeight: FontWeight.bold))),
// // // // //                     ...selectedTextCols.map((_) => const DataCell(Text(''))),
// // // // //                     ...selectedNumCols.map((c) => DataCell(
// // // // //                           Text(formatNum(sumNumericColumn(c)), style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // //                         )),
// // // // //                   ],
// // // // //                 ),
// // // // //               ],
// // // // //             ),
// // // // //           ),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   void _showColumnsOptions() {
// // // // //     showDialog(
// // // // //       context: context,
// // // // //       builder: (context) => StatefulBuilder(
// // // // //         builder: (context, setLocal) => AlertDialog(
// // // // //           title: const Text('إعدادات الأعمدة'),
// // // // //           content: SingleChildScrollView(
// // // // //             child: Column(
// // // // //               mainAxisSize: MainAxisSize.min,
// // // // //               crossAxisAlignment: CrossAxisAlignment.start,
// // // // //               children: [
// // // // //                 const Text('أعمدة النصوص:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
// // // // //                 ...textColumnsMap.entries.map((entry) => CheckboxListTile(
// // // // //                       title: Text(entry.value),
// // // // //                       value: selectedTextCols.contains(entry.key),
// // // // //                       onChanged: (v) => setLocal(() => v! ? selectedTextCols.add(entry.key) : selectedTextCols.remove(entry.key)),
// // // // //                     )),
// // // // //                 const Divider(),
// // // // //                 const Text('أعمدة الأرقام:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
// // // // //                 ...numericColumnsMap.entries.map((entry) => CheckboxListTile(
// // // // //                       title: Text(entry.value),
// // // // //                       value: selectedNumCols.contains(entry.key),
// // // // //                       onChanged: (v) => setLocal(() => v! ? selectedNumCols.add(entry.key) : selectedNumCols.remove(entry.key)),
// // // // //                     )),
// // // // //               ],
// // // // //             ),
// // // // //           ),
// // // // //           actions: [
// // // // //             TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
// // // // //             ElevatedButton(
// // // // //                 onPressed: () {
// // // // //                   _saveColumns();
// // // // //                   Navigator.pop(context);
// // // // //                   loadReport();
// // // // //                 },
// // // // //                 child: const Text('تطبيق وحفظ')),
// // // // //           ],
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   Widget _dateItem(String label, DateTime value, VoidCallback onPick) {
// // // // //     return InkWell(
// // // // //       onTap: onPick,
// // // // //       child: Column(
// // // // //         children: [
// // // // //           Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
// // // // //           Text(intl.DateFormat('yyyy-MM-dd').format(value), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }
// // // // import 'package:flutter/material.dart';
// // // // import 'package:intl/intl.dart' as intl;
// // // // import 'package:supabase_flutter/supabase_flutter.dart';
// // // // import 'package:shared_preferences/shared_preferences.dart';

// // // // class PlanninReportScreen extends StatefulWidget {
// // // //   const PlanninReportScreen({super.key});

// // // //   @override
// // // //   State<PlanninReportScreen> createState() => _FarzaReportScreenState();
// // // // }

// // // // class _FarzaReportScreenState extends State<PlanninReportScreen> {
// // // //   final supabase = Supabase.instance.client;

// // // //   DateTime fromDate = DateTime(2025, 12, 1);
// // // //   DateTime toDate = DateTime.now();
  
// // // //   // الفلاتر البولينية
// // // //   bool? filterAcceptedForOperation; 
// // // //   bool? filterIsConvertedIntoInvoice;

// // // //   final Map<String, String> textColumnsMap = {
// // // //     'Date': 'التاريخ',
// // // //     'ShippingDate': 'تاريخ الشحن',
// // // //     'Country': 'الدولة',
// // // //     'Count': 'الحجم',
// // // //     'CTNType': 'نوع الكرتون',
// // // //     'CTNWeight': 'وزن الكرتون',
// // // //     'Brand': 'الماركه',
// // // //     'Serial': 'رقم الطلبية',
// // // //     'AcceptedForOperation': 'تحت التشغيل', // أضفناها هنا لضمان طلبها من الـ RPC
// // // //     'IsConvertedIntoInvoice': 'مغلق',      // أضفناها هنا لضمان طلبها من الـ RPC
// // // //   };

// // // //   final Map<String, String> numericColumnsMap = {
// // // //     'PalletsCount': 'كمية الطلبية',
// // // //     'Production_Pallet': 'كمية الانتاج',
// // // //     'Shipping_Pallet': 'كمية المشحون',
// // // //     'balance': 'مطلوب انتاجه',
// // // //   };

// // // //   List<String> selectedTextCols = [];
// // // //   List<String> selectedNumCols = [];

// // // //   List reportData = []; 
// // // //   List filteredData = []; 
// // // //   bool loading = false;

// // // //   Map<String, List<String>> activeFilters = {};

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _loadSavedColumns().then((_) {
// // // //       loadReport();
// // // //     });
// // // //   }

// // // //   Future<void> _loadSavedColumns() async {
// // // //     final prefs = await SharedPreferences.getInstance();
// // // //     setState(() {
// // // //       selectedTextCols = prefs.getStringList('selectedTextCols') ?? [];
// // // //       selectedNumCols = prefs.getStringList('selectedNumCols') ?? [];
// // // //     });
// // // //   }

// // // //   Future<void> _saveColumns() async {
// // // //     final prefs = await SharedPreferences.getInstance();
// // // //     await prefs.setStringList('selectedTextCols', selectedTextCols);
// // // //     await prefs.setStringList('selectedNumCols', selectedNumCols);
// // // //   }

// // // //   String formatNum(dynamic v, {bool isMoney = true}) {
// // // //     if (v == null) return isMoney ? '0.00' : '0';
// // // //     final formatter = intl.NumberFormat.decimalPattern();
// // // //     if (isMoney) {
// // // //       formatter.minimumFractionDigits = 2;
// // // //       formatter.maximumFractionDigits = 2;
// // // //     }
// // // //     return formatter.format(v is num ? v : double.tryParse(v.toString()) ?? 0);
// // // //   }

// // // //   Future<void> loadReport() async {
// // // //     setState(() => loading = true);
// // // //     try {
// // // //       // لكي تعمل الفلاتر البولينية، يجب أن نطلب هذه الأعمدة من الـ RPC 
// // // //       // بإضافتها إلى p_group_columns حتى لو لم يختارها المستخدم في العرض
// // // //       List<String> rpcGroupCols = List.from(selectedTextCols);
// // // //       if (!rpcGroupCols.contains('AcceptedForOperation')) rpcGroupCols.add('AcceptedForOperation');
// // // //       if (!rpcGroupCols.contains('IsConvertedIntoInvoice')) rpcGroupCols.add('IsConvertedIntoInvoice');

// // // //       final res = await supabase.rpc(
// // // //         'get_planning_report',
// // // //         params: {
// // // //           'p_date_from': intl.DateFormat('yyyy-MM-dd').format(fromDate),
// // // //           'p_date_to': intl.DateFormat('yyyy-MM-dd').format(toDate),
// // // //           'p_crop_name': null, 
// // // //           'p_crop_class': null,
// // // //           'p_group_columns': rpcGroupCols, // نرسل الأعمدة المطلوبة للفلترة هنا
// // // //           'p_sum_columns': selectedNumCols,
// // // //         },
// // // //       );
// // // //       setState(() {
// // // //         reportData = List.from(res);
// // // //         _applyLocalFilters(); 
// // // //         loading = false;
// // // //       });
// // // //     } catch (e) {
// // // //       setState(() => loading = false);
// // // //       if (mounted) {
// // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // //           SnackBar(content: Text('خطأ في تحميل التقرير: $e')),
// // // //         );
// // // //       }
// // // //     }
// // // //   }

// // // //   bool _toBool(dynamic val) {
// // // //     if (val == null) return false;
// // // //     if (val is bool) return val;
// // // //     if (val is num) return val == 1;
// // // //     if (val is String) {
// // // //       final s = val.toLowerCase().trim();
// // // //       return s == 'true' || s == '1' || s == 'yes' || s == 't';
// // // //     }
// // // //     return false;
// // // //   }

// // // //   void _applyLocalFilters() {
// // // //     setState(() {
// // // //       filteredData = reportData.where((row) {
// // // //         bool match = true;
// // // //         final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};

// // // //         // الفلاتر البولينية تبحث دائماً داخل extra_columns لأن الدالة تضعها هناك
// // // //         if (filterAcceptedForOperation != null) {
// // // //           if (_toBool(extra['AcceptedForOperation']) != filterAcceptedForOperation) match = false;
// // // //         }

// // // //         if (filterIsConvertedIntoInvoice != null) {
// // // //           if (_toBool(extra['IsConvertedIntoInvoice']) != filterIsConvertedIntoInvoice) match = false;
// // // //         }

// // // //         // فلاتر الأعمدة الديناميكية
// // // //         if (match) {
// // // //           activeFilters.forEach((colKey, selectedValues) {
// // // //             if (selectedValues.isNotEmpty) {
// // // //               String rowValue = "";
// // // //               if (colKey == 'crop_name') {
// // // //                 rowValue = row['crop_name']?.toString() ?? "";
// // // //               } else if (colKey == 'class') {
// // // //                 rowValue = row['class']?.toString() ?? "";
// // // //               } else {
// // // //                 rowValue = extra[colKey]?.toString() ?? "";
// // // //               }
// // // //               if (!selectedValues.contains(rowValue)) match = false;
// // // //             }
// // // //           });
// // // //         }
        
// // // //         return match;
// // // //       }).toList();
// // // //     });
// // // //   }

// // // //   num get totalNetWeight => filteredData.fold(0, (s, e) => s + (e['net_weight'] ?? 0));

// // // //   num sumNumericColumn(String columnName) {
// // // //     if (filteredData.isEmpty) return 0;
// // // //     return filteredData.fold(0, (s, e) {
// // // //       final extra = e['extra_columns'] as Map<String, dynamic>? ?? {};
// // // //       final val = extra[columnName];
// // // //       return s + (val is num ? val : (double.tryParse(val?.toString() ?? '0') ?? 0));
// // // //     });
// // // //   }

// // // //   void _showFilterDialog(String title, String colKey) {
// // // //     List tempFiltered = reportData.where((row) {
// // // //       bool match = true;
// // // //       final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};

// // // //       if (filterAcceptedForOperation != null) {
// // // //          if (_toBool(extra['AcceptedForOperation']) != filterAcceptedForOperation) match = false;
// // // //       }
// // // //       if (filterIsConvertedIntoInvoice != null) {
// // // //          if (_toBool(extra['IsConvertedIntoInvoice']) != filterIsConvertedIntoInvoice) match = false;
// // // //       }
      
// // // //       activeFilters.forEach((key, values) {
// // // //         if (key != colKey && values.isNotEmpty) {
// // // //           String val = "";
// // // //           if (key == 'crop_name') val = row['crop_name']?.toString() ?? "";
// // // //           else if (key == 'class') val = row['class']?.toString() ?? "";
// // // //           else {
// // // //             val = extra[key]?.toString() ?? "";
// // // //           }
// // // //           if (!values.contains(val)) match = false;
// // // //         }
// // // //       });
// // // //       return match;
// // // //     }).toList();

// // // //     Set<String> uniqueValues = {};
// // // //     for (var row in tempFiltered) {
// // // //       if (colKey == 'crop_name') uniqueValues.add(row['crop_name']?.toString() ?? "");
// // // //       else if (colKey == 'class') uniqueValues.add(row['class']?.toString() ?? "");
// // // //       else {
// // // //         final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
// // // //         uniqueValues.add(extra[colKey]?.toString() ?? "");
// // // //       }
// // // //     }
// // // //     List<String> sortedList = uniqueValues.where((v) => v.isNotEmpty).toList()..sort();
// // // //     List<String> tempSelected = List.from(activeFilters[colKey] ?? []);
// // // //     String searchQuery = "";

// // // //     showDialog(
// // // //       context: context,
// // // //       builder: (context) => StatefulBuilder(
// // // //         builder: (context, setDialogState) {
// // // //           List<String> displayList = sortedList
// // // //               .where((item) => item.toLowerCase().contains(searchQuery.toLowerCase()))
// // // //               .toList();

// // // //           return AlertDialog(
// // // //             title: Text('فلترة $title'),
// // // //             content: SizedBox(
// // // //               width: double.maxFinite,
// // // //               child: Column(
// // // //                 mainAxisSize: MainAxisSize.min,
// // // //                 children: [
// // // //                   TextField(
// // // //                     decoration: const InputDecoration(
// // // //                       hintText: 'بحث داخل القائمة...',
// // // //                       prefixIcon: Icon(Icons.search),
// // // //                       border: OutlineInputBorder(),
// // // //                     ),
// // // //                     onChanged: (v) => setDialogState(() => searchQuery = v),
// // // //                   ),
// // // //                   const SizedBox(height: 10),
// // // //                   ConstrainedBox(
// // // //                     constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
// // // //                     child: ListView.builder(
// // // //                       shrinkWrap: true,
// // // //                       itemCount: displayList.length,
// // // //                       itemBuilder: (context, index) {
// // // //                         final val = displayList[index];
// // // //                         return CheckboxListTile(
// // // //                           title: Text(val),
// // // //                           value: tempSelected.contains(val),
// // // //                           onChanged: (checked) {
// // // //                             setDialogState(() {
// // // //                               if (checked!) tempSelected.add(val);
// // // //                               else tempSelected.remove(val);
// // // //                             });
// // // //                           },
// // // //                         );
// // // //                       },
// // // //                     ),
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //             actions: [
// // // //               TextButton(
// // // //                 onPressed: () {
// // // //                   setState(() {
// // // //                     activeFilters[colKey] = [];
// // // //                     _applyLocalFilters();
// // // //                   });
// // // //                   Navigator.pop(context);
// // // //                 },
// // // //                 child: const Text('إلغاء الكل', style: TextStyle(color: Colors.red)),
// // // //               ),
// // // //               ElevatedButton(
// // // //                 onPressed: () {
// // // //                   setState(() {
// // // //                     activeFilters[colKey] = tempSelected;
// // // //                     _applyLocalFilters();
// // // //                   });
// // // //                   Navigator.pop(context);
// // // //                 },
// // // //                 child: const Text('تطبيق'),
// // // //               ),
// // // //             ],
// // // //           );
// // // //         },
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _buildFilterHeader(String title, String colKey) {
// // // //     bool isFiltered = activeFilters[colKey]?.isNotEmpty ?? false;
// // // //     return InkWell(
// // // //       onTap: () => _showFilterDialog(title, colKey),
// // // //       child: Row(
// // // //         mainAxisSize: MainAxisSize.min,
// // // //         children: [
// // // //           Text(title),
// // // //           Icon(
// // // //             Icons.filter_alt,
// // // //             size: 16,
// // // //             color: isFiltered ? Colors.blue : Colors.grey[400],
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Directionality(
// // // //       textDirection: TextDirection.rtl,
// // // //       child: Scaffold(
// // // //         backgroundColor: Colors.grey[100],
// // // //         appBar: AppBar(
// // // //           title: const Text('تقرير التخطيط'),
// // // //           centerTitle: true,
// // // //           actions: [
// // // //             IconButton(
// // // //               icon: const Icon(Icons.refresh),
// // // //               onPressed: loadReport,
// // // //             )
// // // //           ],
// // // //         ),
// // // //         body: Column(
// // // //           children: [
// // // //             _filtersSection(),
// // // //             _summaryCards(),
// // // //             Expanded(
// // // //               child: loading
// // // //                   ? const Center(child: CircularProgressIndicator())
// // // //                   : _tableSection(),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _filtersSection() {
// // // //     return Card(
// // // //       margin: const EdgeInsets.all(12),
// // // //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
// // // //       child: Padding(
// // // //         padding: const EdgeInsets.all(12),
// // // //         child: Column(
// // // //           children: [
// // // //             Row(
// // // //               children: [
// // // //                 // فلتر تحت التشغيل
// // // //                 Expanded(
// // // //                   child: CheckboxListTile(
// // // //                     contentPadding: EdgeInsets.zero,
// // // //                     title: const Text('تحت التشغيل', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
// // // //                     value: filterAcceptedForOperation ?? false,
// // // //                     controlAffinity: ListTileControlAffinity.leading,
// // // //                     onChanged: (v) => setState(() {
// // // //                       filterAcceptedForOperation = (v == true) ? true : null;
// // // //                       _applyLocalFilters();
// // // //                     }),
// // // //                   ),
// // // //                 ),
// // // //                 // فلتر مغلق
// // // //                 Expanded(
// // // //                   child: CheckboxListTile(
// // // //                     contentPadding: EdgeInsets.zero,
// // // //                     title: const Text('مغلق', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
// // // //                     value: filterIsConvertedIntoInvoice ?? false,
// // // //                     controlAffinity: ListTileControlAffinity.leading,
// // // //                     onChanged: (v) => setState(() {
// // // //                       filterIsConvertedIntoInvoice = (v == true) ? true : null;
// // // //                       _applyLocalFilters();
// // // //                     }),
// // // //                   ),
// // // //                 ),
// // // //                 IconButton.filledTonal(
// // // //                   onPressed: _showColumnsOptions,
// // // //                   icon: const Icon(Icons.settings),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //             const Divider(height: 10),
// // // //             Row(
// // // //               mainAxisAlignment: MainAxisAlignment.spaceAround,
// // // //               children: [
// // // //                 _dateItem('من', fromDate, () async {
// // // //                   final picked = await showDatePicker(
// // // //                     context: context,
// // // //                     initialDate: fromDate,
// // // //                     firstDate: DateTime(2020),
// // // //                     lastDate: DateTime(2030),
// // // //                   );
// // // //                   if (picked != null) {
// // // //                     setState(() {
// // // //                       fromDate = picked;
// // // //                       loadReport();
// // // //                     });
// // // //                   }
// // // //                 }),
// // // //                 _dateItem('إلى', toDate, () async {
// // // //                   final picked = await showDatePicker(
// // // //                     context: context,
// // // //                     initialDate: toDate,
// // // //                     firstDate: DateTime(2020),
// // // //                     lastDate: DateTime(2030),
// // // //                   );
// // // //                   if (picked != null) {
// // // //                     setState(() {
// // // //                       toDate = picked;
// // // //                       loadReport();
// // // //                     });
// // // //                   }
// // // //                 }),
// // // //                 TextButton(
// // // //                   onPressed: () => setState(() {
// // // //                     activeFilters.clear();
// // // //                     filterAcceptedForOperation = null;
// // // //                     filterIsConvertedIntoInvoice = null;
// // // //                     _applyLocalFilters();
// // // //                   }),
// // // //                   child: const Text('تصفير الفلاتر', style: TextStyle(color: Colors.red, fontSize: 12)),
// // // //                 )
// // // //               ],
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _summaryCards() {
// // // //     return Padding(
// // // //       padding: const EdgeInsets.symmetric(horizontal: 12),
// // // //       child: Row(
// // // //         children: [
// // // //           _cardInfo('إجمالي الكمية (المصفاة)', formatNum(totalNetWeight), Colors.blue),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _cardInfo(String title, String value, Color color) {
// // // //     return Expanded(
// // // //       child: Card(
// // // //         color: color.withOpacity(0.1),
// // // //         child: Padding(
// // // //           padding: const EdgeInsets.all(12),
// // // //           child: Column(
// // // //             children: [
// // // //               Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
// // // //               Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _tableSection() {
// // // //     if (filteredData.isEmpty && reportData.isEmpty) return const Center(child: Text('لا توجد بيانات متاحة'));
    
// // // //     return Card(
// // // //       margin: const EdgeInsets.all(12),
// // // //       child: Scrollbar(
// // // //         child: SingleChildScrollView(
// // // //           scrollDirection: Axis.vertical,
// // // //           child: SingleChildScrollView(
// // // //             scrollDirection: Axis.horizontal,
// // // //             child: DataTable(
// // // //               headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
// // // //               columns: [
// // // //                 DataColumn(label: _buildFilterHeader('الصنف', 'crop_name')),
// // // //                 DataColumn(label: _buildFilterHeader('الدرجة', 'class')),
// // // //                 const DataColumn(label: Text('الكمية')),
// // // //                 ...selectedTextCols.map((c) => DataColumn(label: _buildFilterHeader(textColumnsMap[c] ?? c, c))),
// // // //                 ...selectedNumCols.map((c) => DataColumn(label: Text(numericColumnsMap[c] ?? c))),
// // // //               ],
// // // //               rows: [
// // // //                 ...filteredData.map((row) {
// // // //                   final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
// // // //                   return DataRow(cells: [
// // // //                     DataCell(Text(row['crop_name'] ?? '')),
// // // //                     DataCell(Text(row['class'] ?? '')),
// // // //                     DataCell(Text(formatNum(row['net_weight']))),
// // // //                     ...selectedTextCols.map((c) => DataCell(Text(extra[c]?.toString() ?? '-'))),
// // // //                     ...selectedNumCols.map((c) => DataCell(Text(formatNum(extra[c])))),
// // // //                   ]);
// // // //                 }),
// // // //                 DataRow(
// // // //                   color: MaterialStateProperty.all(Colors.amber[50]),
// // // //                   cells: [
// // // //                     const DataCell(Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold))),
// // // //                     const DataCell(Text('-')),
// // // //                     DataCell(Text(formatNum(totalNetWeight), style: const TextStyle(fontWeight: FontWeight.bold))),
// // // //                     ...selectedTextCols.map((_) => const DataCell(Text(''))),
// // // //                     ...selectedNumCols.map((c) => DataCell(
// // // //                           Text(formatNum(sumNumericColumn(c)), style: const TextStyle(fontWeight: FontWeight.bold)),
// // // //                         )),
// // // //                   ],
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   void _showColumnsOptions() {
// // // //     showDialog(
// // // //       context: context,
// // // //       builder: (context) => StatefulBuilder(
// // // //         builder: (context, setLocal) => AlertDialog(
// // // //           title: const Text('إعدادات الأعمدة'),
// // // //           content: SingleChildScrollView(
// // // //             child: Column(
// // // //               mainAxisSize: MainAxisSize.min,
// // // //               crossAxisAlignment: CrossAxisAlignment.start,
// // // //               children: [
// // // //                 const Text('أعمدة النصوص:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
// // // //                 ...textColumnsMap.entries.map((entry) {
// // // //                   // لا نريد إظهار أعمدة الفلترة كخيار للمستخدم إلا إذا رغب في ذلك، لكن هنا تظهر كخيارات عادية
// // // //                   return CheckboxListTile(
// // // //                       title: Text(entry.value),
// // // //                       value: selectedTextCols.contains(entry.key),
// // // //                       onChanged: (v) => setLocal(() => v! ? selectedTextCols.add(entry.key) : selectedTextCols.remove(entry.key)),
// // // //                     );
// // // //                 }),
// // // //                 const Divider(),
// // // //                 const Text('أعمدة الأرقام:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
// // // //                 ...numericColumnsMap.entries.map((entry) => CheckboxListTile(
// // // //                       title: Text(entry.value),
// // // //                       value: selectedNumCols.contains(entry.key),
// // // //                       onChanged: (v) => setLocal(() => v! ? selectedNumCols.add(entry.key) : selectedNumCols.remove(entry.key)),
// // // //                     )),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //           actions: [
// // // //             TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
// // // //             ElevatedButton(
// // // //                 onPressed: () {
// // // //                   _saveColumns();
// // // //                   Navigator.pop(context);
// // // //                   loadReport();
// // // //                 },
// // // //                 child: const Text('تطبيق وحفظ')),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _dateItem(String label, DateTime value, VoidCallback onPick) {
// // // //     return InkWell(
// // // //       onTap: onPick,
// // // //       child: Column(
// // // //         children: [
// // // //           Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
// // // //           Text(intl.DateFormat('yyyy-MM-dd').format(value), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // import 'package:flutter/material.dart';
// // // import 'package:intl/intl.dart' as intl;
// // // import 'package:supabase_flutter/supabase_flutter.dart';
// // // import 'package:shared_preferences/shared_preferences.dart';

// // // class PlanninReportScreen extends StatefulWidget {
// // //   const PlanninReportScreen({super.key});

// // //   @override
// // //   State<PlanninReportScreen> createState() => _FarzaReportScreenState();
// // // }

// // // class _FarzaReportScreenState extends State<PlanninReportScreen> {
// // //   final supabase = Supabase.instance.client;

// // //   DateTime fromDate = DateTime(2025, 12, 1);
// // //   DateTime toDate = DateTime.now();
  
// // //   // الفلتر الجديد للحالة (انتظار - تحت التشغيل - انتهى)
// // //   String? statusFilter; 

// // //   final Map<String, String> textColumnsMap = {
// // //     'Date': 'التاريخ',
// // //     'ShippingDate': 'تاريخ الشحن',
// // //     'Country': 'الدولة',
// // //     'Count': 'الحجم',
// // //     'CTNType': 'نوع الكرتون',
// // //     'CTNWeight': 'وزن الكرتون',
// // //     'Brand': 'الماركه',
// // //     'Serial': 'رقم الطلبية',
// // //     'status': 'الحالة', 
// // //   };

// // //   final Map<String, String> numericColumnsMap = {
// // //     'PalletsCount': 'كمية الطلبية',
// // //     'Production_Pallet': 'كمية الانتاج',
// // //     'Shipping_Pallet': 'كمية المشحون',
// // //     'balance': 'مطلوب انتاجه',
// // //   };

// // //   List<String> selectedTextCols = [];
// // //   List<String> selectedNumCols = [];

// // //   List reportData = []; 
// // //   List filteredData = []; 
// // //   bool loading = false;

// // //   Map<String, List<String>> activeFilters = {};

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _loadSavedColumns().then((_) {
// // //       loadReport();
// // //     });
// // //   }

// // //   Future<void> _loadSavedColumns() async {
// // //     final prefs = await SharedPreferences.getInstance();
// // //     setState(() {
// // //       selectedTextCols = prefs.getStringList('selectedTextCols') ?? [];
// // //       selectedNumCols = prefs.getStringList('selectedNumCols') ?? [];
// // //     });
// // //   }

// // //   Future<void> _saveColumns() async {
// // //     final prefs = await SharedPreferences.getInstance();
// // //     await prefs.setStringList('selectedTextCols', selectedTextCols);
// // //     await prefs.setStringList('selectedNumCols', selectedNumCols);
// // //   }

// // //   String formatNum(dynamic v, {bool isMoney = true}) {
// // //     if (v == null) return isMoney ? '0.00' : '0';
// // //     final formatter = intl.NumberFormat.decimalPattern();
// // //     if (isMoney) {
// // //       formatter.minimumFractionDigits = 2;
// // //       formatter.maximumFractionDigits = 2;
// // //     }
// // //     return formatter.format(v is num ? v : double.tryParse(v.toString()) ?? 0);
// // //   }

// // //   Future<void> loadReport() async {
// // //     setState(() => loading = true);
// // //     try {
// // //       // نطلب عمود status دائماً لإجراء الفلترة عليه
// // //       List<String> rpcGroupCols = List.from(selectedTextCols);
// // //       if (!rpcGroupCols.contains('status')) rpcGroupCols.add('status');

// // //       final res = await supabase.rpc(
// // //         'get_planning_report',
// // //         params: {
// // //           'p_date_from': intl.DateFormat('yyyy-MM-dd').format(fromDate),
// // //           'p_date_to': intl.DateFormat('yyyy-MM-dd').format(toDate),
// // //           'p_crop_name': null, 
// // //           'p_crop_class': null,
// // //           'p_group_columns': rpcGroupCols,
// // //           'p_sum_columns': selectedNumCols,
// // //         },
// // //       );
// // //       setState(() {
// // //         reportData = List.from(res);
// // //         _applyLocalFilters(); 
// // //         loading = false;
// // //       });
// // //     } catch (e) {
// // //       setState(() => loading = false);
// // //       if (mounted) {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(content: Text('خطأ في تحميل التقرير: $e')),
// // //         );
// // //       }
// // //     }
// // //   }

// // //   void _applyLocalFilters() {
// // //     setState(() {
// // //       filteredData = reportData.where((row) {
// // //         bool match = true;
// // //         final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};

// // //         // الفلترة بناءً على الحالة النصية القادمة من View8
// // //         if (statusFilter != null) {
// // //           if (extra['status'] != statusFilter) match = false;
// // //         }

// // //         // فلاتر الأعمدة الديناميكية
// // //         if (match) {
// // //           activeFilters.forEach((colKey, selectedValues) {
// // //             if (selectedValues.isNotEmpty) {
// // //               String rowValue = "";
// // //               if (colKey == 'crop_name') {
// // //                 rowValue = row['crop_name']?.toString() ?? "";
// // //               } else if (colKey == 'class') {
// // //                 rowValue = row['class']?.toString() ?? "";
// // //               } else {
// // //                 rowValue = extra[colKey]?.toString() ?? "";
// // //               }
// // //               if (!selectedValues.contains(rowValue)) match = false;
// // //             }
// // //           });
// // //         }
        
// // //         return match;
// // //       }).toList();
// // //     });
// // //   }

// // //   num sumNumericColumn(String columnName) {
// // //     if (filteredData.isEmpty) return 0;
// // //     return filteredData.fold(0, (s, e) {
// // //       final extra = e['extra_columns'] as Map<String, dynamic>? ?? {};
// // //       final val = extra[columnName];
// // //       return s + (val is num ? val : (double.tryParse(val?.toString() ?? '0') ?? 0));
// // //     });
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Directionality(
// // //       textDirection: TextDirection.rtl,
// // //       child: Scaffold(
// // //         backgroundColor: Colors.grey[100],
// // //         appBar: AppBar(
// // //           title: const Text('تقرير التخطيط'),
// // //           centerTitle: true,
// // //           actions: [
// // //             IconButton(
// // //               icon: const Icon(Icons.refresh),
// // //               onPressed: loadReport,
// // //             )
// // //           ],
// // //         ),
// // //         body: Column(
// // //           children: [
// // //             _filtersSection(),
// // //             _summaryCards(),
// // //             Expanded(
// // //               child: loading
// // //                   ? const Center(child: CircularProgressIndicator())
// // //                   : _tableSection(),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _filtersSection() {
// // //     return Card(
// // //       margin: const EdgeInsets.all(12),
// // //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
// // //       child: Padding(
// // //         padding: const EdgeInsets.all(12),
// // //         child: Column(
// // //           children: [
// // //             // تصميم الفلتر الجديد (راديو بوتون أو قائمة منسدلة)
// // //             Row(
// // //               children: [
// // //                 const Text('الحالة: ', style: TextStyle(fontWeight: FontWeight.bold)),
// // //                 Expanded(
// // //                   child: SingleChildScrollView(
// // //                     scrollDirection: Axis.horizontal,
// // //                     child: Row(
// // //                       children: ['انتظار', 'تحت التشغيل', 'انتهي'].map((s) {
// // //                         return Padding(
// // //                           padding: const EdgeInsets.symmetric(horizontal: 4),
// // //                           child: ChoiceChip(
// // //                             label: Text(s, style: const TextStyle(fontSize: 12)),
// // //                             selected: statusFilter == s,
// // //                             onSelected: (selected) {
// // //                               setState(() {
// // //                                 statusFilter = selected ? s : null;
// // //                                 _applyLocalFilters();
// // //                               });
// // //                             },
// // //                           ),
// // //                         );
// // //                       }).toList(),
// // //                     ),
// // //                   ),
// // //                 ),
// // //                 IconButton.filledTonal(
// // //                   onPressed: _showColumnsOptions,
// // //                   icon: const Icon(Icons.settings),
// // //                 ),
// // //               ],
// // //             ),
// // //             const Divider(height: 20),
// // //             Row(
// // //               mainAxisAlignment: MainAxisAlignment.spaceAround,
// // //               children: [
// // //                 _dateItem('من', fromDate, () async {
// // //                   final picked = await showDatePicker(
// // //                     context: context,
// // //                     initialDate: fromDate,
// // //                     firstDate: DateTime(2020),
// // //                     lastDate: DateTime(2030),
// // //                   );
// // //                   if (picked != null) {
// // //                     setState(() {
// // //                       fromDate = picked;
// // //                       loadReport();
// // //                     });
// // //                   }
// // //                 }),
// // //                 _dateItem('إلى', toDate, () async {
// // //                   final picked = await showDatePicker(
// // //                     context: context,
// // //                     initialDate: toDate,
// // //                     firstDate: DateTime(2020),
// // //                     lastDate: DateTime(2030),
// // //                   );
// // //                   if (picked != null) {
// // //                     setState(() {
// // //                       toDate = picked;
// // //                       loadReport();
// // //                     });
// // //                   }
// // //                 }),
// // //                 TextButton(
// // //                   onPressed: () => setState(() {
// // //                     activeFilters.clear();
// // //                     statusFilter = null;
// // //                     _applyLocalFilters();
// // //                   }),
// // //                   child: const Text('تصفير الفلاتر', style: TextStyle(color: Colors.red, fontSize: 12)),
// // //                 )
// // //               ],
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _summaryCards() {
// // //     num totalWeight = filteredData.fold(0, (s, e) => s + (e['net_weight'] ?? 0));
// // //     return Padding(
// // //       padding: const EdgeInsets.symmetric(horizontal: 12),
// // //       child: Row(
// // //         children: [
// // //           _cardInfo('إجمالي الكمية (المصفاة)', formatNum(totalWeight), Colors.blue),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   Widget _cardInfo(String title, String value, Color color) {
// // //     return Expanded(
// // //       child: Card(
// // //         color: color.withOpacity(0.1),
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(12),
// // //           child: Column(
// // //             children: [
// // //               Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
// // //               Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _tableSection() {
// // //     if (filteredData.isEmpty && reportData.isEmpty) return const Center(child: Text('لا توجد بيانات متاحة'));
    
// // //     return Card(
// // //       margin: const EdgeInsets.all(12),
// // //       child: Scrollbar(
// // //         child: SingleChildScrollView(
// // //           scrollDirection: Axis.vertical,
// // //           child: SingleChildScrollView(
// // //             scrollDirection: Axis.horizontal,
// // //             child: DataTable(
// // //               headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
// // //               columns: [
// // //                 DataColumn(label: _buildFilterHeader('الصنف', 'crop_name')),
// // //                 DataColumn(label: _buildFilterHeader('الدرجة', 'class')),
// // //                 const DataColumn(label: Text('الكمية')),
// // //                 ...selectedTextCols.map((c) => DataColumn(label: _buildFilterHeader(textColumnsMap[c] ?? c, c))),
// // //                 ...selectedNumCols.map((c) => DataColumn(label: Text(numericColumnsMap[c] ?? c))),
// // //               ],
// // //               rows: [
// // //                 ...filteredData.map((row) {
// // //                   final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
// // //                   return DataRow(cells: [
// // //                     DataCell(Text(row['crop_name'] ?? '')),
// // //                     DataCell(Text(row['class'] ?? '')),
// // //                     DataCell(Text(formatNum(row['net_weight']))),
// // //                     ...selectedTextCols.map((c) => DataCell(Text(extra[c]?.toString() ?? '-'))),
// // //                     ...selectedNumCols.map((c) => DataCell(Text(formatNum(extra[c])))),
// // //                   ]);
// // //                 }),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // --- دوال المساعدة للفلترة والأعمدة (بقيت كما هي مع تعديلات بسيطة للتحسين) ---
// // //   void _showFilterDialog(String title, String colKey) {
// // //     Set<String> uniqueValues = {};
// // //     for (var row in reportData) {
// // //       final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
// // //       if (colKey == 'crop_name') uniqueValues.add(row['crop_name']?.toString() ?? "");
// // //       else if (colKey == 'class') uniqueValues.add(row['class']?.toString() ?? "");
// // //       else uniqueValues.add(extra[colKey]?.toString() ?? "");
// // //     }
// // //     List<String> sortedList = uniqueValues.where((v) => v.isNotEmpty).toList()..sort();
// // //     List<String> tempSelected = List.from(activeFilters[colKey] ?? []);

// // //     showDialog(
// // //       context: context,
// // //       builder: (context) => StatefulBuilder(
// // //         builder: (context, setDialogState) => AlertDialog(
// // //           title: Text('فلترة $title'),
// // //           content: SizedBox(
// // //             width: double.maxFinite,
// // //             child: ListView.builder(
// // //               shrinkWrap: true,
// // //               itemCount: sortedList.length,
// // //               itemBuilder: (context, index) {
// // //                 final val = sortedList[index];
// // //                 return CheckboxListTile(
// // //                   title: Text(val),
// // //                   value: tempSelected.contains(val),
// // //                   onChanged: (checked) => setDialogState(() {
// // //                     if (checked!) tempSelected.add(val);
// // //                     else tempSelected.remove(val);
// // //                   }),
// // //                 );
// // //               },
// // //             ),
// // //           ),
// // //           actions: [
// // //             ElevatedButton(
// // //               onPressed: () {
// // //                 setState(() {
// // //                   activeFilters[colKey] = tempSelected;
// // //                   _applyLocalFilters();
// // //                 });
// // //                 Navigator.pop(context);
// // //               },
// // //               child: const Text('تطبيق'),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildFilterHeader(String title, String colKey) {
// // //     bool isFiltered = activeFilters[colKey]?.isNotEmpty ?? false;
// // //     return InkWell(
// // //       onTap: () => _showFilterDialog(title, colKey),
// // //       child: Row(
// // //         mainAxisSize: MainAxisSize.min,
// // //         children: [
// // //           Text(title),
// // //           Icon(Icons.filter_alt, size: 16, color: isFiltered ? Colors.blue : Colors.grey[400]),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   void _showColumnsOptions() {
// // //     showDialog(
// // //       context: context,
// // //       builder: (context) => StatefulBuilder(
// // //         builder: (context, setLocal) => AlertDialog(
// // //           title: const Text('إعدادات الأعمدة'),
// // //           content: SingleChildScrollView(
// // //             child: Column(
// // //               mainAxisSize: MainAxisSize.min,
// // //               children: [
// // //                 ...textColumnsMap.entries.map((entry) => CheckboxListTile(
// // //                   title: Text(entry.value),
// // //                   value: selectedTextCols.contains(entry.key),
// // //                   onChanged: (v) => setLocal(() => v! ? selectedTextCols.add(entry.key) : selectedTextCols.remove(entry.key)),
// // //                 )),
// // //                 const Divider(),
// // //                 ...numericColumnsMap.entries.map((entry) => CheckboxListTile(
// // //                   title: Text(entry.value),
// // //                   value: selectedNumCols.contains(entry.key),
// // //                   onChanged: (v) => setLocal(() => v! ? selectedNumCols.add(entry.key) : selectedNumCols.remove(entry.key)),
// // //                 )),
// // //               ],
// // //             ),
// // //           ),
// // //           actions: [
// // //             ElevatedButton(
// // //               onPressed: () {
// // //                 _saveColumns();
// // //                 Navigator.pop(context);
// // //                 loadReport();
// // //               },
// // //               child: const Text('حفظ'),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _dateItem(String label, DateTime value, VoidCallback onPick) {
// // //     return InkWell(
// // //       onTap: onPick,
// // //       child: Column(
// // //         children: [
// // //           Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
// // //           Text(intl.DateFormat('yyyy-MM-dd').format(value), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart' as intl;
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import 'package:shared_preferences/shared_preferences.dart';

// // class PlanninReportScreen extends StatefulWidget {
// //   const PlanninReportScreen({super.key});

// //   @override
// //   State<PlanninReportScreen> createState() => _FarzaReportScreenState();
// // }

// // class _FarzaReportScreenState extends State<PlanninReportScreen> {
// //   final supabase = Supabase.instance.client;

// //   DateTime fromDate = DateTime(2025, 12, 1);
// //   DateTime toDate = DateTime.now();
  
// //   // فلتر الحالة الجديد
// //   String? statusFilter; 

// //   final Map<String, String> textColumnsMap = {
// //     'Date': 'التاريخ',
// //     'ShippingDate': 'تاريخ الشحن',
// //     'Country': 'الدولة',
// //     'Count': 'الحجم',
// //     'CTNType': 'نوع الكرتون',
// //     'CTNWeight': 'وزن الكرتون',
// //     'Brand': 'الماركه',
// //     'Serial': 'رقم الطلبية',
// //     'status': 'الحالة', 
// //   };

// //   final Map<String, String> numericColumnsMap = {
// //     'PalletsCount': 'كمية الطلبية',
// //     'Production_Pallet': 'كمية الانتاج',
// //     'Shipping_Pallet': 'كمية المشحون',
// //     'balance': 'مطلوب انتاجه',
// //   };

// //   List<String> selectedTextCols = [];
// //   List<String> selectedNumCols = [];

// //   List reportData = []; 
// //   List filteredData = []; 
// //   bool loading = false;

// //   Map<String, List<String>> activeFilters = {};

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadSavedColumns().then((_) {
// //       loadReport();
// //     });
// //   }

// //   Future<void> _loadSavedColumns() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     setState(() {
// //       selectedTextCols = prefs.getStringList('selectedTextCols') ?? [];
// //       selectedNumCols = prefs.getStringList('selectedNumCols') ?? [];
// //     });
// //   }

// //   Future<void> _saveColumns() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     await prefs.setStringList('selectedTextCols', selectedTextCols);
// //     await prefs.setStringList('selectedNumCols', selectedNumCols);
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

// //   Future<void> loadReport() async {
// //     setState(() => loading = true);
// //     try {
// //       List<String> rpcGroupCols = List.from(selectedTextCols);
// //       if (!rpcGroupCols.contains('status')) rpcGroupCols.add('status');

// //       final res = await supabase.rpc(
// //         'get_planning_report',
// //         params: {
// //           'p_date_from': intl.DateFormat('yyyy-MM-dd').format(fromDate),
// //           'p_date_to': intl.DateFormat('yyyy-MM-dd').format(toDate),
// //           'p_crop_name': null, 
// //           'p_crop_class': null,
// //           'p_group_columns': rpcGroupCols,
// //           'p_sum_columns': selectedNumCols,
// //         },
// //       );
// //       setState(() {
// //         reportData = List.from(res);
// //         _applyLocalFilters(); 
// //         loading = false;
// //       });
// //     } catch (e) {
// //       setState(() => loading = false);
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('خطأ في تحميل التقرير: $e')),
// //         );
// //       }
// //     }
// //   }

// //   void _applyLocalFilters() {
// //     setState(() {
// //       filteredData = reportData.where((row) {
// //         bool match = true;
// //         final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};

// //         if (statusFilter != null) {
// //           if (extra['status'] != statusFilter) match = false;
// //         }

// //         if (match) {
// //           activeFilters.forEach((colKey, selectedValues) {
// //             if (selectedValues.isNotEmpty) {
// //               String rowValue = "";
// //               if (colKey == 'crop_name') {
// //                 rowValue = row['crop_name']?.toString() ?? "";
// //               } else if (colKey == 'class') {
// //                 rowValue = row['class']?.toString() ?? "";
// //               } else {
// //                 rowValue = extra[colKey]?.toString() ?? "";
// //               }
// //               if (!selectedValues.contains(rowValue)) match = false;
// //             }
// //           });
// //         }
        
// //         return match;
// //       }).toList();
// //     });
// //   }

// //   num get currentTotalWeight => filteredData.fold(0, (s, e) => s + (e['net_weight'] ?? 0));

// //   num sumNumericColumn(String columnName) {
// //     if (filteredData.isEmpty) return 0;
// //     return filteredData.fold(0, (s, e) {
// //       final extra = e['extra_columns'] as Map<String, dynamic>? ?? {};
// //       final val = extra[columnName];
// //       return s + (val is num ? val : (double.tryParse(val?.toString() ?? '0') ?? 0));
// //     });
// //   }

// //   // دالة الفلترة مع البحث النصي
// //   void _showFilterDialog(String title, String colKey) {
// //     Set<String> uniqueValues = {};
// //     for (var row in reportData) {
// //       final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
// //       if (colKey == 'crop_name') uniqueValues.add(row['crop_name']?.toString() ?? "");
// //       else if (colKey == 'class') uniqueValues.add(row['class']?.toString() ?? "");
// //       else uniqueValues.add(extra[colKey]?.toString() ?? "");
// //     }
    
// //     List<String> sortedList = uniqueValues.where((v) => v.isNotEmpty).toList()..sort();
// //     List<String> tempSelected = List.from(activeFilters[colKey] ?? []);
// //     String dialogSearchQuery = "";

// //     showDialog(
// //       context: context,
// //       builder: (context) => StatefulBuilder(
// //         builder: (context, setDialogState) {
// //           // تصفية القائمة بناءً على نص البحث داخل الدايالوج
// //           List<String> filteredList = sortedList
// //               .where((item) => item.toLowerCase().contains(dialogSearchQuery.toLowerCase()))
// //               .toList();

// //           return AlertDialog(
// //             title: Text('فلترة $title'),
// //             content: SizedBox(
// //               width: double.maxFinite,
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   TextField(
// //                     decoration: const InputDecoration(
// //                       hintText: 'بحث داخل القائمة...',
// //                       prefixIcon: Icon(Icons.search),
// //                       border: OutlineInputBorder(),
// //                     ),
// //                     onChanged: (v) => setDialogState(() => dialogSearchQuery = v),
// //                   ),
// //                   const SizedBox(height: 10),
// //                   ConstrainedBox(
// //                     constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
// //                     child: ListView.builder(
// //                       shrinkWrap: true,
// //                       itemCount: filteredList.length,
// //                       itemBuilder: (context, index) {
// //                         final val = filteredList[index];
// //                         return CheckboxListTile(
// //                           title: Text(val),
// //                           value: tempSelected.contains(val),
// //                           onChanged: (checked) {
// //                             setDialogState(() {
// //                               if (checked!) tempSelected.add(val);
// //                               else tempSelected.remove(val);
// //                             });
// //                           },
// //                         );
// //                       },
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             actions: [
// //               TextButton(
// //                 onPressed: () {
// //                   setState(() {
// //                     activeFilters[colKey] = [];
// //                     _applyLocalFilters();
// //                   });
// //                   Navigator.pop(context);
// //                 },
// //                 child: const Text('إلغاء الكل', style: TextStyle(color: Colors.red)),
// //               ),
// //               ElevatedButton(
// //                 onPressed: () {
// //                   setState(() {
// //                     activeFilters[colKey] = tempSelected;
// //                     _applyLocalFilters();
// //                   });
// //                   Navigator.pop(context);
// //                 },
// //                 child: const Text('تطبيق'),
// //               ),
// //             ],
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   Widget _buildFilterHeader(String title, String colKey) {
// //     bool isFiltered = activeFilters[colKey]?.isNotEmpty ?? false;
// //     return InkWell(
// //       onTap: () => _showFilterDialog(title, colKey),
// //       child: Row(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Text(title),
// //           Icon(Icons.filter_alt, size: 16, color: isFiltered ? Colors.blue : Colors.grey[400]),
// //         ],
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Directionality(
// //       textDirection: TextDirection.rtl,
// //       child: Scaffold(
// //         backgroundColor: Colors.grey[100],
// //         appBar: AppBar(
// //           title: const Text('تقرير التخطيط'),
// //           centerTitle: true,
// //           actions: [
// //             IconButton(icon: const Icon(Icons.refresh), onPressed: loadReport)
// //           ],
// //         ),
// //         body: Column(
// //           children: [
// //             _filtersSection(),
// //             // _summaryCards(),
// //             Expanded(
// //               child: loading
// //                   ? const Center(child: CircularProgressIndicator())
// //                   : _tableSection(),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _filtersSection() {
// //     return Card(
// //       margin: const EdgeInsets.all(12),
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(12),
// //         child: Column(
// //           children: [
// //             Row(
// //               children: [
// //                 const Text('الحالة: ', style: TextStyle(fontWeight: FontWeight.bold)),
// //                 Expanded(
// //                   child: SingleChildScrollView(
// //                     scrollDirection: Axis.horizontal,
// //                     child: Row(
// //                       children: ['انتظار', 'تحت التشغيل', 'انتهي'].map((s) {
// //                         return Padding(
// //                           padding: const EdgeInsets.symmetric(horizontal: 4),
// //                           child: ChoiceChip(
// //                             label: Text(s, style: const TextStyle(fontSize: 12)),
// //                             selected: statusFilter == s,
// //                             onSelected: (selected) {
// //                               setState(() {
// //                                 statusFilter = selected ? s : null;
// //                                 _applyLocalFilters();
// //                               });
// //                             },
// //                           ),
// //                         );
// //                       }).toList(),
// //                     ),
// //                   ),
// //                 ),
// //                 IconButton.filledTonal(
// //                   onPressed: _showColumnsOptions,
// //                   icon: const Icon(Icons.settings),
// //                 ),
// //               ],
// //             ),
// //             const Divider(height: 20),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceAround,
// //               children: [
// //                 _dateItem('من', fromDate, () async {
// //                   final picked = await showDatePicker(context: context, initialDate: fromDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
// //                   if (picked != null) setState(() { fromDate = picked; loadReport(); });
// //                 }),
// //                 _dateItem('إلى', toDate, () async {
// //                   final picked = await showDatePicker(context: context, initialDate: toDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
// //                   if (picked != null) setState(() { toDate = picked; loadReport(); });
// //                 }),
// //                 TextButton(
// //                   onPressed: () => setState(() {
// //                     activeFilters.clear();
// //                     statusFilter = null;
// //                     _applyLocalFilters();
// //                   }),
// //                   child: const Text('تصفير الفلاتر', style: TextStyle(color: Colors.red, fontSize: 12)),
// //                 )
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // Widget _summaryCards() {
// //   //   return Padding(
// //   //     padding: const EdgeInsets.symmetric(horizontal: 12),
// //   //     child: Row(
// //   //       children: [
// //   //         _cardInfo('إجمالي الوزن (المصفى)', formatNum(currentTotalWeight), Colors.blue),
// //   //       ],
// //   //     ),
// //   //   );
// //   // }

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
// //     if (filteredData.isEmpty && reportData.isEmpty) return const Center(child: Text('لا توجد بيانات متاحة'));
    
// //     return Card(
// //       margin: const EdgeInsets.all(12),
// //       child: Scrollbar(
// //         child: SingleChildScrollView(
// //           scrollDirection: Axis.vertical,
// //           child: SingleChildScrollView(
// //             scrollDirection: Axis.horizontal,
// //             child: DataTable(
// //               headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
// //               columns: [
// //                 DataColumn(label: _buildFilterHeader('الصنف', 'crop_name')),
// //                 DataColumn(label: _buildFilterHeader('الدرجة', 'class')),
// //                 const DataColumn(label: Text('الكمية')),
// //                 ...selectedTextCols.map((c) => DataColumn(label: _buildFilterHeader(textColumnsMap[c] ?? c, c))),
// //                 ...selectedNumCols.map((c) => DataColumn(label: Text(numericColumnsMap[c] ?? c))),
// //               ],
// //               rows: [
// //                 // صفوف البيانات
// //                 ...filteredData.map((row) {
// //                   final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
// //                   return DataRow(cells: [
// //                     DataCell(Text(row['crop_name'] ?? '')),
// //                     DataCell(Text(row['class'] ?? '')),
// //                     DataCell(Text(formatNum(row['net_weight']))),
// //                     ...selectedTextCols.map((c) => DataCell(Text(extra[c]?.toString() ?? '-'))),
// //                     ...selectedNumCols.map((c) => DataCell(Text(formatNum(extra[c])))),
// //                   ]);
// //                 }),
// //                 // سطر الإجمالي (Total Row)
// //                 DataRow(
// //                   color: WidgetStateProperty.all(Colors.amber[50]),
// //                   cells: [
// //                     const DataCell(Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold))),
// //                     const DataCell(Text('')),
// //                     DataCell(Text(formatNum(currentTotalWeight), style: const TextStyle(fontWeight: FontWeight.bold))),
// //                     ...selectedTextCols.map((_) => const DataCell(Text(''))),
// //                     ...selectedNumCols.map((c) => DataCell(
// //                       Text(formatNum(sumNumericColumn(c)), style: const TextStyle(fontWeight: FontWeight.bold)),
// //                     )),
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
// //               children: [
// //                 ...textColumnsMap.entries.map((entry) => CheckboxListTile(
// //                   title: Text(entry.value),
// //                   value: selectedTextCols.contains(entry.key),
// //                   onChanged: (v) => setLocal(() => v! ? selectedTextCols.add(entry.key) : selectedTextCols.remove(entry.key)),
// //                 )),
// //                 const Divider(),
// //                 ...numericColumnsMap.entries.map((entry) => CheckboxListTile(
// //                   title: Text(entry.value),
// //                   value: selectedNumCols.contains(entry.key),
// //                   onChanged: (v) => setLocal(() => v! ? selectedNumCols.add(entry.key) : selectedNumCols.remove(entry.key)),
// //                 )),
// //               ],
// //             ),
// //           ),
// //           actions: [
// //             ElevatedButton(onPressed: () { _saveColumns(); Navigator.pop(context); loadReport(); }, child: const Text('حفظ')),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _dateItem(String label, DateTime value, VoidCallback onPick) {
// //     return InkWell(
// //       onTap: onPick,
// //       child: Column(
// //         children: [
// //           Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
// //           Text(intl.DateFormat('yyyy-MM-dd').format(value), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
// //         ],
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart' as intl;
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class PlanninReportScreen extends StatefulWidget {
//   const PlanninReportScreen({super.key});

//   @override
//   State<PlanninReportScreen> createState() => _FarzaReportScreenState();
// }

// class _FarzaReportScreenState extends State<PlanninReportScreen> {
//   final supabase = Supabase.instance.client;

//   DateTime fromDate = DateTime(2025, 12, 1);
//   DateTime toDate = DateTime.now();
  
//   // فلتر الحالة
//   String? statusFilter; 

//   final Map<String, String> textColumnsMap = {
//     'Date': 'التاريخ',
//     'ShippingDate': 'تاريخ الشحن',
//     'Country': 'الدولة',
//     'Count': 'الحجم',
//     'CTNType': 'نوع الكرتون',
//     'CTNWeight': 'وزن الكرتون',
//     'Brand': 'الماركه',
//     'Serial': 'رقم الطلبية',
//   };

//   final Map<String, String> numericColumnsMap = {
//     'PalletsCount': 'كمية الطلبية',
//     'Production_Pallet': 'كمية الانتاج',
//     'Shipping_Pallet': 'كمية المشحون',
//     'balance': 'مطلوب انتاجه',
//   };

//   List<String> selectedTextCols = [];
//   List<String> selectedNumCols = [];

//   List rawReportData = []; // البيانات الخام من السيرفر
//   List mergedData = [];   // البيانات بعد الدمج
//   List filteredData = []; // البيانات بعد الفلترة النهائية
//   bool loading = false;

//   Map<String, List<String>> activeFilters = {};

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedColumns().then((_) {
//       loadReport();
//     });
//   }

//   Future<void> _loadSavedColumns() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       selectedTextCols = prefs.getStringList('selectedTextCols') ?? [];
//       selectedNumCols = prefs.getStringList('selectedNumCols') ?? [];
//     });
//   }

//   Future<void> _saveColumns() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setStringList('selectedTextCols', selectedTextCols);
//     await prefs.setStringList('selectedNumCols', selectedNumCols);
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

//   Future<void> loadReport() async {
//     setState(() => loading = true);
//     try {
//       // نرسل الـ status دائماً للسيرفر لنتمكن من الفلترة عليها محلياً
//       List<String> rpcGroupCols = List.from(selectedTextCols);
//       if (!rpcGroupCols.contains('status')) rpcGroupCols.add('status');

//       final res = await supabase.rpc(
//         'get_planning_report',
//         params: {
//           'p_date_from': intl.DateFormat('yyyy-MM-dd').format(fromDate),
//           'p_date_to': intl.DateFormat('yyyy-MM-dd').format(toDate),
//           'p_crop_name': null, 
//           'p_crop_class': null,
//           'p_group_columns': rpcGroupCols,
//           'p_sum_columns': selectedNumCols,
//         },
//       );
      
//       setState(() {
//         rawReportData = List.from(res);
//         _processAndMergeData();
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

//   // دالة دمج الأسطر المتشابهة وجمع القيم الرقمية
//   void _processAndMergeData() {
//     Map<String, Map<String, dynamic>> grouped = {};

//     for (var row in rawReportData) {
//       final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
      
//       // ننشئ "مفتاح فريد" للسطر بناءً على الأعمدة النصية المختارة + الصنف والدرجة
//       // لكن نستبعد الـ status من المفتاح لكي ندمج الحالات المختلفة في سطر واحد
//       String groupKey = "${row['crop_name']}_${row['class']}";
//       for (var col in selectedTextCols) {
//         if (col != 'status') {
//           groupKey += "_${extra[col] ?? ''}";
//         }
//       }

//       if (!grouped.containsKey(groupKey)) {
//         // إذا كان السطر جديد، نضيفه كما هو
//         grouped[groupKey] = {
//           'crop_name': row['crop_name'],
//           'class': row['class'],
//           'net_weight': (row['net_weight'] ?? 0) as num,
//           'extra_columns': Map<String, dynamic>.from(extra),
//           'statuses': [extra['status']], // نحتفظ بقائمة الحالات للفلترة لاحقاً
//         };
//       } else {
//         // إذا كان موجود، نجمع القيم الرقمية
//         grouped[groupKey]!['net_weight'] += (row['net_weight'] ?? 0) as num;
        
//         Map<String, dynamic> existingExtra = grouped[groupKey]!['extra_columns'];
//         for (var numCol in selectedNumCols) {
//           num val = num.tryParse(extra[numCol]?.toString() ?? '0') ?? 0;
//           num current = num.tryParse(existingExtra[numCol]?.toString() ?? '0') ?? 0;
//           existingExtra[numCol] = current + val;
//         }
        
//         // نضيف الحالة لقائمة الحالات لو لم تكن موجودة
//         if (!grouped[groupKey]!['statuses'].contains(extra['status'])) {
//           grouped[groupKey]!['statuses'].add(extra['status']);
//         }
//       }
//     }

//     mergedData = grouped.values.toList();
//     _applyLocalFilters();
//   }

//   void _applyLocalFilters() {
//     setState(() {
//       filteredData = mergedData.where((row) {
//         bool match = true;
//         final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};

//         // فلتر الحالة: السطر يظهر إذا كانت الحالة المختارة موجودة ضمن حالاته
//         if (statusFilter != null) {
//           List statuses = row['statuses'] ?? [];
//           if (!statuses.contains(statusFilter)) match = false;
//         }

//         if (match) {
//           activeFilters.forEach((colKey, selectedValues) {
//             if (selectedValues.isNotEmpty) {
//               String rowValue = "";
//               if (colKey == 'crop_name') {
//                 rowValue = row['crop_name']?.toString() ?? "";
//               } else if (colKey == 'class') {
//                 rowValue = row['class']?.toString() ?? "";
//               } else {
//                 rowValue = extra[colKey]?.toString() ?? "";
//               }
//               if (!selectedValues.contains(rowValue)) match = false;
//             }
//           });
//         }
        
//         return match;
//       }).toList();
//     });
//   }

//   num get currentTotalWeight => filteredData.fold(0, (s, e) => s + (e['net_weight'] ?? 0));

//   num sumNumericColumn(String columnName) {
//     if (filteredData.isEmpty) return 0;
//     return filteredData.fold(0, (s, e) {
//       final extra = e['extra_columns'] as Map<String, dynamic>? ?? {};
//       final val = extra[columnName];
//       return s + (val is num ? val : (double.tryParse(val?.toString() ?? '0') ?? 0));
//     });
//   }

//   void _showFilterDialog(String title, String colKey) {
//     Set<String> uniqueValues = {};
//     // نستخدم mergedData للفلترة لضمان ظهور القيم المتاحة فقط بعد الدمج
//     for (var row in mergedData) {
//       final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
//       if (colKey == 'crop_name') uniqueValues.add(row['crop_name']?.toString() ?? "");
//       else if (colKey == 'class') uniqueValues.add(row['class']?.toString() ?? "");
//       else uniqueValues.add(extra[colKey]?.toString() ?? "");
//     }
    
//     List<String> sortedList = uniqueValues.where((v) => v.isNotEmpty).toList()..sort();
//     List<String> tempSelected = List.from(activeFilters[colKey] ?? []);
//     String dialogSearchQuery = "";

//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setDialogState) {
//           List<String> filteredList = sortedList
//               .where((item) => item.toLowerCase().contains(dialogSearchQuery.toLowerCase()))
//               .toList();

//           return AlertDialog(
//             title: Text('فلترة $title'),
//             content: SizedBox(
//               width: double.maxFinite,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     decoration: const InputDecoration(
//                       hintText: 'بحث داخل القائمة...',
//                       prefixIcon: Icon(Icons.search),
//                       border: OutlineInputBorder(),
//                     ),
//                     onChanged: (v) => setDialogState(() => dialogSearchQuery = v),
//                   ),
//                   const SizedBox(height: 10),
//                   ConstrainedBox(
//                     constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
//                     child: ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: filteredList.length,
//                       itemBuilder: (context, index) {
//                         final val = filteredList[index];
//                         return CheckboxListTile(
//                           title: Text(val),
//                           value: tempSelected.contains(val),
//                           onChanged: (checked) {
//                             setDialogState(() {
//                               if (checked!) tempSelected.add(val);
//                               else tempSelected.remove(val);
//                             });
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   setState(() {
//                     activeFilters[colKey] = [];
//                     _applyLocalFilters();
//                   });
//                   Navigator.pop(context);
//                 },
//                 child: const Text('إلغاء الكل', style: TextStyle(color: Colors.red)),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     activeFilters[colKey] = tempSelected;
//                     _applyLocalFilters();
//                   });
//                   Navigator.pop(context);
//                 },
//                 child: const Text('تطبيق'),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildFilterHeader(String title, String colKey) {
//     bool isFiltered = activeFilters[colKey]?.isNotEmpty ?? false;
//     return InkWell(
//       onTap: () => _showFilterDialog(title, colKey),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(title),
//           Icon(Icons.filter_alt, size: 16, color: isFiltered ? Colors.blue : Colors.grey[400]),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         backgroundColor: Colors.grey[100],
//         appBar: AppBar(
//           title: const Text('تقرير التخطيط المجمع'),
//           centerTitle: true,
//           actions: [
//             IconButton(icon: const Icon(Icons.refresh), onPressed: loadReport)
//           ],
//         ),
//         body: Column(
//           children: [
//             _filtersSection(),
//             // _summaryCards(),
//             Expanded(
//               child: loading
//                   ? const Center(child: CircularProgressIndicator())
//                   : _tableSection(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _filtersSection() {
//     return Card(
//       margin: const EdgeInsets.all(12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 const Text('تصفية بالحالة: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Row(
//                       children: ['انتظار', 'تحت التشغيل', 'انتهي'].map((s) {
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 4),
//                           child: ChoiceChip(
//                             label: Text(s, style: const TextStyle(fontSize: 11)),
//                             selected: statusFilter == s,
//                             onSelected: (selected) {
//                               setState(() {
//                                 statusFilter = selected ? s : null;
//                                 _applyLocalFilters();
//                               });
//                             },
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 ),
//                 IconButton.filledTonal(
//                   onPressed: _showColumnsOptions,
//                   icon: const Icon(Icons.view_column_rounded),
//                 ),
//               ],
//             ),
//             const Divider(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _dateItem('من', fromDate, () async {
//                   final picked = await showDatePicker(context: context, initialDate: fromDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
//                   if (picked != null) setState(() { fromDate = picked; loadReport(); });
//                 }),
//                 _dateItem('إلى', toDate, () async {
//                   final picked = await showDatePicker(context: context, initialDate: toDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
//                   if (picked != null) setState(() { toDate = picked; loadReport(); });
//                 }),
//                 TextButton.icon(
//                   onPressed: () => setState(() {
//                     activeFilters.clear();
//                     statusFilter = null;
//                     _applyLocalFilters();
//                   }),
//                   icon: const Icon(Icons.clear_all, size: 16),
//                   label: const Text('تصفير', style: TextStyle(fontSize: 12)),
//                 )
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Widget _summaryCards() {
//   //   return Padding(
//   //     padding: const EdgeInsets.symmetric(horizontal: 12),
//   //     child: Row(
//   //       children: [
//   //         _cardInfo('إجمالي الوزن المجمع', formatNum(currentTotalWeight), Colors.teal),
//   //       ],
//   //     ),
//   //   );
//   // }

//   Widget _cardInfo(String title, String value, Color color) {
//     return Expanded(
//       child: Card(
//         color: color.withOpacity(0.05),
//         elevation: 0,
//         shape: RoundedRectangleBorder(side: BorderSide(color: color.withOpacity(0.2)), borderRadius: BorderRadius.circular(10)),
//         child: Padding(
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             children: [
//               Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
//               Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _tableSection() {
//     if (filteredData.isEmpty && !loading) return const Center(child: Padding(
//       padding: EdgeInsets.all(20.0),
//       child: Text('لا توجد بيانات تطابق البحث'),
//     ));
    
//     return Card(
//       margin: const EdgeInsets.all(12),
//       clipBehavior: Clip.antiAlias,
//       child: Scrollbar(
//         thumbVisibility: true,
//         child: SingleChildScrollView(
//           scrollDirection: Axis.vertical,
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: DataTable(
//               headingRowColor: WidgetStateProperty.all(Colors.blueGrey[50]),
//               columnSpacing: 20,
//               horizontalMargin: 15,
//               columns: [
//                 DataColumn(label: _buildFilterHeader('الصنف', 'crop_name')),
//                 DataColumn(label: _buildFilterHeader('الدرجة', 'class')),
//                 const DataColumn(label: Text('الوزن الكلي')),
//                 ...selectedTextCols.where((c) => c != 'status').map((c) => DataColumn(label: _buildFilterHeader(textColumnsMap[c] ?? c, c))),
//                 ...selectedNumCols.map((c) => DataColumn(label: Text(numericColumnsMap[c] ?? c))),
//               ],
//               rows: [
//                 ...filteredData.map((row) {
//                   final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
//                   return DataRow(cells: [
//                     DataCell(Text(row['crop_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500))),
//                     DataCell(Text(row['class'] ?? '')),
//                     DataCell(Text(formatNum(row['net_weight']))),
//                     ...selectedTextCols.where((c) => c != 'status').map((c) => DataCell(Text(extra[c]?.toString() ?? '-'))),
//                     ...selectedNumCols.map((c) => DataCell(Text(formatNum(extra[c])))),
//                   ]);
//                 }),
//                 // سطر الإجمالي النهائي
//                 DataRow(
//                   color: WidgetStateProperty.all(Colors.amber[50]),
//                   cells: [
//                     const DataCell(Text('الإجمالي العام', style: TextStyle(fontWeight: FontWeight.bold))),
//                     const DataCell(Text('')),
//                     DataCell(Text(formatNum(currentTotalWeight), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal))),
//                     ...selectedTextCols.where((c) => c != 'status').map((_) => const DataCell(Text(''))),
//                     ...selectedNumCols.map((c) => DataCell(
//                       Text(formatNum(sumNumericColumn(c)), style: const TextStyle(fontWeight: FontWeight.bold)),
//                     )),
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
//               children: [
//                 ...textColumnsMap.entries.where((e) => e.key != 'status').map((entry) => CheckboxListTile(
//                   title: Text(entry.value),
//                   value: selectedTextCols.contains(entry.key),
//                   onChanged: (v) => setLocal(() => v! ? selectedTextCols.add(entry.key) : selectedTextCols.remove(entry.key)),
//                 )),
//                 const Divider(),
//                 ...numericColumnsMap.entries.map((entry) => CheckboxListTile(
//                   title: Text(entry.value),
//                   value: selectedNumCols.contains(entry.key),
//                   onChanged: (v) => setLocal(() => v! ? selectedNumCols.add(entry.key) : selectedNumCols.remove(entry.key)),
//                 )),
//               ],
//             ),
//           ),
//           actions: [
//             ElevatedButton(onPressed: () { _saveColumns(); Navigator.pop(context); loadReport(); }, child: const Text('تطبيق التعديلات')),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _dateItem(String label, DateTime value, VoidCallback onPick) {
//     return InkWell(
//       onTap: onPick,
//       child: Column(
//         children: [
//           Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
//           Text(intl.DateFormat('yyyy-MM-dd').format(value), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlanninReportScreen extends StatefulWidget {
  const PlanninReportScreen({super.key});

  @override
  State<PlanninReportScreen> createState() => _FarzaReportScreenState();
}

class _FarzaReportScreenState extends State<PlanninReportScreen> {
  final supabase = Supabase.instance.client;

  DateTime fromDate = DateTime(2025, 12, 1);
  DateTime toDate = DateTime.now();
  
  // فلتر الحالة
  String? statusFilter; 

  final Map<String, String> textColumnsMap = {
    'Date': 'التاريخ',
    'ShippingDate': 'تاريخ الشحن',
    'Country': 'الدولة',
    'Count': 'الحجم',
    'CTNType': 'نوع الكرتون',
    'CTNWeight': 'وزن الكرتون',
    'Brand': 'الماركه',
    'Serial': 'رقم الطلبية',
  };

  final Map<String, String> numericColumnsMap = {
    'PalletsCount': 'كمية الطلبية',
    'Production_Pallet': 'كمية الانتاج',
    'Shipping_Pallet': 'كمية المشحون',
    'balance': 'مطلوب انتاجه',
  };

  List<String> selectedTextCols = [];
  List<String> selectedNumCols = [];

  List rawReportData = []; // البيانات الخام من السيرفر
  List mergedData = [];   // البيانات بعد الدمج
  List filteredData = []; // البيانات بعد الفلترة النهائية
  bool loading = false;

  Map<String, List<String>> activeFilters = {};

  @override
  void initState() {
    super.initState();
    _loadSavedColumns().then((_) {
      loadReport();
    });
  }

  Future<void> _loadSavedColumns() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedTextCols = prefs.getStringList('selectedTextCols') ?? [];
      selectedNumCols = prefs.getStringList('selectedNumCols') ?? [];
    });
  }

  Future<void> _saveColumns() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedTextCols', selectedTextCols);
    await prefs.setStringList('selectedNumCols', selectedNumCols);
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

  Future<void> loadReport() async {
    setState(() => loading = true);
    try {
      // نرسل الـ status دائماً ضمن الـ group_columns للسيرفر لكي يعيد لنا البيانات موزعة حسب الحالة
      // ثم نقوم نحن بالدمج أو الفلترة برمجياً لتجنب خطأ الـ RPC
      List<String> rpcGroupCols = List.from(selectedTextCols);
      if (!rpcGroupCols.contains('status')) rpcGroupCols.add('status');

      final res = await supabase.rpc(
        'get_planning_report',
        params: {
          'p_date_from': intl.DateFormat('yyyy-MM-dd').format(fromDate),
          'p_date_to': intl.DateFormat('yyyy-MM-dd').format(toDate),
          'p_crop_name': null, 
          'p_crop_class': null,
          'p_group_columns': rpcGroupCols,
          'p_sum_columns': selectedNumCols,
        },
      );
      
      setState(() {
        rawReportData = List.from(res);
        _processAndMergeData();
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

  // دالة دمج الأسطر المتشابهة وجمع القيم الرقمية مع مراعاة فلتر الحالة
  void _processAndMergeData() {
    Map<String, Map<String, dynamic>> grouped = {};

    for (var row in rawReportData) {
      final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
      
      // إذا كان هناك فلتر حالة مختار، نتجاهل أي سطر لا يطابق هذه الحالة قبل الدمج
      if (statusFilter != null && extra['status'] != statusFilter) {
        continue;
      }

      // ننشئ "مفتاح فريد" للسطر بناءً على الأعمدة النصية المختارة (بدون الحالة)
      String groupKey = "${row['crop_name']}_${row['class']}";
      for (var col in selectedTextCols) {
        if (col != 'status') {
          groupKey += "_${extra[col] ?? ''}";
        }
      }

      if (!grouped.containsKey(groupKey)) {
        grouped[groupKey] = {
          'crop_name': row['crop_name'],
          'class': row['class'],
          'net_weight': (row['net_weight'] ?? 0) as num,
          'extra_columns': Map<String, dynamic>.from(extra),
        };
      } else {
        grouped[groupKey]!['net_weight'] += (row['net_weight'] ?? 0) as num;
        
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
            String rowValue = "";
            if (colKey == 'crop_name') {
              rowValue = row['crop_name']?.toString() ?? "";
            } else if (colKey == 'class') {
              rowValue = row['class']?.toString() ?? "";
            } else {
              rowValue = extra[colKey]?.toString() ?? "";
            }
            if (!selectedValues.contains(rowValue)) match = false;
          }
        });
        
        return match;
      }).toList();
    });
  }

  num get currentTotalWeight => filteredData.fold(0, (s, e) => s + (e['net_weight'] ?? 0));

  num sumNumericColumn(String columnName) {
    if (filteredData.isEmpty) return 0;
    return filteredData.fold(0, (s, e) {
      final extra = e['extra_columns'] as Map<String, dynamic>? ?? {};
      final val = extra[columnName];
      return s + (val is num ? val : (double.tryParse(val?.toString() ?? '0') ?? 0));
    });
  }

  void _showFilterDialog(String title, String colKey) {
    Set<String> uniqueValues = {};
    for (var row in mergedData) {
      final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
      if (colKey == 'crop_name') uniqueValues.add(row['crop_name']?.toString() ?? "");
      else if (colKey == 'class') uniqueValues.add(row['class']?.toString() ?? "");
      else uniqueValues.add(extra[colKey]?.toString() ?? "");
    }
    
    List<String> sortedList = uniqueValues.where((v) => v.isNotEmpty).toList()..sort();
    List<String> tempSelected = List.from(activeFilters[colKey] ?? []);
    String dialogSearchQuery = "";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          List<String> filteredList = sortedList
              .where((item) => item.toLowerCase().contains(dialogSearchQuery.toLowerCase()))
              .toList();

          return AlertDialog(
            title: Text('فلترة $title'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'بحث داخل القائمة...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setDialogState(() => dialogSearchQuery = v),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final val = filteredList[index];
                        return CheckboxListTile(
                          title: Text(val),
                          value: tempSelected.contains(val),
                          onChanged: (checked) {
                            setDialogState(() {
                              if (checked!) tempSelected.add(val);
                              else tempSelected.remove(val);
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    activeFilters[colKey] = [];
                    _applyLocalFilters();
                  });
                  Navigator.pop(context);
                },
                child: const Text('إلغاء الكل', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    activeFilters[colKey] = tempSelected;
                    _applyLocalFilters();
                  });
                  Navigator.pop(context);
                },
                child: const Text('تطبيق'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterHeader(String title, String colKey) {
    bool isFiltered = activeFilters[colKey]?.isNotEmpty ?? false;
    return InkWell(
      onTap: () => _showFilterDialog(title, colKey),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title),
          Icon(Icons.filter_alt, size: 16, color: isFiltered ? Colors.blue : Colors.grey[400]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('تقرير التخطيط المطور'),
          centerTitle: true,
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: loadReport)
          ],
        ),
        body: Column(
          children: [
            _filtersSection(),
            // _summaryCards(),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : _tableSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filtersSection() {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                const Text('عرض الحالة: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['انتظار', 'تحت التشغيل', 'انتهي'].map((s) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(s, style: const TextStyle(fontSize: 11)),
                            selected: statusFilter == s,
                            onSelected: (selected) {
                              setState(() {
                                statusFilter = selected ? s : null;
                                // نقوم بإعادة معالجة البيانات الموجودة أصلاً
                                _processAndMergeData();
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: _showColumnsOptions,
                  icon: const Icon(Icons.view_column_rounded),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _dateItem('من', fromDate, () async {
                  final picked = await showDatePicker(context: context, initialDate: fromDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
                  if (picked != null) setState(() { fromDate = picked; loadReport(); });
                }),
                _dateItem('إلى', toDate, () async {
                  final picked = await showDatePicker(context: context, initialDate: toDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
                  if (picked != null) setState(() { toDate = picked; loadReport(); });
                }),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      activeFilters.clear();
                      statusFilter = null;
                      _processAndMergeData();
                    });
                  },
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('تصفير الكل', style: TextStyle(fontSize: 12)),
                )
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
          _cardInfo('إجمالي الوزن المعروض', formatNum(currentTotalWeight), Colors.teal),
        ],
      ),
    );
  }

  Widget _cardInfo(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.05),
        elevation: 0,
        shape: RoundedRectangleBorder(side: BorderSide(color: color.withOpacity(0.2)), borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tableSection() {
    if (filteredData.isEmpty && !loading) return const Center(child: Padding(
      padding: EdgeInsets.all(20.0),
      child: Text('لا توجد بيانات تطابق الاختيارات'),
    ));
    
    return Card(
      margin: const EdgeInsets.all(12),
      clipBehavior: Clip.antiAlias,
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.blueGrey[50]),
              columnSpacing: 20,
              horizontalMargin: 15,
              columns: [
                DataColumn(label: _buildFilterHeader('الصنف', 'crop_name')),
                DataColumn(label: _buildFilterHeader('الدرجة', 'class')),
                const DataColumn(label: Text('الوزن الكلي')),
                ...selectedTextCols.where((c) => c != 'status').map((c) => DataColumn(label: _buildFilterHeader(textColumnsMap[c] ?? c, c))),
                ...selectedNumCols.map((c) => DataColumn(label: Text(numericColumnsMap[c] ?? c))),
              ],
              rows: [
                ...filteredData.map((row) {
                  final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
                  return DataRow(cells: [
                    DataCell(Text(row['crop_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500))),
                    DataCell(Text(row['class'] ?? '')),
                    DataCell(Text(formatNum(row['net_weight']))),
                    ...selectedTextCols.where((c) => c != 'status').map((c) => DataCell(Text(extra[c]?.toString() ?? '-'))),
                    ...selectedNumCols.map((c) => DataCell(Text(formatNum(extra[c])))),
                  ]);
                }),
                // سطر الإجمالي النهائي
                DataRow(
                  color: WidgetStateProperty.all(Colors.amber[50]),
                  cells: [
                    const DataCell(Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataCell(Text('')),
                    DataCell(Text(formatNum(currentTotalWeight), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal))),
                    ...selectedTextCols.where((c) => c != 'status').map((_) => const DataCell(Text(''))),
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
              children: [
                ...textColumnsMap.entries.map((entry) => CheckboxListTile(
                  title: Text(entry.value),
                  value: selectedTextCols.contains(entry.key),
                  onChanged: (v) => setLocal(() => v! ? selectedTextCols.add(entry.key) : selectedTextCols.remove(entry.key)),
                )),
                const Divider(),
                ...numericColumnsMap.entries.map((entry) => CheckboxListTile(
                  title: Text(entry.value),
                  value: selectedNumCols.contains(entry.key),
                  onChanged: (v) => setLocal(() => v! ? selectedNumCols.add(entry.key) : selectedNumCols.remove(entry.key)),
                )),
              ],
            ),
          ),
          actions: [
            ElevatedButton(onPressed: () { _saveColumns(); Navigator.pop(context); loadReport(); }, child: const Text('تطبيق')),
          ],
        ),
      ),
    );
  }

  Widget _dateItem(String label, DateTime value, VoidCallback onPick) {
    return InkWell(
      onTap: onPick,
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(intl.DateFormat('yyyy-MM-dd').format(value), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
        ],
      ),
    );
  }
}