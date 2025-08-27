import 'package:flutter/material.dart';
import 'package:learnify/widgets/warp_indicator.dart';
import 'package:learnify/const.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WarpIndicator(
        starsCount: 25,
        skyColor: Colors.transparent,
        starColorGetter: (index) => blueColor(),
        onRefresh: () async {},
        child: Container(),
      ),
    );
  }
}
