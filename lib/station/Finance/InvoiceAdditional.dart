// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart' as intl;

// class InvoiceAdditionalScreen extends StatefulWidget {
//   const InvoiceAdditionalScreen({super.key});

//   @override
//   State<InvoiceAdditionalScreen> createState() => _InvoiceAdditionalScreenState();
// }

// class _InvoiceAdditionalScreenState extends State<InvoiceAdditionalScreen> {
//   final SupabaseClient supabase = Supabase.instance.client;
  
//   List<Map<String, dynamic>> _invoices = [];
//   List<Map<String, dynamic>> _filteredInvoices = [];
//   bool _isLoading = true;

//   // متغيرات البحث والفلترة
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }

//   // جلب البيانات من جدول Invoice_addtional
//   Future<void> _fetchData() async {
//     if (!mounted) return;
//     setState(() => _isLoading = true);
//     try {
//       final data = await supabase
//           .from('Invoice_addtional')
//           .select()
//           .order('created_at', ascending: false);

//       final List<Map<String, dynamic>> fetchedData = List<Map<String, dynamic>>.from(data);
      
//       if (mounted) {
//         setState(() {
//           _invoices = fetchedData;
//           _filteredInvoices = fetchedData;
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('خطأ في جلب البيانات: $e')),
//         );
//       }
//     }
//   }

//   // دالة لحفظ سجل جديد
//   Future<void> _saveNewInvoice(Map<String, dynamic> invoiceData) async {
//     try {
//       await supabase.from('Invoice_addtional').insert(invoiceData);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('تم حفظ البيانات بنجاح')),
//         );
//       }
//       _fetchData(); // تحديث القائمة
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('خطأ أثناء الحفظ: $e')),
//         );
//       }
//     }
//   }

//   // عرض نافذة إضافة سجل جديد
//   void _showAddInvoiceDialog() {
//     final formKey = GlobalKey<FormState>();
//     final TextEditingController invoiceNumController = TextEditingController();
//     final TextEditingController finalAmtController = TextEditingController();
//     final TextEditingController qualityController = TextEditingController();
//     final TextEditingController weightController = TextEditingController();
//     final TextEditingController freightController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setDialogState) => Directionality(
//           textDirection: TextDirection.rtl,
//           child: AlertDialog(
//             title: const Text('إضافة بيانات فاتورة إضافية'),
//             content: SingleChildScrollView(
//               child: Form(
//                 key: formKey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextFormField(
//                       controller: invoiceNumController,
//                       decoration: const InputDecoration(labelText: 'رقم الفاتورة'),
//                       validator: (value) => value!.isEmpty ? 'مطلوب' : null,
//                     ),
//                     TextFormField(
//                       controller: finalAmtController,
//                       decoration: const InputDecoration(labelText: 'المبلغ النهائي'),
//                       keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                       validator: (value) => value!.isEmpty ? 'مطلوب' : null,
//                     ),
//                     TextFormField(
//                       controller: qualityController,
//                       decoration: const InputDecoration(labelText: 'خصم الجودة'),
//                       keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                     ),
//                     TextFormField(
//                       controller: weightController,
//                       decoration: const InputDecoration(labelText: 'خصم الوزن'),
//                       keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                     ),
//                     TextFormField(
//                       controller: freightController,
//                       decoration: const InputDecoration(labelText: 'نولون مقدم'),
//                       keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             actions: [
//               TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
//               ElevatedButton(
//                 onPressed: () {
//                   if (formKey.currentState!.validate()) {
//                     final newEntry = {
//                       'InvoiceNumber': invoiceNumController.text,
//                       'Final_AMT': double.tryParse(finalAmtController.text) ?? 0,
//                       'QualityDeduction': double.tryParse(qualityController.text) ?? 0,
//                       'WeightDeduction': double.tryParse(weightController.text) ?? 0,
//                       'FreightAdvance': double.tryParse(freightController.text) ?? 0,
//                     };
//                     _saveNewInvoice(newEntry);
//                     Navigator.pop(context);
//                   }
//                 },
//                 child: const Text('حفظ'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // البحث برقم الفاتورة
//   void _filterInvoices(String query) {
//     setState(() {
//       _filteredInvoices = _invoices.where((invoice) {
//         final invoiceNum = invoice['InvoiceNumber']?.toString().toLowerCase() ?? '';
//         return invoiceNum.contains(query.toLowerCase());
//       }).toList();
//     });
//   }

