import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnify/admin/add_courses.dart';
import 'package:learnify/auth/fill_profile.dart';
import 'package:learnify/const.dart';
import 'package:learnify/courses/popular_courses.dart';
import 'package:learnify/edit_profile/edit_profile.dart';
import 'package:learnify/home/cubit/home_cubit.dart';
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
    Container(),
    Container(),
    AddCoursesScreen(),
    EditProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();

    return Scaffold(
      bottomNavigationBar: FlashyTabBar(
        animationDuration: const Duration(milliseconds: 800),
        animationCurve: Curves.linear,
        selectedIndex: _selectedIndex,
        iconSize: 30,
        showElevation: false,
        // use this to remove appBar's elevation
        onItemSelected: (index) => setState(() {
          _selectedIndex = index;
        }),
        items: [
          FlashyTabBarItem(
            icon: Icon(
              CupertinoIcons.house_fill,
              color: blueColor(),
            ),
            title: Text('Home'),
          ),
          FlashyTabBarItem(
            icon: Icon(
              CupertinoIcons.arrow_down_to_line_alt,
              color: Colors.green,
            ),
            title: Text('Enrolled'),
          ),
          FlashyTabBarItem(
            icon: Icon(
              Icons.bookmark,
              color: Colors.yellow,
            ),
            title: Text('Saved'),
          ),
          FlashyTabBarItem(
            icon: Icon(
              Icons.notification_important,
              color: Colors.red,
            ),
            title: Text('profile'),
          ),
          FlashyTabBarItem(
            icon: Icon(
              Icons.person_4,
              color: Colors.black,
            ),
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
          child: _selectedIndex == 1
              ? PopularCourses(
                  courses: cubit.getEnrolledCourses(),
                  categories:
                      cubit.specificCourseCategory(cubit.getEnrolledCourses()),
                  screenName: 'Enrolled',
                  isBack: false,
                )
              : _selectedIndex == 2
                  ? PopularCourses(
                      courses: cubit.getCoursesById(),
                      categories:
                          cubit.specificCourseCategory(cubit.getCoursesById()),
                      screenName: 'Saved Courses',
                      isBack: false,
                    )
                  : tabItems[_selectedIndex],
        ),
      ),
    );
  }
}
