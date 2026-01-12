
import 'package:flutter/material.dart';
import 'package:manageon/global.dart';

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
        _ReportItem('تقرير نتيجة الاعمال', Icons.analytics, 'operation', Colors.indigo),
       _ReportItem('تقرير التخطيط', Icons.analytics, 'Planning', Colors.indigo),
    ];

    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 900 ? 4 : (screenWidth > 600 ? 3 : 2);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
      
        // backgroundColor: const Color(0xffF8FAFC),
        body: 
        CustomScrollView(
          slivers: [
            const SliverAppBar(
              // expandedHeight: 120.0,
              floating: false,
              pinned: true,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsetsDirectional.only(start: 24, bottom: 16),
                centerTitle: true,
                title: Text(
                  'مركز التقارير',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color.fromARGB(255, 255, 255, 255)
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