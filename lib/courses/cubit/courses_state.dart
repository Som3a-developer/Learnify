part of 'courses_cubit.dart';

sealed class CoursesState {}

class CoursesInitial extends CoursesState {}

class CoursesLoading extends CoursesState {}

class CoursesSuccess extends CoursesState {
  final List<CoursesModel> courses;
  final String? selectedCategory;

  CoursesSuccess({required this.courses, this.selectedCategory});
}

class CoursesFailed extends CoursesState {}