import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/colors.dart';
import '../utils/text_style.dart';

class TitleCard extends StatelessWidget {
  final String title;
  final String value;
  const TitleCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return         Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
          color: AppColors.cardBGColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.white, width: 2)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
      title,
            style: AppTextStyles.medium(
              fontSize: 16.sp,
              color: AppColors.textColorPrimary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.medium(
              fontSize: 16.sp,
              color: AppColors.textColorPrimary,
            ),
          )
        ],
      ),
    );
  }
}
