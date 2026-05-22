import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';

class ConnectionLostScreen extends StatelessWidget {
  const ConnectionLostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.dark,
      ),
      body: Padding(
        padding: EdgeInsets.all(32.w),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.signal_wifi_off, color: Colors.red, size: 80),
              const SizedBox(height: 20),
              Text(
                S.of(context).noInternetConnection,
                style: AppTextStyles.medium()
                    .copyWith(fontWeight: FontWeight.w700, fontSize: 24.sp),
              ),
              18.h.verticalSpace,
              Text(
                S.of(context).pleaseCheckYournetworkSettings,
                style: AppTextStyles.regular(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
