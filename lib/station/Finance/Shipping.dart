

// // import 'package:flutter/material.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import 'package:intl/intl.dart';
// // import 'package:flutter/services.dart';
// // import 'package:excel/excel.dart';
// // import 'package:file_picker/file_picker.dart'; // لاختيار الملفات في الويب
// // import 'dart:typed_data'; // ضروري للتعامل مع بيانات الملفات في الويب

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
// //     'ContainerNumber': [],
// //     'PL_serial': [],
// //     'ETD': [],
// //     'ETA': [],
// //   };

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchData();
// //   }

// //   // 1. جلب البيانات من الـ View وتجميعها
// //   Future<void> _fetchData() async {
// //     setState(() => _isLoading = true);
// //     try {
// //       final data = await supabase.from('Station_GroupInvoices').select();
      
// //       final Map<String, dynamic> groupedMap = {};
// //       for (var item in data) {
// //         String key = "${item['PL_serial']}_${item['SO_Serial']}";
// //         if (!groupedMap.containsKey(key)) {
// //           groupedMap[key] = item;
// //         }
// //       }

// //       setState(() {
// //         _allInvoices = groupedMap.values.toList();
// //         _isLoading = false;
// //       });
// //     } catch (e) {
// //       print('error : $e');
// //       setState(() => _isLoading = false);
// //       _showSnackBar("خطأ في جلب البيانات: $e", Colors.red);
// //     }
// //   }

// //   // 2. تنزيل قالب إكسل (نسخة الويب) - تم إصلاح النوع هنا
// //   Future<void> _downloadExcelTemplate() async {
// //     setState(() => _isLoading = true);
// //     try {
// //       // إنشاء ملف Excel جديد
// //       var excel = Excel.createExcel();
// //       Sheet sheetObject = excel['Sheet1'];

// //       // إضافة العناوين (Headers) باستخدام TextCellValue
// //       List<CellValue> headers = [
// //         TextCellValue("Country"),
// //         TextCellValue("SO_Serial"),
// //         TextCellValue("ContainerNumber"),
// //         TextCellValue("PL_serial"),
// //         TextCellValue("ETD"),
// //         TextCellValue("ETA"),
// //       ];
// //       sheetObject.appendRow(headers);

// //       // في الويب، نقوم بحفظ الملف كقائمة من البايتات ثم نطلب من المتصفح تحميله
// //       var fileBytes = excel.save();
      
// //       if (fileBytes != null) {
// //         _showSnackBar("جاري تحميل القالب إلى متصفحك...", Colors.blue);
        
// //         // حفظ الملف في الويب
// //         excel.save(fileName: "Shipping_Template.xlsx");
        
// //         _showSnackBar("تم إرسال طلب تحميل الملف بنجاح", Colors.green);
// //       }
// //     } catch (e) {
// //       _showSnackBar("خطأ أثناء تحميل القالب: $e", Colors.red);
// //     } finally {
// //       setState(() => _isLoading = false);
// //     }
// //   }

// //   // 3. رفع البيانات من الإكسل (نسخة الويب) - تم تحديث القراءة هنا
// //   Future<void> _importFromExcel() async {
// //     try {
// //       FilePickerResult? result = await FilePicker.platform.pickFiles(
// //         type: FileType.custom,
// //         allowedExtensions: ['xlsx'],
// //         withData: true,
// //       );

// //       if (result != null && result.files.first.bytes != null) {
// //         setState(() => _isLoading = true);
// //         var bytes = result.files.first.bytes!;
// //         var excel = Excel.decodeBytes(bytes);

// //         for (var table in excel.tables.keys) {
// //           var rows = excel.tables[table]!.rows;
// //           // نتخطى أول صف لأنه العناوين
// //           for (int i = 1; i < rows.length; i++) {
// //             var row = rows[i];
// //             if (row.length >= 5) {
// //               // استخراج البيانات باستخدام .value
// //               final plSerialStr = row[2]?.value?.toString();
// //               final etdValue = row[3]?.value?.toString();
// //               final etaValue = row[4]?.value?.toString();

// //               if (plSerialStr != null) {
// //                 int? plSerial = int.tryParse(plSerialStr);
// //                 DateTime? etd = etdValue != null ? DateTime.tryParse(etdValue) : null;
// //                 DateTime? eta = etaValue != null ? DateTime.tryParse(etaValue) : null;
                
