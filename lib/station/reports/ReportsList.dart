import 'package:flutter/material.dart';
import 'package:manageon/station/reports/FarzaReport.dart';
import 'package:manageon/station/reports/RawReport.dart';

class ReportsDashboardScreen extends StatelessWidget {


  const ReportsDashboardScreen({super.key, });

  @override
  Widget build(BuildContext context) {
    final items = [
      _ReportItem('تقرير الفرزة', Icons.rule, 'sorting'),
      _ReportItem('تقرير الإنتاج', Icons.factory, 'production'),
      _ReportItem('تقرير الخام', Icons.inventory_2, 'raw'),
      _ReportItem('تقرير المبيعات', Icons.point_of_sale, 'sales'),
      _ReportItem('رصيد الثلاجة', Icons.ac_unit, 'fridge'),
      _ReportItem('تقرير المشحون', Icons.local_shipping, 'shipped'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF3F5F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'التقارير',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _ReportCard(
                      item: item,
                   onTap: () {
  Widget screen;

  switch (item.key) {
    case 'sorting':
      screen = const FarzaReportScreen();
      break;
    case 'production':
      screen = Text('data');
      break;
    case 'raw':
      screen = const RawReportScreen();
      break;
    case 'sales':
     screen = Text('data');
      break;
    case 'fridge':
      screen = Text('data');
      break;
    case 'shipped':
      screen = Text('data');
      break;
    default:
      return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => screen),
  );
},

                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportItem {
  final String title;
  final IconData icon;
  final String key;

  _ReportItem(this.title, this.icon, this.key);
}

class _ReportCard extends StatelessWidget {
  final _ReportItem item;
  final VoidCallback onTap;

  const _ReportCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xffFFFFFF), Color(0xffE9EEF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: Icon(item.icon, size: 32, color: Colors.blueGrey),
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
