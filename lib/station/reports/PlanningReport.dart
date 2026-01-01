
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart' as intl;
// import 'package:supabase_flutter/supabase_flutter.dart';

// class PlanninReportScreen extends StatefulWidget {
//   const PlanninReportScreen({super.key});

//   @override
//   State<PlanninReportScreen> createState() => _FarzaReportScreenState();
// }

// class _FarzaReportScreenState extends State<PlanninReportScreen> {
//   final supabase = Supabase.instance.client;

//   DateTime fromDate = DateTime(2025, 12, 1);
//   DateTime toDate = DateTime.now();
//   String? selectedCrop;
//   String? selectedClass;

//   // الخرائط لربط الاسم الإنجليزي (قاعدة البيانات) بالاسم العربي (العرض)
//   final Map<String, String> textColumnsMap = {
    
//     'Date': 'التاريخ',
//     'ShippingDate':'تاريخ الشحن',
//     'Country':'الدولة',
//     'Count': 'الحجم',
//     'CTNType': 'نوع الكرتون',
//     'CTNWeight': 'وزن الكرتون',
//     'Brand': 'الماركه',
//   };

//   final Map<String, String> numericColumnsMap = {
//     'PalletsCount': 'كمية الطلبية',
//     'Production_Pallet': 'كمية الانتاج',
//     'Shipping_Pallet': 'كمية المشحون',
//     'balance': 'مطلوب انتاجه',
//     // 'EmpetyWeight': 'الوزن الفارغ',
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
//       final res = await supabase.from('view8').select('Items');
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
//       final res = await supabase.from('view8').select('Class');
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
//         'get_planning_report',
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
//   // num get totalValue => reportData.fold(0, (s, e) => s + (e['total_value'] ?? 0));

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
//         appBar: AppBar(title: const Text('تقرير المشحون'), centerTitle: true),
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
//           // _cardInfo('إجمالي القيمة', formatNum(totalValue), Colors.green),
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
//     // final avgPrice = totalNetWeight == 0 ? 0 : totalValue / totalNetWeight;

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
//                 // const DataColumn(label: Text('متوسط السعر')),
//                 // const DataColumn(label: Text('القيمة')),
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
//                     // DataCell(Text(formatNum(row['avg_price']))),
//                     // DataCell(Text(formatNum(row['total_value']))),
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
//     // DataCell(Text(formatNum(avgPrice), style: const TextStyle(fontWeight: FontWeight.bold))),
//     // DataCell(Text(formatNum(totalValue), style: const TextStyle(fontWeight: FontWeight.bold))),
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

class PlanninReportScreen extends StatefulWidget {
  const PlanninReportScreen({super.key});

  @override
  State<PlanninReportScreen> createState() => _FarzaReportScreenState();
}

class _FarzaReportScreenState extends State<PlanninReportScreen> {
  final supabase = Supabase.instance.client;

  DateTime fromDate = DateTime(2025, 12, 1);
  DateTime toDate = DateTime.now();
  String? selectedCrop;
  String? selectedClass;

  final Map<String, String> textColumnsMap = {
    'Date': 'التاريخ',
    'ShippingDate': 'تاريخ الشحن',
    'Country': 'الدولة',
    'Count': 'الحجم',
    'CTNType': 'نوع الكرتون',
    'CTNWeight': 'وزن الكرتون',
    'Brand': 'الماركه',
  };

  final Map<String, String> numericColumnsMap = {
    'PalletsCount': 'كمية الطلبية',
    'Production_Pallet': 'كمية الانتاج',
    'Shipping_Pallet': 'كمية المشحون',
    'balance': 'مطلوب انتاجه',
  };

  List<String> selectedTextCols = [];
  List<String> selectedNumCols = [];

  List reportData = []; // البيانات الخام من السيرفر
  List filteredData = []; // البيانات بعد الفلترة المحلية
  bool loading = false;
  List<String> cropList = [];
  List<String> classList = [];

  // خريطة لتخزين الفلاتر النشطة (اسم العمود -> القيمة المختارة)
  Map<String, String?> activeFilters = {};

  @override
  void initState() {
    super.initState();
    _loadSavedColumns().then((_) {
      loadCropNames();
      loadClass();
      loadReport();
    });
  }

