import 'package:flutter/cupertino.dart';

class Onboarding {
  String? title;
  String? description;
  IconData? icon;
  Onboarding({
    this.title,
    this.description,
    this.icon,
  });
}

List<Onboarding> onboardingList = [
  Onboarding(
    title: "Online Learning",
    description:
        "We Provide Classes Online Classes and Pre Recorded Leactures.!",
    icon: CupertinoIcons.arrow_right_circle_fill,
  ),
  Onboarding(
    title: "Learn from Anytime",
    description: "Booked or Same the Lectures for Future",
    icon: CupertinoIcons.arrow_right_circle_fill,
  ),
  Onboarding(
    title: "Get Online Certificate",
    description: "Analyse your scores and Track your results",
    icon: CupertinoIcons.arrow_right_circle_fill,
  ),
];
