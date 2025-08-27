import 'package:bloc/bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:learnify/Helpers/dio_helper.dart';
import 'package:learnify/Helpers/hive_helper.dart';
import 'package:learnify/auth/login_screen.dart';
import 'package:learnify/firebase/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  // final cardin = {
  //   "email": "youssefemail19@gmail.com",
  //   "password": "123456",
  // };
  void dispose(TextEditingController emailController,
      TextEditingController passwordController) {
    // Dispose of the controllers to free up resources
    emailController.clear();
    passwordController.clear();
  }

  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    emit(LoginLoading());
    try {
      await FirebaseAuthHelper.signInUser(context, email, password);
      emit(LoginSuccess());
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> fillProfile({
    required String name,
    required String phone,
    required String token,
  }) async {
    emit(LoginLoading());
    // Simulate a profile fill operation
    // In a real app, you would save the profile data to a database or API
    if (name.isNotEmpty && phone.isNotEmpty) {
      await FirebaseAuthHelper.saveUserInfo(
        uid: HiveHelper.getToken()!,
        name: name,
        phone: phone,
      );
      await HiveHelper.setUser(name: name, phone: phone);
      await HiveHelper.setToken(token);
      emit(LoginInitial());

      Get.offAll(() => LoginScreen());
    } else {
      emit(LoginFailure("Please fill in all fields correctly."));
    }
  }

  Future<void> signup({
    required TextEditingController email,
    required TextEditingController password,
    required BuildContext context,
  }) async {
    emit(LoginLoading());
    if (email.text.isNotEmpty && password.text.isNotEmpty) {
      try {
        await FirebaseAuthHelper.registerUser(
          context,
          email.text,
          password.text,
        );
        dispose(email, password);
        emit(SigninSuccess());
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    } else {
      emit(LoginFailure("Please fill in all fields correctly."));
    }
  }

  Future<void> googleSignIn() async {
    emit(LoginLoading());
    try {
      await FirebaseAuthHelper.signInWithGoogle();
      emit(LoginSuccess());
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}
