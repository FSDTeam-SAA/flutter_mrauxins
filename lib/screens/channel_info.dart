import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/cubit/home_cubit.dart';
import 'package:two_one_two_messenger/cubit/home_state.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/date_format.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/group_info_model.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/utils/app_dialoge.dart';
import 'package:two_one_two_messenger/utils/app_pop_up.dart';
import 'package:two_one_two_messenger/utils/image_picker.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/avatar_widgets.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/navigation.dart';
import '../utils/text_style.dart';
import '../widgets/appbar.dart';
import '../widgets/buttons.dart';
import '../widgets/svg_images.dart';
import '../widgets/text_fields.dart';
import 'add_member_group.dart';

class ChannelInfoScreen extends StatefulWidget {
  const ChannelInfoScreen(
      {super.key, required this.groupId, required this.currentUser});
  final String groupId;
  final UserData currentUser;
  @override
  State<ChannelInfoScreen> createState() => _ChannelInfoScreenState();
}

class _ChannelInfoScreenState extends State<ChannelInfoScreen> {
  final _groupFormKey = GlobalKey<FormState>();
  final TextEditingController _customLinkController = TextEditingController();
  String? _customLinkStatus;
  bool _customLinkValid = false;

  void _validateCustomLink(String value) {
    final cleaned = value.trim().toLowerCase();
    if (cleaned.isEmpty) {
      setState(() { _customLinkStatus = null; _customLinkValid = false; });
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
      inputData: {"inviteLink": newLink, "chatType": "channel"},
      files: null,
    ).then((_) {
      if (!mounted) return;
      homeCubit.getGroupInfobyId(context, chatId);
      Utils.showSnackBar(context, 'Share link updated.');
    });
  }

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
        title: S.of(context).lblChannelInfo,
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
                    child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    S.of(context).somethingWentWrongPleaseTryAgain,
                    style: AppTextStyles.regular(),
                  ),
                )),
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

          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h).copyWith(bottom: 0),
            child: Form(
              key: _groupFormKey,
              child: ListView(
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
                              : (state.groupData?.groupImage ?? "").isNotEmpty
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
                                  onImagePicked: homeCubit.selectGroupImage);
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
                      readOnly: !(state.groupData?.isAdmin ?? false),
                      prefixIcon: SvgImage(
                        source: SvgAssets.icNewGroup,
                        fit: BoxFit.scaleDown,
                        color: AppColors.white,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return S.of(context).groupNameError;
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                    ),
                    child: Text(
                      S.of(context).channelPermission,
                      style: AppTextStyles.medium(
                        fontSize: 14.sp,
                        color: AppColors.purpleText,
                      ),
                    ),
                  ),
                  16.s,
                  IgnorePointer(
                    ignoring: !(state.groupData?.isAdmin ?? false),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                      ),
                      child: BlocBuilder<HomeCubit, HomeState>(
                          builder: (context, state) {
                        return Column(
                          children: [
                            buildGroupPermission(
                              context,
                              text: 'Private Channel',
                              defaultValue: state.privateGroup,
                              onChanged: (value) {
                                homeCubit.togglePrivateGroup(value);
                                homeCubit.updateGroupSetting(
                                    context, widget.groupId, ChatType.channel);
                              },
                            ),
                            buildGroupPermission(
                              context,
                              text: S.of(context).lblShowProfilePhoto,
                              defaultValue: state.showProfilePhotoForGroup,
                              onChanged: (value) {
                                homeCubit.toggleShowProfilePhotoForUpdate(
                                    context,
                                    widget.groupId,
                                    value,
                                    ChatType.channel);
                              },
                            ),
                            buildGroupPermission(
                              context,
                              text: 'Hide Subscribers Info',
                              defaultValue: state.hideMembersInfo,
                              onChanged: (value) {
                                homeCubit.toggleHideMembersInfo(value);
                                homeCubit.updateGroupSetting(
                                    context, widget.groupId, ChatType.channel);
                              },
                            ),
                            buildGroupPermission(
                              context,
                              text: 'Hide New Subscribers Message',
                              defaultValue: state.hideNewMembersMessage,
                              onChanged: (value) {
                                homeCubit.toggleHideNewMembersMessage(value);
                                homeCubit.updateGroupSetting(
                                    context, widget.groupId, ChatType.channel);
                              },
                            ),
                            buildGroupPermission(
                              context,
                              text: 'Restrict Content Sharing',
                              defaultValue: state.restrictContentSharing,
                              onChanged: (value) {
                                homeCubit.toggleRestrictContentSharing(value);
                                homeCubit.updateGroupSetting(
                                    context, widget.groupId, ChatType.channel);
                              },
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                  30.s,
                  if ((state.groupData?.inviteLink ?? '').isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.dialogBg,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: AppColors.darkInputFill),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Invite Link',
                                style: AppTextStyles.medium(fontSize: 16.sp)),
                            12.s,
                            Text(
                              state.privateGroup
                                  ? 'People can only join this channel using an invite link.'
                                  : 'This channel is public, so anyone with this link can view and join it.',
                              style: AppTextStyles.regular(
                                fontSize: 13.sp,
                                color: AppColors.white.withValues(alpha: 0.65),
                              ),
                            ),
                            12.s,
                            Text(
                              state.privateGroup
                                  ? 'Your unique invite link is below, and you can revoke it at any time.'
                                  : 'Customise your share link or use the one generated below.',
                              style: AppTextStyles.regular(
                                fontSize: 13.sp,
                                color: AppColors.white.withValues(alpha: 0.65),
                              ),
                            ),
                            12.s,
                            if (!state.privateGroup) ...[
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
                                            color: AppColors.white
                                                .withValues(alpha: 0.4))),
                                    Expanded(
                                      child: TextField(
                                        controller: _customLinkController,
                                        onChanged: _validateCustomLink,
                                        style: AppTextStyles.regular(
                                            fontSize: 14.sp),
                                        decoration: InputDecoration(
                                          hintText: 'custom-name',
                                          hintStyle: AppTextStyles.regular(
                                              fontSize: 14.sp,
                                              color: AppColors.white
                                                  .withValues(alpha: 0.3)),
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 10.h),
                                        ),
                                      ),
                                    ),
                                    if (_customLinkValid)
                                      IconButton(
                                        onPressed: () => _saveCustomLink(
                                            context, widget.groupId),
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
                                    color: _customLinkValid
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ],
                              12.s,
                            ],
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                color: AppColors.darkInputFill,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                state.groupData?.inviteLink ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.regular(fontSize: 13.sp),
                              ),
                            ),
                            12.s,
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 46.h,
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          Utils.copyToClipboard(context,
                                              state.groupData?.inviteLink ?? ''),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.white
                                            .withValues(alpha: 0.12),
                                        foregroundColor: AppColors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(24.r),
                                        ),
                                      ),
                                      child: Text('Copy',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.medium(
                                              fontSize: 15.sp)),
                                    ),
                                  ),
                                ),
                                8.s,
                                Expanded(
                                  child: SizedBox(
                                    height: 46.h,
                                    child: ElevatedButton(
                                      onPressed: () => Share.share(
                                        'Join "${state.groupData?.groupName ?? "channel"}" on 212 Messenger:\n${state.groupData?.inviteLink ?? ''}',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryColor,
                                        foregroundColor: AppColors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(24.r),
                                        ),
                                      ),
                                      child: Text('Share',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.medium(
                                              fontSize: 15.sp)),
                                    ),
                                  ),
                                ),
                                8.s,
                                Expanded(
                                  child: SizedBox(
                                    height: 46.h,
                                    child: ElevatedButton(
                                      onPressed: () => _showQrDialog(context,
                                          state.groupData?.inviteLink ?? ''),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF930C17),
                                        foregroundColor: AppColors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(24.r),
                                          side: const BorderSide(
                                              color: Color(0xFFDF3340)),
                                        ),
                                      ),
                                      child: Text('QR Code',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.medium(
                                              fontSize: 15.sp)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  30.s,
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                    ),
                    child: Row(
                      children: [
                        if (state.groupData?.isAdmin ?? false)
                          Expanded(
                            child: CustomButton(
                                onPressed: () async {
                                  // if (state.selectedGroupPic == null &&
                                  //     (state.groupData?.groupImage ?? '')
                                  //         .isEmpty) {
                                  //   Utils.showSnackBar(context,
                                  //       AppConstants.pleaseSelectGroupImage);
                                  //   return;
                                  // }

                                  if (_groupFormKey.currentState!.validate()) {
                                    homeCubit.updateGroup(context,
                                        widget.groupId, ChatType.channel);
                                    // if ((state.groupData?.isAdmin ?? false)) {

                                    //         homeCubit.deleteGroup(context, widget.groupId);
                                    // } else {
                                    //            homeCubit.leaveGroup(context, widget.groupId);
                                    // }
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
                                if ((state.groupData?.isAdmin ?? false) &&
                                    (state.groupData?.isCreatedBy ?? false)) {
                                  showCommonAlertDialog(
                                    context: context,
                                    title: S.of(context).deleteChannel,
                                    subTitle:
                                        S.of(context).lblDeleteChannelSubTitle,
                                    submitBtnText: S.of(context).delete,
                                    onSubmit: () => homeCubit.deleteGroup(
                                        context, widget.groupId),
                                  );
                                } else {
                                  showCommonAlertDialog(
                                    context: context,
                                    title: S.of(context).leaveChannel,
                                    subTitle:
                                        S.of(context).lblLeaveChannelSubTitle,
                                    submitBtnText: S.of(context).yes,
                                    onSubmit: () => homeCubit.leaveGroup(
                                        context, widget.groupId),
                                  );
                                }
                              },
                              child: Text(
                                (state.groupData?.isAdmin ?? false) &&
                                        (state.groupData?.isCreatedBy ?? false)
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
                  ),
                  30.s,
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          S.of(context).subscribers,
                          style: AppTextStyles.medium(
                              fontSize: 18.sp, color: AppColors.purpleText),
                        ),
                        if ((state.groupData?.isAdmin ?? false))
                          GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                NavigationService()
                                    .navigateTo(AddMemberGroupScreen(
                                  title: S.of(context).addSubscribers,
                                  admins: state.groupData?.participants ?? [],
                                  isGroup: false,
                                  onSubmit: () => homeCubit.addMembersToGroup(
                                      context, widget.groupId),
                                ));
                              },
                              child: Text(
                                S.of(context).addSubscribers,
                                style: AppTextStyles.medium(
                                    fontSize: 18.sp,
                                    color: AppColors.purpleText),
                              ))
                      ],
                    ),
                  ),
                  // ...(state.groupData?.admins ?? []).map(
                  //   (admin) => membersTile(
                  //       context: context,
                  //       isAdmin: true,
                  //       currentUserIsAdmin: (state.groupData?.isAdmin ?? false),
                  //       participant: admin),
                  // ),
                  ...(state.groupData?.participants ?? []).map(
                    (participant) => membersTile(
                        context: context,
                        // isAdmin: participant.isAdmin??false,
                        groupId: widget.groupId,
                        currentUserIsAdmin: (state.groupData?.isAdmin ?? false),
                        participant: participant),
                  )
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget buildGroupPermission(
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

  Widget membersTile(
      {required BuildContext context,
      // required bool isAdmin,
      required bool currentUserIsAdmin,
      required String groupId,
      required Participant participant}) {
    // showMessage("membersTile=== ${participant.isCreator}");
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
                                : participant.name ?? "",
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.medium(
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                        4.s,
                        if (participant.isAdmin ?? false)
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
                    isAdmin: participant.isAdmin ?? false,
                    isGroup: false,
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
        false);
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
}
