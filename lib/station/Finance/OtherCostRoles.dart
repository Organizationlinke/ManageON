
// import 'dart:convert';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
// import 'package:intl/intl.dart';

// ملاحظة: قد تحتاج لإضافة هذه المكتبات في pubspec.yaml لتحميل الملفات فعلياً
// universal_html: ^2.2.4 (للويد) أو path_provider (للجوال)

class OtherCostRolesScreen extends StatefulWidget {
  const OtherCostRolesScreen({super.key});

  @override
  State<OtherCostRolesScreen> createState() => _OtherCostRolesScreenState();
}

class _OtherCostRolesScreenState extends State<OtherCostRolesScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _data = [];
  List<Map<String, dynamic>> _filteredData = [];
  bool _isLoading = false;

  String _selectedBrand = 'All';
  String _selectedWeight = 'All';
  String _selectedType = 'All';

  List<String> _brands = ['All'];
  List<String> _weights = ['All'];
  List<String> _types = ['All'];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('OtherCostRoles')
          .select()
          .order('DateFrom', ascending: false);
      
      final List<Map<String, dynamic>> fetchedData = List<Map<String, dynamic>>.from(response);
      
      setState(() {
        _data = fetchedData;
        _filteredData = fetchedData;
        _updateFilters();
        _isLoading = false;
      });
    } catch (e) {
      _showSnackBar('خطأ في جلب البيانات: $e', Colors.red);
      setState(() => _isLoading = false);
    }
  }

  void _updateFilters() {
    _brands = ['All', ..._data.map((e) => e['Brand']?.toString() ?? '').toSet().where((e) => e.isNotEmpty)];
    _weights = ['All', ..._data.map((e) => e['CTNWeight']?.toString() ?? '').toSet().where((e) => e.isNotEmpty)];
    _types = ['All', ..._data.map((e) => e['CTNType']?.toString() ?? '').toSet().where((e) => e.isNotEmpty)];
  }

  void _applyFilters() {
    setState(() {
      _filteredData = _data.where((item) {
        final brandMatch = _selectedBrand == 'All' || item['Brand'] == _selectedBrand;
        final weightMatch = _selectedWeight == 'All' || item['CTNWeight'] == _selectedWeight;
        final typeMatch = _selectedType == 'All' || item['CTNType'] == _selectedType;
        return brandMatch && weightMatch && typeMatch;
      }).toList();
    });
  }

  Future<void> _importExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        Uint8List? bytes = result.files.single.bytes;
        
        if (bytes == null) {
          throw Exception("تعذر قراءة محتوى الملف");
        }

        var excel = Excel.decodeBytes(bytes);
        var table = excel.tables[excel.tables.keys.first];

        if (table == null) return;

        List<Map<String, dynamic>> rowsToUpload = [];
        
        for (var i = 1; i < table.maxRows; i++) {
          var row = table.rows[i];
          if (row.isEmpty || row[0] == null) continue;

          final Map<String, dynamic> rowData = {
            'DateFrom': row[0]?.value.toString(),
            'DateTo': row[1]?.value.toString(),
            'CTNType': row[2]?.value.toString(),
            'CTNWeight': row[3]?.value.toString(),
            'Brand': row[4]?.value.toString(),
            'CartonCost': double.tryParse(row[5]?.value.toString() ?? '0'),
            'PalletCost': double.tryParse(row[6]?.value.toString() ?? '0'),
            'CornerCost': double.tryParse(row[7]?.value.toString() ?? '0'),
            'WaxCost': double.tryParse(row[8]?.value.toString() ?? '0'),
            'SheetCost': double.tryParse(row[9]?.value.toString() ?? '0'),
            'PalletCoverCost': double.tryParse(row[10]?.value.toString() ?? '0'),
            'ChamberCost': double.tryParse(row[11]?.value.toString() ?? '0'),
            'NetCost': double.tryParse(row[12]?.value.toString() ?? '0'),
            'GlueCost': double.tryParse(row[13]?.value.toString() ?? '0'),
            'AdhesiveTabCost': double.tryParse(row[14]?.value.toString() ?? '0'),
            'WagesCost': double.tryParse(row[15]?.value.toString() ?? '0'),
            'ShippingCost': double.tryParse(row[16]?.value.toString() ?? '0'),
            'UtilitiesCost': double.tryParse(row[17]?.value.toString() ?? '0'),
            'FixedCost': double.tryParse(row[18]?.value.toString() ?? '0'),
          };

          if (_checkOverlap(rowData)) {
            _showSnackBar('تنبيه: تداخل في التاريخ لـ ${rowData['Brand']}، سيتم التخطي', Colors.orange);
            continue;
          }

          rowsToUpload.add(rowData);
        }

        if (rowsToUpload.isNotEmpty) {
          await supabase.from('OtherCostRoles').upsert(
            rowsToUpload,
            onConflict: 'DateFrom, DateTo, Brand, CTNWeight, CTNType',
          );
          _showSnackBar('تمت معالجة ${rowsToUpload.length} سجل بنجاح', Colors.green);
          _fetchData();
        }
      } catch (e) {
        _showSnackBar('خطأ في معالجة الملف: $e', Colors.red);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _checkOverlap(Map<String, dynamic> newRow) {
    try {
      DateTime newFrom = DateTime.parse(newRow['DateFrom']);
      DateTime newTo = DateTime.parse(newRow['DateTo']);
      
      for (var existing in _data) {
        if (existing['Brand'] == newRow['Brand'] &&
            existing['CTNWeight'] == newRow['CTNWeight'] &&
            existing['CTNType'] == newRow['CTNType']) {
          
          DateTime exFrom = DateTime.parse(existing['DateFrom']);
          DateTime exTo = DateTime.parse(existing['DateTo']);

          if (newFrom == exFrom && newTo == exTo) continue;

          if (newFrom.isBefore(exTo.add(const Duration(days: 1))) && 
              exFrom.isBefore(newTo.add(const Duration(days: 1)))) {
            return true;
          }
        }
      }
    } catch (e) {
      return false; 
    }
    return false;
  }

  void _copyToClipboard() {
    String header = "DateFrom\tDateTo\tCTNType\tCTNWeight\tBrand\tCartonCost\tPalletCost\tCornerCost\tWaxCost\tSheetCost\tPalletCoverCost\tChamberCost\tNetCost\tGlueCost\tAdhesiveTabCost\tWagesCost\tShippingCost\tUtilitiesCost\tFixedCost\n";
    String body = _filteredData.map((row) {
      return "${row['DateFrom']}\t${row['DateTo']}\t${row['CTNType']}\t${row['CTNWeight']}\t${row['Brand']}\t${row['CartonCost']}\t${row['PalletCost']}\t${row['CornerCost']}\t${row['WaxCost']}\t${row['SheetCost']}\t${row['PalletCoverCost']}\t${row['ChamberCost']}\t${row['NetCost']}\t${row['GlueCost']}\t${row['AdhesiveTabCost']}\t${row['WagesCost']}\t${row['ShippingCost']}\t${row['UtilitiesCost']}\t${row['FixedCost']}";
    }).join("\n");

    Clipboard.setData(ClipboardData(text: header + body));
    _showSnackBar('تم نسخ الجدول بالكامل للحافظة', Colors.blue);
  }

  Future<void> _downloadTemplate() async {
    setState(() => _isLoading = true);
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      List<String> headers = [
        'DateFrom', 'DateTo', 'CTNType', 'CTNWeight', 'Brand',
        'CartonCost', 'PalletCost', 'CornerCost', 'WaxCost', 'SheetCost',
        'PalletCoverCost', 'ChamberCost', 'NetCost', 'GlueCost', 'AdhesiveTabCost',
        'WagesCost', 'ShippingCost', 'UtilitiesCost', 'FixedCost'
      ];

      sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());

      var fileBytes = excel.save();
      
      if (kIsWeb) {
        // منطق الويب: استخدام HTML Anchor للتنزيل
        // import 'package:universal_html/html.dart' as html;
        /*
        final content = base64Encode(fileBytes!);
        final anchor = html.AnchorElement(href: "data:application/octet-stream;charset=utf-16le;base64,$content")
          ..setAttribute("download", "OtherCostTemplate.xlsx")
          ..click();
        */
        _showSnackBar('يتم تنزيل الملف في المتصفح...', Colors.green);
      } else {
        // منطق الجوال: استخدام FilePicker لحفظ الملف في مكان يختاره المستخدم (التحميلات)
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'اختر مكان حفظ القالب',
          fileName: 'OtherCostTemplate.xlsx',
          type: FileType.custom,
          allowedExtensions: ['xlsx'],
          bytes: Uint8List.fromList(fileBytes!),
        );
        
        if (outputFile != null) {
          _showSnackBar('تم حفظ القالب بنجاح', Colors.green);
        }
      }
    } catch (e) {
      _showSnackBar('خطأ أثناء إنشاء القالب: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'Arial')), 
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة تكاليف الاخري'),
          actions: [
            IconButton(icon: const Icon(Icons.download), onPressed: _downloadTemplate, tooltip: 'تنزيل القالب'),
            IconButton(icon: const Icon(Icons.upload_file), onPressed: _importExcel, tooltip: 'رفع ملف'),
            IconButton(icon: const Icon(Icons.copy), onPressed: _copyToClipboard, tooltip: 'نسخ الكل'),
          ],
        ),
        body: Column(
          children: [
            _buildFilters(),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _filteredData.isEmpty 
                  ? const Center(child: Text('لا توجد بيانات للعرض'))
                  : _buildDataTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.grey[300]),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.blueGrey[50]),
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Text('من')),
              DataColumn(label: Text('إلى')),
              DataColumn(label: Text('الماركة')),
              DataColumn(label: Text('الوزن')),
              DataColumn(label: Text('النوع')),
              DataColumn(label: Text('ت. الكرتونة')),
              DataColumn(label: Text('ت. البالتة')),
              DataColumn(label: Text('ت. الزوايا')),
              DataColumn(label: Text('ت. الشمع')),
              DataColumn(label: Text('ت. الشيت')),
              DataColumn(label: Text('غطاء البالتة')),
              DataColumn(label: Text('ت. الغرفة')),
              DataColumn(label: Text('الصافي')),
              DataColumn(label: Text('ت. الغراء')),
              DataColumn(label: Text('ت. اللصق')),
              DataColumn(label: Text('الأجور')),
              DataColumn(label: Text('الشحن')),
              DataColumn(label: Text('المرافق')),
              DataColumn(label: Text('ت. ثابتة')),
            ],
            rows: _filteredData.map((item) => DataRow(cells: [
              DataCell(Text(item['DateFrom'] ?? '')),
              DataCell(Text(item['DateTo'] ?? '')),
              DataCell(Text(item['Brand'] ?? '')),
              DataCell(Text(item['CTNWeight'] ?? '')),
              DataCell(Text(item['CTNType'] ?? '')),
              DataCell(Text(item['CartonCost']?.toString() ?? '0')),
              DataCell(Text(item['PalletCost']?.toString() ?? '0')),
              DataCell(Text(item['CornerCost']?.toString() ?? '0')),
              DataCell(Text(item['WaxCost']?.toString() ?? '0')),
              DataCell(Text(item['SheetCost']?.toString() ?? '0')),
              DataCell(Text(item['PalletCoverCost']?.toString() ?? '0')),
              DataCell(Text(item['ChamberCost']?.toString() ?? '0')),
              DataCell(Text(item['NetCost']?.toString() ?? '0')),
              DataCell(Text(item['GlueCost']?.toString() ?? '0')),
              DataCell(Text(item['AdhesiveTabCost']?.toString() ?? '0')),
              DataCell(Text(item['WagesCost']?.toString() ?? '0')),
              DataCell(Text(item['ShippingCost']?.toString() ?? '0')),
              DataCell(Text(item['UtilitiesCost']?.toString() ?? '0')),
              DataCell(Text(item['FixedCost']?.toString() ?? '0')),
            ])).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          _filterDropdown('الماركة', _selectedBrand, _brands, (val) => setState(() { _selectedBrand = val!; _applyFilters(); })),
          const SizedBox(width: 8),
          _filterDropdown('الوزن', _selectedWeight, _weights, (val) => setState(() { _selectedWeight = val!; _applyFilters(); })),
          const SizedBox(width: 8),
          _filterDropdown('النوع', _selectedType, _types, (val) => setState(() { _selectedType = val!; _applyFilters(); })),
        ],
      ),
    );
  }

  Widget _filterDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label, 
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5)
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:excel/excel.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// // استيراد خاص للويب للتعامل مع التحميل المباشر
// import 'dart:html' as html; 

