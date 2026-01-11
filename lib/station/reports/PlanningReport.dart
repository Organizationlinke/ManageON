
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:manageon/global.dart';
import 'package:manageon/station/Operation/OperationReportsScreen.dart';
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
          title: const Text('تقرير التخطيط '),
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
                const Text('الحالة: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
                  icon: const Icon(Icons.filter_alt_off, size: 16,color: color_cancel,),
                  label: const Text('مسح', style: TextStyle(fontSize: 12)),
                ),
                 TextButton.icon(
                  onPressed: () {
                    setState(() {
                Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                     const ReportsScreen()
                                 
                          ));
                    });
                  },
                  icon: const Icon(Icons.auto_mode, size: 16,color: color_finish,),
                  label: const Text('التشغيل', style: TextStyle(fontSize: 12)),
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