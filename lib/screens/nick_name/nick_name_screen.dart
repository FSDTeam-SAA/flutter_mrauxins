import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/utils/app_dialoge.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/buttons.dart';
import 'package:two_one_two_messenger/widgets/text_fields.dart';

// class NickNameScreen extends StatelessWidget {
//   const NickNameScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold();
//   }
// }

Future<void> showNickNameDialog(
  BuildContext context, {
  String? nickName,
  Function(String? name)? onPressed,
}) async {
  // print("nickName >> $nickName");
  final controller = TextEditingController(text: nickName);
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(.5),
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.scaffoldBgDark,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            S.of(context).nickName,
            style: AppTextStyles.medium(
              fontSize: 18.sp,
              color: AppColors.purpleText,
            ),
          ),
          SizedBox(height: 10.h),
          CustomTextField(
            controller: controller,
            label: S.of(context).nickName,
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    S.of(context).cancel,
                    style: AppTextStyles.medium(
                      fontSize: 16.sp,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    // if (controller.text.trim().isEmpty) {
                    //   // Utils.showSnackBar(
                    //   //   context,
                    //   //   S.of(context).pleaseEnterNickName,
                    //   // );
                    //   Fluttertoast.showToast(
                    //       msg: S.of(context).pleaseEnterNickName);
                    //   return;
                    // }
                    String nickName = controller.text.trim();
                    Navigator.pop(context);
                    onPressed?.call(nickName);
                  },
                  child: Text(
                    S.of(context).submitButtonText,
                    style: AppTextStyles.medium(
                      fontSize: 16.sp,
                      color: AppColors.white,
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    ),
  );
}
