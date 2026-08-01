import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';

class GroupAccordionHeader extends StatelessWidget {
  const GroupAccordionHeader({
    super.key,
    required this.title,
    required this.isExpanded,
    required this.onTap,
  });

  final String title;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: 48.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isExpanded
                ? const Color(0xFF2D2029)
                : AppColors.dialogBg.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: const Color(0xFF86334D).withValues(alpha: 0.65),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.medium(fontSize: 15.sp),
                ),
              ),
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: AppColors.white,
                size: 22.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
