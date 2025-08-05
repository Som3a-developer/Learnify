import 'package:flutter/cupertino.dart';
import 'package:learnify/Helpers/hive_helper.dart';
import 'package:learnify/courses/course_details.dart';
import 'package:learnify/courses/popular_courses.dart';
import 'package:learnify/home/cubit/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:learnify/widgets/texts.dart';
import 'package:learnify/const.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:learnify/widgets/custom_search_bar.dart';
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
        ? HiveHelper.getCategories()
        : cubit.allCategories;
    final List<String> publishers = cubit.allPublishers.isEmpty
        ? HiveHelper.getPublishers()
        : cubit.allPublishers;
    final List<Map<String, dynamic>>? courses = cubit.allCourses.isEmpty
        ? HiveHelper.getCourses()
        : cubit.allCourses
            .map((doc) => Map<String, dynamic>.from(doc.data() as Map))
            .toSet()
            .toList();

    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) async {},
      builder: (context, state) {
        return state is HomeLoading
            ? Center(child: CircularProgressIndicator())
            : state is HomeFailure
                ? Center(child: boldtexts("Please refresh"))
                : Scaffold(
                    backgroundColor: Colors.white,
                    appBar: AppBar(
                      elevation: 0,
                      backgroundColor: Colors.white,
                      toolbarHeight: width * 0.2,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          boldtexts('Hi,  ${HiveHelper.getUserName()}'),
                          SizedBox(height: 4),
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
                              child: Icon(Icons.person, color: Colors.black),
                              onTap: () async {
                                await cubit.signout();
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                    body: GestureDetector(
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
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
                              Text('Search Results for " ${cubit.searchQuery}"',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: width * 0.03),
                              if (cubit.searchResults.isEmpty)
                                Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.search_off,
                                          size: 50, color: Colors.grey),
                                      SizedBox(height: 10),
                                      Text('No courses found'),
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
                                                id: course['id'],
                                                title: course['title'],
                                                category: course['category'],
                                                price: course['price'],
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    boldtexts('25% OFF', color: Colors.white),
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
                                        style: TextStyle(color: blueColor())),
                                    onTap: () => Get.to(() =>
                                        Categories(allCategories: categories)),
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
                                      padding:
                                          EdgeInsets.only(right: width * 0.02),
                                      child: categoryChip(cat, context),
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
                                        style: TextStyle(color: blueColor())),
                                    onTap: () => Get.to(() =>
                                        PopularCourses(categories: categories)),
                                  ),
                                ],
                              ),
                              SizedBox(height: width * 0.03),
                              SizedBox(
                                height: height * 0.25,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: courses!.take(4).length,
                                  itemBuilder: (context, index) {
                                    final Map<String, dynamic> course =
                                        courses[index];
                                    return Padding(
                                      padding:
                                          EdgeInsets.only(right: width * 0.03),
                                      child: GestureDetector(
                                        onTap: () => Get.to(() =>
                                            CourseDetails(course: course)),
                                        child: courseCard(
                                          id: course['id'],
                                          title: course['title'] ?? "-",
                                          category: course['category'] ?? "-",
                                          price: course['price'] ?? "-",
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
                                      padding:
                                          EdgeInsets.only(right: width * 0.03),
                                      child: mentorAvatar(course[index], width),
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
                  );
      },
    );
  }

  Widget categoryChip(String text, BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text),
      ),
    );
  }

  Widget courseCard({
    required int id,
    required String title,
    required String category,
    required String price,
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
              style: TextStyle(fontSize: 12, color: Colors.orange),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: height * 0.005),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: height * 0.005),
            Text(
              '\$$price   |   $students Std',
              style: TextStyle(fontSize: 12, color: Colors.grey),
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
        SizedBox(height: 6),
        Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}
