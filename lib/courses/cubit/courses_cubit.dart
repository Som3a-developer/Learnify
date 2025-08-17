import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:learnify/Helpers/dio_helper.dart';
import 'package:learnify/Helpers/hive_helper.dart';
import 'package:meta/meta.dart';

part 'courses_state.dart';

class CoursesCubit extends Cubit<CoursesState> {
  CoursesCubit() : super(CoursesInitial());
  final List<int> saved = HiveHelper.getSavedCourses() ?? [];

  Future<void> saveCourse(int id) async {
    emit(CoursesLoading());
    try {
      if (await HiveHelper.isSaved(id)) {
        Get.snackbar("oops..,", "Already saved");
        emit(CoursesInitial());
      } else {
        await HiveHelper.setSavedCourses(id);
        emit(CoursesSuccess());
      }
    } catch (e) {
      emit(CoursesFailed());
      Get.snackbar("Error", "$e");
    }
  }

  Future<void> unSaveCourse(int id) async {
    emit(CoursesLoading());
    await HiveHelper.unSaveCourse(id);
    emit(CoursesSuccess());
  }

  Future<void> setEnrolled(
      {required String userId, required int courseId}) async {
    try {
      await DioHelper.postData(
        path: "enrollments",
        body: {"user_id": userId, "course_id": courseId},
      );
      await HiveHelper.setEnrolledCourses(enrolledcourse: courseId);
    } catch (e) {
      Get.snackbar(
        "Failed",
        e.toString(),
        backgroundColor: Colors.red,
      );
    }
  }

  bool isEnrolled({int? courseId}) {
    if (courseId == null) return false;
    try {
      final enrolled = HiveHelper.getEnrolledCourses();
      if (enrolled!.contains(courseId)) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      Get.snackbar("Erorr", e.toString());
      return false;
    }
  }
}
