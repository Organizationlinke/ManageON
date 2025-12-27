import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// استبدل هذه القيم بالقيم الحقيقية من مشروع Supabase الخاص بك

const String SUPABASE_URL ='https://desuoranpsjltjthfosv.supabase.co';
const String SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRlc3VvcmFucHNqbHRqdGhmb3N2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY4MjY0OTQsImV4cCI6MjA4MjQwMjQ5NH0.svrdVLKrlaQiV33oL9OZvD-crU672VqEXkJnYXUX380';

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