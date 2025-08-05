import 'package:learnify/auth/cubit/login_cubit.dart';
import 'package:learnify/auth/login_screen.dart';
import 'package:learnify/const.dart';
import 'package:learnify/widgets/custom_textfield.dart';
import 'package:learnify/widgets/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  static final _formKey = GlobalKey<FormState>();

  SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = context.width;
    final h = context.height;
    final cubit = context.read<LoginCubit>();
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        return state is LoginLoading
            ? Center(child: CircularProgressIndicator())
            : Scaffold(
                body: GestureDetector(
                  onTap: () {
                    FocusScope.of(context)
                        .unfocus(); // لإخفاء الكيبورد عند الضغط خارج الحقول
                  },
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(padding(w)),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          spacing: h * 0.02,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: h * 0.12,
                            ),
                            Center(child: Image.asset("${img}LOGO.png")),
                            boldtexts("Get Started.!"),
                            normaltexts(
                                "Create an Account to Continue your allCourses"),
                            CustomTextfield(
                              text: "Email",
                              controller: _emailController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your email";
                                }
                                return null;
                              },
                            ),
                            CustomTextfield(
                              text: "Password",
                              isPassword: true,
                              controller: _passwordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your password";
                                }
                                return null;
                              },
                            ),
                            GestureDetector(
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  cubit.signup(
                                    context: context,
                                    email: _emailController,
                                    password: _passwordController,
                                  );
                                }
                              },
                              child: signButton(h: h, text: "Sign Up"),
                            ),
                            Center(
                              child: normaltexts("Or Continue with"),
                            ),
                            GestureDetector(
                              onTap: () {
                                cubit.googleSignIn();
                              },
                              child: Center(
                                child: googleIcon(context),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                normaltexts("Already have an Account?"),
                                GestureDetector(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    Get.off(() => LoginScreen());
                                  },
                                  child: Text(
                                    " Sign In",
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      decorationColor: blueColor(),
                                      color: blueColor(),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
      },
    );
  }

  Widget googleIcon(BuildContext context) {
    final w = context.width;
    final h = context.height;

    return Container(
      margin: EdgeInsets.only(right: w * 0.05),
      width: w < h ? w * 0.15 : h * 0.15,
      height: w < h ? w * 0.15 : h * 0.15,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Image.asset("${img}Google.png", width: w * 0.1, height: w * 0.1),
      ),
    );
  }
}
