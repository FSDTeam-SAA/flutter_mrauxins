import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:two_one_two_messenger/cubit/chat_cubit.dart';
import 'package:two_one_two_messenger/cubit/chat_state.dart';
import 'package:two_one_two_messenger/cubit/user_data_cubit.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/models/saved_messages.dart';
import 'package:two_one_two_messenger/services/socket_service.dart';
import 'package:two_one_two_messenger/utils/app_pop_up.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/buttons.dart';
import 'package:two_one_two_messenger/widgets/chat_bubble.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';
import 'package:two_one_two_messenger/widgets/error_widget.dart';
import 'package:two_one_two_messenger/widgets/sent_media_widgets.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';

class SavedMessages extends StatefulWidget {
  const SavedMessages({super.key});

  @override
  State<SavedMessages> createState() => _SavedMessagesState();
}

class _SavedMessagesState extends State<SavedMessages> {
  List<SavedMessage> chatList = [];
  TextEditingController messageCon = TextEditingController();
  final scrollController = ScrollController();
  UserData? userData;
  final SocketService _socketService = SocketService();
  @override
  void initState() {
    super.initState();
    // _chatStreamController = StreamController<List<ChatData>>.broadcast();
    userData = context.read<UserDataCubit>().state;

    init();
  }

  Future<void> init() async {
    // _focusNode.addListener(_handleFocusChange);
    userData ??= await chatCubit.dbHelper.getLoginData();
    scrollController.addListener(_onScroll);
    _socketService.onSavedMessage(
      (message) {
        showMessage("updateSavedMessageList==>outer===>${message}");
        if (message["messageId"] != null && message["message"] != null) {
          chatCubit.updateSavedMessageList(message);
        }
      },
    );
    _socketService.onEditSavedMessage(
      (message) {
        showMessage("onEditSavedMessage>> Data::::$message");
        if (message["messageId"] != null) {
          chatCubit.onEditSaveMessage(message);
        }
      },
    );
    _socketService.onReactSavedMessageEvent(
      (message) {
        showMessage("onReactSavedMessageEvent>> Data::::$message");
        if (message["messageId"] != null) {
          chatCubit.onReactSavedMessage(message);
        }
      },
    );

    _socketService.onPinnedSavedMessage((data) {
      showMessage(
          ":: onPinnedMessage==> $data ${mounted && chatCubit.chatId == data["pinMessage"]}");
      chatCubit.onPinnedSavedMessage(
          messageId: data["pinMessage"]["messageId"]);
    });
    _socketService.onUnPinnedSavedMessage((data) {
      showMessage(":: onUnPinnedMessage==> $data  ");
      chatCubit.onUnPinnedSavedMessage(
          messageId: data["pinMessage"]["messageId"]);
    });
    //   _socketService.onPinnedMessage((data) {
    //   showMessage(
    //       ":: onPinnedMessage==> $data ${widget.userId} ${mounted && chatCubit.chatId == data["chatId"]}");
    //   chatCubit.onPinnedMessage(
    //       chatId: data["chatId"], messageId: data["pinMessage"]["messageId"]);
    // });
    // _socketService.onUnPinnedMessage((data) {
    //   showMessage(
    //       ":: onUnPinnedMessage==> $data ${widget.userId} ${mounted && chatCubit.chatId == data["chatId"]}");
    //   if (mounted && chatCubit.chatId == data["chatId"]) {
    //     chatCubit.onUnPinnedMessage(
    //         chatId: data["chatId"], messageId: data["pinMessage"]["messageId"]);
    //   }
    // });
    await fetchSavedMessages();
  }

  Future<void> fetchSavedMessages() async {
    chatCubit.getSaveMessages(context, isLoadMore: false, searchQuery: "");
  }

  Future<void> _onScroll() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      await chatCubit.getSaveMessages(context,
          isLoadMore: true, searchQuery: searchController.text.trim());
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    messageCon.dispose();

