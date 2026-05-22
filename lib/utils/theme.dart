import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_style.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        titleTextStyle: AppTextStyles.thin(
          fontSize: 20.0,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.thin(
          fontSize: 57.0,
        ),
        displayMedium: AppTextStyles.medium(
          fontSize: 45.0,
        ),
        displaySmall: AppTextStyles.medium(
          fontSize: 36.0,
        ),
        headlineLarge: AppTextStyles.thin(
          fontSize: 32.0,
        ),
        headlineMedium: AppTextStyles.medium(
          fontSize: 28.0,
        ),
        headlineSmall: AppTextStyles.medium(
          fontSize: 24.0,
        ),
        titleLarge: AppTextStyles.medium(
          fontSize: 22.0,
        ),
        titleMedium: AppTextStyles.regular(
          fontSize: 16.0,
        ),
        titleSmall: AppTextStyles.regular(
          fontSize: 14.0,
        ),
        bodyLarge: AppTextStyles.regular(
          fontSize: 16.0,
        ),
        bodyMedium: AppTextStyles.regular(
          fontSize: 14.0,
        ),
        bodySmall: AppTextStyles.regular(
          fontSize: 12.0,
        ),
        labelLarge: AppTextStyles.medium(
          fontSize: 14.0,
        ),
        labelMedium: AppTextStyles.regular(
          fontSize: 12.0,
        ),
        labelSmall: AppTextStyles.regular(
          fontSize: 11.0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        hintStyle: AppTextStyles.regular(
          fontSize: 14.0,
          color: AppColors.textColorHint,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.black, // Set your desired cursor color here
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: AppColors.buttonColor,
        textTheme: ButtonTextTheme.primary,
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(AppColors.textColorPrimary),
        fillColor: WidgetStateProperty.all(
            AppColors.checkboxColor), // Set checkbox fill color
        overlayColor: WidgetStateProperty.all(AppColors.checkboxColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0), // Apply border radius
          side: BorderSide.none,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: AppColors.dark,
      scaffoldBackgroundColor: AppColors.scaffoldBgDark,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.dark,
        titleTextStyle: AppTextStyles.thin(
          fontSize: 20.0,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.thin(
          fontSize: 57.0,
        ),
        displayMedium: AppTextStyles.medium(
          fontSize: 45.0,
        ),
        displaySmall: AppTextStyles.medium(
          fontSize: 36.0,
        ),
        headlineLarge: AppTextStyles.thin(
          fontSize: 32.0,
        ),
        headlineMedium: AppTextStyles.medium(
          fontSize: 28.0,
        ),
        headlineSmall: AppTextStyles.medium(
          fontSize: 24.0,
        ),
        titleLarge: AppTextStyles.medium(
          fontSize: 22.0,
        ),
        titleMedium: AppTextStyles.regular(
          fontSize: 16.0,
        ),
        titleSmall: AppTextStyles.regular(
          fontSize: 14.0,
        ),
        bodyLarge: AppTextStyles.regular(
          fontSize: 16.0,
        ),
        bodyMedium: AppTextStyles.regular(
          fontSize: 14.0,
        ),
        bodySmall: AppTextStyles.regular(
          fontSize: 12.0,
        ),
        labelLarge: AppTextStyles.medium(
          fontSize: 14.0,
        ),
        labelMedium: AppTextStyles.regular(
          fontSize: 12.0,
        ),
        labelSmall: AppTextStyles.regular(
          fontSize: 11.0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkInputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        hintStyle: AppTextStyles.regular(
          fontSize: 14.0,
          color: AppColors.textColorHint,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.white, // Set your desired cursor color here
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: AppColors.buttonColor,
        textTheme: ButtonTextTheme.primary,
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(AppColors.textColorPrimary),
        fillColor: WidgetStateProperty.all(
            AppColors.checkboxColor), // Set checkbox fill color
        overlayColor: WidgetStateProperty.all(AppColors.checkboxColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0), // Apply border radius
          side: BorderSide.none,
        ),
      ),
    
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.transparent)
    );
  }
}
