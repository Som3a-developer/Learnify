import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnify/Helpers/hive_helper.dart';
import 'package:learnify/courses/categories.dart';
import 'package:learnify/courses/course_details.dart';
import 'package:learnify/courses/cubit/courses_cubit.dart';
import 'package:learnify/home/cubit/home_cubit.dart';
import 'package:learnify/home/models/courses_model.dart';
import 'package:learnify/widgets/texts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PopularCourses extends StatelessWidget {
  const PopularCourses(
      {required this.categories, required this.courses, super.key});

  final List<CoursesModel> courses;

  final List categories;

  @override
  Widget build(BuildContext context) {
    final w = context.width;
    final h = context.height;
    final cubit = context.read<CoursesCubit>();

    final courseList = courses;
    final filters = ['All', 'Graphic Design', '3D Design', 'Arts & Humanities'];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Icon(
                Icons.arrow_back,
              ),
            ),
            SizedBox(width: w * .01),
            boldtexts('Popular Courses'),
            Spacer(),
            GestureDetector(
              onTap: () {
                Get.to(() => Categories(
                      allCategories: categories,
                    ));
              },
              child: Icon(Icons.search),
            ),
          ],
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: index == 0 ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        categories[index],
                        style: TextStyle(
                          color: index == 0 ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: courseList!.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final data = courseList[index];
                  return GestureDetector(
                    onTap: () {
                      Get.to(
                        CourseDetails(
                          course: data,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 64,
                            width: 64,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.category ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data.title ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    "${data.points}" ?? '',
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      size: 14, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(
                                    '',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.person,
                                      size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    '- Std',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Spacer(),
                          BlocBuilder<CoursesCubit, CoursesState>(
                            builder: (context, state) {

                              return GestureDetector(
                                onTap: () {
                                  try {
                                    if (!HiveHelper.isSaved(data.courseId!)) {
                                      if (data.courseId! >= 0) {
                                        cubit.saveCourse(data.courseId!);
                                      }
                                    }else{
                                    cubit.unSaveCourse(data.courseId!);
                                    }
                                  } catch (e) {
                                  Get.snackbar("title", "couldn't Save");
                                  }
                                },
                                child:HiveHelper.isSaved(data.courseId!)? Icon(
                                        size: w * .09,
                                        Icons.bookmark,
                                        color: Colors.amberAccent,
                                      )
                                    :
                                Icon(
                                  size: w*.09,
                                  Icons.bookmark_border_sharp,
                                  color:Colors.black,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
