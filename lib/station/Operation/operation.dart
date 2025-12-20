// import 'package:flutter/material.dart';
// import 'dart:async';

// // ملاحظة: يجب إضافة حزم supabase_flutter و google_fonts في pubspec.yaml
// // هذا الكود يركز على الواجهة والمنطق البرمجي المتوافق مع متطلباتك



// class BaronCitrusApp extends StatelessWidget {
//   const BaronCitrusApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'البارون للموالح',
//    theme: ThemeData(
//   primaryColor: const Color(0xFF059669),
//   colorScheme: ColorScheme.fromSeed(
//     seedColor: const Color(0xFF059669),
//   ),
//   useMaterial3: true,
// ),

//       home: const MainScaffold(),
//     );
//   }
// }

// class MainScaffold extends StatefulWidget {
//   const MainScaffold({super.key});

//   @override
//   State<MainScaffold> createState() => _MainScaffoldState();
// }

// class _MainScaffoldState extends State<MainScaffold> {
//   int _selectedIndex = 0;
//   int _selectedLine = 1;

//   final List<Widget> _pages = [
//     const DashboardPage(),
//     const ProductionReportPage(),
//     const FaultsReportPage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF064E3B),
//         title: Row(
//           children: [
//             const Icon(Icons.local_shipping, color: const Color(0xFF059669)),
//             const SizedBox(width: 10),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('البارون للموالح', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
//                 Text('نظام إدارة الإنتاج الذكي', style: TextStyle(color: const Color(0xFF059669).withOpacity(0.7), fontSize: 10)),
//               ],
//             ),
//           ],
//         ),
//         actions: [
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: StreamBuilder(
//                 stream: Stream.periodic(const Duration(seconds: 1)),
//                 builder: (context, snapshot) {
//                   return Text(
//                     TimeOfDay.now().format(context),
//                     style: const TextStyle(color: const Color(0xFF059669), fontWeight: FontWeight.bold, fontFamily: 'monospace'),
//                   );
//                 },
//               ),
//             ),
//           )
//         ],
//       ),
//       body: Column(
//         children: [
//           // Line Selector for Mobile Optimization
//           if (_selectedIndex == 0)
//             Container(
//               padding: const EdgeInsets.all(12),
//               color: Colors.white,
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: _buildLineToggle(1, 'الخط الأول'),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: _buildLineToggle(2, 'الخط الثاني'),
//                   ),
//                 ],
//               ),
//             ),
//           Expanded(child: _pages[_selectedIndex]),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: (index) => setState(() => _selectedIndex = index),
//         selectedItemColor: const Color(0xFF059669),
//         unselectedItemColor: Colors.grey,
//         selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'التشغيل'),
//           BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'التقارير'),
//           BottomNavigationBarItem(icon: Icon(Icons.warning_amber), label: 'الأعطال'),
//         ],
//       ),
//     );
//   }

//   Widget _buildLineToggle(int lineNum, String label) {
//     bool isSelected = _selectedLine == lineNum;
//     return GestureDetector(
//       onTap: () => setState(() => _selectedLine = lineNum),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         decoration: BoxDecoration(
//           color: isSelected ? const Color(0xFFECFDF5) : Colors.grey[200],
//           borderRadius: BorderRadius.circular(15),
//           border: Border.all(color: isSelected ? const Color(0xFF059669) : Colors.transparent, width: 2),
//         ),
//         child: Center(
//           child: Text(
//             label,
//             style: TextStyle(
//               color: isSelected ? const Color(0xFF065F46) : Colors.grey[600],
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // --- Dashboard Page ---
// class DashboardPage extends StatefulWidget {
//   const DashboardPage({super.key});

//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }

// class _DashboardPageState extends State<DashboardPage> {
//   double progress = 0.45; // Mock progress for UI demo
//   int speed = 30;

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           _buildActiveTractorCard(),
//           const SizedBox(height: 20),
//           _buildControlButtons(),
//         ],
//       ),
//     );
//   }

//   Widget _buildActiveTractorCard() {
//     return Card(
//       elevation: 4,
//       shadowColor: Colors.black12,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: const BoxDecoration(
//               color: Color(0xFF064E3B),
//               borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('الجرار الحالي', style: TextStyle(color: Colors.white70, fontSize: 12)),
//                     Text('#4588', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
//                   child: Row(
//                     children: [
//                       const Text('ص/د', style: TextStyle(color: Colors.white70, fontSize: 10)),
//                       const SizedBox(width: 5),
//                       Text('$speed', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
//                       const SizedBox(width: 5),
//                       const Icon(Icons.speed, color: const Color(0xFF059669), size: 16),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     _buildStatItem('وقت البدء', '08:30 ص', Icons.access_time),
//                     _buildStatItem('المتوقع', '10:15 ص', Icons.event_available),
//                   ],
//                 ),
//                 const SizedBox(height: 25),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text('تقدم الإنتاج', style: TextStyle(fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
//                     Text('${(progress * 100).toInt()}%', style: const TextStyle(color: const Color(0xFF059669), fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: LinearProgressIndicator(
//                     value: progress,
//                     minHeight: 12,
//                     backgroundColor: Colors.grey[200],
//                     valueColor: const AlwaysStoppedAnimation<Color>(const Color(0xFF059669)),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text('720 / 1600 صندوق', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildStatItem(String label, String value, IconData icon) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(icon, size: 14, color: Colors.grey),
//             const SizedBox(width: 4),
//             Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
//           ],
//         ),
//         Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//       ],
//     );
//   }

//   Widget _buildControlButtons() {
//     return Row(
//       children: [
//         Expanded(
//           child: ElevatedButton.icon(
//             onPressed: () {},
//             icon: const Icon(Icons.check_circle),
//             label: const Text('إنهاء التشغيل'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF1E293B),
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(vertical: 18),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//             ),
//           ),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: OutlinedButton.icon(
//             onPressed: () {},
//             icon: const Icon(Icons.warning_amber_rounded),
//             label: const Text('تسجيل عطل'),
//             style: OutlinedButton.styleFrom(
//               foregroundColor: Colors.red,
//               side: const BorderSide(color: Colors.red),
//               padding: const EdgeInsets.symmetric(vertical: 18),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // --- Production Report Page ---
// class ProductionReportPage extends StatelessWidget {
//   const ProductionReportPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: 5,
//       itemBuilder: (context, index) {
//         return Container(
//           margin: const EdgeInsets.only(bottom: 16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: Colors.grey[200]!),
//           ),
//           child: Column(
//             children: [
//               ListTile(
//                 leading: CircleAvatar(backgroundColor: const Color(0xFF059669), child: const Icon(Icons.local_shipping, color: const Color(0xFF059669))),
//                 title: const Text('جرار #4580',),
//                 subtitle: const Text('الخط الأول - 18 ديسمبر 2025', style: TextStyle(fontSize: 10)),
//                 trailing: const Icon(Icons.more_vert),
//               ),
//               const Divider(height: 1),
//               Padding(
//                 padding: const EdgeInsets.all(15),
//                 child: Column(
//                   children: [
//                     _buildReportRow(['البدء: 07:00 ص', 'الانتهاء: 08:30 ص']),
//                     const SizedBox(height: 10),
//                     _buildReportRow(['المتوقع: 80 د', 'الفعلي: 90 د']),
//                     const SizedBox(height: 10),
//                     Container(
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(10)),
//                       child: const Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
//                           Text('الأعطال: 10 د', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
//                           Text('الفرق: +10 د', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 11)),
//                           Text('الصافي: 80 د', style: TextStyle(color: const Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 11)),
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//               )
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildReportRow(List<String> items) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: items.map((text) => Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF64748B)))).toList(),
//     );
//   }
// }

// // --- Faults Report Page ---
// class FaultsReportPage extends StatelessWidget {
//   const FaultsReportPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: 3,
//       itemBuilder: (context, index) {
//         return Card(
//           margin: const EdgeInsets.only(bottom: 12),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//           child: const ListTile(
//             leading: Icon(Icons.error_outline, color: Colors.red),
//             title: Text('عطل في الموتور الرئيسي', style: TextStyle(fontWeight: FontWeight.bold)),
//             subtitle: Text('قسم الصيانة - المدة: 15 دقيقة'),
//             trailing: Text('10:20 ص', style: TextStyle(color: Colors.grey, fontSize: 10)),
//           ),
//         );
//       },
//     );
//   }
// }