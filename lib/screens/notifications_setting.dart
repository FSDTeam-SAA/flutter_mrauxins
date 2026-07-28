import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/cubit/profile_cubit.dart';
import 'package:two_one_two_messenger/cubit/profile_state.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/widgets/appbar.dart';

class NotificationsSetting extends StatefulWidget {
  const NotificationsSetting({super.key});

  @override
  State<NotificationsSetting> createState() => _NotificationsSettingState();
}

class _NotificationsSettingState extends State<NotificationsSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CommonAppBar(
          title: S.of(context).notificationsSettings,
          isBackShow: true,
          isActionsShow: false,
        ),
        body:
            BlocBuilder<ProfileCubit, ProfileState>(builder: (context, state) {
          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
            ),
            children: [
              buildNotificationSettingTile(
                context,
                text: S.of(context).stopNotifications,
                defaultValue: state.userData?.isStopNotification ?? false,
                onChanged: (value) {
                  profileCubit.toggleStopNtification(context, value);
                },
              ),
              buildNotificationSettingTile(
                context,
                text: S.of(context).muteNotification,
                defaultValue: state.userData?.isMuteNotification ?? false,
                onChanged: (value) {
                  profileCubit.toggleMuteNotification(context, value);
                },
              ),
            ],
          );
        }));
  }

  Widget buildNotificationSettingTile(
    BuildContext context, {
    required String text,
    required Function(bool)? onChanged,
    required bool defaultValue,
  }) {
    return Column(
      children: [
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: AppTextStyles.medium(
                fontSize: 18.sp,
              ),
            ),
            SizedBox(
              height: 25.h,
              child: Switch(
                padding: EdgeInsets.zero,
                value: defaultValue,
                onChanged: onChanged,
                activeTrackColor: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 17.h),
        Divider(
          height: 0.h,
          color: AppColors.darkInputFill,
        ),
      ],
    );
  }

}
