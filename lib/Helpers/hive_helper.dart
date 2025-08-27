import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Manages all local storage operations using Hive
/// Handles user data, courses cache and onboarding state
class HiveHelper {
  static const onboardingBox = "ONBOARDING_BOX";
  static const userBox = "USER_BOX";
  static const coursesBox = "COURSES_BOX";
  static const enrolledCoursesBox = "ENROLLED_COURSES";
  static const savedCoursesBox = "SAVED_COURSES";
  static const qrCounterBox="QR_COUNTER";

  /// Sets onboarding completion flag
  static Future<void> setValueInOnboardingBox() async {
    try {
      final box = await Hive.openBox(onboardingBox);
      await box.put(onboardingBox, true);
    } catch (e) {
      throw Exception('Failed to set onboarding value: ${e.toString()}');
    }
  }

  /// Checks if onboarding was completed
  static bool checkOnBoardingValue() {
    try {
      return Hive.box(onboardingBox).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Saves user token to local storage
  static Future<void> setToken(String? tokenParam) async {
    try {
      final box = await Hive.openBox(userBox);
      await box.put("token", tokenParam);
    } catch (e) {
      throw Exception('Failed to set token: ${e.toString()}');
    }
  }

  /// Retrieves user token from local storage
  static String? getToken() {
    try {
      final box = Hive.box(userBox);
      return box.isNotEmpty ? box.get("token") : null;
    } catch (e) {
      return null;
    }
  }

  /// Saves user data to local storage
  static Future<void> setUser({
    String? name,
    String? email,
    String? phone,
  }) async {
    try {
      final box = await Hive.openBox(userBox);
      await box.putAll({
        "name": name,
        "email": email,
        "phone": phone,
      });
    } catch (e) {
      throw Exception('Failed to set user data: ${e.toString()}');
    }
  }

  /// Saves courses data to local cache
  static Future<void> setCourses({
    List<Map<String, dynamic>>? courses,
  }) async {
    try {
      await Hive.box(HiveHelper.coursesBox).put(
        "courses",
        courses!.map((e) => Map<String, dynamic>.from(e)).toList(),
      );
    } catch (e) {
      throw Exception('Failed to set courses: ${e.toString()}');
    }
  }

  static Future<void> setCategories({
    required List<String> categories,
  }) async {
    try {
      await Hive.box(HiveHelper.coursesBox).put(
        "categories",
        categories!,
      );
    } catch (e) {
      throw Exception('Failed to set categories: ${e.toString()}');
    }
  }

  static Future<void> setPublishers({
    required List<String> publishers,
  }) async {
    try {
      await Hive.box(HiveHelper.coursesBox).put(
        "publishers",
        publishers,
      );
    } catch (e) {
      throw Exception('Failed to set categories: ${e.toString()}');
    }
  }

  static Future<void> setEnrolledCourses({
    int? enrolledcourse,
  }) async {
    try {

      // جلب البيانات وتحويلها لأرقام لو كانت Strings
      List<dynamic> stored =
          Hive.box(HiveHelper.enrolledCoursesBox).get("enrolledcourses") ?? [];

      List<int> enrolledCourses =
          stored.map((e) => e is String ? int.parse(e) : e as int).toList();

      enrolledCourses.add(enrolledcourse!);

      await Hive.box(HiveHelper.enrolledCoursesBox).put(
        "enrolledcourses",
        enrolledCourses,
      );
    } catch (e) {
      throw Exception('Failed to set enrolledCourses: ${e.toString()}');
    }
  }

  static Future<void> setSavedCourses(int id) async {
    try {
      // جلب البيانات وتحويلها لأرقام لو كانت Strings
      List<int> stored =
          Hive.box(HiveHelper.savedCoursesBox).get("savedcourses") ?? [];

      stored.add(id);

      await Hive.box(HiveHelper.savedCoursesBox).put(
        "savedcourses",
        stored,
      );
    } catch (e) {
      throw Exception('Failed to set enrolledCourses: ${e.toString()}');
    }
  }

/// Set qrCounter
    static Future<void> setQrCounter({int? qr})async{
    try{
      await Hive.box(HiveHelper.qrCounterBox).put("qr", qr);
    }catch(e){
      throw Exception('Failed to set qr: ${e.toString()}');
    }
  }

  /// Retrieves user name from local storage
  static String? getUserName() {
    try {
      return Hive.box(userBox).get("name");
    } catch (e) {
      return null;
    }
  }

  /// Retrieves user email from local storage
  static String? getUserEmail() {
    try {
      return Hive.box(userBox).get("email");
    } catch (e) {
      return null;
    }
  }

  /// Retrieves user phone from local storage
  static String? getUserPhone() {
    try {
      return Hive.box(userBox).get("phone");
    } catch (e) {
      return null;
    }
  }

  /// Retrieves cached courses from local storage
  static List<Map<String, dynamic>> getCourses() {
    try {
      final box = Hive.box(coursesBox);
      final rawList = box.get("courses");
      if (rawList == null || rawList is! List) return [];

      return rawList
          .whereType<Map>()
          .map((e) => e.map(
                (key, value) => MapEntry(key.toString(), value),
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Retrieves unique categories from cached courses
  static List<String> getCategories() {
    try {
      if (Hive.box(coursesBox).isEmpty) return [];
      return Hive.box(coursesBox).get("categories");
    } catch (e) {
      return [];
    }
  }

  /// Retrieves unique publishers from cached courses
  static List<String> getPublishers() {
    try {
      if (Hive.box(coursesBox).isEmpty) return [];
      return Hive.box(coursesBox).get("publishers");
    } catch (e) {
      return [];
    }
  }

  static List<int>? getEnrolledCourses() {
    try {
      return Hive.box(enrolledCoursesBox).get("enrolledcourses");
    } catch (e) {
      return [];
    }
  }

  static List<int>? getSavedCourses() {
    try {
      return Hive.box(savedCoursesBox).get("savedcourses");
    } catch (e) {
      return [];
    }
  }

  static bool isSaved(int id) {
    final savedcourses = getSavedCourses();
    if (savedcourses == null) return false;
    if (savedcourses.contains(id)) {
      return true;
    } else {
      return false;
    }
  }

  static bool isEnrolled(int? courseid) {
    final list = Hive.box(enrolledCoursesBox).get("enrolledcourses");
    if (list is List) {
      return list.contains(courseid);
    }
    return false;
  }
static Future<int> getQrCounter()async{
    return await Hive.box(HiveHelper.qrCounterBox).get("qr")??7;
}
  /// Clears all user data from local storage
  static void clearUser() {
    try {
      Hive.box(userBox).clear();
    } catch (e) {
      throw Exception('Failed to clear user data: ${e.toString()}');
    }
  }

  /// Clears token from local storage
  static void clearToken() {
    try {
      Hive.box(userBox).delete("token");
    } catch (e) {
      throw Exception('Failed to clear token: ${e.toString()}');
    }
  }

  /// Clears courses cache from local storage
  static void clearCourses() {
    try {
      Hive.box(coursesBox).clear();
    } catch (e) {
      throw Exception('Failed to clear courses: ${e.toString()}');
    }
  }

  static Future<void> clearEnrolledCourses() async{
    try {
    await  Hive.box(enrolledCoursesBox).clear();
    } catch (e) {
      throw Exception('Failed to clear courses: ${e.toString()}');
    }
  }

  static Future<void> unSaveCourse(int id) async {
    try {
      // جلب البيانات وتحويلها لأرقام لو كانت Strings
      List<int> stored =
          Hive.box(HiveHelper.savedCoursesBox).get("savedcourses") ?? [];

      stored.remove(id);

      await Hive.box(HiveHelper.savedCoursesBox).put(
        "savedcourses",
        stored,
      );
    } catch (e) {
      throw Exception('Failed to set enrolledCourses: ${e.toString()}');
    }
  }
}