//   void _copyToClipboard() {
//     if (_filteredInvoices.isEmpty) return;
//     String buffer = "رقم الفاتورة | المبلغ النهائي | الجودة | الوزن | النولون\n------------------------------------------------\n";
//     for (var i in _filteredInvoices) {
//       buffer += "${i['InvoiceNumber']} | ${i['Final_AMT']} | ${i['QualityDeduction']} | ${i['WeightDeduction']} | ${i['FreightAdvance']}\n";
//     }
//     Clipboard.setData(ClipboardData(text: buffer)).then((_) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ البيانات للحافظة')));
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('بيانات الفواتير الإضافية'),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.copy),
//             onPressed: _copyToClipboard,
//             tooltip: 'نسخ البيانات',
//           ),
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _fetchData,
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _showAddInvoiceDialog,
//         label: const Text('إضافة بيان'),
//         icon: const Icon(Icons.add_chart),
//       ),
//       body: Directionality(
//         textDirection: TextDirection.rtl,
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: TextField(
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   labelText: 'بحث برقم الفاتورة',
//                   prefixIcon: const Icon(Icons.search),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//                 ),
//                 onChanged: _filterInvoices,
//               ),
//             ),
//             const Divider(height: 1),
//             Expanded(
//               child: _isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : _buildDataTable(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDataTable() {
//     if (_filteredInvoices.isEmpty) {
//       return const Center(child: Text('لا توجد بيانات متاحة'));
//     }
//     return SingleChildScrollView(
//       scrollDirection: Axis.vertical,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: DataTable(
//           headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
//           columns: const [
//             DataColumn(label: Text('رقم الفاتورة', style: TextStyle(fontWeight: FontWeight.bold))),
//             DataColumn(label: Text('المبلغ النهائي', style: TextStyle(fontWeight: FontWeight.bold))),
//             DataColumn(label: Text('خصم الجودة', style: TextStyle(fontWeight: FontWeight.bold))),
//             DataColumn(label: Text('خصم الوزن', style: TextStyle(fontWeight: FontWeight.bold))),
//             DataColumn(label: Text('نولون مقدم', style: TextStyle(fontWeight: FontWeight.bold))),
//           ],
//           rows: _filteredInvoices.map((i) {
//             return DataRow(cells: [
//               DataCell(Text(i['InvoiceNumber']?.toString() ?? '')),
//               DataCell(Text(i['Final_AMT']?.toString() ?? '0')),
//               DataCell(Text(i['QualityDeduction']?.toString() ?? '0')),
//               DataCell(Text(i['WeightDeduction']?.toString() ?? '0')),
//               DataCell(Text(i['FreightAdvance']?.toString() ?? '0')),
//             ]);
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl ;

class InvoiceAdditionalScreen extends StatefulWidget {
  const InvoiceAdditionalScreen({super.key});

  @override
  State<InvoiceAdditionalScreen> createState() => _InvoiceAdditionalScreenState();
}

class _InvoiceAdditionalScreenState extends State<InvoiceAdditionalScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> _invoices = [];
  List<Map<String, dynamic>> _filteredInvoices = [];
  bool _isLoading = true;

  // متغيرات الفلترة والبحث
  final TextEditingController _searchController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // جلب البيانات من جدول Invoice_addtional
  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await supabase
          .from('Invoice_addtional')
          .select()
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> fetchedData = List<Map<String, dynamic>>.from(data);
      
      if (mounted) {
        setState(() {
          _invoices = fetchedData;
          _filteredInvoices = fetchedData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في جلب البيانات: $e')),
        );
      }
    }
  }

  // دالة لحفظ سجل جديد
  Future<void> _saveNewInvoice(Map<String, dynamic> invoiceData) async {
    try {
      await supabase.from('Invoice_addtional').insert(invoiceData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ البيانات بنجاح')),
        );
      }
      _fetchData(); 
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ أثناء الحفظ: $e')),
        );
      }
    }
  }

  // عرض نافذة إضافة سجل جديد
  void _showAddInvoiceDialog() {
    final formKey = GlobalKey<FormState>();
    final TextEditingController invoiceNumController = TextEditingController();
    final TextEditingController finalAmtController = TextEditingController();
    final TextEditingController qualityController = TextEditingController();
    final TextEditingController weightController = TextEditingController();
    final TextEditingController freightController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    int? selectedCurrencyId;

    final List<Map<String, dynamic>> currencies = [
      {'id': 405, 'name': 'دولار'},
      {'id': 404, 'name': 'يورو'},
      {'id': 406, 'name': 'جنيه'},
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('إضافة بيانات فاتورة إضافية'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('تاريخ الفاتورة'),
                      subtitle: Text(intl.DateFormat('yyyy-MM-dd').format(selectedDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setDialogState(() => selectedDate = date);
                        }
                      },
                    ),
                    TextFormField(
                      controller: invoiceNumController,
                      decoration: const InputDecoration(labelText: 'رقم الفاتورة'),
                      validator: (value) => value!.isEmpty ? 'مطلوب' : null,
                    ),
                    TextFormField(
                      controller: finalAmtController,
                      decoration: const InputDecoration(labelText: 'المبلغ النهائي'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) => value!.isEmpty ? 'مطلوب' : null,
                    ),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'العملة'),
                      items: currencies.map((c) => DropdownMenuItem<int>(
                        value: c['id'],
                        child: Text(c['name']),
                      )).toList(),
                      onChanged: (val) => selectedCurrencyId = val,
                      validator: (value) => value == null ? 'مطلوب' : null,
                    ),
                    TextFormField(
                      controller: qualityController,
                      decoration: const InputDecoration(labelText: 'خصم الجودة'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    TextFormField(
                      controller: weightController,
                      decoration: const InputDecoration(labelText: 'خصم الوزن'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    TextFormField(
                      controller: freightController,
                      decoration: const InputDecoration(labelText: 'نولون مقدم'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final newEntry = {
                      'InvoiceNumber': invoiceNumController.text,
                      'Final_AMT': double.tryParse(finalAmtController.text) ?? 0,
                      'QualityDeduction': double.tryParse(qualityController.text) ?? 0,
                      'WeightDeduction': double.tryParse(weightController.text) ?? 0,
                      'FreightAdvance': double.tryParse(freightController.text) ?? 0,
                      'RecordDate': intl.DateFormat('yyyy-MM-dd').format(selectedDate),
                      'CurrencyId': selectedCurrencyId,
                    };
                    _saveNewInvoice(newEntry);
                    Navigator.pop(context);
                  }
                },
                child: const Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة الفلترة (بحث + تاريخ)
  void _applyFilters() {
    setState(() {
      _filteredInvoices = _invoices.where((invoice) {
        // فلتر البحث النصي
        final invoiceNum = invoice['InvoiceNumber']?.toString().toLowerCase() ?? '';
        final query = _searchController.text.toLowerCase();
        bool matchesQuery = invoiceNum.contains(query);

        // فلتر التاريخ
        bool matchesDate = true;
        final rawDate = invoice['RecordDate'] ?? invoice['created_at'];
        if (rawDate != null) {
          final payDate = DateTime.parse(rawDate.toString());
          if (_fromDate != null && payDate.isBefore(_fromDate!)) matchesDate = false;
          if (_toDate != null && payDate.isAfter(_toDate!.add(const Duration(days: 1)))) matchesDate = false;
        }

        return matchesQuery && matchesDate;
      }).toList();
    });
  }

  void _copyToClipboard() {
    if (_filteredInvoices.isEmpty) return;
    String buffer = "التاريخ | رقم الفاتورة | المبلغ | الجودة | الوزن | النولون\n------------------------------------------------\n";
    for (var i in _filteredInvoices) {
      final date = i['RecordDate']?.toString() ?? i['created_at']?.toString().substring(0, 10) ?? '';
      buffer += "$date | ${i['InvoiceNumber']} | ${i['Final_AMT']} | ${i['QualityDeduction']} | ${i['WeightDeduction']} | ${i['FreightAdvance']}\n";
    }
    Clipboard.setData(ClipboardData(text: buffer)).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ البيانات للحافظة')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بيانات الفواتير الإضافية'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyToClipboard,
            tooltip: 'نسخ البيانات',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddInvoiceDialog,
        label: const Text('إضافة بيان'),
        icon: const Icon(Icons.add_chart),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            _buildFilterPanel(),
            const Divider(height: 1),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildDataTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Card(
      margin: const EdgeInsets.all(12.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'بحث برقم الفاتورة',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (_) => _applyFilters(),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _fromDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() => _fromDate = date);
                        _applyFilters();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('من تاريخ', style: TextStyle(fontSize: 10, color: Colors.blue)),
                          Text(_fromDate == null ? 'اختر' : intl.DateFormat('yyyy-MM-dd').format(_fromDate!)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _toDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() => _toDate = date);
                        _applyFilters();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('إلى تاريخ', style: TextStyle(fontSize: 10, color: Colors.blue)),
                          Text(_toDate == null ? 'اختر' : intl.DateFormat('yyyy-MM-dd').format(_toDate!)),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear_all),
                  onPressed: () {
                    setState(() {
                      _fromDate = null;
                      _toDate = null;
                      _searchController.clear();
                    });
                    _applyFilters();
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    if (_filteredInvoices.isEmpty) {
      return const Center(child: Text('لا توجد بيانات متاحة'));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
          columns: const [
            DataColumn(label: Text('التاريخ')),
            DataColumn(label: Text('رقم الفاتورة')),
            DataColumn(label: Text('المبلغ النهائي')),
            DataColumn(label: Text('العملة')),
            DataColumn(label: Text('خصم الجودة')),
            DataColumn(label: Text('خصم الوزن')),
            DataColumn(label: Text('نولون مقدم')),
          ],
          rows: _filteredInvoices.map((i) {
            String currencyName = '';
            switch (i['CurrencyId']) {
              case 405: currencyName = 'دولار'; break;
              case 404: currencyName = 'يورو'; break;
              case 406: currencyName = 'جنيه'; break;
              default: currencyName = '-';
            }
            
            return DataRow(cells: [
              DataCell(Text(i['RecordDate']?.toString() ?? i['created_at']?.toString().substring(0, 10) ?? '')),
              DataCell(Text(i['InvoiceNumber']?.toString() ?? '')),
              DataCell(Text(i['Final_AMT']?.toString() ?? '0')),
              DataCell(Text(currencyName)),
              DataCell(Text(i['QualityDeduction']?.toString() ?? '0')),
              DataCell(Text(i['WeightDeduction']?.toString() ?? '0')),
              DataCell(Text(i['FreightAdvance']?.toString() ?? '0')),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}