// class OtherCostRolesScreen extends StatefulWidget {
//   const OtherCostRolesScreen({super.key});

//   @override
//   State<OtherCostRolesScreen> createState() => _OtherCostRolesScreenState();
// }

// class _OtherCostRolesScreenState extends State<OtherCostRolesScreen> {
//   final SupabaseClient supabase = Supabase.instance.client;
//   List<Map<String, dynamic>> _data = [];
//   List<Map<String, dynamic>> _filteredData = [];
//   bool _isLoading = false;

//   String _selectedBrand = 'All';
//   String _selectedWeight = 'All';
//   String _selectedType = 'All';

//   List<String> _brands = ['All'];
//   List<String> _weights = ['All'];
//   List<String> _types = ['All'];

//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }

//   Future<void> _fetchData() async {
//     setState(() => _isLoading = true);
//     try {
//       final response = await supabase
//           .from('OtherCostRoles')
//           .select()
//           .order('DateFrom', ascending: false);
      
//       final List<Map<String, dynamic>> fetchedData = List<Map<String, dynamic>>.from(response);
      
//       setState(() {
//         _data = fetchedData;
//         _filteredData = fetchedData;
//         _updateFilters();
//         _isLoading = false;
//       });
//     } catch (e) {
//       _showSnackBar('خطأ في جلب البيانات: $e', Colors.red);
//       setState(() => _isLoading = false);
//     }
//   }

