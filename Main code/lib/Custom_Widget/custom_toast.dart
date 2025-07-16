import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showCustomToast(BuildContext context, {
  required String message,
  Color backgroundColor = Colors.black87,
  Color textColor = Colors.white,
  double fontSize = 14.0,
  Toast toastLength = Toast.LENGTH_SHORT,
  ToastGravity gravity = ToastGravity.BOTTOM,
  bool addTopPadding = false,
  int delayMilliseconds = 100,
}) {
  Future.delayed(Duration(milliseconds: delayMilliseconds), () {
    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
    );
  });
}