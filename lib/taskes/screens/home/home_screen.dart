import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageon/global.dart';
import 'package:manageon/taskes/providers/app_state_provider.dart';
import 'package:manageon/login_screen.dart';
import 'package:manageon/taskes/screens/profile/user_profile_screen.dart';
import 'package:manageon/taskes/screens/tasks/tasks_screen.dart';
import 'package:manageon/taskes/screens/team/team_screen.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    // DashboardScreen(),
    // Center(child: Text("DashboardScreen"),),
    TasksScreen(),
    // Center(child: Text("reports"),),
    // AnalyticsScreen(),
    TeamScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    // Clear the logged-in user state
    ref.read(loggedInUserProvider.notifier).state = null;
    // Navigate to login screen and remove all previous routes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) =>  LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
       
          title: Text(_getAppBarTitle(_selectedIndex)),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () {

                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => UserProfileScreen()),
                );
                print('aaa');
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
          ],
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.dashboard_outlined),
            //   label: 'لوحة التحكم',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined),
              label: 'المهام',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.bar_chart_outlined),
            //   label: 'التقارير',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined),
              label: 'الفريق',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: colorbar,
          unselectedItemColor: Colors.grey,
        ),
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'لوحة التحكم';
      case 1:
        return 'إدارة المهام';
      case 2:
        return 'التقارير';
      case 3:
        return 'إدارة الفريق';
      default:
        return 'مُنجِز';
    }
  }
}
