// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart' as intl;

// class CustomerPaymentsScreen extends StatefulWidget {
//   const CustomerPaymentsScreen({Key? key}) : super(key: key);

//   @override
//   State<CustomerPaymentsScreen> createState() => _CustomerPaymentsScreenState();
// }

// class _CustomerPaymentsScreenState extends State<CustomerPaymentsScreen> {
//   final SupabaseClient supabase = Supabase.instance.client;
  
//   List<Map<String, dynamic>> _payments = [];
//   List<Map<String, dynamic>> _filteredPayments = [];
//   bool _isLoading = true;

//   // متغيرات الفلترة
//   DateTime? _fromDate;
//   DateTime? _toDate;
//   String? _selectedCustomer;
//   List<String> _customerList = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }

//   // جلب البيانات من الـ View في Supabase
//   Future<void> _fetchData() async {
//     setState(() => _isLoading = true);
//     try {
//       final data = await supabase
//           .from('CustomerPayments')
//           .select()
//           .order('Pay_Date', ascending: false);

//       final List<Map<String, dynamic>> fetchedData = List<Map<String, dynamic>>.from(data);
      
//       setState(() {
//         _payments = fetchedData;
//         _filteredPayments = fetchedData;
//         // استخراج قائمة العملاء الفريدة للفلتر
//         _customerList = fetchedData
//             .map((e) => e['Name']?.toString() ?? 'غير معروف')
//             .toSet()
//             .toList();
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('خطأ في جلب البيانات: $e')),
//         );
//       }
//     }
//   }

//   // دالة الفلترة المحلية
//   void _applyFilters() {
//     setState(() {
//       _filteredPayments = _payments.where((payment) {
//         final payDateStr = payment['Pay_Date']?.toString();
//         if (payDateStr == null) return false;
        
//         final payDate = DateTime.parse(payDateStr);
//         final customerName = payment['Name']?.toString();

//         bool matchDate = true;
//         if (_fromDate != null && payDate.isBefore(_fromDate!)) matchDate = false;
//         if (_toDate != null && payDate.isAfter(_toDate!.add(const Duration(days: 1)))) matchDate = false;

//         bool matchCustomer = true;
//         if (_selectedCustomer != null && customerName != _selectedCustomer) matchCustomer = false;

//         return matchDate && matchCustomer;
//       }).toList();
//     });
//   }

//   // نسخ البيانات للحافظة بتنسيق نصي
//   void _copyToClipboard() {
//     if (_filteredPayments.isEmpty) return;

//     String buffer = "التاريخ | العميل | المبلغ | النوع | العملة\n";
//     buffer += "------------------------------------------\n";
//     for (var p in _filteredPayments) {
//       final date = p['Pay_Date']?.toString().substring(0, 10) ?? '';
//       buffer += "$date | ${p['Name']} | ${p['AMT']} | ${p['Type']} | ${p['CurrencyName']}\n";
//     }

//     Clipboard.setData(ClipboardData(text: buffer)).then((_) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('تم نسخ البيانات للحافظة')),
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('تحصيلات العملاء'),
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
//       body: Directionality(
//         textDirection: TextDirection.rtl,
//         child: Column(
//           children: [
//             _buildFilterPanel(),
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