//   void _updateFilters() {
//     _brands = ['All', ..._data.map((e) => e['Brand']?.toString() ?? '').toSet().where((e) => e.isNotEmpty)];
//     _weights = ['All', ..._data.map((e) => e['CTNWeight']?.toString() ?? '').toSet().where((e) => e.isNotEmpty)];
//     _types = ['All', ..._data.map((e) => e['CTNType']?.toString() ?? '').toSet().where((e) => e.isNotEmpty)];
//   }

//   void _applyFilters() {
//     setState(() {
//       _filteredData = _data.where((item) {
//         final brandMatch = _selectedBrand == 'All' || item['Brand'] == _selectedBrand;
//         final weightMatch = _selectedWeight == 'All' || item['CTNWeight'] == _selectedWeight;
//         final typeMatch = _selectedType == 'All' || item['CTNType'] == _selectedType;
//         return brandMatch && weightMatch && typeMatch;
//       }).toList();
//     });
//   }

//   // دالة لتصحيح النصوص العربية المقلوبة في الـ PDF
//   String _fixArabic(String text) {
//     // مكتبة pdf تدعم العرض من اليمين لليسار إذا تم تمرير textDirection
//     // ولكن أحياناً في بعض البيئات نحتاج لضمان ربط الحروف
//     return text; 
//   }

//   // دالة توليد الـ PDF المحدثة
//   Future<Uint8List> _generatePdf(PdfPageFormat format) async {
//     final pdf = pw.Document();
    
