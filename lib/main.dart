

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageon/constants.dart';
import 'package:manageon/taskes/screens/auth/login_screen.dart';
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