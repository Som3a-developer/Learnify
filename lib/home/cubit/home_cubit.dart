import 'package:bloc/bloc.dart' hide Transition;
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:learnify/Helpers/hive_helper.dart';
import 'package:learnify/firebase/firebase_auth.dart';
import 'package:learnify/firebase/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  bool isSearching = false;
  List<QueryDocumentSnapshot> allCourses = [];
  List<Map<String, dynamic>> searchResults = [];
  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  List<String> allCategories = [];

  List<String> allPublishers = [];
  Future<void> signout() async {
    emit(HomeLoading());
    await FirebaseAuthHelper().signOutUser();
    await HiveHelper.setToken(null);
    HiveHelper.clearUser();
    emit(HomeInitial());
  }

  Future<void> getData() async {
    emit(HomeLoading());
    try {
      final List<Map<String, dynamic>> cashe;
      allCourses = await Firestore().getData();
      cashe = allCourses
          .map((doc) => Map<String, dynamic>.from(doc.data() as Map))
          .toSet()
          .toList();

      await HiveHelper.setCourses(courses: cashe);
      allCategories = allCourses
          .map(
              (doc) => Map<String, dynamic>.from(doc.data() as Map)['category'])
          .whereType<String>()
          .map((e) => e.trim().toLowerCase())
          .toSet()
          .toList();

      allPublishers = allCourses.isEmpty
          ? HiveHelper.getPublishers()
          : allCourses
              .map((doc) => doc['publisher']?.toString() ?? '')
              .where((publisher) => publisher.isNotEmpty)
              .toSet()
              .toList();
      final categoriesSet = <String, String>{};
      final publisheresSet = <String, String>{};
      for (var doc in allCourses) {
        final data = Map<String, dynamic>.from(doc.data() as Map);
        final cat = data['category'];
        if (cat is String) {
          categoriesSet[cat.trim().toLowerCase()] = cat.trim();
          final pub = data['publisher'];
          if (pub is String) {
            publisheresSet[pub.trim().toLowerCase()] = pub.trim();
          }
        }
      }
      allCategories = categoriesSet.values.toList();
      allPublishers = publisheresSet.values.toList();
      HiveHelper.setCategories(categories: allCategories);
      await HiveHelper.setPublishers(publishers: allPublishers);
      print(allCourses[0]["category"]);
    } catch (e) {
      print(e.toString());
    }
    emit(HomeGetDataSuccess());
  }

  /// Searches [allCourses] for courses whose title or category contains [query].
  ///
  /// If [query] is not empty, sets [searchResults] to the filtered list and
  /// emits [HomeSearch] with [query].
  ///
  /// If [query] is empty, does nothing.
  ///
  void performSearch(String query) {
    searchQuery = query;
    isSearching = query.isNotEmpty;

    if (isSearching) {
      searchResults = allCourses
          .map((doc) => Map<String, dynamic>.from(doc.data() as Map))
          .where((course) =>
              (course['title'] ?? '')
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              (course['category'] ?? '')
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
      emit(HomeSearch(query));
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery = '';
    isSearching = false;
    emit(HomeInitial());
  }
}
