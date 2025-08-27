import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnify/Helpers/hive_helper.dart';
import 'package:learnify/courses/categories.dart';
import 'package:learnify/courses/course_details.dart';
import 'package:learnify/courses/cubit/courses_cubit.dart';
import 'package:learnify/home/models/courses_model.dart';
import 'package:learnify/widgets/texts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PopularCourses extends StatefulWidget {
  const PopularCourses({
    required this.categories,
    required this.courses,
    required this.screenName,
    required this.isBack,
    super.key,
  });

  final List<String> categories;
  final List<CoursesModel> courses;
  final String screenName;
  final bool isBack;

  @override
  State<PopularCourses> createState() => _PopularCoursesState();
}

class _PopularCoursesState extends State<PopularCourses> {
  @override
  void initState() {
    super.initState();
    context.read<CoursesCubit>().reset(widget.courses);
  }

  @override
  Widget build(BuildContext context) {
    final w = context.width;
    final cubit = context.read<CoursesCubit>();

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: Get.back,
          child: const Icon(Icons.arrow_back),
        ),
        title: Text('${widget.screenName}'),
        actions: widget.isBack ?[
          GestureDetector(
            onTap: () =>
                Get.to(() => Categories(allCategories: widget.categories)),
            child: const Icon(Icons.search),
          ),
          SizedBox(width: w * 0.02),
        ]:[],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<CoursesCubit, CoursesState>(
          builder: (context, state) {
            final courseList =
                state is CoursesSuccess ? state.courses : widget.courses;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            cubit.changeCat(
                              cat: widget.categories[index],
                              courses: widget.courses,
                            );
                          },
                          child: categoryCard(
                            index,
                            state is CoursesSuccess &&
                                    state.selectedCategory ==
                                        widget.categories[index]
                                ? index
                                : -1,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (state is CoursesLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: courseList.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final data = courseList[index];
                        return GestureDetector(
                          onTap: () => Get.to(CourseDetails(course: data)),
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data.category ?? 'No Category',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        data.title ?? 'No Title',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            data.points?.toString() ?? '0',
                                            style: const TextStyle(
                                                color: Colors.blue),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                BlocSelector<CoursesCubit, CoursesState, bool>(
                                  selector: (state) =>
                                      data.courseId != null &&
                                      HiveHelper.isSaved(data.courseId!),
                                  builder: (context, isSaved) {
                                    return GestureDetector(
                                      onTap: () {
                                        if (data.courseId != null) {
                                          if (isSaved) {
                                            cubit.unSaveCourse(data.courseId!);
                                          } else {
                                            cubit.saveCourse(data.courseId!);
                                          }
                                        }
                                      },
                                      child: Icon(
                                        isSaved
                                            ? Icons.bookmark
                                            : Icons.bookmark_border_sharp,
                                        size: w * 0.09,
                                        color: isSaved
                                            ? Colors.amberAccent
                                            : Colors.black,
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
            );
          },
        ),
      ),
    );
  }

  Widget categoryCard(int index, int selectedIndex) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: index == selectedIndex ? Colors.blue : Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        widget.categories[index],
        style: TextStyle(
          color: index == selectedIndex ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
