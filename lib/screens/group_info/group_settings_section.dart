import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/cubit/group_cubit.dart';
import 'package:two_one_two_messenger/cubit/group_state.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

import 'group_accordion_header.dart';

class GroupSettingsSection extends StatefulWidget {
  const GroupSettingsSection({
    super.key,
    required this.groupId,
    required this.isAdmin,
    required this.expanded,
    required this.onToggleExpanded,
  });

  final String groupId;
  final bool isAdmin;
  final bool expanded;
  final VoidCallback onToggleExpanded;

  @override
  State<GroupSettingsSection> createState() => _GroupSettingsSectionState();
}

class _GroupSettingsSectionState extends State<GroupSettingsSection> {
  bool _settingsDirty = false;

  void _markSettingsDirty() {
    if (!_settingsDirty) setState(() => _settingsDirty = true);
  }

  Future<void> _saveSettings(BuildContext context) async {
    await groupCubit.updateGroup(context, widget.groupId, ChatType.group,
        showSuccessMessage: true);
    if (mounted) setState(() => _settingsDirty = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GroupAccordionHeader(
          title: 'Group Settings',
          isExpanded: widget.expanded,
          onTap: widget.onToggleExpanded,
        ),
        if (widget.expanded)
          BlocBuilder<GroupCubit, GroupState>(builder: (context, state) {
            return Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w).copyWith(top: 10.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 18.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B1F25),
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                    color: const Color(0xFF86334D).withValues(alpha: 0.55),
                  ),
                ),
                child: Column(
                  children: [
                    _buildGroupPermission(
                      context,
                      text: 'Private Group',
                      defaultValue: state.privateGroup,
                      onChanged: widget.isAdmin
                          ? (value) {
                              groupCubit.togglePrivateGroup(value);
                              _markSettingsDirty();
                            }
                          : null,
                    ),
                    _buildGroupPermission(
                      context,
                      text: 'Show Members Profile Photo',
                      defaultValue: state.showProfilePhotoForGroup,
                      onChanged: widget.isAdmin
                          ? (value) {
                              groupCubit.toggleShowProfilePhoto(value);
                              _markSettingsDirty();
                            }
                          : null,
                    ),
                    _buildGroupPermission(
                      context,
                      text: 'Show Group Profile Photo',
                      defaultValue: state.showGroupProfilePhoto,
                      onChanged: widget.isAdmin
                          ? (value) {
                              groupCubit.toggleShowGroupProfilePhoto(value);
                              _markSettingsDirty();
                            }
                          : null,
                    ),
                    _buildGroupPermission(
                      context,
                      text: S.of(context).allowMembersToSendMessage,
                      defaultValue: state.sendMessageForGroup,
                      onChanged: widget.isAdmin
                          ? (value) {
                              groupCubit.toggleSendMessage(value);
                              _markSettingsDirty();
                            }
                          : null,
                    ),
                    _buildGroupPermission(
                      context,
                      text: 'Hide Members Info',
                      defaultValue: state.hideMembersInfo,
                      onChanged: widget.isAdmin
                          ? (value) {
                              groupCubit.toggleHideMembersInfo(value);
                              _markSettingsDirty();
                            }
                          : null,
                    ),
                    _buildGroupPermission(
                      context,
                      text: 'Hide New Members Message',
                      defaultValue: state.hideNewMembersMessage,
                      onChanged: widget.isAdmin
                          ? (value) {
                              groupCubit.toggleHideNewMembersMessage(value);
                              _markSettingsDirty();
                            }
                          : null,
                    ),
                    _buildGroupPermission(
                      context,
                      text: 'Restrict Content Sharing',
                      defaultValue: state.restrictContentSharing,
                      onChanged: widget.isAdmin
                          ? (value) {
                              groupCubit.toggleRestrictContentSharing(value);
                              _markSettingsDirty();
                            }
                          : null,
                      isLast: true,
                    ),
                    if (_settingsDirty) ...[
                      16.s,
                      SizedBox(
                        width: double.infinity,
                        height: 44.h,
                        child: ElevatedButton(
                          onPressed: () => _saveSettings(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text('Save Changes',
                              style: AppTextStyles.medium(fontSize: 15.sp)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildGroupPermission(
    BuildContext context, {
    required String text,
    required Function(bool)? onChanged,
    required bool defaultValue,
    bool isLast = false,
  }) {
    return Column(
      children: [
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.medium(
                  fontSize: 16.sp,
                ),
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
        if (!isLast)
          Divider(
            height: 0.h,
            color: AppColors.white.withValues(alpha: 0.09),
          ),
      ],
    );
  }
}
