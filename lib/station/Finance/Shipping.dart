// // // import 'package:flutter/material.dart';
// // // import 'package:supabase_flutter/supabase_flutter.dart';
// // // import 'package:intl/intl.dart';

// // // class ShippingManagementScreen extends StatefulWidget {
// // //   const ShippingManagementScreen({super.key});

// // //   @override
// // //   State<ShippingManagementScreen> createState() =>
// // //       _ShippingManagementScreenState();
// // // }

// // // class _ShippingManagementScreenState extends State<ShippingManagementScreen> {
// // //   final SupabaseClient supabase = Supabase.instance.client;
// // //   bool _isLoading = false;
// // //   List<dynamic> _allInvoices = [];

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _fetchData();
// // //   }

// // //   // جلب البيانات من الـ View
// // //   Future<void> _fetchData() async {
// // //     setState(() => _isLoading = true);
// // //     try {
// // //       // جلب البيانات من View: station_groupinvoices
// // //       final data = await supabase.from('station_groupinvoices').select();

// // //       setState(() {
// // //         _allInvoices = data;
// // //         _isLoading = false;
// // //       });
// // //     } catch (e) {
// // //       setState(() => _isLoading = false);
// // //       _showSnackBar("خطأ في جلب البيانات: $e", Colors.red);
// // //     }
// // //   }

// // //   // وظيفة حفظ أو تحديث التواريخ في جدول PL_Dates
// // //   Future<void> _upsertDates(int? plSerial, DateTime? etd, DateTime? eta) async {
// // //     if (plSerial == null) return;

// // //     try {
// // //       // استخدام upsert بناءً على PL_Serial
// // //       // ملاحظة: يجب التأكد من وجود Unique constraint على PL_Serial في قاعدة البيانات ليعمل الـ upsert بشكل صحيح
// // //       await supabase.from('PL_Dates').upsert({
// // //         'PL_Serial': plSerial,
// // //         'ETD': etd?.toIso8601String(),
// // //         'ETA': eta?.toIso8601String(),
// // //       }, onConflict: 'PL_Serial');

// // //       _showSnackBar("تم الحفظ بنجاح", Colors.green);
// // //       _fetchData(); // تحديث القائمة بعد الحفظ
// // //     } catch (e) {
// // //       _showSnackBar("خطأ أثناء الحفظ: $e", Colors.red);
// // //     }
// // //   }

// // //   void _showSnackBar(String message, Color color) {
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(content: Text(message), backgroundColor: color),
// // //     );
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     // تصفية البيانات للتابة الأولى (أحد التاريخين فارغ)
// // //     final incompleteInvoices = _allInvoices
// // //         .where((item) => item['ETD'] == null || item['ETA'] == null)
// // //         .toList();

// // //     // تصفية البيانات للتابة الثانية (التاريخين مكتملين)
// // //     final completeInvoices = _allInvoices
// // //         .where((item) => item['ETD'] != null && item['ETA'] != null)
// // //         .toList();

// // //     return DefaultTabController(
// // //       length: 2,
// // //       child: Scaffold(
// // //         appBar: AppBar(
// // //           // foregroundColor: Colors.white,
// // //           // backgroundColor: Colors.blue, // أو أي لون تحبه
// // //           title: const TabBar(
// // //             labelColor: Colors.white, // لون النص المختار
// // //             unselectedLabelColor: Colors.white70, // لون النص غير المختار
// // //             indicatorColor: Colors.white, // لون الخط تحت التاب
// // //             tabs: [
// // //               Tab(
// // //                 text: "مواعيد مطلوبة",
// // //                 icon: Icon(Icons.pending_actions),
// // //               ),
// // //               Tab(
// // //                 text: "مواعيد مكتملة",
// // //                 icon: Icon(Icons.check_circle_outline),
// // //               ),
// // //             ],
// // //           ),
// // //           actions: [
// // //             IconButton(
// // //               icon: const Icon(Icons.refresh, color: Colors.white),
// // //               onPressed: _fetchData,
// // //             )
// // //           ],
// // //         ),
// // //         body: _isLoading
// // //             ? const Center(child: CircularProgressIndicator())
// // //             : TabBarView(
// // //                 children: [
// // //                   _buildInvoicesTable(incompleteInvoices, isUpdate: false),
// // //                   _buildInvoicesTable(completeInvoices, isUpdate: true),
// // //                 ],
// // //               ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildInvoicesTable(List<dynamic> data, {required bool isUpdate}) {
// // //     if (data.isEmpty) {
// // //       return const Center(child: Text("لا توجد بيانات متاحة"));
// // //     }

