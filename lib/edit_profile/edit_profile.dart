import 'package:learnify/Helpers/hive_helper.dart';
import 'package:learnify/const.dart';
import 'package:learnify/edit_profile/change_password.dart';
import 'package:learnify/edit_profile/cubit/profile_cubit.dart';
import 'package:learnify/firebase/firebase_auth.dart';
import 'package:learnify/widgets/custom_textfield.dart';
import 'package:learnify/widgets/texts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfile extends StatelessWidget {
  EditProfile({super.key});

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _passwordController =
      TextEditingController(); // لادخال الباسورد عند الحذف

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileCubit>();

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return state is ProfileEditingLoading
            ? const Center(child: CircularProgressIndicator())
            : Scaffold(
                resizeToAvoidBottomInset: true,
                appBar: AppBar(
                  title: boldtexts('Edit Your Profile'),
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(padding(context.width)),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        spacing: context.height * 0.02,
                        children: [
                          boldtexts("Name"),
                          CustomTextfield(
                            isEnabled: cubit.isEnabled,
                            prefixIcon: const Icon(CupertinoIcons.person),
                            text: HiveHelper.getUserName()!,
                            controller: _nameController,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value == HiveHelper.getUserName()) {
                                return "Please enter your full name";
                              }
                              return null;
                            },
                          ),
                          boldtexts("Email"),
                          CustomTextfield(
                            text: FirebaseAuth.instance.currentUser?.email ??
                                "Email",
                            isEnabled: false, // Email ثابت
                          ),
                          boldtexts("Phone"),
                          CustomTextfield(
                            isEnabled: cubit.isEnabled,
                            prefixIcon: const Icon(CupertinoIcons.phone),
                            text: HiveHelper.getUserPhone()!,
                            controller: _phoneController,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.length < 11 ||
                                  value == HiveHelper.getUserPhone()) {
                                return "Please enter a valid phone number";
                              }
                              return null;
                            },
                          ),
                          state is ProfileEditing
                              ? GestureDetector(
                                  onTap: () async {
                                    if (_formKey.currentState!.validate()) {
                                      cubit.patchEdit(
                                        phone: _phoneController.text,
                                        name: _nameController.text,
                                      );
                                    } else {
                                      Get.snackbar(
                                          "Error", "Please enter valid values",
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white);
                                    }
                                  },
                                  child: signButton(
                                    h: context.height,
                                    text: "Done",
                                    withArrow: false,
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () async {
                                    cubit.startEditing();
                                  },
                                  child: signButton(
                                    h: context.height,
                                    text: "Continue",
                                    withArrow: false,
                                  ),
                                ),
                          GestureDetector(
                            onTap: () {
                              Get.to(ChangePassword());
                            },
                            child: signButton(
                              h: context.height,
                              text: "Change password",
                              withArrow: true,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null) return;

                              final isGoogle = user.providerData.any(
                                  (info) => info.providerId == "google.com");

                              if (isGoogle) {
                                // جوجل → يتحذف على طول
                                await FirebaseAuthHelper.deleteAccount();
                              } else {
                                // ايميل/باسورد → نطلب باسورد
                                await showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      title: boldtexts("Confirm Password"),
                                      content: CustomTextfield(
                                        controller: _passwordController,
                                        isPassword: true,
                                        prefixIcon: const Icon(Icons.lock),
                                        text: "Enter your current password",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text("Cancel"),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            Navigator.pop(ctx);
                                            await FirebaseAuthHelper
                                                .deleteAccount(
                                              email: user.email!,
                                              password:
                                                  _passwordController.text,
                                            );
                                          },
                                          child: signButton(
                                            h: context.height * 0.1,
                                            text: "Confirm",
                                            withArrow: false,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: signButton(
                              withArrow: false,
                              color: Colors.red,
                              h: context.height,
                              text: "Delete profile",
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
