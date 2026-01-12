
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart' as intl;
// import 'package:supabase_flutter/supabase_flutter.dart';

// class PackingListReportScreen extends StatefulWidget {
//   const PackingListReportScreen({super.key});

//   @override
//   State<PackingListReportScreen> createState() => _FarzaReportScreenState();
// }

// class _FarzaReportScreenState extends State<PackingListReportScreen> {
//   final supabase = Supabase.instance.client;

//   DateTime fromDate = DateTime(2025, 12, 1);
//   DateTime toDate = DateTime.now();
//   String? selectedCrop;
//   String? selectedClass;

//   // الخرائط لربط الاسم الإنجليزي (قاعدة البيانات) بالاسم العربي (العرض)
//   final Map<String, String> textColumnsMap = {
    
//     'ShippingDate': 'التاريخ',
//     'Count':'الحجم',
//     'CTNType':'نوع الكرتون',
//     'CTNWeight': 'وزن الكرتون',
//     'Brand': 'الماركه',
//     'CustomerName':'العميل',
//   };

//   final Map<String, String> numericColumnsMap = {
//     'GrossWeight': 'الوزن القائم',
//     'CTNCountInPallets': 'عدد الكرتون',
//     'Pallet_Count':'عدد البالتات',
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
//       final res = await supabase.from('Stations_PackingListsData').select('Items');
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
//       final res = await supabase.from('Stations_PackingListsData').select('Class');
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
//         'get_packinglist_report',
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
//   num get totalcontainer => reportData.fold(0, (s, e) => s + (e['container_count'] ?? 0));
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
//                 const DataColumn(label: Text('عدد الحاويات')),
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
//                     DataCell(Text(formatNum(row['container_count']))),
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
//     DataCell(Text(formatNum(totalcontainer), style: const TextStyle(fontWeight: FontWeight.bold))),
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

class PackingListReportScreen extends StatefulWidget {
  const PackingListReportScreen({super.key});

  @override
  State<PackingListReportScreen> createState() => _PackingListReportScreenState();
}

class _PackingListReportScreenState extends State<PackingListReportScreen> {
  final supabase = Supabase.instance.client;

  DateTime fromDate = DateTime(2025, 12, 1);
  DateTime toDate = DateTime.now();
  String? selectedCrop;
  String? selectedClass;

  // الخرائط لربط الاسم الإنجليزي (قاعدة البيانات) بالاسم العربي (العرض)
  final Map<String, String> textColumnsMap = {
    'ShippingDate': 'التاريخ',
    'Count': 'الحجم',
    'CTNType': 'نوع الكرتون',
    'CTNWeight': 'وزن الكرتون',
    'Brand': 'الماركه',
    'CustomerName': 'العميل',
    'Country':'الدوله'
  };

  final Map<String, String> numericColumnsMap = {
    'GrossWeight': 'الوزن القائم',
    'CTNCountInPallets': 'عدد الكرتون',
    'Pallet_Count': 'عدد البالتات',
  };

  List<String> selectedTextCols = [];
  List<String> selectedNumCols = [];

  List rawReportData = [];   // البيانات الخام من السيرفر
  List mergedData = [];      // البيانات بعد الدمج البرمجي
  List filteredData = [];    // البيانات بعد الفلترة المحلية داخل الجدول
  bool loading = false;
  List<String> cropList = [];
  List<String> classList = [];

  // مخزن الفلاتر النشطة لرؤوس الأعمدة
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

