// // import 'package:flutter/material.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import 'package:intl/intl.dart'as intl;

// // class CropReportScreen extends StatefulWidget {
// //   const CropReportScreen({super.key});

// //   @override
// //   State<CropReportScreen> createState() => _CropReportScreenState();
// // }

// // class _CropReportScreenState extends State<CropReportScreen> {
// //   final supabase = Supabase.instance.client;

// //   DateTime? dateFrom;
// //   DateTime? dateTo;
// //   Map<String, dynamic>? selectedItem;
// //   List<Map<String, dynamic>> itemsList = [];
// //   bool isLoading = false;

// //   // نتائج التقارير
// //   List<dynamic> rawReport = [];
// //   List<dynamic> farzaReport = [];
// //   List<dynamic> productionReport = [];

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchItems();
// //   }

// //   // جلب قائمة الأصناف من الـ View
// //   Future<void> _fetchItems() async {
// //     try {
// //       final data = await supabase.from('station_items').select();
// //       setState(() {
// //         itemsList = List<Map<String, dynamic>>.from(data);
// //       });
// //     } catch (e) {
// //       _showError("خطأ في جلب الأصناف: $e");
// //     }
// //   }

// //   // جلب التقارير الثلاثة
// //   Future<void> _fetchReports() async {
// //     if (dateFrom == null || dateTo == null || selectedItem == null) {
// //       _showError("يرجى اختيار الفترة والصنف أولاً");
// //       return;
// //     }

// //     setState(() => isLoading = true);

// //     try {
// //       final dateFromStr = intl.DateFormat('yyyy-MM-dd').format(dateFrom!);
// //       final dateToStr = intl.DateFormat('yyyy-MM-dd').format(dateTo!);

// //       // استدعاء الدوال الثلاث في وقت واحد
// //       final results = await Future.wait([
// //         supabase.rpc('get_raw_report', params: {
// //           'p_date_from': dateFromStr,
// //           'p_date_to': dateToStr,
// //           'p_crop_name': selectedItem!['CropNameAr'],
// //         }),
// //         supabase.rpc('get_farza_report', params: {
// //           'p_date_from': dateFromStr,
// //           'p_date_to': dateToStr,
// //           'p_crop_name': selectedItem!['CropNameAr'],
// //         }),
// //         supabase.rpc('get_production_report', params: {
// //           'p_date_from': dateFromStr,
// //           'p_date_to': dateToStr,
// //           'p_crop_name': selectedItem!['Items'],
// //           'p_crop_class': null,
// //         }),
// //       ]);

// //       setState(() {
// //         rawReport = results[0] as List<dynamic>;
// //         farzaReport = results[1] as List<dynamic>;
// //         productionReport = results[2] as List<dynamic>;
// //       });
// //     } catch (e) {
// //       _showError("خطأ أثناء جلب التقارير: $e");
// //     } finally {
// //       setState(() => isLoading = false);
// //     }
// //   }

