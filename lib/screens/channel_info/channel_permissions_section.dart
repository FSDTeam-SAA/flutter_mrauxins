import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/cubit/group_cubit.dart';
import 'package:two_one_two_messenger/cubit/group_state.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

class ChannelPermissionsSection extends StatelessWidget {
  const ChannelPermissionsSection({
    super.key,
    required this.groupId,
    required this.isAdmin,
  });

  final String groupId;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isAdmin,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: BlocBuilder<GroupCubit, GroupState>(builder: (context, state) {
          return Column(
            children: [
              _buildGroupPermission(
                context,
                text: 'Private Channel',
                defaultValue: state.privateGroup,
                onChanged: (value) {
                  groupCubit.togglePrivateGroup(value);
                  groupCubit.updateGroupSetting(
                      context, groupId, ChatType.channel);
                },
              ),
              _buildGroupPermission(
                context,
                text: S.of(context).lblShowProfilePhoto,
                defaultValue: state.showProfilePhotoForGroup,
                onChanged: (value) {
                  groupCubit.toggleShowProfilePhotoForUpdate(
                      context, groupId, value, ChatType.channel);
                },
              ),
              _buildGroupPermission(
                context,
                text: 'Show Channel Display Image',
                defaultValue: state.showGroupProfilePhoto,
                onChanged: (value) {
                  groupCubit.toggleShowGroupProfilePhoto(value);
                  groupCubit.updateGroupSetting(
                      context, groupId, ChatType.channel);
                },
              ),
              _buildGroupPermission(
                context,
                text: 'Hide Subscribers Info',
                defaultValue: state.hideMembersInfo,
                onChanged: (value) {
                  groupCubit.toggleHideMembersInfo(value);
                  groupCubit.updateGroupSetting(
                      context, groupId, ChatType.channel);
                },
              ),
              _buildGroupPermission(
                context,
                text: 'Hide New Subscribers Message',
                defaultValue: state.hideNewMembersMessage,
                onChanged: (value) {
                  groupCubit.toggleHideNewMembersMessage(value);
                  groupCubit.updateGroupSetting(
                      context, groupId, ChatType.channel);
                },
              ),
              _buildGroupPermission(
                context,
                text: 'Restrict Content Sharing',
                defaultValue: state.restrictContentSharing,
                onChanged: (value) {
                  groupCubit.toggleRestrictContentSharing(value);
                  groupCubit.updateGroupSetting(
                      context, groupId, ChatType.channel);
                },
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildGroupPermission(
    BuildContext context, {
    required String text,
    required Function(bool)? onChanged,
    required bool defaultValue,
  }) {
    return Column(
      children: [
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: AppTextStyles.regular(
                fontSize: 14.sp,
              ),
            ),
            Switch(
              value: defaultValue,
              onChanged: onChanged,
              activeTrackColor: AppColors.primaryColor,
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Divider(
          height: 0.h,
          color: AppColors.darkInputFill,
        ),
      ],
    );
  }
}
