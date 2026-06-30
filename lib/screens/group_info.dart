import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:two_one_two_messenger/cubit/home_cubit.dart';
import 'package:two_one_two_messenger/cubit/home_state.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/date_format.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/group_info_model.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/utils/app_pop_up.dart';
import 'package:two_one_two_messenger/utils/image_picker.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/avatar_widgets.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';

import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/navigation.dart';
import '../utils/text_style.dart';
import '../widgets/appbar.dart';
import '../widgets/buttons.dart';
import '../widgets/svg_images.dart';
import '../widgets/text_fields.dart';
import 'add_member_group.dart';

class GroupInfoScreen extends StatefulWidget {
  const GroupInfoScreen(
      {super.key, required this.groupId, required this.currentUser});
  final String groupId;
  final UserData currentUser;
  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

enum _GroupInfoSection { settings, invite }

enum _GroupInfoTab { members, admins }

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  final _groupFormKey = GlobalKey<FormState>();
  _GroupInfoSection? _expandedSection;
  _GroupInfoTab _selectedTab = _GroupInfoTab.members;

  @override
  void initState() {
    super.initState();
    onInit();
  }

  Future<void> onInit() async {
    homeCubit.getGroupInfobyId(context, widget.groupId);
// user??= await homeCubit.dbHelper.getLoginData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        isBackShow: true,
        isActionsShow: false,
        title: S.of(context).lblGroupInfo,
      ),
      body: SafeArea(
        child:
            BlocBuilder<HomeCubit, HomeState>(builder: (contextProfile, state) {
          if (state.groupLoadingState == LoadingState.loading) {
            return Center(child: CustomLoadingWidget());
          } else if (state.groupLoadingState == LoadingState.error) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child:
                        Text(S.of(context).somethingWentWrongPleaseTryAgain)),
                20.s,
                CustomButton(
                    onPressed: () {
                      homeCubit.getGroupInfobyId(context, widget.groupId);
                    },
                    child: Text(
                      S.of(context).refresh,
                      style: AppTextStyles.baseStyle(),
                    ))
              ],
            );
          }
          final participants = state.groupData?.participants ?? [];
          final admins = state.groupData?.admins ?? [];
          final selectedPeople =
              _selectedTab == _GroupInfoTab.members ? participants : admins;
          final isAdmin = state.groupData?.isAdmin ?? false;

          return Padding(
            padding: EdgeInsets.only(top: 20.h),
            child: Form(
              key: _groupFormKey,
              child: ListView(
                padding: EdgeInsets.only(bottom: 24.h),
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 150.h,
                        child: Container(
                          width: 120.w,
                          height: 120.h,
                          decoration: BoxDecoration(
                            color: AppColors.darkAppBar,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.darkAppBar, width: 4.w),
                          ),
                          child: state.selectedGroupPic != null
                              ? CircleAvatar(
                                  radius: 60.r,
                                  backgroundImage: FileImage(
                                      File(state.selectedGroupPic!.path)),
                                  // Use FileImage for circular display
                                  backgroundColor: Colors
                                      .transparent, // Set background to transparent if needed
                                )
                              : ((state.groupData?.groupImage ?? "").isNotEmpty &&
                                      (state.groupData?.isGroupProfilePhoto ?? true))
                                  ? AvatarWidgets(
                                      userPic:
                                          state.groupData?.groupImage ?? "",
                                      height: 120,
                                      width: 120,
                                    )
                                  : Center(
                                      child: SvgImage(
                                        source: SvgAssets.icNewGroup,
                                        width: 50.w,
                                        color: AppColors.white,
                                      ),
                                    ),
                        ),
                      ),
                      if ((state.groupData?.isAdmin ?? false))
                        Positioned(
                          bottom: 0,
                          right: 0,
                          left: 0,
                          child: GestureDetector(
                            onTap: () {
                              showCustomImageOptionPickerDialog(
                                  context: context,
                                  onImagePicked: (image) {
                                    homeCubit.selectGroupImage(image);
                                    if (_groupFormKey.currentState
                                            ?.validate() ??
                                        false) {
                                      homeCubit.updateGroup(context,
                                          widget.groupId, ChatType.group);
                                    }
                                  });
                            },
                            child: CircleAvatar(
                              radius: 15.r,
                              backgroundColor: AppColors.primaryColor,
                              child: SvgImage(
                                source: SvgAssets.icCamera,
                                width: 15.w,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                    ),
                    child: CustomTextField(
                      controller: state.groupNameController,
                      label: S.of(context).groupNamePlaceholder,
                      readOnly: !isAdmin,
                      prefixIcon: SvgImage(
                        source: SvgAssets.icNewGroup,
                        fit: BoxFit.scaleDown,
                        color: AppColors.white,
                      ),
                      textInputAction: TextInputAction.next,
                      onChanged: (_) {
                        if (isAdmin &&
                            (_groupFormKey.currentState?.validate() ?? false)) {
                          homeCubit.updateGroupSetting(
                              context, widget.groupId, ChatType.group);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return S.of(context).groupNameError;
                        }
                        return null;
                      },
                    ),
                  ),
                  24.s,
                  _accordionHeader(
                    title: 'Group Settings',
                    section: _GroupInfoSection.settings,
                  ),
                  if (_expandedSection == _GroupInfoSection.settings)
                    _settingsPanel(context, state, isAdmin),
                  12.s,
                  if ((state.groupData?.inviteLink ?? '').isNotEmpty) ...[
                    _accordionHeader(
                      title: 'Invite Link',
                      section: _GroupInfoSection.invite,
                    ),
                    if (_expandedSection == _GroupInfoSection.invite)
                      _invitePanel(context, state),
                    20.s,
                  ],
                  _peopleTabs(),
                  26.s,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedTab == _GroupInfoTab.members
                              ? S.of(context).groupMembers
                              : S.of(context).admin,
                          style: AppTextStyles.medium(
                            fontSize: 18.sp,
                            color: AppColors.purpleText,
                          ),
                        ),
                        if (isAdmin && _selectedTab == _GroupInfoTab.members)
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              NavigationService().navigateTo(
                                AddMemberGroupScreen(
                                  title: S.of(context).addMembers,
                                  admins: state.groupData?.participants ?? [],
                                  isGroup: true,
                                  onSubmit: () => homeCubit.addMembersToGroup(
                                      context, widget.groupId),
                                ),
                              );
                            },
                            child: Text(
                              S.of(context).addMembers,
                              style: AppTextStyles.medium(
                                fontSize: 16.sp,
                                color: AppColors.purpleText,
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                  if (selectedPeople.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 28.h),
                      child: Text(
                        _selectedTab == _GroupInfoTab.members
                            ? 'No members to show'
                            : 'No admins to show',
                        style: AppTextStyles.regular(
                          fontSize: 14.sp,
                          color: AppColors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ...selectedPeople.map(
                    (participant) => membersTile(
                      context: context,
                      groupId: widget.groupId,
                      currentUserIsAdmin: isAdmin,
                      participant: participant,
                      forceAdminBadge: _selectedTab == _GroupInfoTab.admins,
                    ),
                  )
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _accordionHeader({
    required String title,
    required _GroupInfoSection section,
  }) {
    final isExpanded = _expandedSection == section;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () {
          setState(() {
            _expandedSection = isExpanded ? null : section;
          });
        },
        child: Container(
          constraints: BoxConstraints(minHeight: 48.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isExpanded
                ? const Color(0xFF2D2029)
                : AppColors.dialogBg.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: const Color(0xFF86334D).withValues(alpha: 0.65),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.medium(fontSize: 15.sp),
                ),
              ),
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: AppColors.white,
                size: 22.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _settingsDirty = false;

  void _markSettingsDirty() {
    if (!_settingsDirty) setState(() => _settingsDirty = true);
  }

  Future<void> _saveSettings(BuildContext context) async {
    await homeCubit.updateGroup(
        context, widget.groupId, ChatType.group,
        showSuccessMessage: true);
    if (mounted) setState(() => _settingsDirty = false);
  }

  Widget _settingsPanel(BuildContext context, HomeState state, bool isAdmin) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w).copyWith(top: 10.h),
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
            buildGroupPermission(
              context,
              text: 'Private Group',
              defaultValue: state.privateGroup,
              onChanged: isAdmin
                  ? (value) {
                      homeCubit.togglePrivateGroup(value);
                      _markSettingsDirty();
                    }
                  : null,
            ),
            buildGroupPermission(
              context,
              text: 'Show Members Profile Photo',
              defaultValue: state.showProfilePhotoForGroup,
              onChanged: isAdmin
                  ? (value) {
                      homeCubit.toggleShowProfilePhoto(value);
                      _markSettingsDirty();
                    }
                  : null,
            ),
            buildGroupPermission(
              context,
              text: 'Show Group Profile Photo',
              defaultValue: state.showGroupProfilePhoto,
              onChanged: isAdmin
                  ? (value) {
                      homeCubit.toggleShowGroupProfilePhoto(value);
                      _markSettingsDirty();
                    }
                  : null,
            ),
            buildGroupPermission(
              context,
              text: S.of(context).allowMembersToSendMessage,
              defaultValue: state.sendMessageForGroup,
              onChanged: isAdmin
                  ? (value) {
                      homeCubit.toggleSendMessage(value);
                      _markSettingsDirty();
                    }
                  : null,
            ),
            buildGroupPermission(
              context,
              text: 'Hide Members Info',
              defaultValue: state.hideMembersInfo,
              onChanged: isAdmin
                  ? (value) {
                      homeCubit.toggleHideMembersInfo(value);
                      _markSettingsDirty();
                    }
                  : null,
            ),
            buildGroupPermission(
              context,
              text: 'Hide New Members Message',
              defaultValue: state.hideNewMembersMessage,
              onChanged: isAdmin
                  ? (value) {
                      homeCubit.toggleHideNewMembersMessage(value);
                      _markSettingsDirty();
                    }
                  : null,
            ),
            buildGroupPermission(
              context,
              text: 'Restrict Content Sharing',
              defaultValue: state.restrictContentSharing,
              onChanged: isAdmin
                  ? (value) {
                      homeCubit.toggleRestrictContentSharing(value);
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
  }

  final TextEditingController _customLinkController = TextEditingController();
  String? _customLinkStatus;
  bool _customLinkValid = false;

  void _validateCustomLink(String value) {
    final cleaned = value.trim().toLowerCase();
    if (cleaned.isEmpty) {
      setState(() {
        _customLinkStatus = null;
        _customLinkValid = false;
      });
      return;
    }
    final valid = RegExp(r'^[a-z0-9_]{5,}$').hasMatch(cleaned);
    setState(() {
      _customLinkValid = valid;
      _customLinkStatus = valid
          ? '$cleaned is available.'
          : 'Use a-z, 0-9 and underscores. Minimum 5 characters.';
    });
  }

  void _saveCustomLink(BuildContext context, String chatId) {
    if (!_customLinkValid) return;
    final customName = _customLinkController.text.trim().toLowerCase();
    final newLink = 'messenger212://join/$chatId/$customName';
    homeCubit.apiClient.updateGroup(
      context,
      groupId: chatId,
      inputData: {"inviteLink": newLink, "chatType": "group"},
      files: null,
    ).then((_) {
      if (!mounted) return;
      homeCubit.getGroupInfobyId(context, chatId);
      Utils.showSnackBar(context, 'Share link updated.');
    });
  }

  Widget _invitePanel(BuildContext context, HomeState state) {
    final link = state.groupData?.inviteLink ?? '';
    final isPrivate = state.privateGroup;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w).copyWith(top: 10.h),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFF2B1F25),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invite Link', style: AppTextStyles.medium(fontSize: 17.sp)),
            22.s,
            Text(
              isPrivate
                  ? 'This group is set to private, so people can only join using an invite link.'
                  : 'This group is public, so anyone with this link can view and join it.',
              style: AppTextStyles.regular(
                fontSize: 14.sp,
                color: AppColors.white.withValues(alpha: 0.6),
              ),
            ),
            16.s,
            Text(
              isPrivate
                  ? 'Your unique invite link is below, and you can revoke it or create a new one at any time.'
                  : 'Customise your share link or use the one generated below.',
              style: AppTextStyles.regular(
                fontSize: 14.sp,
                color: AppColors.white.withValues(alpha: 0.6),
              ),
            ),
            14.s,
            if (!isPrivate) ...[
              Container(
                height: 45.h,
                padding: EdgeInsets.only(left: 14.w),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  children: [
                    Text('messenger212://join/.../',
                        style: AppTextStyles.regular(
                            fontSize: 12.sp,
                            color: AppColors.white.withValues(alpha: 0.4))),
                    Expanded(
                      child: TextField(
                        controller: _customLinkController,
                        onChanged: _validateCustomLink,
                        style: AppTextStyles.regular(fontSize: 14.sp),
                        decoration: InputDecoration(
                          hintText: 'custom-name',
                          hintStyle: AppTextStyles.regular(
                              fontSize: 14.sp,
                              color: AppColors.white.withValues(alpha: 0.3)),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                      ),
                    ),
                    if (_customLinkValid)
                      IconButton(
                        onPressed: () =>
                            _saveCustomLink(context, widget.groupId),
                        icon: Icon(Icons.check_circle,
                            color: Colors.green, size: 22.sp),
                      ),
                  ],
                ),
              ),
              if (_customLinkStatus != null) ...[
                8.s,
                Text(
                  _customLinkStatus!,
                  style: AppTextStyles.regular(
                    fontSize: 13.sp,
                    color: _customLinkValid ? Colors.green : Colors.orange,
                  ),
                ),
              ],
              14.s,
            ],
            Container(
              height: 45.h,
              padding: EdgeInsets.only(left: 14.w),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      link,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.regular(fontSize: 14.sp),
                    ),
                  ),
                  if (isPrivate)
                    IconButton(
                      onPressed: () => _showRevokeDialog(context),
                      icon: Icon(
                        Icons.refresh,
                        color: AppColors.white,
                        size: 20.sp,
                      ),
                    ),
                ],
              ),
            ),
            22.s,
            Row(
              children: [
                Expanded(
                  child: _inviteActionButton(
                    text: 'Copy',
                    color: AppColors.white.withValues(alpha: 0.12),
                    onPressed: () => Utils.copyToClipboard(context, link),
                  ),
                ),
                8.s,
                Expanded(
                  child: _inviteActionButton(
                    text: 'Share',
                    color: AppColors.primaryColor,
                    onPressed: () => Share.share(
                      'Join "${state.groupData?.groupName ?? "group"}" on 212 Messenger:\n$link',
                    ),
                  ),
                ),
                8.s,
                Expanded(
                  child: _inviteActionButton(
                    text: 'QR Code',
                    color: const Color(0xFF930C17),
                    borderColor: const Color(0xFFDF3340),
                    onPressed: () => _showQrDialog(context, link),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _inviteActionButton({
    required String text,
    required Color color,
    Color? borderColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 46.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
            side: BorderSide(color: borderColor ?? Colors.transparent),
          ),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.medium(fontSize: 15.sp),
        ),
      ),
    );
  }

  void _showQrDialog(BuildContext context, String link) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.dialogBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Invite QR Code',
                    style: AppTextStyles.medium(fontSize: 18.sp)),
                16.s,
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: QrImageView(
                    data: link,
                    version: QrVersions.auto,
                    size: 220.w,
                  ),
                ),
                18.s,
                CustomButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Close',
                    style: AppTextStyles.medium(color: AppColors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRevokeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF1E1D22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
            side: BorderSide(
              color: const Color(0xFF8E1322).withValues(alpha: 0.8),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 18.r,
                  backgroundColor: AppColors.white.withValues(alpha: 0.08),
                  child:
                      Icon(Icons.link_off, color: AppColors.white, size: 18.sp),
                ),
                18.s,
                Text('Revoke Link',
                    style: AppTextStyles.medium(fontSize: 20.sp)),
                14.s,
                Text(
                  'Are you sure you want to revoke this link? Once revoked, it can no longer be used to join.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.regular(
                    fontSize: 15.sp,
                    color: AppColors.white.withValues(alpha: 0.72),
                  ),
                ),
                22.s,
                Row(
                  children: [
                    Expanded(
                      child: _inviteActionButton(
                        text: 'Cancel',
                        color: AppColors.white.withValues(alpha: 0.14),
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ),
                    12.s,
                    Expanded(
                      child: _inviteActionButton(
                        text: 'Revoke',
                        color: const Color(0xFF930C17),
                        borderColor: const Color(0xFFDF3340),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          homeCubit.revokeGroupInviteLink(
                              context, widget.groupId);
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _peopleTabs() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        height: 42.h,
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppColors.darkInputFill.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.36),
          ),
        ),
        child: Row(
          children: [
            _tabButton(_GroupInfoTab.members, 'Members'),
            _tabButton(_GroupInfoTab.admins, 'Admins'),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(_GroupInfoTab tab, String label) {
    final isSelected = _selectedTab == tab;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: () => setState(() => _selectedTab = tab),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF68283B) : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
            border: isSelected
                ? Border.all(
                    color: const Color(0xFFC13C61).withValues(alpha: 0.8),
                  )
                : null,
          ),
          child: Text(
            label,
            style: AppTextStyles.regular(
              fontSize: 13.sp,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGroupPermission(
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

  Widget membersTile(
      {required BuildContext context,
      // required bool isAdmin,
      required bool currentUserIsAdmin,
      required String groupId,
      required Participant participant,
      bool forceAdminBadge = false}) {
    final isParticipantAdmin =
        forceAdminBadge || (participant.isAdmin ?? false);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0.w),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.darkAppBar))),
      child: Column(
        children: [
          17.s,
          Row(
            children: [
              AvatarWidgets(
                userPic: participant.profilePicture ?? "",
                height: 50,
                width: 50,
              ),
              16.s,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            participant.id == widget.currentUser.sId
                                ? S.of(context).you
                                // : AppMethods.getNickNameForParticipate(sender)
                                : participant.name ?? "",
                            //   (user.isActiveNickname ?? false)
                            // ? (user.nickName ??
                            //     user.name ??
                            //     user.userName ??
                            //     "")
                            // : (user.name ?? user.userName ?? ""),
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.medium(
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                        4.s,
                        if (isParticipantAdmin)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                                color: AppColors.purpleText,
                                borderRadius: BorderRadius.circular(16)),
                            child: Text(
                              S.of(context).admin,
                              style: AppTextStyles.regular(
                                  color: AppColors.textColorPrimary),
                            ),
                          )
                      ],
                    ),
                    6.s,
                    if (participant.lastSeen != null)
                      Text(
                        "${S.of(context).sLastSeen} ${participant.lastSeen?.formattedDateWithDayMonthAtTime}",
                        style: AppTextStyles.regular(
                            fontSize: 13.sp,
                            color: AppColors.white.withValues(alpha: 0.5)),
                      )
                  ],
                ),
              ),
              if ((participant.id != widget.currentUser.sId) &&
                  !(participant.isCreator ?? false) &&
                  currentUserIsAdmin)
                buildOptionMenuForGroup(
                    context: context,
                    isAdmin: isParticipantAdmin,
                    isGroup: true,
                    name: participant.name ?? "",
                    onSelected: handleGroupAction,
                    userId: participant.id ?? ""),
            ],
          ),
          17.s,
        ],
      ),
    );
  }

  Future<void> _createAdmin(BuildContext context, String userId) async {
    await homeCubit.assignAdminToGroup(
      context,
      {"chatId": widget.groupId, "userId": userId, "removeFromAdmin": false},
    );
  }

  Future<void> _removeAdmin(BuildContext context, String userId) async {
    await homeCubit.assignAdminToGroup(
      context,
      {"chatId": widget.groupId, "userId": userId, "removeFromAdmin": true},
    );
  }

  Future<void> _removeMember(
      BuildContext context, String userId, String name, bool isGroup) async {
    await homeCubit.removeMemberFromGroup(
        context,
        {
          "chatId": widget.groupId,
          "memberId": userId,
        },
        name,
        true);
  }

  void handleGroupAction(BuildContext context, GroupAdminAthority authority,
      String userId, String name, bool isGroup) {
    switch (authority) {
      case GroupAdminAthority.createAdmin:
        _createAdmin(context, userId);
        break;
      case GroupAdminAthority.removeMember:
        _removeMember(context, userId, name, isGroup);
        break;
      case GroupAdminAthority.removeAdmin:
        _removeAdmin(context, userId);
        break;
    }
  }
}