  // --- 1. حفظ واسترجاع الأعمدة المختارة ---
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

  Future<void> loadCropNames() async {
    try {
      final res = await supabase.from('view8').select('Items');
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
      final res = await supabase.from('view8').select('Class');
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
      activeFilters.clear(); // مسح الفلاتر عند تحميل بيانات جديدة
    });
    try {
      final res = await supabase.rpc(
        'get_planning_report',
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
        filteredData = List.from(res);
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

  // --- 2. منطق الفلترة المحلية داخل الجدول ---
  void _applyLocalFilters() {
    setState(() {
      filteredData = reportData.where((row) {
        bool match = true;
        activeFilters.forEach((colKey, filterValue) {
          if (filterValue != null) {
            String rowValue = "";
            if (colKey == 'crop_name') rowValue = row['crop_name']?.toString() ?? "";
            else if (colKey == 'class') rowValue = row['class']?.toString() ?? "";
            else {
              final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
              rowValue = extra[colKey]?.toString() ?? "";
            }
            if (rowValue != filterValue) match = false;
          }
        });
        return match;
      }).toList();
    });
  }

  num get totalNetWeight => filteredData.fold(0, (s, e) => s + (e['net_weight'] ?? 0));

  num sumNumericColumn(String columnName) {
    if (filteredData.isEmpty) return 0;
    return filteredData.fold(0, (s, e) {
      final extra = e['extra_columns'] as Map<String, dynamic>? ?? {};
      final val = extra[columnName];
      return s + (val is num ? val : (double.tryParse(val?.toString() ?? '0') ?? 0));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(title: const Text('تقرير التخطيط'), centerTitle: true),
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
                const SizedBox(width: 10),
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
          _cardInfo('إجمالي الكمية (المصفاة)', formatNum(totalNetWeight), Colors.blue),
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

  // --- زر الفلترة في رأس العمود ---
  Widget _buildFilterHeader(String title, String colKey) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.filter_list,
            size: 18,
            color: activeFilters[colKey] != null ? Colors.red : Colors.grey,
          ),
          onSelected: (value) {
            setState(() {
              activeFilters[colKey] = (value == "CLEAR") ? null : value;
              _applyLocalFilters();
            });
          },
          itemBuilder: (context) {
            // استخراج القيم الفريدة من البيانات الخام لهذا العمود
            Set<String> uniqueValues = {};
            for (var row in reportData) {
              if (colKey == 'crop_name') uniqueValues.add(row['crop_name']?.toString() ?? "");
              else if (colKey == 'class') uniqueValues.add(row['class']?.toString() ?? "");
              else {
                final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
                uniqueValues.add(extra[colKey]?.toString() ?? "");
              }
            }
            
            return [
              const PopupMenuItem(value: "CLEAR", child: Text("إلغاء الفلتر", style: TextStyle(color: Colors.blue))),
              ...uniqueValues.where((v) => v.isNotEmpty).map((v) => PopupMenuItem(value: v, child: Text(v))),
            ];
          },
        ),
      ],
    );
  }

  Widget _tableSection() {
    if (filteredData.isEmpty && reportData.isEmpty) return const Center(child: Text('لا توجد بيانات متاحة'));
    if (filteredData.isEmpty) return const Center(child: Text('لا توجد نتائج تطابق الفلتر'));

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
                DataColumn(label: _buildFilterHeader('الصنف', 'crop_name')),
                DataColumn(label: _buildFilterHeader('الدرجة', 'class')),
                const DataColumn(label: Text('الكمية')),
                ...selectedTextCols.map((c) => DataColumn(label: _buildFilterHeader(textColumnsMap[c] ?? c, c))),
                ...selectedNumCols.map((c) => DataColumn(label: Text(numericColumnsMap[c] ?? c))),
              ],
              rows: [
                ...filteredData.map((row) {
                  final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
                  return DataRow(cells: [
                    DataCell(Text(row['crop_name'] ?? '')),
                    DataCell(Text(row['class'] ?? '')),
                    DataCell(Text(formatNum(row['net_weight']))),
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
                  _saveColumns(); // حفظ في التخزين المحلي
                  Navigator.pop(context);
                  loadReport();
                },
                child: const Text('تطبيق وحفظ')),
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