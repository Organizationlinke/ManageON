
// import 'package:flutter/material.dart';
// import 'package:manageon/login.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized(); 
//    const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
//   const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
//   await Supabase.initialize(
//     //      url: supabaseUrl, // قراءة URL
//     // anonKey: supabaseAnonKey, // قراءة المفتاح
//     url: 'https://qsvhdpitcljewzqjqhbe.supabase.co',
//     anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFzdmhkcGl0Y2xqZXd6cWpxaGJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5NDYwMTksImV4cCI6MjA2OTUyMjAxOX0.YH-RR0w03qgYcpHQM-eygczVuheNljrbvXm6i-9uSwM',
//   //  realtimeClientOptions: RealtimeClientOptions(
//   //   reconnectAttempts: 10,
//   //   reconnectInterval: const Duration(seconds: 3),
//   // ),
//   );
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//        debugShowCheckedModeBanner: false,
//       home: LoginScreen(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageon/constants.dart';
// import 'package:manageon/login.dart';
import 'package:manageon/screens/auth/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // قم باستبدال SUPABASE_URL و SUPABASE_ANON_KEY بالمفاتيح الخاصة بك
  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق إدارة المهام',
      
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Cairo',
        scaffoldBackgroundColor: const Color(0xFFFDFBF7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE0F7FA),
          background: const Color(0xFFFDFBF7),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF267A81),
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFFFDFBF7)),
          titleTextStyle: TextStyle(
            fontFamily: 'Cairo',
            color: Color(0xFFFDFBF7),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        useMaterial3: true,
      ),


      
       debugShowCheckedModeBanner: false,
       home:LoginScreen(),
      // home:  LoginScreen(), // يبدأ التطبيق دائما من شاشة تسجيل الدخول
    );
  }
}