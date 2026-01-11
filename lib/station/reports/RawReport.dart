
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart' as intl;
// import 'package:supabase_flutter/supabase_flutter.dart';

// class RawReportScreen extends StatefulWidget {
//   const RawReportScreen({super.key});

//   @override
//   State<RawReportScreen> createState() => _FarzaReportScreenState();
// }

// class _FarzaReportScreenState extends State<RawReportScreen> {
//   final supabase = Supabase.instance.client;

//   DateTime fromDate = DateTime(2025, 12, 1);
//   DateTime toDate = DateTime.now();
//   String? selectedCrop;

//   // الخرائط لربط الاسم الإنجليزي (قاعدة البيانات) بالاسم العربي (العرض)
//   final Map<String, String> textColumnsMap = {
    
//     'OprationDate': 'التاريخ',
//     'Serial':'علم الوزن',
//     'GroupSupplier':'المورد',
//     'VehicleNumber': 'رقم السيارة',
//     'DrvierName': 'اسم السائق',
//   };

//   final Map<String, String> numericColumnsMap = {
//     'GrossWeight': 'الوزن القائم',
//     'EmpetyWeight': 'الوزن الفارغ',
//     'TransportationCost':'تكلفة النقل',
//     'PickingCost':'تكلفة القطف',
//   };

//   List<String> selectedTextCols = [];
//   List<String> selectedNumCols = [];

//   List reportData = [];
//   bool loading = false;
//   List<String> cropList = [];

//   @override
//   void initState() {
//     super.initState();
//     loadCropNames();
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
//       final res = await supabase.from('Stations_RawTable').select('CropName');
//       final set = <String>{};
//       for (final e in res) {
//         if (e['CropName'] != null) set.add(e['CropName']);
//       }
//       setState(() => cropList = set.toList()..sort());
//     } catch (e) {
//       debugPrint('Error: $e');
//     }
//   }

//   Future<void> loadReport() async {
//     setState(() => loading = true);
//     try {
//       final res = await supabase.rpc(
//         'get_raw_report',
//         params: {
//           'p_date_from': intl.DateFormat('yyyy-MM-dd').format(fromDate),
//           'p_date_to': intl.DateFormat('yyyy-MM-dd').format(toDate),
//           'p_crop_name': selectedCrop,
//           'p_group_columns': selectedTextCols,
//           'p_sum_columns': selectedNumCols,
//         },
//       );
//       setState(() {
//         reportData = List.from(res);
//         //  ..sort((a, b) =>
//         // DateTime.parse(a['OprationDate'])
//         //     .compareTo(DateTime.parse(b['OprationDate'])));
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

//   num get totalNetWeight => reportData.fold(0, (s, e) => s + (e['NetWeight'] ?? 0));
//   num get totalValue => reportData.fold(0, (s, e) => s + (e['TotalValue'] ?? 0));

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
//         appBar: AppBar(title: const Text('تقرير الخام'), centerTitle: true),
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
//                 const DataColumn(label: Text('الكمية')),
//                 const DataColumn(label: Text('متوسط السعر')),
//                 const DataColumn(label: Text('القيمة')),
//                 // جلب الاسم العربي للأعمدة النصية المختارة
//                 ...selectedTextCols.map((c) => DataColumn(label: Text(textColumnsMap[c] ?? c))),
//                 // جلب الاسم العربي للأعمدة الرقمية المختارة
//                 ...selectedNumCols.map((c) => DataColumn(label: Text(numericColumnsMap[c] ?? c))),
//               ],
//               rows: [
//                 ...reportData.map((row) {
//                   final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
//                   return DataRow(cells: [
//                     DataCell(Text(row['CropName'] ?? '')),
//                     DataCell(Text(formatNum(row['NetWeight']))),
//                     DataCell(Text(formatNum(row['AvgPrice']))),
//                     DataCell(Text(formatNum(row['TotalValue']))),
//                     ...selectedTextCols.map((c) => DataCell(Text(extra[c]?.toString() ?? '-'))),
//                     ...selectedNumCols.map((c) => DataCell(Text(formatNum(extra[c])))),
//                   ]);
//                 }),
//                 DataRow(
//                   color: MaterialStateProperty.all(Colors.amber[50]),
//                   cells: [
//                     const DataCell(Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold))),
//                     DataCell(Text(formatNum(totalNetWeight), style: const TextStyle(fontWeight: FontWeight.bold))),
//                     DataCell(Text(formatNum(avgPrice), style: const TextStyle(fontWeight: FontWeight.bold))),
//                     DataCell(Text(formatNum(totalValue), style: const TextStyle(fontWeight: FontWeight.bold))),
//                     ...selectedTextCols.map((_) => const DataCell(Text(''))),
//                     ...selectedNumCols.map((c) => DataCell(Text(
//                           formatNum(sumNumericColumn(c)),
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ))),
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

