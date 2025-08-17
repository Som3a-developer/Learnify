part of 'home_cubit.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeGetDataSuccess extends HomeState {}

class HomeGetDataError extends HomeState {
  final String message;
  HomeGetDataError(this.message);
}

class HomeSearch extends HomeState {
  final String query;
  HomeSearch(this.query);
}

class HomeSearchError extends HomeState {
  final String message;
  HomeSearchError(this.message);
}