// //                 await _upsertDates(plSerial, etd, eta);
// //               }
// //             }
// //           }
// //         }
// //         _showSnackBar("تمت عملية الاستيراد بنجاح", Colors.green);
// //         _fetchData();
// //       }
// //     } catch (e) {
// //       _showSnackBar("خطأ أثناء استيراد الملف: $e", Colors.red);
// //     } finally {
// //       setState(() => _isLoading = false);
// //     }
// //   }

// //   // 4. نسخ بيانات الجدول الحالي إلى الحافظة
// //   void _copyTableToClipboard(List<dynamic> data) {
// //     if (data.isEmpty) {
// //       _showSnackBar("لا توجد بيانات لنسخها", Colors.orange);
// //       return;
// //     }

// //     String header = "Country\tSO_Serial\tContainerNumber\tPL_serial\tETD\tETA\n";
// //     String rows = data.map((item) {
// //       return "${item['Country'] ?? '-'}\t${item['SO_Serial'] ?? '-'}\t${item['ContainerNumber'] ?? '-'}\t${item['PL_serial'] ?? '-'}\t${item['ETD'] ?? '-'}\t${item['ETA'] ?? '-'}";
// //     }).join("\n");

// //     String fullContent = header + rows;
    
// //     Clipboard.setData(ClipboardData(text: fullContent)).then((_) {
// //       _showSnackBar("تم نسخ بيانات الجدول إلى الحافظة بنجاح", Colors.green);
// //     });
// //   }

// //   // وظيفة الحفظ (Upsert)
// //   Future<void> _upsertDates(int? plSerial, DateTime? etd, DateTime? eta) async {
// //     if (plSerial == null) return;
    
// //     try {
// //       final existingData = await supabase
// //           .from('PL_Dates')
// //           .select('id')
// //           .eq('PL_Serial', plSerial)
// //           .maybeSingle();

// //       final payload = {
// //         'PL_Serial': plSerial,
// //         'ETD': etd?.toIso8601String(),
// //         'ETA': eta?.toIso8601String(),
// //       };

// //       if (existingData != null) {
// //         await supabase
// //             .from('PL_Dates')
// //             .update(payload)
// //             .eq('PL_Serial', plSerial);
// //       } else {
// //         await supabase
// //             .from('PL_Dates')
// //             .insert(payload);
// //       }
// //     } catch (e) {
// //       print("Error upserting PL $plSerial: $e");
// //     }
// //   }

// //   void _showSnackBar(String message, Color color) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text(message), backgroundColor: color),
// //     );
// //   }

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

// //   void _showMultiSelectFilter(String column) {
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
// //                         setState(() {}); 
// //                       },
// //                     );
// //                   },
// //                 ),
// //               ),
// //               actions: [
// //                 TextButton(
// //                   onPressed: () {
// //                     setState(() { _selectedFilters[column]!.clear(); });
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
// //     final incompleteInvoices = _allInvoices.where((item) => item['ETD'] == null || item['ETA'] == null).toList();
// //     final completeInvoices = _allInvoices.where((item) => item['ETD'] != null && item['ETA'] != null).toList();

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
// //             PopupMenuButton<String>(
// //               icon: const Icon(Icons.more_vert, color: Colors.white),
// //               onSelected: (value) {
// //                 if (value == 'download') _downloadExcelTemplate();
// //                 if (value == 'upload') _importFromExcel();
// //                 if (value == 'copy') _copyTableToClipboard(_allInvoices);
// //               },
// //               itemBuilder: (context) => [
// //                 const PopupMenuItem(value: 'download', child: ListTile(leading: Icon(Icons.download), title: Text("تحميل قالب Excel"))),
// //                 const PopupMenuItem(value: 'upload', child: ListTile(leading: Icon(Icons.upload_file), title: Text("رفع من Excel"))),
// //                 const PopupMenuItem(value: 'copy', child: ListTile(leading: Icon(Icons.copy), title: Text("نسخ الجدول"))),
// //               ],
// //             ),
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
// //         if (_selectedFilters.values.any((v) => v.isNotEmpty))
// //           Padding(
// //             padding: const EdgeInsets.all(8.0),
// //             child: Wrap(
// //               spacing: 8,
// //               children: [
// //                 ActionChip(
// //                   label: const Text("مسح الكل"),
// //                   onPressed: () {
// //                     setState(() { _selectedFilters.forEach((key, value) => value.clear()); });
// //                   },
// //                   backgroundColor: Colors.red.shade100,
// //                 ),
// //                 ..._selectedFilters.entries
// //                     .where((e) => e.value.isNotEmpty)
// //                     .map((e) => Chip(
// //                           label: Text("${e.key}: ${e.value.length}"),
// //                           onDeleted: () {
// //                             setState(() { _selectedFilters[e.key]!.clear(); });
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
// //                          _buildSortableHeader('ContainerNumber'),
// //                         _buildSortableHeader('PL_serial'),
// //                         _buildSortableHeader('ETD'),
// //                         _buildSortableHeader('ETA'),
// //                         const DataColumn(label: Text('الإجراء')),
// //                       ],
// //                       rows: data.map((item) {
// //                         return DataRow(cells: [
// //                           DataCell(Text(item['Country']?.toString() ?? '-')),
// //                           DataCell(Text(item['SO_Serial']?.toString() ?? '-')),
// //                           DataCell(Text(item['ContainerNumber']?.toString() ?? '-')),
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
// import 'package:flutter/services.dart';
// import 'package:excel/excel.dart';
// import 'package:file_picker/file_picker.dart'; // لاختيار الملفات في الويب
// import 'dart:typed_data'; // ضروري للتعامل مع بيانات الملفات في الويب

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
//     'ContainerNumber': [],
//     'PL_serial': [],
//     'ETD': [],
//     'ETA': [],
//   };