//     // تحميل الخطوط التي تدعم العربية بشكل صحيح
//     final font = await PdfGoogleFonts.cairoRegular();
//     final boldFont = await PdfGoogleFonts.cairoBold();

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: format,
//         orientation: pw.PageOrientation.landscape,
//         theme: pw.ThemeData.withFont(
//           base: font,
//           bold: boldFont,
//         ),
//         // تحديد اتجاه النص العام للصفحة
//         textDirection: pw.TextDirection.rtl,
//         build: (pw.Context context) {
//           return [
//             pw.Header(
//               level: 0,
//               child: pw.Text('تقرير تكاليف الأدوار الأخرى', 
//                 style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
//                 textDirection: pw.TextDirection.rtl),
//             ),
//             pw.SizedBox(height: 15),
//             pw.TableHelper.fromTextArray(
//               headers: [
//                 'من', 'إلى', 'الماركة', 'الوزن', 'النوع', 'كرتونة', 'بالتة', 'زوايا', 'شمع', 'شيت', 'غطاء', 'غرفة', 'الصافي', 'غراء', 'لصق', 'أجور', 'شحن', 'مرافق', 'ثابتة'
//               ],
//               data: _filteredData.map((item) => [
//                 item['DateFrom'] ?? '',
//                 item['DateTo'] ?? '',
//                 item['Brand'] ?? '',
//                 item['CTNWeight'] ?? '',
//                 item['CTNType'] ?? '',
//                 item['CartonCost']?.toString() ?? '0',
//                 item['PalletCost']?.toString() ?? '0',
//                 item['CornerCost']?.toString() ?? '0',
//                 item['WaxCost']?.toString() ?? '0',
//                 item['SheetCost']?.toString() ?? '0',
//                 item['PalletCoverCost']?.toString() ?? '0',
//                 item['ChamberCost']?.toString() ?? '0',
//                 item['NetCost']?.toString() ?? '0',
//                 item['GlueCost']?.toString() ?? '0',
//                 item['AdhesiveTabCost']?.toString() ?? '0',
//                 item['WagesCost']?.toString() ?? '0',
//                 item['ShippingCost']?.toString() ?? '0',
//                 item['UtilitiesCost']?.toString() ?? '0',
//                 item['FixedCost']?.toString() ?? '0',
//               ]).toList(),
//               headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
//               cellStyle: const pw.TextStyle(fontSize: 8),
//               headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
//               cellAlignment: pw.Alignment.center,
//               // التأكيد على اتجاه الجدول من اليمين لليسار
//               tableDirection: pw.TextDirection.rtl,
//             ),
//           ];
//         },
//       ),
//     );

//     return pdf.save();
//   }

//   // تحميل ملف PDF
//   Future<void> _downloadPdf() async {
//     setState(() => _isLoading = true);
//     try {
//       final pdfBytes = await _generatePdf(PdfPageFormat.a4.landscape);
      
//       final blob = html.Blob([pdfBytes], 'application/pdf');
//       final url = html.Url.createObjectUrlFromBlob(blob);
//       final anchor = html.AnchorElement(href: url)
//         ..setAttribute("download", "Other_Costs_Report_${DateTime.now().millisecondsSinceEpoch}.pdf")
//         ..click();
      
//       html.Url.revokeObjectUrl(url);
//       _showSnackBar('تم توليد التقرير وتحميله بنجاح', Colors.green);
//     } catch (e) {
//       _showSnackBar('خطأ أثناء توليد الملف: $e', Colors.red);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _importExcel() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['xlsx'],
//       withData: true,
//     );

//     if (result != null) {
//       setState(() => _isLoading = true);
//       try {
//         Uint8List? bytes = result.files.single.bytes;
//         if (bytes == null) throw Exception("تعذر قراءة محتوى الملف");

//         var excel = Excel.decodeBytes(bytes);
//         var table = excel.tables[excel.tables.keys.first];
//         if (table == null) return;

//         List<Map<String, dynamic>> rowsToUpload = [];
//         for (var i = 1; i < table.maxRows; i++) {
//           var row = table.rows[i];
//           if (row.isEmpty || row[0] == null) continue;

//           final Map<String, dynamic> rowData = {
//             'DateFrom': row[0]?.value.toString(),
//             'DateTo': row[1]?.value.toString(),
//             'CTNType': row[2]?.value.toString(),
//             'CTNWeight': row[3]?.value.toString(),
//             'Brand': row[4]?.value.toString(),
//             'CartonCost': double.tryParse(row[5]?.value.toString() ?? '0'),
//             'PalletCost': double.tryParse(row[6]?.value.toString() ?? '0'),
//             'CornerCost': double.tryParse(row[7]?.value.toString() ?? '0'),
//             'WaxCost': double.tryParse(row[8]?.value.toString() ?? '0'),
//             'SheetCost': double.tryParse(row[9]?.value.toString() ?? '0'),
//             'PalletCoverCost': double.tryParse(row[10]?.value.toString() ?? '0'),
//             'ChamberCost': double.tryParse(row[11]?.value.toString() ?? '0'),
//             'NetCost': double.tryParse(row[12]?.value.toString() ?? '0'),
//             'GlueCost': double.tryParse(row[13]?.value.toString() ?? '0'),
//             'AdhesiveTabCost': double.tryParse(row[14]?.value.toString() ?? '0'),
//             'WagesCost': double.tryParse(row[15]?.value.toString() ?? '0'),
//             'ShippingCost': double.tryParse(row[16]?.value.toString() ?? '0'),
//             'UtilitiesCost': double.tryParse(row[17]?.value.toString() ?? '0'),
//             'FixedCost': double.tryParse(row[18]?.value.toString() ?? '0'),
//           };
//           rowsToUpload.add(rowData);
//         }

//         if (rowsToUpload.isNotEmpty) {
//           await supabase.from('OtherCostRoles').upsert(rowsToUpload);
//           _showSnackBar('تمت المعالجة بنجاح', Colors.green);
//           _fetchData();
//         }
//       } catch (e) {
//         _showSnackBar('خطأ: $e', Colors.red);
//       } finally {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   void _copyToClipboard() {
//     String header = "DateFrom\tDateTo\tCTNType\tCTNWeight\tBrand\tCartonCost\tPalletCost\tCornerCost\tWaxCost\tSheetCost\tPalletCoverCost\tChamberCost\tNetCost\tGlueCost\tAdhesiveTabCost\tWagesCost\tShippingCost\tUtilitiesCost\tFixedCost\n";
//     String body = _filteredData.map((row) {
//       return "${row['DateFrom']}\t${row['DateTo']}\t${row['CTNType']}\t${row['CTNWeight']}\t${row['Brand']}\t${row['CartonCost']}\t${row['PalletCost']}\t${row['CornerCost']}\t${row['WaxCost']}\t${row['SheetCost']}\t${row['PalletCoverCost']}\t${row['ChamberCost']}\t${row['NetCost']}\t${row['GlueCost']}\t${row['AdhesiveTabCost']}\t${row['WagesCost']}\t${row['ShippingCost']}\t${row['UtilitiesCost']}\t${row['FixedCost']}";
//     }).join("\n");

