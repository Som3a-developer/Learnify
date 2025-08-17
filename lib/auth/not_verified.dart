import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learnify/firebase/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learnify/home/home_screen.dart';

class NotVerifiedScreen extends StatefulWidget {
  const NotVerifiedScreen({super.key});

  @override
  State<NotVerifiedScreen> createState() => _NotVerifiedScreenState();
}

class _NotVerifiedScreenState extends State<NotVerifiedScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(Duration(seconds: 3), (timer) async {
      await FirebaseAuth.instance.currentUser?.reload();
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        Get.snackbar(
          "Email Verified",
          "Your email has been verified successfully.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        timer.cancel();
        Get.offAll(() => HomeScreen(),
            transition: Transition.native,
            duration: const Duration(seconds: 1));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Email Not Verified"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Your email is not verified.",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Logic to resend verification email
                // This should call a method from FirebaseAuthHelper to resend the email
                FirebaseAuthHelper.resendVerificationEmail();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Verification email sent!")),
                );
              },
              child: const Text("Resend Verification Email"),
            ),
          ],
        ),
      ),
    );
  }
}
