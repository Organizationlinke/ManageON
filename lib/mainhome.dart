// import 'package:flutter/material.dart';
// import 'package:manageon/Vodavon/VodafoneCash.dart';
// import 'package:manageon/station/Finance/OtherCostRoles.dart';
// import 'package:manageon/station/Finance/Payments.dart';
// import 'package:manageon/station/Finance/Shipping.dart';
// import 'package:manageon/station/Operation/MainOperation.dart';
// import 'package:manageon/station/reports/ReportsList.dart';
// import 'package:manageon/taskes/screens/home/home_screen.dart';

// class MainFiltersScreen extends StatelessWidget {
//   const MainFiltersScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Manage ON"),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Expanded(
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: _buildMainButton(
//                       title: "المهام",
//                       icon: Icons.task_alt,
//                       color: Colors.blue,
//                       onTap: () {
                         
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                                 builder: (context) =>
//                                      const HomeScreen()
                                 
//                           ));
                        
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 20),
//                   Expanded(
//                     child: _buildMainButton(
//                       title: "الماليه",
//                       icon: Icons.task_alt,
//                       color: Colors.blue,
//                       onTap: () {
                         
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                                 builder: (context) =>
//                                      const FinanceScreen()
                                 
//                           ));
                        
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 20),
//                   Expanded(
//                     child: _buildMainButton(
//                       title: "التشغيل",
//                       icon: Icons.settings,
//                       color: Colors.orange,
//                       onTap: () {
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                                 builder: (context) =>
//                                 MainOperation()
//                                       // FaultLoggingApp()
                                 
//                           ));
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: _buildMainButton(
//                       title: "المشحون",
//                       icon: Icons.verified,
//                       color: Colors.green,
//                       onTap: () {
//                          Navigator.of(context).push(
//                             MaterialPageRoute(
//                                 builder: (context) =>
//                                      const ShippingManagementScreen()
                                 
//                           ));
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 20),
//                   Expanded(
//                     child: _buildMainButton(
//                       title: "التقارير",
//                       icon: Icons.bar_chart,
//                       color: Colors.purple,
//                       onTap: () {
//                                  Navigator.of(context).push(
//                             MaterialPageRoute(
//                                 builder: (context) =>
//                                      const ReportsDashboardScreen()
                                 
//                           ));
//                       },
//                     ),
//                   ),
//                    const SizedBox(width: 20),
//                   Expanded(
//                     child: _buildMainButton(
//                       title: "فودافون كاش",
//                       icon: Icons.bar_chart,
//                       color: Colors.purple,
//                       onTap: () {
//                                  Navigator.of(context).push(
//                             MaterialPageRoute(
//                                 builder: (context) =>
//                                      const VodafoneCashApp()
                                 
