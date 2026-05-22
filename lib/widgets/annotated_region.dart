import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:two_one_two_messenger/utils/colors.dart';

class CustomAnnotatedRegions extends StatelessWidget {
  final Widget child;
  final bool isDarkTheme;
  final Color statusBarColor;

  const CustomAnnotatedRegions(
      {super.key,
      required this.child,
      this.isDarkTheme = true,
      this.statusBarColor = Colors.transparent});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
          statusBarColor: statusBarColor,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.light,
          // statusBarIconBrightness: _statusBarColor(),
          // statusBarBrightness: _statusBarColor(),
          systemNavigationBarColor: AppColors.scaffoldBgDark,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarContrastEnforced: true,
          systemNavigationBarIconBrightness: Brightness.light),
      child: child,
    );
  }

  Brightness _statusBarColor() {
    late Brightness brightness;

    if (isDarkTheme) {
      brightness = Platform.isIOS ? Brightness.light : Brightness.dark;
    } else {
      brightness = Platform.isIOS ? Brightness.dark : Brightness.light;
    }

    return brightness;
  }
}
