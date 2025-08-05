import 'package:flutter/material.dart';

Text boldtexts(String text, {Color color = const Color(0xFF202244)}) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 16.0,
      color: color,
      fontWeight: FontWeight.w600,
      fontFamily: 'Jostify',
    ),
  );
}

Text normaltexts(String text, {Color color = const Color(0xFF202244)}) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 14.0,
      color: color,
      fontWeight: FontWeight.w400,
      fontFamily: 'Jostify',
    ),
  );
}