// // //     return SingleChildScrollView(
// // //       scrollDirection: Axis.vertical,
// // //       child: SingleChildScrollView(
// // //         scrollDirection: Axis.horizontal,
// // //         child: DataTable(
// // //           columns: const [
// // //             DataColumn(label: Text('Country')),
// // //             DataColumn(label: Text('SO_Serial')),
// // //             DataColumn(label: Text('PL_serial')),
// // //             DataColumn(label: Text('ETD')),
// // //             DataColumn(label: Text('ETA')),
// // //             DataColumn(label: Text('الإجراء')),
// // //           ],
// // //           rows: data.map((item) {
// // //             return DataRow(cells: [
// // //               DataCell(Text(item['Country']?.toString() ?? '-')),
// // //               DataCell(Text(item['SO_Serial']?.toString() ?? '-')),
// // //               DataCell(Text(item['PL_serial']?.toString() ?? '-')),
// // //               DataCell(Text(item['ETD'] ?? 'غير محدد')),
// // //               DataCell(Text(item['ETA'] ?? 'غير محدد')),
// // //               DataCell(
// // //                 ElevatedButton.icon(
// // //                   onPressed: () => _showEditDialog(item),
// // //                   icon: Icon(isUpdate ? Icons.edit : Icons.add),
// // //                   label: Text(isUpdate ? "تعديل" : "إضافة"),
// // //                 ),
// // //               ),
// // //             ]);
// // //           }).toList(),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // دايالوج لاختيار التواريخ والحفظ
// // //   void _showEditDialog(dynamic item) {
// // //     DateTime? selectedETD =
// // //         item['ETD'] != null ? DateTime.parse(item['ETD']) : null;
// // //     DateTime? selectedETA =
// // //         item['ETA'] != null ? DateTime.parse(item['ETA']) : null;

// // //     showDialog(
// // //       context: context,
// // //       builder: (context) {
// // //         return StatefulBuilder(
// // //           builder: (context, setDialogState) {
// // //             return AlertDialog(
// // //               title: Text("تحديث مواعيد PL: ${item['PL_serial']}"),
// // //               content: Column(
// // //                 mainAxisSize: MainAxisSize.min,
// // //                 children: [
// // //                   ListTile(
// // //                     title: const Text("تاريخ ETD"),
// // //                     subtitle: Text(selectedETD == null
// // //                         ? "اختر التاريخ"
// // //                         : DateFormat('yyyy-MM-dd').format(selectedETD!)),
// // //                     trailing: const Icon(Icons.calendar_today),
// // //                     onTap: () async {
// // //                       DateTime? picked = await showDatePicker(
// // //                         context: context,
// // //                         initialDate: selectedETD ?? DateTime.now(),
// // //                         firstDate: DateTime(2020),
// // //                         lastDate: DateTime(2030),
// // //                       );
// // //                       if (picked != null) {
// // //                         setDialogState(() => selectedETD = picked);
// // //                       }
// // //                     },
// // //                   ),
// // //                   ListTile(
// // //                     title: const Text("تاريخ ETA"),
// // //                     subtitle: Text(selectedETA == null
// // //                         ? "اختر التاريخ"
// // //                         : DateFormat('yyyy-MM-dd').format(selectedETA!)),
// // //                     trailing: const Icon(Icons.calendar_today),
// // //                     onTap: () async {
// // //                       DateTime? picked = await showDatePicker(
// // //                         context: context,
// // //                         initialDate: selectedETA ?? DateTime.now(),
// // //                         firstDate: DateTime(2020),
// // //                         lastDate: DateTime(2030),
// // //                       );
// // //                       if (picked != null) {
// // //                         setDialogState(() => selectedETA = picked);
// // //                       }
// // //                     },
// // //                   ),
// // //                 ],
// // //               ),
// // //               actions: [
// // //                 TextButton(
// // //                     onPressed: () => Navigator.pop(context),
// // //                     child: const Text("إلغاء")),
// // //                 ElevatedButton(
// // //                   onPressed: () {
// // //                     Navigator.pop(context);
// // //                     _upsertDates(
// // //                       int.tryParse(item['PL_serial'].toString()),
// // //                       selectedETD,
// // //                       selectedETA,
// // //                     );
// // //                   },
// // //                   child: const Text("حفظ"),
// // //                 ),
// // //               ],
// // //             );
// // //           },
// // //         );
// // //       },
// // //     );
// // //   }
// // // }

// // import 'package:flutter/material.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import 'package:intl/intl.dart';

// // class ShippingManagementScreen extends StatefulWidget {
// //   const ShippingManagementScreen({super.key});

// //   @override
// //   State<ShippingManagementScreen> createState() => _ShippingManagementScreenState();
// // }

// // class _ShippingManagementScreenState extends State<ShippingManagementScreen> {
// //   final SupabaseClient supabase = Supabase.instance.client;
// //   bool _isLoading = false;
// //   List<dynamic> _allInvoices = [];

// //   // فلاتر البحث لكل عمود
// //   final Map<String, List<String>> _selectedFilters = {
// //     'Country': [],
// //     'SO_Serial': [],
// //     'PL_serial': [],
// //     'ETD': [],
// //     'ETA': [],
// //   };

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchData();
// //   }

