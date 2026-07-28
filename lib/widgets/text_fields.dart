import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/colors.dart';
import '../utils/text_style.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? prefix;
  final Widget? suffixIcon;
  final String? errorText;
  final bool readOnly;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? maxLength;
  final double borderRadius;
  final String? Function(String?)? validator; // Validator for form validation
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.errorText,
    this.validator, // Accept validator callback
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
    this.maxLines,
    this.maxLength,
    this.readOnly = false,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: AppTextStyles.medium(
        fontSize: 16.sp,
        color: AppColors.white,
      ).copyWith(
        decoration: TextDecoration.none,
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: onChanged,
      validator: validator, // Add validator for validation
      maxLines: maxLines,
      maxLength: maxLength,
      readOnly: readOnly,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        hintText: label,
        errorText: errorText,
        hintStyle: AppTextStyles.regular(
          fontSize: 16.sp,
          color: AppColors.textPlaceHolder,
        ),
        prefixIcon: prefixIcon,

        prefix: prefix,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius.r),
          borderSide: BorderSide.none,
        ),
        filled: true,
        // fillColor: AppColors.textFieldBG,
      ),
    );
  }
}