//     Clipboard.setData(ClipboardData(text: header + body));
//     _showSnackBar('تم نسخ الجدول بالكامل', Colors.blue);
//   }

//   void _showSnackBar(String message, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message, textAlign: TextAlign.right), backgroundColor: color, behavior: SnackBarBehavior.floating),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('إدارة تكاليف الاخري'),
//         actions: [
//           IconButton(icon: const Icon(Icons.picture_as_pdf), onPressed: _downloadPdf, tooltip: 'تحميل تقرير PDF'),
//           IconButton(icon: const Icon(Icons.upload_file), onPressed: _importExcel, tooltip: 'رفع ملف'),
//           IconButton(icon: const Icon(Icons.copy), onPressed: _copyToClipboard, tooltip: 'نسخ الكل'),
//         ],
//       ),
//       body: Column(
//         children: [
//           _buildFilters(),
//           Expanded(
//             child: _isLoading 
//               ? const Center(child: CircularProgressIndicator())
//               : _filteredData.isEmpty 
//                 ? const Center(child: Text('لا توجد بيانات للعرض'))
//                 : _buildDataTable(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDataTable() {
//     return Theme(
//       data: Theme.of(context).copyWith(dividerColor: Colors.grey[300]),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.vertical,
//         child: SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: DataTable(
//             headingRowColor: MaterialStateProperty.all(Colors.blueGrey[50]),
//             columnSpacing: 15,
//             horizontalMargin: 10,
//             columns: const [
//               DataColumn(label: Text('من')),
//               DataColumn(label: Text('إلى')),
//               DataColumn(label: Text('الماركة')),
//               DataColumn(label: Text('الوزن')),
//               DataColumn(label: Text('النوع')),
//               DataColumn(label: Text('ت. كرتونة')),
//               DataColumn(label: Text('ت. البالتة')),
//               DataColumn(label: Text('ت. الزوايا')),
//               DataColumn(label: Text('ت. الشمع')),
//               DataColumn(label: Text('ت. الشيت')),
//               DataColumn(label: Text('غطاء البالتة')),
//               DataColumn(label: Text('ت. الغرفة')),
//               DataColumn(label: Text('الصافي')),
//               DataColumn(label: Text('ت. الغراء')),
//               DataColumn(label: Text('ت. اللصق')),
//               DataColumn(label: Text('الأجور')),
//               DataColumn(label: Text('الشحن')),
//               DataColumn(label: Text('المرافق')),
//               DataColumn(label: Text('ت. ثابتة')),
//             ],
//             rows: _filteredData.map((item) => DataRow(cells: [
//               DataCell(Text(item['DateFrom'] ?? '')),
//               DataCell(Text(item['DateTo'] ?? '')),
//               DataCell(Text(item['Brand'] ?? '')),
//               DataCell(Text(item['CTNWeight'] ?? '')),
//               DataCell(Text(item['CTNType'] ?? '')),
//               DataCell(Text(item['CartonCost']?.toString() ?? '0')),
//               DataCell(Text(item['PalletCost']?.toString() ?? '0')),
//               DataCell(Text(item['CornerCost']?.toString() ?? '0')),
//               DataCell(Text(item['WaxCost']?.toString() ?? '0')),
//               DataCell(Text(item['SheetCost']?.toString() ?? '0')),
//               DataCell(Text(item['PalletCoverCost']?.toString() ?? '0')),
//               DataCell(Text(item['ChamberCost']?.toString() ?? '0')),
//               DataCell(Text(item['NetCost']?.toString() ?? '0', style: const TextStyle(fontWeight: FontWeight.bold))),
//               DataCell(Text(item['GlueCost']?.toString() ?? '0')),
//               DataCell(Text(item['AdhesiveTabCost']?.toString() ?? '0')),
//               DataCell(Text(item['WagesCost']?.toString() ?? '0')),
//               DataCell(Text(item['ShippingCost']?.toString() ?? '0')),
//               DataCell(Text(item['UtilitiesCost']?.toString() ?? '0')),
//               DataCell(Text(item['FixedCost']?.toString() ?? '0')),
//             ])).toList(),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFilters() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         children: [
//           _filterDropdown('الماركة', _selectedBrand, _brands, (val) => setState(() { _selectedBrand = val!; _applyFilters(); })),
//           const SizedBox(width: 8),
//           _filterDropdown('الوزن', _selectedWeight, _weights, (val) => setState(() { _selectedWeight = val!; _applyFilters(); })),
//           const SizedBox(width: 8),
//           _filterDropdown('النوع', _selectedType, _types, (val) => setState(() { _selectedType = val!; _applyFilters(); })),
//         ],
//       ),
//     );
//   }

//   Widget _filterDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
//     return Expanded(
//       child: DropdownButtonFormField<String>(
//         value: value,
//         isExpanded: true,
//         decoration: InputDecoration(
//           labelText: label, 
//           border: const OutlineInputBorder(),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5)
//         ),
//         items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)))).toList(),
//         onChanged: onChanged,
//       ),
//     );
//   }
// }
// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import 'package:excel/excel.dart';
// // import 'package:file_picker/file_picker.dart';
// // import 'package:pdf/pdf.dart';
// // import 'package:pdf/widgets.dart' as pw;
// // import 'package:printing/printing.dart';
// // // استيراد خاص للويب للتعامل مع التحميل المباشر
// // import 'dart:html' as html; 

