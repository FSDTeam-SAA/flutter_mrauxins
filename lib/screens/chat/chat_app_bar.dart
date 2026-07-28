import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/cubit/chat_cubit.dart';
import 'package:two_one_two_messenger/cubit/chat_state.dart';
import 'package:two_one_two_messenger/cubit/home_cubit.dart';
import 'package:two_one_two_messenger/cubit/home_state.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/date_format.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/screens/chat/chat_bottom_sheets.dart';
import 'package:two_one_two_messenger/screens/chat/chat_dialogs.dart';
import 'package:two_one_two_messenger/screens/chat/chat_screen_data.dart';
import 'package:two_one_two_messenger/screens/groupCall.dart';
import 'package:two_one_two_messenger/screens/report_user_screen.dart';
import 'package:two_one_two_messenger/screens/user_profile.dart';
import 'package:two_one_two_messenger/screens/voice_call_page.dart';
import 'package:two_one_two_messenger/services/socket_service.dart';
import 'package:two_one_two_messenger/utils/app_dialoge.dart';
import 'package:two_one_two_messenger/utils/app_pop_up.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/avatar_widgets.dart';
import 'package:two_one_two_messenger/widgets/sent_media_widgets.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';

class ChatAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ChatScreenData data;
  final void Function(bool newStatus) onNickNameStatusChanged;
  final void Function({required String? newNickName, required bool? newStatus})
      onNickNameChanged;
  final void Function(bool restrictContentSharing)
      onRestrictContentSharingChanged;

  const ChatAppBar({
    super.key,
    required this.data,
    required this.onNickNameStatusChanged,
    required this.onNickNameChanged,
    required this.onRestrictContentSharingChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  State<ChatAppBar> createState() => _ChatAppBarState();
}

class _ChatAppBarState extends State<ChatAppBar> {
  final GlobalKey _actionButtonKey = GlobalKey();

  Offset? _getButtonOffset() {
    RenderBox? renderBox =
        _actionButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      return renderBox.localToGlobal(Offset.zero) + Offset(0, 50.h);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    return AppBar(
      backgroundColor: AppColors.dark,
      leading: IconButton(
        onPressed: () async {
          context
              .read<ChatCubit>()
              .changeChatPageStatus('', false, data.userData?.sId ?? "");
          await NavigationService().goBack();
        },
        icon: SvgImage(
            source: SvgAssets.icArrowBack,
            width: 20.w,
            color: AppColors.white),
      ),
      titleSpacing: 0.w,
      title: Row(
        children: [
          GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (data.chatType == ChatType.one_to_one &&
                    data.sender != null &&
                    data.sender?.isOnline != null) {
                  NavigationService().navigateTo(
                    UserProfileScreen(
                      user: UserData.fromJson(
                        data.sender!.toJson(),
                      ),
                      onNickNameStatusChangge: (newStatus) {
                        widget.onNickNameStatusChanged(newStatus);
                      },
                      onNickNameChange: (
                          {required newNickName, required newStatus}) {
                        widget.onNickNameChanged(
                            newNickName: newNickName, newStatus: newStatus);
                      },
                    ),
                  );
                }
              },
              child: BlocBuilder<HomeCubit, HomeState>(
                  builder: (contextChat, state) {
                final hideGroupPhoto = (data.chatType == ChatType.channel ||
                        data.chatType == ChatType.group) &&
                    !(state.groupData?.isGroupProfilePhoto ?? true);
                return AvatarWidgets(
                  userPic: hideGroupPhoto
                      ? ''
                      : (data.chatType == ChatType.channel ||
                              data.chatType == ChatType.group)
                          ? (state.groupData?.groupImage ?? data.userPic)
                          : data.userPic,
                  svgAvatar: (data.chatType == ChatType.channel)
                      ? SvgAssets.megaphone
                      : (data.chatType == ChatType.group)
                          ? SvgAssets.person2
                          : SvgAssets.icPerson,
                );
              })),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<HomeCubit, HomeState>(
                    builder: (contextChat, state) {
                  return Text(
                    (data.chatType == ChatType.channel ||
                            data.chatType == ChatType.group)
                        ? (state.groupData?.groupName ?? data.userName)
                        : ((data.sender?.isActiveNickname ?? false)
                            ? (data.sender?.nickName ?? data.userName)
                            : data.sender?.name ?? data.userName),
                    style: AppTextStyles.medium(fontSize: 16.sp),
                  );
                }),
                SizedBox(
                  height: 5,
                ),
                BlocBuilder<ChatCubit, ChatState>(
                    builder: (contextChat, state) {
                  if (data.chatType == ChatType.one_to_one) {
                    return Text(
                      (state.chatMessageModel?.isOnline ?? false)
                          ? S.of(context).online
                          : state.chatMessageModel?.lastSeen != null
                              ? "${S.of(context).sLastSeen} ${state.chatMessageModel?.lastSeen?.formatTimeAgo}"
                              : "",
                      style: AppTextStyles.regular(
                          fontSize: 10.sp,
                          color: AppColors.white.withValues(alpha: 0.5)),
                    );
                  }
                  return BlocBuilder<HomeCubit, HomeState>(
                      builder: (contextChat, state) {
                    if (state.groupData?.participants == null) {
                      return SizedBox();
                    }
                    final int count = state.groupData?.participantCount ??
                        state.groupData?.participants?.length ??
                        0;
                    return Text(
                      (data.chatType == ChatType.group)
                          ? S.of(context).noOfMember(count)
                          : S.of(context).noOfSubscriber(count),
                      // "",
                      style: AppTextStyles.regular(
                          fontSize: 10.sp,
                          color: AppColors.white.withValues(alpha: 0.5)),
                    );
                  });
                }),
              ],
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        // Adjust height of the divider
        child: Container(
          color: AppColors.darkAppBar, // Set divider color
          height: 1, // Divider thickness
        ),
      ),
      actions: [
        if (data.chatType != ChatType.channel)
          BlocBuilder<HomeCubit, HomeState>(builder: (contextHome, homeState) {
            final bool isGroup = data.chatType == ChatType.group;
            final int memberCount =
                homeState.groupData?.participants?.length ?? 0;

            // If it's a group and only one member is there, disable calls
            final bool isCallDisabled = isGroup && memberCount <= 1;

            return BlocBuilder<ChatCubit, ChatState>(
                builder: (contextChat, state) {
              if (!(data.isSendMessage) ||
                  (data.isDeletedUser) ||
                  (state.chatMessageModel?.youBlocked ?? false) ||
                  (state.chatMessageModel?.removeFromChat ?? false) ||
                  (state.chatMessageModel?.otherUserRemoveFromChat ??
                      false) ||
                  (state.chatMessageModel?.isBlocked ?? false) ||
                  isCallDisabled) {
                return SizedBox();
              }
              return GestureDetector(
                onTap: () {
                  if ((data.chatType == ChatType.one_to_one)) {
                    NavigationService().navigateTo(CallingPage(
                      callType: CallType.video,
                      currentConversationId: data.chatId.isEmpty
                          ? (chatCubit.state.currentConversationId ??
                              data.currentChatId ??
                              "")
                          : data.chatId,
                      image: data.userPic ?? "",
                      receiverId: data.userId,
                      // name: data.userName ?? '',
                      name: AppMethods.getNickNameForParticipateDetails(
                          data.sender),
                      isActive: false,
                      from: "chatPage",
                    ));
                  } else {
                    // if((homeCubit.state.groupData?.participants??[]).length<=1){
                    // Utils.showSnackBar(context, S.of(context).);
                    // }

                    NavigationService().navigateTo(GroupCallingPage(
                      callType: CallType.video_group_call,
                      currentConversationId: data.chatId.isEmpty
                          ? (chatCubit.state.currentConversationId ??
                              data.currentChatId ??
                              "")
                          : data.chatId,
                      image: data.userPic ?? "",
                      receiverId: data.userId,
                      name: data.userName ?? '',
                      isActive: false,
                      from: "chatPage",
                    ));
                  }
                },
                behavior: HitTestBehavior.translucent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SvgImage(
                    source: SvgAssets.icVideo,
                    width: 20.w,
                    height: 20.w,
                    color: AppColors.white,
                  ),
                ),
              );
            });
          }),
        if (data.chatType != ChatType.channel)
          BlocBuilder<HomeCubit, HomeState>(builder: (contextHome, homeState) {
            final bool isGroup = data.chatType == ChatType.group;
            final int memberCount =
                homeState.groupData?.participants?.length ?? 0;

            // If it's a group and only one member is there, disable calls
            final bool isCallDisabled = isGroup && memberCount <= 1;

            return BlocBuilder<ChatCubit, ChatState>(
                builder: (contextChat, state) {
              if (!(data.isSendMessage) ||
                  (data.isDeletedUser) ||
                  (state.chatMessageModel?.youBlocked ?? false) ||
                  (state.chatMessageModel?.removeFromChat ?? false) ||
                  (state.chatMessageModel?.otherUserRemoveFromChat ??
                      false) ||
                  (state.chatMessageModel?.isBlocked ?? false) ||
                  isCallDisabled) {
                return SizedBox();
              }
              return GestureDetector(
                onTap: () {
                  if ((data.chatType == ChatType.one_to_one)) {
                    NavigationService().navigateTo(CallingPage(
                      callType: CallType.voice,
                      currentConversationId: data.chatId.isEmpty
                          ? (chatCubit.state.currentConversationId ??
                              data.currentChatId ??
                              "")
                          : data.chatId,
                      image: data.userPic ?? "",
                      // name: data.userName ?? '',
                      name: AppMethods.getNickNameForParticipateDetails(
                          data.sender),
                      receiverId: data.userId,
                      isActive: false,
                      from: "chatPage",
                    ));
                  } else {
                    NavigationService().navigateTo(GroupCallingPage(
                      callType: CallType.voice_group_call,
                      currentConversationId: data.chatId.isEmpty
                          ? (chatCubit.state.currentConversationId ??
                              data.currentChatId ??
                              "")
                          : data.chatId,
                      image: data.userPic ?? "",
                      name: data.userName ?? '',
                      receiverId: data.userId,
                      isActive: false,
                      from: "chatPage",
                    ));
                  }
                },
                behavior: HitTestBehavior.translucent,
                child: Padding(
                  padding: const EdgeInsets.only(right: 0.0, left: 8),
                  child: SvgImage(
                    source: SvgAssets.icPhone,
                    width: 18.w,
                    height: 18.h,
                    color: AppColors.white,
                  ),
                ),
              );
            });
          }),
        BlocBuilder<ChatCubit, ChatState>(builder: (contextChat, state) {
          // if ((state.chatMessageModel?.isBlocked ?? false)) {
          //   return SizedBox();
          // }
          if ((state.chatMessageModel?.removeFromChat ?? false) ||
              (state.chatMessageModel?.otherUserRemoveFromChat ?? false)) {
            return PopupMenuButton<MessageOption>(
              color: AppColors.dialogBg,
              icon: SvgImage(
                  source: SvgAssets.icMoreDots,
                  width: 18.w,
                  color: AppColors.white),
              onSelected: (value) {
                showClearChatDialog(
                    context: context, chatId: data.currentChatId);
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<MessageOption>>[
                PopupMenuItem<MessageOption>(
                  value: MessageOption.clearChat,
                  child: Text(
                    S.of(context).clearChat,
                    style: AppTextStyles.regular(color: AppColors.white),
                  ),
                ),
              ],
            );
          }
          return IconButton(
            key: _actionButtonKey,
            onPressed: () {
              if ((data.chatType != ChatType.one_to_one)) {
                if ((state.chatMessageModel?.removeFromChat ?? false) ||
                    (state.chatMessageModel?.otherUserRemoveFromChat ??
                        false)) {
                  return;
                }
                showDraggableBottomSheet(
                  context: context,
                  data: data,
                  onRestrictContentSharingChanged:
                      widget.onRestrictContentSharingChanged,
                );
              } else {
                List<ChatOption> chatOption = [
                  ChatOption(
                    value: "viewContact",
                    name: S.of(context).viewContact,
                    icon: SvgImage(
                      source: SvgAssets.icPerson,
                      color: AppColors.white,
                    ),
                    onTap: () {
                      if (data.chatType == ChatType.one_to_one &&
                          data.sender != null &&
                          data.sender?.isOnline != null) {
                        NavigationService().navigateTo(UserProfileScreen(
                          user: UserData.fromJson(data.sender!.toJson()),
                        ));
                      }
                    },
                  ),
                  if (!((state.chatMessageModel?.youBlocked ?? false) ||
                      (state.chatMessageModel?.isBlocked ?? false)))
                    ChatOption(
                      value: "disapperingMessages",
                      name: S.of(context).disappearingMessage,
                      icon:
                          Icon(Icons.timer, color: AppColors.white, size: 24),
                      onTap: () {
                        showDisappearingMessageTimerSheet(
                          context,
                          data.disAppearingMessagesTime,
                          (value) async {
                            String senderId = userDataCubit.state?.sId ??
                                (await chatCubit.dbHelper.getLoginData())
                                    ?.sId ??
                                "";
                            showMessage(
                                "updateMessageAutoDeleteTime call => ${{
                              "chatId": data.currentChatId,
                              "messageAutoDeleteTime": value,
                              "messageId": DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              "userId": senderId
                            }}");
                            SocketService().sendEvent(
                                AppConstants.updateMessageAutoDeleteTime, {
                              "chatId": data.currentChatId,
                              "messageAutoDeleteTime": value,
                              "messageId": DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              "userId": senderId
                            });
                          },
                        );
                      },
                    ),
                  if (!data.isDeletedUser)
                    ChatOption(
                      value: "reportUser",
                      name: S.of(context).reportUser,
                      icon:
                          Icon(Icons.report, color: AppColors.white, size: 24),
                      onTap: () {
                        NavigationService().navigateTo(ReportUserPage(
                          onReport: (reason, description) async {
                            showMessage(
                                "Report User $reason   $description");

                            await homeCubit.reportUser(
                                userId: data.userId,
                                userName: data.userName,
                                reason: reason,
                                description: description,
                                context: context);
                          },
                        ));
                      },
                    ),
                  if (!data.isDeletedUser)
                    ChatOption(
                      value: "blockedUser",
                      name: (state.chatMessageModel?.youBlocked ?? false)
                          ? S.of(context).unBlockUser
                          : S.of(context).blockUser,
                      icon: Icon(
                          (state.chatMessageModel?.youBlocked ?? false)
                              ? Icons.person_off
                              : Icons.block,
                          color: AppColors.white,
                          size: 24),
                      onTap: () {
                        if ((state.chatMessageModel?.youBlocked ?? false)) {
                          showCommonBlockUserDialog(
                              context: context,
                              icon: Icons.person_off,
                              onSubmit: () {
                                homeCubit.unBlockedUser(
                                  userId: data.userId,
                                  context: context,
                                  callback: () async {
                                    chatCubit.handleUnblockUser(false);
                                    Utils.showSnackBar(
                                        context,
                                        S
                                            .of(context)
                                            .unblockUserSuccessfully(
                                                data.userName ?? ""));
                                  },
                                );
                              },
                              title: S.of(context).unblockUserTitle,
                              subTitle: S
                                  .of(context)
                                  .unblockUserSubtitle(data.userName));
                        } else {
                          showCommonBlockUserDialog(
                              context: context,
                              onSubmit: () {
                                homeCubit.blockedUser(
                                  chatId: data.currentChatId ??
                                      chatCubit.state.currentConversationId ??
                                      data.chatId,
                                  userId: data.userId,
                                  context: context,
                                  callback: () async {
                                    chatCubit.handleUnblockUser(true);
                                    Utils.showSnackBar(
                                        context,
                                        S
                                            .of(context)
                                            .blockUserSuccessfully(
                                                data.userName ?? ""));
                                  },
                                );
                              },
                              title: S.of(context).blockUserTitle,
                              subTitle: S.of(context).blockUserSubtitle(
                                  data.userName ??
                                      S.of(context).blockedContacts));
                        }
                      },
                    ),
                  ChatOption(
                    value: "clearChat",
                    name: S.of(context).clearChat,
                    icon: SvgImage(
                      source: SvgAssets.clearChat,
                      color: AppColors.white,
                    ),
                    onTap: () {
                      showClearChatDialog(
                          context: context, chatId: data.currentChatId);
                    },
                  ),
                ];

                chatOptionpopUpMenu(
                  context: context,
                  options: chatOption,
                  offset: _getButtonOffset() ?? Offset(0, 80),
                );
              }
            },
            icon: SvgImage(
              source: SvgAssets.icMoreDots,
              width: 18.w,
              height: 18.h,
              color: AppColors.white,
            ),
          );
        })
      ],
    );
  }
}