    super.dispose();
  }

  Map<String, GlobalKey> messageKeys = {};
  String? highlightedMessageId;
  // MessageModel? replyingToMessage;
  void scrollToMessage(String messageId) {
    if (messageKeys.containsKey(messageId)) {
      GlobalKey? key = messageKeys[messageId];

      if (key != null && key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        showMessage(
            "scrollToMessage: Message is not built yet, scrolling manually.");

        int index = chatList.indexWhere((msg) => msg.messageId == messageId);
        if (index != -1) {
          scrollController.animateTo(
            (index * 100.0), // Approximate item height
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }

      // Trigger a highlight animation
      setState(() {
        highlightedMessageId = messageId;
      });

      // Remove highlight after some time
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          highlightedMessageId = null;
        });
      });
    }
  }

  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        leading: IconButton(
          onPressed: () async {
            await NavigationService().goBack();
          },
          icon: SvgImage(
              source: SvgAssets.icArrowBack,
              width: 20.w,
              color: AppColors.white),
        ),
        titleSpacing: 0.w,
        title: BlocBuilder<ChatCubit, ChatState>(builder: (context, state) {
          return state.isSearchSavedMessages
              ? TextFormField(
                  controller: searchController,
                  onChanged: (query) {
                    chatCubit.onSearchSavedMessages(context, query);
                  },
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: S.of(context).sSearchContacts,
                    border: InputBorder.none,
                    filled: false,
                  ),
                )
              : Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).sSavedMessages,
                          style: AppTextStyles.medium(fontSize: 16.sp),
                        ),
                      ],
                    ),
                  ],
                );
        }),

        // Row(
        //   children: [

        //     Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //        Text(
        //            AppConstants.sSavedMessages,
        //           style: AppTextStyles.medium(fontSize: 16.sp),
        //         ),

        //       ],
        //     ),
        //   ],
        // ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          // Adjust height of the divider
          child: Container(
            color: AppColors.darkAppBar, // Set divider color
            height: 1, // Divider thickness
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              chatCubit.handleSearchSavedMessage(
                context,
                () => searchController.clear(),
              );
            },
            behavior: HitTestBehavior.translucent,
            child: BlocBuilder<ChatCubit, ChatState>(builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: state.isSearchSavedMessages
                    ? Icon(
                        Icons.close,
                        size: 20.w,
                        color: AppColors.white,
                      )
                    : SvgImage(
                        source: SvgAssets.icSearch,
                        width: 20.w,
                        height: 20.w,
                        color: AppColors.white,
                      ),
              );
            }),
          ),

          buildOptionMenu(
            context: context,
            onSelected: (item) {
              handleClick(item.index, context);
            },
          ),
          // IconButton(
          //   icon: SvgImage(
          //     source: SvgAssets.icMoreDots,
          //     width: 18.w,
          //     height: 18.h,
          //     color: AppColors.white,
          //   ),
          //   onPressed: () => buildOptionMenu(),
          // )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (contextChat, state) {
                  if (state.savedMessageLoadingState == LoadingState.loading) {
                    return Center(
                      child: CustomLoadingWidget(),
                    );
                  } else if (state.savedMessageLoadingState ==
                      LoadingState.success) {
                    // chatList = state.chatList.reversed.toList();
                    chatList = state.savedMessagesData?.savedMessages ?? [];

                    return chatList.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 16.w),
                                padding: EdgeInsets.symmetric(
                                        vertical: 16.h, horizontal: 16.w)
                                    .copyWith(top: 40, bottom: 24),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40.r),
                                  color: AppColors.secondaryBgColor,
                                ),
                                child: Column(
                                  spacing: 24.h,
                                  children: [
                                    // 24.s,
                                    SvgImage(
                                      source: SvgAssets.cloudStorage,
                                      height: 72,
                                      width: 72,
                                    ),
                                    // 24.s,
                                    Text(
                                      S.of(context).yourCloudStorage,
                                      style: AppTextStyles.semiBold(
                                          fontSize: 22.sp,
                                          color: AppColors.white),
                                    ),
                                    // 24.s,
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 7,
                                          backgroundColor: AppColors.white,
                                        ),
                                        8.s,
                                        Expanded(
                                          child: Text(
                                            S
                                                .of(context)
                                                .forwardMessageHereToSaveThem,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.regular(
                                                color: AppColors.white
                                                    .withValues(alpha: 0.8)),
                                          ),
                                        ),
                                      ],
                                    ),