// //   // جلب البيانات من الـ View
// //   Future<void> _fetchData() async {
// //     setState(() => _isLoading = true);
// //     try {
// //       final data = await supabase.from('station_groupinvoices').select();
// //       setState(() {
// //         _allInvoices = data;
// //         _isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() => _isLoading = false);
// //       _showSnackBar("خطأ في جلب البيانات: $e", Colors.red);
// //     }
// //   }

// //   // وظيفة الحفظ
// //   Future<void> _upsertDates(int? plSerial, DateTime? etd, DateTime? eta) async {
// //     if (plSerial == null) return;
// //     try {
// //       await supabase.from('PL_Dates').upsert({
// //         'PL_Serial': plSerial,
// //         'ETD': etd?.toIso8601String(),
// //         'ETA': eta?.toIso8601String(),
// //       }, onConflict: 'PL_Serial');

// //       _showSnackBar("تم الحفظ بنجاح", Colors.green);
// //       _fetchData();
// //     } catch (e) {
// //         print(e);
// //       _showSnackBar("خطأ أثناء الحفظ: $e", Colors.red);
// //     }
// //   }

// //   void _showSnackBar(String message, Color color) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text(message), backgroundColor: color),
// //     );
// //   }

// //   // تصفية القائمة بناءً على الفلاتر المختارة
// //   List<dynamic> _applyFilters(List<dynamic> sourceData) {
// //     return sourceData.where((item) {
// //       bool matches = true;
// //       _selectedFilters.forEach((column, selectedValues) {
// //         if (selectedValues.isNotEmpty) {
// //           String itemValue = item[column]?.toString() ?? 'غير محدد';
// //           if (!selectedValues.contains(itemValue)) {
// //             matches = false;
// //           }
// //         }
// //       });
// //       return matches;
// //     }).toList();
// //   }

// //   // إظهار نافذة الاختيار المتعدد
// //   void _showMultiSelectFilter(String column) {
// //     // الحصول على كل القيم الفريدة لهذا العمود من البيانات الأصلية
// //     List<String> uniqueValues = _allInvoices
// //         .map((item) => item[column]?.toString() ?? 'غير محدد')
// //         .toSet()
// //         .toList();
// //     uniqueValues.sort();

// //     showDialog(
// //       context: context,
// //       builder: (context) {
// //         return StatefulBuilder(
// //           builder: (context, setDialogState) {
// //             return AlertDialog(
// //               title: Text("تصفية: $column"),
// //               content: SizedBox(
// //                 width: double.maxFinite,
// //                 child: ListView.builder(
// //                   shrinkWrap: true,
// //                   itemCount: uniqueValues.length,
// //                   itemBuilder: (context, index) {
// //                     final value = uniqueValues[index];
// //                     final isSelected = _selectedFilters[column]!.contains(value);
// //                     return CheckboxListTile(
// //                       title: Text(value),
// //                       value: isSelected,
// //                       onChanged: (bool? checked) {
// //                         setDialogState(() {
// //                           if (checked == true) {
// //                             _selectedFilters[column]!.add(value);
// //                           } else {
// //                             _selectedFilters[column]!.remove(value);
// //                           }
// //                         });
// //                         setState(() {}); // لتحديث الجدول فوراً
// //                       },
// //                     );
// //                   },
// //                 ),
// //               ),
// //               actions: [
// //                 TextButton(
// //                   onPressed: () {
// //                     setState(() {
// //                       _selectedFilters[column]!.clear();
// //                     });
// //                     Navigator.pop(context);
// //                   },
// //                   child: const Text("مسح الفلتر"),
// //                 ),
// //                 ElevatedButton(
// //                   onPressed: () => Navigator.pop(context),
// //                   child: const Text("تم"),
// //                 ),
// //               ],
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final incompleteInvoices = _allInvoices
// //         .where((item) => item['ETD'] == null || item['ETA'] == null)
// //         .toList();

// //     final completeInvoices = _allInvoices
// //         .where((item) => item['ETD'] != null && item['ETA'] != null)
// //         .toList();

// //     return DefaultTabController(
// //       length: 2,
// //       child: Scaffold(
// //         appBar: AppBar(
// //           backgroundColor: Theme.of(context).primaryColor,
// //           title: const TabBar(
// //             labelColor: Colors.white,
// //             unselectedLabelColor: Colors.white70,
// //             indicatorColor: Colors.white,
// //             tabs: [
// //               Tab(text: "مواعيد مطلوبة", icon: Icon(Icons.pending_actions)),
// //               Tab(text: "مواعيد مكتملة", icon: Icon(Icons.check_circle_outline)),
// //             ],
// //           ),
// //           actions: [
// //             IconButton(
// //               icon: const Icon(Icons.refresh, color: Colors.white),
// //               onPressed: _fetchData,
// //             )
// //           ],
// //         ),
// //         body: _isLoading
// //             ? const Center(child: CircularProgressIndicator())
// //             : TabBarView(
// //                 children: [
// //                   _buildInvoicesTable(_applyFilters(incompleteInvoices), isUpdate: false),
// //                   _buildInvoicesTable(_applyFilters(completeInvoices), isUpdate: true),
// //                 ],
// //               ),
// //       ),
// //     );
// //   }

