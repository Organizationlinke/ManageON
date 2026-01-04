

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
//   String? selectedCrop;
//   String? selectedClass;

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

//   List reportData = []; // البيانات الخام من السيرفر
//   List filteredData = []; // البيانات بعد الفلترة المحلية
//   bool loading = false;
//   List<String> cropList = [];
//   List<String> classList = [];

//   // خريطة لتخزين الفلاتر النشطة (اسم العمود -> القيمة المختارة)
//   Map<String, String?> activeFilters = {};

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedColumns().then((_) {
//       loadCropNames();
//       loadClass();
//       loadReport();
//     });
//   }

//   // --- 1. حفظ واسترجاع الأعمدة المختارة ---
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

//   Future<void> loadClass() async {
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
//     setState(() {
//       loading = true;
//       activeFilters.clear(); // مسح الفلاتر عند تحميل بيانات جديدة
//     });
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
//         filteredData = List.from(res);
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

//   // --- 2. منطق الفلترة المحلية داخل الجدول ---
//   void _applyLocalFilters() {
//     setState(() {
//       filteredData = reportData.where((row) {
//         bool match = true;
//         activeFilters.forEach((colKey, filterValue) {
//           if (filterValue != null) {
//             String rowValue = "";
//             if (colKey == 'crop_name') rowValue = row['crop_name']?.toString() ?? "";
//             else if (colKey == 'class') rowValue = row['class']?.toString() ?? "";
//             else {
//               final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
//               rowValue = extra[colKey]?.toString() ?? "";
//             }
//             if (rowValue != filterValue) match = false;
//           }
//         });
//         return match;
//       }).toList();
//     });
//   }

//   num get totalNetWeight => filteredData.fold(0, (s, e) => s + (e['net_weight'] ?? 0));

//   num sumNumericColumn(String columnName) {
//     if (filteredData.isEmpty) return 0;
//     return filteredData.fold(0, (s, e) {
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
//         appBar: AppBar(title: const Text('تقرير التخطيط'), centerTitle: true),
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
//                 const SizedBox(width: 10),
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
//           _cardInfo('إجمالي الكمية (المصفاة)', formatNum(totalNetWeight), Colors.blue),
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

//   // --- زر الفلترة في رأس العمود ---
//   Widget _buildFilterHeader(String title, String colKey) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(title),
//         PopupMenuButton<String>(
//           icon: Icon(
//             Icons.filter_list,
//             size: 18,
//             color: activeFilters[colKey] != null ? Colors.red : Colors.grey,
//           ),
//           onSelected: (value) {
//             setState(() {
//               activeFilters[colKey] = (value == "CLEAR") ? null : value;
//               _applyLocalFilters();
//             });
//           },
//           itemBuilder: (context) {
//             // استخراج القيم الفريدة من البيانات الخام لهذا العمود
//             Set<String> uniqueValues = {};
//             for (var row in reportData) {
//               if (colKey == 'crop_name') uniqueValues.add(row['crop_name']?.toString() ?? "");
//               else if (colKey == 'class') uniqueValues.add(row['class']?.toString() ?? "");
//               else {
//                 final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
//                 uniqueValues.add(extra[colKey]?.toString() ?? "");
//               }
//             }
            
//             return [
//               const PopupMenuItem(value: "CLEAR", child: Text("إلغاء الفلتر", style: TextStyle(color: Colors.blue))),
//               ...uniqueValues.where((v) => v.isNotEmpty).map((v) => PopupMenuItem(value: v, child: Text(v))),
//             ];
//           },
//         ),
//       ],
//     );
//   }

//   Widget _tableSection() {
//     if (filteredData.isEmpty && reportData.isEmpty) return const Center(child: Text('لا توجد بيانات متاحة'));
//     if (filteredData.isEmpty) return const Center(child: Text('لا توجد نتائج تطابق الفلتر'));

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
//                 DataColumn(label: _buildFilterHeader('الصنف', 'crop_name')),
//                 DataColumn(label: _buildFilterHeader('الدرجة', 'class')),
//                 const DataColumn(label: Text('الكمية')),
//                 ...selectedTextCols.map((c) => DataColumn(label: _buildFilterHeader(textColumnsMap[c] ?? c, c))),
//                 ...selectedNumCols.map((c) => DataColumn(label: Text(numericColumnsMap[c] ?? c))),
//               ],
//               rows: [
//                 ...filteredData.map((row) {
//                   final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
//                   return DataRow(cells: [
//                     DataCell(Text(row['crop_name'] ?? '')),
//                     DataCell(Text(row['class'] ?? '')),
//                     DataCell(Text(formatNum(row['net_weight']))),
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
//                   _saveColumns(); // حفظ في التخزين المحلي
//                   Navigator.pop(context);
//                   loadReport();
//                 },
//                 child: const Text('تطبيق وحفظ')),
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

  List reportData = []; // البيانات الخام
  List filteredData = []; // البيانات بعد الفلترة
  bool loading = false;
  List<String> cropList = [];
  List<String> classList = [];

  // تعديل: خريطة لتخزين الفلاتر المتعددة (اسم العمود -> قائمة القيم المختارة)
  Map<String, List<String>> activeFilters = {};

  @override
  void initState() {
    super.initState();
    _loadSavedColumns().then((_) {
      loadCropNames();
      loadClass();
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
      // لم نعد نمسح activeFilters هنا لكي تظل الفلاتر كما هي عند التحديث
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
        _applyLocalFilters(); // تطبيق الفلاتر الموجودة مسبقاً على البيانات الجديدة
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

  void _applyLocalFilters() {
    setState(() {
      filteredData = reportData.where((row) {
        bool match = true;
        activeFilters.forEach((colKey, selectedValues) {
          if (selectedValues.isNotEmpty) {
            String rowValue = "";
            if (colKey == 'crop_name') {
              rowValue = row['crop_name']?.toString() ?? "";
            } else if (colKey == 'class') {
              rowValue = row['class']?.toString() ?? "";
            } else {
              final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
              rowValue = extra[colKey]?.toString() ?? "";
            }
            if (!selectedValues.contains(rowValue)) match = false;
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

  // --- دالة لبناء ديالوج الفلترة المتقدم ---
  void _showFilterDialog(String title, String colKey) {
    // 1. تقليص اللستة بناءً على الفلاتر الأخرى (Cross-filtering)
    // نأخذ البيانات المفلترة حالياً *بدون* تأثير فلتر هذا العمود نفسه
    List tempFiltered = reportData.where((row) {
      bool match = true;
      activeFilters.forEach((key, values) {
        if (key != colKey && values.isNotEmpty) {
          String val = "";
          if (key == 'crop_name') val = row['crop_name']?.toString() ?? "";
          else if (key == 'class') val = row['class']?.toString() ?? "";
          else {
            final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
            val = extra[key]?.toString() ?? "";
          }
          if (!values.contains(val)) match = false;
        }
      });
      return match;
    }).toList();

    Set<String> uniqueValues = {};
    for (var row in tempFiltered) {
      if (colKey == 'crop_name') uniqueValues.add(row['crop_name']?.toString() ?? "");
      else if (colKey == 'class') uniqueValues.add(row['class']?.toString() ?? "");
      else {
        final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
        uniqueValues.add(extra[colKey]?.toString() ?? "");
      }
    }
    List<String> sortedList = uniqueValues.where((v) => v.isNotEmpty).toList()..sort();
    
    List<String> tempSelected = List.from(activeFilters[colKey] ?? []);
    String searchQuery = "";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          List<String> displayList = sortedList
              .where((item) => item.toLowerCase().contains(searchQuery.toLowerCase()))
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
                    onChanged: (v) => setDialogState(() => searchQuery = v),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: displayList.length,
                      itemBuilder: (context, index) {
                        final val = displayList[index];
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
          Icon(
            Icons.filter_alt,
            size: 16,
            color: isFiltered ? Colors.blue : Colors.grey[400],
          ),
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
          title: const Text('تقرير التخطيط'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: loadReport,
              tooltip: 'تحديث البيانات مع بقاء الفلاتر',
            )
          ],
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
                    decoration: const InputDecoration(labelText: 'الصنف الأساسي', border: OutlineInputBorder()),
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
                    decoration: const InputDecoration(labelText: 'الدرجة الأساسية', border: OutlineInputBorder()),
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
                if (activeFilters.values.any((v) => v.isNotEmpty))
                  TextButton.icon(
                    onPressed: () => setState(() {
                      activeFilters.clear();
                      _applyLocalFilters();
                    }),
                    icon: const Icon(Icons.clear_all, color: Colors.red),
                    label: const Text('مسح الفلاتر', style: TextStyle(color: Colors.red)),
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

  Widget _tableSection() {
    if (filteredData.isEmpty && reportData.isEmpty) return const Center(child: Text('لا توجد بيانات متاحة'));
    
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
                if (filteredData.isEmpty)
                   const DataRow(cells: [
                    DataCell(Text('لا توجد نتائج تطابق الفلتر')),
                    DataCell(Text('')), DataCell(Text('')),
                    // سنحتاج لإضافة خلايا فارغة هنا بناء على طول الأعمدة لتجنب الأخطاء
                  ])
                else
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
                  _saveColumns();
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