
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageon/Vodavon/VodafoneCash.dart';
import 'package:manageon/constants.dart'; // تأكد أن هذا الملف موجود ويحتوي على kPrimaryColor
import 'package:manageon/mainhome.dart';
import 'package:manageon/station/Finance/Shipping.dart';
import 'package:manageon/station/Operation/OperationApp.dart';
import 'package:manageon/station/Operation/faults_page.dart';
import 'package:manageon/station/reports/ReportsList.dart';
import 'package:manageon/taskes/models/user_model.dart';
import 'package:manageon/taskes/providers/app_state_provider.dart';
import 'package:manageon/taskes/screens/home/home_screen.dart';
import 'package:manageon/global.dart'; // مثال على استيراد ملف الألوان
import 'package:shared_preferences/shared_preferences.dart'; // لا تنسى هذا الاستيراد!

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials(); // استدعاء لتحميل البيانات المحفوظة عند التهيئة
  }

  // دالة لتحميل بيانات الاعتماد المحفوظة
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    _userNameController.text = prefs.getString('user_enter') ?? '';
    _passwordController.text = prefs.getString('pass') ?? '';
  }

  // دالة مساعدة لعرض SnackBar
  void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userName = _userNameController.text.trim();
      final password = _passwordController.text.trim();

      if (userName.isEmpty || password.isEmpty) {
        showSnackBar(context, 'الرجاء إدخال اسم المستخدم وكلمة المرور', isError: true);
        setState(() => _isLoading = false);
        return;
      }

      final response = await supabase
          .from('usersin') // أو 'usertable' بناءً على جدولك الفعلي
          .select('*, departments:department(*)')
          .eq('user_name', userName) // أو 'user_enter'
          .eq('pass', password)
          .maybeSingle();

      if (response != null) {
         user_id=response["id"];
user_level=response["level"];
        // User found, login successful
        final user = AppUser.fromJson(response);
        ref.read(loggedInUserProvider.notifier).state = user;

        // حفظ اسم المستخدم وكلمة المرور هنا
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_enter', userName);
        await prefs.setString('pass', password);

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) =>
            //  const HomeScreen()
           user_level==0?  MainFiltersScreen():
           user_level==10?FaultLoggingApp():
           user_level==11? OperationApp():
           user_level==12||user_level==13?VodafoneCashApp():
           user_level==14?ReportsDashboardScreen():
          user_level==15? FinanceScreen():
          user_level==16? ShippingManagementScreen():
          user_level==17? SalesReportsDashboardScreen():HomeScreen()
             ),
          );
        }
      } else {
        // User not found or password incorrect
        if (mounted) {
          showSnackBar(context, 'اسم المستخدم أو كلمة المرور غير صحيحة', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'حدث خطأ غير متوقع: $e', isError: true);
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorbar,
          foregroundColor: Colorapp,
          title: Text(
            'شاشة تسجيل الدخول',
            style: TextStyle(color: Colorapp),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.network(
                      'https://xqrkwvakkvihaeujnuvh.supabase.co/storage/v1/object/public/userphoto/manageon2.png',
                      width: 300,
                    ),
                    const SizedBox(height: 50),
                    TextFormField(
                      controller: _userNameController,
                      decoration: InputDecoration(
                        labelText: 'اسم المستخدم',
                        border: const OutlineInputBorder(),
                        icon: Icon(Icons.person, color: colorbar),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        border: const OutlineInputBorder(),
                        icon: Icon(Icons.lock, color: Colors.blue),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color_Button,
                              foregroundColor: Colorapp,
                              padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 25),
                            ),
                            child: const Text(
                              'تسجيل الدخول',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                    const SizedBox(height: 200),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}