// //   Widget _buildInvoicesTable(List<dynamic> data, {required bool isUpdate}) {
// //     return Column(
// //       children: [
// //         // شريط الفلاتر النشطة (اختياري لتسهيل المسح)
// //         if (_selectedFilters.values.any((v) => v.isNotEmpty))
// //           Padding(
// //             padding: const EdgeInsets.all(8.0),
// //             child: Wrap(
// //               spacing: 8,
// //               children: [
// //                 ActionChip(
// //                   label: const Text("مسح الكل"),
// //                   onPressed: () {
// //                     setState(() {
// //                       _selectedFilters.forEach((key, value) => value.clear());
// //                     });
// //                   },
// //                   backgroundColor: Colors.red.shade100,
// //                 ),
// //                 ..._selectedFilters.entries
// //                     .where((e) => e.value.isNotEmpty)
// //                     .map((e) => Chip(
// //                           label: Text("${e.key}: ${e.value.length}"),
// //                           onDeleted: () {
// //                             setState(() {
// //                               _selectedFilters[e.key]!.clear();
// //                             });
// //                           },
// //                         )),
// //               ],
// //             ),
// //           ),
// //         Expanded(
// //           child: data.isEmpty
// //               ? const Center(child: Text("لا توجد بيانات مطابقة للبحث"))
// //               : SingleChildScrollView(
// //                   scrollDirection: Axis.vertical,
// //                   child: SingleChildScrollView(
// //                     scrollDirection: Axis.horizontal,
// //                     child: DataTable(
// //                       columns: [
// //                         _buildSortableHeader('Country'),
// //                         _buildSortableHeader('SO_Serial'),
// //                         _buildSortableHeader('PL_serial'),
// //                         _buildSortableHeader('ETD'),
// //                         _buildSortableHeader('ETA'),
// //                         const DataColumn(label: Text('الإجراء')),
// //                       ],
// //                       rows: data.map((item) {
// //                         return DataRow(cells: [
// //                           DataCell(Text(item['Country']?.toString() ?? '-')),
// //                           DataCell(Text(item['SO_Serial']?.toString() ?? '-')),
// //                           DataCell(Text(item['PL_serial']?.toString() ?? '-')),
// //                           DataCell(Text(item['ETD'] ?? 'غير محدد')),
// //                           DataCell(Text(item['ETA'] ?? 'غير محدد')),
// //                           DataCell(
// //                             ElevatedButton.icon(
// //                               onPressed: () => _showEditDialog(item),
// //                               icon: Icon(isUpdate ? Icons.edit : Icons.add),
// //                               label: Text(isUpdate ? "تعديل" : "إضافة"),
// //                             ),
// //                           ),
// //                         ]);
// //                       }).toList(),
// //                     ),
// //                   ),
// //                 ),
// //         ),
// //       ],
// //     );
// //   }

// //   DataColumn _buildSortableHeader(String label) {
// //     final bool hasFilter = _selectedFilters[label]!.isNotEmpty;
// //     return DataColumn(
// //       label: InkWell(
// //         onTap: () => _showMultiSelectFilter(label),
// //         child: Row(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Text(label, style: TextStyle(color: hasFilter ? Colors.blue : Colors.black, fontWeight: hasFilter ? FontWeight.bold : FontWeight.normal)),
// //             Icon(Icons.filter_list, size: 16, color: hasFilter ? Colors.blue : Colors.grey),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // دايالوج التعديل
// //   void _showEditDialog(dynamic item) {
// //     DateTime? selectedETD = item['ETD'] != null ? DateTime.parse(item['ETD']) : null;
// //     DateTime? selectedETA = item['ETA'] != null ? DateTime.parse(item['ETA']) : null;

