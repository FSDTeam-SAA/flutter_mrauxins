import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/cubit/group_cubit.dart';
import 'package:two_one_two_messenger/cubit/group_state.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';

import 'channel_info/channel_actions_row.dart';
import 'channel_info/channel_avatar_picker.dart';
import 'channel_info/channel_invite_section.dart';
import 'channel_info/channel_members_list.dart';
import 'channel_info/channel_permissions_section.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/keyboard_safe_scaffold.dart';
import '../widgets/appbar.dart';
import '../widgets/buttons.dart';
import '../widgets/svg_images.dart';
import '../widgets/text_fields.dart';

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

  @override
  void initState() {
    super.initState();
    onInit();
  }

  Future<void> onInit() async {
    groupCubit.getGroupInfobyId(context, widget.groupId);
// user??= await homeCubit.dbHelper.getLoginData();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardSafeScaffold(
      appBar: CommonAppBar(
        isBackShow: true,
        isActionsShow: false,
        title: S.of(context).lblChannelInfo,
      ),
      body: SafeArea(
        child:
            BlocBuilder<GroupCubit, GroupState>(builder: (contextProfile, state) {
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
                      groupCubit.getGroupInfobyId(context, widget.groupId);
                    },
                    child: Text(
                      S.of(context).refresh,
                      style: AppTextStyles.baseStyle(),
                    ))
              ],
            );
          }

          final isAdmin = state.groupData?.isAdmin ?? false;

          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h).copyWith(bottom: 0),
            child: Form(
              key: _groupFormKey,
              child: ListView(
                children: [
                  ChannelAvatarPicker(
                    selectedGroupPic: state.selectedGroupPic,
                    groupImage: state.groupData?.groupImage,
                    isAdmin: isAdmin,
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
                  ChannelPermissionsSection(
                    groupId: widget.groupId,
                    isAdmin: isAdmin,
                  ),
                  30.s,
                  ChannelInviteSection(
                    groupId: widget.groupId,
                    inviteLink: state.groupData?.inviteLink,
                    groupName: state.groupData?.groupName,
                    privateGroup: state.privateGroup,
                  ),
                  30.s,
                  ChannelActionsRow(
                    groupId: widget.groupId,
                    isAdmin: isAdmin,
                    isCreatedBy: state.groupData?.isCreatedBy ?? false,
                    formKey: _groupFormKey,
                  ),
                  30.s,
                  ChannelMembersList(
                    groupId: widget.groupId,
                    currentUser: widget.currentUser,
                    participants: state.groupData?.participants ?? [],
                    isAdmin: isAdmin,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