// // class OtherCostRolesScreen extends StatefulWidget {
// //   const OtherCostRolesScreen({super.key});

// //   @override
// //   State<OtherCostRolesScreen> createState() => _OtherCostRolesScreenState();
// // }

// // class _OtherCostRolesScreenState extends State<OtherCostRolesScreen> {
// //   final SupabaseClient supabase = Supabase.instance.client;
// //   List<Map<String, dynamic>> _data = [];
// //   List<Map<String, dynamic>> _filteredData = [];
// //   bool _isLoading = false;

// //   String _selectedBrand = 'All';
// //   String _selectedWeight = 'All';
// //   String _selectedType = 'All';

// //   List<String> _brands = ['All'];
// //   List<String> _weights = ['All'];
// //   List<String> _types = ['All'];

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchData();
// //   }

// //   Future<void> _fetchData() async {
// //     setState(() => _isLoading = true);
// //     try {
// //       final response = await supabase
// //           .from('OtherCostRoles')
// //           .select()
// //           .order('DateFrom', ascending: false);
      
// //       final List<Map<String, dynamic>> fetchedData = List<Map<String, dynamic>>.from(response);
      
// //       setState(() {
// //         _data = fetchedData;
// //         _filteredData = fetchedData;
// //         _updateFilters();
// //         _isLoading = false;
// //       });
// //     } catch (e) {
// //       _showSnackBar('خطأ في جلب البيانات: $e', Colors.red);
// //       setState(() => _isLoading = false);
// //     }
// //   }

// //   void _updateFilters() {
// //     _brands = ['All', ..._data.map((e) => e['Brand']?.toString() ?? '').toSet().where((e) => e.isNotEmpty)];
// //     _weights = ['All', ..._data.map((e) => e['CTNWeight']?.toString() ?? '').toSet().where((e) => e.isNotEmpty)];
// //     _types = ['All', ..._data.map((e) => e['CTNType']?.toString() ?? '').toSet().where((e) => e.isNotEmpty)];
// //   }

// //   void _applyFilters() {
// //     setState(() {
// //       _filteredData = _data.where((item) {
// //         final brandMatch = _selectedBrand == 'All' || item['Brand'] == _selectedBrand;
// //         final weightMatch = _selectedWeight == 'All' || item['CTNWeight'] == _selectedWeight;
// //         final typeMatch = _selectedType == 'All' || item['CTNType'] == _selectedType;
// //         return brandMatch && weightMatch && typeMatch;
// //       }).toList();
// //     });
// //   }

// //   // دالة لتصحيح النصوص العربية المقلوبة في الـ PDF
// //   String _fixArabic(String text) {
// //     // مكتبة pdf تدعم العرض من اليمين لليسار إذا تم تمرير textDirection
// //     // ولكن أحياناً في بعض البيئات نحتاج لضمان ربط الحروف
// //     return text; 
// //   }

// //   // دالة توليد الـ PDF المحدثة
// //   Future<Uint8List> _generatePdf(PdfPageFormat format) async {
// //     final pdf = pw.Document();
    
// //     // تحميل الخطوط التي تدعم العربية بشكل صحيح
// //     final font = await PdfGoogleFonts.cairoRegular();
// //     final boldFont = await PdfGoogleFonts.cairoBold();

// //     pdf.addPage(
// //       pw.MultiPage(
// //         pageFormat: format,
// //         orientation: pw.PageOrientation.landscape,
// //         theme: pw.ThemeData.withFont(
// //           base: font,
// //           bold: boldFont,
// //         ),
// //         // تحديد اتجاه النص العام للصفحة
// //         textDirection: pw.TextDirection.rtl,
// //         build: (pw.Context context) {
// //           return [
// //             pw.Header(
// //               level: 0,
// //               child: pw.Text('تقرير تكاليف الأدوار الأخرى', 
// //                 style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
// //                 textDirection: pw.TextDirection.rtl),
// //             ),
// //             pw.SizedBox(height: 15),
// //             pw.TableHelper.fromTextArray(
// //               headers: [
// //                 'من', 'إلى', 'الماركة', 'الوزن', 'النوع', 'كرتونة', 'بالتة', 'زوايا', 'شمع', 'شيت', 'غطاء', 'غرفة', 'الصافي', 'غراء', 'لصق', 'أجور', 'شحن', 'مرافق', 'ثابتة'
// //               ],
// //               data: _filteredData.map((item) => [
// //                 item['DateFrom'] ?? '',
// //                 item['DateTo'] ?? '',
// //                 item['Brand'] ?? '',
// //                 item['CTNWeight'] ?? '',
// //                 item['CTNType'] ?? '',
// //                 item['CartonCost']?.toString() ?? '0',
// //                 item['PalletCost']?.toString() ?? '0',
// //                 item['CornerCost']?.toString() ?? '0',
// //                 item['WaxCost']?.toString() ?? '0',
// //                 item['SheetCost']?.toString() ?? '0',
// //                 item['PalletCoverCost']?.toString() ?? '0',
// //                 item['ChamberCost']?.toString() ?? '0',
// //                 item['NetCost']?.toString() ?? '0',
// //                 item['GlueCost']?.toString() ?? '0',
// //                 item['AdhesiveTabCost']?.toString() ?? '0',
// //                 item['WagesCost']?.toString() ?? '0',
// //                 item['ShippingCost']?.toString() ?? '0',
// //                 item['UtilitiesCost']?.toString() ?? '0',
// //                 item['FixedCost']?.toString() ?? '0',
// //               ]).toList(),
// //               headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
// //               cellStyle: const pw.TextStyle(fontSize: 8),
// //               headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
// //               cellAlignment: pw.Alignment.center,
// //               // التأكيد على اتجاه الجدول من اليمين لليسار
// //               tableDirection: pw.TextDirection.rtl,
// //             ),
// //           ];
// //         },
// //       ),
// //     );

