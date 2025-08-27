import 'dart:async';
import 'package:learnify/Helpers/hive_helper.dart';
import 'package:learnify/auth/fill_profile.dart';
import 'package:learnify/auth/signup_screen.dart';
import 'package:learnify/const.dart';
import 'package:learnify/home/Home.dart';
import 'package:learnify/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 2)).then((val) {
        if (HiveHelper.checkOnBoardingValue()) {
          if (FirebaseAuth.instance.currentUser != null) {
            if (HiveHelper.getToken() != null) {
              Get.offAll(() => Home());
            } else {
              Get.offAll(() => FillProfile(token: ""));
            }
          } else {
            Get.offAll(() => SignUpScreen());
          }
        } else {
          Get.offAll(() => OnboardingScreen());
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0961F5),
      body: Center(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Image.asset(
              "${img}Oval.png",
            ),
            Image.asset(
              "${img}SHAPE.png",
            ),
            Image.asset(
              "${img}LOGO.png",
            ),
          ],
        ),
      ),
    );
  }
}
