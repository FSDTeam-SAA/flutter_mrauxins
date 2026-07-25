import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:two_one_two_messenger/cubit/chat_cubit.dart';
import 'package:two_one_two_messenger/cubit/chat_state.dart';
import 'package:two_one_two_messenger/cubit/typing_cubit.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/chat_message_model.dart';
import 'package:two_one_two_messenger/screens/chat/chat_screen_data.dart';
import 'package:two_one_two_messenger/screens/chat/pinned_messages_widget.dart';
import 'package:two_one_two_messenger/services/socket_service.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/chat_bubble.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';
import 'package:two_one_two_messenger/widgets/error_widget.dart';
import 'package:two_one_two_messenger/widgets/sent_media_widgets.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';
import 'package:two_one_two_messenger/widgets/typing_status_bubble.dart';

class ChatMessageList extends StatelessWidget {
  final ChatScreenData data;
  final Map<String, GlobalKey> messageKeys;
  final String? highlightedMessageId;
  final AutoScrollController scrollController;
  final Future<void> Function(
      MessageModel message, List<MessageModel> processedList) onHighlightMessage;
  final ValueChanged<List<MessageModel>> onMessageListChanged;
  final ValueChanged<int> onDisappearingMessagesTimeChanged;
  final VoidCallback onRefresh;

