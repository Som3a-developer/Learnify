import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:learnify/Helpers/hive_helper.dart';
import 'package:learnify/auth/cubit/login_cubit.dart';
import 'package:learnify/Helpers/dio_helper.dart';
import 'package:learnify/courses/cubit/courses_cubit.dart';
import 'package:learnify/home/cubit/home_cubit.dart';
import 'package:learnify/splash/splash.dart';
import 'package:learnify/onCrash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    await dotenv.load(fileName: "assets/env/.env");

    DioHelper.init();

    await Firebase.initializeApp();
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
    );

    await Hive.initFlutter();
    await Hive.openBox(HiveHelper.onboardingBox);
    await Hive.openBox(HiveHelper.userBox);
    await Hive.openBox(HiveHelper.coursesBox);
    await Hive.openBox(HiveHelper.enrolledCourses);
    await Hive.openBox(HiveHelper.savedCourses);

    runApp(const MyApp());
  }, (error, stack) {
    runApp(const CrashApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LoginCubit()),
        BlocProvider(create: (_) => HomeCubit()..getData()),
        BlocProvider(create: (_) => CoursesCubit()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        home: Splash(),
      ),
    );
  }
}

class CrashApp extends StatelessWidget {
  const CrashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      color: Colors.white,
      debugShowCheckedModeBanner: false,
      home: OnCrash(),
    );
  }
}
