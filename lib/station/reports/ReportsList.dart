// // import 'package:flutter/material.dart';
// // import 'package:manageon/station/reports/ColdStorReport.dart';
// // import 'package:manageon/station/reports/FarzaReport.dart';
// // import 'package:manageon/station/reports/PackingListReport.dart';
// // import 'package:manageon/station/reports/ProductionReport.dart';
// // import 'package:manageon/station/reports/RawReport.dart';
// // import 'package:manageon/station/reports/SalesInvoiceReport.dart';

// // class ReportsDashboardScreen extends StatelessWidget {


// //   const ReportsDashboardScreen({super.key, });

// //   @override
// //   Widget build(BuildContext context) {
// //     final items = [
// //       _ReportItem('تقرير الفرزة', Icons.rule, 'sorting'),
// //       _ReportItem('تقرير الإنتاج', Icons.factory, 'production'),
// //       _ReportItem('تقرير الخام', Icons.inventory_2, 'raw'),
// //       _ReportItem('تقرير المبيعات', Icons.point_of_sale, 'sales'),
// //       _ReportItem('رصيد الثلاجة', Icons.ac_unit, 'fridge'),
// //       _ReportItem('تقرير المشحون', Icons.local_shipping, 'shipped'),
// //     ];

// //     return Scaffold(
// //       backgroundColor: const Color(0xffF3F5F9),
// //       body: SafeArea(
// //         child: Padding(
// //           padding: const EdgeInsets.all(16),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               const Text(
// //                 'التقارير',
// //                 style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
// //               ),
// //               const SizedBox(height: 16),
// //               Expanded(
// //                 child: GridView.builder(
// //                   itemCount: items.length,
// //                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //                     crossAxisCount: 4,
// //                     crossAxisSpacing: 16,
// //                     mainAxisSpacing: 16,
// //                     childAspectRatio: 1.1,
// //                   ),
// //                   itemBuilder: (context, index) {
// //                     final item = items[index];
// //                     return _ReportCard(
// //                       item: item,
// //                    onTap: () {
// //   Widget screen;

// //   switch (item.key) {
// //     case 'sorting':
// //       screen = const FarzaReportScreen();
// //       break;
// //     case 'production':
// //       screen = ProductionReportScreen();
// //       break;
// //     case 'raw':
// //       screen = const RawReportScreen();
// //       break;
// //     case 'sales':
// //      screen = SalesInvoiceReportScreen();
// //       break;
// //     case 'fridge':
// //       screen =ColdStorReportScreen();
// //       break;
// //     case 'shipped':
// //       screen =PackingListReportScreen();
// //       break;
// //     default:
// //       return;
// //   }

// //   Navigator.push(
// //     context,
// //     MaterialPageRoute(builder: (_) => screen),
// //   );
// // },

