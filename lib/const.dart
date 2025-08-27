import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

blueColor() {
  return const Color(0xff0961F5);
}

textColor() {
  return const Color(0xFF202244);
}

String img = "assets/images/";

double padding(double context) {
  return context * 0.05;
}

Widget signButton(
    {required double h, required String text, bool? withArrow, Color? color}) {
  return Stack(
    alignment: Alignment.center,
    children: [
      Container(
        height: h * 0.07,
        width: double.infinity,
        decoration: BoxDecoration(
          color: color ?? blueColor(),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 50),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
      if (withArrow != false)
        const Positioned(
          right: 10,
          child: Icon(
            CupertinoIcons.arrow_right_circle_fill,
            size: 50,
            color: Colors.white,
          ),
        ),
    ],
  );
}
