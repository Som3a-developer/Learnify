import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learnify/Helpers/dio_helper.dart';
import 'package:learnify/Helpers/hive_helper.dart';
import 'package:learnify/auth/fill_profile.dart';
import 'package:learnify/auth/not_verified.dart';
import 'package:learnify/home/Home.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/login_screen.dart';

class FirebaseAuthHelper {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  static Future<UserCredential> registerUser(
      BuildContext context, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user!.sendEmailVerification();
      await HiveHelper.setToken(credential.user!.uid);
      await HiveHelper.setUser(email: credential.user!.email);

      Get.snackbar("Email Verification", "Please verify your account.",
          backgroundColor: Colors.green, colorText: Colors.white);

      Get.to(
          () => FillProfile(
                token: credential.user!.uid,
              ),
          transition: Transition.native,
          duration: const Duration(seconds: 1));

      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return _showError("The password provided is too weak.");
      } else if (e.code == 'email-already-in-use') {
        return _showError("The account already exists for that email.");
      }
    } catch (e) {
      return _showError(e.toString());
    }
    return Future.error("Unknown error");
  }

  static Future<void> saveUserInfo({
    required String uid,
    required String name,
    required String phone,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await DioHelper.postData(
      path: "users",
      body: {
        "user_name": name,
        "phone": phone,
        "user_id": uid,
        "email": _auth.currentUser!.email,
        "last_login": DateTime.now().toString()
      },
      prefer: "resolution=merge-duplicates",
    );
  }

  static Future<void> getUserData() async {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      Get.offAll(LoginScreen());
      return;
    }

    final response = await DioHelper.getData(
      path: "users",
      queryParameters: {"user_id": "eq.$uid"},
    );

    final data = response.data;

    if (data is List && data.isNotEmpty) {
      final user = data[0] as Map<String, dynamic>;
      await HiveHelper.setToken(uid);
      await HiveHelper.setUser(
        email: user['email'],
        name: user['user_name'],
        phone: user['phone'],
      );
    } else {
      Get.offAll(LoginScreen());
      Get.snackbar(
        "Failed",
        "bad connection",
        backgroundColor: Colors.red,
      );
    }
  }

  static Future<UserCredential> signInUser(
      BuildContext context, String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      if (_auth.currentUser!.emailVerified) {
        final firstTime = await isFirstTime(credential.user!.uid);

        if (firstTime) {
          await HiveHelper.setUser(email: credential.user!.email);
          Get.offAll(
              () => FillProfile(
                    token: credential.user!.uid,
                  ),
              transition: Transition.native,
              duration: const Duration(seconds: 1));
        } else {
          await getUserData();
          Get.offAll(() => Home(),
              transition: Transition.native,
              duration: const Duration(seconds: 1));
        }

        return credential;
      } else {
        Get.snackbar("Email Verification", "Please verify your account.",
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.offAll(() => NotVerifiedScreen(),
            transition: Transition.native,
            duration: const Duration(seconds: 1));
        return Future.error("Email not verified");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return _showError("No user found for that email.");
      } else if (e.code == 'wrong-password') {
        return _showError("Wrong password provided.");
      } else if (e.code == 'invalid-email' ||
          e.code == 'malformed-credential') {
        return _showError("Invalid email or malformed credential.");
      } else {
        return _showError("Wrong E-mail or Password.");
      }
    } catch (e) {
      return _showError(e.toString());
    }
  }

  static Future<void> resendVerificationEmail() async {
    try {
      await _auth.currentUser!.sendEmailVerification();
      Get.snackbar("Email Sent", "Verification email has been sent.",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      _showError("Failed to send verification email: $e");
    }
  }

  static Future<void> signOutUser() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await FirebaseAuth.instance.signOut();

      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect();
      }
      Get.offAll(() => LoginScreen());
      Get.snackbar("Sign Out", "You have been signed out.",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Sign Out", " There is a problem.",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  static Future<bool> isFirstTime(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return !doc.exists;
  }

  static Future<void> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final firstTime = await isFirstTime(userCredential.user!.uid);
        await HiveHelper.setToken(userCredential.user!.uid);

        if (firstTime) {
          Get.snackbar("Let's get you in", "Fill your profile.",
              backgroundColor: Colors.green, colorText: Colors.white);
          Get.offAll(
              () => FillProfile(
                    token: HiveHelper.getToken()!,
                  ),
              transition: Transition.native,
              duration: const Duration(seconds: 1));
        } else {
          await getUserData();

          Get.snackbar("Welcome", "Google sign-in succeeded.",
              backgroundColor: Colors.green, colorText: Colors.white);
          Get.offAll(() => Home(),
              transition: Transition.native,
              duration: const Duration(seconds: 1));
        }
      }
    } catch (e) {
      _showError("Google sign-in failed, please try again.,$e");
    }
  }

  Future<void> forgetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar("Password Reset", "Check your email to reset password.",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      _showError("Please check the email you entered.");
    }
  }

  static Future<UserCredential> _showError(String message) {
    Get.snackbar("Error", message,
        backgroundColor: Colors.red, colorText: Colors.white);
    return Future.error(message);
  }

  static Future<void> deleteAccount({
    String? email,
    String? password,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user signed in");

    try {
      final providers = user.providerData.map((p) => p.providerId).toList();

      // ✅ Google re-auth
      if (providers.contains("google.com")) {
        final googleUser = await GoogleSignIn().signInSilently();
        final googleAuth = await googleUser?.authentication;
        if (googleAuth == null) throw Exception("Google re-auth failed");

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await user.reauthenticateWithCredential(credential);
      }

      // ✅ Email re-auth
      if (providers.contains("password")) {
        if (email == null || password == null) {
          throw Exception("Email and password required");
        }
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }

      final uid = user.uid;

      // ✅ Firestore
      await _firestore.collection("users").doc(uid).delete();

      // ✅ Supabase (عن طريق DioHelper)
      await DioHelper.deleteData(
        path: "users",
        queryParameters: {"user_id": "eq.$uid"},
      );

      // لو عندك جداول تانية في Supabase لازم تكرر نفس الخطوة
      final supabaseTables = {
        "users": "user_id",
        "enrollments": "user_id",
        "courses": "publisher", // غيّر حسب العمود الصحيح
      };
      for (final entry in supabaseTables.entries) {
        await DioHelper.deleteData(
          path: entry.key,
          queryParameters: {
            entry.value: entry.value == "created_by"
                ? "eq.${HiveHelper.getUserName()}"
                : "eq.$uid"
          },
        );
      }

      // ✅ FirebaseAuth
      await user.delete();

      // ✅ Sign out
      await signOutUser();

      Get.snackbar("Deleted", "Account deleted successfully",
          backgroundColor: Colors.green, colorText: Colors.white);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception("Wrong password");
      } else if (e.code == 'requires-recent-login') {
        throw Exception("Reauthentication required");
      } else {
        throw Exception("Auth error: ${e.message}");
      }
    } catch (e) {
      throw Exception("Error deleting account: $e");
    }
  }

  // Change password
  static Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        Get.snackbar("Error", "No user signed in",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      // Re-authenticate
      final cred = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(cred);

      // Update password
      await user.updatePassword(newPassword);

      Get.snackbar("Success", "Password changed successfully",
          backgroundColor: Colors.green, colorText: Colors.white);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        Get.snackbar("Error", "Current password is incorrect",
            backgroundColor: Colors.red, colorText: Colors.white);
      } else if (e.code == 'weak-password') {
        Get.snackbar("Error", "The new password is too weak",
            backgroundColor: Colors.red, colorText: Colors.white);
      } else {
        Get.snackbar("Error", "Password change failed: ${e.message}",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