//   Widget _buildFilterPanel() {
//     return Card(
//       // margin: const EdgeInsets(all: 12.0),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: InkWell(
//                     onTap: () async {
//                       final date = await showDatePicker(
//                         context: context,
//                         initialDate: _fromDate ?? DateTime.now(),
//                         firstDate: DateTime(2000),
//                         lastDate: DateTime(2100),
//                       );
//                       if (date != null) {
//                         setState(() => _fromDate = date);
//                         _applyFilters();
//                       }
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text('من تاريخ', style: TextStyle(fontSize: 10, color: Colors.blue)),
//                           const SizedBox(height: 4),
//                           Text(_fromDate == null ? 'اختر تاريخ' : intl.DateFormat('yyyy-MM-dd').format(_fromDate!),
//                               style: const TextStyle(fontWeight: FontWeight.bold)),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: InkWell(
//                     onTap: () async {
//                       final date = await showDatePicker(
//                         context: context,
//                         initialDate: _toDate ?? DateTime.now(),
//                         firstDate: DateTime(2000),
//                         lastDate: DateTime(2100),
//                       );
//                       if (date != null) {
//                         setState(() => _toDate = date);
//                         _applyFilters();
//                       }
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text('إلى تاريخ', style: TextStyle(fontSize: 10, color: Colors.blue)),
//                           const SizedBox(height: 4),
//                           Text(_toDate == null ? 'اختر تاريخ' : intl.DateFormat('yyyy-MM-dd').format(_toDate!),
//                               style: const TextStyle(fontWeight: FontWeight.bold)),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             DropdownButtonFormField<String>(
//               decoration: InputDecoration(
//                 labelText: 'تصفية بالعميل',
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               ),
//               value: _selectedCustomer,
//               items: [
//                 const DropdownMenuItem(value: null, child: Text('كل العملاء')),
//                 ..._customerList.map((c) => DropdownMenuItem(value: c, child: Text(c))),
//               ],
//               onChanged: (val) {
//                 setState(() => _selectedCustomer = val);
//                 _applyFilters();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDataTable() {
//     if (_filteredPayments.isEmpty) {
//       return const Center(child: Text('لا توجد بيانات مطابقة للبحث'));
//     }
//     return SingleChildScrollView(
//       scrollDirection: Axis.vertical,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: DataTable(
//           headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
//           columns: const [
//             DataColumn(label: Text('التاريخ', style: TextStyle(fontWeight: FontWeight.bold))),
//             DataColumn(label: Text('العميل', style: TextStyle(fontWeight: FontWeight.bold))),
//             DataColumn(label: Text('المبلغ (USD)', style: TextStyle(fontWeight: FontWeight.bold))),
//             DataColumn(label: Text('النوع', style: TextStyle(fontWeight: FontWeight.bold))),
//             DataColumn(label: Text('العملة', style: TextStyle(fontWeight: FontWeight.bold))),
//           ],
//           rows: _filteredPayments.map((p) {
//             return DataRow(cells: [
//               DataCell(Text(p['Pay_Date']?.toString().substring(0, 10) ?? '')),
//               DataCell(Text(p['Name'] ?? 'بدون اسم')),
//               DataCell(Text(
//                 p['AMT'] != null 
//                 ? double.parse(p['AMT'].toString()).toStringAsFixed(2) 
//                 : '0.00'
//               )),
//               DataCell(Text(p['Type']?.toString() ?? '')),
//               DataCell(Text(p['CurrencyName'] ?? '')),
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
import 'package:intl/intl.dart' as intl;

class CustomerPaymentsScreen extends StatefulWidget {
  const CustomerPaymentsScreen({super.key});

  @override
  State<CustomerPaymentsScreen> createState() => _CustomerPaymentsScreenState();
}

