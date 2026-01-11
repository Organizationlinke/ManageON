
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarzaReportScreen extends StatefulWidget {
  const FarzaReportScreen({super.key});

  @override
  State<FarzaReportScreen> createState() => _FarzaReportScreenState();
}

class _FarzaReportScreenState extends State<FarzaReportScreen> {
  final supabase = Supabase.instance.client;

  DateTime fromDate = DateTime(2025, 12, 1);
  DateTime toDate = DateTime.now();
  String? selectedCrop;

  // الخرائط لربط الاسم الإنجليزي (قاعدة البيانات) بالاسم العربي (العرض)
  final Map<String, String> textColumnsMap = {
    'Date': 'التاريخ',
    'Serial': 'علم الوزن',
    'Customer': 'العميل',
    'CarNumber': 'رقم السيارة',
    'DrvierName': 'اسم السائق',
  };

  final Map<String, String> numericColumnsMap = {
    'GrossWeight': 'الوزن القائم',
    'EmptyWeight': 'الوزن الفارغ',
  };

  List<String> selectedTextCols = [];
  List<String> selectedNumCols = [];

  List rawReportData = [];   // البيانات الخام من السيرفر
  List mergedData = [];      // البيانات بعد الدمج البرمجي
  List filteredData = [];    // البيانات بعد الفلترة المحلية (داخل الجدول)
  bool loading = false;
  List<String> cropList = [];

  // مخزن الفلاتر النشطة لرؤوس الأعمدة
  Map<String, List<String>> activeFilters = {};

  @override
  void initState() {
    super.initState();
    _loadSavedColumns().then((_) {
      loadCropNames();
      loadReport();
    });
  }