class RawReportScreen extends StatefulWidget {
  const RawReportScreen({super.key});

  @override
  State<RawReportScreen> createState() => _RawReportScreenState();
}

class _RawReportScreenState extends State<RawReportScreen> {
  final supabase = Supabase.instance.client;

  DateTime fromDate = DateTime(2025, 12, 1);
  DateTime toDate = DateTime.now();
  String? selectedCrop;

  // الخرائط لربط الاسم الإنجليزي بالاسم العربي
  final Map<String, String> textColumnsMap = {
    'OprationDate': 'التاريخ',
    'Serial': 'علم الوزن',
    'GroupSupplier': 'المورد',
    'VehicleNumber': 'رقم السيارة',
    'DrvierName': 'اسم السائق',
  };

  final Map<String, String> numericColumnsMap = {
    'GrossWeight': 'الوزن القائم',
    'EmpetyWeight': 'الوزن الفارغ',
    'TransportationCost': 'تكلفة النقل',
    'PickingCost': 'تكلفة القطف',
  };

  List<String> selectedTextCols = [];
  List<String> selectedNumCols = [];

  List rawData = [];      // البيانات الخام من RPC
  List mergedData = [];   // البيانات بعد الدمج البرمجي
  List filteredData = []; // البيانات بعد الفلترة المحلية
  bool loading = false;
  List<String> cropList = [];

  // خريطة الفلاتر النشطة (للفلترة داخل الجدول)
  Map<String, List<String>> activeFilters = {};

  @override
  void initState() {
    super.initState();
    _loadSavedSettings().then((_) {
      loadCropNames();
      loadReport();
    });
  }

