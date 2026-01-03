
// import 'package:flutter/material.dart';
// import 'package:manageon/global.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:intl/intl.dart' as intl;

// // ملاحظة: تأكد من إضافة supabase_flutter و intl في ملف pubspec.yaml
// // تأكد من تهيئة Supabase في دالة main



// class VodafoneCashApp extends StatelessWidget {
//   const VodafoneCashApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'مدير فودافون كاش',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.red.shade900),
//         useMaterial3: true,
//         fontFamily: 'Arial', 
//       ),
//       home: const MainNavigation(),
//     );
//   }
// }

// class MainNavigation extends StatefulWidget {
//   const MainNavigation({super.key});

//   @override
//   State<MainNavigation> createState() => _MainNavigationState();
// }

// class _MainNavigationState extends State<MainNavigation> {
//   int _selectedIndex = 0;

//   final List<Widget> _screens = [
//     const NumbersScreen(),
//     user_level==13?Text('null'): TransactionsScreen(),
//     const ReportsScreen(),
//     const DetailedLogsScreen(), // الشاشة الجديدة
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Directionality(
//         textDirection: TextDirection.rtl,
//         child: _screens[_selectedIndex],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         type: BottomNavigationBarType.fixed,
//         onTap: (index) => setState(() => _selectedIndex = index),
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.phone_android), label: 'الأرقام'),
//           BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'العمليات'),
//           BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'التقارير'),
//           BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'السجل'),
//         ],
//       ),
//     );
//   }
// }

// // --- 1. شاشة تسجيل الأرقام ---
// class NumbersScreen extends StatefulWidget {
//   const NumbersScreen({super.key});

//   @override
//   State<NumbersScreen> createState() => _NumbersScreenState();
// }

// class _NumbersScreenState extends State<NumbersScreen> {
//   final _supabase = Supabase.instance.client;
//   final _numberController = TextEditingController();
//   final _dayLimitController = TextEditingController();
//   final _monthLimitController = TextEditingController();

//   Future<void> _addNumber() async {
//     if (_numberController.text.isEmpty) return;
    
//     try {
//       await _supabase.from('Vod_Number').insert({
//         'number': _numberController.text,
//         'day_limit': int.parse(_dayLimitController.text),
//         'month_limit': int.parse(_monthLimitController.text),
//       });
//       _numberController.clear();
//       _dayLimitController.clear();
//       _monthLimitController.clear();
//       setState(() {});
//       if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إضافة الرقم بنجاح')));
//     } catch (e) {
//       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('إدارة أرقام فودافون كاش'),
//       backgroundColor: color_Button,
//       foregroundColor: const Color.fromARGB(255, 255, 255, 255),),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showAddDialog(),
//         child: const Icon(Icons.add),
//       ),
//       body: FutureBuilder(
//         future: _supabase.from('Vod_Number').select(),
//         builder: (context, AsyncSnapshot snapshot) {
//           if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
//           final data = snapshot.data as List;
//           return ListView.builder(
//             itemCount: data.length,
//             itemBuilder: (context, index) {
//               final item = data[index];
//               return Card(
//                 margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                 child: ListTile(
//                   title: Text(item['number'], style: const TextStyle(fontWeight: FontWeight.bold)),
//                   subtitle: Text('حد يومي: ${item['day_limit']} | حد شهري: ${item['month_limit']}'),
//                   leading: const Icon(Icons.contact_phone, color: Colors.red),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   void _showAddDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: TextDirection.rtl,
//         child: AlertDialog(
//           title: const Text('إضافة رقم جديد'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(controller: _numberController, decoration: const InputDecoration(labelText: 'رقم الهاتف'), keyboardType: TextInputType.phone),
//               TextField(controller: _dayLimitController, decoration: const InputDecoration(labelText: 'الحد اليومي'), keyboardType: TextInputType.number),
//               TextField(controller: _monthLimitController, decoration: const InputDecoration(labelText: 'الحد الشهري'), keyboardType: TextInputType.number),
//             ],
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
//             ElevatedButton(onPressed: () { _addNumber(); Navigator.pop(context); }, child: const Text('حفظ')),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // --- 2. شاشة تسجيل العمليات (إيداع/سحب) ---
// class TransactionsScreen extends StatefulWidget {
//   const TransactionsScreen({super.key});

