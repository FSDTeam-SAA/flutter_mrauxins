import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/constants.dart';

class AppCheckBox extends StatelessWidget {
  const AppCheckBox(
      {super.key,
      required this.value,
      this.onChanged,
      this.shape,
      this.activeColor,
      this.borderColor});

  final bool value;
  final void Function(bool?)? onChanged;
  final OutlinedBorder? shape;
  final Color? borderColor;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    return value
        ? SvgPicture.asset(
            SvgAssets.checkIcon,
            fit: BoxFit.scaleDown,
            // colorFilter: ColorFilter.mode(
            //   Colors.transparent,
            //   BlendMode.srcIn,
            // ),
            // height: 24.h,
            // width: 24.w,
          )
        : Container(
            height: 24,
            width: 24,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(color: AppColors.buttonColor)),
          );

    return Transform.scale(
      scale: 1,
      alignment: Alignment.centerLeft,
      child: Checkbox(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        value: value,
        splashRadius: 0,
        checkColor: AppColors.white,
        side: WidgetStateBorderSide.resolveWith(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return const BorderSide(color: Colors.transparent);
            }
            return BorderSide(
              width: 2,
              color: borderColor ?? AppColors.buttonColor,
            );
          },
        ),
        onChanged: onChanged,
        activeColor: activeColor ?? AppColors.buttonColor,
        shape: shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                100.r,
              ),
            ),
      ),
    );
  }
}
