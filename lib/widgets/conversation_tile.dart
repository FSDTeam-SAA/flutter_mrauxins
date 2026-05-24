import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/conversation_model.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/screens/chat_screen.dart';
import 'package:two_one_two_messenger/services/api_config.dart';
import 'package:two_one_two_messenger/services/socket_service.dart';
import 'package:two_one_two_messenger/utils/app_dialoge.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/alert_dialog.dart';
import 'package:two_one_two_messenger/widgets/network_image.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';

class ConversationTile extends StatelessWidget {
  ConversationTile({
    super.key,
    required this.isGroup,
    // required this.slidableController,
    required this.conversationData,
    required this.isArchive,
    this.participantDetails,
    required this.user,
  });
  final bool isGroup;
  final bool isArchive;
  final ConversationData conversationData;
  final ParticipantDetail? participantDetails;
  final UserData user;
  // final SlidableController slidableController;

  final socketService = SocketService();
  @override
  Widget build(BuildContext context) {
    // log("unreadMessageCount===>   $isGroup${conversationData.unreadMessageCount}");
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: isGroup
          ? Slidable(
              key: ValueKey(conversationData.id),

              startActionPane: ActionPane(
                // A motion is a widget used to control how the pane animates.
                motion: const ScrollMotion(),

                // A pane can dismiss the Slidable.
                dismissible: null,
                // All actions are defined in the children parameter.
                children: [
                  // A SlidableAction can have an icon and/or a label.
                  SlidableAction(
                    padding: EdgeInsets.zero,
                    onPressed: (context) {
                      showCommonDeleteDialog(
                        context: context,
                        subTitle: S.of(context).deleteChatSubtitle,
                        title: S.of(context).deleteThisChat,
                        onSubmit: () {
                          homeCubit.deleteChat(context, conversationData.id!);
                        },
                      );
                    },
                    backgroundColor: AppColors.redColor,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: S.of(context).delete,
                  ),
                  // pinUnpinSlidableAction(
                  //   context,
                  //   isPin: conversationData.isPinned ?? false,
                  //   onpinUnpin: (p0) => onpinUnpin(
                  //     chatId: conversationData.id ?? "",
                  //     userId: user.sId ?? "",
                  //     isPin: p0,
                  //   ),
                  // ),
                  // readUnreadSlidableAction(
                  //   context,
                  //   // isRead: conversationData.isRead ?? false,
                  //   isRead: (conversationData.unreadMessageCount ?? 0) == 0,
                  //   onClickReadUnRead: (p0) => onClickReadUnRead(
                  //     chatId: conversationData.id ?? "",
                  //     userId: user.sId ?? "",
                  //     // isPin: p0,
                  //   ),
                  // ),
                ],
              ),

              // The end action pane is the one at the right or the bottom side.
              endActionPane: ActionPane(
                motion: ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      log("ConversationTile==> $isArchive");
                      CustomAlertDialog(
                        context: context,
                        icon: Icon(
                          Icons.archive,
                          color: AppColors.white,
                        ),
                        title: isArchive
                            ? S.of(context).areYouSureToWantToUnArchiveThisChat
                            : S.of(context).areYouSureToWantToArchiveThisChat,
                        buttonText: S.current.yes,
                        onPressed: () {
                          if (isArchive) {
                            homeCubit.unArchiveChat(
                                user.sId ?? "", conversationData.id ?? "");
                          } else {
                            homeCubit.archiveChat(
                                user.sId ?? "", conversationData.id ?? "");
                          }
                        },
                      );
                    },
                    backgroundColor: AppColors.dialogBg,
                    foregroundColor: AppColors.white,
                    icon: Icons.archive,
                    label: isArchive
                        ? S.of(context).unArchive
                        : S.of(context).archive,
                  ),
                  // muteUnmuteSlidableAction(
                  //   context,
                  //   isMute: conversationData.isNotificationMute ?? false,
                  //   onMuteUnMute: (value) => onClickMuteUnMute(
                  //     chatId: conversationData.id ?? "",
                  //     userId: user.sId ?? "",
                  //     isMuted: value,
                  //   ),
                  // ),
                ],
              ),

              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onLongPress: () => onLongPressConversation(
                  context,
                  isGroup: isGroup,
                  isAddContact: false, // in group not to add contact option
                  isAlredyinFavorites: true,
                  isBlocked: true,
                  isLockChat: true,
                  isMute: conversationData.isNotificationMute ?? false,
                ),
                onTap: () async {
                  await chatCubit.resetChatScreenState();
                  NavigationService().navigateToChat(
                      chatId: conversationData.id ?? '',
                      ChatScreen(
                        chatType: conversationData.type ?? ChatType.group,
                        unreadMessageCount:
                            conversationData.unreadMessageCount ?? 0,
                        aesKey: conversationData.encryptedAESKey ?? "",
                        userName: conversationData.groupName ?? "",
                        userId: "",
                        createdBy: conversationData.createdBy,
                        userPic: conversationData.groupImage ?? "",
                        chatId: conversationData.id ?? '',
                        lastMessage: conversationData.lastMessage,
                        isSendMessage: conversationData.isSendMessage ?? true,
                        restrictContentSharing:
                            conversationData.restrictContentSharing ?? false,
                        isShowProfileImage:
                            conversationData.isProfilePhoto ?? true,
                      ));
                },
                child: Row(
                  children: [
                    Container(
                      height: 50.w,
                      width: 50.w,
                      decoration: BoxDecoration(
                        color: AppColors.darkInputFill,
                        shape: BoxShape.circle,
                      ),
                      child: ((conversationData.groupImage ?? "").isNotEmpty)
                          ? AppNetworkImage(
                              imageUrl:
                                  '${Urls.mediaUrl}${conversationData.groupImage ?? ""}' ??
                                      '',
                              borderRadius: BorderRadius.all(
                                Radius.circular(50.r),
                              ),
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: SvgImage(
                                source: isGroup
                                    ? (conversationData.type ==
                                            ChatType.channel)
                                        ? SvgAssets.megaphone
                                        : SvgAssets.person2
                                    : SvgAssets.icPerson,
                                color: AppColors.white,
                              ),
                            ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              conversationData.groupName ?? "",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: AppTextStyles.medium(fontSize: 16.sp),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              (conversationData.lastMessage?.content ?? "")
                                      .isNotEmpty
                                  ? (conversationData.lastMessage?.content ??
                                      "")
                                  : conversationData.lastMessage?.systemMessage
                                          ?.message ??
                                      "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.regular(fontSize: 12.sp),
                            ),
                          ]),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        (conversationData.unreadMessageCount ?? 0) == 0
                            ? SizedBox(
                                height: 22.w,
                                width: 22.w,
                              )
                            : Container(
                                height: 22.w,
                                width: 22.w,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primaryColor),
                                alignment: Alignment.center,
                                child: Text(
                                  "${conversationData.unreadMessageCount ?? 0}",
                                  style: AppTextStyles.medium(
                                      fontSize: 12.sp, color: AppColors.white),
                                ),
                              ),
                        SizedBox(height: 10.h),
                        if (conversationData.lastMessage?.createdAt != null)
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // _buildPinWidget(conversationData.isPinned),
                              // _buildMuteWidget(
                              //     conversationData.isNotificationMute),
                              // Visibility(
                              //   visible: conversationData.isPinned ?? false,
                              //   child: Padding(
                              //     padding: const EdgeInsets.only(right: 5),
                              //     child: Icon(
                              //       Icons.push_pin,
                              //       size: 18.h,
                              //       color: Colors.white,
                              //     ),
                              //   ),
                              // ),
                              if (conversationData.lastMessage?.createdAt !=
                                  null)
                                Text(
                                  (conversationData.lastMessage?.createdAt ??
                                          DateTime.now())
                                      .formatMessageTimestamp(),
                                  style: AppTextStyles.regular(
                                      fontSize: 12.sp,
                                      color: AppColors.white
                                          .withValues(alpha: 0.65)),
                                ),
                            ],
                          ),
                      ],
                    )
                  ],
                ),
              ),
            )
          : participantDetails == null
              ? SizedBox()
              : Slidable(
                  key: ValueKey(conversationData.id),

                  startActionPane: ActionPane(
                    // A motion is a widget used to control how the pane animates.
                    motion: const ScrollMotion(),

                    // A pane can dismiss the Slidable.
                    dismissible: null,
                    // All actions are defined in the children parameter.
                    children: [
                      // A SlidableAction can have an icon and/or a label.
                      SlidableAction(
                        padding: EdgeInsets.zero,
                        onPressed: (context) {
                          showCommonDeleteDialog(
                            context: context,
                            subTitle: S.of(context).deleteChatSubtitle,
                            title: S.of(context).deleteThisChat,
                            onSubmit: () {
                              homeCubit.deleteChat(
                                context,
                                conversationData.id!,
                              );
                            },
                          );
                        },
                        backgroundColor: AppColors.redColor,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: S.of(context).delete,
                      ),
                      // pinUnpinSlidableAction(
                      //   context,
                      //   isPin: conversationData.isPinned ?? false,
                      //   onpinUnpin: (p0) => onpinUnpin(
                      //     chatId: conversationData.id ?? "",
                      //     userId: user.sId ?? "",
                      //     isPin: p0,
                      //   ),
                      // ),
                      // readUnreadSlidableAction(
                      //   context,
                      //   // isRead: conversationData.isRead ?? false,
                      //   isRead: (conversationData.unreadMessageCount ?? 0) == 0,
                      //   onClickReadUnRead: (p0) => onClickReadUnRead(
                      //     chatId: conversationData.id ?? "",
                      //     userId: user.sId ?? "",
                      //     // isPin: p0,
                      //   ),
                      // ),

                      // readUnreadSlidableAction(
                      //   context,
                      //   isRead: false,
                      //   onSubmit: () {},
                      // )
                      // SlidableAction(
                      //   onPressed: (context) {
                      //     // showCommonDeleteDialog(
                      //     //   context: context,
                      //     //   subTitle: S.of(context).deleteChatSubtitle,
                      //     //   title: S.of(context).deleteThisChat,
                      //     //   onSubmit: () {
                      //     //     homeCubit.deleteChat(
                      //     //         context, conversationData.id!);
                      //     //   },
                      //     // );
                      //   },
                      //   backgroundColor: AppColors.greenColor,
                      //   foregroundColor: Colors.white,
                      //   icon: Icons.push_pin_outlined,
                      //   label: S.of(context).pin,
                      // ),
                    ],
                  ),

                  // The end action pane is the one at the right or the bottom side.
                  endActionPane: ActionPane(
                    motion: ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          log("ConversationTile==> $isArchive");
                          CustomAlertDialog(
                            context: context,
                            icon: Icon(
                              Icons.archive,
                              color: AppColors.white,
                            ),
                            title: isArchive
                                ? S
                                    .of(context)
                                    .areYouSureToWantToUnArchiveThisChat
                                : S
                                    .of(context)
                                    .areYouSureToWantToArchiveThisChat,
                            buttonText: S.current.yes,
                            onPressed: () {
                              if (isArchive) {
                                homeCubit.unArchiveChat(
                                    user.sId ?? "", conversationData.id ?? "");
                              } else {
                                homeCubit.archiveChat(
                                    user.sId ?? "", conversationData.id ?? "");
                              }
                            },
                          );
                        },
                        backgroundColor: AppColors.dialogBg,
                        foregroundColor: AppColors.white,
                        icon: Icons.archive,
                        label: isArchive
                            ? S.of(context).unArchive
                            : S.of(context).archive,
                      ),
                      // muteUnmuteSlidableAction(
                      //   context,
                      //   isMute: conversationData.isNotificationMute ?? false,
                      //   onMuteUnMute: (value) => onClickMuteUnMute(
                      //     chatId: conversationData.id ?? "",
                      //     userId: user.sId ?? "",
                      //     isMuted: value,
                      //   ),
                      // ),
                    ],
                  ),

                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onLongPress: () => onLongPressConversation(
                      context,
                      isGroup: isGroup,
                      isAddContact: true,
                      isAlredyinFavorites: true,
                      isBlocked: true,
                      isLockChat: true,
                      isMute: conversationData.isNotificationMute ?? false,
                    ),
                    // onLongPress: () {
                    //   CustomAlertDialog(
                    //     context: context,
                    //     icon: Icon(
                    //       Icons.archive,
                    //       color: AppColors.white,
                    //     ),
                    //     title: isArchive
                    //         ? S.of(context).areYouSureToWantToUnArchiveThisChat
                    //         : S.of(context).areYouSureToWantToArchiveThisChat,
                    //     buttonText: S.current.yes,
                    //     onPressed: () {
                    //       if (isArchive) {
                    //         homeCubit.unArchiveChat(
                    //             user.sId ?? "", conversationData.id ?? "");
                    //       } else {
                    //         homeCubit.archiveChat(
                    //             user.sId ?? "", conversationData.id ?? "");
                    //       }
                    //     },
                    //   );
                    // },
                    onTap: () async {
                      // debugPrint(
                      //     "lastMessahge=== ${state.conversationModel?.data?[index].lastMessage?.toJson()}");
                      await chatCubit.resetChatScreenState();
                      NavigationService().navigateToChat(
                          chatId: conversationData.id ?? '',
                          ChatScreen(
                            chatType:
                                conversationData.type ?? ChatType.one_to_one,
                            unreadMessageCount:
                                conversationData.unreadMessageCount ?? 0,
                            aesKey: conversationData.encryptedAESKey ?? "",
                            sender: participantDetails,
                            userName: participantDetails?.name ?? "",
                            userId: participantDetails?.id ?? "",
                            userPic: participantDetails?.profilePicture ?? "",
                            chatId: conversationData.id ?? '',
                            lastMessage: conversationData.lastMessage,
                            isSendMessage:
                                conversationData.isSendMessage ?? true,
                            restrictContentSharing:
                                conversationData.restrictContentSharing ??
                                    false,
                            isShowProfileImage:
                                conversationData.isProfilePhoto ?? true,
                            // isDeletedUser: true,
                          ));
                    },
                    child: Row(
                      children: [
                        Container(
                          height: 50.w,
                          width: 50.w,
                          decoration: BoxDecoration(
                            color: AppColors.darkInputFill,
                            shape: BoxShape.circle,
                          ),
                          child: (participantDetails?.profilePicture != null)
                              ? AppNetworkImage(
                                  imageUrl:
                                      '${Urls.mediaUrl}${participantDetails?.profilePicture}' ??
                                          '',
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(50.r),
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: SvgImage(
                                    source: SvgAssets.icPerson,
                                    color: AppColors.white,
                                  ),
                                ),
                        ),
                        SizedBox(width: 15.w),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  // participantDetails?.nickName ??
                                  //     participantDetails?.name ??
                                  //     '',
                                  AppMethods.getNickNameForParticipateDetails(
                                      participantDetails),
                                  // (participantDetails?.isActiveNickname ??
                                  //         false)
                                  //     ? (participantDetails?.nickName ??
                                  //         participantDetails?.name ??
                                  //         "")
                                  //     : (participantDetails?.name ?? ""),

                                  // participantDetails?.name ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: AppTextStyles.medium(fontSize: 16.sp),
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  conversationData.lastMessage?.content ??
                                      conversationData.lastMessage
                                          ?.systemMessage?.message ??
                                      "",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.regular(fontSize: 12.sp),
                                ),
                              ]),
                        ),
                        4.w.s,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            (conversationData.unreadMessageCount ?? 0) == 0
                                ? SizedBox(
                                    height: 22.w,
                                    width: 22.w,
                                  )
                                : Container(
                                    height: 22.w,
                                    width: 22.w,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primaryColor),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "${conversationData.unreadMessageCount ?? 0}",
                                      style: AppTextStyles.medium(
                                          fontSize: 12.sp,
                                          color: AppColors.white),
                                    ),
                                  ),
                            SizedBox(height: 10.h),
                            Row(
                              children: [
                                // _buildPinWidget(conversationData.isPinned),
                                // _buildMuteWidget(
                                //     conversationData.isNotificationMute),
                                if (conversationData.lastMessage?.createdAt !=
                                    null)
                                  Text(
                                    (conversationData.lastMessage?.createdAt ??
                                            DateTime.now())
                                        .formatMessageTimestamp(),
                                    style: AppTextStyles.regular(
                                      fontSize: 12.sp,
                                      color: AppColors.white
                                          .withValues(alpha: 0.65),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
    );
  }

  SlidableAction muteUnmuteSlidableAction(
    BuildContext context, {
    required bool isMute,
    required void Function(bool) onMuteUnMute,
  }) {
    return SlidableAction(
      padding: EdgeInsets.all(0),
      onPressed: (context) => onMuteUnMute.call(!isMute),
      backgroundColor: Colors.amber,
      foregroundColor: Colors.white,
      icon: isMute ? Icons.volume_up : Icons.volume_off,
      label: isMute ? S.of(context).unmute : S.of(context).mute,
    );
  }

  void onClickMuteUnMute({
    required String userId,
    required String chatId,
    required bool isMuted,
  }) {
    final Map<String, dynamic> data = {
      'userId': userId,
      'chatId': chatId,
      'isMuted': isMuted
    };

    socketService.emitpinUnpinConversation(data);
  }

  SlidableAction pinUnpinSlidableAction(
    BuildContext context, {
    required bool isPin,
    required void Function(bool) onpinUnpin,
  }) {
    return SlidableAction(
      padding: EdgeInsets.all(0),
      onPressed: (context) => onpinUnpin.call(!isPin),
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      icon: Icons.push_pin,
      label: isPin ? S.of(context).unPin : S.of(context).pin,
    );
  }

  void onpinUnpin({
    required String userId,
    required String chatId,
    required bool isPin,
  }) {
    final Map<String, dynamic> data = {
      'userId': userId,
      'chatId': chatId,
      'isPin': isPin
    };

    socketService.emitpinUnpinConversation(data);
  }

  SlidableAction readUnreadSlidableAction(
    BuildContext context, {
    required bool isRead,
    required void Function(bool) onClickReadUnRead,
  }) {
    return SlidableAction(
      padding: EdgeInsets.all(0),
      onPressed: (context) => onClickReadUnRead.call(!isRead),
      backgroundColor: Colors.grey,
      foregroundColor: Colors.white,
      icon: Icons.chat_outlined,
      label: isRead ? S.of(context).unread : S.of(context).read,
    );
  }

  void onClickReadUnRead({
    required String userId,
    required String chatId,
    // required bool isPin,
  }) {
    final Map<String, dynamic> data = {
      'userId': userId,
      'chatId': chatId,
      // 'isPin': isPin
    };

    socketService.emitMarkMessageAsUnread(data);
  }

  Widget _buildPinWidget(bool? isPin) {
    return Visibility(
      visible: isPin ?? false,
      child: Padding(
        padding: const EdgeInsets.only(right: 5),
        child: Icon(
          Icons.push_pin,
          size: 18.h,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildMuteWidget(bool? isMute) {
    return Visibility(
      visible: isMute ?? false,
      child: Padding(
        padding: const EdgeInsets.only(right: 5),
        child: Icon(
          Icons.push_pin,
          size: 18.h,
          color: Colors.white,
        ),
      ),
    );
  }

  void onLongPressConversation(
    BuildContext context, {
    required bool isGroup,
    required bool isAddContact,
    required bool isMute,
    required bool isLockChat,
    required bool isAlredyinFavorites,
    required bool isBlocked,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.scaffoldBgDark,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Wrap(
              children: [
                if (!isGroup && isAddContact)
                  BottomSheetTile(
                    title: "Add to contacts",
                    icon: Icons.person_add,
                    onTap: () => Navigator.pop(context),
                  ),
                BottomSheetTile(
                  title: isMute ? "UnMute" : "Mute",
                  icon: isMute ? Icons.volume_up : Icons.volume_off,
                  onTap: () {},
                ),
                BottomSheetTile(
                  icon: isLockChat ? Icons.lock : Icons.lock_open,
                  title: isLockChat ? "UnLock chat" : "Lock chat",
                  onTap: () {},
                ),
                BottomSheetTile(
                  icon: Icons.clear_rounded,
                  title: "Clear chat",
                  onTap: () {},
                ),
                BottomSheetTile(
                  icon: Icons.favorite_border_outlined,
                  title: isAlredyinFavorites
                      ? "Remove from Favourites"
                      : "Add to Favourites",
                  onTap: () {},
                ),
                BottomSheetTile(
                  icon: Icons.group_add,
                  title: "Add to list",
                  onTap: () {},
                ),
                BottomSheetTile(
                  icon: Icons.block,
                  title: isBlocked ? "UnBlock" : "Block",
                  color: Colors.red,
                  onTap: () {},
                ),
                BottomSheetTile(
                  icon: Icons.delete_forever,
                  title: "Delete Chat",
                  color: Colors.red,
                  onTap: () {},
                ),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Close",
                      style: AppTextStyles.medium(color: AppColors.buttonColor),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class BottomSheetTile extends StatelessWidget {
  final String title;
  final void Function()? onTap;
  final IconData? icon;
  final Color? color;
  final bool isShowDivider;
  const BottomSheetTile({
    super.key,
    required this.title,
    this.onTap,
    this.icon,
    this.color,
    this.isShowDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          splashColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
          title: Text(
            title,
            style: AppTextStyles.regular(
              fontSize: 16.sp,
              color: color ?? AppColors.white,
            ),
          ),
          trailing: Icon(
            icon ?? Icons.person_add_alt_1_outlined,
            color: color ?? Colors.white,
          ),
          onTap: onTap,
        ),
        Visibility(
          visible: isShowDivider,
          child: Divider(
            color: AppColors.dividerColor,
            height: 0,
          ),
        )
      ],
    );
  }
}