//   @override
//   State<TransactionsScreen> createState() => _TransactionsScreenState();
// }

// class _TransactionsScreenState extends State<TransactionsScreen> {
//   final _supabase = Supabase.instance.client;
//   int? _selectedNumberId;
//   int _transactionType = 1; // 1 = إيداع, 2 = صرف
//   final _amtController = TextEditingController();
//   final _customerController = TextEditingController();

//   Future<void> _saveTransaction() async {
//     if (_selectedNumberId == null || _amtController.text.isEmpty) return;

//     try {
//       await _supabase.from('Vod_Number_Used').insert({
//         'Vod_Number_id': _selectedNumberId,
//         'AMT': double.parse(_amtController.text),
//         'Customer': _customerController.text,
//         'type': _transactionType,
//         'date': intl.DateFormat('yyyy-MM-dd').format(DateTime.now()),
//       });
//       _amtController.clear();
//       _customerController.clear();
//       if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسجيل العملية')));
//     } catch (e) {
//       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('تسجيل العمليات اليومية'),
//        backgroundColor: color_Button,
//       foregroundColor: const Color.fromARGB(255, 255, 255, 255),),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             FutureBuilder(
//               future: _supabase.from('Vod_Number').select(),
//               builder: (context, AsyncSnapshot snapshot) {
//                 if (!snapshot.hasData) return const LinearProgressIndicator();
//                 final list = snapshot.data as List;
//                 return DropdownButtonFormField<int>(
//                   decoration: const InputDecoration(labelText: 'اختر الخط'),
//                   items: list.map((e) => DropdownMenuItem<int>(value: e['id'], child: Text(e['number']))).toList(),
//                   onChanged: (val) => setState(() => _selectedNumberId = val),
//                 );
//               },
//             ),
//             const SizedBox(height: 15),
//             SegmentedButton<int>(
//               segments: const [
//                 ButtonSegment(value: 1, label: Text('إيداع (وارد)'), icon: Icon(Icons.call_received)),
//                 ButtonSegment(value: 2, label: Text('صرف (مسحوب)'), icon: Icon(Icons.call_made)),
//               ],
//               selected: {_transactionType},
//               onSelectionChanged: (val) => setState(() => _transactionType = val.first),
//             ),
//             const SizedBox(height: 15),
//             TextField(controller: _amtController, decoration: const InputDecoration(labelText: 'المبلغ', border: OutlineInputBorder()), keyboardType: TextInputType.number),
//             const SizedBox(height: 15),
//             TextField(controller: _customerController, decoration: const InputDecoration(labelText: 'اسم العميل / ملاحظات', border: OutlineInputBorder())),
//             const SizedBox(height: 25),
//             ElevatedButton.icon(
//               onPressed: _saveTransaction,
//               icon: const Icon(Icons.save),
//               label: const Text('حفظ العملية'),
//               style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // --- 3. شاشة التقارير والأرصدة ---
// class ReportsScreen extends StatefulWidget {
//   const ReportsScreen({super.key});

//   @override
//   State<ReportsScreen> createState() => _ReportsScreenState();
// }

// class _ReportsScreenState extends State<ReportsScreen> {
//   final _supabase = Supabase.instance.client;

//   Future<List<Map<String, dynamic>>> _fetchReportData() async {
//     final now = DateTime.now();
//     final today = intl.DateFormat('yyyy-MM-dd').format(now);
//     final monthStart = intl.DateFormat('yyyy-MM-01').format(now);

//     final numbers = await _supabase.from('Vod_Number').select();
//     List<Map<String, dynamic>> report = [];

//     for (var num in numbers) {
//       final int numId = num['id'];
      