class _CustomerPaymentsScreenState extends State<CustomerPaymentsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> _payments = [];
  List<Map<String, dynamic>> _filteredPayments = [];
  bool _isLoading = true;

  // متغيرات الفلترة
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _selectedCustomer;
  List<String> _customerList = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // جلب البيانات من الـ View في Supabase
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await supabase
          .from('CustomerPayments')
          .select()
          .order('Pay_Date', ascending: false);

      final List<Map<String, dynamic>> fetchedData = List<Map<String, dynamic>>.from(data);
      
      setState(() {
        _payments = fetchedData;
        _filteredPayments = fetchedData;
        _customerList = fetchedData
            .map((e) => e['Name']?.toString() ?? 'غير معروف')
            .toSet()
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في جلب البيانات: $e')),
        );
      }
    }
  }

  // دالة لحفظ تحصيل جديد في جدول Payments
  Future<void> _saveNewPayment(Map<String, dynamic> paymentData) async {
    try {
      await supabase.from('Payments').insert(paymentData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ التحصيل بنجاح')),
        );
      }
      _fetchData(); // تحديث القائمة بعد الحفظ
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ أثناء الحفظ: $e')),
        );
      }
    }
  }

  // عرض نافذة إضافة تحصيل جديد
  void _showAddPaymentDialog() {
    final formKey = GlobalKey<FormState>();
    DateTime selectedDate = DateTime.now();
    final TextEditingController customerCodeController = TextEditingController();
    final TextEditingController amtController = TextEditingController();
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
            title: const Text('تسجيل تحصيل جديد'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('تاريخ الإيداع'),
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
                      controller: customerCodeController,
                      decoration: const InputDecoration(labelText: 'كود العميل'),
                      validator: (value) => value!.isEmpty ? 'مطلوب' : null,
                    ),
                    TextFormField(
                      controller: amtController,
                      decoration: const InputDecoration(labelText: 'المبلغ'),
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
                      'Pay_Date': intl.DateFormat('yyyy-MM-dd').format(selectedDate),
                      'CustomerCode': customerCodeController.text,
                      'AMT': double.tryParse(amtController.text),
                      'CurrencyId': selectedCurrencyId,
                    };
                    _saveNewPayment(newEntry);
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

  void _applyFilters() {
    setState(() {
      _filteredPayments = _payments.where((payment) {
        final payDateStr = payment['Pay_Date']?.toString();
        if (payDateStr == null) return false;
        
        final payDate = DateTime.parse(payDateStr);
        final customerName = payment['Name']?.toString();

        bool matchDate = true;
        if (_fromDate != null && payDate.isBefore(_fromDate!)) matchDate = false;
        if (_toDate != null && payDate.isAfter(_toDate!.add(const Duration(days: 1)))) matchDate = false;

        bool matchCustomer = true;
        if (_selectedCustomer != null && customerName != _selectedCustomer) matchCustomer = false;

        return matchDate && matchCustomer;
      }).toList();
    });
  }

  void _copyToClipboard() {
    if (_filteredPayments.isEmpty) return;
    String buffer = "التاريخ | العميل | المبلغ | النوع | العملة\n------------------------------------------\n";
    for (var p in _filteredPayments) {
      final date = p['Pay_Date']?.toString().substring(0, 10) ?? '';
      buffer += "$date | ${p['Name']} | ${p['AMT']} | ${p['Type']} | ${p['CurrencyName']}\n";
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
        title: const Text('تحصيلات العملاء'),
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
        onPressed: _showAddPaymentDialog,
        label: const Text('إضافة تحصيل'),
        icon: const Icon(Icons.add),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Column(
          children: [
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
                          const SizedBox(height: 4),
                          Text(_fromDate == null ? 'اختر تاريخ' : intl.DateFormat('yyyy-MM-dd').format(_fromDate!),
                              style: const TextStyle(fontWeight: FontWeight.bold)),
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
                          const SizedBox(height: 4),
                          Text(_toDate == null ? 'اختر تاريخ' : intl.DateFormat('yyyy-MM-dd').format(_toDate!),
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'تصفية بالعميل',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: _selectedCustomer,
              items: [
                const DropdownMenuItem(value: null, child: Text('كل العملاء')),
                ..._customerList.map((c) => DropdownMenuItem(value: c, child: Text(c))),
              ],
              onChanged: (val) {
                setState(() => _selectedCustomer = val);
                _applyFilters();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    if (_filteredPayments.isEmpty) {
      return const Center(child: Text('لا توجد بيانات مطابقة للبحث'));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
          columns: const [
            DataColumn(label: Text('التاريخ', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('العميل', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('المبلغ (USD)', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('النوع', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('العملة', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _filteredPayments.map((p) {
            return DataRow(cells: [
              DataCell(Text(p['Pay_Date']?.toString().substring(0, 10) ?? '')),
              DataCell(Text(p['Name'] ?? 'بدون اسم')),
              DataCell(Text(
                p['AMT'] != null 
                ? double.parse(p['AMT'].toString()).toStringAsFixed(2) 
                : '0.00'
              )),
              DataCell(Text(p['Type']?.toString() ?? '')),
              DataCell(Text(p['CurrencyName'] ?? '')),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}