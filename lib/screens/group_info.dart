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

import 'group_info/group_avatar_picker.dart';
import 'group_info/group_info_tab.dart';
import 'group_info/group_invite_section.dart';
import 'group_info/group_members_section.dart';
import 'group_info/group_settings_section.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/appbar.dart';
import '../widgets/buttons.dart';
import '../widgets/svg_images.dart';
import '../widgets/text_fields.dart';

class GroupInfoScreen extends StatefulWidget {
  const GroupInfoScreen(
      {super.key, required this.groupId, required this.currentUser});
  final String groupId;
  final UserData currentUser;
  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

enum _GroupInfoSection { settings, invite }

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  final _groupFormKey = GlobalKey<FormState>();
  _GroupInfoSection? _expandedSection;
  GroupInfoTab _selectedTab = GroupInfoTab.members;

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
    return Scaffold(
      appBar: CommonAppBar(
        isBackShow: true,
        isActionsShow: false,
        title: S.of(context).lblGroupInfo,
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
                    child:
                        Text(S.of(context).somethingWentWrongPleaseTryAgain)),
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
          final participants = state.groupData?.participants ?? [];
          final admins = state.groupData?.admins ?? [];
          final isAdmin = state.groupData?.isAdmin ?? false;

          return Padding(
            padding: EdgeInsets.only(top: 20.h),
            child: Form(
              key: _groupFormKey,
              child: ListView(
                padding: EdgeInsets.only(bottom: 24.h),
                children: [
                  GroupAvatarPicker(
                    groupId: widget.groupId,
                    formKey: _groupFormKey,
                    selectedGroupPic: state.selectedGroupPic,
                    groupImage: state.groupData?.groupImage,
                    isGroupProfilePhoto:
                        state.groupData?.isGroupProfilePhoto ?? true,
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
                      onChanged: (_) {
                        if (isAdmin &&
                            (_groupFormKey.currentState?.validate() ?? false)) {
                          groupCubit.updateGroupSetting(
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
                  GroupSettingsSection(
                    groupId: widget.groupId,
                    isAdmin: isAdmin,
                    expanded: _expandedSection == _GroupInfoSection.settings,
                    onToggleExpanded: () {
                      setState(() {
                        _expandedSection =
                            _expandedSection == _GroupInfoSection.settings
                                ? null
                                : _GroupInfoSection.settings;
                      });
                    },
                  ),
                  12.s,
                  GroupInviteSection(
                    groupId: widget.groupId,
                    inviteLink: state.groupData?.inviteLink,
                    groupName: state.groupData?.groupName,
                    privateGroup: state.privateGroup,
                    expanded: _expandedSection == _GroupInfoSection.invite,
                    onToggleExpanded: () {
                      setState(() {
                        _expandedSection =
                            _expandedSection == _GroupInfoSection.invite
                                ? null
                                : _GroupInfoSection.invite;
                      });
                    },
                  ),
                  GroupMembersSection(
                    groupId: widget.groupId,
                    currentUser: widget.currentUser,
                    participants: participants,
                    admins: admins,
                    isAdmin: isAdmin,
                    selectedTab: _selectedTab,
                    onTabSelected: (tab) {
                      setState(() => _selectedTab = tab);
                    },
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