// 24.s,
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 7,
                                          backgroundColor: AppColors.white,
                                        ),
                                        8.s,
                                        Text(
                                          S
                                              .of(context)
                                              .sendMediaAndFilesToStoreThem,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.regular(
                                              color: AppColors.white
                                                  .withValues(alpha: 0.8)),
                                        ),
                                      ],
                                    ),
                                    // 24.s,
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 7,
                                          backgroundColor: AppColors.white,
                                        ),
                                        8.s,
                                        Expanded(
                                          child: Text(
                                            S
                                                .of(context)
                                                .accessThisCharFromAnyDevice,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.regular(
                                                color: AppColors.white
                                                    .withValues(alpha: 0.8)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // 24.s,
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 7,
                                          backgroundColor: AppColors.white,
                                        ),
                                        8.s,
                                        Expanded(
                                          child: Text(
                                            S
                                                .of(context)
                                                .useSearchToQuicklyFindThings,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.regular(
                                                color: AppColors.white
                                                    .withValues(alpha: 0.8)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // 8.s,
                                  ],
                                ),
                              ),
                            ],
                          )

                        // Center(
                        //     child: Text(
                        //       "",
                        //       style: AppTextStyles.medium(fontSize: 20.sp),
                        //     ),
                        //   )
                        : Column(
                            children: [
                              PinnedMessagesWidget(
                                currentUserId: userData?.sId ?? "",
                                pinnedMessages: List.from(state
                                        .savedMessagesData
                                        ?.pinnedSavedMessages ??
                                    []),
                                onViewMessage: (id) {
                                  showMessage(
                                      "Viewing pinned message ID:${(state.savedMessagesData?.pinnedSavedMessages ?? [])} $id");
                                  scrollToMessage(id);
                                },
                                onUnpin: (id) {
                                  showMessage("Unpinning message ID: $id");
                                  // Remove from pinned list
                                },
                              ),
                              Expanded(
                                child: GroupedListView<SavedMessage, String>(
                                  elements: chatList,
                                  reverse: true,
                                  sort: false,
                                  groupBy: (element) {
                                    if (element.messageDetails?.createdAt ==
                                        null) return "";
                                    return Utils.getFormattedDate(
                                        (element.messageDetails?.createdAt ??
                                                DateTime.now())
                                            .millisecondsSinceEpoch);
                                  },
                                  groupSeparatorBuilder: (String groupByValue) {
                                    return Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10.w),
                                        child: Text(
                                          groupByValue.isEmpty
                                              ? ""
                                              : Utils.getDateLabel(
                                                  groupByValue),
                                          style: AppTextStyles.regular(),
                                        ),
                                      ),
                                    );
                                  },
                                  itemComparator: (a, b) => a
                                      .messageDetails!.createdAt
                                      .toString()
                                      .toLowerCase()
                                      .compareTo(b.messageDetails!.createdAt
                                          .toString()
                                          .toLowerCase()),
                                  order: GroupedListOrder.DESC,
                                  indexedItemBuilder:
                                      (context, element, index) {
                                    if (index == chatList.length - 1 &&
                                        state.savedMessageLoadingMore) {
                                      return Column(
                                        children: [
                                          CustomLoadingWidget(),
                                          chatList[index].messageDetails == null
                                              ? SizedBox()
                                              :
                                              // Dismissible(
                                              //     key: chatList[index]
                                              //         .messageDetails!
                                              //         .key,

                                              // direction: chatList[index]
                                              //             .senderDetails
                                              //             ?.id ==
                                              //         userData?.sId
                                              //     ? DismissDirection
                                              //         .endToStart
                                              //     : DismissDirection
                                              //         .startToEnd, // Swipe Right to Reply
                                              // onUpdate: (details) {
                                              //   log("onUpdate ${details.progress}");
                                              //   if (details.progress >
                                              //       0.5) {
                                              //     // If swipe progress is more than 50%, reset it
                                              //   }
                                              // },
                                              // dismissThresholds: {
                                              //   DismissDirection
                                              //       .endToStart: 0.5,
                                              //   DismissDirection
                                              //       .startToEnd: 0.5,
                                              // },
                                              // resizeDuration:
                                              //     Duration.zero,
                                              // crossAxisEndOffset: 0.5,
                                              // confirmDismiss:
                                              //     (direction) async {
                                              //   setState(() {
                                              //     chatCubit
                                              //         .handleReplySavedMessage(
                                              //             chatList[
                                              //                 index]);
                                              //   }); // Trigger reply action
                                              //   return false; // Prevent actual dismissal
                                              // },
                                              // child:
                                              AnimatedContainer(
                                                  key: chatList[index]
                                                      .messageDetails!
                                                      .key,
                                                  duration: Duration(
                                                      milliseconds:
                                                          300), // 🔥 Smooth animation
                                                  curve: Curves.easeInOut,
                                                  decoration: BoxDecoration(
                                                    color: highlightedMessageId ==
                                                            chatList[index]
                                                                .messageId
                                                        ? AppColors.primaryColor
                                                            .withOpacity(0.3)
                                                        : Colors
                                                            .transparent, // 🔥 Highlight effect
                                                  ),
                                                  child:
                                                      ChatBubbleForSavedMessage(
                                                          onTapScroll: () {
                                                            if (chatList[index]
                                                                    .messageDetails
                                                                    ?.replyTo !=
                                                                null) {
                                                              showMessage(
                                                                  "onTapScroll  ${chatList[index].messageDetails!.replyTo!.messageId!}");
                                                              scrollToMessage(chatList[
                                                                      index]
                                                                  .messageDetails!
                                                                  .replyTo!
                                                                  .messageId!);
                                                            }
                                                          },
                                                          message:
                                                              chatList[index],
                                                          isSender: chatList[
                                                                      index]
                                                                  .senderDetails
                                                                  ?.id ==
                                                              userData?.sId,
                                                          index: index,
                                                          isGroup: true,
                                                          currentUserId:
                                                              userData?.sId ??
                                                                  "",
                                                          mainContext: context),
                                                ),
                                          // ),
                                        ],
                                      );
                                    }
                                    if (chatList[index].messageDetails !=
                                        null) {
                                      messageKeys[
                                              chatList[index].messageId ?? ""] =
                                          chatList[index].messageDetails!.key;
                                    }

                                    return chatList[index].messageDetails ==
                                            null
                                        ? SizedBox()
                                        :
                                        //  Dismissible(
                                        //     key: chatList[index]
                                        //         .messageDetails!
                                        //         .key,

                                        //     direction: chatList[index]
                                        //                 .senderDetails
                                        //                 ?.id ==
                                        //             userData?.sId
                                        //         ? DismissDirection.endToStart
                                        //         : DismissDirection
                                        //             .startToEnd, // Swipe Right to Reply
                                        //     onUpdate: (details) {
                                        //       log("onUpdate ${details.progress}");
                                        //       if (details.progress > 0.5) {
                                        //         // If swipe progress is more than 50%, reset it
                                        //       }
                                        //     },
                                        //     dismissThresholds: {
                                        //       DismissDirection.endToStart:
                                        //           0.5,
                                        //       DismissDirection.startToEnd:
                                        //           0.5,
                                        //     },
                                        //     resizeDuration: Duration.zero,
                                        //     crossAxisEndOffset: 0.5,
                                        //     confirmDismiss:
                                        //         (direction) async {
                                        //       setState(() {
                                        //         chatCubit
                                        //             .handleReplySavedMessage(
                                        //                 chatList[index]);
                                        //       }); // Trigger reply action
                                        //       return false; // Prevent actual dismissal
                                        //     },
                                        //     child:
                                        AnimatedContainer(
                                            duration: Duration(
                                                milliseconds:
                                                    300), // 🔥 Smooth animation
                                            curve: Curves.easeInOut,
                                            decoration: BoxDecoration(
                                              color: highlightedMessageId ==
                                                      chatList[index].messageId
                                                  ? AppColors.primaryColor
                                                      .withOpacity(0.3)
                                                  : Colors
                                                      .transparent, // 🔥 Highlight effect
                                            ),
                                            child: ChatBubbleForSavedMessage(
                                                onTapScroll: () {
                                                  // if (chatList[index]
                                                  //         .replyTo !=
                                                  //     null) {
                                                  //   showMessage(
                                                  //       "onTapScroll  ${chatList[index].replyTo!.messageId!}");
                                                  //   scrollToMessage(
                                                  //       chatList[index]
                                                  //           .replyTo!
                                                  //           .messageId!);
                                                  // }
                                                },
                                                message: chatList[index],
                                                isSender: chatList[index]
                                                        .senderDetails
                                                        ?.id ==
                                                    userData?.sId,
                                                index: index,
                                                currentUserId:
                                                    userData?.sId ?? "",
                                                // isFromSavedMessage: true,
                                                isGroup: true,
                                                mainContext: context),
                                            // ),
                                          );
                                  }, // optional
                                ),
                                // ListView.builder(
                                //     controller: scrollController,
                                //     padding: EdgeInsets.only(bottom: 0.h),
                                //     reverse: true,
                                //     shrinkWrap: true,
                                //     itemCount: chatList.length,
                                //     itemBuilder: (con, index) {
                                //       if (index == chatList.length - 1 &&
                                //           state.savedMessageLoadingMore) {
                                //         return Column(
                                //           children: [
                                //             CustomLoadingWidget(),
                                //             chatList[index].messageDetails ==
                                //                     null
                                //                 ? SizedBox()
                                //                 :
                                //                 // Dismissible(
                                //                 //     key: chatList[index]
                                //                 //         .messageDetails!
                                //                 //         .key,

                                //                 // direction: chatList[index]
                                //                 //             .senderDetails
                                //                 //             ?.id ==
                                //                 //         userData?.sId
                                //                 //     ? DismissDirection
                                //                 //         .endToStart
                                //                 //     : DismissDirection
                                //                 //         .startToEnd, // Swipe Right to Reply
                                //                 // onUpdate: (details) {
                                //                 //   log("onUpdate ${details.progress}");
                                //                 //   if (details.progress >
                                //                 //       0.5) {
                                //                 //     // If swipe progress is more than 50%, reset it
                                //                 //   }
                                //                 // },
                                //                 // dismissThresholds: {
                                //                 //   DismissDirection
                                //                 //       .endToStart: 0.5,
                                //                 //   DismissDirection
                                //                 //       .startToEnd: 0.5,
                                //                 // },
                                //                 // resizeDuration:
                                //                 //     Duration.zero,
                                //                 // crossAxisEndOffset: 0.5,
                                //                 // confirmDismiss:
                                //                 //     (direction) async {
                                //                 //   setState(() {
                                //                 //     chatCubit
                                //                 //         .handleReplySavedMessage(
                                //                 //             chatList[
                                //                 //                 index]);
                                //                 //   }); // Trigger reply action
                                //                 //   return false; // Prevent actual dismissal
                                //                 // },
                                //                 // child:
                                //                 AnimatedContainer(
                                //                     duration: Duration(
                                //                         milliseconds:
                                //                             300), // 🔥 Smooth animation
                                //                     curve: Curves.easeInOut,
                                //                     decoration: BoxDecoration(
                                //                       color: highlightedMessageId ==
                                //                               chatList[index]
                                //                                   .messageId
                                //                           ? AppColors
                                //                               .primaryColor
                                //                               .withOpacity(0.3)
                                //                           : Colors
                                //                               .transparent, // 🔥 Highlight effect
                                //                     ),
                                //                     child:
                                //                         ChatBubbleForSavedMessage(
                                //                             onTapScroll: () {
                                //                               // if (chatList[index]
                                //                               //         .replyTo !=
                                //                               //     null) {
                                //                               //   showMessage(
                                //                               //       "onTapScroll  ${chatList[index].replyTo!.messageId!}");
                                //                               //   scrollToMessage(
                                //                               //       chatList[index]
                                //                               //           .replyTo!
                                //                               //           .messageId!);
                                //                               // }
                                //                             },
                                //                             message:
                                //                                 chatList[index],
                                //                             isSender: chatList[
                                //                                         index]
                                //                                     .senderDetails
                                //                                     ?.id ==
                                //                                 userData?.sId,
                                //                             index: index,
                                //                             isGroup: true,
                                //                             currentUserId:
                                //                                 userData?.sId ??
                                //                                     "",
                                //                             mainContext:
                                //                                 context),
                                //                   ),
                                //             // ),
                                //           ],
                                //         );
                                //       }
                                //       return chatList[index].messageDetails ==
                                //               null
                                //           ? SizedBox()
                                //           :
                                //           //  Dismissible(
                                //           //     key: chatList[index]
                                //           //         .messageDetails!
                                //           //         .key,

                                //           //     direction: chatList[index]
                                //           //                 .senderDetails
                                //           //                 ?.id ==
                                //           //             userData?.sId
                                //           //         ? DismissDirection.endToStart
                                //           //         : DismissDirection
                                //           //             .startToEnd, // Swipe Right to Reply
                                //           //     onUpdate: (details) {
                                //           //       log("onUpdate ${details.progress}");
                                //           //       if (details.progress > 0.5) {
                                //           //         // If swipe progress is more than 50%, reset it
                                //           //       }
                                //           //     },
                                //           //     dismissThresholds: {
                                //           //       DismissDirection.endToStart:
                                //           //           0.5,
                                //           //       DismissDirection.startToEnd:
                                //           //           0.5,
                                //           //     },
                                //           //     resizeDuration: Duration.zero,
                                //           //     crossAxisEndOffset: 0.5,
                                //           //     confirmDismiss:
                                //           //         (direction) async {
                                //           //       setState(() {
                                //           //         chatCubit
                                //           //             .handleReplySavedMessage(
                                //           //                 chatList[index]);
                                //           //       }); // Trigger reply action
                                //           //       return false; // Prevent actual dismissal
                                //           //     },
                                //           //     child:
                                //           AnimatedContainer(
                                //               duration: Duration(
                                //                   milliseconds:
                                //                       300), // 🔥 Smooth animation
                                //               curve: Curves.easeInOut,
                                //               decoration: BoxDecoration(
                                //                 color: highlightedMessageId ==
                                //                         chatList[index]
                                //                             .messageId
                                //                     ? AppColors.primaryColor
                                //                         .withOpacity(0.3)
                                //                     : Colors
                                //                         .transparent, // 🔥 Highlight effect
                                //               ),
                                //               child: ChatBubbleForSavedMessage(
                                //                   onTapScroll: () {
                                //                     // if (chatList[index]
                                //                     //         .replyTo !=
                                //                     //     null) {
                                //                     //   showMessage(
                                //                     //       "onTapScroll  ${chatList[index].replyTo!.messageId!}");
                                //                     //   scrollToMessage(
                                //                     //       chatList[index]
                                //                     //           .replyTo!
                                //                     //           .messageId!);
                                //                     // }
                                //                   },
                                //                   message: chatList[index],
                                //                   isSender: chatList[index]
                                //                           .senderDetails
                                //                           ?.id ==
                                //                       userData?.sId,
                                //                   index: index,
                                //                   currentUserId:
                                //                       userData?.sId ?? "",
                                //                   // isFromSavedMessage: true,
                                //                   isGroup: true,
                                //                   mainContext: context),
                                //               // ),
                                //             );
                                //     }),
                              ),
                            ],
                          );
                  } else if (state.savedMessageLoadingState ==
                      LoadingState.error) {
                    return CustomErrorWidget(
                      errorMessage: S.of(context).errorMessageForChatScreen,
                      onRefresh: () {
                        fetchSavedMessages();
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageCon,
                    style: AppTextStyles.medium(
                      fontSize: 16.sp,
                      color: AppColors.white,
                    ).copyWith(
                      decoration: TextDecoration.none,
                    ),
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,

                    // focusNode: _focusNode,
                    maxLines: 5,
                    expands: false,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: S.of(context).typeMessage,
                      hintStyle: AppTextStyles.regular(
                        fontSize: 14.sp,
                      ),
                      filled: true,
                      fillColor: AppColors.darkInputFill,
                      suffixIcon: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 15.w, vertical: 10.h),
                        child: BlocBuilder<ChatCubit, ChatState>(
                          builder: (context, state) {
                            return InkWell(
                                onTap: () {
                                  buildBottomSheet(
                                      aesKey: "",
                                      chatId: "",
                                      context: context,
                                      replyMessage: null,
                                      isFromSavedMessage: true);
                                },
                                child:
                                    SvgPicture.asset(SvgAssets.icAddRounded));
                          },
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () {
                    try {
                      if (messageCon.text.trim().isNotEmpty) {
                        chatCubit
                            .sentSaveMessage(
                          context,
                          mediaType: 0,
                          mimeType: MimeType.none,

                          content: messageCon.text.trim(),
                          // callback: (sentMessageModel) {

                          // },
                        )
                            .then(
                          (value) {
                            messageCon.clear();
                            // context
                            //     .read<ChatCubit>()
                            //     .getChatMessages(
                            //         chatId ?? "", context);
                          },
                        );
                      }
                    } catch (e, st) {
                      showMessage("on Saved Message == $e, $st");
                    }
                  },
                  child: Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                        color: AppColors.primaryColor, shape: BoxShape.circle),
                    child: Center(child: SvgImage(source: SvgAssets.icSend)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void handleClick(int index, BuildContext context) {
    switch (index) {
      case 0:
        showClearChatDialog(context);
        break;
    }
  }

  void showClearChatDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return BlocBuilder<ChatCubit, ChatState>(
            builder: (contextMessage, state) {
          return Dialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26.r),
            ), //this right here
            child: SizedBox(
              width: double.infinity,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.dark,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        S.of(context).clearChat,
                        style: AppTextStyles.medium(fontSize: 20.sp),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        S.of(context).lblClearChatSubTitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.regular(
                            fontSize: 14.sp,
                            color: AppColors.textColorSecondary),
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: CustomButton(
                              onPressed: () async =>
                                  await NavigationService().goBack(),
                              backgroundColor: AppColors.btnGrey,
                              child: Text(
                                S.of(context).cancel,
                                style: AppTextStyles.medium(
                                  fontSize: 16.sp,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: CustomButton(
                              onPressed: () async {
                                await NavigationService().goBack();
                                chatCubit.clearAllSavedMessages(
                                  context,
                                  callback: (response) {
                                    Utils.showSnackBar(
                                        context, response.message ?? '',
                                        seconds: 3);
                                  },
                                );
                              },
                              child: Text(
                                S.of(context).clear,
                                style: AppTextStyles.medium(
                                  fontSize: 16.sp,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }
}

class PinnedMessagesWidget extends StatefulWidget {
  final List<SavedMessage> pinnedMessages; // List of pinned messages
  final Function(String messageId) onViewMessage;
  final Function(String messageId) onUnpin;
  final String currentUserId;

  const PinnedMessagesWidget({
    required this.pinnedMessages,
    required this.onViewMessage,
    required this.onUnpin,
    required this.currentUserId,
    Key? key,
  }) : super(key: key);

  @override
  _PinnedMessagesWidgetState createState() => _PinnedMessagesWidgetState();
}

class _PinnedMessagesWidgetState extends State<PinnedMessagesWidget> {
  int _currentIndex = 0;

  SavedMessage currentMessage = SavedMessage();

  @override
  void initState() {
    if (widget.pinnedMessages.isNotEmpty) {
      currentMessage = widget.pinnedMessages[_currentIndex];
    }
    if (mounted) {
      setState(() {});
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PinnedMessagesWidget oldWidget) {
    // log("PinnedMessagesWidget didUpdateWidget");
    _currentIndex = 0;
    if (widget.pinnedMessages.isNotEmpty) {
      currentMessage = widget.pinnedMessages[_currentIndex];
    }
    if (mounted) {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  void _nextMessage() {
    if (_currentIndex < widget.pinnedMessages.length - 1) {
      setState(() {
        _currentIndex++;
        currentMessage = widget.pinnedMessages[_currentIndex];
      });
    }
  }

  void _previousMessage() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        currentMessage = widget.pinnedMessages[_currentIndex];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pinnedMessages.isEmpty) {
      return SizedBox(); // Hide if no pinned messages
    }

    return BlocBuilder<ChatCubit, ChatState>(builder: (contextChat, state) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.darkInputFill,
          borderRadius: BorderRadius.circular(8),
          // border: Border.all(color: Colors.blue.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.push_pin, color: AppColors.white),
            SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () =>
                    widget.onViewMessage(currentMessage.messageId ?? ""),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.currentUserId ==
                              currentMessage.messageDetails?.sender?.id
                          ? S.of(context).you
                          : AppMethods.getNickName(
                                  currentMessage.messageDetails?.sender) ??
                              // currentMessage.messageDetails?.sender?.name ??
                              S.of(context).you,
                      style: AppTextStyles.medium(),
                    ),
                    4.s,
                    Text(
                      currentMessage.messageDetails?.content ??
                          S.of(context).noMessage,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.regular(),
                    ),
                  ],
                ),
              ),
            ),
            // IconButton(
            //   icon: Icon(Icons.visibility, color: AppColors.primaryColor),
            //   onPressed: () => widget.onViewMessage(currentMessage.messageId!),
            // ),
            Column(
              children: [
                TextButton(
                    onPressed: () => chatCubit.unPinSavedMessage(
                        userId: widget.currentUserId,
                        messageId: currentMessage.messageId ?? ""),
                    child: Text(
                      S.of(context).unPin,
                      style: AppTextStyles.regular(color: AppColors.purpleText),
                    )),
                // IconButton(
                //   icon: Icon(Icons.close, color: Colors.red),
                //   onPressed: () => widget.onUnpin(currentMessage["id"]!),
                // ),
                if (widget.pinnedMessages.length > 1)
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _previousMessage,
                        behavior: HitTestBehavior.translucent,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(Icons.arrow_back,
                              color: _currentIndex > 0
                                  ? AppColors.primaryColor
                                  : AppColors.white),
                        ),
                      ),
                      GestureDetector(
                        onTap: _nextMessage,
                        behavior: HitTestBehavior.translucent,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(Icons.arrow_forward,
                              color: _currentIndex <
                                      widget.pinnedMessages.length - 1
                                  ? AppColors.primaryColor
                                  : AppColors.white),
                        ),
                      ),
                      // IconButton(
                      //   padding: EdgeInsets.all(1),
                      //   icon: Icon(Icons.arrow_back,
                      //       color: _currentIndex > 0
                      //           ? AppColors.primaryColor
                      //           : AppColors.white),
                      //   onPressed: _previousMessage,
                      // ),
                      // IconButton(
                      //   padding: EdgeInsets.all(1),
                      //   icon: Icon(Icons.arrow_forward,
                      //       color:
                      //           _currentIndex < widget.pinnedMessages.length - 1
                      //               ? AppColors.primaryColor
                      //               : AppColors.white),
                      //   onPressed: _nextMessage,
                      // ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