//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }

//   // 1. جلب البيانات من الـ View وتجميعها
//   Future<void> _fetchData() async {
//     setState(() => _isLoading = true);
//     try {
//       final data = await supabase.from('Station_GroupInvoices').select();
      
//       final Map<String, dynamic> groupedMap = {};
//       for (var item in data) {
//         String key = "${item['PL_serial']}_${item['SO_Serial']}";
//         if (!groupedMap.containsKey(key)) {
//           groupedMap[key] = item;
//         }
//       }

//       setState(() {
//         _allInvoices = groupedMap.values.toList();
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('error : $e');
//       setState(() => _isLoading = false);
//       _showSnackBar("خطأ في جلب البيانات: $e", Colors.red);
//     }
//   }

//   // 2. تنزيل قالب إكسل (نسخة الويب)
//   Future<void> _downloadExcelTemplate() async {
//     setState(() => _isLoading = true);
//     try {
//       var excel = Excel.createExcel();
//       Sheet sheetObject = excel['Sheet1'];

//       List<CellValue> headers = [
//         TextCellValue("Country"),
//         TextCellValue("SO_Serial"),
//         TextCellValue("ContainerNumber"),
//         TextCellValue("PL_serial"),
//         TextCellValue("ETD"),
//         TextCellValue("ETA"),
//       ];
//       sheetObject.appendRow(headers);

//       var fileBytes = excel.save();
//       if (fileBytes != null) {
//         _showSnackBar("جاري تحميل القالب...", Colors.blue);
//         excel.save(fileName: "Shipping_Template.xlsx");
//       }
//     } catch (e) {
//       _showSnackBar("خطأ أثناء تحميل القالب: $e", Colors.red);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   // 3. رفع البيانات من الإكسل (حفظ جماعي سريع)
//   Future<void> _importFromExcel() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['xlsx'],
//         withData: true,
//       );

//       if (result != null && result.files.first.bytes != null) {
//         setState(() => _isLoading = true);
//         var bytes = result.files.first.bytes!;
//         var excel = Excel.decodeBytes(bytes);
        
//         List<Map<String, dynamic>> upsertData = [];

//         for (var table in excel.tables.keys) {
//           var rows = excel.tables[table]!.rows;
//           for (int i = 1; i < rows.length; i++) {
//             var row = rows[i];
//             // ترتيب الأعمدة: 0:Country, 1:SO, 2:Container, 3:PL, 4:ETD, 5:ETA
//             if (row.length >= 6) {
//               final plSerialStr = row[3]?.value?.toString();
//               // final containerNum = row[2]?.value?.toString();
//               final etdValue = row[4]?.value?.toString();
//               final etaValue = row[5]?.value?.toString();