  const ChatMessageList({
    super.key,
    required this.data,
    required this.messageKeys,
    required this.highlightedMessageId,
    required this.scrollController,
    required this.onHighlightMessage,
    required this.onMessageListChanged,
    required this.onDisappearingMessagesTimeChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: BlocBuilder<ChatCubit, ChatState>(
        builder: (contextChat, state) {
          if (state.chatLoadingState == LoadingState.loading) {
            return Center(
              child: CustomLoadingWidget(),
            );
          } else if (state.chatLoadingState == LoadingState.success) {
            // chatList = state.chatList.reversed.toList();
            debugPrint("chat message build called");
            final chatList = List<MessageModel>.from(state.chatList ?? []);
            // messageList.clear();
            onMessageListChanged(List.from(chatList));
            final currentTypingusers =
                contextChat.watch<TypingCubit>().state.currentTypingusers;
            if (currentTypingusers.isNotEmpty) {
              if (chatList.isNotEmpty && chatList[0].type != "typing") {
                // showMessage("addMessages == ${chatList[0].type}");
                chatList.insert(
                    0,
                    MessageModel(
                      type: "typing",
                      sender: currentTypingusers.first.sender ??
                          Sender(
                              id: currentTypingusers.first.sender?.id ?? "",
                              profilePicture: currentTypingusers
                                      .first.sender?.profilePicture ??
                                  "",
                              userName: currentTypingusers
                                      .first.sender?.userName ??
                                  ""),
                    ));
              }
            }

            if (chatList.isEmpty) {
              return Center(
                child: data.chatType != ChatType.one_to_one &&
                        data.groupMessageString.isNotEmpty
                    ? Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: AppColors.darkInputFill,
                            borderRadius: BorderRadius.circular(47.r)),
                        child: Row(
                          children: [
                            SvgImage(
                              source: SvgAssets.icInfo,
                              color: AppColors.white,
                            ),
                            8.s,
                            Expanded(
                              child: Text(
                                data.groupMessageString,
                                // overflow: TextOver,
                                softWrap: true,
                                style: AppTextStyles.regular(
                                    color: AppColors.white
                                        .withValues(alpha: 85)),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.h, horizontal: 16.w),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.darkInputFill,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                WidgetSpan(
                                  child: Icon(Icons.lock,
                                      color: AppColors.darkTextColorHint,
                                      size: 16),
                                  alignment: PlaceholderAlignment
                                      .middle, // Align with text
                                ),
                                TextSpan(
                                  text:
                                      " ${S.of(context).messageEncryptionInfo}",
                                  style: AppTextStyles.regular(
                                          color: AppColors.darkTextColorHint)
                                      .copyWith(height: 1.5),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                        ),
                      ),
              );
            }

            // if (chatList.length < 2) {

            // } else {
            //   if (chatList[0].type != "encryption_info") {
            //     chatList.insert(
            //         0, MessageModel(type: "encryption_info"));
            //   }
            //   if (chatList[1].type != "disappearing_message") {
            //     chatList.insert(
            //         1, MessageModel(type: "disappearing_message"));
            //   }
            // }
            chatList.add(
              MessageModel(type: "encryption_info"),
            );
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PinnedMessagesWidget(
                  pinnedMessages: (state.chatMessageModel?.pinnedMessages ??
                              <dynamic>{})
                          .isEmpty
                      ? []
                      : List.from(
                          state.chatMessageModel!.pinnedMessages!.toList()),
                  onViewMessage: (message) {
                    // showMessage("Viewing pinned message ID: $id");
                    // scrollToMessage(id);
                    onHighlightMessage(message, chatList);
                  },
                  onUnpin: (id) {
                    showMessage("Unpinning message ID: $id");
                    // Remove from pinned list
                  },
                  currentUserId: data.userData!.sId!,
                ),
                Expanded(
                  child: GroupedListView<MessageModel, String>(
                    elements: chatList,
                    controller: scrollController,
                    reverse: true,
                    sort: false,
                    groupBy: (element) {
                      if (element.createdAt == null) return "";
                      return Utils.getFormattedDate(
                          (element.createdAt ?? DateTime.now())
                              .millisecondsSinceEpoch);
                    },
                    groupSeparatorBuilder: (String groupByValue) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.w),
                          child: Text(
                            groupByValue.isEmpty
                                ? ""
                                : Utils.getDateLabel(groupByValue),
                            style: AppTextStyles.regular(),
                          ),
                        ),
                      );
                    },
                    itemComparator: (a, b) => a.createdAt
                        .toString()
                        .toLowerCase()
                        .compareTo(b.createdAt.toString().toLowerCase()),
                    order: GroupedListOrder.DESC,
                    indexedItemBuilder: (context, element, index) {
                      Widget child;
                      if (chatList[index].type == "typing") {
                        child = TypingIndicatorBubble(
                          chatType: data.chatType,
                          profilePic:
                              chatList[index].sender?.profilePicture ?? "",
                        );
                      } else if (chatList[index].type == "encryption_info") {
                        child = Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 8.h, horizontal: 16.w),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.darkInputFill,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: Icon(Icons.lock,
                                        color: AppColors.darkTextColorHint,
                                        size: 16),
                                    alignment: PlaceholderAlignment
                                        .middle, // Align with text
                                  ),
                                  TextSpan(
                                    text:
                                        " ${S.of(context).messageEncryptionInfo}",
                                    style: AppTextStyles.regular(
                                            color: AppColors.darkTextColorHint)
                                        .copyWith(height: 1.5),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              softWrap: true,
                            ),
                          ),
                        );
                      } else if (chatList[index].type ==
                          "disappearing_messages") {
                        onDisappearingMessagesTimeChanged(
                            chatList[index].disAppearingMessages ?? 0);
                        child = GestureDetector(
                          onTap: () {
                            showDisappearingMessageTimerSheet(
                              context,
                              chatList[index].disAppearingMessages ?? 0,
                              (value) async {
                                String senderId = userDataCubit.state?.sId ??
                                    (await chatCubit.dbHelper.getLoginData())
                                        ?.sId ??
                                    "";

                                SocketService().sendEvent(
                                    AppConstants.updateMessageAutoDeleteTime, {
                                  "chatId": chatList[index].chatId ??
                                      data.currentChatId,
                                  "messageAutoDeleteTime": value,
                                  "messageId": DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                                  "userId": senderId
                                });
                              },
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.h, horizontal: 16.w),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.btnGrey, // Use a different color
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    WidgetSpan(
                                      child: Icon(Icons.timer,
                                          color: AppColors.white, size: 16),
                                      alignment: PlaceholderAlignment
                                          .middle, // Align with text
                                    ),
                                    TextSpan(
                                      text:
                                          " ${S.of(context).disappearingMessageInfo(chatList[index].sender?.name ?? "", Utils.getDisappearingMessageLabel(chatList[index].disAppearingMessages ?? 0))}",
                                      style: AppTextStyles.regular(
                                              color: AppColors.white)
                                          .copyWith(height: 1.5),
                                    ),
                                  ],
                                ),
                                softWrap: true,
                                textAlign: TextAlign.center,
                              ),

                              //  Row(
                              //   children: [
                              //     Icon(Icons.timer,
                              //         color: AppColors.white, size: 18),
                              //     SizedBox(width: 8),
                              //     Expanded(
                              //       child: Text(
                              //         S.of(context).disappearingMessageInfo(
                              //             "UserName", "7"),
                              //         softWrap: true,
                              //         style: AppTextStyles.regular(
                              //             color: AppColors.white),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                            ),
                          ),
                        );
                      } else if (chatList[index].type == "system_message") {
                        // String name = chatList[index]
                        //             .systemMessage
                        //             ?.userId ==
                        //         userData?.sId
                        //     ? S.current.you
                        //     : chatList[index].systemMessage?.name ??
                        //         "";
                        child = Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 8.h, horizontal: 16.w),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.btnGrey.withValues(
                                  alpha: 0.4), // Use a different color
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              chatList[index].systemMessage?.message ?? "",
                              style: AppTextStyles.regular(
                                      color: AppColors.white)
                                  .copyWith(height: 1.5),
                              softWrap: true,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      } else if (!(chatList[index].isSent ?? true)) {
                        // messageKeys[chatList[index].messageId!] =
                        //     chatList[index].key;
                        child = ChatBubble(
                            aesKey: data.aesKey,
                            isShowProfileImage: data.isShowProfileImage,
                            message: chatList[index],
                            isSender: chatList[index].sender?.id ==
                                data.userData?.sId,
                            index: index,
                            isAccessToMessageUtilities: (data.isSendMessage &&
                                !(state.chatMessageModel?.youBlocked ??
                                    false) &&
                                !((state.chatMessageModel?.removeFromChat ??
                                    false)) &&
                                !((state.chatMessageModel
                                        ?.otherUserRemoveFromChat ??
                                    false)) &&
                                !(state.chatMessageModel?.isBlocked ??
                                    false)),
                            onTapScroll: () {
                              if (chatList[index].replyTo != null) {
                                showMessage(
                                    "onTapScroll  ${chatList[index].replyTo!.messageId!}");
                                onHighlightMessage(
                                    chatList[index].replyTo!, chatList);
                              }
                            },
                            onSwipe: () {},
                            restrictContentSharing:
                                data.restrictContentSharing,
                            isGroup: data.chatType != ChatType.one_to_one,
                            mainContext: context);
                      } else {
                        messageKeys[chatList[index].messageId!] =
                            chatList[index].key;
                        child = Dismissible(
                          key: chatList[index].key,

                          direction: chatList[index].sender?.id ==
                                  data.userData?.sId
                              ? DismissDirection.endToStart
                              : DismissDirection
                                  .startToEnd, // Swipe Right to Reply
                          onUpdate: (details) {
                            // log("onUpdate ${details.progress}");
                            if (details.progress > 0.5) {
                              // If swipe progress is more than 50%, reset it
                            }
                          },
                          dismissThresholds: {
                            DismissDirection.endToStart: 0.5,
                            DismissDirection.startToEnd: 0.5,
                          },
                          resizeDuration: Duration.zero,
                          crossAxisEndOffset: 0.5,
                          confirmDismiss: (direction) async {
                            if ((data.isSendMessage &&
                                !(state.chatMessageModel?.youBlocked ??
                                    false) &&
                                !((state.chatMessageModel?.removeFromChat ??
                                    false)) &&
                                !((state.chatMessageModel
                                        ?.otherUserRemoveFromChat ??
                                    false)) &&
                                !(state.chatMessageModel?.isBlocked ??
                                    false))) {
                              // setState(() {
                              chatCubit.handleReplyMessage(chatList[index]);
                              // });
                            } // Trigger reply action
                            return false; // Prevent actual dismissal
                          },
                          child: AnimatedContainer(
                            duration: Duration(
                                milliseconds: 300), // 🔥 Smooth animation
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: highlightedMessageId ==
                                      chatList[index].messageId
                                  ? AppColors.primaryColor
                                      .withValues(alpha: 0.3)
                                  : Colors
                                      .transparent, // 🔥 Highlight effect
                            ),
                            child: ChatBubble(
                                aesKey: data.aesKey,
                                isShowProfileImage: data.isShowProfileImage,
                                message: chatList[index],
                                isSender: chatList[index].sender?.id ==
                                    data.userData?.sId,
                                index: index,
                                isAccessToMessageUtilities:
                                    (data.isSendMessage &&
                                        !(state.chatMessageModel
                                                ?.youBlocked ??
                                            false) &&
                                        !((state.chatMessageModel
                                                ?.removeFromChat ??
                                            false)) &&
                                        !((state.chatMessageModel
                                                ?.otherUserRemoveFromChat ??
                                            false)) &&
                                        !(state.chatMessageModel?.isBlocked ??
                                            false)),
                                onTapScroll: () {
                                  if (chatList[index].replyTo != null) {
                                    showMessage(
                                        "onTapScroll  ${chatList[index].replyTo!.messageId!}");
                                    onHighlightMessage(
                                        chatList[index].replyTo!, chatList);
                                  }
                                },
                                onSwipe: () {},
                                restrictContentSharing:
                                    data.restrictContentSharing,
                                isGroup: data.chatType != ChatType.one_to_one,
                                mainContext: context),
                          ),
                        );
                      }
                      return AutoScrollTag(
                        key: ValueKey(
                            'scroll-${chatList[index].messageId ?? index}'),
                        controller: scrollController,
                        index: index,
                        highlightColor:
                            AppColors.primaryColor.withValues(alpha: 0.3),
                        child: child,
                      );
                    },
                  ),

                  // ListView.builder(
                  //     controller: scrollController,
                  //     padding: EdgeInsets.only(bottom: 0.h),
                  //     reverse: true,
                  //     shrinkWrap: true,
                  //     itemCount: chatList.length,
                  //     itemBuilder: (con, index) {

                  //     }),
                ),
              ],
            );
          } else if (state.chatLoadingState == LoadingState.error) {
            return CustomErrorWidget(
              errorMessage: S.of(context).errorMessageForChatScreen,
              onRefresh: onRefresh,
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
