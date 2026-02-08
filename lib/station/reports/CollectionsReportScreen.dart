
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // إضافة هذا الاستيراد للتعامل مع الحافظة
import 'package:intl/intl.dart' as intl;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollectionsReportScreen extends StatefulWidget {
  const CollectionsReportScreen({super.key});

  @override
  State<CollectionsReportScreen> createState() => _CollectionsReportScreenState();
}

class _CollectionsReportScreenState extends State<CollectionsReportScreen> {
  final supabase = Supabase.instance.client;

  DateTime fromDate = DateTime(2025, 1, 1);
  DateTime toDate = DateTime.now();
  String? selectedCustomer;

  final Map<String, String> textColumnsMap = {
    'Payment_terms': 'شروط الدفع',
    'Basd_Date': 'اساس الاستحقاق',
    'InvoiceNumber': 'رقم الفاتورة',
    'Invoice_Date': 'تاريخ الفاتورة',
    'SO_Date': 'تاريخ الاوردر',
    'Shipping_Date': 'تاريخ الشحن',
    'ETD': 'تاريخ المغادرة',
    'ETA': 'تاريخ الوصول',
    'DueDate': 'تاريخ الاستحقاق',
  };

  final Map<String, String> numericColumnsMap = {};

  List<String> selectedTextCols = [];
  List<String> selectedNumCols = [];

  List rawData = [];
  List mergedData = [];
  List filteredData = [];
  bool loading = false;
  List<String> customerList = [];

  Map<String, List<String>> activeFilters = {};

  @override
  void initState() {
    super.initState();
    _loadSavedSettings().then((_) {
      loadCustomerNames();
      loadReport();
    });
  }

  // دالة نسخ البيانات إلى الحافظة بتنسيق Excel
  void _copyToClipboard() {
    if (filteredData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد بيانات لنسخها')),
      );
      return;
    }

    StringBuffer buffer = StringBuffer();

    // 1. إضافة العناوين (Headers)
    List<String> headers = [
      'اسم العميل',
      'إجمالي المستحق',
      'المبلغ المحصل',
      'المبلغ المتبقي',
      ...selectedTextCols.map((c) => textColumnsMap[c] ?? c),
      ...selectedNumCols.map((c) => numericColumnsMap[c] ?? c),
    ];
    buffer.writeln(headers.join('\t'));

    // 2. إضافة الصفوف (Rows)
    for (var row in filteredData) {
      final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
      List<String> rowData = [
        row['CustomerName']?.toString() ?? '',
        row['TotalDueAMT']?.toString() ?? '0',
        row['TotalPaidAllocated']?.toString() ?? '0',
        row['TotalRemaining']?.toString() ?? '0',
        ...selectedTextCols.map((c) => extra[c]?.toString() ?? '-'),
        ...selectedNumCols.map((c) => extra[c]?.toString() ?? '0'),
      ];
      buffer.writeln(rowData.join('\t'));
    }

    // 3. إضافة سطر الإجمالي (Totals)
    List<String> totals = [
      'الإجمالي العام',
      currentTotalDue.toString(),
      currentTotalPaid.toString(),
      currentTotalRemaining.toString(),
      ...selectedTextCols.map((_) => ''),
      ...selectedNumCols.map((c) => sumNumericColumn(c).toString()),
    ];
    buffer.writeln(totals.join('\t'));

