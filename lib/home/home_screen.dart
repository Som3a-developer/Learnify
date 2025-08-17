import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:learnify/Helpers/hive_helper.dart';
import 'package:learnify/courses/course_details.dart';
import 'package:learnify/courses/popular_courses.dart';
import 'package:learnify/home/cubit/home_cubit.dart';
import 'package:learnify/home/models/courses_model.dart';
import 'package:learnify/widgets/texts.dart';
import 'package:learnify/const.dart';
import 'package:learnify/widgets/custom_search_bar.dart';
import 'package:learnify/widgets/warp_indicator.dart';
import '../courses/categories.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final cubit = context.read<HomeCubit>();

    final List<String> categories = cubit.allCategories.isEmpty
        ? HiveHelper.getCategories().isNotEmpty
            ? HiveHelper.getCategories()
            : []
        : cubit.allCategories;
    final List<String> publishers = cubit.allPublishers.isEmpty
        ? HiveHelper.getPublishers().isNotEmpty
            ? HiveHelper.getPublishers()
            : []
        : cubit.allPublishers;
    final List<CoursesModel> courses = cubit.model.isEmpty
        ? HiveHelper.getCourses().isNotEmpty
            ? HiveHelper.getCourses()
                .map((e) => CoursesModel.fromJson(e))
                .toList()
            : []
        : cubit.model;

    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) async {},
      builder: (context, state) {
        return state is HomeLoading
            ? const Center(child: CircularProgressIndicator())
            : Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  toolbarHeight: width * 0.2,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      boldtexts('Hi, ${HiveHelper.getUserName()}'),
                      const SizedBox(height: 4),
                      normaltexts(
                          'What Would you like to learn Today? Search Below.'),
                    ],
                  ),
                  actions: [
                    Padding(
                      padding: EdgeInsets.all(width * 0.03),
                      child: CircleAvatar(
                        radius: width * 0.05,
                        backgroundColor: Colors.grey.shade200,
                        child: GestureDetector(
                          child: const Icon(Icons.person, color: Colors.black),
                          onTap: () async {
                            await cubit.signout();
                          },
                        ),
                      ),
                    )
                  ],
                ),
                body: WarpIndicator(
                  starsCount: 25,
                  skyColor: Colors.transparent,
                  starColorGetter: (index) => blueColor(),
                  onRefresh: () async {
                    await cubit.getData(refresh: true);
                  },
                  child: state is HomeGetDataError
                      ? Center(child: boldtexts("Please refresh"))
                      : GestureDetector(
                          onTap: () => FocusScope.of(context).unfocus(),
                          child: SingleChildScrollView(
                            padding:
                                EdgeInsets.symmetric(horizontal: width * 0.05),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: width * 0.03),
                                CustomSearchBar(
                                  width: width,
                                  controller: cubit.searchController,
                                  onChanged: cubit.performSearch,
                                  onSubmitted: cubit.performSearch,
                                  onClear: cubit.clearSearch,
                                ),
                                SizedBox(height: width * 0.05),
                                if (cubit.isSearching) ...[
                                  Text(
                                      'Search Results for "${cubit.searchQuery}"',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: width * 0.03),
                                  if (cubit.searchResults.isEmpty)
                                    Center(
                                      child: Column(
                                        children: [
                                          const Icon(Icons.search_off,
                                              size: 50, color: Colors.grey),
                                          const SizedBox(height: 10),
                                          const Text('No courses found'),
                                        ],
                                      ),
                                    )
                                  else
                                    Column(
                                      children: cubit.searchResults
                                          .take(4)
                                          .map((course) => Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: width * 0.03),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Get.to(() => CourseDetails(
                                                        course: course));
                                                  },
                                                  child: courseCard(
                                                    title: course.title!,
                                                    category: course.category!,
                                                    points: course.points!,
                                                    width: width,
                                                    height: height,
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  SizedBox(height: width * 0.06),
                                ] else ...[
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(width * 0.04),
                                    decoration: BoxDecoration(
                                      color: blueColor(),
                                      borderRadius:
                                          BorderRadius.circular(width * 0.05),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        boldtexts('25% OFF',
                                            color: Colors.white),
                                        SizedBox(height: width * 0.015),
                                        normaltexts("Today's Special",
                                            color: Colors.white),
                                        SizedBox(height: width * 0.015),
                                        normaltexts(
                                            'Get a Discount for Every Course Order only valid for Today!',
                                            color: Colors.white),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: width * 0.06),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      boldtexts('Categories'),
                                      GestureDetector(
                                        child: Text('See All',
                                            style:
                                                TextStyle(color: blueColor())),
                                        onTap: () => Get.to(() => Categories(
                                            allCategories: categories)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: width * 0.03),
                                  SizedBox(
                                    height: 40,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: categories.length,
                                      itemBuilder: (context, index) {
                                        final cat = categories[index];
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              right: width * 0.02),
                                          child: GestureDetector(
                                              onTap: () {
                                                Get.to(PopularCourses(
                                                    categories: [cat],
                                                    courses: cubit
                                                        .getCoursesByCategory(
                                                            cat)));
                                              },
                                              child:
                                                  categoryChip(cat, context)),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(height: width * 0.06),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      boldtexts('Popular Courses'),
                                      GestureDetector(
                                        child: Text('See All',
                                            style:
                                                TextStyle(color: blueColor())),
                                        onTap: () =>
                                            Get.to(() => PopularCourses(
                                                  categories: categories,
                                                  courses: [],
                                                )),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: width * 0.03),
                                  SizedBox(
                                    height: height * 0.25,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: courses.take(4).length,
                                      itemBuilder: (context, index) {
                                        final CoursesModel course =
                                            courses[index];
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              right: width * 0.03),
                                          child: GestureDetector(
                                            onTap: () => Get.to(() =>
                                                CourseDetails(course: course)),
                                            child: courseCard(
                                              title: course.title ?? "-",
                                              category: course.category ?? "-",
                                              points: course.points ?? 0,
                                              width: width,
                                              height: height,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(height: width * 0.06),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      boldtexts('Mentors'),
                                      Text('See All',
                                          style: TextStyle(color: blueColor())),
                                    ],
                                  ),
                                  SizedBox(height: width * 0.03),
                                  SizedBox(
                                    height: width * 0.3,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemExtent: width * 0.2,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: publishers.length,
                                      itemBuilder: (context, index) {
                                        final course = publishers;
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              right: width * 0.03),
                                          child: mentorAvatar(
                                              course[index], width),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(height: width * 0.06),
                                ],
                              ],
                            ),
                          ),
                        ),
                ),
              );
      },
    );
  }

  Widget categoryChip(String text, BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text),
      ),
    );
  }

  Widget courseCard({
    required String title,
    required String category,
    required int points,
    String students = "-",
    required double width,
    required double height,
  }) {
    return GestureDetector(
      child: Container(
        width: width * 0.45,
        padding: EdgeInsets.all(width * 0.03),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(width * 0.04),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: height * 0.1,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(width * 0.03),
              ),
            ),
            SizedBox(height: height * 0.015),
            Text(
              category,
              style: const TextStyle(fontSize: 12, color: Colors.orange),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: height * 0.005),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: height * 0.005),
            Text(
              '\$$points   |   $students Std',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget mentorAvatar(String name, double width) {
    return Column(
      children: [
        CircleAvatar(radius: width * 0.08, backgroundColor: Colors.black),
        const SizedBox(height: 6),
        Text(name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}