  // تحميل إعدادات الأعمدة المحفوظة
  Future<void> _loadSavedColumns() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedTextCols = prefs.getStringList('packing_selectedTextCols') ?? [];
      selectedNumCols = prefs.getStringList('packing_selectedNumCols') ?? [];
    });
  }

  // حفظ إعدادات الأعمدة
  Future<void> _saveColumns() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('packing_selectedTextCols', selectedTextCols);
    await prefs.setStringList('packing_selectedNumCols', selectedNumCols);
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
      final res = await supabase.from('Stations_PackingListsData').select('Items');
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
      final res = await supabase.from('Stations_PackingListsData').select('Class');
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
    setState(() => loading = true);
    try {
      final res = await supabase.rpc(
        'get_packinglist_report',
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

  // دمج البيانات برمجياً لضمان التجميع الصحيح
  void _processAndMergeData() {
    Map<String, Map<String, dynamic>> grouped = {};

    for (var row in rawReportData) {
      final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};

      // مفتاح الدمج: الصنف + الدرجة + الأعمدة التفصيلية المختارة
      String groupKey = "${row['crop_name']}_${row['class']}";
      for (var col in selectedTextCols) {
        groupKey += "_${extra[col] ?? ''}";
      }

      if (!grouped.containsKey(groupKey)) {
        grouped[groupKey] = {
          'crop_name': row['crop_name'],
          'class': row['class'],
          'net_weight': (row['net_weight'] ?? 0) as num,
          'container_count': (row['container_count'] ?? 0) as num,
          'extra_columns': Map<String, dynamic>.from(extra),
        };
      } else {
        grouped[groupKey]!['net_weight'] += (row['net_weight'] ?? 0) as num;
        grouped[groupKey]!['container_count'] += (row['container_count'] ?? 0) as num;

        // دمج القيم الرقمية في extra_columns
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

  // تطبيق الفلاتر المحلية (In-memory)
  void _applyLocalFilters() {
    setState(() {
      filteredData = mergedData.where((row) {
        bool match = true;
        final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};

        activeFilters.forEach((colKey, selectedValues) {
          if (selectedValues.isNotEmpty) {
            String rowValue = "";
            if (colKey == 'crop_name') rowValue = row['crop_name']?.toString() ?? "";
            else if (colKey == 'class') rowValue = row['class']?.toString() ?? "";
            else rowValue = extra[colKey]?.toString() ?? "";

            if (!selectedValues.contains(rowValue)) match = false;
          }
        });
        return match;
      }).toList();
    });
  }

  num get totalNetWeight => filteredData.fold(0, (s, e) => s + (e['net_weight'] ?? 0));
  num get totalContainer => filteredData.fold(0, (s, e) => s + (e['container_count'] ?? 0));

  num sumNumericColumn(String columnName) {
    return filteredData.fold(0, (s, e) {
      final extra = e['extra_columns'] as Map<String, dynamic>? ?? {};
      final val = extra[columnName];
      return s + (val is num ? val : (double.tryParse(val?.toString() ?? '0') ?? 0));
    });
  }

  // نافذة الفلترة الخاصة برؤوس الأعمدة
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
    String searchQuery = "";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDS) {
          List<String> filteredList = sortedList.where((i) => i.contains(searchQuery)).toList();
          return AlertDialog(
            title: Text('تصفية $title'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(hintText: 'بحث...', prefixIcon: Icon(Icons.search)),
                    onChanged: (v) => setDS(() => searchQuery = v),
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredList.length,
                      itemBuilder: (c, i) => CheckboxListTile(
                        title: Text(filteredList[i]),
                        value: tempSelected.contains(filteredList[i]),
                        onChanged: (v) => setDS(() => v! ? tempSelected.add(filteredList[i]) : tempSelected.remove(filteredList[i])),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () { setState(() { activeFilters[colKey] = []; _applyLocalFilters(); }); Navigator.pop(context); }, child: const Text('إلغاء الفلتر', style: TextStyle(color: Colors.red))),
              ElevatedButton(onPressed: () { setState(() { activeFilters[colKey] = tempSelected; _applyLocalFilters(); }); Navigator.pop(context); }, child: const Text('تطبيق')),
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Icon(Icons.filter_list_alt, size: 14, color: isFiltered ? Colors.blue : Colors.grey[400]),
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
        appBar: AppBar(title: const Text('تقرير المشحون'), centerTitle: true),
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
          child: const Icon(Icons.refresh),
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
                      const DropdownMenuItem(value: null, child: Text('كل الأصناف')),
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
                      const DropdownMenuItem(value: null, child: Text('كل الدرجات')),
                      ...classList.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                    ],
                    onChanged: (v) => setState(() => selectedClass = v),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: _showColumnsOptions,
                  icon: const Icon(Icons.settings_suggest_rounded),
                  tooltip: 'إعدادات العرض',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _dateItem('من تاريخ', fromDate, (d) => setState(() => fromDate = d)),
                _dateItem('إلى تاريخ', toDate, (d) => setState(() => toDate = d)),
                TextButton.icon(
                  onPressed: () => setState(() { activeFilters.clear(); _applyLocalFilters(); }),
                  icon: const Icon(Icons.layers_clear, size: 16),
                  label: const Text('مسح الفلاتر', style: TextStyle(fontSize: 12)),
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
          _cardInfo('صافي الوزن', formatNum(totalNetWeight), Colors.blue),
          const SizedBox(width: 8),
          _cardInfo('عدد الحاويات', formatNum(totalContainer, isMoney: false), Colors.green),
        ],
      ),
    );
  }

  Widget _cardInfo(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _tableSection() {
    if (filteredData.isEmpty && !loading) return const Center(child: Text('لا توجد بيانات لهذه الفترة'));

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
              columnSpacing: 25,
              columns: [
                DataColumn(label: _buildFilterHeader('الصنف', 'crop_name')),
                DataColumn(label: _buildFilterHeader('الدرجة', 'class')),
                const DataColumn(label: Text('الكمية', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('الحاويات', style: TextStyle(fontWeight: FontWeight.bold))),
                ...selectedTextCols.map((c) => DataColumn(label: _buildFilterHeader(textColumnsMap[c] ?? c, c))),
                ...selectedNumCols.map((c) => DataColumn(label: Text(numericColumnsMap[c] ?? c, style: const TextStyle(fontWeight: FontWeight.bold)))),
              ],
              rows: [
                ...filteredData.map((row) {
                  final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
                  return DataRow(cells: [
                    DataCell(Text(row['crop_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(row['class'] ?? '')),
                    DataCell(Text(formatNum(row['net_weight']))),
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
                    DataCell(Text(formatNum(totalNetWeight), style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(formatNum(totalContainer, isMoney: false), style: const TextStyle(fontWeight: FontWeight.bold))),
                    ...selectedTextCols.map((_) => const DataCell(Text(''))),
                    ...selectedNumCols.map((c) => DataCell(Text(formatNum(sumNumericColumn(c)), style: const TextStyle(fontWeight: FontWeight.bold)))),
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
          title: const Text('تخصيص أعمدة التقرير'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('أعمدة التصنيف (نصية):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                ...textColumnsMap.entries.map((entry) => CheckboxListTile(
                      title: Text(entry.value),
                      value: selectedTextCols.contains(entry.key),
                      onChanged: (v) => setLocal(() => v! ? selectedTextCols.add(entry.key) : selectedTextCols.remove(entry.key)),
                    )),
                const Divider(),
                const Text('أعمدة التجميع (رقمية):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
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
                _saveColumns();
                Navigator.pop(context);
                loadReport();
              },
              child: const Text('حفظ الإعدادات وتطبيق'),
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
        if (d != null) {
          onPick(d);
          loadReport();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(intl.DateFormat('yyyy-MM-dd').format(value), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    );
  }
}