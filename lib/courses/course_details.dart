import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' hide ContextExtensionss;
import 'package:learnify/Helpers/hive_helper.dart';
import 'package:learnify/const.dart';
import 'package:learnify/courses/cubit/courses_cubit.dart';
import 'package:learnify/courses/full_screen.dart';
import 'package:learnify/extentions.dart';
import 'package:learnify/firebase/firebase_auth.dart';
import 'package:learnify/home/models/courses_model.dart';
import 'package:learnify/widgets/texts.dart';

class CourseDetails extends StatelessWidget {
  const CourseDetails({super.key, required this.course});

  final CoursesModel course;

  @override
  Widget build(BuildContext context) {
    final height = context.height;
    final width = context.width;
    final cubit = context.read<CoursesCubit>();
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: height * 0.28,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
            ),
          ),
          Positioned.fill(
            top: height * 0.28,
            child: Container(
              color: Colors.white,
            ),
          ),
          Positioned.fill(
            top: height * 0.2,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: width * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.06),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          top: height * 0.06,
                          bottom: height * 0.03,
                          left: width * 0.04,
                          right: width * 0.04,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(width * 0.04),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              spreadRadius: 1,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          spacing: height * 0.0005,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.category ?? "",
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: width * 0.03,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: height * 0.005),
                            Text(
                              course.title ?? "",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: width * 0.045,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: height * 0.015),
                            Text(
                              "About the course",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: width * 0.03,
                              ),
                            ),
                            SizedBox(height: height * 0.01),
                            Padding(
                              padding: EdgeInsets.only(left: width * 0.02),
                              child: Text(
                                course.description ?? "",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: width * 0.04,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: -width * 0.11,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            if (HiveHelper.isEnrolled(course.courseId ?? 1)) {
                              Get.to(FullScreenYoutubePlayer(
                                url: course.url ?? "",
                              ));
                            } else {
                              Get.snackbar("Not Enrolled",
                                  "You are not enrolled in this course",
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white);
                            }
                          },
                          child: Image.asset(
                            "${img}Video.png",
                            width: width * 0.22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.03),
                  boldtexts("Instructor"),
                  SizedBox(height: height * 0.01),
                  Row(
                    spacing: width * 0.02,
                    children: [
                      CircleAvatar(
                        radius: width * 0.065,
                        backgroundImage: AssetImage(img + "profile.png"),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.publisher ?? "",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: width * 0.04,
                            ),
                          ),
                          Text(
                            course.category ?? "",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: width * 0.03,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Icon(
                        CupertinoIcons.chat_bubble_2,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.04),
                  BlocBuilder<CoursesCubit, CoursesState>(
                    builder: (context, state) {
                      return cubit.isEnrolled(
                        courseId: course.courseId ?? -1,
                      )
                          ? Container(
                              alignment: Alignment.center,
                              height: height * 0.07,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius:
                                    BorderRadius.circular(width * 0.04),
                              ),
                              child: Text(
                                "Enrolled",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: width * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                cubit.setEnrolled(
                                    userId: HiveHelper.getToken()!,
                                    courseId: course.courseId ?? 1);
                                Get.snackbar(
                                  "Enrolled",
                                  "You have enrolled in this course",
                                );
                              },
                              child: signButton(h: height, text: "Enroll Now"));
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
