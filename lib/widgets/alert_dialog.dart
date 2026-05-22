// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/widgets/buttons.dart';

import '../utils/colors.dart';
import '../utils/utils.dart';

Future<void> CustomAlertDialog(
    {required BuildContext context,
    required Widget icon,
    required String title,
    String? description,
    required String buttonText,
    required Function() onPressed,
    bool isClose = true}) async {
  await Utils.hideKeyboard();
  await showDialog(
    context: context,
    barrierDismissible: isClose,
    // barrierColor: context.theme.scaffoldBackgroundColor.withValues(alpha:0.3),
    builder: (context) {
      return PopScope(
        canPop: isClose,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            backgroundColor: AppColors.dark,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r)),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: AppColors.darkInputFill,
                    child: icon,
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Text(
                    title,
                    style: AppTextStyles.medium(),
                    textAlign: TextAlign.center,
                    textScaler: const TextScaler.linear(1.1),
                  ),
                  if (description != null) ...[
                    SizedBox(height: 5.h),
                    Text(
                      description,
                      style: AppTextStyles.medium(
                          color: AppColors.textColorSecondary),
                      textAlign: TextAlign.center,
                      textScaler: const TextScaler.linear(0.9),
                    ),
                  ],
                  SizedBox(height: 20.h),
                  CustomButton(
                      child: Text(
                        buttonText,
                        style: AppTextStyles.medium(
                          fontSize: 16.sp,
                          color: AppColors.white,
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await onPressed();
                      }),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