  // تحميل الإعدادات المحفوظة للأعمدة
  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedTextCols = prefs.getStringList('raw_selectedTextCols') ?? [];
      selectedNumCols = prefs.getStringList('raw_selectedNumCols') ?? [];
    });
  }

  // حفظ إعدادات الأعمدة
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('raw_selectedTextCols', selectedTextCols);
    await prefs.setStringList('raw_selectedNumCols', selectedNumCols);
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
      final res = await supabase.from('Stations_RawTable').select('CropName');
      final set = <String>{};
      for (final e in res) {
        if (e['CropName'] != null) set.add(e['CropName']);
      }
      setState(() => cropList = set.toList()..sort());
    } catch (e) {
      debugPrint('Error loading crops: $e');
    }
  }

  Future<void> loadReport() async {
    setState(() => loading = true);
    try {
      final res = await supabase.rpc(
        'get_raw_report',
        params: {
          'p_date_from': intl.DateFormat('yyyy-MM-dd').format(fromDate),
          'p_date_to': intl.DateFormat('yyyy-MM-dd').format(toDate),
          'p_crop_name': selectedCrop,
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل التقرير: $e')),
        );
      }
    }
  }

  // معالجة ودمج البيانات محلياً
  void _processAndMergeData() {
    Map<String, Map<String, dynamic>> grouped = {};

    for (var row in rawData) {
      final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};

      // إنشاء مفتاح فريد بناءً على الأعمدة النصية المختارة + الصنف
      String groupKey = "${row['CropName']}";
      for (var col in selectedTextCols) {
        groupKey += "_${extra[col] ?? ''}";
      }

      if (!grouped.containsKey(groupKey)) {
        grouped[groupKey] = {
          'CropName': row['CropName'],
          'NetWeight': (row['NetWeight'] ?? 0) as num,
          'TotalValue': (row['TotalValue'] ?? 0) as num,
          'AvgPrice': (row['AvgPrice'] ?? 0) as num,
          'extra_columns': Map<String, dynamic>.from(extra),
        };
      } else {
        // تحديث القيم التجميعية
        grouped[groupKey]!['NetWeight'] += (row['NetWeight'] ?? 0) as num;
        grouped[groupKey]!['TotalValue'] += (row['TotalValue'] ?? 0) as num;
        
        // إعادة حساب متوسط السعر للسطر المدمج
        num totalW = grouped[groupKey]!['NetWeight'];
        num totalV = grouped[groupKey]!['TotalValue'];
        grouped[groupKey]!['AvgPrice'] = totalW == 0 ? 0 : totalV / totalW;

        // دمج الأعمدة الرقمية الإضافية
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

  // تطبيق الفلاتر المحلية (Column Filters)
  void _applyLocalFilters() {
    setState(() {
      filteredData = mergedData.where((row) {
        bool match = true;
        final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};

        activeFilters.forEach((colKey, selectedValues) {
          if (selectedValues.isNotEmpty) {
            String rowValue = "";
            if (colKey == 'CropName') {
              rowValue = row['CropName']?.toString() ?? "";
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

  num get currentTotalNetWeight => filteredData.fold(0, (s, e) => s + (e['NetWeight'] ?? 0));
  num get currentTotalValue => filteredData.fold(0, (s, e) => s + (e['TotalValue'] ?? 0));

  num sumNumericColumn(String columnName) {
    if (filteredData.isEmpty) return 0;
    return filteredData.fold(0, (s, e) {
      final extra = e['extra_columns'] as Map<String, dynamic>? ?? {};
      final val = extra[columnName];
      return s + (val is num ? val : (double.tryParse(val?.toString() ?? '0') ?? 0));
    });
  }

  // نافذة اختيار قيم الفلترة لكل عمود
  void _showFilterDialog(String title, String colKey) {
    Set<String> uniqueValues = {};
    for (var row in mergedData) {
      final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
      if (colKey == 'CropName') uniqueValues.add(row['CropName']?.toString() ?? "");
      else uniqueValues.add(extra[colKey]?.toString() ?? "");
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
                    decoration: const InputDecoration(hintText: 'بحث...', prefixIcon: Icon(Icons.search)),
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
          Icon(Icons.filter_alt, size: 14, color: isFiltered ? Colors.blue : Colors.grey[500]),
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
          title: const Text('تقرير الخام'), 
          centerTitle: true,
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: loadReport)
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
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: _showColumnsOptions,
                  icon: const Icon(Icons.view_column_rounded),
                  tooltip: 'إعدادات الأعمدة',
                ),
                IconButton.outlined(
                  onPressed: () {
                    setState(() {
                      activeFilters.clear();
                      _applyLocalFilters();
                    });
                  },
                  icon: const Icon(Icons.filter_alt_off),
                  tooltip: 'مسح فلاتر الجدول',
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
          _cardInfo('إجمالي الكمية (المعروضة)', formatNum(currentTotalNetWeight), Colors.blue),
          const SizedBox(width: 8),
          _cardInfo('إجمالي القيمة (المعروضة)', formatNum(currentTotalValue), Colors.green),
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
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tableSection() {
    if (filteredData.isEmpty && !loading) return const Center(child: Text('لا توجد بيانات تطابق الاختيارات'));
    
    final avgPrice = currentTotalNetWeight == 0 ? 0 : currentTotalValue / currentTotalNetWeight;

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
              columns: [
                DataColumn(label: _buildFilterHeader('الصنف', 'CropName')),
                const DataColumn(label: Text('الكمية')),
                const DataColumn(label: Text('متوسط السعر')),
                const DataColumn(label: Text('القيمة')),
                ...selectedTextCols.map((c) => DataColumn(label: _buildFilterHeader(textColumnsMap[c] ?? c, c))),
                ...selectedNumCols.map((c) => DataColumn(label: Text(numericColumnsMap[c] ?? c))),
              ],
              rows: [
                ...filteredData.map((row) {
                  final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
                  return DataRow(cells: [
                    DataCell(Text(row['CropName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(formatNum(row['NetWeight']))),
                    DataCell(Text(formatNum(row['AvgPrice']))),
                    DataCell(Text(formatNum(row['TotalValue']))),
                    ...selectedTextCols.map((c) => DataCell(Text(extra[c]?.toString() ?? '-'))),
                    ...selectedNumCols.map((c) => DataCell(Text(formatNum(extra[c])))),
                  ]);
                }),
                // سطر الإجمالي
                DataRow(
                  color: WidgetStateProperty.all(Colors.amber[50]),
                  cells: [
                    const DataCell(Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(formatNum(currentTotalNetWeight), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                    DataCell(Text(formatNum(avgPrice), style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(formatNum(currentTotalValue), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                    ...selectedTextCols.map((_) => const DataCell(Text(''))),
                    ...selectedNumCols.map((c) => DataCell(Text(
                          formatNum(sumNumericColumn(c)),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ))),
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
            ElevatedButton(
              onPressed: () {
                _saveSettings();
                Navigator.pop(context);
                loadReport();
              }, 
              child: const Text('تطبيق وحفظ'),
            ),
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
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(intl.DateFormat('yyyy-MM-dd').format(value), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
        ],
      ),
    );
  }
}