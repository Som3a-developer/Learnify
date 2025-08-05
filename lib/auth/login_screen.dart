import 'package:learnify/auth/cubit/login_cubit.dart';
import 'package:learnify/auth/signup_screen.dart';
import 'package:learnify/const.dart';
import 'package:learnify/firebase/firebase_auth.dart';
import 'package:learnify/widgets/custom_textfield.dart';
import 'package:learnify/widgets/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final w = context.width;
    final h = context.height;
    final cubit = context.read<LoginCubit>();

    return Scaffold(
      body: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) async {
          if (state is LoginSuccess) {
            cubit.dispose(_emailController, _passwordController);
          }
        },
        child: BlocBuilder<LoginCubit, LoginState>(
          builder: (context, state) {
            return state is LoginLoading
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
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
                            GestureDetector(
                              onTap: () {
                                cubit.googleSignIn();
                              },
                              child: Center(
                                child: Image.asset(
                                  "${img}LOGO.png",
                                ),
                              ),
                            ),
                            boldtexts("Let's sign you in.!"),
                            normaltexts(
                                "Login your Account to Continue your allCourses"),
                            CustomTextfield(
                              text: "Email",
                              controller: _emailController,
                              validator: (val) {
                                final bool emailValid = RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(val!);
                                if (!emailValid) {
                                  return "This field should be a valid email";
                                }
                                return null;
                              },
                            ),
                            CustomTextfield(
                              text: "Password",
                              isPassword: true,
                              controller: _passwordController,
                              validator: (val) {
                                if (val!.length < 6) {
                                  return "Password should be more than 6 letters";
                                }
                                return null;
                              },
                            ),
                            Row(
                              children: [
                                Spacer(),
                                InkWell(
                                  onTap: () {
                                    FirebaseAuthHelper()
                                        .forgetPassword(_emailController.text);
                                  },
                                  child: boldtexts(
                                    "Forgot Password?",
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (_formKey.currentState!.validate()) {
                                  await cubit.login(
                                    context: context,
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  );
                                }
                              },
                              child: signButton(
                                h: h,
                                text: "Login",
                              ),
                            ),
                            Center(
                              child: normaltexts(
                                "Or Continue with",
                              ),
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
                                normaltexts("Don't have an Account?"),
                                GestureDetector(
                                  onTap: () {
                                    //remove the previous screen from the stack except the first one

                                    Get.off(() => SignUpScreen());
                                  },
                                  child: Text(
                                    " Sign UP",
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
                  );
          },
        ),
      ),
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
        child: Image.asset(
          "${img}Google.png",
          width: w * 0.1,
          height: w * 0.1,
        ),
      ),
    );
  }
}
