import 'package:learnify/auth/cubit/login_cubit.dart';
import 'package:learnify/const.dart';
import 'package:learnify/home/home_screen.dart';
import 'package:learnify/widgets/custom_textfield.dart';
import 'package:learnify/widgets/texts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FillProfile extends StatelessWidget {
  FillProfile({super.key, required this.token});

  final String token;
  final _nameController = TextEditingController();

  final _phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LoginCubit>();

    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) async {
        if (state is LoginSuccess) {
          Get.offAll(() => HomeScreen());
          Get.snackbar(
            "Profile Updated",
            "Your profile has been updated successfully.",
            backgroundColor: Colors.green.withOpacity(0.8),
          );
          await Future.delayed(Duration(seconds: 1));
          cubit.dispose(_nameController, _phoneController);
        } else if (state is LoginFailure) {
          Get.snackbar('Login Failed', state.error);
        }
      },
      builder: (context, state) {
        return state is LoginLoading
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
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                                top: context.width * 0.07),
                            width: context.width * 0.25,
                            height: context.width * 0.25,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                            ),
                            child: Image.asset(
                              "${img}profile.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Handle image upload
                              Get.snackbar('Profile Picture',
                                  'Change profile picture functionality not implemented yet.');
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                CupertinoIcons.create,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    CustomTextfield(
                      prefixIcon: Icon(CupertinoIcons.person),
                      text: "Full Name",
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your full name";
                        }
                        return null;
                      },
                    ),
                    CustomTextfield(
                      text: FirebaseAuth.instance.currentUser?.email ??
                          "Email",

                      isEnabled:
                      false, // Email is pre-filled and not editable
                    ),
                    CustomTextfield(
                      prefixIcon: Icon(CupertinoIcons.phone),
                      text: "Phone Number",
                      controller: _phoneController,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length < 11) {
                          return "Please enter a valid phone number";
                        }
                        return null;
                      },
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          await cubit.fillProfile(
                            token: token,
                            name: _nameController.text,
                            phone: _phoneController.text,
                          );
                        }
                      },
                      child:
                      signButton(h: context.height, text: "Continue"),
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