// //   void _showError(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text(message,)),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text("تقارير الأصناف"),
// //         centerTitle: true,
// //       ),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           children: [
// //             _buildFilters(),
// //             const SizedBox(height: 20),
// //             if (isLoading)
// //               const CircularProgressIndicator()
// //             else ...[
// //               _buildReportSection("1. تقرير المواد الخام", rawReport, isProduction: false),
// //               const SizedBox(height: 16),
// //               _buildReportSection("2. تقرير الفرزة", farzaReport, isProduction: false),
// //               const SizedBox(height: 16),
// //               _buildReportSection("3. تقرير الإنتاج", productionReport, isProduction: true),
// //             ],
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildFilters() {
// //     return Card(
// //       child: Padding(
// //         padding: const EdgeInsets.all(12.0),
// //         child: Column(
// //           children: [
// //             Row(
// //               children: [
// //                 Expanded(
// //                   child: ListTile(
// //                     title: const Text("من"),
// //                     subtitle: Text(dateFrom == null ? "اختر التاريخ" : intl.DateFormat('yyyy-MM-dd').format(dateFrom!)),
// //                     onTap: () async {
// //                       final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
// //                       if (picked != null) setState(() => dateFrom = picked);
// //                     },
// //                   ),
// //                 ),
// //                 Expanded(
// //                   child: ListTile(
// //                     title: const Text("إلى"),
// //                     subtitle: Text(dateTo == null ? "اختر التاريخ" : intl.DateFormat('yyyy-MM-dd').format(dateTo!)),
// //                     onTap: () async {
// //                       final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
// //                       if (picked != null) setState(() => dateTo = picked);
// //                     },
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             DropdownButtonFormField<Map<String, dynamic>>(
// //               decoration: const InputDecoration(labelText: "اختر الصنف"),
// //               items: itemsList.map((item) {
// //                 return DropdownMenuItem(
// //                   value: item,
// //                   child: Text(item['CropNameAr'] ?? ""),
// //                 );
// //               }).toList(),
// //               onChanged: (val) => setState(() => selectedItem = val),
// //             ),
// //             const SizedBox(height: 10),
// //             ElevatedButton(
// //               onPressed: _fetchReports,
// //               style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
// //               child: const Text("بحث جلب البيانات"),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildReportSection(String title, List<dynamic> data, {required bool isProduction}) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Padding(
// //           padding: const EdgeInsets.symmetric(vertical: 8.0),
// //           child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
// //         ),
// //         if (data.isEmpty)
// //           const Center(child: Text("لا توجد بيانات لهذا القسم"))
// //         else
// //           SingleChildScrollView(
// //             scrollDirection: Axis.horizontal,
// //             child: DataTable(
// //               headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
// //               columns: [
// //                 const DataColumn(label: Text("الصنف")),
// //                 if (isProduction) const DataColumn(label: Text("Class")),
// //                 const DataColumn(label: Text("الكمية")),
// //                 const DataColumn(label: Text("القيمة")),
// //                 const DataColumn(label: Text("المتوسط")),
// //               ],
// //               rows: data.map((row) {
// //                 return DataRow(cells: [
// //                   DataCell(Text(isProduction ? (row['crop_name'] ?? "") : (row['CropName'] ?? ""))),
// //                   if (isProduction) DataCell(Text(row['class'] ?? "")),
// //                   DataCell(Text(_format(isProduction ? row['net_weight'] : row['NetWeight']))),
// //                   DataCell(Text(_format(isProduction ? row['total_value'] : row['TotalValue']))),
// //                   DataCell(Text(_format(isProduction ? row['avg_price'] : row['AvgPrice']))),
// //                 ]);
// //               }).toList(),
// //             ),
// //           ),
// //       ],
// //     );
// //   }

// //   String _format(dynamic value) {
// //     if (value == null) return "0";
// //     return intl.NumberFormat("#,##0.00").format(value);
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:intl/intl.dart'as intl;

// class CropReportScreen extends StatefulWidget {
//   const CropReportScreen({super.key});

//   @override
//   State<CropReportScreen> createState() => _CropReportScreenState();
// }

// class _CropReportScreenState extends State<CropReportScreen> {
//   final supabase = Supabase.instance.client;

//   // تعريف خيار "الكل" كمتغير ثابت لضمان تطابق المرجع في الذاكرة
//   static final Map<String, dynamic> allItemsOption = {'Items': null, 'CropNameAr': 'الكل'};

//   DateTime? dateFrom = DateTime(2025, 12, 1);
//   DateTime? dateTo = DateTime.now();
  
//   // تعيين القيمة الافتراضية من المرجع الثابت
//   Map<String, dynamic>? selectedItem;
//   List<Map<String, dynamic>> itemsList = [];
//   bool isLoading = false;

//   // نتائج التقارير
//   List<dynamic> rawReport = [];
//   List<dynamic> farzaReport = [];
//   List<dynamic> productionReport = [];

//   @override
//   void initState() {
//     super.initState();
//     selectedItem = allItemsOption; // تهيئة العنصر المختار
//     itemsList = [allItemsOption];   // تهيئة القائمة بالخيار الافتراضي
//     _fetchItems();
//   }

//   Future<void> _fetchItems() async {
//     try {
//       final data = await supabase.from('station_items').select();
//       setState(() {
//         // إعادة بناء القائمة مع الحفاظ على مرجع "الكل" الثابت
//         itemsList = [allItemsOption];
//         itemsList.addAll(List<Map<String, dynamic>>.from(data));
//       });
//     } catch (e) {
//       _showError("خطأ في جلب الأصناف: $e");
//     }
//   }

//   Future<void> _fetchReports() async {
//     if (dateFrom == null || dateTo == null) {
//       _showError("يرجى اختيار الفترة أولاً");
//       return;
//     }

//     setState(() => isLoading = true);

//     try {
//       final dateFromStr = intl.DateFormat('yyyy-MM-dd').format(dateFrom!);
//       final dateToStr = intl.DateFormat('yyyy-MM-dd').format(dateTo!);

//       final results = await Future.wait([
//         supabase.rpc('get_raw_report', params: {
//           'p_date_from': dateFromStr,
//           'p_date_to': dateToStr,
//           'p_crop_name': selectedItem?['CropNameAr'] == 'الكل' ? null : selectedItem?['CropNameAr'],
//         }),
//         supabase.rpc('get_farza_report', params: {
//           'p_date_from': dateFromStr,
//           'p_date_to': dateToStr,
//           'p_crop_name': selectedItem?['CropNameAr'] == 'الكل' ? null : selectedItem?['CropNameAr'],
//         }),
//         supabase.rpc('get_production_report', params: {
//           'p_date_from': dateFromStr,
//           'p_date_to': dateToStr,
//           'p_crop_name': selectedItem?['Items'], 
//           'p_crop_class': null,
//         }),
//       ]);

//       setState(() {
//         rawReport = results[0] as List<dynamic>;
//         farzaReport = results[1] as List<dynamic>;
//         productionReport = results[2] as List<dynamic>;
//       });
//     } catch (e) {
//       _showError("خطأ أثناء جلب التقارير: $e");
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   double get _totalRawWeight {
//     if (rawReport.isEmpty) return 0;
//     return rawReport.fold(0.0, (sum, item) => sum + (item['NetWeight'] ?? 0.0));
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message, textDirection: TextDirection.rtl)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("تقارير الأصناف المتقدمة"),
//         centerTitle: true,
//       ),
//       body: Directionality(
//         textDirection: TextDirection.rtl,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               _buildFilters(),
//               const SizedBox(height: 20),
//               if (isLoading)
//                 const CircularProgressIndicator()
//               else ...[
//                 _buildReportSection("1. تقرير المواد الخام", rawReport, type: 'raw'),
//                 const SizedBox(height: 16),
//                 _buildReportSection("2. تقرير الفرزة", farzaReport, type: 'farza'),
//                 const SizedBox(height: 16),
//                 _buildReportSection("3. تقرير الإنتاج", productionReport, type: 'prod'),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFilters() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     icon: const Icon(Icons.calendar_today, size: 18),
//                     label: Text(dateFrom == null ? "من" : intl.DateFormat('yyyy-MM-dd').format(dateFrom!)),
//                     onPressed: () async {
//                       final picked = await showDatePicker(context: context, initialDate: dateFrom ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
//                       if (picked != null) setState(() => dateFrom = picked);
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     icon: const Icon(Icons.calendar_today, size: 18),
//                     label: Text(dateTo == null ? "إلى" : intl.DateFormat('yyyy-MM-dd').format(dateTo!)),
//                     onPressed: () async {
//                       final picked = await showDatePicker(context: context, initialDate: dateTo ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
//                       if (picked != null) setState(() => dateTo = picked);
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             DropdownButtonFormField<Map<String, dynamic>>(
//               value: selectedItem,
//               decoration: const InputDecoration(
//                 labelText: "اختيار الصنف",
//                 border: OutlineInputBorder(),
//                 contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               ),
//               // استخدام التحقق من القيمة لضمان مطابقة العنصر المختار حتى لو تغيرت القائمة
//               items: itemsList.map((item) {
//                 return DropdownMenuItem<Map<String, dynamic>>(
//                   value: item,
//                   child: Text(item['CropNameAr'] ?? ""),
//                 );
//               }).toList(),
//               onChanged: (val) => setState(() => selectedItem = val),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _fetchReports,
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 50),
//                 backgroundColor: Colors.blueAccent,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               child: const Text("تحديث البيانات", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildReportSection(String title, List<dynamic> data, {required String type}) {
//     double totalRaw = _totalRawWeight;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(8),
//           color: Colors.blueGrey[50],
//           child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
//         ),
//         if (data.isEmpty)
//           const Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Center(child: Text("لا توجد بيانات متاحة")),
//           )
//         else
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: DataTable(
//               headingRowHeight: 40,
//               columnSpacing: 25,
//               columns: [
//                 if (type == 'prod') const DataColumn(label: Text("Class")),
//                 const DataColumn(label: Text("الكمية")),
//                 const DataColumn(label: Text("القيمة")),
//                 const DataColumn(label: Text("المتوسط")),
//                 if (type != 'raw') const DataColumn(label: Text("النسبة %")),
//               ],
//               rows: data.map((row) {
//                 double currentWeight = (type == 'prod' ? row['net_weight'] : row['NetWeight']) ?? 0.0;
//                 double percentage = totalRaw > 0 ? (currentWeight / totalRaw) * 100 : 0.0;

//                 return DataRow(cells: [
//                   if (type == 'prod') DataCell(Text(row['class'] ?? "-")),
//                   DataCell(Text(_format(currentWeight))),
//                   DataCell(Text(_format(type == 'prod' ? row['total_value'] : row['TotalValue']))),
//                   DataCell(Text(_format(type == 'prod' ? row['avg_price'] : row['AvgPrice']))),
//                   if (type != 'raw') 
//                     DataCell(Text(
//                       "${percentage.toStringAsFixed(1)}%",
//                       style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
//                     )),
//                 ]);
//               }).toList(),
//             ),
//           ),
//       ],
//     );
//   }

//   String _format(dynamic value) {
//     if (value == null) return "0";
//     return intl.NumberFormat("#,##0.00").format(value);
//   }
// }
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart' as intl;

class CropReportScreen extends StatefulWidget {
  const CropReportScreen({super.key});

  @override
  State<CropReportScreen> createState() => _CropReportScreenState();
}

class _CropReportScreenState extends State<CropReportScreen> {
  final supabase = Supabase.instance.client;

  // تعريف خيار "الكل" كمتغير ثابت لضمان تطابق المرجع في الذاكرة
  static final Map<String, dynamic> allItemsOption = {'Items': null, 'CropNameAr': 'الكل'};

  DateTime? dateFrom = DateTime(2025, 12, 1);
  DateTime? dateTo = DateTime.now();
  
  // تعيين القيمة الافتراضية من المرجع الثابت
  Map<String, dynamic>? selectedItem;
  List<Map<String, dynamic>> itemsList = [];
  bool isLoading = false;

  // نتائج التقارير (بعد المعالجة والتجميع)
  List<dynamic> rawReport = [];
  List<dynamic> farzaReport = [];
  List<dynamic> productionReport = [];

  @override
  void initState() {
    super.initState();
    selectedItem = allItemsOption; // تهيئة العنصر المختار
    itemsList = [allItemsOption];   // تهيئة القائمة بالخيار الافتراضي
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    try {
      final data = await supabase.from('station_items').select();
      setState(() {
        itemsList = [allItemsOption];
        itemsList.addAll(List<Map<String, dynamic>>.from(data));
      });
    } catch (e) {
      _showError("خطأ في جلب الأصناف: $e");
    }
  }

  Future<void> _fetchReports() async {
    if (dateFrom == null || dateTo == null) {
      _showError("يرجى اختيار الفترة أولاً");
      return;
    }

    setState(() => isLoading = true);

    try {
      final dateFromStr = intl.DateFormat('yyyy-MM-dd').format(dateFrom!);
      final dateToStr = intl.DateFormat('yyyy-MM-dd').format(dateTo!);

      final results = await Future.wait([
        supabase.rpc('get_raw_report', params: {
          'p_date_from': dateFromStr,
          'p_date_to': dateToStr,
          'p_crop_name': selectedItem?['CropNameAr'] == 'الكل' ? null : selectedItem?['CropNameAr'],
        }),
        supabase.rpc('get_farza_report', params: {
          'p_date_from': dateFromStr,
          'p_date_to': dateToStr,
          'p_crop_name': selectedItem?['CropNameAr'] == 'الكل' ? null : selectedItem?['CropNameAr'],
        }),
        supabase.rpc('get_production_report', params: {
          'p_date_from': dateFromStr,
          'p_date_to': dateToStr,
          'p_crop_name': selectedItem?['Items'], 
          'p_crop_class': null,
        }),
      ]);

      _processData(results[0], results[1], results[2]);

    } catch (e) {
      _showError("خطأ أثناء جلب التقارير: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // دالة لمعالجة وتجميع البيانات عند اختيار "الكل"
  void _processData(dynamic raw, dynamic farza, dynamic prod) {
    List<dynamic> rawList = List.from(raw);
    List<dynamic> farzaList = List.from(farza);
    List<dynamic> prodList = List.from(prod);

    if (selectedItem?['CropNameAr'] == 'الكل') {
      // 1. تجميع الخام في سطر واحد
      if (rawList.isNotEmpty) {
        double totalWeight = rawList.fold(0.0, (sum, item) => sum + (item['NetWeight'] ?? 0.0));
        double totalValue = rawList.fold(0.0, (sum, item) => sum + (item['TotalValue'] ?? 0.0));
        rawList = [{
          'NetWeight': totalWeight,
          'TotalValue': totalValue,
          'AvgPrice': totalWeight > 0 ? totalValue / totalWeight : 0.0,
        }];
      }

      // 2. تجميع الفرزة في سطر واحد
      if (farzaList.isNotEmpty) {
        double totalWeight = farzaList.fold(0.0, (sum, item) => sum + (item['NetWeight'] ?? 0.0));
        double totalValue = farzaList.fold(0.0, (sum, item) => sum + (item['TotalValue'] ?? 0.0));
        farzaList = [{
          'NetWeight': totalWeight,
          'TotalValue': totalValue,
          'AvgPrice': totalWeight > 0 ? totalValue / totalWeight : 0.0,
        }];
      }

      // 3. تجميع الإنتاج حسب الكلاس (كل كلاس في سطر)
      Map<String, Map<String, dynamic>> groupedProd = {};
      for (var item in prodList) {
        String className = item['class'] ?? "غير محدد";
        if (!groupedProd.containsKey(className)) {
          groupedProd[className] = {
            'class': className,
            'net_weight': 0.0,
            'total_value': 0.0,
          };
        }
        groupedProd[className]!['net_weight'] += (item['net_weight'] ?? 0.0);
        groupedProd[className]!['total_value'] += (item['total_value'] ?? 0.0);
      }
      
      prodList = groupedProd.values.map((item) {
        double weight = item['net_weight'];
        double value = item['total_value'];
        return {
          'class': item['class'],
          'net_weight': weight,
          'total_value': value,
          'avg_price': weight > 0 ? value / weight : 0.0,
        };
      }).toList();
    }

    setState(() {
      rawReport = rawList;
      farzaReport = farzaList;
      productionReport = prodList;
    });
  }

  double get _totalRawWeight {
    if (rawReport.isEmpty) return 0;
    return rawReport.fold(0.0, (sum, item) => sum + (item['NetWeight'] ?? 0.0));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, textDirection: TextDirection.rtl)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("تقارير الأصناف المتقدمة"),
          centerTitle: true,
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildFilters(),
                const SizedBox(height: 20),
                if (isLoading)
                  const CircularProgressIndicator()
                else ...[
                  _buildReportSection("1. تقرير المواد الخام", rawReport, type: 'raw'),
                  const SizedBox(height: 16),
                  _buildReportSection("2. تقرير الفرزة", farzaReport, type: 'farza'),
                  const SizedBox(height: 16),
                  _buildReportSection("3. تقرير الإنتاج", productionReport, type: 'prod'),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(dateFrom == null ? "من" : intl.DateFormat('yyyy-MM-dd').format(dateFrom!)),
                    onPressed: () async {
                      final picked = await showDatePicker(context: context, initialDate: dateFrom ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                      if (picked != null) setState(() => dateFrom = picked);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(dateTo == null ? "إلى" : intl.DateFormat('yyyy-MM-dd').format(dateTo!)),
                    onPressed: () async {
                      final picked = await showDatePicker(context: context, initialDate: dateTo ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                      if (picked != null) setState(() => dateTo = picked);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Map<String, dynamic>>(
              value: selectedItem,
              decoration: const InputDecoration(
                labelText: "اختيار الصنف",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: itemsList.map((item) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: item,
                  child: Text(item['CropNameAr'] ?? ""),
                );
              }).toList(),
              onChanged: (val) => setState(() => selectedItem = val),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchReports,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("تحديث البيانات", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportSection(String title, List<dynamic> data, {required String type}) {
    double totalRaw = _totalRawWeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          color: Colors.blueGrey[50],
          child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        ),
        if (data.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text("لا توجد بيانات متاحة")),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 40,
              columnSpacing: 25,
              columns: [
                if (type == 'prod') const DataColumn(label: Text("Class")),
                const DataColumn(label: Text("الكمية")),
                const DataColumn(label: Text("المتوسط")), // ترتيب جديد
                const DataColumn(label: Text("القيمة")),  // ترتيب جديد
                if (type != 'raw') const DataColumn(label: Text("النسبة %")),
              ],
              rows: data.map((row) {
                double currentWeight = (type == 'prod' ? row['net_weight'] : row['NetWeight']) ?? 0.0;
                double percentage = totalRaw > 0 ? (currentWeight / totalRaw) * 100 : 0.0;
                double currentAvg = (type == 'prod' ? row['avg_price'] : row['AvgPrice']) ?? 0.0;
                double currentValue = (type == 'prod' ? row['total_value'] : row['TotalValue']) ?? 0.0;

                return DataRow(cells: [
                  if (type == 'prod') DataCell(Text(row['class'] ?? "-")),
                  DataCell(Text(_format(currentWeight))),
                  DataCell(Text(_format(currentAvg))), // ترتيب جديد
                  DataCell(Text(_format(currentValue))), // ترتيب جديد
                  if (type != 'raw') 
                    DataCell(Text(
                      "${percentage.toStringAsFixed(1)}%",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                    )),
                ]);
              }).toList(),
            ),
          ),
      ],
    );
  }

  String _format(dynamic value) {
    if (value == null) return "0";
    return intl.NumberFormat("#,##0.00").format(value);
  }
}