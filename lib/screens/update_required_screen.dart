import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

class UpdateRequiredScreen extends StatelessWidget {
  final String playStoreUrl;

  const UpdateRequiredScreen({super.key, required this.playStoreUrl});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              ImgAssets.updateRequiredBg,
              fit: BoxFit.cover,
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Column(
                  children: [
                    60.h.verticalSpace,
                    Image.asset(
                      ImgAssets.logo,
                      width: 140.w,
                      height: 140.h,
                    ),
                    24.h.verticalSpace,
                    Text(
                      'Update Required',
                      style: AppTextStyles.extraBold(
                        fontSize: 28.sp,
                        color: AppColors.white,
                      ),
                    ),
                    24.h.verticalSpace,
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.updateCardBg,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64.w,
                            height: 64.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.redColor.withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              ImgAssets.downloadIcon,
                              width: 28.w,
                              height: 28.h,
                            ),
                          ),
                          20.h.verticalSpace,
                          Text(
                            "You're using an older version of the app. Please update to continue enjoying secure messaging and new features.",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.regular(
                              fontSize: 14.sp,
                              color: AppColors.white,
                            ),
                          ),
                          24.h.verticalSpace,
                          SizedBox(
                            width: double.infinity,
                            height: 35.h,
                            child: ElevatedButton(
                              onPressed: () =>
                                  Utils.launchUrlHelper(playStoreUrl, context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.updateButtonColor,
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                surfaceTintColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32.r),
                                ),
                              ),
                              child: Text(
                                'Update Now',
                                style: AppTextStyles.semiBold(
                                  fontSize: 14.sp,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                          20.h.verticalSpace,
                          Text(
                            'This update includes performance improvements and security enhancements.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.regular(
                              fontSize: 13.sp,
                              color: AppColors.textColorHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
