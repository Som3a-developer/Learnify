part of 'courses_cubit.dart';

@immutable
sealed class CoursesState {}

final class CoursesInitial extends CoursesState {}
final class CoursesLoading extends CoursesState {}
final class CoursesSuccess extends CoursesState {}
final class CoursesFailed extends CoursesState {}