    // نسخ النص النهائي إلى الحافظة
    Clipboard.setData(ClipboardData(text: buffer.toString())).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم نسخ البيانات! يمكنك الآن لصقها في ملف إكسيل')),
        );
      }
    });
  }

  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedTextCols = prefs.getStringList('coll_selectedTextCols') ?? [];
      selectedNumCols = prefs.getStringList('coll_selectedNumCols') ?? [];
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('coll_selectedTextCols', selectedTextCols);
    await prefs.setStringList('coll_selectedNumCols', selectedNumCols);
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

  Future<void> loadCustomerNames() async {
    try {
      final res = await supabase.from('Customers_Collections2').select('CustomerName');
      final set = <String>{};
      for (final e in res) {
        if (e['CustomerName'] != null) set.add(e['CustomerName']);
      }
      setState(() => customerList = set.toList()..sort());
    } catch (e) {
      debugPrint('Error loading customers: $e');
    }
  }

  Future<void> loadReport() async {
    setState(() => loading = true);
    try {
      final res = await supabase.rpc(
        'get_collections_report',
        params: {
          'p_date_from': intl.DateFormat('yyyy-MM-dd').format(fromDate),
          'p_date_to': intl.DateFormat('yyyy-MM-dd').format(toDate),
          'p_customer_name': selectedCustomer,
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
          SnackBar(content: Text('خطأ في تحميل تقرير التحصيل: $e')),
        );
      }
    }
  }

  void _processAndMergeData() {
    Map<String, Map<String, dynamic>> grouped = {};
    for (var row in rawData) {
      final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
      String groupKey = "${row['CustomerName']}";
      for (var col in selectedTextCols) {
        groupKey += "_${extra[col] ?? ''}";
      }
      if (!grouped.containsKey(groupKey)) {
        grouped[groupKey] = {
          'CustomerName': row['CustomerName'],
          'TotalDueAMT': (row['TotalDueAMT'] ?? 0) as num,
          'TotalPaidAllocated': (row['TotalPaidAllocated'] ?? 0) as num,
          'TotalRemaining': (row['TotalRemaining'] ?? 0) as num,
          'extra_columns': Map<String, dynamic>.from(extra),
        };
      } else {
        grouped[groupKey]!['TotalDueAMT'] += (row['TotalDueAMT'] ?? 0) as num;
        grouped[groupKey]!['TotalPaidAllocated'] += (row['TotalPaidAllocated'] ?? 0) as num;
        grouped[groupKey]!['TotalRemaining'] += (row['TotalRemaining'] ?? 0) as num;
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
            if (colKey == 'CustomerName') {
              rowValue = row['CustomerName']?.toString() ?? "";
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

  num get currentTotalDue => filteredData.fold(0, (s, e) => s + (e['TotalDueAMT'] ?? 0));
  num get currentTotalPaid => filteredData.fold(0, (s, e) => s + (e['TotalPaidAllocated'] ?? 0));
  num get currentTotalRemaining => filteredData.fold(0, (s, e) => s + (e['TotalRemaining'] ?? 0));

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
      if (colKey == 'CustomerName') uniqueValues.add(row['CustomerName']?.toString() ?? "");
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
          title: const Text('تقرير التحصيلات'),
          centerTitle: true,
          actions: [
            // إضافة زر النسخ في الـ AppBar
            IconButton(
              icon: const Icon(Icons.copy_all),
              tooltip: 'نسخ للـ Excel',
              onPressed: _copyToClipboard,
            ),
            IconButton(icon: const Icon(Icons.refresh), onPressed: loadReport),
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
                    decoration: const InputDecoration(labelText: 'العميل', border: OutlineInputBorder()),
                    value: selectedCustomer,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('كل العملاء')),
                      ...customerList.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                    ],
                    onChanged: (v) => setState(() => selectedCustomer = v),
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
                _dateItem('تاريخ الاستحقاق من', fromDate, (d) => setState(() => fromDate = d)),
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
          _cardInfo('إجمالي المستحق', formatNum(currentTotalDue), Colors.blue),
          const SizedBox(width: 4),
          _cardInfo('إجمالي المحصل', formatNum(currentTotalPaid), Colors.green),
          const SizedBox(width: 4),
          _cardInfo('إجمالي المتبقي', formatNum(currentTotalRemaining), Colors.red),
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
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            children: [
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
              FittedBox(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tableSection() {
    if (filteredData.isEmpty && !loading) return const Center(child: Text('لا توجد بيانات تطابق الاختيارات'));
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
                DataColumn(label: _buildFilterHeader('اسم العميل', 'CustomerName')),
                const DataColumn(label: Text('إجمالي المستحق')),
                const DataColumn(label: Text('المبلغ المحصل')),
                const DataColumn(label: Text('المبلغ المتبقي')),
                ...selectedTextCols.map((c) => DataColumn(label: _buildFilterHeader(textColumnsMap[c] ?? c, c))),
                ...selectedNumCols.map((c) => DataColumn(label: Text(numericColumnsMap[c] ?? c))),
              ],
              rows: [
                ...filteredData.map((row) {
                  final extra = row['extra_columns'] as Map<String, dynamic>? ?? {};
                  return DataRow(cells: [
                    DataCell(Text(row['CustomerName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(formatNum(row['TotalDueAMT']))),
                    DataCell(Text(formatNum(row['TotalPaidAllocated']))),
                    DataCell(Text(formatNum(row['TotalRemaining']), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500))),
                    ...selectedTextCols.map((c) => DataCell(Text(extra[c]?.toString() ?? '-'))),
                    ...selectedNumCols.map((c) => DataCell(Text(formatNum(extra[c])))),
                  ]);
                }),
                DataRow(
                  color: WidgetStateProperty.all(Colors.amber[50]),
                  cells: [
                    const DataCell(Text('الإجمالي العام', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(formatNum(currentTotalDue), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                    DataCell(Text(formatNum(currentTotalPaid), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                    DataCell(Text(formatNum(currentTotalRemaining), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
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
                const Text('أعمدة النصوص التجميعية:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                ...textColumnsMap.entries.map((entry) => CheckboxListTile(
                  title: Text(entry.value),
                  value: selectedTextCols.contains(entry.key),
                  onChanged: (v) => setLocal(() => v! ? selectedTextCols.add(entry.key) : selectedTextCols.remove(entry.key)),
                )),
                const Divider(),
                const Text('أعمدة الأرقام التجميعية:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
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