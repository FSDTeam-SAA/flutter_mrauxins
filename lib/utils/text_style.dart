import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/utils/colors.dart';

import 'utils.dart';

class AppTextStyles {
  static const String fontFamily = 'NotoSans';

  // Base TextStyle function for size and color customization
  static TextStyle baseStyle({
    FontWeight weight = FontWeight.normal,
    FontStyle fontStyle = FontStyle.normal,
    double? fontSize,
    Color? color,
    double letterSpacing = 0.0,
    double height = 1.2,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontWeight: weight,
      fontStyle: fontStyle,
      fontSize: fontSize ?? 14.0.sp, // Use ScreenUtil for responsive font size
      color: color ?? AppColors.white,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle thin({double fontSize = 14.0, Color? color}) {
    return baseStyle(
      weight: FontWeight.w100,
      fontSize: fontSize,
      color: color,
    );
  }

  static TextStyle light({double fontSize = 14.0, Color? color}) {
    return baseStyle(
      weight: FontWeight.w300,
      fontSize: fontSize,
      color: color,
    );
  }

  static TextStyle regular({double? fontSize, Color? color}) {
    return baseStyle(
      weight: FontWeight.w400,
      fontSize: fontSize ?? 14.sp,
      color: color,
    );
  }

  static TextStyle medium({double? fontSize, Color? color}) {
    return baseStyle(
      weight: FontWeight.w500,
      fontSize: fontSize ?? 16.sp,
      color: color,
    );
  }

  static TextStyle bold({double? fontSize, Color? color}) {
    return baseStyle(
      weight: FontWeight.w700,
      fontSize: fontSize ?? 18.sp,
      color: color,
    );
  }

  static TextStyle semiBold({double? fontSize, Color? color}) {
    return baseStyle(
      weight: FontWeight.w600,
      fontSize: fontSize ?? 18.sp,
      color: color,
    );
  }

  static TextStyle extraBold({double? fontSize, Color? color}) {
    return baseStyle(
      weight: FontWeight.w800,
      fontSize: fontSize ?? 20.sp,
      color: color,
    );
  }

  static TextStyle black({double? fontSize, Color? color}) {
    return baseStyle(
      weight: FontWeight.w900,
      fontSize: fontSize ?? 22.sp,
      color: color,
    );
  }
}