// //                     );
// //                   },
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class _ReportItem {
// //   final String title;
// //   final IconData icon;
// //   final String key;

// //   _ReportItem(this.title, this.icon, this.key);
// // }

// // class _ReportCard extends StatelessWidget {
// //   final _ReportItem item;
// //   final VoidCallback onTap;

// //   const _ReportCard({required this.item, required this.onTap});

// //   @override
// //   Widget build(BuildContext context) {
// //     return InkWell(
// //       borderRadius: BorderRadius.circular(20),
// //       onTap: onTap,
// //       child: Container(
// //         decoration: BoxDecoration(
// //           gradient: const LinearGradient(
// //             colors: [Color(0xffFFFFFF), Color(0xffE9EEF6)],
// //             begin: Alignment.topLeft,
// //             end: Alignment.bottomRight,
// //           ),
// //           borderRadius: BorderRadius.circular(20),
// //           boxShadow: const [
// //             BoxShadow(
// //               color: Colors.black12,
// //               blurRadius: 10,
// //               offset: Offset(0, 6),
// //             ),
// //           ],
// //         ),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             CircleAvatar(
// //               radius: 30,
// //               backgroundColor: Colors.blue.withOpacity(0.1),
// //               child: Icon(item.icon, size: 32, color: Colors.blueGrey),
// //             ),
// //             const SizedBox(height: 12),
// //             Text(
// //               item.title,
// //               textAlign: TextAlign.center,
// //               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';

// // ملاحظة: تأكد من استيراد الملفات الخاصة بك هنا كما في الكود الأصلي
// // import 'package:manageon/station/reports/...';

// class ReportsDashboardScreen extends StatelessWidget {
//   const ReportsDashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // قائمة البيانات مع ألوان مخصصة لكل تقرير لإعطاء هوية بصرية
//     final items = [
//       _ReportItem('تقرير الفرزة', Icons.rule_rounded, 'sorting', Colors.orange),
//       _ReportItem('تقرير الإنتاج', Icons.precision_manufacturing_rounded, 'production', Colors.blue),
//       _ReportItem('تقرير الخام', Icons.inventory_2_rounded, 'raw', Colors.green),
//       _ReportItem('تقرير المبيعات', Icons.analytics_rounded, 'sales', Colors.purple),
//       _ReportItem('رصيد الثلاجة', Icons.ac_unit_rounded, 'fridge', Colors.cyan),
//       _ReportItem('تقرير المشحون', Icons.local_shipping_rounded, 'shipped', Colors.indigo),
//     ];

//     // تحديد عدد الأعمدة بناءً على عرض الشاشة لضمان الاحترافية على التابلت والموبايل
//     double screenWidth = MediaQuery.of(context).size.width;
//     int crossAxisCount = screenWidth > 900 ? 4 : (screenWidth > 600 ? 3 : 2);

//     return Scaffold(
//       backgroundColor: const Color(0xffF8FAFC), // لون خلفية هادئ ومريح للعين
//       body: CustomScrollView(
//         slivers: [
//           // Header جذاب مع تصميم منحني
//           SliverAppBar(
//             expandedHeight: 120.0,
//             floating: false,
//             pinned: true,
//             elevation: 0,
//             backgroundColor: Colors.white,
//             flexibleSpace: FlexibleSpaceBar(
//               titlePadding: const EdgeInsetsDirectional.only(start: 24, bottom: 16),
//               centerTitle: false,
//               title: const Text(
//                 'مركز التقارير',
//                 style: TextStyle(
//                   color: Color(0xff1E293B),
//                   fontWeight: FontWeight.bold,
//                   fontSize: 22,
//                 ),
//               ),
//             ),
//           ),
          
//           // محتوى الشبكة (Grid)
//           SliverPadding(
//             padding: const EdgeInsets.all(24),
//             sliver: SliverGrid(
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: crossAxisCount,
//                 crossAxisSpacing: 20,
//                 mainAxisSpacing: 20,
//                 childAspectRatio: 1.0,
//               ),
//               delegate: SliverChildBuilderDelegate(
//                 (context, index) {
//                   final item = items[index];
//                   return _ReportCard(
//                     item: item,
//                     onTap: () => _navigateToReport(context, item.key),
//                   );
//                 },
//                 childCount: items.length,
//               ),
//             ),
//           ),
          
//           // قسم إضافي اختياري (إحصائيات سريعة أو تذييل)
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.withOpacity(0.05),
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: Colors.blue.withOpacity(0.1)),
//                 ),
//                 child: const Row(
//                   children: [
//                     Icon(Icons.info_outline, color: Colors.blue),
//                     SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         'يتم تحديث جميع التقارير لحظياً بناءً على البيانات المدخلة في النظام.',
//                         style: TextStyle(color: Colors.blueGrey, fontSize: 13),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   void _navigateToReport(BuildContext context, String key) {
//     // منطق التنقل الخاص بك (يبقى كما هو مع تحسين الهيكل)
//     Widget? screen;
//     switch (key) {
//       case 'sorting': /* screen = const FarzaReportScreen(); */ break;
//       case 'production': /* screen = ProductionReportScreen(); */ break;
//       // ... باقي الحالات
//     }

//     if (screen != null) {
//       Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
//     }
//   }
// }

// class _ReportItem {
//   final String title;
//   final IconData icon;
//   final String key;
//   final Color color;

//   _ReportItem(this.title, this.icon, this.key, this.color);
// }

// class _ReportCard extends StatelessWidget {
//   final _ReportItem item;
//   final VoidCallback onTap;

