import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';

import '../utils/colors.dart';

class CustomLoader extends StatelessWidget {
  const CustomLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Center(
        child: Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 80),
              shape: BoxShape.circle),
          child: CustomLoadingWidget(
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}
