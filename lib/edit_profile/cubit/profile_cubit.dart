import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:learnify/Helpers/dio_helper.dart';
import 'package:meta/meta.dart';

import '../../Helpers/hive_helper.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());
  bool isEnabled = false;
  Timer? _timer;

  void periodic() {
    _timer = Timer.periodic(Duration(minutes: 2), (timer) async {
      isEnabled = false;
      emit(ProfileInitial());
      _timer?.cancel();
    });
  }

  void startEditing() {
    emit(ProfileEditing());

    Get.snackbar("Go on", "Start editing",
        colorText: Colors.white, backgroundColor: Colors.blue);
    isEnabled = true;
    periodic();
  }

  Future<void> patchEdit({required String name, required String phone}) async {
    emit(ProfileEditingLoading());
    try {
      await DioHelper.postData(path: "rpc/update_user_profile", body: {
        "p_user_id": HiveHelper.getToken(),
        "p_user_name": name,
        "p_phone": phone,
      });
      await HiveHelper.setUser(
          name: name, phone: phone, email: HiveHelper.getUserEmail());
      emit(ProfileEditingSuccess());
      Get.snackbar(
        "Success",
        "Updated Successfully",
        backgroundColor: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        "Sorry",
        "Some thing went Wrong",
        backgroundColor: Colors.red,
      );
      emit(ProfileEditingFailure());
    }
  }
}