//                           ));
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMainButton({
//     required String title,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         decoration: BoxDecoration(
//           color: color.withOpacity(.15),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: color, width: 2),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 50, color: color),
//             const SizedBox(height: 10),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 20,
//                 color: color,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class FinanceScreen extends StatelessWidget {
//   const FinanceScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Manage ON"),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
      
//             Expanded(
//               child: Row(
//                 children: [
//              Expanded(
//                     child: _buildMainButton(
//                       title: "التكاليف الاساسية",
//                       icon: Icons.task_alt,
//                       color: Colors.blue,
//                       onTap: () {
                         
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                                 builder: (context) =>
//                                      const OtherCostRolesScreen()
                                 
//                           ));
                        
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 20),
//                   Expanded(
//                     child: _buildMainButton(
//                       title: "التقارير",
//                       icon: Icons.bar_chart,
//                       color: Colors.purple,
//                       onTap: () {
//                                  Navigator.of(context).push(
//                             MaterialPageRoute(
//                                 builder: (context) =>
//                                      const ReportsDashboardScreen()
                                 
//                           ));
//                       },
//                     ),
//                   ),
               
//                 ],
//               ),
//             ),
//             SizedBox(height: 10,),
//               Expanded(
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: _buildMainButton(
//                       title: "فودافون كاش",
//                       icon: Icons.bar_chart,
//                       color: Colors.purple,
//                       onTap: () {
//                                  Navigator.of(context).push(
//                             MaterialPageRoute(
//                                 builder: (context) =>
//                                      const VodafoneCashApp()
                                 
//                           ));
//                       },
//                     ),
//                   ),
//                    Expanded(
//                     child: _buildMainButton(
//                       title: "تسجيل التحصيلات",
//                       icon: Icons.bar_chart,
//                       color: Colors.purple,
//                       onTap: () {
//                                  Navigator.of(context).push(
//                             MaterialPageRoute(
//                                 builder: (context) =>
//                                      const CustomerPaymentsScreen()
                                 
//                           ));
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMainButton({
//     required String title,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         decoration: BoxDecoration(
//           color: color.withOpacity(.15),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: color, width: 2),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 50, color: color),
//             const SizedBox(height: 10),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 20,
//                 color: color,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

// استيراد الشاشات الخاصة بك
import 'package:manageon/Vodavon/VodafoneCash.dart';
import 'package:manageon/global.dart';
import 'package:manageon/station/Finance/InvoiceAdditional.dart';
import 'package:manageon/station/Finance/OtherCostRoles.dart';
import 'package:manageon/station/Finance/Payments.dart';
import 'package:manageon/station/Finance/Shipping.dart';
import 'package:manageon/station/Operation/MainOperation.dart';
import 'package:manageon/station/reports/ReportsList.dart';
// import 'package:manageon/reports_dashboard_screen.dart'; // شاشة التقارير المطورة
import 'package:manageon/taskes/screens/home/home_screen.dart';

// كلاس موحد لبيانات الأزرار
class _MenuAction {
  final String title;
  final IconData icon;
  final Color color;
  final Widget targetScreen;

  _MenuAction(this.title, this.icon, this.color, this.targetScreen);
}

// ---------------------------------------------------------
// الشاشة الرئيسية: MainFiltersScreen
// ---------------------------------------------------------
class MainFiltersScreen extends StatelessWidget {
  const MainFiltersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_MenuAction> mainActions = [
      _MenuAction('المهام', Icons.task_alt_rounded, Colors.blue, const HomeScreen()),
      _MenuAction('المالية', Icons.account_balance_wallet_rounded, Colors.teal, const FinanceScreen()),
      _MenuAction('التشغيل', Icons.settings_suggest_rounded, Colors.orange, MainOperation()),
      _MenuAction('المشحون', Icons.local_shipping_rounded, Colors.green, const ShippingManagementScreen()),
      _MenuAction('التقارير', Icons.insert_chart_outlined_rounded, Colors.purple, const ReportsDashboardScreen()),
      _MenuAction('فودافون كاش', Icons.smartphone_rounded, Colors.redAccent, const VodafoneCashApp()),
    ];

    return _BaseDashboard(
      title: 'Manage ON',
      actions: mainActions,
      isPrimary: true,
    );
  }
}

// ---------------------------------------------------------
// الشاشة المالية: FinanceScreen
// ---------------------------------------------------------
class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_MenuAction> financeActions = [
      _MenuAction('التكاليف الأساسية', Icons.assignment_rounded, Colors.blue, const OtherCostRolesScreen()),
      _MenuAction('التقارير المالية', Icons.analytics_rounded, Colors.purple, const ReportsDashboardScreen()),
      _MenuAction('فودافون كاش', Icons.phone_android_rounded, Colors.red, const VodafoneCashApp()),
      _MenuAction('تسجيل التحصيلات', Icons.payments_rounded, Colors.green, const CustomerPaymentsScreen()),
      _MenuAction('تسجيل الخصومات', Icons.payments_rounded, Colors.green, const InvoiceAdditionalScreen()),
    ];

    return _BaseDashboard(
      title: 'الإدارة المالية',
      actions: financeActions,
      isPrimary: false,
    );
  }
}

// ---------------------------------------------------------
// مكون لوحة التحكم العام (Base Dashboard) لتجنب التكرار
// ---------------------------------------------------------
class _BaseDashboard extends StatelessWidget {
  final String title;
  final List<_MenuAction> actions;
  final bool isPrimary;

  const _BaseDashboard({
    required this.title,
    required this.actions,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffF1F5F9),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              // expandedHeight: 120.0,
              pinned: true,
              elevation: 0,
              centerTitle: true,
              backgroundColor: isPrimary ? Colors.blue.shade800 : Colors.teal.shade800,
              foregroundColor: colorbar_bottom,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: isPrimary 
                        ? [Colors.blue.shade900, Colors.blue.shade600]
                        : [Colors.teal.shade900, Colors.teal.shade600],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = actions[index];
                    return _DashboardCard(item: item);
                  },
                  childCount: actions.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// تصميم الكارت الموحد
class _DashboardCard extends StatelessWidget {
  final _MenuAction item;

  const _DashboardCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: item.color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => item.targetScreen)
          ),
          splashColor: item.color.withOpacity(0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, size: 36, color: item.color),
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff334155),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
