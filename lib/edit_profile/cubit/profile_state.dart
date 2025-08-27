part of 'profile_cubit.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileEditing extends ProfileState {}

final class ProfileEditingLoading extends ProfileState {}

final class ProfileEditingSuccess extends ProfileState {}

final class ProfileEditingFailure extends ProfileState {}
