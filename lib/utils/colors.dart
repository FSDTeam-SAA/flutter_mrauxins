import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primaryColor = Color(0xFF3E5EFE);
  static const Color greenColor = Color.fromARGB(
    255,
    62,
    254,
    94,
  );
  static const Color secondaryColor = Color(0xFFD8E8F8);

  // Background colors
  static const Color scaffoldBackground = Colors.white;
  static const Color scaffoldBackground2 = Color(0xFFF3F3F9);
  static const Color inputFill = Color(0xFFF2F2F2);
  static const Color secondaryBgColor = Color(0xFF323E5A);
  static const Color white = Colors.white;
  static Color offWhite = Color(0xFFFFFFFF).withValues(alpha: 65);
  static const Color black = Colors.black;
  static const Color seondaryIconColor = Color(0x121B3280);
  // Text colors
  static const Color textColorPrimary = Color(0xFF181D42);
  static const Color textColorSecondary = Color(0xFF717171);
  static const Color textColorThird = Color(0xFFA7A0A0);
  static const Color textColorFourth = Color(0xFF767885);
  static const Color textColorFifth = Color(0XFF767885);

  static const Color textColorHint = Color(0xFFB0B0B0);
  // Light grey for hint text

  // Dark Theme Color

  // Background colors
  static const Color scaffoldBgDark = Color(0XFF212733);
  // static const Color scaffoldBackground2 = Color(0xFFF3F3F9);
  static const Color darkInputFill = Color(0xFF3E4664);
  static const List<Color> gradientColor = [
    Color(0XFF212733),
    Color(0XFF1A1C23)
  ];
  static const Color dark = Color(0XFF212733);
  static const Color dialogBg = Color(0XFF21293D);
  static const Color darkTextColorHint = Color(0xFFFFFFD9);
  static const Color darkAppBar = Color(0XFF30374A);

  // Other common colors

  // static const Color dividerColor = Color(0xFF434a61);
  static Color get dividerColor => Color(0XFFF4F5F8).withOpacity(0.1);
  static const Color buttonColor = Color(0xFF3E5EFE);
  static const Color checkboxColor = Color(0xFFD1D1D1);
  static const Color iconColor = Color(0xFF002E5B);
  static const Color cardBGColor = Color(0xFFD8E8F8);
  static const Color dropDownBGColor = Color(0xFFF6F6F6);

  static const Color textFieldBG = Color(0xFFF0F0F0);
  static const Color textPlaceHolder = Color(0xFF8C8C8C);
  static const Color redColor = Color(0xFFE90D0D);
  static const Color purpleText = Color(0xFFC5CAFF);
  static const Color whiteOpa = Color(0XFFFFFF80);
  static const Color btnGrey = Color(0XFF3A4359);
}
