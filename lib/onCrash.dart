import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnCrash extends StatelessWidget {
  const OnCrash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text("Something went wrong Please restart the app"),
            Icon(
              CupertinoIcons.xmark_circle_fill,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