//       final transactions = await _supabase
//           .from('Vod_Number_Used')
//           .select()
//           .eq('Vod_Number_id', numId);

//       double currentBalance = 0;
//       double dailyWithdrawals = 0;
//       double monthlyWithdrawals = 0;

//       for (var tx in transactions) {
//         double amt = double.parse(tx['AMT'].toString());
//         int type = tx['type']; 
//         String txDate = tx['date'];

//         if (type == 1) currentBalance += amt;
//         if (type == 2) {
//           currentBalance -= amt;
//           if (txDate == today) dailyWithdrawals += amt;
//           if (txDate.compareTo(monthStart) >= 0) monthlyWithdrawals += amt;
//         }
//       }

//       report.add({
//         'number': num['number'],
//         'balance': currentBalance,
//         'daily_used': dailyWithdrawals,
//         'monthly_used': monthlyWithdrawals,
//         'day_limit': num['day_limit'],
//         'month_limit': num['month_limit'],
//         'remaining_day': (num['day_limit'] ?? 0) - dailyWithdrawals,
//         'remaining_month': (num['month_limit'] ?? 0) - monthlyWithdrawals,
//       });
//     }
//     return report;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('تقرير الأرصدة والحدود'),
//        backgroundColor: color_Button,
//       foregroundColor: const Color.fromARGB(255, 255, 255, 255),),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _fetchReportData(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
//           return ListView.builder(
//             itemCount: snapshot.data!.length,
//             itemBuilder: (context, index) {
//               final data = snapshot.data![index];
//               return Card(
//                 margin: const EdgeInsets.all(10),
//                 elevation: 4,
//                 child: Padding(
//                   padding: const EdgeInsets.all(15),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(data['number'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
//                           Container(
//                             padding: const EdgeInsets.all(5),
//                             color: Colors.green.shade100,
//                             child: Text('الرصيد: ${data['balance']} ج.م', style: const TextStyle(fontWeight: FontWeight.bold)),
//                           ),
//                         ],
//                       ),
//                       const Divider(),
//                       _buildInfoRow('مسحوبات اليوم:', '${data['daily_used']} / ${data['day_limit']}'),
//                       _buildProgressBar(data['daily_used'], data['day_limit']),
//                       const SizedBox(height: 10),
//                       _buildInfoRow('مسحوبات الشهر:', '${data['monthly_used']} / ${data['month_limit']}'),
//                       _buildProgressBar(data['monthly_used'], data['month_limit']),
//                       const SizedBox(height: 10),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text('المتبقي اليوم: ${data['remaining_day']}', style: TextStyle(color: data['remaining_day'] < 1000 ? Colors.red : Colors.black)),
//                           Text('المتبقي الشهر: ${data['remaining_month']}', style: const TextStyle(fontWeight: FontWeight.w500)),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label),
//           Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }

//   Widget _buildProgressBar(double used, dynamic limit) {
//     double l = (limit ?? 1).toDouble();
//     double percent = used / l;
//     if (percent > 1.0) percent = 1.0;
//     return LinearProgressIndicator(
//       value: percent,
//       backgroundColor: Colors.grey.shade200,
//       color: percent > 0.9 ? Colors.red : Colors.blue,
//       minHeight: 8,
//     );
//   }
// }

// // --- 4. شاشة سجل العمليات التفصيلي ---
// class DetailedLogsScreen extends StatefulWidget {
//   const DetailedLogsScreen({super.key});

//   @override
//   State<DetailedLogsScreen> createState() => _DetailedLogsScreenState();
// }

// class _DetailedLogsScreenState extends State<DetailedLogsScreen> {
//   final _supabase = Supabase.instance.client;

//   Future<List<Map<String, dynamic>>> _fetchDetailedLogs() async {
//     // جلب العمليات مع بيانات الرقم المرتبط بها باستخدام الـ Foreign Key
//     final response = await _supabase
//         .from('Vod_Number_Used')
//         .select('*, Vod_Number(number)')
//         .order('created_at', ascending: false);
    