//               if (plSerialStr != null) {
//                 int? plSerial = int.tryParse(plSerialStr);
//                 if (plSerial != null) {
//                   upsertData.add({
//                     'PL_Serial': plSerial,
//                     // 'ContainerNumber': containerNum,
//                     'ETD': _formatDateForDb(etdValue),
//                     'ETA': _formatDateForDb(etaValue),
//                   });
//                 }
//               }
//             }
//           }
//         }

//         if (upsertData.isNotEmpty) {
//           // تنفيذ عملية Upsert جماعية في طلب واحد
//           await supabase.from('PL_Dates').upsert(
//             upsertData,
//             onConflict: 'PL_Serial', // المفتاح الذي يتم التأكد من عدم تكراره (تحديث بناءً عليه)
//           );
//           _showSnackBar("تم حفظ ${upsertData.length} سجل بنجاح", Colors.green);
//           _fetchData();
//         } else {
//           _showSnackBar("لا توجد بيانات صالحة في الملف", Colors.orange);
//         }
//       }
//     } catch (e) {
//       _showSnackBar("خطأ أثناء الاستيراد الجماعي: $e", Colors.red);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   // مساعدة لتنسيق التاريخ قبل الإرسال
//   String? _formatDateForDb(String? input) {
//     if (input == null || input.isEmpty) return null;
//     try {
//       DateTime dt = DateTime.parse(input);
//       return dt.toIso8601String();
//     } catch (e) {
//       return null;
//     }
//   }

//   // 4. نسخ بيانات الجدول الحالي إلى الحافظة
//   void _copyTableToClipboard(List<dynamic> data) {
//     if (data.isEmpty) {
//       _showSnackBar("لا توجد بيانات لنسخها", Colors.orange);
//       return;
//     }

//     String header = "Country\tSO_Serial\tContainerNumber\tPL_serial\tETD\tETA\n";
//     String rows = data.map((item) {
//       return "${item['Country'] ?? '-'}\t${item['SO_Serial'] ?? '-'}\t${item['ContainerNumber'] ?? '-'}\t${item['PL_serial'] ?? '-'}\t${item['ETD'] ?? '-'}\t${item['ETA'] ?? '-'}";
//     }).join("\n");

//     Clipboard.setData(ClipboardData(text: header + rows)).then((_) {
//       _showSnackBar("تم نسخ الجدول إلى الحافظة", Colors.green);
//     });
//   }

//   // حفظ مفرد (للتعديل اليدوي من الشاشة)
//   Future<void> _upsertSingle(int plSerial, DateTime? etd, DateTime? eta) async {
//     try {
//       setState(() => _isLoading = true);
//       await supabase.from('PL_Dates').upsert({
//         'PL_Serial': plSerial,
        
//         'ETD': etd?.toIso8601String(),
//         'ETA': eta?.toIso8601String(),
//       }, onConflict: 'PL_Serial');
      
//       _showSnackBar("تم التحديث بنجاح", Colors.green);
//       _fetchData();
//     } catch (e) {
//       _showSnackBar("خطأ في الحفظ: $e", Colors.red);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   void _showSnackBar(String message, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: color),
//     );
//   }

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

//   void _showMultiSelectFilter(String column) {
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
//                         setState(() {}); 
//                       },
//                     );
//                   },
//                 ),
//               ),
//               actions: [
//                 TextButton(onPressed: () { setState(() { _selectedFilters[column]!.clear(); }); Navigator.pop(context); }, child: const Text("مسح")),
//                 ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("تم")),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final incomplete = _allInvoices.where((item) => item['ETD'] == null || item['ETA'] == null).toList();
//     final complete = _allInvoices.where((item) => item['ETD'] != null && item['ETA'] != null).toList();

