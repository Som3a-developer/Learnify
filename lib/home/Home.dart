import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learnify/admin/add_courses.dart';
import 'package:learnify/auth/fill_profile.dart';
import 'package:learnify/courses/popular_courses.dart';
import 'package:learnify/home/home_screen.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  List<Widget> tabItems = [
    HomeScreen(),
    PopularCourses(courses: [],categories: [],),
    AddCoursesScreen(),
    FillProfile()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: FlashyTabBar(
        animationDuration: const Duration(milliseconds: 800),
        animationCurve: Curves.linear,
        selectedIndex: _selectedIndex,
        iconSize: 30,
        showElevation: false, // use this to remove appBar's elevation
        onItemSelected: (index) => setState(() {
          _selectedIndex = index;
        }),
        items: [
          FlashyTabBarItem(
            icon: Icon(CupertinoIcons.house_fill),
            title: Text('Home'),
          ),
          FlashyTabBarItem(
            icon: Icon(CupertinoIcons.doc_plaintext),
            title: Text('Home'),
          ),
          FlashyTabBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            title: Text('Transaction'),
          ),
          FlashyTabBarItem(
            icon: Icon(Icons.person_4),
            title: Text('profile'),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 800),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: Container(
          key: ValueKey<int>(_selectedIndex),
          alignment: Alignment.center,
          child: tabItems[_selectedIndex],
        ),
      ),
    );
  }
}
