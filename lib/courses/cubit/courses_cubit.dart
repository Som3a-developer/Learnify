import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:learnify/Helpers/hive_helper.dart';
import 'package:learnify/home/cubit/home_cubit.dart';
import 'package:learnify/home/models/courses_model.dart';
import 'package:learnify/widgets/qr_viewer.dart';

part 'courses_state.dart';

class CoursesCubit extends Cubit<CoursesState> {
  final HomeCubit homeCubit;

  CoursesCubit({required this.homeCubit}) : super(CoursesInitial());

  List<CoursesModel> _currentCourses = [];

  List<int> get saved => HiveHelper.getSavedCourses() ?? [];

  void reset(List<CoursesModel> courses) {
    _currentCourses = courses;
    emit(CoursesSuccess(courses: courses, selectedCategory: null));
  }

  void changeCat({required String cat, required List<CoursesModel> courses}) {
    emit(CoursesLoading());
    try {
      final filteredCourses = homeCubit.getCoursesByCategory(cat, courses: courses);
      _currentCourses = filteredCourses;
      emit(CoursesSuccess(courses: filteredCourses, selectedCategory: cat));
    } catch (e) {
      emit(CoursesFailed());
      Get.snackbar('Error', 'Failed to filter courses');
    }
  }

  Future<void> saveCourse(int id) async {
    emit(CoursesLoading());
    try {
      if (await HiveHelper.isSaved(id)) {
        Get.snackbar('Warning', 'Course already saved');
        emit(CoursesSuccess(courses: _currentCourses));
      } else {
        await HiveHelper.setSavedCourses(id);
        emit(CoursesSuccess(courses: _currentCourses));
      }
    } catch (e) {
      emit(CoursesFailed());
      Get.snackbar('Error', 'Failed to save course: $e');
    }
  }

  Future<void> unSaveCourse(int id) async {
    emit(CoursesLoading());
    try {
      await HiveHelper.unSaveCourse(id);
      emit(CoursesSuccess(courses: _currentCourses));
    } catch (e) {
      emit(CoursesFailed());
      Get.snackbar('Error', 'Failed to unsave course: $e');
    }
  }

  Future<void> setEnrolled({
    required String userId,
    required int courseId,
    required int points,
  }) async {
    emit(CoursesLoading());
    Get.to(
          () => QrViewer(
        points: points,
        courseId: courseId,
        userId: userId,
        onResult: (bool success) {
          if (success) {
            emit(CoursesSuccess(courses: _currentCourses));
          } else {
            emit(CoursesFailed());
            Get.snackbar('Error', 'Failed to enroll in course');
          }
        },
      ),
      preventDuplicates: true,
    );
  }

  bool isEnrolled({int? courseId}) {
    if (courseId == null) return false;
    try {
      final enrolled = HiveHelper.getEnrolledCourses();
      return enrolled?.contains(courseId) ?? false;
    } catch (e) {
      return false;
    }
  }
}