//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Theme.of(context).primaryColor,
//           title: const TabBar(
//             labelColor: Colors.white,
//             indicatorColor: Colors.white,
//             tabs: [
//               Tab(text: "مواعيد مطلوبة", icon: Icon(Icons.pending_actions)),
//               Tab(text: "مواعيد مكتملة", icon: Icon(Icons.check_circle_outline)),
//             ],
//           ),
//           actions: [
//             PopupMenuButton<String>(
//               icon: const Icon(Icons.more_vert, color: Colors.white),
//               onSelected: (val) {
//                 if (val == 'download') _downloadExcelTemplate();
//                 if (val == 'upload') _importFromExcel();
//                 if (val == 'copy') _copyTableToClipboard(_allInvoices);
//               },
//               itemBuilder: (ctx) => [
//                 const PopupMenuItem(value: 'download', child: ListTile(leading: Icon(Icons.download), title: Text("تحميل القالب"))),
//                 const PopupMenuItem(value: 'upload', child: ListTile(leading: Icon(Icons.upload_file), title: Text("رفع البيانات"))),
//                 const PopupMenuItem(value: 'copy', child: ListTile(leading: Icon(Icons.copy), title: Text("نسخ الكل"))),
//               ],
//             ),
//             IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _fetchData)
//           ],
//         ),
//         body: _isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : TabBarView(
//                 children: [
//                   _buildInvoicesTable(_applyFilters(incomplete), isUpdate: false),
//                   _buildInvoicesTable(_applyFilters(complete), isUpdate: true),
//                 ],
//               ),
//       ),
//     );
//   }

//   Widget _buildInvoicesTable(List<dynamic> data, {required bool isUpdate}) {
//     return Column(
//       children: [
//         Expanded(
//           child: SingleChildScrollView(
//             scrollDirection: Axis.vertical,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: DataTable(
//                 columns: [
//                   _buildSortableHeader('Country'),
//                   _buildSortableHeader('SO_Serial'),
//                   _buildSortableHeader('ContainerNumber'),
//                   _buildSortableHeader('PL_serial'),
//                   _buildSortableHeader('ETD'),
//                   _buildSortableHeader('ETA'),
//                   const DataColumn(label: Text('الإجراء')),
//                 ],
//                 rows: data.map((item) {
//                   return DataRow(cells: [
//                     DataCell(Text(item['Country']?.toString() ?? '-')),
//                     DataCell(Text(item['SO_Serial']?.toString() ?? '-')),
//                     DataCell(Text(item['ContainerNumber']?.toString() ?? '-')),
//                     DataCell(Text(item['PL_serial']?.toString() ?? '-')),
//                     DataCell(Text(item['ETD'] ?? 'N/A')),
//                     DataCell(Text(item['ETA'] ?? 'N/A')),
//                     DataCell(
//                       IconButton(
//                         icon: Icon(isUpdate ? Icons.edit : Icons.add_circle, color: Colors.blue),
//                         onPressed: () => _showEditDialog(item),
//                       ),
//                     ),
//                   ]);
//                 }).toList(),
//               ),
//             ),
//           ),
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
//             Text(label, style: TextStyle(color: hasFilter ? Colors.blue : Colors.black)),
//             Icon(Icons.filter_alt, size: 14, color: hasFilter ? Colors.blue : Colors.grey),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showEditDialog(dynamic item) {
//     DateTime? selectedETD = item['ETD'] != null ? DateTime.tryParse(item['ETD']) : null;
//     DateTime? selectedETA = item['ETA'] != null ? DateTime.tryParse(item['ETA']) : null;
//     final TextEditingController containerController = TextEditingController(text: item['ContainerNumber']?.toString() ?? "");

