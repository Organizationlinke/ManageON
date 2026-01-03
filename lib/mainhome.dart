import 'package:flutter/material.dart';
import 'package:manageon/Vodavon/VodafoneCash.dart';
import 'package:manageon/station/Operation/OperationApp.dart';
import 'package:manageon/station/Operation/faults_page.dart';
import 'package:manageon/station/reports/ReportsList.dart';
import 'package:manageon/taskes/screens/home/home_screen.dart';

class MainFiltersScreen extends StatelessWidget {
  const MainFiltersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الفلاتر"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildMainButton(
                      title: "المهام",
                      icon: Icons.task_alt,
                      color: Colors.blue,
                      onTap: () {
                         
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                     const HomeScreen()
                                 
                          ));
                        
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildMainButton(
                      title: "التشغيل",
                      icon: Icons.settings,
                      color: Colors.orange,
                      onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                      FaultLoggingApp()
                                 
                          ));
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildMainButton(
                      title: "الجودة",
                      icon: Icons.verified,
                      color: Colors.green,
                      onTap: () {
                         Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                     const OperationApp()
                                 
                          ));
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildMainButton(
                      title: "التقارير",
                      icon: Icons.bar_chart,
                      color: Colors.purple,
                      onTap: () {
                                 Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                     const ReportsDashboardScreen()
                                 
                          ));
                      },
                    ),
                  ),
                   const SizedBox(width: 20),
                  Expanded(
                    child: _buildMainButton(
                      title: "فودافون كاش",
                      icon: Icons.bar_chart,
                      color: Colors.purple,
                      onTap: () {
                                 Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                     const VodafoneCashApp()
                                 
                          ));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
