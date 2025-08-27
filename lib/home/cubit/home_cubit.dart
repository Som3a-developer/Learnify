import 'dart:developer';

import 'package:bloc/bloc.dart' hide Transition;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:learnify/Helpers/hive_helper.dart';
import 'package:learnify/firebase/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learnify/Helpers/dio_helper.dart';
import 'package:learnify/home/models/courses_model.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  bool isSearching = false;
  List<CoursesModel> model = [];
  List<CoursesModel> searchResults = [];

  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  List<String> allCategories = [];
  List<String> allPublishers = [];

  List<String> specificCourseCategory(List<CoursesModel> coursesList) {
    return coursesList
        .map((course) => course.category ?? "")
        .where((category) => category.isNotEmpty)
        .toList();
  }

  /// Get courses by category
  List<CoursesModel> getCoursesByCategory(String category,
      {List<CoursesModel>? courses}) {
    final lowerCategory = category.toLowerCase();
    return (courses ?? model).where((course) {
      final courseCategory = course.category?.toLowerCase() ?? '';
      return courseCategory == lowerCategory;
    }).toList();
  }

  List<CoursesModel> getEnrolledCourses() {
    try {
      final saved = HiveHelper.getEnrolledCourses();

      if (saved == null || saved.isEmpty) {
        Get.snackbar("Ooops..,", "No Enrolled Courses");
        return [];
      }

      final enrolledCourses = model.where((course) {
        final courseId = course.courseId ?? 0;
        return saved.contains(courseId);
      }).toList();

      return enrolledCourses;
    } catch (e) {
      Get.snackbar("Ooops..,", "No Enrolled Courses");
      return [];
    }
  }

  List<CoursesModel> getCoursesById() {
    try {
      final saved = HiveHelper.getSavedCourses();

      if (saved == null || saved.isEmpty) {
        Get.snackbar("Ooops..,", "No Enrolled Courses");
        return [];
      }

      final savedCourses = model.where((course) {
        final courseId = course.courseId ?? 0;
        return saved.contains(courseId);
      }).toList();

      return savedCourses;
    } catch (e) {
      Get.snackbar("Ooops..,", "No Enrolled Courses");
      return [];
    }
  }

  /// Get courses by publisher
  List<CoursesModel> getCoursesByPublisher(String publisher) {
    final lowerPublisher = publisher.toLowerCase();
    return model.where((course) {
      final coursePublisher = course.publisher?.toLowerCase() ?? '';
      return coursePublisher == lowerPublisher;
    }).toList();
  }

  Future<void> signout() async {
    emit(HomeLoading());
    await FirebaseAuthHelper.signOutUser();
    await HiveHelper.setToken(null);
    HiveHelper.clearEnrolledCourses();
    HiveHelper.clearUser();
    HiveHelper.clearCourses();
    emit(HomeInitial());
  }

  Future<void> getData({bool refresh = false}) async {
    if (!refresh) {
      emit(HomeLoading());
    }
    allCategories = HiveHelper.getCategories();
    allPublishers = HiveHelper.getPublishers();
    model = (HiveHelper.getCourses() as List)
        .map((e) => CoursesModel.fromJson(e))
        .toList();

    try {
      final response = await DioHelper.getData(path: "courses");
      model =
          (response.data as List).map((e) => CoursesModel.fromJson(e)).toList();

      await HiveHelper.setCourses(
          courses: model.map((e) => CoursesModel().toJson(e)).toList());

      final categoriesResponse = await DioHelper.getData(
        path: "rpc/get_distinct_categories",
      );

      allCategories = (categoriesResponse.data as List)
          .map<String>((v) => v.toString())
          .where((category) => category.isNotEmpty)
          .toList();
      final publishersResponse = await DioHelper.getData(
        path: "rpc/get_distinct_publishers",
      );

      allPublishers = (publishersResponse.data as List)
          .map<String>((v) => v.toString())
          .where((publisher) => publisher.isNotEmpty)
          .toList();

      await HiveHelper.setCategories(categories: allCategories);

      await HiveHelper.setPublishers(publishers: allPublishers);

      final enrolledResponse = (await DioHelper.getData(
          path: "enrollments",
          queryParameters: {"user_id": "eq.${HiveHelper.getToken()}"}));
      final enrolledData = enrolledResponse.data;
      await HiveHelper.clearEnrolledCourses();
      for (int i = 0; i < enrolledData.length; i++) {
        final course = enrolledData[i] as Map<String, dynamic>;
        await HiveHelper.setEnrolledCourses(
            enrolledcourse: course["course_id"]);
      }
    } catch (e) {
      emit(HomeGetDataError('Failed to load data'));
      return;
    }
    emit(HomeGetDataSuccess());
  }

  /// Performs search on courses with improved performance and error handling
  void performSearch(String query) {
    try {
      searchQuery = query.trim();
      isSearching = searchQuery.isNotEmpty;

      if (!isSearching) {
        searchResults = [];
        emit(HomeInitial());
        return;
      }

      final lowerQuery = searchQuery.toLowerCase();

      searchResults = model.where((course) {
        final title = course.title?.toLowerCase() ?? '';
        final category = course.category?.toLowerCase() ?? '';
        final publisher = course.publisher?.toLowerCase() ?? '';
        final description = course.description?.toLowerCase() ?? '';

        return title.contains(lowerQuery) ||
            category.contains(lowerQuery) ||
            publisher.contains(lowerQuery) ||
            description.contains(lowerQuery);
      }).toList();

      emit(HomeSearch(searchQuery));
    } catch (e) {
      searchResults = [];
      emit(HomeSearchError('Failed to perform search'));
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery = '';
    isSearching = false;
    emit(HomeInitial());
  }
}
