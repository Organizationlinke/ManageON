import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// استبدل هذه القيم بالقيم الحقيقية من مشروع Supabase الخاص بك

const String SUPABASE_URL ='https://qsvhdpitcljewzqjqhbe.supabase.co';
const String SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhxcmt3dmFra3ZpaGFldWpudXZoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1ODYwMzcsImV4cCI6MjA3ODE2MjAzN30.v27FN2Q7zTJetGRCeEw7s6epc3pPoVDNFpxK3NuOWJU';

// للوصول السريع للعميل
final supabase = Supabase.instance.client;

// ألوان التطبيق
const kPrimaryColor = Color(0xFFD4A373);
const kSecondaryColor = Color(0xFFEADBC8);
const kTextColor = Color(0xFF3f3c3a);
const kBackgroundColor = Color(0xFFFDFBF7);

// دالة لعرض رسالة خطأ أو نجاح
void showSnackBar(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
    ),
  );
}