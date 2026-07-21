import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/cubit/home_cubit.dart';
import 'package:two_one_two_messenger/cubit/home_state.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/screens/channel_info.dart';
import 'package:two_one_two_messenger/screens/chat/chat_dialogs.dart';
import 'package:two_one_two_messenger/screens/chat/chat_screen_data.dart';
import 'package:two_one_two_messenger/screens/group_info.dart';
import 'package:two_one_two_messenger/services/socket_service.dart';
import 'package:two_one_two_messenger/utils/app_dialoge.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/sent_media_widgets.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';

void showDraggableBottomSheet({
  required BuildContext context,
  required ChatScreenData data,
  required void Function(bool restrictContentSharing)
      onRestrictContentSharingChanged,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows full-screen dragging
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
    ),
    backgroundColor: AppColors.dialogBg,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16.0.w,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 16.0.w,
          ),
          child: BlocBuilder<HomeCubit, HomeState>(
              builder: (contextChat, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () async {
                    if (data.chatType != ChatType.one_to_one &&
                        data.userData != null) {
                      if (data.chatType == ChatType.group) {
                        Navigator.pop(context);
                        await NavigationService().navigateTo(GroupInfoScreen(
                          groupId: data.chatId,
                          currentUser: data.userData!,
                        ));
                        onRestrictContentSharingChanged(
                            homeCubit.state.restrictContentSharing);
                      } else if (data.chatType == ChatType.channel) {
                        Navigator.pop(context);
                        await NavigationService().navigateTo(ChannelInfoScreen(
                          groupId: data.chatId,
                          currentUser: data.userData!,
                        ));
                        onRestrictContentSharingChanged(
                            homeCubit.state.restrictContentSharing);
                      }
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      30.s,
                      Row(
                        children: [
                          SvgImage(
                            source: SvgAssets.icInfo,
                            color: AppColors.white,
                          ),
                          10.s,
                          Text(
                            data.chatType == ChatType.group
                                ? S.of(context).lblGroupInfo
                                : S.of(context).lblChannelInfo,
                            style: AppTextStyles.regular(
                              fontSize: 18.sp,
                            ),
                          )
                        ],
                      ),
                      30.s,
                      Container(
                        color: AppColors.darkAppBar, // Set divider color
                        height: 1, // Divider thickness
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () async {
                    await showClearChatDialog(
                        context: context, chatId: data.currentChatId);
                    Navigator.pop(context);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      30.s,
                      Row(
                        children: [
                          SvgImage(
                            source: SvgAssets.clearChat,
                            color: AppColors.white,
                          ),
                          10.s,
                          Text(
                            S.of(context).clearChat,
                            style: AppTextStyles.regular(
                              fontSize: 18.sp,
                            ),
                          )
                        ],
                      ),
                      30.s,
                      Container(
                        color: AppColors.darkAppBar, // Set divider color
                        height: 1, // Divider thickness
                      ),
                    ],
                  ),
                ),
                // if (!(state.groupData?.isCreatedBy ?? false) &&
                //     (state.groupLoadingState != LoadingState.loading))

                // for group dissapper
                if (data.chatType == ChatType.group)
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      // debugPrint(
                      //   "disAppearingMessagesTime<><>$disAppearingMessagesTime",
                      // );
                      Navigator.pop(context);
                      showDisappearingMessageTimerSheet(
                        context,
                        data.disAppearingMessagesTime,
                        (p0) async {
                          // ChatMessageModel
                          // debugPrint(chatCubit.state.createConversationModel.d)

                          String senderId = userDataCubit.state?.sId ??
                              (await chatCubit.dbHelper.getLoginData())
                                  ?.sId ??
                              "";
                          showMessage("updateMessageAutoDeleteTime call => ${{
                            "chatId": data.currentChatId,
                            "messageAutoDeleteTime": p0,
                            "messageId": DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            "userId": senderId
                          }}");

                          SocketService().sendEvent(
                              AppConstants.updateMessageAutoDeleteTime, {
                            "chatId": data.currentChatId,
                            "messageAutoDeleteTime": p0,
                            "messageId": DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            "userId": senderId
                          });

                          // homeCubit.updateChatDisAppear(index: index, timeValue: p0);
                        },
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        30.s,
                        Row(
                          children: [
                            Icon(Icons.timer,
                                color: AppColors.white, size: 24),
                            10.s,
                            Text(
                              S.of(context).disappearingMessage,
                              style: AppTextStyles.regular(
                                fontSize: 18.sp,
                              ),
                            )
                          ],
                        ),
                        30.s,
                        Container(
                          color: AppColors.darkAppBar, // Set divider color
                          height: 1, // Divider thickness
                        ),
                      ],
                    ),
                  ),

                if (data.chatType == ChatType.group)
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      Navigator.pop(context);
                      showCommonAlertDialog(
                        context: context,
                        title: data.chatType == ChatType.group
                            ? S.of(context).leaveGroup
                            : S.of(context).leaveChannel,
                        subTitle: data.chatType == ChatType.group
                            ? S.of(context).lblLeaveGroupSubTitle
                            : S.of(context).lblLeaveChannelSubTitle,
                        submitBtnText: S.of(context).yes,
                        onSubmit: () =>
                            homeCubit.leaveGroup(context, data.chatId),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        30.s,
                        Row(
                          children: [
                            SvgImage(
                              source: SvgAssets.deleteUser,
                              color: AppColors.white,
                            ),
                            10.s,
                            Text(
                              data.chatType == ChatType.group
                                  ? S.of(context).leaveGroup
                                  : S.of(context).leaveChannel,
                              style: AppTextStyles.regular(
                                fontSize: 18.sp,
                              ),
                            )
                          ],
                        ),
                        30.s,
                        Container(
                          color: AppColors.darkAppBar, // Set divider color
                          height: 1, // Divider thickness
                        ),
                      ],
                    ),
                  ),
                if ((state.groupData?.isCreatedBy ?? false) &&
                    (state.groupLoadingState != LoadingState.loading) &&
                    data.chatType == ChatType.channel)
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      Navigator.pop(context);
                      showCommonAlertDialog(
                        context: context,
                        title: data.chatType == ChatType.group
                            ? S.of(context).deleteGroup
                            : S.of(context).deleteChannel,
                        subTitle: data.chatType == ChatType.group
                            ? S.of(context).lblDeleteGroupSubTitle
                            : S.of(context).lblDeleteChannelSubTitle,
                        submitBtnText: S.of(context).delete,
                        onSubmit: () =>
                            homeCubit.deleteGroup(context, data.chatId),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        30.s,
                        Row(
                          children: [
                            SvgImage(
                              source: SvgAssets.icTrash,
                              color: AppColors.white,
                            ),
                            10.s,
                            Text(
                              data.chatType == ChatType.group
                                  ? S.of(context).deleteGroup
                                  : S.of(context).deleteChannel,
                              style: AppTextStyles.regular(
                                fontSize: 18.sp,
                              ),
                            )
                          ],
                        ),
                        30.s,
                      ],
                    ),
                  ),

                if ((state.groupData?.isCreatedBy ?? false) &&
                    (state.groupLoadingState != LoadingState.loading) &&
                    data.chatType == ChatType.group &&
                    ((state.groupData?.participants ?? []).isNotEmpty &&
                        (state.groupData?.participants ?? []).length == 1 &&
                        ((state.groupData?.participants ?? []).first.id ==
                            (data.userData?.sId ?? ""))))
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      Navigator.pop(context);
                      showCommonAlertDialog(
                        context: context,
                        title: data.chatType == ChatType.group
                            ? S.of(context).deleteGroup
                            : S.of(context).deleteChannel,
                        subTitle: data.chatType == ChatType.group
                            ? S.of(context).lblDeleteGroupSubTitle
                            : S.of(context).lblDeleteChannelSubTitle,
                        submitBtnText: S.of(context).delete,
                        onSubmit: () =>
                            homeCubit.deleteGroup(context, data.chatId),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        30.s,
                        Row(
                          children: [
                            SvgImage(
                              source: SvgAssets.icTrash,
                              color: AppColors.white,
                            ),
                            10.s,
                            Text(
                              data.chatType == ChatType.group
                                  ? S.of(context).deleteGroup
                                  : S.of(context).deleteChannel,
                              style: AppTextStyles.regular(
                                fontSize: 18.sp,
                              ),
                            )
                          ],
                        ),
                        30.s,
                      ],
                    ),
                  ),
              ],
            );
          }),
        ),
      );
    },
  );
}