//     return List<Map<String, dynamic>>.from(response);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('سجل العمليات التفصيلي'),
//          backgroundColor: color_Button,
//       foregroundColor: const Color.fromARGB(255, 255, 255, 255),
//         actions: [
//           IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState(() {})),
//         ],
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _fetchDetailedLogs(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('حدث خطأ: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('لا توجد عمليات مسجلة حتى الآن.'));
//           }

//           final logs = snapshot.data!;

//           return SingleChildScrollView(
//             scrollDirection: Axis.vertical,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: DataTable(
//                 headingRowColor: MaterialStateProperty.all(Colors.red.shade50),
//                 columns: const [
//                   DataColumn(label: Text('التاريخ')),
//                   DataColumn(label: Text('الرقم')),
//                   DataColumn(label: Text('المبلغ')),
//                   DataColumn(label: Text('النوع')),
//                   DataColumn(label: Text('العميل')),
//                 ],
//                 rows: logs.map((log) {
//                   final bool isDeposit = log['type'] == 1;
//                   final String dateStr = log['date'] ?? '';
//                   final String phone = log['Vod_Number']?['number'] ?? 'غير معروف';
//                   final String amount = '${log['AMT']} ج.م';
//                   final String customer = log['Customer'] ?? '-';

//                   return DataRow(cells: [
//                     DataCell(Text(dateStr)),
//                     DataCell(Text(phone, style: const TextStyle(fontWeight: FontWeight.bold))),
//                     DataCell(Text(amount, style: TextStyle(color: isDeposit ? Colors.green : Colors.red, fontWeight: FontWeight.bold))),
//                     DataCell(
//                       Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: BoxDecoration(
//                           color: isDeposit ? Colors.green.shade100 : Colors.red.shade100,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Text(isDeposit ? 'إيداع' : 'صرف', style: TextStyle(color: isDeposit ? Colors.green.shade900 : Colors.red.shade900)),
//                       ),
//                     ),
//                     DataCell(Text(customer)),
//                   ]);
//                 }).toList(),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // حزمة ضرورية لعملية النسخ
import 'package:manageon/global.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart' as intl;

class VodafoneCashApp extends StatelessWidget {
  const VodafoneCashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مدير فودافون كاش',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red.shade900),
        useMaterial3: true,
        fontFamily: 'Arial', 
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // دالة مساعدة لنسخ النص
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ الرقم: $text'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      NumbersScreen(onCopy: (txt) => _copyToClipboard(context, txt)),
      user_level == 13 ? const Center(child: Text('غير مسموح لك بالدخول')) : const TransactionsScreen(),
      ReportsScreen(onCopy: (txt) => _copyToClipboard(context, txt)),
      const DetailedLogsScreen(),
    ];

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.phone_android), label: 'الأرقام'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'العمليات'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'التقارير'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'السجل'),
        ],
      ),
    );
  }
}

// --- 1. شاشة تسجيل الأرقام ---
class NumbersScreen extends StatefulWidget {
  final Function(String) onCopy;
  const NumbersScreen({super.key, required this.onCopy});

  @override
  State<NumbersScreen> createState() => _NumbersScreenState();
}

class _NumbersScreenState extends State<NumbersScreen> {
  final _supabase = Supabase.instance.client;
  final _numberController = TextEditingController();
  final _dayLimitController = TextEditingController();
  final _monthLimitController = TextEditingController();