// //     showDialog(
// //       context: context,
// //       builder: (context) {
// //         return StatefulBuilder(
// //           builder: (context, setDialogState) {
// //             return AlertDialog(
// //               title: Text("تحديث مواعيد PL: ${item['PL_serial']}"),
// //               content: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   ListTile(
// //                     title: const Text("تاريخ ETD"),
// //                     subtitle: Text(selectedETD == null ? "اختر التاريخ" : DateFormat('yyyy-MM-dd').format(selectedETD!)),
// //                     trailing: const Icon(Icons.calendar_today),
// //                     onTap: () async {
// //                       DateTime? picked = await showDatePicker(
// //                         context: context,
// //                         initialDate: selectedETD ?? DateTime.now(),
// //                         firstDate: DateTime(2020),
// //                         lastDate: DateTime(2030),
// //                       );
// //                       if (picked != null) setDialogState(() => selectedETD = picked);
// //                     },
// //                   ),
// //                   ListTile(
// //                     title: const Text("تاريخ ETA"),
// //                     subtitle: Text(selectedETA == null ? "اختر التاريخ" : DateFormat('yyyy-MM-dd').format(selectedETA!)),
// //                     trailing: const Icon(Icons.calendar_today),
// //                     onTap: () async {
// //                       DateTime? picked = await showDatePicker(
// //                         context: context,
// //                         initialDate: selectedETA ?? DateTime.now(),
// //                         firstDate: DateTime(2020),
// //                         lastDate: DateTime(2030),
// //                       );
// //                       if (picked != null) setDialogState(() => selectedETA = picked);
// //                     },
// //                   ),
// //                 ],
// //               ),
// //               actions: [
// //                 TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
// //                 ElevatedButton(
// //                   onPressed: () {
// //                     Navigator.pop(context);
// //                     _upsertDates(int.tryParse(item['PL_serial'].toString()), selectedETD, selectedETA);
// //                   },
// //                   child: const Text("حفظ"),
// //                 ),
// //               ],
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:intl/intl.dart';

// class ShippingManagementScreen extends StatefulWidget {
//   const ShippingManagementScreen({super.key});

//   @override
//   State<ShippingManagementScreen> createState() => _ShippingManagementScreenState();
// }

// class _ShippingManagementScreenState extends State<ShippingManagementScreen> {
//   final SupabaseClient supabase = Supabase.instance.client;
//   bool _isLoading = false;
//   List<dynamic> _allInvoices = [];

//   // فلاتر البحث لكل عمود
//   final Map<String, List<String>> _selectedFilters = {
//     'Country': [],
//     'SO_Serial': [],
//     'PL_serial': [],
//     'ETD': [],
//     'ETA': [],
//   };

//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }

//   // جلب البيانات من الـ View
//   Future<void> _fetchData() async {
//     setState(() => _isLoading = true);
//     try {
//       final data = await supabase.from('station_groupinvoices').select();
//       setState(() {
//         _allInvoices = data;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showSnackBar("خطأ في جلب البيانات: $e", Colors.red);
//     }
//   }

//   // وظيفة الحفظ المعدلة لحل مشكلة الـ Unique Constraint
//   Future<void> _upsertDates(int? plSerial, DateTime? etd, DateTime? eta) async {
//     if (plSerial == null) return;
    
//     setState(() => _isLoading = true);
//     try {
//       // 1. التحقق أولاً من وجود السجل في جدول PL_Dates
//       final existingData = await supabase
//           .from('PL_Dates')
//           .select('id')
//           .eq('PL_Serial', plSerial)
//           .maybeSingle();

//       final payload = {
//         'PL_Serial': plSerial,
//         'ETD': etd?.toIso8601String(),
//         'ETA': eta?.toIso8601String(),
//       };

//       if (existingData != null) {
//         // 2. إذا كان موجوداً، نقوم بالتحديث باستخدام المعرف (ID)
//         await supabase
//             .from('PL_Dates')
//             .update(payload)
//             .eq('PL_Serial', plSerial);
//       } else {
//         // 3. إذا لم يكن موجوداً، نقوم بإضافة سجل جديد
//         await supabase
//             .from('PL_Dates')
//             .insert(payload);
//       }

//       _showSnackBar("تم الحفظ بنجاح", Colors.green);
//       _fetchData();
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showSnackBar("خطأ أثناء الحفظ: $e", Colors.red);
//     }
//   }

//   void _showSnackBar(String message, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: color),
//     );
//   }

//   // تصفية القائمة بناءً على الفلاتر المختارة
//   List<dynamic> _applyFilters(List<dynamic> sourceData) {
//     return sourceData.where((item) {
//       bool matches = true;
//       _selectedFilters.forEach((column, selectedValues) {
//         if (selectedValues.isNotEmpty) {
//           String itemValue = item[column]?.toString() ?? 'غير محدد';
//           if (!selectedValues.contains(itemValue)) {
//             matches = false;
//           }
//         }
//       });
//       return matches;
//     }).toList();
//   }

