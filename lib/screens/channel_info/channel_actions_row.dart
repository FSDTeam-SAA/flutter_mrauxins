import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/utils/app_dialoge.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/buttons.dart';

class ChannelActionsRow extends StatelessWidget {
  const ChannelActionsRow({
    super.key,
    required this.groupId,
    required this.isAdmin,
    required this.isCreatedBy,
    required this.formKey,
  });

  final String groupId;
  final bool isAdmin;
  final bool isCreatedBy;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          if (isAdmin)
            Expanded(
              child: CustomButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      groupCubit.updateGroup(context, groupId, ChatType.channel);
                    }
                  },
                  child: Text(
                    S.of(context).update,
                    style: AppTextStyles.medium(
                      fontSize: 16.sp,
                      color: AppColors.white,
                    ),
                  )),
            ),
          10.s,
          Expanded(
            child: CustomButton(
                onPressed: () async {
                  if (isAdmin && isCreatedBy) {
                    showCommonAlertDialog(
                      context: context,
                      title: S.of(context).deleteChannel,
                      subTitle: S.of(context).lblDeleteChannelSubTitle,
                      submitBtnText: S.of(context).delete,
                      onSubmit: () =>
                          groupCubit.deleteGroup(context, groupId),
                    );
                  } else {
                    showCommonAlertDialog(
                      context: context,
                      title: S.of(context).leaveChannel,
                      subTitle: S.of(context).lblLeaveChannelSubTitle,
                      submitBtnText: S.of(context).yes,
                      onSubmit: () =>
                          groupCubit.leaveGroup(context, groupId),
                    );
                  }
                },
                child: Text(
                  isAdmin && isCreatedBy
                      ? S.of(context).deleteChannel
                      : S.of(context).leaveChannel,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.medium(
                    fontSize: 16.sp,
                    color: AppColors.white,
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
