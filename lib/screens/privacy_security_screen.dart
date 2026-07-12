import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/cubit/profile_cubit.dart';
import 'package:two_one_two_messenger/cubit/profile_state.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/appbar.dart';

class PrivacyAndSecuritySetting extends StatefulWidget {
  const PrivacyAndSecuritySetting({super.key});

  @override
  State<PrivacyAndSecuritySetting> createState() =>
      _PrivacyAndSecuritySettingState();
}

class _PrivacyAndSecuritySettingState extends State<PrivacyAndSecuritySetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CommonAppBar(
          title:  S.of(context).privacyAndSecurity,
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
              buildProfilePrivacyTile(context,
                  text: S.of(context).makeProfilePrivate,
                  subTitle: state.profilePrivacy == ProfilePivacy.private.value
                      ? S.of(context).privateProfileText
                      : S.of(context).publicProfileText,
                  onChanged: (isPrivate) {
                profileCubit.handleProfilePrivacy(isPrivate, context);
              },
                  defaultValue:
                      state.profilePrivacy == ProfilePivacy.private.value),
              buildNormalTile(
                context,
                text: S.of(context).privacyPolicy,
                subTitle: "",
                onTap: () {
                  EasyLauncher.url(
                      url: 'https://the212.me/app-privacy-policy/',
                      mode: Mode.inAppBrowser);
                },
              )
            ],
          );
        }));
  }

  Widget buildNormalTile(
    BuildContext context, {
    required String text,
    required String subTitle,
    required void Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.h.s,
          Text(
            text,
            style: AppTextStyles.medium(
              fontSize: 18.sp,
            ),
          ),
          if (subTitle.isNotEmpty) 8.h.s,
          if (subTitle.isNotEmpty)
            Text(
              subTitle,
              style: AppTextStyles.regular(
                  fontSize: 12.sp, color: AppColors.textColorHint),
            ),
          17.h.s,
          Divider(
            height: 0.h,
            color: AppColors.darkInputFill,
          ),
        ],
      ),
    );
  }

  Widget buildProfilePrivacyTile(
    BuildContext context, {
    required String text,
    required String subTitle,
    required Function(bool)? onChanged,
    required bool defaultValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: AppTextStyles.medium(
                      fontSize: 18.sp,
                    ),
                  ),
                  Text(
                    subTitle,
                    style: AppTextStyles.regular(
                        fontSize: 12.sp, color: AppColors.textColorHint),
                  ),
                ],
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
