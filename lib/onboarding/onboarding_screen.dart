import 'package:learnify/Helpers/hive_helper.dart';
import 'package:learnify/const.dart';
import 'package:learnify/widgets/onboarding.dart';
import 'package:learnify/widgets/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../auth/signup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int index = 0;

  void changePage() {
    if (index < onboardingList.length - 1) {
      setState(() => index++);
    } else {
      Get.offAll(() => SignUpScreen());
      HiveHelper.setValueInOnboardingBox();
    }
  }

  void goBack() {
    if (index > 0) {
      setState(() => index--);
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = context.width;
    final pad = padding(width);

    return WillPopScope(
      onWillPop: () async {
        goBack();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: EdgeInsets.all(pad),
              child: GestureDetector(
                onTap: () {
                  HiveHelper.setValueInOnboardingBox();

                  Get.offAll(
                    () => SignUpScreen(),
                  );
                },
                child: boldtexts('Skip'),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.only(bottom: width * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              boldtexts(onboardingList[index].title ?? "No Title"),
              const SizedBox(height: 10),
              Text(onboardingList[index].description ?? "No Description"),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: pad),
                    child: Row(
                      children: List.generate(
                        onboardingList.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: index == i ? 24 : 8,
                          decoration: BoxDecoration(
                            color: index == i
                                ? blueColor()
                                : blueColor().withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: pad),
                    child: GestureDetector(
                      onTap: changePage,
                      child: index != onboardingList.length - 1
                          ? Icon(
                              onboardingList[index].icon,
                              size: 50,
                              color: blueColor(),
                            )
                          : Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                Container(
                                  height: 60,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    color: blueColor(),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 50),
                                      child: Text(
                                        'Get Started',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 10,
                                  child: Icon(
                                    onboardingList[index].icon,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