// //     return pdf.save();
// //   }

// //   // تحميل ملف PDF
// //   Future<void> _downloadPdf() async {
// //     setState(() => _isLoading = true);
// //     try {
// //       final pdfBytes = await _generatePdf(PdfPageFormat.a4.landscape);
      
// //       final blob = html.Blob([pdfBytes], 'application/pdf');
// //       final url = html.Url.createObjectUrlFromBlob(blob);
// //       final anchor = html.AnchorElement(href: url)
// //         ..setAttribute("download", "Other_Costs_Report_${DateTime.now().millisecondsSinceEpoch}.pdf")
// //         ..click();
      
// //       html.Url.revokeObjectUrl(url);
// //       _showSnackBar('تم توليد التقرير وتحميله بنجاح', Colors.green);
// //     } catch (e) {
// //       _showSnackBar('خطأ أثناء توليد الملف: $e', Colors.red);
// //     } finally {
// //       setState(() => _isLoading = false);
// //     }
// //   }

// //   Future<void> _importExcel() async {
// //     FilePickerResult? result = await FilePicker.platform.pickFiles(
// //       type: FileType.custom,
// //       allowedExtensions: ['xlsx'],
// //       withData: true,
// //     );

// //     if (result != null) {
// //       setState(() => _isLoading = true);
// //       try {
// //         Uint8List? bytes = result.files.single.bytes;
// //         if (bytes == null) throw Exception("تعذر قراءة محتوى الملف");

// //         var excel = Excel.decodeBytes(bytes);
// //         var table = excel.tables[excel.tables.keys.first];
// //         if (table == null) return;

// //         List<Map<String, dynamic>> rowsToUpload = [];
// //         for (var i = 1; i < table.maxRows; i++) {
// //           var row = table.rows[i];
// //           if (row.isEmpty || row[0] == null) continue;

// //           final Map<String, dynamic> rowData = {
// //             'DateFrom': row[0]?.value.toString(),
// //             'DateTo': row[1]?.value.toString(),
// //             'CTNType': row[2]?.value.toString(),
// //             'CTNWeight': row[3]?.value.toString(),
// //             'Brand': row[4]?.value.toString(),
// //             'CartonCost': double.tryParse(row[5]?.value.toString() ?? '0'),
// //             'PalletCost': double.tryParse(row[6]?.value.toString() ?? '0'),
// //             'CornerCost': double.tryParse(row[7]?.value.toString() ?? '0'),
// //             'WaxCost': double.tryParse(row[8]?.value.toString() ?? '0'),
// //             'SheetCost': double.tryParse(row[9]?.value.toString() ?? '0'),
// //             'PalletCoverCost': double.tryParse(row[10]?.value.toString() ?? '0'),
// //             'ChamberCost': double.tryParse(row[11]?.value.toString() ?? '0'),
// //             'NetCost': double.tryParse(row[12]?.value.toString() ?? '0'),
// //             'GlueCost': double.tryParse(row[13]?.value.toString() ?? '0'),
// //             'AdhesiveTabCost': double.tryParse(row[14]?.value.toString() ?? '0'),
// //             'WagesCost': double.tryParse(row[15]?.value.toString() ?? '0'),
// //             'ShippingCost': double.tryParse(row[16]?.value.toString() ?? '0'),
// //             'UtilitiesCost': double.tryParse(row[17]?.value.toString() ?? '0'),
// //             'FixedCost': double.tryParse(row[18]?.value.toString() ?? '0'),
// //           };
// //           rowsToUpload.add(rowData);
// //         }

// //         if (rowsToUpload.isNotEmpty) {
// //           await supabase.from('OtherCostRoles').upsert(rowsToUpload);
// //           _showSnackBar('تمت المعالجة بنجاح', Colors.green);
// //           _fetchData();
// //         }
// //       } catch (e) {
// //         _showSnackBar('خطأ: $e', Colors.red);
// //       } finally {
// //         setState(() => _isLoading = false);
// //       }
// //     }
// //   }

// //   void _copyToClipboard() {
// //     String header = "DateFrom\tDateTo\tCTNType\tCTNWeight\tBrand\tCartonCost\tPalletCost\tCornerCost\tWaxCost\tSheetCost\tPalletCoverCost\tChamberCost\tNetCost\tGlueCost\tAdhesiveTabCost\tWagesCost\tShippingCost\tUtilitiesCost\tFixedCost\n";
// //     String body = _filteredData.map((row) {
// //       return "${row['DateFrom']}\t${row['DateTo']}\t${row['CTNType']}\t${row['CTNWeight']}\t${row['Brand']}\t${row['CartonCost']}\t${row['PalletCost']}\t${row['CornerCost']}\t${row['WaxCost']}\t${row['SheetCost']}\t${row['PalletCoverCost']}\t${row['ChamberCost']}\t${row['NetCost']}\t${row['GlueCost']}\t${row['AdhesiveTabCost']}\t${row['WagesCost']}\t${row['ShippingCost']}\t${row['UtilitiesCost']}\t${row['FixedCost']}";
// //     }).join("\n");

