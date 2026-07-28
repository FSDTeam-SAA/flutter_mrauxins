import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/cubit/chat_cubit.dart';
import 'package:two_one_two_messenger/cubit/chat_state.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/buttons.dart';

Future<void> showClearChatDialog({
  required BuildContext context,
  required String? chatId,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return BlocBuilder<ChatCubit, ChatState>(
          builder: (contextMessage, state) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26.r),
          ), //this right here
          child: SizedBox(
            width: double.infinity,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.dark,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      S.of(context).clearChat,
                      style: AppTextStyles.medium(fontSize: 20.sp),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      S.of(context).lblClearChatSubTitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.regular(
                          fontSize: 14.sp,
                          color: AppColors.textColorSecondary),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: CustomButton(
                            onPressed: () async =>
                                await NavigationService().goBack(),
                            backgroundColor: AppColors.btnGrey,
                            child: Text(
                              S.of(context).cancel,
                              style: AppTextStyles.medium(
                                fontSize: 16.sp,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: CustomButton(
                            onPressed: () async {
                              await chatCubit.clearChat(
                                chatId ?? '',
                                // context,
                                callback: (response) {
                                  Utils.showSnackBar(
                                      context, response.message ?? '',
                                      seconds: 3);
                                },
                              );
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              S.of(context).clear,
                              style: AppTextStyles.medium(
                                fontSize: 16.sp,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      });
    },
  );
}