//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setDialogState) => AlertDialog(
//           title: Text("تحديث PL: ${item['PL_serial']}"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: containerController,
//                 decoration: const InputDecoration(labelText: "رقم الحاوية (Container Number)"),
//               ),
//               const SizedBox(height: 10),
//               ListTile(
//                 title: const Text("ETD"),
//                 subtitle: Text(selectedETD == null ? "اختر التاريخ" : DateFormat('yyyy-MM-dd').format(selectedETD!)),
//                 onTap: () async {
//                   DateTime? p = await showDatePicker(context: context, initialDate: selectedETD ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
//                   if (p != null) setDialogState(() => selectedETD = p);
//                 },
//               ),
//               ListTile(
//                 title: const Text("ETA"),
//                 subtitle: Text(selectedETA == null ? "اختر التاريخ" : DateFormat('yyyy-MM-dd').format(selectedETA!)),
//                 onTap: () async {
//                   DateTime? p = await showDatePicker(context: context, initialDate: selectedETA ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
//                   if (p != null) setDialogState(() => selectedETA = p);
//                 },
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _upsertSingle(
//                   int.parse(item['PL_serial'].toString()),
//                   selectedETD,
//                   selectedETA,
                  
//                 );
//               },
//               child: const Text("حفظ"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart'; // لاختيار الملفات في الويب
import 'dart:typed_data'; // ضروري للتعامل مع بيانات الملفات في الويب

class ShippingManagementScreen extends StatefulWidget {
  const ShippingManagementScreen({super.key});

  @override
  State<ShippingManagementScreen> createState() => _ShippingManagementScreenState();
}

class _ShippingManagementScreenState extends State<ShippingManagementScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool _isLoading = false;
  List<dynamic> _allInvoices = [];
  
  // لتخزين الـ PL_Serials المختارة للوصول
  final Set<int> _selectedPLs = {};

  // فلاتر البحث لكل عمود
  final Map<String, List<String>> _selectedFilters = {
    'Country': [],
    'SO_Serial': [],
    'ContainerNumber': [],
    'PL_serial': [],
    'ETD': [],
    'ETA': [],
    'Is_Arrival': [],
  };

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // 1. جلب البيانات من الـ View وتجميعها
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await supabase.from('Station_GroupInvoices').select();
      
      final Map<String, dynamic> groupedMap = {};
      for (var item in data) {
        String key = "${item['PL_serial']}_${item['SO_Serial']}";
        if (!groupedMap.containsKey(key)) {
          groupedMap[key] = item;
        }
      }

      setState(() {
        _allInvoices = groupedMap.values.toList();
        _selectedPLs.clear(); // تفريغ التحديد عند التحديث
        _isLoading = false;
      });
    } catch (e) {
      print('error : $e');
      setState(() => _isLoading = false);
      _showSnackBar("خطأ في جلب البيانات: $e", Colors.red);
    }
  }

  // تحديث حالة الوصول جماعياً
  Future<void> _updateArrivalStatus(int status) async {
    if (_selectedPLs.isEmpty) {
      _showSnackBar("يرجى اختيار سجل واحد على الأقل", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);
    try {
      // تحديث عمود Is_Arrival بناءً على PL_Serial المختار
      for (var plSerial in _selectedPLs) {
        await supabase.from('PL_Dates').upsert({
          'PL_Serial': plSerial,
          'Is_Arrival': status,
        }, onConflict: 'PL_Serial');
      }

      _showSnackBar("تم تحديث حالة الوصول لـ ${_selectedPLs.length} سجل", Colors.green);
      _fetchData();
    } catch (e) {
      print('error : $e');
      _showSnackBar("خطأ أثناء التحديث: $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 2. تنزيل قالب إكسل (نسخة الويب)
  Future<void> _downloadExcelTemplate() async {
    setState(() => _isLoading = true);
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      List<CellValue> headers = [
        TextCellValue("Country"),
        TextCellValue("SO_Serial"),
        TextCellValue("ContainerNumber"),
        TextCellValue("PL_serial"),
        TextCellValue("ETD"),
        TextCellValue("ETA"),
        TextCellValue("Is_Arrival"),
      ];
      sheetObject.appendRow(headers);

      var fileBytes = excel.save();
      if (fileBytes != null) {
        _showSnackBar("جاري تحميل القالب...", Colors.blue);
        excel.save(fileName: "Shipping_Template.xlsx");
      }
    } catch (e) {
      _showSnackBar("خطأ أثناء تحميل القالب: $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 3. رفع البيانات من الإكسل
  Future<void> _importFromExcel() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );

      if (result != null && result.files.first.bytes != null) {
        setState(() => _isLoading = true);
        var bytes = result.files.first.bytes!;
        var excel = Excel.decodeBytes(bytes);
        
        List<Map<String, dynamic>> upsertData = [];

        for (var table in excel.tables.keys) {
          var rows = excel.tables[table]!.rows;
          for (int i = 1; i < rows.length; i++) {
            var row = rows[i];
            if (row.length >= 6) {
              final plSerialStr = row[3]?.value?.toString();
              final etdValue = row[4]?.value?.toString();
              final etaValue = row[5]?.value?.toString();

              if (plSerialStr != null) {
                int? plSerial = int.tryParse(plSerialStr);
                if (plSerial != null) {
                  upsertData.add({
                    'PL_Serial': plSerial,
                    'ETD': _formatDateForDb(etdValue),
                    'ETA': _formatDateForDb(etaValue),
                  });
                }
              }
            }
          }
        }

        if (upsertData.isNotEmpty) {
          await supabase.from('PL_Dates').upsert(
            upsertData,
            onConflict: 'PL_Serial',
          );
          _showSnackBar("تم حفظ ${upsertData.length} سجل بنجاح", Colors.green);
          _fetchData();
        } else {
          _showSnackBar("لا توجد بيانات صالحة في الملف", Colors.orange);
        }
      }
    } catch (e) {
      _showSnackBar("خطأ أثناء الاستيراد الجماعي: $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String? _formatDateForDb(String? input) {
    if (input == null || input.isEmpty) return null;
    try {
      DateTime dt = DateTime.parse(input);
      return dt.toIso8601String();
    } catch (e) {
      return null;
    }
  }

  void _copyTableToClipboard(List<dynamic> data) {
    if (data.isEmpty) {
      _showSnackBar("لا توجد بيانات لنسخها", Colors.orange);
      return;
    }

    String header = "Country\tSO_Serial\tContainerNumber\tPL_serial\tETD\tETA\n";
    String rows = data.map((item) {
      return "${item['Country'] ?? '-'}\t${item['SO_Serial'] ?? '-'}\t${item['ContainerNumber'] ?? '-'}\t${item['PL_serial'] ?? '-'}\t${item['ETD'] ?? '-'}\t${item['ETA'] ?? '-'}";
    }).join("\n");

    Clipboard.setData(ClipboardData(text: header + rows)).then((_) {
      _showSnackBar("تم نسخ الجدول إلى الحافظة", Colors.green);
    });
  }

  Future<void> _upsertSingle(int plSerial, DateTime? etd, DateTime? eta) async {
    try {
      setState(() => _isLoading = true);
      await supabase.from('PL_Dates').upsert({
        'PL_Serial': plSerial,
        'ETD': etd?.toIso8601String(),
        'ETA': eta?.toIso8601String(),
      }, onConflict: 'PL_Serial');
      
      _showSnackBar("تم التحديث بنجاح", Colors.green);
      _fetchData();
    } catch (e) {
      _showSnackBar("خطأ في الحفظ: $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

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
                TextButton(onPressed: () { setState(() { _selectedFilters[column]!.clear(); }); Navigator.pop(context); }, child: const Text("مسح")),
                ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("تم")),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // تصفية البيانات لكل تابة
    final incomplete = _allInvoices.where((item) => item['ETD'] == null || item['ETA'] == null).toList();
    final complete = _allInvoices.where((item) => item['ETD'] != null && item['ETA'] != null).toList();
    
    // التبويبات الجديدة بناءً على Is_Arrival
    final notArrived = _allInvoices.where((item) => item['ETD'] != null && item['ETA'] != null && (item['Is_Arrival'] == 0 || item['Is_Arrival'] == null)).toList();
    final arrived = _allInvoices.where((item) => item['Is_Arrival'] == 1).toList();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "مواعيد مطلوبة"),
              Tab(text: "مواعيد مكتملة"),
              Tab(text: "لم تصل بعد"),
              Tab(text: "وصلت"),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (val) {
                if (val == 'download') _downloadExcelTemplate();
                if (val == 'upload') _importFromExcel();
                if (val == 'copy') _copyTableToClipboard(_allInvoices);
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'download', child: ListTile(leading: Icon(Icons.download), title: Text("تحميل القالب"))),
                const PopupMenuItem(value: 'upload', child: ListTile(leading: Icon(Icons.upload_file), title: Text("رفع البيانات"))),
                const PopupMenuItem(value: 'copy', child: ListTile(leading: Icon(Icons.copy), title: Text("نسخ الكل"))),
              ],
            ),
            IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _fetchData)
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildInvoicesTable(_applyFilters(incomplete), isUpdate: false),
                  _buildInvoicesTable(_applyFilters(complete), isUpdate: true),
                  _buildArrivalManagementTable(_applyFilters(notArrived), targetStatus: 1),
                  _buildArrivalManagementTable(_applyFilters(arrived), targetStatus: 0),
                ],
              ),
      ),
    );
  }

  // جدول التبويبات الأساسية (مواعيد)
  Widget _buildInvoicesTable(List<dynamic> data, {required bool isUpdate}) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  _buildSortableHeader('Country'),
                  _buildSortableHeader('SO_Serial'),
                  _buildSortableHeader('ContainerNumber'),
                  _buildSortableHeader('PL_serial'),
                  _buildSortableHeader('ETD'),
                  _buildSortableHeader('ETA'),
                  const DataColumn(label: Text('تعديل')),
                ],
                rows: data.map((item) {
                  return DataRow(cells: [
                    DataCell(Text(item['Country']?.toString() ?? '-')),
                    DataCell(Text(item['SO_Serial']?.toString() ?? '-')),
                    DataCell(Text(item['ContainerNumber']?.toString() ?? '-')),
                    DataCell(Text(item['PL_serial']?.toString() ?? '-')),
                    DataCell(Text(item['ETD'] ?? 'N/A')),
                    DataCell(Text(item['ETA'] ?? 'N/A')),
                    DataCell(
                      IconButton(
                        icon: Icon(isUpdate ? Icons.edit : Icons.add_circle, color: Colors.blue),
                        onPressed: () => _showEditDialog(item),
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

  // جدول إدارة الوصول (مع تشيك بوكس)
  Widget _buildArrivalManagementTable(List<dynamic> data, {required int targetStatus}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("تم اختيار: ${_selectedPLs.length}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _updateArrivalStatus(targetStatus),
                icon: Icon(targetStatus == 1 ? Icons.local_shipping : Icons.undo),
                label: Text(targetStatus == 1 ? "تحديث كـ وصلت" : "تراجع عن الوصول"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: targetStatus == 1 ? Colors.green : Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  const DataColumn(label: Text('تحديد')),
                  _buildSortableHeader('Country'),
                  _buildSortableHeader('SO_Serial'),
                  _buildSortableHeader('ContainerNumber'),
                  _buildSortableHeader('PL_serial'),
                  _buildSortableHeader('ETD'),
                  _buildSortableHeader('ETA'),
                ],
                rows: data.map((item) {
                  final int plSerial = int.parse(item['PL_serial'].toString());
                  final isSelected = _selectedPLs.contains(plSerial);
                  return DataRow(
                    selected: isSelected,
                    cells: [
                    DataCell(
                      Checkbox(
                        value: isSelected,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedPLs.add(plSerial);
                            } else {
                              _selectedPLs.remove(plSerial);
                            }
                          });
                        },
                      ),
                    ),
                    DataCell(Text(item['Country']?.toString() ?? '-')),
                    DataCell(Text(item['SO_Serial']?.toString() ?? '-')),
                    DataCell(Text(item['ContainerNumber']?.toString() ?? '-')),
                    DataCell(Text(item['PL_serial']?.toString() ?? '-')),
                    DataCell(Text(item['ETD'] ?? 'N/A')),
                    DataCell(Text(item['ETA'] ?? 'N/A')),
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
            Text(label, style: TextStyle(color: hasFilter ? Colors.blue : Colors.black)),
            Icon(Icons.filter_alt, size: 14, color: hasFilter ? Colors.blue : Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(dynamic item) {
    DateTime? selectedETD = item['ETD'] != null ? DateTime.tryParse(item['ETD']) : null;
    DateTime? selectedETA = item['ETA'] != null ? DateTime.tryParse(item['ETA']) : null;
    final TextEditingController containerController = TextEditingController(text: item['ContainerNumber']?.toString() ?? "");

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("تحديث PL: ${item['PL_serial']}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: containerController,
                decoration: const InputDecoration(labelText: "رقم الحاوية (Container Number)"),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text("ETD"),
                subtitle: Text(selectedETD == null ? "اختر التاريخ" : DateFormat('yyyy-MM-dd').format(selectedETD!)),
                onTap: () async {
                  DateTime? p = await showDatePicker(context: context, initialDate: selectedETD ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                  if (p != null) setDialogState(() => selectedETD = p);
                },
              ),
              ListTile(
                title: const Text("ETA"),
                subtitle: Text(selectedETA == null ? "اختر التاريخ" : DateFormat('yyyy-MM-dd').format(selectedETA!)),
                onTap: () async {
                  DateTime? p = await showDatePicker(context: context, initialDate: selectedETA ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                  if (p != null) setDialogState(() => selectedETA = p);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _upsertSingle(
                  int.parse(item['PL_serial'].toString()),
                  selectedETD,
                  selectedETA,
                );
              },
              child: const Text("حفظ"),
            ),
          ],
        ),
      ),
    );
  }
}