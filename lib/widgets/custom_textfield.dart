import 'package:learnify/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextfield extends StatefulWidget {
  final String text;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final bool isEnabled;

  const CustomTextfield({
    super.key,
    required this.text,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.prefixIcon,
    this.isEnabled = true,
  });

  @override
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onEditingComplete: () => FocusScope.of(context).unfocus(),
      enabled: widget.isEnabled,
      controller: widget.controller,
      obscureText: widget.isPassword && _obscureText,
      validator: widget.validator,
      decoration: InputDecoration(
        prefixIcon: widget.prefixIcon ??
            Icon(
              widget.isPassword ? CupertinoIcons.lock : CupertinoIcons.mail,
              color: textColor(),
            ),
        hintText: widget.text,
        hintStyle: TextStyle(
          color: textColor(),
          fontSize: 14,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        suffixIcon: widget.isPassword
            ? InkWell(
                onTap: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child: Icon(
                  _obscureText ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                ),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.transparent),
        ),
      ),
    );
  }
}
