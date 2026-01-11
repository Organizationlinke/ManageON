import 'package:flutter/material.dart';
import 'package:manageon/station/Operation/OperationApp.dart';
import 'package:manageon/station/Operation/faults_page.dart';


class MainOperation extends StatelessWidget {
  const MainOperation({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ProductionDashboardScreen(),
    );
  }
}

/// =======================
/// الشاشة الرئيسية
/// =======================
class ProductionDashboardScreen extends StatelessWidget {
  const ProductionDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تشغيل خط الإنتاج'),
        centerTitle: true,
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // زر تسجيل الأعطال
            _DashboardButton(
              icon: Icons.build_circle,
              label: 'تسجيل الأعطال اليومية',
              color: Colors.redAccent,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>  FaultLoggingApp(),
                  ),
                );
              },
            ),

            // زر تشغيل خط الإنتاج
            _DashboardButton(
              icon: Icons.play_circle_fill,
              label: 'تشغيل خط الإنتاج',
              color: Colors.green,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OperationApp(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// =======================
/// ويدجت زر أيقوني
/// =======================
class _DashboardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _DashboardButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          iconSize: 80,
          onPressed: onPressed,
          icon: Icon(icon, color: color),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

