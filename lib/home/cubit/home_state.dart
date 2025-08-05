part of 'home_cubit.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeSearch extends HomeState {
  final String query;

  HomeSearch(this.query);
}

final class HomeSuccess extends HomeState {
  final List<String> results;
  HomeSuccess(this.results);
}

final class HomeGetDataSuccess extends HomeState {}

final class HomeFailure extends HomeState {
  final String error;
  HomeFailure(this.error);
}

final class HomeEmpty extends HomeState {
  final String message;
  HomeEmpty(this.message);
}
