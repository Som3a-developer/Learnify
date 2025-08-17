import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'main.dart'; // مهم تستورد main عشان تقدر تنادي عليه

class OnCrash extends StatelessWidget {
  const OnCrash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Something went wrong\nPlease restart the app"),
            const SizedBox(height: 20),
            const Icon(
              CupertinoIcons.xmark_circle_fill,
              color: Colors.red,
              size: 50,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                main(); // هنا بيعيد تشغيل التطبيق من الأول
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