  Future<void> _addNumber() async {
    if (_numberController.text.isEmpty) return;
    try {
      await _supabase.from('Vod_Number').insert({
        'number': _numberController.text,
        'day_limit': int.parse(_dayLimitController.text),
        'month_limit': int.parse(_monthLimitController.text),
      });
      _numberController.clear();
      _dayLimitController.clear();
      _monthLimitController.clear();
      setState(() {});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إضافة الرقم بنجاح')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة أرقام فودافون كاش'),
        backgroundColor: color_Button,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: _supabase.from('Vod_Number').select(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data as List;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              final String phoneNumber = item['number'].toString();
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(phoneNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('حد يومي: ${item['day_limit']} | حد شهري: ${item['month_limit']}'),
                  leading: const Icon(Icons.contact_phone, color: Colors.red),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy, color: Colors.grey),
                    onPressed: () => widget.onCopy(phoneNumber),
                    tooltip: 'نسخ الرقم',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('إضافة رقم جديد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _numberController, decoration: const InputDecoration(labelText: 'رقم الهاتف'), keyboardType: TextInputType.phone),
              TextField(controller: _dayLimitController, decoration: const InputDecoration(labelText: 'الحد اليومي'), keyboardType: TextInputType.number),
              TextField(controller: _monthLimitController, decoration: const InputDecoration(labelText: 'الحد الشهري'), keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(onPressed: () { _addNumber(); Navigator.pop(context); }, child: const Text('حفظ')),
          ],
        ),
      ),
    );
  }
}

