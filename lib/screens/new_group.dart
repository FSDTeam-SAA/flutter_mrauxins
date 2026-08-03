import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/cubit/group_cubit.dart';
import 'package:two_one_two_messenger/cubit/group_state.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/utils/image_picker.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/navigation.dart';
import '../utils/text_style.dart';
import '../widgets/appbar.dart';
import '../widgets/keyboard_safe_scaffold.dart';
import '../widgets/buttons.dart';
import '../widgets/svg_images.dart';
import '../widgets/text_fields.dart';
import 'add_member_group.dart';

class NewGroupScreen extends StatefulWidget {
  const NewGroupScreen({super.key, required this.isGroup});
  final bool isGroup;
  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  final _groupFormKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return KeyboardSafeScaffold(
      appBar: CommonAppBar(
        isBackShow: true,
        isActionsShow: false,
        title:
            widget.isGroup ? S.of(context).newGroup : S.of(context).newChannel,
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
            left: 32.w, right: 32.w, bottom: Platform.isIOS ? 32.h : 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<GroupCubit, GroupState>(
                builder: (contextNewGroup, state) {
              return CustomButton(
                  onPressed: () async {
                    // if (state.selectedGroupPic == null) {
                    //   Utils.showSnackBar(
                    //       context,
                    //       widget.isGroup
                    //           ? AppConstants.pleaseSelectGroupImage
                    //           : AppConstants.pleaseSelectChannelImage);
                    //   return;
                    // }

                    if (_groupFormKey.currentState!.validate()) {
                      NavigationService().navigateTo(AddMemberGroupScreen(
                        admins: [],
                        title: widget.isGroup
                            ? S.of(context).newGroup
                            : S.of(context).newChannel,
                        isGroup: widget.isGroup,
                        onSubmit: () => groupCubit.createGroup(context,
                            widget.isGroup ? ChatType.group : ChatType.channel),
                      ));
                    }
                  },
                  child: Text(
                    widget.isGroup
                        ? S.of(context).createGroupBtn
                        : S.of(context).createChannelBtn,
                    style: AppTextStyles.medium(
                      fontSize: 16.sp,
                      color: AppColors.white,
                    ),
                  ));
            }),
            SizedBox(
              height: 16.h,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child:
            BlocBuilder<GroupCubit, GroupState>(builder: (contextProfile, state) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Form(
              key: _groupFormKey,
              child: ListView(
                children: [
                  // Stack(
                  //   alignment: Alignment.center,
                  //   children: [
                  //     SizedBox(
                  //       height: 150.h,
                  //       child: Container(
                  //         width: 120.w,
                  //         height: 120.h,
                  //         decoration: BoxDecoration(
                  //           color: AppColors.darkAppBar,
                  //           shape: BoxShape.circle,
                  //           border: Border.all(
                  //               color: AppColors.darkAppBar,
                  //               width: 4.w),
                  //         ),
                  //         child: BlocBuilder<ProfilePickCubit, ProfilePickState>(
                  //             builder: (contextProfile, profileState) {
                  //           if (profileState is ProfilePickSuccess) {
                  //             return CircleAvatar(
                  //               radius: 60.r,
                  //               backgroundImage: FileImage(profileState.file),
                  //               // Use FileImage for circular display
                  //               backgroundColor: Colors
                  //                   .transparent, // Set background to transparent if needed
                  //             );
                  //             // return ClipOval(
                  //             //   child: Image.file(
                  //             //     profileState.file,
                  //             //     width: 100.w,
                  //             //     height: 100.h,
                  //             //     fit: BoxFit.contain,
                  //             //   ),
                  //             // );
                  //           }
                  //           /*else if (profileState is ProfilePickError) {
                  //                   return Icon(
                  //                     Icons.error,
                  //                     color: AppColors.redColor,
                  //                     size: 30.w,
                  //                   );
                  //                 } */
                  //           else {
                  //             /*return user?.profilePicture != null
                  //                     ? Center(
                  //                   child: SizedBox(
                  //                     height: 115.h,
                  //                     width: 115.w,
                  //                     child: AppNetworkImage(
                  //                       imageUrl:
                  //                       '${Urls.imageUrl}${user?.profilePicture}',
                  //                       fit: BoxFit.cover,
                  //                       borderRadius:
                  //                       BorderRadius.circular(100.r),
                  //                     ),
                  //                   ),
                  //                 )
                  //                     :*/
                  //             return Center(
                  //               child: SvgImage(
                  //                   source: SvgAssets.icNewGroup,
                  //                   width: 50.w,
                  //                   color: AppColors.white
                  //                       ),
                  //             );
                  //           }
                  //         }),
                  //       ),
                  //     ),
                  //     Positioned(
                  //       bottom: 0,
                  //       right: 0,
                  //       left: 0,
                  //       child: GestureDetector(
                  //         onTap: () {
                  //           context.read<ProfilePickCubit>().pickImage(context);
                  //         },
                  //         child: CircleAvatar(
                  //           radius: 15.r,
                  //           backgroundColor: AppColors.primaryColor,
                  //           child: SvgImage(
                  //             source: SvgAssets.icCamera,
                  //             width: 15.w,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
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
                              : Center(
                                  child: SvgImage(
                                    source: SvgAssets.icNewGroup,
                                    width: 50.w,
                                    color: AppColors.white,
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: GestureDetector(
                          onTap: () {
                            showCustomImageOptionPickerDialog(
                                context: context,
                                onImagePicked: groupCubit.selectGroupImage);
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
                  CustomTextField(
                    controller: state.groupNameController,
                    label: widget.isGroup
                        ? S.of(context).groupNamePlaceholder
                        : S.of(context).channelNamePlaceholder,
                    prefixIcon: SvgImage(
                      source: SvgAssets.icNewGroup,
                      fit: BoxFit.scaleDown,
                      color: AppColors.white,
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return widget.isGroup
                            ? S.of(context).groupNameError
                            : S.of(context).channelNameError;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    widget.isGroup
                        ? S.of(context).groupPermission
                        : S.of(context).channelPermission,
                    style: AppTextStyles.medium(
                      fontSize: 14.sp,
                      color: AppColors.purpleText,
                    ),
                  ),
                  16.s,
                  BlocBuilder<GroupCubit, GroupState>(builder: (context, state) {
                    return Column(
                      children: [
                        buildGroupPermission(
                          context,
                          text: widget.isGroup
                              ? 'Private Group'
                              : 'Private Channel',
                          defaultValue: state.privateGroup,
                          onChanged: (value) {
                            groupCubit.togglePrivateGroup(value);
                          },
                        ),
                        buildGroupPermission(
                          context,
                          text: S.of(context).lblShowProfilePhoto,
                          defaultValue: state.showProfilePhotoForGroup,
                          onChanged: (value) {
                            groupCubit.toggleShowProfilePhoto(value);
                          },
                        ),
                        buildGroupPermission(
                          context,
                          text: widget.isGroup
                              ? 'Show Group Display Image'
                              : 'Show Channel Display Image',
                          defaultValue: state.showGroupProfilePhoto,
                          onChanged: (value) {
                            groupCubit.toggleShowGroupProfilePhoto(value);
                          },
                        ),
                        if (widget.isGroup)
                          buildGroupPermission(
                            context,
                            text: S.of(context).allowMembersToSendMessage,
                            defaultValue: state.sendMessageForGroup,
                            onChanged: (value) {
                              groupCubit.toggleSendMessage(value);
                            },
                          ),
                        buildGroupPermission(
                          context,
                          text: widget.isGroup
                              ? 'Hide Members Info'
                              : 'Hide Subscribers Info',
                          defaultValue: state.hideMembersInfo,
                          onChanged: (value) {
                            groupCubit.toggleHideMembersInfo(value);
                          },
                        ),
                        buildGroupPermission(
                          context,
                          text: widget.isGroup
                              ? 'Hide New Members Message'
                              : 'Hide New Subscribers Message',
                          defaultValue: state.hideNewMembersMessage,
                          onChanged: (value) {
                            groupCubit.toggleHideNewMembersMessage(value);
                          },
                        ),
                        buildGroupPermission(
                          context,
                          text: 'Restrict Content Sharing',
                          defaultValue: state.restrictContentSharing,
                          onChanged: (value) {
                            groupCubit.toggleRestrictContentSharing(value);
                          },
                        ),
                      ],
                    );
                  }),
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
}