//   const _ReportCard({required this.item, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: item.color.withOpacity(0.08),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(24),
//           onTap: onTap,
//           splashColor: item.color.withOpacity(0.1),
//           highlightColor: item.color.withOpacity(0.05),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // تصميم أيقونة احترافي مع خلفية متدرجة خفيفة
//                 Container(
//                   padding: const EdgeInsets.all(14),
//                   decoration: BoxDecoration(
//                     color: item.color.withOpacity(0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     item.icon,
//                     size: 36,
//                     color: item.color,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   item.title,
//                   textAlign: TextAlign.center,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xff334155),
//                     letterSpacing: -0.2,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 // إضافة مؤشر سهم صغير لتعزيز تجربة المستخدم
//                 Icon(
//                   Icons.arrow_forward_ios_rounded,
//                   size: 12,
//                   color: Colors.grey.withOpacity(0.5),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

// استيراد الشاشات الخاصة بك كما في الكود الأصلي
import 'package:manageon/station/reports/ColdStorReport.dart';
import 'package:manageon/station/reports/FarzaReport.dart';
import 'package:manageon/station/reports/PackingListReport.dart';
import 'package:manageon/station/reports/PlanningReport.dart';
import 'package:manageon/station/reports/ProductionReport.dart';
import 'package:manageon/station/reports/RawReport.dart';
import 'package:manageon/station/reports/SalesInvoiceReport.dart';
import 'package:manageon/station/reports/TotalOperation.dart';

class ReportsDashboardScreen extends StatelessWidget {
  const ReportsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // قائمة البيانات مع ألوان مخصصة لكل تقرير
    final items = [
      _ReportItem('تقرير الفرزة', Icons.rule_rounded, 'sorting', Colors.orange),
      _ReportItem('تقرير الإنتاج', Icons.precision_manufacturing_rounded, 'production', Colors.blue),
      _ReportItem('تقرير الخام', Icons.inventory_2_rounded, 'raw', Colors.green),
      _ReportItem('تقرير المبيعات', Icons.analytics_rounded, 'sales', Colors.purple),
      _ReportItem('رصيد الثلاجة', Icons.ac_unit_rounded, 'fridge', Colors.cyan),
      _ReportItem('تقرير المشحون', Icons.local_shipping_rounded, 'shipped', Colors.indigo),
        _ReportItem('تقرير التشغيل', Icons.analytics, 'operation', Colors.indigo),
       _ReportItem('تقرير التخطيط', Icons.analytics, 'Planning', Colors.indigo),
    ];

    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 900 ? 4 : (screenWidth > 600 ? 3 : 2);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffF8FAFC),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsetsDirectional.only(start: 24, bottom: 16),
                centerTitle: false,
                title: const Text(
                  'مركز التقارير',
                  style: TextStyle(
                    color: Color(0xff1E293B),
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = items[index];
                    return _ReportCard(
                      item: item,
                      onTap: () => _navigateToReport(context, item.key),
                    );
                  },
                  childCount: items.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.withOpacity(0.1)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'يتم تحديث جميع التقارير لحظياً بناءً على البيانات المدخلة في النظام.',
                          style: TextStyle(color: Colors.blueGrey, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // دالة التنقل الفعالة التي تدعم الشاشات الخاصة بك
  void _navigateToReport(BuildContext context, String key) {
    Widget screen;

    switch (key) {
      case 'sorting':
        screen = const FarzaReportScreen();
        break;
      case 'production':
        screen = ProductionReportScreen();
        break;
      case 'raw':
        screen = const RawReportScreen();
        break;
      case 'sales':
        screen = SalesInvoiceReportScreen();
        break;
      case 'fridge':
        screen = ColdStorReportScreen();
        break;
      case 'shipped':
        screen = PackingListReportScreen();
        break;
        case 'operation':
        screen = CropReportScreen();
        break;
          case 'Planning':
        screen = PlanninReportScreen();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

class _ReportItem {
  final String title;
  final IconData icon;
  final String key;
  final Color color;

  _ReportItem(this.title, this.icon, this.key, this.color);
}

class _ReportCard extends StatelessWidget {
  final _ReportItem item;
  final VoidCallback onTap;

  const _ReportCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: item.color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          splashColor: item.color.withOpacity(0.1),
          highlightColor: item.color.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.icon,
                    size: 36,
                    color: item.color,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff334155),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: Colors.grey.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}