//   // إظهار نافذة الاختيار المتعدد
//   void _showMultiSelectFilter(String column) {
//     // الحصول على كل القيم الفريدة لهذا العمود من البيانات الأصلية
//     List<String> uniqueValues = _allInvoices
//         .map((item) => item[column]?.toString() ?? 'غير محدد')
//         .toSet()
//         .toList();
//     uniqueValues.sort();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return AlertDialog(
//               title: Text("تصفية: $column"),
//               content: SizedBox(
//                 width: double.maxFinite,
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: uniqueValues.length,
//                   itemBuilder: (context, index) {
//                     final value = uniqueValues[index];
//                     final isSelected = _selectedFilters[column]!.contains(value);
//                     return CheckboxListTile(
//                       title: Text(value),
//                       value: isSelected,
//                       onChanged: (bool? checked) {
//                         setDialogState(() {
//                           if (checked == true) {
//                             _selectedFilters[column]!.add(value);
//                           } else {
//                             _selectedFilters[column]!.remove(value);
//                           }
//                         });
//                         setState(() {}); // لتحديث الجدول فوراً
//                       },
//                     );
//                   },
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     setState(() {
//                       _selectedFilters[column]!.clear();
//                     });
//                     Navigator.pop(context);
//                   },
//                   child: const Text("مسح الفلتر"),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text("تم"),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final incompleteInvoices = _allInvoices
//         .where((item) => item['ETD'] == null || item['ETA'] == null)
//         .toList();

//     final completeInvoices = _allInvoices
//         .where((item) => item['ETD'] != null && item['ETA'] != null)
//         .toList();

//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Theme.of(context).primaryColor,
//           title: const TabBar(
//             labelColor: Colors.white,
//             unselectedLabelColor: Colors.white70,
//             indicatorColor: Colors.white,
//             tabs: [
//               Tab(text: "مواعيد مطلوبة", icon: Icon(Icons.pending_actions)),
//               Tab(text: "مواعيد مكتملة", icon: Icon(Icons.check_circle_outline)),
//             ],
//           ),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.refresh, color: Colors.white),
//               onPressed: _fetchData,
//             )
//           ],
//         ),
//         body: _isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : TabBarView(
//                 children: [
//                   _buildInvoicesTable(_applyFilters(incompleteInvoices), isUpdate: false),
//                   _buildInvoicesTable(_applyFilters(completeInvoices), isUpdate: true),
//                 ],
//               ),
//       ),
//     );
//   }

//   Widget _buildInvoicesTable(List<dynamic> data, {required bool isUpdate}) {
//     return Column(
//       children: [
//         // شريط الفلاتر النشطة (اختياري لتسهيل المسح)
//         if (_selectedFilters.values.any((v) => v.isNotEmpty))
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Wrap(
//               spacing: 8,
//               children: [
//                 ActionChip(
//                   label: const Text("مسح الكل"),
//                   onPressed: () {
//                     setState(() {
//                       _selectedFilters.forEach((key, value) => value.clear());
//                     });
//                   },
//                   backgroundColor: Colors.red.shade100,
//                 ),
//                 ..._selectedFilters.entries
//                     .where((e) => e.value.isNotEmpty)
//                     .map((e) => Chip(
//                           label: Text("${e.key}: ${e.value.length}"),
//                           onDeleted: () {
//                             setState(() {
//                               _selectedFilters[e.key]!.clear();
//                             });
//                           },
//                         )),
//               ],
//             ),
//           ),
//         Expanded(
//           child: data.isEmpty
//               ? const Center(child: Text("لا توجد بيانات مطابقة للبحث"))
//               : SingleChildScrollView(
//                   scrollDirection: Axis.vertical,
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: DataTable(
//                       columns: [
//                         _buildSortableHeader('Country'),
//                         _buildSortableHeader('SO_Serial'),
//                         _buildSortableHeader('PL_serial'),
//                         _buildSortableHeader('ETD'),
//                         _buildSortableHeader('ETA'),
//                         const DataColumn(label: Text('الإجراء')),
//                       ],
//                       rows: data.map((item) {
//                         return DataRow(cells: [
//                           DataCell(Text(item['Country']?.toString() ?? '-')),
//                           DataCell(Text(item['SO_Serial']?.toString() ?? '-')),
//                           DataCell(Text(item['PL_serial']?.toString() ?? '-')),
//                           DataCell(Text(item['ETD'] ?? 'غير محدد')),
//                           DataCell(Text(item['ETA'] ?? 'غير محدد')),
//                           DataCell(
//                             ElevatedButton.icon(
//                               onPressed: () => _showEditDialog(item),
//                               icon: Icon(isUpdate ? Icons.edit : Icons.add),
//                               label: Text(isUpdate ? "تعديل" : "إضافة"),
//                             ),
//                           ),
//                         ]);
//                       }).toList(),
//                     ),
//                   ),
//                 ),
//         ),
//       ],
//     );
//   }

//   DataColumn _buildSortableHeader(String label) {
//     final bool hasFilter = _selectedFilters[label]!.isNotEmpty;
//     return DataColumn(
//       label: InkWell(
//         onTap: () => _showMultiSelectFilter(label),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(label, style: TextStyle(color: hasFilter ? Colors.blue : Colors.black, fontWeight: hasFilter ? FontWeight.bold : FontWeight.normal)),
//             Icon(Icons.filter_list, size: 16, color: hasFilter ? Colors.blue : Colors.grey),
//           ],
//         ),
//       ),
//     );
//   }

//   // دايالوج التعديل
//   void _showEditDialog(dynamic item) {
//     DateTime? selectedETD = item['ETD'] != null ? DateTime.parse(item['ETD']) : null;
//     DateTime? selectedETA = item['ETA'] != null ? DateTime.parse(item['ETA']) : null;

//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return AlertDialog(
//               title: Text("تحديث مواعيد PL: ${item['PL_serial']}"),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   ListTile(
//                     title: const Text("تاريخ ETD"),
//                     subtitle: Text(selectedETD == null ? "اختر التاريخ" : DateFormat('yyyy-MM-dd').format(selectedETD!)),
//                     trailing: const Icon(Icons.calendar_today),
//                     onTap: () async {
//                       DateTime? picked = await showDatePicker(
//                         context: context,
//                         initialDate: selectedETD ?? DateTime.now(),
//                         firstDate: DateTime(2020),
//                         lastDate: DateTime(2030),
//                       );
//                       if (picked != null) setDialogState(() => selectedETD = picked);
//                     },
//                   ),
//                   ListTile(
//                     title: const Text("تاريخ ETA"),
//                     subtitle: Text(selectedETA == null ? "اختر التاريخ" : DateFormat('yyyy-MM-dd').format(selectedETA!)),
//                     trailing: const Icon(Icons.calendar_today),
//                     onTap: () async {
//                       DateTime? picked = await showDatePicker(
//                         context: context,
//                         initialDate: selectedETA ?? DateTime.now(),
//                         firstDate: DateTime(2020),
//                         lastDate: DateTime(2030),
//                       );
//                       if (picked != null) setDialogState(() => selectedETA = picked);
//                     },
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                     _upsertDates(int.tryParse(item['PL_serial'].toString()), selectedETD, selectedETA);
//                   },
//                   child: const Text("حفظ"),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ShippingManagementScreen extends StatefulWidget {
  const ShippingManagementScreen({super.key});

  @override
  State<ShippingManagementScreen> createState() => _ShippingManagementScreenState();
}

class _ShippingManagementScreenState extends State<ShippingManagementScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool _isLoading = false;
  List<dynamic> _allInvoices = [];

  // فلاتر البحث لكل عمود
  final Map<String, List<String>> _selectedFilters = {
    'Country': [],
    'SO_Serial': [],
    'PL_serial': [],
    'ETD': [],
    'ETA': [],
  };

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // جلب البيانات من الـ View وتجميعها
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await supabase.from('station_groupinvoices').select();
      
      // تجميع البيانات لمنع التكرار (Grouping by unique identifiers)
      final Map<String, dynamic> groupedMap = {};
      
      for (var item in data) {
        // نستخدم PL_serial و SO_Serial كمفتاح فريد للتجميع
        String key = "${item['PL_serial']}_${item['SO_Serial']}";
        if (!groupedMap.containsKey(key)) {
          groupedMap[key] = item;
        }
      }

      setState(() {
        _allInvoices = groupedMap.values.toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("خطأ في جلب البيانات: $e", Colors.red);
    }
  }

  // وظيفة الحفظ المعدلة لحل مشكلة الـ Unique Constraint
  Future<void> _upsertDates(int? plSerial, DateTime? etd, DateTime? eta) async {
    if (plSerial == null) return;
    
    setState(() => _isLoading = true);
    try {
      // 1. التحقق أولاً من وجود السجل في جدول PL_Dates
      final existingData = await supabase
          .from('PL_Dates')
          .select('id')
          .eq('PL_Serial', plSerial)
          .maybeSingle();

      final payload = {
        'PL_Serial': plSerial,
        'ETD': etd?.toIso8601String(),
        'ETA': eta?.toIso8601String(),
      };

      if (existingData != null) {
        // 2. إذا كان موجوداً، نقوم بالتحديث باستخدام المعرف (ID)
        await supabase
            .from('PL_Dates')
            .update(payload)
            .eq('PL_Serial', plSerial);
      } else {
        // 3. إذا لم يكن موجوداً، نقوم بإضافة سجل جديد
        await supabase
            .from('PL_Dates')
            .insert(payload);
      }

      _showSnackBar("تم الحفظ بنجاح", Colors.green);
      _fetchData();
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("خطأ أثناء الحفظ: $e", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  // تصفية القائمة بناءً على الفلاتر المختارة
  List<dynamic> _applyFilters(List<dynamic> sourceData) {
    return sourceData.where((item) {
      bool matches = true;
      _selectedFilters.forEach((column, selectedValues) {
        if (selectedValues.isNotEmpty) {
          String itemValue = item[column]?.toString() ?? 'غير محدد';
          if (!selectedValues.contains(itemValue)) {
            matches = false;
          }
        }
      });
      return matches;
    }).toList();
  }

  // إظهار نافذة الاختيار المتعدد
  void _showMultiSelectFilter(String column) {
    List<String> uniqueValues = _allInvoices
        .map((item) => item[column]?.toString() ?? 'غير محدد')
        .toSet()
        .toList();
    uniqueValues.sort();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("تصفية: $column"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: uniqueValues.length,
                  itemBuilder: (context, index) {
                    final value = uniqueValues[index];
                    final isSelected = _selectedFilters[column]!.contains(value);
                    return CheckboxListTile(
                      title: Text(value),
                      value: isSelected,
                      onChanged: (bool? checked) {
                        setDialogState(() {
                          if (checked == true) {
                            _selectedFilters[column]!.add(value);
                          } else {
                            _selectedFilters[column]!.remove(value);
                          }
                        });
                        setState(() {}); 
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedFilters[column]!.clear();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("مسح الفلتر"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("تم"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final incompleteInvoices = _allInvoices
        .where((item) => item['ETD'] == null || item['ETA'] == null)
        .toList();

    final completeInvoices = _allInvoices
        .where((item) => item['ETD'] != null && item['ETA'] != null)
        .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "مواعيد مطلوبة", icon: Icon(Icons.pending_actions)),
              Tab(text: "مواعيد مكتملة", icon: Icon(Icons.check_circle_outline)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _fetchData,
            )
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildInvoicesTable(_applyFilters(incompleteInvoices), isUpdate: false),
                  _buildInvoicesTable(_applyFilters(completeInvoices), isUpdate: true),
                ],
              ),
      ),
    );
  }

  Widget _buildInvoicesTable(List<dynamic> data, {required bool isUpdate}) {
    return Column(
      children: [
        if (_selectedFilters.values.any((v) => v.isNotEmpty))
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text("مسح الكل"),
                  onPressed: () {
                    setState(() {
                      _selectedFilters.forEach((key, value) => value.clear());
                    });
                  },
                  backgroundColor: Colors.red.shade100,
                ),
                ..._selectedFilters.entries
                    .where((e) => e.value.isNotEmpty)
                    .map((e) => Chip(
                          label: Text("${e.key}: ${e.value.length}"),
                          onDeleted: () {
                            setState(() {
                              _selectedFilters[e.key]!.clear();
                            });
                          },
                        )),
              ],
            ),
          ),
        Expanded(
          child: data.isEmpty
              ? const Center(child: Text("لا توجد بيانات مطابقة للبحث"))
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        _buildSortableHeader('Country'),
                        _buildSortableHeader('SO_Serial'),
                        _buildSortableHeader('PL_serial'),
                        _buildSortableHeader('ETD'),
                        _buildSortableHeader('ETA'),
                        const DataColumn(label: Text('الإجراء')),
                      ],
                      rows: data.map((item) {
                        return DataRow(cells: [
                          DataCell(Text(item['Country']?.toString() ?? '-')),
                          DataCell(Text(item['SO_Serial']?.toString() ?? '-')),
                          DataCell(Text(item['PL_serial']?.toString() ?? '-')),
                          DataCell(Text(item['ETD'] ?? 'غير محدد')),
                          DataCell(Text(item['ETA'] ?? 'غير محدد')),
                          DataCell(
                            ElevatedButton.icon(
                              onPressed: () => _showEditDialog(item),
                              icon: Icon(isUpdate ? Icons.edit : Icons.add),
                              label: Text(isUpdate ? "تعديل" : "إضافة"),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  DataColumn _buildSortableHeader(String label) {
    final bool hasFilter = _selectedFilters[label]!.isNotEmpty;
    return DataColumn(
      label: InkWell(
        onTap: () => _showMultiSelectFilter(label),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(color: hasFilter ? Colors.blue : Colors.black, fontWeight: hasFilter ? FontWeight.bold : FontWeight.normal)),
            Icon(Icons.filter_list, size: 16, color: hasFilter ? Colors.blue : Colors.grey),
          ],
        ),
      ),
    );
  }

  // دايالوج التعديل
  void _showEditDialog(dynamic item) {
    DateTime? selectedETD = item['ETD'] != null ? DateTime.parse(item['ETD']) : null;
    DateTime? selectedETA = item['ETA'] != null ? DateTime.parse(item['ETA']) : null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("تحديث مواعيد PL: ${item['PL_serial']}"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text("تاريخ ETD"),
                    subtitle: Text(selectedETD == null ? "اختر التاريخ" : DateFormat('yyyy-MM-dd').format(selectedETD!)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedETD ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) setDialogState(() => selectedETD = picked);
                    },
                  ),
                  ListTile(
                    title: const Text("تاريخ ETA"),
                    subtitle: Text(selectedETA == null ? "اختر التاريخ" : DateFormat('yyyy-MM-dd').format(selectedETA!)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedETA ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) setDialogState(() => selectedETA = picked);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _upsertDates(int.tryParse(item['PL_serial'].toString()), selectedETD, selectedETA);
                  },
                  child: const Text("حفظ"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}