  // تحميل إعدادات الأعمدة المحفوظة
  Future<void> _loadSavedColumns() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedTextCols = prefs.getStringList('farza_selectedTextCols') ?? [];
      selectedNumCols = prefs.getStringList('farza_selectedNumCols') ?? [];
    });
  }

  // حفظ إعدادات الأعمدة
  Future<void> _saveColumns() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('farza_selectedTextCols', selectedTextCols);
    await prefs.setStringList('farza_selectedNumCols', selectedNumCols);
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
      final res = await supabase.from('Stations_FarzaTable').select('CropName');
      final set = <String>{};
      for (final e in res) {
        if (e['CropName'] != null) set.add(e['CropName']);
      }
      setState(() => cropList = set.toList()..sort());
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> loadReport() async {
    setState(() => loading = true);
    try {
      final res = await supabase.rpc(
        'get_farza_report',
        params: {
          'p_date_from': intl.DateFormat('yyyy-MM-dd').format(fromDate),
          'p_date_to': intl.DateFormat('yyyy-MM-dd').format(toDate),
          'p_crop_name': selectedCrop,
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

  // عملية دمج البيانات المتشابهة برمجياً
  void _processAndMergeData() {
    Map<String, Map<String, dynamic>> grouped = {};

    for (var row in rawReportData) {
      final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};

      // إنشاء مفتاح فريد يعتمد على الصنف + الأعمدة النصية المختارة
      String groupKey = "${row['CropName']}";
      for (var col in selectedTextCols) {
        groupKey += "_${extra[col] ?? ''}";
      }

      if (!grouped.containsKey(groupKey)) {
        grouped[groupKey] = {
          'CropName': row['CropName'],
          'NetWeight': (row['NetWeight'] ?? 0) as num,
          'TotalValue': (row['TotalValue'] ?? 0) as num,
          'extra_columns': Map<String, dynamic>.from(extra),
        };
      } else {
        grouped[groupKey]!['NetWeight'] += (row['NetWeight'] ?? 0) as num;
        grouped[groupKey]!['TotalValue'] += (row['TotalValue'] ?? 0) as num;

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

  // تطبيق الفلترة المحلية (In-memory Filter)
  void _applyLocalFilters() {
    setState(() {
      filteredData = mergedData.where((row) {
        bool match = true;
        final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};

        activeFilters.forEach((colKey, selectedValues) {
          if (selectedValues.isNotEmpty) {
            String rowValue = (colKey == 'CropName') 
                ? row['CropName']?.toString() ?? "" 
                : extra[colKey]?.toString() ?? "";
            
            if (!selectedValues.contains(rowValue)) match = false;
          }
        });
        return match;
      }).toList();
    });
  }

  num get totalNetWeight => filteredData.fold(0, (s, e) => s + (e['NetWeight'] ?? 0));
  num get totalValue => filteredData.fold(0, (s, e) => s + (e['TotalValue'] ?? 0));

  num sumNumericColumn(String columnName) {
    return filteredData.fold(0, (s, e) {
      final extra = e['extra_columns'] as Map<String, dynamic>? ?? {};
      final val = extra[columnName];
      return s + (val is num ? val : (double.tryParse(val?.toString() ?? '0') ?? 0));
    });
  }

  // نافذة اختيار قيم الفلترة للعمود
  void _showFilterDialog(String title, String colKey) {
    Set<String> uniqueValues = {};
    for (var row in mergedData) {
      final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
      uniqueValues.add((colKey == 'CropName') ? row['CropName']?.toString() ?? "" : extra[colKey]?.toString() ?? "");
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
            title: Text('فلترة $title'),
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
              TextButton(onPressed: () { setState(() { activeFilters[colKey] = []; _applyLocalFilters(); }); Navigator.pop(context); }, child: const Text('إعادة تعيين', style: TextStyle(color: Colors.red))),
              ElevatedButton(onPressed: () { setState(() { activeFilters[colKey] = tempSelected; _applyLocalFilters(); }); Navigator.pop(context); }, child: const Text('تطبيق')),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterHeader(String title, String colKey) {
    bool hasFilter = activeFilters[colKey]?.isNotEmpty ?? false;
    return InkWell(
      onTap: () => _showFilterDialog(title, colKey),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title),
          Icon(Icons.filter_alt, size: 14, color: hasFilter ? Colors.blue : Colors.grey[500]),
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
        appBar: AppBar(title: const Text('تقرير مبيعات الفرزة '), centerTitle: true),
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
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _dateItem('من', fromDate, (d) => setState(() => fromDate = d)),
                _dateItem('إلى', toDate, (d) => setState(() => toDate = d)),
                TextButton.icon(
                  onPressed: () => setState(() { activeFilters.clear(); _applyLocalFilters(); }),
                  icon: const Icon(Icons.filter_alt_off, size: 16),
                  label: const Text('حذف الفلاتر', style: TextStyle(fontSize: 12)),
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
          _cardInfo('إجمالي القيمة', formatNum(totalValue), Colors.green),
        ],
      ),
    );
  }

  Widget _cardInfo(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _tableSection() {
    if (filteredData.isEmpty && !loading) return const Center(child: Text('لا توجد بيانات متاحة'));
    final avgPrice = totalNetWeight == 0 ? 0 : totalValue / totalNetWeight;

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
                  num rowWeight = row['NetWeight'] ?? 0;
                  num rowValue = row['TotalValue'] ?? 0;
                  num rowAvg = rowWeight == 0 ? 0 : rowValue / rowWeight;
                  return DataRow(cells: [
                    DataCell(Text(row['CropName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(formatNum(rowWeight))),
                    DataCell(Text(formatNum(rowAvg))),
                    DataCell(Text(formatNum(rowValue))),
                    ...selectedTextCols.map((c) => DataCell(Text(extra[c]?.toString() ?? '-'))),
                    ...selectedNumCols.map((c) => DataCell(Text(formatNum(extra[c])))),
                  ]);
                }),
                DataRow(
                  color: WidgetStateProperty.all(Colors.amber[50]),
                  cells: [
                    const DataCell(Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(formatNum(totalNetWeight), style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(formatNum(avgPrice), style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(formatNum(totalValue), style: const TextStyle(fontWeight: FontWeight.bold))),
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
          title: const Text('إعدادات الأعمدة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('أعمدة البيانات النصية:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                ...textColumnsMap.entries.map((entry) => CheckboxListTile(
                      title: Text(entry.value),
                      value: selectedTextCols.contains(entry.key),
                      onChanged: (v) => setLocal(() => v! ? selectedTextCols.add(entry.key) : selectedTextCols.remove(entry.key)),
                    )),
                const Divider(),
                const Text('أعمدة المجاميع الرقمية:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
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
                child: const Text('حفظ وتطبيق')),
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
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(intl.DateFormat('yyyy-MM-dd').format(value), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    );
  }
}