import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learnify/Helpers/hive_helper.dart';
import 'package:learnify/auth/fill_profile.dart';
import 'package:learnify/auth/not_verified.dart';
import 'package:learnify/home/Home.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/login_screen.dart';

class FirebaseAuthHelper {
  static Future<UserCredential> registerUser(
      BuildContext context, String emailAddress, String password) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      FirebaseAuth.instance.currentUser!.sendEmailVerification();
      Get.snackbar(
        "Email Verification",
        "Please verify your account.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      await HiveHelper.setToken(credential.user!.uid);
      await HiveHelper.setUser(email: credential.user!.email);
      Get.to(FillProfile(),
          transition: Transition.native, duration: const Duration(seconds: 1));
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Get.snackbar(
          "Error",
          "The password provided is too weak.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return Future.error("Weak password");
      } else if (e.code == 'email-already-in-use') {
        Get.snackbar(
          "Error",
          "The account already exists for that email.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return Future.error("Email already in use");
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return Future.error("An error occurred");
    }
    return Future.error("Unknown error");
  }

  static Future<void> saveUserInfo({
    required String uid,
    required String name,
    required String phone,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> getUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    final docSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      await HiveHelper.setUser(
          email: data?['email'], name: data?['name'], phone: data?['phone']);
    } else {
      print('User data not found');
    }
  }

  // Now signInUser is a class method and accessible.
  static Future<UserCredential> signInUser(
      BuildContext context, String emailAddress, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailAddress, password: password);
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        final firstTime = await isFirstTime(credential.user!.uid);

        if (firstTime) {
          await HiveHelper.setUser(email: credential.user!.uid);
          await HiveHelper.setUser(email: credential.user!.email);
          Get.offAll(() => FillProfile(),
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
        Get.snackbar(
          "Email Verification",
          "Please verify your account.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAll(() => NotVerifiedScreen(),
            transition: Transition.native,
            duration: const Duration(seconds: 1));
        return Future.error("Email not verified");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Get.snackbar(
          "Error",
          "No user found for that email.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return Future.error("No user found for that email");
      } else if (e.code == 'wrong-password') {
        Get.snackbar(
          "Error",
          "Wrong password provided for that user.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return Future.error("Wrong password provided for that user");
      } else if (e.code == 'invalid-email' ||
          e.code == 'malformed-credential') {
        Get.snackbar(
          "Error",
          "Invalid email or malformed credential provided.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return Future.error("Invalid email or malformed credential");
      } else {
        Get.snackbar(
          "Error",
          "Wrong E-mail or Password please check credentials",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return Future.error("Wrong E-mail or Password");
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "e.toString()",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return Future.error("An error occurred");
    }
  }

  static Future<void> resendVerificationEmail() async {
    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
      Get.snackbar(
        "Email Sent",
        "A verification email has been sent to your email address.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to send verification email: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> signOutUser() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    googleSignIn.disconnect();
    await FirebaseAuth.instance.signOut();
    Get.offAll(LoginScreen());
    Get.snackbar(
      "Sign Out",
      "You have been signed out successfully.",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  static Future<bool> isFirstTime(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return !doc.exists;
  }

  static Future signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print('Google sign-in canceled by user');
        return;
      }

      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        final firstTime = await isFirstTime(userCredential.user!.uid);
        await HiveHelper.setToken(userCredential.user!.uid);
        await HiveHelper.setUser(email: userCredential.user!.email);

        if (firstTime) {
          Get.snackbar(
            "Let's get you in",
            "Google sign-in Succeded Fill Your profile",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          Get.offAll(() => FillProfile(),
              transition: Transition.native,
              duration: const Duration(seconds: 1));
        } else {
          await getUserData();
          Get.snackbar(
            "Welcome",
            "Google sign-in Succeded",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          Get.offAll(() => Home(),
              transition: Transition.native,
              duration: const Duration(seconds: 1));
        }
      }
    } catch (e) {
      print('Google Sign-In Failed: $e');
      Get.snackbar(
        "Error",
        "Google sign-in failed, please try again",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> forgetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Get.snackbar(
        "Password Changer",
        "Please check your account to reset password.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Wrong Email",
        "Please check the email you entered.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