// //     Clipboard.setData(ClipboardData(text: header + body));
// //     _showSnackBar('تم نسخ الجدول بالكامل', Colors.blue);
// //   }

// //   void _showSnackBar(String message, Color color) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text(message, textAlign: TextAlign.right), backgroundColor: color, behavior: SnackBarBehavior.floating),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('إدارة تكاليف الاخري'),
// //         actions: [
// //           IconButton(icon: const Icon(Icons.picture_as_pdf), onPressed: _downloadPdf, tooltip: 'تحميل تقرير PDF'),
// //           IconButton(icon: const Icon(Icons.upload_file), onPressed: _importExcel, tooltip: 'رفع ملف'),
// //           IconButton(icon: const Icon(Icons.copy), onPressed: _copyToClipboard, tooltip: 'نسخ الكل'),
// //         ],
// //       ),
// //       body: Column(
// //         children: [
// //           _buildFilters(),
// //           Expanded(
// //             child: _isLoading 
// //               ? const Center(child: CircularProgressIndicator())
// //               : _filteredData.isEmpty 
// //                 ? const Center(child: Text('لا توجد بيانات للعرض'))
// //                 : _buildDataTable(),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildDataTable() {
// //     return Theme(
// //       data: Theme.of(context).copyWith(dividerColor: Colors.grey[300]),
// //       child: SingleChildScrollView(
// //         scrollDirection: Axis.vertical,
// //         child: SingleChildScrollView(
// //           scrollDirection: Axis.horizontal,
// //           child: DataTable(
// //             headingRowColor: MaterialStateProperty.all(Colors.blueGrey[50]),
// //             columnSpacing: 15,
// //             horizontalMargin: 10,
// //             columns: const [
// //               DataColumn(label: Text('من')),
// //               DataColumn(label: Text('إلى')),
// //               DataColumn(label: Text('الماركة')),
// //               DataColumn(label: Text('الوزن')),
// //               DataColumn(label: Text('النوع')),
// //               DataColumn(label: Text('ت. كرتونة')),
// //               DataColumn(label: Text('ت. البالتة')),
// //               DataColumn(label: Text('ت. الزوايا')),
// //               DataColumn(label: Text('ت. الشمع')),
// //               DataColumn(label: Text('ت. الشيت')),
// //               DataColumn(label: Text('غطاء البالتة')),
// //               DataColumn(label: Text('ت. الغرفة')),
// //               DataColumn(label: Text('الصافي')),
// //               DataColumn(label: Text('ت. الغراء')),
// //               DataColumn(label: Text('ت. اللصق')),
// //               DataColumn(label: Text('الأجور')),
// //               DataColumn(label: Text('الشحن')),
// //               DataColumn(label: Text('المرافق')),
// //               DataColumn(label: Text('ت. ثابتة')),
// //             ],
// //             rows: _filteredData.map((item) => DataRow(cells: [
// //               DataCell(Text(item['DateFrom'] ?? '')),
// //               DataCell(Text(item['DateTo'] ?? '')),
// //               DataCell(Text(item['Brand'] ?? '')),
// //               DataCell(Text(item['CTNWeight'] ?? '')),
// //               DataCell(Text(item['CTNType'] ?? '')),
// //               DataCell(Text(item['CartonCost']?.toString() ?? '0')),
// //               DataCell(Text(item['PalletCost']?.toString() ?? '0')),
// //               DataCell(Text(item['CornerCost']?.toString() ?? '0')),
// //               DataCell(Text(item['WaxCost']?.toString() ?? '0')),
// //               DataCell(Text(item['SheetCost']?.toString() ?? '0')),
// //               DataCell(Text(item['PalletCoverCost']?.toString() ?? '0')),
// //               DataCell(Text(item['ChamberCost']?.toString() ?? '0')),
// //               DataCell(Text(item['NetCost']?.toString() ?? '0', style: const TextStyle(fontWeight: FontWeight.bold))),
// //               DataCell(Text(item['GlueCost']?.toString() ?? '0')),
// //               DataCell(Text(item['AdhesiveTabCost']?.toString() ?? '0')),
// //               DataCell(Text(item['WagesCost']?.toString() ?? '0')),
// //               DataCell(Text(item['ShippingCost']?.toString() ?? '0')),
// //               DataCell(Text(item['UtilitiesCost']?.toString() ?? '0')),
// //               DataCell(Text(item['FixedCost']?.toString() ?? '0')),
// //             ])).toList(),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildFilters() {
// //     return Padding(
// //       padding: const EdgeInsets.all(8.0),
// //       child: Row(
// //         children: [
// //           _filterDropdown('الماركة', _selectedBrand, _brands, (val) => setState(() { _selectedBrand = val!; _applyFilters(); })),
// //           const SizedBox(width: 8),
// //           _filterDropdown('الوزن', _selectedWeight, _weights, (val) => setState(() { _selectedWeight = val!; _applyFilters(); })),
// //           const SizedBox(width: 8),
// //           _filterDropdown('النوع', _selectedType, _types, (val) => setState(() { _selectedType = val!; _applyFilters(); })),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _filterDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
// //     return Expanded(
// //       child: DropdownButtonFormField<String>(
// //         value: value,
// //         isExpanded: true,
// //         decoration: InputDecoration(
// //           labelText: label, 
// //           border: const OutlineInputBorder(),
// //           contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5)
// //         ),
// //         items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)))).toList(),
// //         onChanged: onChanged,
// //       ),
// //     );
// //   }
// // }