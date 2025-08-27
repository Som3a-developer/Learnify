import 'package:learnify/Helpers/hive_helper.dart';
import 'package:learnify/const.dart';
import 'package:learnify/edit_profile/cubit/profile_cubit.dart';
import 'package:learnify/firebase/firebase_auth.dart';
import 'package:learnify/widgets/custom_textfield.dart';
import 'package:learnify/widgets/texts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePassword extends StatelessWidget {
  ChangePassword({super.key});

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _newAgainPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileCubit>();

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return state is ProfileEditingLoading
            ? Center(child: CircularProgressIndicator())
            : Scaffold(
                resizeToAvoidBottomInset: true,
                appBar: AppBar(
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                  title: boldtexts('Fill Your Profile'),
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(padding(context.width)),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        spacing: context.height * 0.02,
                        children: [
                          boldtexts("Old Password"),
                          CustomTextfield(
                            isPassword: true,
                            prefixIcon: Icon(CupertinoIcons.lock),
                            text: "old Password",
                            controller: _oldPasswordController,
                            validator: (val) {
                              if (val!.length < 6) {
                                return "Password should be more than 6 letters";
                              }
                              return null;
                            },
                          ),
                          boldtexts("new Password"),
                          CustomTextfield(
                            isPassword: true,
                            prefixIcon: Icon(CupertinoIcons.lock),
                            text: "New Password",
                            controller: _newPasswordController,
                            validator: (val) {
                              if (val!.length < 6) {
                                return "Password should be more than 6 letters";
                              }
                              return null;
                            },
                          ),
                          boldtexts("New Password again"),
                          CustomTextfield(
                            isPassword: true,
                            prefixIcon: Icon(CupertinoIcons.lock),
                            text: "New Password",
                            controller: _newAgainPasswordController,
                            validator: (val) {
                              if (val!.length < 6) {
                                return "Password should be more than 6 letters";
                              }
                              return null;
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_newPasswordController.text ==
                                  _newAgainPasswordController.text) {
                                FirebaseAuthHelper.changePassword(
                                  email: HiveHelper.getUserEmail()!,
                                  currentPassword: _oldPasswordController.text,
                                  newPassword: _newPasswordController.text,
                                );
                                Get.back();
                              } else {
                                Get.snackbar(
                                  "Check new password",
                                  "RE write your password",
                                  backgroundColor: Colors.red,
                                );
                              }
                            },
                            child: signButton(
                              h: context.height,
                              text: "Change Password",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
      },
    );
  }
}