// --- 2. شاشة تسجيل العمليات (إيداع/سحب) ---
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _supabase = Supabase.instance.client;
  int? _selectedNumberId;
  int _transactionType = 1; 
  final _amtController = TextEditingController();
  final _customerController = TextEditingController();

  Future<void> _saveTransaction() async {
    if (_selectedNumberId == null || _amtController.text.isEmpty) return;
    try {
      await _supabase.from('Vod_Number_Used').insert({
        'Vod_Number_id': _selectedNumberId,
        'AMT': double.parse(_amtController.text),
        'Customer': _customerController.text,
        'type': _transactionType,
        'date': intl.DateFormat('yyyy-MM-dd').format(DateTime.now()),
      });
      _amtController.clear();
      _customerController.clear();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسجيل العملية')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل العمليات اليومية'),
        backgroundColor: color_Button,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder(
              future: _supabase.from('Vod_Number').select(),
              builder: (context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) return const LinearProgressIndicator();
                final list = snapshot.data as List;
                return DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'اختر الخط'),
                  items: list.map((e) => DropdownMenuItem<int>(value: e['id'], child: Text(e['number']))).toList(),
                  onChanged: (val) => setState(() => _selectedNumberId = val),
                );
              },
            ),
            const SizedBox(height: 15),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('إيداع (وارد)'), icon: Icon(Icons.call_received)),
                ButtonSegment(value: 2, label: Text('صرف (مسحوب)'), icon: Icon(Icons.call_made)),
              ],
              selected: {_transactionType},
              onSelectionChanged: (val) => setState(() => _transactionType = val.first),
            ),
            const SizedBox(height: 15),
            TextField(controller: _amtController, decoration: const InputDecoration(labelText: 'المبلغ', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 15),
            TextField(controller: _customerController, decoration: const InputDecoration(labelText: 'اسم العميل / ملاحظات', border: OutlineInputBorder())),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: _saveTransaction,
              icon: const Icon(Icons.save),
              label: const Text('حفظ العملية'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 3. شاشة التقارير والأرصدة ---
class ReportsScreen extends StatefulWidget {
  final Function(String) onCopy;
  const ReportsScreen({super.key, required this.onCopy});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> _fetchReportData() async {
    final now = DateTime.now();
    final today = intl.DateFormat('yyyy-MM-dd').format(now);
    final monthStart = intl.DateFormat('yyyy-MM-01').format(now);

    final numbers = await _supabase.from('Vod_Number').select();
    List<Map<String, dynamic>> report = [];

    for (var num in numbers) {
      final int numId = num['id'];
      final transactions = await _supabase.from('Vod_Number_Used').select().eq('Vod_Number_id', numId);

      double currentBalance = 0;
      double dailyWithdrawals = 0;
      double monthlyWithdrawals = 0;

      for (var tx in transactions) {
        double amt = double.parse(tx['AMT'].toString());
        int type = tx['type']; 
        String txDate = tx['date'];

        if (type == 1) currentBalance += amt;
        if (type == 2) {
          currentBalance -= amt;
          if (txDate == today) dailyWithdrawals += amt;
          if (txDate.compareTo(monthStart) >= 0) monthlyWithdrawals += amt;
        }
      }

      report.add({
        'number': num['number'],
        'balance': currentBalance,
        'daily_used': dailyWithdrawals,
        'monthly_used': monthlyWithdrawals,
        'day_limit': num['day_limit'],
        'month_limit': num['month_limit'],
        'remaining_day': (num['day_limit'] ?? 0) - dailyWithdrawals,
        'remaining_month': (num['month_limit'] ?? 0) - monthlyWithdrawals,
      });
    }
    return report;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير الأرصدة والحدود'),
        backgroundColor: color_Button,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchReportData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final data = snapshot.data![index];
              final String phoneNumber = data['number'].toString();
              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(phoneNumber, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 18, color: Colors.grey),
                                onPressed: () => widget.onCopy(phoneNumber),
                                tooltip: 'نسخ الرقم',
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(4)),
                            child: Text('الرصيد: ${data['balance']} ج.م', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const Divider(),
                      _buildInfoRow('مسحوبات اليوم:', '${data['daily_used']} / ${data['day_limit']}'),
                      _buildProgressBar(data['daily_used'], data['day_limit']),
                      const SizedBox(height: 10),
                      _buildInfoRow('مسحوبات الشهر:', '${data['monthly_used']} / ${data['month_limit']}'),
                      _buildProgressBar(data['monthly_used'], data['month_limit']),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('المتبقي اليوم: ${data['remaining_day']}', style: TextStyle(color: data['remaining_day'] < 1000 ? Colors.red : Colors.black)),
                          Text('المتبقي الشهر: ${data['remaining_month']}', style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double used, dynamic limit) {
    double l = (limit ?? 1).toDouble();
    double percent = used / l;
    if (percent > 1.0) percent = 1.0;
    return LinearProgressIndicator(
      value: percent,
      backgroundColor: Colors.grey.shade200,
      color: percent > 0.9 ? Colors.red : Colors.blue,
      minHeight: 8,
    );
  }
}

// --- 4. شاشة سجل العمليات التفصيلي ---
class DetailedLogsScreen extends StatefulWidget {
  const DetailedLogsScreen({super.key});

  @override
  State<DetailedLogsScreen> createState() => _DetailedLogsScreenState();
}

class _DetailedLogsScreenState extends State<DetailedLogsScreen> {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> _fetchDetailedLogs() async {
    final response = await _supabase.from('Vod_Number_Used').select('*, Vod_Number(number)').order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل العمليات التفصيلي'),
        backgroundColor: color_Button,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState(() {})),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchDetailedLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('لا توجد عمليات مسجلة.'));

          final logs = snapshot.data!;
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.red.shade50),
                columns: const [
                  DataColumn(label: Text('التاريخ')),
                  DataColumn(label: Text('الرقم')),
                  DataColumn(label: Text('المبلغ')),
                  DataColumn(label: Text('النوع')),
                  DataColumn(label: Text('العميل')),
                ],
                rows: logs.map((log) {
                  final bool isDeposit = log['type'] == 1;
                  return DataRow(cells: [
                    DataCell(Text(log['date'] ?? '')),
                    DataCell(Text(log['Vod_Number']?['number'] ?? 'غير معروف', style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text('${log['AMT']} ج.م', style: TextStyle(color: isDeposit ? Colors.green : Colors.red, fontWeight: FontWeight.bold))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: isDeposit ? Colors.green.shade100 : Colors.red.shade100, borderRadius: BorderRadius.circular(4)),
                        child: Text(isDeposit ? 'إيداع' : 'صرف', style: TextStyle(color: isDeposit ? Colors.green.shade900 : Colors.red.shade900)),
                      ),
                    ),
                    DataCell(Text(log['Customer'] ?? '-')),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}