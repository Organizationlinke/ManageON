



import 'package:flutter/material.dart';
import 'package:manageon/global.dart';
import 'package:manageon/screens/home/home_screen.dart';
// import 'package:manageon/manag/add_task.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  @override
  void initState() {
    super.initState();
  
    _loadSavedCredentials();
    
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    _userController.text = prefs.getString('user_enter') ?? '';
    _passController.text = prefs.getString('pass') ?? '';
  }

  Future<void> _login() async {
    final userEnter = _userController.text;
    final pass = _passController.text;

    final response = await Supabase.instance.client
        .from('usertable')
        .select()
        .eq('user_enter', userEnter)
        .eq('pass', pass)
        .single();

    if (response .isNotEmpty) {
      user_id=response["id"];
      // user_uuid=response["uuid"];
      user_respose=response;
     
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_enter', userEnter);
      await prefs.setString('pass', pass);
   
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>HomeScreen()),
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => UserProfileScreen(userData: response)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('اسم المستخدم أو كلمة السر غير صحيحة')),
      );
    }
 
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorbar,
          foregroundColor: Colorapp,
          title: Text('شاشة تسجيل الدخول',style: TextStyle(color: Colorapp),)
          ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
               width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network('https://qsvhdpitcljewzqjqhbe.supabase.co/storage/v1/object/public/userphoto//manageon2.png',
                  width: 300,),
                    // Text('شاشة تسجيل الدخول',style: TextStyle(fontSize: 25),),
                    SizedBox(height: 50),
                  TextField(controller: _userController, decoration: InputDecoration(labelText: 'اسم المستخدم',icon: Icon(Icons.person,color:colorbar,))),
                  TextField(controller: _passController, decoration: InputDecoration(labelText: 'كلمة المرور',icon: Icon(Icons.lock,color: Colors.blue,)), obscureText: true),
                  SizedBox(height: 20),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                      backgroundColor:color_Button,
                      foregroundColor: Colorapp
                    ),
                    onPressed: _login, child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('تسجيل الدخول',style: TextStyle(fontSize: 18),),
                    )),
                  SizedBox(height: 200),
               
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
