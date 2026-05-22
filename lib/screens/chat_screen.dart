import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:two_one_two_messenger/cubit/home_cubit.dart';
import 'package:two_one_two_messenger/cubit/home_state.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/date_format.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/conversation_model.dart';
import 'package:two_one_two_messenger/screens/channel_info.dart';
import 'package:two_one_two_messenger/screens/groupCall.dart';
import 'package:two_one_two_messenger/screens/group_info.dart';
import 'package:two_one_two_messenger/screens/report_user_screen.dart';
import 'package:two_one_two_messenger/screens/user_profile.dart';
import 'package:two_one_two_messenger/screens/voice_call_page.dart';
import 'package:two_one_two_messenger/services/socket_service.dart';
import 'package:two_one_two_messenger/utils/app_dialoge.dart';
import 'package:two_one_two_messenger/utils/app_pop_up.dart';
import 'package:two_one_two_messenger/widgets/avatar_widgets.dart';
import 'package:two_one_two_messenger/widgets/chat_bubble.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';
import 'package:two_one_two_messenger/widgets/error_widget.dart';
import 'package:two_one_two_messenger/widgets/sent_media_widgets.dart';
import 'package:two_one_two_messenger/widgets/typing_status_bubble.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../cubit/user_data_cubit.dart';
import '../models/chat_message_model.dart';
import '../models/otp_verify.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/navigation.dart';
import '../utils/text_style.dart';
import '../utils/utils.dart';
import '../widgets/buttons.dart';
import '../widgets/svg_images.dart';
import 'package:two_one_two_messenger/screens/chat/pinned_messages_widget.dart';

class ChatScreen extends StatefulWidget {
  final String userName;
  final String userId;
  final String userPic;
  ParticipantDetail? sender;
  String chatId;
  final int unreadMessageCount;
  final LastMessage? lastMessage;
  final ChatType chatType;
  final bool isShowProfileImage;
  bool isSendMessage;
  final bool isDeletedUser;
  final ParticipantDetail? createdBy;
  String aesKey;

  ChatScreen({
    super.key,
    required this.unreadMessageCount,
    required this.userName,
    required this.userId,
    required this.userPic,
    this.chatId = '',
    this.lastMessage,
    this.isDeletedUser = false,
    required this.chatType,
    required this.isShowProfileImage,
    required this.isSendMessage,
    required this.aesKey,
    this.createdBy,
    this.sender,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageCon = TextEditingController();
  UserData? userData;
  String? chatId;
  late IO.Socket socket;
  final FocusNode _focusNode = FocusNode();
  String groupMessageString = "";
  // late StreamController<List<ChatData>> _chatStreamController;

  List<MessageModel> messageList = [];
  bool _isHighlightingMessage = false;

  final scrollController = ScrollController();
  final _scrollController = AutoScrollController(
    axis: Axis.vertical,
    // suggestedRowHeight: 200,
  );
  final SocketService _socketService = SocketService();

  int disAppearingMessagesTime = 0;
  final GlobalKey _actionButtonKey = GlobalKey();

  Offset? _getButtonOffset() {
    RenderBox? renderBox =
        _actionButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      return renderBox.localToGlobal(Offset.zero) + Offset(0, 50.h);
    }
  }

  Map<String, GlobalKey> messageKeys = {};
  String? highlightedMessageId;
  // MessageModel? replyingToMessage;
  void scrollToMessage(String messageId) {
    if (messageKeys.containsKey(messageId)) {
      GlobalKey? key = messageKeys[messageId];
      showMessage(
          "scrollToMessage: Message is not built yet, scrolling manually.");
      if (key != null && key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        // scrollToMessage(messageId);
      } else {
        showMessage(
            "scrollToMessage: Message is not built yet, scrolling manually.");

        int index = messageList.indexWhere((msg) => msg.messageId == messageId);
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

  // Animate chat bubble when swiping to reply
  void animateChatBubble(String messageId) {
    setState(() {
      highlightedMessageId = messageId;
    });

    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        highlightedMessageId = null;
      });
    });
  }

  Future<void> onHighlightMessage(
    MessageModel message,
    List<MessageModel> processedList, {
    int retryCount = 0,
    int maxRetries = 100,
  }) async {
    try {
      _isHighlightingMessage = true;
      // log("onHighlightMessage call");
      int index =
          processedList.indexWhere((m) => m.messageId == message.messageId);

      if (index == -1 && retryCount < maxRetries) {
        await chatCubit.getChatMessages(
          chatId: widget.chatId,
          context: context,
          aesKey: widget.aesKey,
          isLoadMore: true,
          searchQuery: "",
        );

        // Wait for messages to render
        await Future.delayed(const Duration(milliseconds: 200));
        await WidgetsBinding.instance.endOfFrame;

        final updatedList = (chatCubit.state.chatList ?? Set.of([])).toList();
        return onHighlightMessage(
          message,
          updatedList,
          retryCount: retryCount + 1,
        );
      }

      if (index != -1) {
        await _scrollToAndHighlight(index);
      }
    } catch (e, st) {
      log("Highlight error: $e, $st");
    } finally {
      _isHighlightingMessage = false;
    }
  }

  Future<void> _scrollToAndHighlight(int index) async {
    showMessage("_scrollToAndHighlight=== $index");
    await WidgetsBinding.instance.endOfFrame; // Wait until layout is complete

    try {
      _isHighlightingMessage = true;
      await _scrollController.scrollToIndex(
        index,
        preferPosition: AutoScrollPosition.middle,
        // duration: const Duration(milliseconds: 300),
      );
      await Future.delayed(const Duration(milliseconds: 100)); // Small delay
      await _scrollController.highlight(index,
          highlightDuration: Duration(seconds: 1)); // Then highlight
    } catch (e) {
      log("Scroll to index failed: $e");
    } finally {
      _isHighlightingMessage = false;
    }
  }

  @override
  void initState() {
    super.initState();
    userData = context.read<UserDataCubit>().state;
    showMessage("initState called${DateTime.now()} ${widget.chatId} ");
    init();
  }

  @override
  void dispose() {
    disposeAllEvents();
    messageCon.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    showMessage("dispose called ${DateTime.now()} ${widget.chatId} ");

    super.dispose();
  }

  Future<void> init() async {
    try {
      _focusNode.addListener(_handleFocusChange);
      userData ??= await chatCubit.dbHelper.getLoginData();
      chatId = widget.chatId;
      // showMessage(":: USER Is Typing ${widget.chatId} ");
      if (widget.createdBy != null) {
        if (userData?.sId != widget.createdBy?.id) {
          groupMessageString =
              "${widget.createdBy?.name} ${widget.chatType == ChatType.channel ? S.current.channelCreatedEmptyChatMsg : S.current.groupCreatedEmptyChatMsg}";
        }
      }
      connectToServer();
      await fetchConversationData();
      _scrollController.addListener(_loadMoreListener);
    } catch (e, st) {
      showMessage("Error init $e,$st");
    }
  }

  Future<void> _loadMoreListener() async {
    if (_isHighlightingMessage) return;

    final maxScrollExtent = _scrollController.position.maxScrollExtent / 2;
    if (_scrollController.offset > maxScrollExtent &&
        (!chatCubit.state.chatMessageLoadingMore &&
            chatCubit.state.chatLoadingState == LoadingState.success)) {
      await chatCubit.getChatMessages(
        chatId: widget.chatId,
        context: context,
        aesKey: widget.aesKey,
        isLoadMore: true,
        searchQuery: "",
      );
    } else {
      log("load more in get Message  ${_scrollController.offset > maxScrollExtent}  2${!chatCubit.state.chatMessageLoadingMore} 3${chatCubit.state.chatLoadingState == LoadingState.success}");
    }

    log("Listener call");
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      // User focused on input -> Send "typing" event
      sendTypingEvent(true);
    } else {
      // User unfocused -> Send "stopped typing" event
      sendTypingEvent(false);
    }
  }

  Future<void> emitMessageReadStatus(
      bool ischatOpen, String lastMessageId) async {
    // showMessage("emitMessageReadStatus==>$lastMessageId");
    _socketService.sendEvent(AppConstants.emitMessageReadStatus, {
      "userId": userData?.sId,
      "chatId": widget.chatId.isEmpty
          ? chatCubit.state.currentConversationId ?? chatId
          : widget.chatId,
      "isChatOpen": ischatOpen,
      "lastMessageId": lastMessageId
    });
  }

  void connectToServer() {
    // final chatCubit = context.read<ChatCubit>();

    _socketService.changeMessageStatus((data) async {
      showMessage(
          ":: changeMessageStatus==> $data ${mounted && chatCubit.chatId == data["chatId"]}");
      if (mounted && chatCubit.chatId == data["chatId"]) {
        await chatCubit.updateMessageStatus(
          context: context,
          lastMsgId: data["lastMessageId"],
        );
      }
    });
    _socketService.onUserOnline((data) {
      showMessage(":: USER Is Online $data");
      if (mounted && data["userId"] == widget.userId) {
        chatCubit.updateOnlineLastStatus(data: data);
      }
    });
    _socketService.onBlockUser((data) {
      showMessage(
          ":: changeMessageStatus==> $data ${widget.userId} ${mounted && chatCubit.chatId == data["chatId"]}");
      if (widget.chatType == ChatType.one_to_one) {
        if (mounted && chatCubit.chatId == data["chatId"]) {
          chatCubit.handleWhenUserBlouckedYou(data["isBlocked"]);
        } else if ((mounted && widget.userId == data["userId"])) {
          chatCubit.handleWhenUserBlouckedYou(data["isBlocked"]);
        }
      }
    });
    _socketService.onRemoveUser((data) {
      showMessage(
          ":: changeMessageStatus==> $data ${widget.userId} ${mounted && chatCubit.chatId == data["chatId"]}");
      if (widget.chatType != ChatType.one_to_one) {
        if (mounted && chatCubit.chatId == data["chatId"]) {
          chatCubit.handleWhenUserRemoveFromGroup();
        }
      }
    });
    _socketService.onAddedToGroup((data) {
      showMessage(
          ":: onAddedToGroup==> $data ${widget.userId} ${mounted && chatCubit.chatId == data["chatId"]}");
      if (widget.chatType != ChatType.one_to_one) {
        if (mounted && chatCubit.chatId == data["chatId"]) {
          chatCubit.handleWhenUserAddedToGroup(data);
          setState(() {
            widget.isSendMessage =
                homeCubit.state.groupData?.isSendMessage ?? true;
          });
        }
      }
    });
    _socketService.onAssignOrRemoveFromAdminToGroup((data) {
      log(":: onAssignOrRemoveFromAdminToGroup==> $data ${widget.userId} ${mounted && chatCubit.chatId == data["chatId"]}");
      if (widget.chatType == ChatType.group) {
        if (mounted && chatCubit.chatId == data["chatId"]) {
          if (!(homeCubit.state.groupData?.isSendMessage ?? true)) {
            setState(() {
              widget.isSendMessage = data["isAdmin"];
              log(":: onAssignOrRemoveFromAdminToGroup111111==> $data ${widget.isSendMessage} ");
            });
          }
        }
      }
    });
    _socketService.onPinnedMessage((data) {
      showMessage(
          ":: onPinnedMessage==> $data ${widget.userId} ${mounted && chatCubit.chatId == data["chatId"]}");
      chatCubit.onPinnedMessage(
          chatId: data["chatId"], messageId: data["pinMessage"]["messageId"]);
    });
    _socketService.onUnPinnedMessage((data) {
      showMessage(
          ":: onUnPinnedMessage==> $data ${widget.userId} ${mounted && chatCubit.chatId == data["chatId"]}");
      if (mounted && chatCubit.chatId == data["chatId"]) {
        chatCubit.onUnPinnedMessage(
            chatId: data["chatId"], messageId: data["pinMessage"]["messageId"]);
      }
    });
    chatCubit.clearTypingList();
    _socketService.onUserTyping(
        // AppConstants.receivedTypingStatus,
        (data) {
      TypingModel newTypingModel = TypingModel.fromJson(data);
      showMessage(
          ":: USER Is Typing ${widget.chatId} ${newTypingModel.chatId == widget.chatId} $data");
      if (newTypingModel.chatId == widget.chatId) {
        chatCubit.updateTypingList(newTypingModel);
      }
    });
  }

  void disposeAllEvents() {
    _socketService.off(AppConstants.updateMessageStatus);
    _socketService.off(AppConstants.socketUserOnline);
    _socketService.off(AppConstants.userBlockedyou);
    _socketService.off(AppConstants.removeFromGroup);
    _socketService.off(AppConstants.addtoGroupGroup);
    _socketService.off(AppConstants.onAssignOrRemoveFromAdminToGroup);
    _socketService.off(AppConstants.onPinedMessage);
    _socketService.off(AppConstants.onUnPinedMessage);
    _socketService.off(AppConstants.receivedTypingStatus);
  }

  Future<void> sendTypingEvent(bool isTyping) async {
    // showMessage("is Typing===> ${{
    //   "chatType": 'one-to-one',
    //   "chatId": widget.chatId.isEmpty
    //       ? (chatCubit.state.currentConversationId ?? chatId ?? "")
    //       : widget.chatId,
    //   "sender": Sender(id: userData?.sId,name: userData?.name,userName: userData?.userName,profilePicture: userData?.profilePicture).toJson(),
    //   "isTypeing": isTyping
    // }}");
    showMessage(
        "sendTypingEvent==>${widget.chatType.name} ${widget.chatId.isEmpty ? chatCubit.state.currentConversationId ?? chatId : widget.chatId}");
    _socketService.sendEvent(AppConstants.sendTyping, {
      "chatType": widget.chatType.name,
      "chatId": widget.chatId.isEmpty
          ? chatCubit.state.currentConversationId ?? chatId
          : widget.chatId,
      "sender": Sender(
              id: userData?.sId,
              userName: userData?.userName,
              profilePicture: userData?.profilePicture)
          .toJson(),
      "isTyping": isTyping
    });
  }

  fetchConversationData() async {
    final chatCubit = context.read<ChatCubit>();
    if (widget.chatType != ChatType.one_to_one && userData != null) {
      if (widget.chatType == ChatType.group ||
          widget.chatType == ChatType.channel) {
        homeCubit.cleanGroupDataInfo();
      }
    }

    if (widget.chatId.isEmpty && (widget.chatType == ChatType.one_to_one)) {
      await chatCubit.createConversation(widget.userId!, context).then(
            (value) {},
          );
      chatId = chatCubit.state.currentConversationId;
      widget.chatId = chatCubit.state.currentConversationId ?? "";
      widget.aesKey =
          chatCubit.state.createConversationModel?.encryptedAESKey ?? "";
      if (widget.chatId.isNotEmpty && widget.aesKey.isNotEmpty) {
        await getMessages(widget.chatId, widget.aesKey);
      }
    } else {
      chatId = widget.chatId;
      await getMessages(widget.chatId, widget.aesKey);
    }
  }

  Future<void> getMessages(String chatId, String aesKey) async {
    chatCubit.changeChatPageStatus(chatId, true, userData?.sId ?? "");

    showMessage("chatid ==> $chatId");

    await chatCubit
        .getChatMessages(
          chatId: chatId,
          context: context,
          aesKey: aesKey,
          isLoadMore: false,
          searchQuery: "",
        )
        .then(
          (value) {},
        );
    await chatCubit.checkAndRetryPendingMessages(
      chatId: chatId,
      context: context,
      aesKey: aesKey,
    );
    // if (widget.chatType == ChatType.one_to_one) {
    if ((widget.lastMessage?.messageId ?? "").isNotEmpty) {
      showMessage("chatid lastmessage==> ${widget.lastMessage?.messageId}");
      emitMessageReadStatus(true, widget.lastMessage!.messageId ?? "");
    } else if ((chatCubit.state.chatList ?? Set.of([])).isNotEmpty) {
      log("chatid lastmessage==> ${chatCubit.state.chatList!.first.toJson()}");
      // emitMessageReadStatus(true, chatCubit.state.chatMessageModel!.messages!.last.messageId ?? "");
    }

    if (widget.chatType != ChatType.one_to_one && userData != null) {
      if (widget.chatType == ChatType.group ||
          widget.chatType == ChatType.channel) {
        homeCubit.getGroupInfobyId(context, widget.chatId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        // if(didPop) return;
        context
            .read<ChatCubit>()
            .changeChatPageStatus('', false, userData?.sId ?? "");
        homeCubit.getConversation(
          context: context,
        );
        homeCubit.refreshStoriesData(context);
        // await NavigationService().goBack();
      },
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.dark,
            leading: IconButton(
              onPressed: () async {
                // showMessage("call ===>");
                context
                    .read<ChatCubit>()
                    .changeChatPageStatus('', false, userData?.sId ?? "");
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
                      if (widget.chatType == ChatType.one_to_one &&
                          widget.sender != null &&
                          widget.sender?.isOnline != null) {
                        NavigationService().navigateTo(
                          UserProfileScreen(
                            user: UserData.fromJson(
                              widget.sender!.toJson(),
                            ),
                            onNickNameStatusChangge: (newStatus) {
                              // print("New Status >> $newStatus");
                              setState(() {
                                widget.sender?.isActiveNickname = newStatus;
                              });
                            },
                            onNickNameChange: (
                                {required newNickName, required newStatus}) {
                              setState(() {
                                widget.sender?.nickName = newNickName;
                                widget.sender?.isActiveNickname = newStatus;
                              });
                            },
                            // onNickNameChange: (newNickName,) {
                            //   setState(() {
                            //     widget.sender?.nickName = newNickName;
                            //   });
                            // },
                          ),
                        );
                      }
                    },
                    child: BlocBuilder<HomeCubit, HomeState>(
                        builder: (contextChat, state) {
                      return AvatarWidgets(
                        userPic: (widget.chatType == ChatType.channel ||
                                widget.chatType == ChatType.group)
                            ? (state.groupData?.groupImage ?? widget.userPic)
                            : widget.userPic,
                        svgAvatar: (widget.chatType == ChatType.channel)
                            ? SvgAssets.megaphone
                            : (widget.chatType == ChatType.group)
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
                          (widget.chatType == ChatType.channel ||
                                  widget.chatType == ChatType.group)
                              ? (state.groupData?.groupName ?? widget.userName)
                              : ((widget.sender?.isActiveNickname ?? false)
                                  ? (widget.sender?.nickName ?? widget.userName)
                                  : widget.sender?.name ?? widget.userName),
                          style: AppTextStyles.medium(fontSize: 16.sp),
                        );
                      }),
                      SizedBox(
                        height: 5,
                      ),
                      BlocBuilder<ChatCubit, ChatState>(
                          builder: (contextChat, state) {
                        if (widget.chatType == ChatType.one_to_one) {
                          return Text(
                            (state.chatMessageModel?.isOnline ?? false)
                                ? S.of(context).online
                                : state.chatMessageModel?.lastSeen != null
                                    ? "${S.of(context).sLastSeen} ${state.chatMessageModel?.lastSeen?.formatTimeAgo}"
                                    : "",
                            style: AppTextStyles.regular(
                                fontSize: 10.sp,
                                color: AppColors.white.withOpacity(0.5)),
                          );
                        }
                        return BlocBuilder<HomeCubit, HomeState>(
                            builder: (contextChat, state) {
                          if (state.groupData?.participants == null) {
                            return SizedBox();
                          }
                          return Text(
                            (widget.chatType == ChatType.group)
                                ? S.of(context).noOfMember(
                                    state.groupData?.participants?.length ?? 0)
                                : S.of(context).noOfSubscriber(
                                    state.groupData?.participants?.length ?? 0),
                            // "",
                            style: AppTextStyles.regular(
                                fontSize: 10.sp,
                                color: AppColors.white.withOpacity(0.5)),
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
              if (widget.chatType != ChatType.channel)
                BlocBuilder<HomeCubit, HomeState>(
                    builder: (contextHome, homeState) {
                  final bool isGroup = widget.chatType == ChatType.group;
                  final int memberCount =
                      homeState.groupData?.participants?.length ?? 0;

                  // If it's a group and only one member is there, disable calls
                  final bool isCallDisabled = isGroup && memberCount <= 1;

                  return BlocBuilder<ChatCubit, ChatState>(
                      builder: (contextChat, state) {
                    if (!(widget.isSendMessage) ||
                        (widget.isDeletedUser) ||
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
                        if ((widget.chatType == ChatType.one_to_one)) {
                          NavigationService().navigateTo(CallingPage(
                            callType: CallType.video,
                            currentConversationId: widget.chatId.isEmpty
                                ? (chatCubit.state.currentConversationId ??
                                    chatId ??
                                    "")
                                : widget.chatId,
                            image: widget.userPic ?? "",
                            receiverId: widget.userId,
                            // name: widget.userName ?? '',
                            name: AppMethods.getNickNameForParticipateDetails(
                                widget.sender),
                            isActive: false,
                            from: "chatPage",
                          ));
                        } else {
                          // if((homeCubit.state.groupData?.participants??[]).length<=1){
                          // Utils.showSnackBar(context, S.of(context).);
                          // }

                          NavigationService().navigateTo(GroupCallingPage(
                            callType: CallType.video_group_call,
                            currentConversationId: widget.chatId.isEmpty
                                ? (chatCubit.state.currentConversationId ??
                                    chatId ??
                                    "")
                                : widget.chatId,
                            image: widget.userPic ?? "",
                            receiverId: widget.userId,
                            name: widget.userName ?? '',
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
              //             IconButton(
              //               padding: EdgeInsets.zero,
              // onPressed: () {   },
              //               icon: SvgImage(
              //                 source: SvgAssets.icVideo,
              //                 width: 18.w,
              //                 height: 18.h,
              //                 color: AppColors.white,
              //               ),
              //             ),
              // 10.s,
              if (widget.chatType != ChatType.channel)
                BlocBuilder<HomeCubit, HomeState>(
                    builder: (contextHome, homeState) {
                  final bool isGroup = widget.chatType == ChatType.group;
                  final int memberCount =
                      homeState.groupData?.participants?.length ?? 0;

                  // If it's a group and only one member is there, disable calls
                  final bool isCallDisabled = isGroup && memberCount <= 1;

                  return BlocBuilder<ChatCubit, ChatState>(
                      builder: (contextChat, state) {
                    if (!(widget.isSendMessage) ||
                        (widget.isDeletedUser) ||
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
                        if ((widget.chatType == ChatType.one_to_one)) {
                          NavigationService().navigateTo(CallingPage(
                            callType: CallType.voice,
                            currentConversationId: widget.chatId.isEmpty
                                ? (chatCubit.state.currentConversationId ??
                                    chatId ??
                                    "")
                                : widget.chatId,
                            image: widget.userPic ?? "",
                            // name: widget.userName ?? '',
                            name: AppMethods.getNickNameForParticipateDetails(
                                widget.sender),
                            receiverId: widget.userId,
                            isActive: false,
                            from: "chatPage",
                          ));
                        } else {
                          NavigationService().navigateTo(GroupCallingPage(
                            callType: CallType.voice_group_call,
                            currentConversationId: widget.chatId.isEmpty
                                ? (chatCubit.state.currentConversationId ??
                                    chatId ??
                                    "")
                                : widget.chatId,
                            image: widget.userPic ?? "",
                            name: widget.userName ?? '',
                            receiverId: widget.userId,
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
              // IconButton(
              //   onPressed: () {

              //   },
              //   icon: SvgImage(
              //     source: SvgAssets.icPhone,
              //     width: 18.w,
              //     height: 18.h,
              //     color: AppColors.white,
              //   ),
              // ),
              // if (widget.chatType != ChatType.one_to_one)
              BlocBuilder<ChatCubit, ChatState>(builder: (contextChat, state) {
                // if ((state.chatMessageModel?.isBlocked ?? false)) {
                //   return SizedBox();
                // }
                if ((state.chatMessageModel?.removeFromChat ?? false) ||
                    (state.chatMessageModel?.otherUserRemoveFromChat ??
                        false)) {
                  return PopupMenuButton<MessageOption>(
                    color: AppColors.dialogBg,
                    icon: SvgImage(
                        source: SvgAssets.icMoreDots,
                        width: 18.w,
                        color: AppColors.white),
                    onSelected: (value) {
                      showClearChatDialog(context);
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
                    if ((widget.chatType != ChatType.one_to_one)) {
                      if ((state.chatMessageModel?.removeFromChat ?? false) ||
                          (state.chatMessageModel?.otherUserRemoveFromChat ??
                              false)) return;
                      showDraggableBottomSheet(context);
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
                            if (widget.chatType == ChatType.one_to_one &&
                                widget.sender != null &&
                                widget.sender?.isOnline != null) {
                              NavigationService().navigateTo(UserProfileScreen(
                                user:
                                    UserData.fromJson(widget.sender!.toJson()),
                              ));
                            }
                          },
                        ),
                        if (!((state.chatMessageModel?.youBlocked ?? false) ||
                            (state.chatMessageModel?.isBlocked ?? false)))
                          ChatOption(
                            value: "disapperingMessages",
                            name: S.of(context).disappearingMessage,
                            icon: Icon(Icons.timer,
                                color: AppColors.white, size: 24),
                            onTap: () {
                              showDisappearingMessageTimerSheet(
                                context,
                                disAppearingMessagesTime,
                                (value) async {
                                  String senderId = userDataCubit.state?.sId ??
                                      (await chatCubit.dbHelper.getLoginData())
                                          ?.sId ??
                                      "";
                                  showMessage(
                                      "updateMessageAutoDeleteTime call => ${{
                                    "chatId": chatId,
                                    "messageAutoDeleteTime": value,
                                    "messageId": DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString(),
                                    "userId": senderId
                                  }}");
                                  _socketService.sendEvent(
                                      AppConstants.updateMessageAutoDeleteTime,
                                      {
                                        "chatId": chatId,
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
                        if (!widget.isDeletedUser)
                          ChatOption(
                            value: "reportUser",
                            name: S.of(context).reportUser,
                            icon: Icon(Icons.report,
                                color: AppColors.white, size: 24),
                            onTap: () {
                              NavigationService().navigateTo(ReportUserPage(
                                onReport: (reason, description) async {
                                  showMessage(
                                      "Report User $reason   $description");

                                  await homeCubit.reportUser(
                                      userId: widget.userId,
                                      userName: widget.userName,
                                      reason: reason,
                                      description: description,
                                      context: context);
                                },
                              ));
                            },
                          ),
                        if (!widget.isDeletedUser)
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
                              if ((state.chatMessageModel?.youBlocked ??
                                  false)) {
                                showCommonBlockUserDialog(
                                    context: context,
                                    icon: Icons.person_off,
                                    onSubmit: () {
                                      homeCubit.unBlockedUser(
                                        userId: widget.userId,
                                        context: context,
                                        callback: () async {
                                          chatCubit.handleUnblockUser(false);
                                          Utils.showSnackBar(
                                              context,
                                              S
                                                  .of(context)
                                                  .unblockUserSuccessfully(
                                                      widget.userName ?? ""));
                                        },
                                      );
                                    },
                                    title: S.of(context).unblockUserTitle,
                                    subTitle: S
                                        .of(context)
                                        .unblockUserSubtitle(widget.userName));
                              } else {
                                showCommonBlockUserDialog(
                                    context: context,
                                    onSubmit: () {
                                      homeCubit.blockedUser(
                                        chatId: chatId ??
                                            chatCubit
                                                .state.currentConversationId ??
                                            widget.chatId,
                                        userId: widget.userId,
                                        context: context,
                                        callback: () async {
                                          chatCubit.handleUnblockUser(true);
                                          Utils.showSnackBar(
                                              context,
                                              S
                                                  .of(context)
                                                  .blockUserSuccessfully(
                                                      widget.userName ?? ""));
                                        },
                                      );
                                    },
                                    title: S.of(context).blockUserTitle,
                                    subTitle: S.of(context).blockUserSubtitle(
                                        widget.userName ??
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
                            showClearChatDialog(context);
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
              // else

              //   buildOptionMenu(
              //     context: context,
              //     onSelected: (item) {
              //       handleClick(item.index, context);
              //     },
              //   ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: BlocBuilder<ChatCubit, ChatState>(
                    builder: (contextChat, state) {
                      if (state.chatLoadingState == LoadingState.loading) {
                        return Center(
                          child: CustomLoadingWidget(),
                        );
                      } else if (state.chatLoadingState ==
                          LoadingState.success) {
                        // chatList = state.chatList.reversed.toList();
                        print("chat message build called");
                        final chatList =
                            List<MessageModel>.from(state.chatList ?? []);
                        // messageList.clear();
                        messageList = List.from(chatList);
                        if ((state.currentTypingusers ?? []).isNotEmpty) {
                          if (chatList.isNotEmpty &&
                              chatList[0].type != "typing") {
                            // showMessage("addMessages == ${chatList[0].type}");
                            chatList.insert(
                                0,
                                MessageModel(
                                  type: "typing",
                                  sender:
                                      state.currentTypingusers!.first.sender ??
                                          Sender(
                                              id: state.currentTypingusers!
                                                      .first.sender?.id ??
                                                  "",
                                              profilePicture: state
                                                      .currentTypingusers!
                                                      .first
                                                      .sender
                                                      ?.profilePicture ??
                                                  "",
                                              userName: state
                                                      .currentTypingusers!
                                                      .first
                                                      .sender
                                                      ?.userName ??
                                                  ""),
                                ));
                          }
                        }

                        if (chatList.isEmpty) {
                          return Center(
                            child: widget.chatType != ChatType.one_to_one &&
                                    groupMessageString.isNotEmpty
                                ? Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: AppColors.darkInputFill,
                                        borderRadius:
                                            BorderRadius.circular(47.r)),
                                    child: Row(
                                      children: [
                                        SvgImage(
                                          source: SvgAssets.icInfo,
                                          color: AppColors.white,
                                        ),
                                        8.s,
                                        Expanded(
                                          child: Text(
                                            groupMessageString,
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
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            WidgetSpan(
                                              child: Icon(Icons.lock,
                                                  color: AppColors
                                                      .darkTextColorHint,
                                                  size: 16),
                                              alignment: PlaceholderAlignment
                                                  .middle, // Align with text
                                            ),
                                            TextSpan(
                                              text:
                                                  " ${S.of(context).messageEncryptionInfo}",
                                              style: AppTextStyles.regular(
                                                      color: AppColors
                                                          .darkTextColorHint)
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
                              pinnedMessages:
                                  (state.chatMessageModel?.pinnedMessages ??
                                              Set.of([]))
                                          .isEmpty
                                      ? []
                                      : List.from(state
                                          .chatMessageModel!.pinnedMessages!
                                          .toList()),
                              onViewMessage: (message) {
                                // showMessage("Viewing pinned message ID: $id");
                                // scrollToMessage(id);
                                if (_isHighlightingMessage) return;
                                onHighlightMessage(message, chatList);
                              },
                              onUnpin: (id) {
                                showMessage("Unpinning message ID: $id");
                                // Remove from pinned list
                              },
                              currentUserId: userData!.sId!,
                            ),
                            Expanded(
                              child: GroupedListView<MessageModel, String>(
                                elements: chatList,
                                controller: _scrollController,
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
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.w),
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
                                    .compareTo(
                                        b.createdAt.toString().toLowerCase()),
                                order: GroupedListOrder.DESC,
                                indexedItemBuilder: (context, element, index) {
                                  Widget child;
                                  if (chatList[index].type == "typing") {
                                    child = TypingIndicatorBubble(
                                      chatType: widget.chatType,
                                      profilePic: chatList[index]
                                              .sender
                                              ?.profilePicture ??
                                          "",
                                    );
                                  } else if (chatList[index].type ==
                                      "encryption_info") {
                                    child = Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8.h, horizontal: 16.w),
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.darkInputFill,
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                        ),
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              WidgetSpan(
                                                child: Icon(Icons.lock,
                                                    color: AppColors
                                                        .darkTextColorHint,
                                                    size: 16),
                                                alignment: PlaceholderAlignment
                                                    .middle, // Align with text
                                              ),
                                              TextSpan(
                                                text:
                                                    " ${S.of(context).messageEncryptionInfo}",
                                                style: AppTextStyles.regular(
                                                        color: AppColors
                                                            .darkTextColorHint)
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
                                    disAppearingMessagesTime =
                                        chatList[index].disAppearingMessages ??
                                            0;
                                    child = GestureDetector(
                                      onTap: () {
                                        showDisappearingMessageTimerSheet(
                                          context,
                                          chatList[index]
                                                  .disAppearingMessages ??
                                              0,
                                          (value) async {
                                            String senderId =
                                                userDataCubit.state?.sId ??
                                                    (await chatCubit.dbHelper
                                                            .getLoginData())
                                                        ?.sId ??
                                                    "";

                                            _socketService.sendEvent(
                                                AppConstants
                                                    .updateMessageAutoDeleteTime,
                                                {
                                                  "chatId":
                                                      chatList[index].chatId ??
                                                          chatId,
                                                  "messageAutoDeleteTime":
                                                      value,
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
                                            color: AppColors
                                                .btnGrey, // Use a different color
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                          ),
                                          child: Text.rich(
                                            TextSpan(
                                              children: [
                                                WidgetSpan(
                                                  child: Icon(Icons.timer,
                                                      color: AppColors.white,
                                                      size: 16),
                                                  alignment: PlaceholderAlignment
                                                      .middle, // Align with text
                                                ),
                                                TextSpan(
                                                  text:
                                                      " ${S.of(context).disappearingMessageInfo(chatList[index].sender?.name ?? "", Utils.getDisappearingMessageLabel(chatList[index].disAppearingMessages ?? 0))}",
                                                  style: AppTextStyles.regular(
                                                          color:
                                                              AppColors.white)
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
                                  } else if (chatList[index].type ==
                                      "system_message") {
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
                                              alpha:
                                                  0.4), // Use a different color
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                        ),
                                        child: Text(
                                          "${chatList[index].systemMessage?.message ?? ""}",
                                          style: AppTextStyles.regular(
                                                  color: AppColors.white)
                                              .copyWith(height: 1.5),
                                          softWrap: true,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  } else if (!(chatList[index].isSent ??
                                      true)) {
                                    // messageKeys[chatList[index].messageId!] =
                                    //     chatList[index].key;
                                    child = ChatBubble(
                                        aesKey: widget.aesKey,
                                        isShowProfileImage:
                                            widget.isShowProfileImage,
                                        message: chatList[index],
                                        isSender: chatList[index].sender?.id ==
                                            userData?.sId,
                                        index: index,
                                        isAccessToMessageUtilities: (widget
                                                .isSendMessage &&
                                            !(state.chatMessageModel?.youBlocked ??
                                                false) &&
                                            !((state.chatMessageModel
                                                    ?.removeFromChat ??
                                                false)) &&
                                            !((state.chatMessageModel
                                                    ?.otherUserRemoveFromChat ??
                                                false)) &&
                                            !(state.chatMessageModel
                                                    ?.isBlocked ??
                                                false)),
                                        onTapScroll: () {
                                          if (chatList[index].replyTo != null) {
                                            showMessage(
                                                "onTapScroll  ${chatList[index].replyTo!.messageId!}");
                                            if (_isHighlightingMessage) return;
                                            onHighlightMessage(
                                                chatList[index].replyTo!,
                                                chatList);
                                          }
                                        },
                                        onSwipe: () {},
                                        isGroup: widget.chatType !=
                                            ChatType.one_to_one,
                                        mainContext: context);
                                  } else {
                                    messageKeys[chatList[index].messageId!] =
                                        chatList[index].key;
                                    child = Dismissible(
                                      key: chatList[index].key,

                                      direction: chatList[index].sender?.id ==
                                              userData?.sId
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
                                        if ((widget.isSendMessage &&
                                            !(state.chatMessageModel?.youBlocked ??
                                                false) &&
                                            !((state.chatMessageModel
                                                    ?.removeFromChat ??
                                                false)) &&
                                            !((state.chatMessageModel
                                                    ?.otherUserRemoveFromChat ??
                                                false)) &&
                                            !(state.chatMessageModel
                                                    ?.isBlocked ??
                                                false))) {
                                          // setState(() {
                                          chatCubit.handleReplyMessage(
                                              chatList[index]);
                                          // });
                                        } // Trigger reply action
                                        return false; // Prevent actual dismissal
                                      },
                                      child: AnimatedContainer(
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
                                        child: ChatBubble(
                                            aesKey: widget.aesKey,
                                            isShowProfileImage:
                                                widget.isShowProfileImage,
                                            message: chatList[index],
                                            isSender: chatList[
                                                        index]
                                                    .sender
                                                    ?.id ==
                                                userData?.sId,
                                            index: index,
                                            isAccessToMessageUtilities: (widget
                                                    .isSendMessage &&
                                                !(state.chatMessageModel
                                                        ?.youBlocked ??
                                                    false) &&
                                                !((state.chatMessageModel
                                                        ?.removeFromChat ??
                                                    false)) &&
                                                !((state.chatMessageModel
                                                        ?.otherUserRemoveFromChat ??
                                                    false)) &&
                                                !(state.chatMessageModel
                                                        ?.isBlocked ??
                                                    false)),
                                            onTapScroll: () {
                                              if (chatList[index].replyTo !=
                                                  null) {
                                                showMessage(
                                                    "onTapScroll  ${chatList[index].replyTo!.messageId!}");
                                                if (_isHighlightingMessage)
                                                  return;
                                                onHighlightMessage(
                                                    chatList[index].replyTo!,
                                                    chatList);
                                              }
                                            },
                                            onSwipe: () {},
                                            isGroup: widget.chatType !=
                                                ChatType.one_to_one,
                                            mainContext: context),
                                      ),
                                    );
                                  }
                                  return AutoScrollTag(
                                    key: ValueKey(
                                        'scroll-${chatList[index].messageId ?? index}'),
                                    controller: _scrollController,
                                    index: index,
                                    highlightColor:
                                        AppColors.primaryColor.withOpacity(0.3),
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
                          onRefresh: () {
                            getMessages(widget.chatId, widget.aesKey);
                          },
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              BlocBuilder<ChatCubit, ChatState>(builder: (contextChat, state) {
                if (widget.isSendMessage &&
                    !(state.chatMessageModel?.youBlocked ?? false) &&
                    !((state.chatMessageModel?.removeFromChat ?? false)) &&
                    !(state.chatMessageModel?.otherUserRemoveFromChat ??
                        false) &&
                    !(state.chatMessageModel?.isBlocked ?? false)) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w)
                        .copyWith(bottom: 16.h),
                    child: Column(
                      children: [
                        if (state.replyingToMessage != null)
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: AppColors.darkInputFill,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(14.r))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        S.of(context).replyingTo,
                                        style: AppTextStyles.medium(),
                                      ),
                                    ),
                                    GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        // setState(() {
                                        // replyingToMessage = null;

                                        chatCubit.handleReplyMessage(null);
                                        // });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Icon(
                                          Icons.close,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                ReplyMessageView(
                                  onTapScroll: () {},
                                  message: state.replyingToMessage!,
                                  isSender:
                                      state.replyingToMessage?.sender?.id ==
                                          userData?.sId,
                                ),
                              ],
                            ),
                          ),
                        4.s,
                        Row(
                          children: [
                            Expanded(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxHeight: 150.h), // Set your max height
                                child: SingleChildScrollView(
                                  reverse: true,
                                  child: TextField(
                                    controller: messageCon,
                                    focusNode: _focusNode,
                                    keyboardType: TextInputType.multiline,
                                    textInputAction: TextInputAction.newline,
                                    maxLines: 5,
                                    expands: false,
                                    onChanged: (value) {},
                                    minLines: 1,
                                    style: AppTextStyles.medium(
                                      fontSize: 16.sp,
                                      color: AppColors.white,
                                    ).copyWith(
                                      decoration: TextDecoration.none,
                                    ),
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
                                        child:
                                            BlocBuilder<ChatCubit, ChatState>(
                                          builder: (context, state) {
                                            return InkWell(
                                                onTap: () {
                                                  buildBottomSheet(
                                                      chatId: chatId,
                                                      context: context,
                                                      aesKey: widget.aesKey,
                                                      replyMessage: state
                                                          .replyingToMessage,
                                                      isFromSavedMessage:
                                                          false);

                                                  // context.read<ChatCubit>().getChatMessages(chatId??"", context);
                                                },
                                                child: SvgPicture.asset(
                                                    SvgAssets.icAddRounded));
                                          },
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(50.r),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () async {
                                showMessage("ChatID::::$chatId");

                                if (messageCon.text.trim().isNotEmpty) {
                                  await chatCubit
                                      .sentMessage(context,
                                          mediaType: 0,
                                          mimeType: MimeType.none,
                                          chatId: chatId ?? '',
                                          aesKey: widget.aesKey,
                                          content: messageCon.text.trim(),
                                          replyMessage: state.replyingToMessage
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
                              },
                              child: Container(
                                width: 48.w,
                                height: 48.w,
                                decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    shape: BoxShape.circle),
                                child: Center(
                                    child: SvgImage(source: SvgAssets.icSend)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                } else if ((state.chatMessageModel?.youBlocked ?? false)) {
                  return Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(16.w),
                      color: AppColors.dialogBg,
                      child: Text(S
                          .of(context)
                          .blockedUserCannotSendMessage(widget.userName)));
                } else if ((state.chatMessageModel?.removeFromChat ?? false)) {
                  return Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(16.w),
                      color: AppColors.dialogBg,
                      child: Text(S.of(context).removedUserCannotSendMessage(
                          widget.chatType == ChatType.group
                              ? S.of(context).group
                              : S.of(context).channel)));
                } else if ((state.chatMessageModel?.otherUserRemoveFromChat ??
                    false)) {
                  return Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(16.w),
                      color: AppColors.dialogBg,
                      child:
                          Text(S.of(context).cannotSendMessageToDeletedUser));
                } else if ((state.chatMessageModel?.isBlocked ?? false)) {
                  return Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(16.w),
                      color: AppColors.dialogBg,
                      child: Text(S
                          .of(context)
                          .userBlockedYouSoCannotSendMessage(widget.userName)));
                } else if (!widget.isSendMessage) {
                  return Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(16.w),
                      color: AppColors.dialogBg,
                      child: Text(S.of(context).onlyAdminsCanSendMessages));
                } else {
                  return Container(
                    color: Colors.red,
                  );
                }
              }),
              // SizedBox(height: 16.h),
            ],
          ),
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

  Future<void> showClearChatDialog(BuildContext context) async {
    await showDialog(
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
                                await chatCubit.clearChat(
                                  chatId ?? '',
                                  // context,
                                  callback: (response) {
                                    Utils.showSnackBar(
                                        context, response.message ?? '',
                                        seconds: 3);
                                  },
                                );
                                Navigator.of(context).pop();
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

  void showDraggableBottomSheet(BuildContext context) {
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
                    onTap: () {
                      if (widget.chatType != ChatType.one_to_one &&
                          userData != null) {
                        if (widget.chatType == ChatType.group) {
                          Navigator.pop(context);
                          NavigationService().navigateTo(GroupInfoScreen(
                            groupId: widget.chatId,
                            currentUser: userData!,
                          ));
                        } else if (widget.chatType == ChatType.channel) {
                          Navigator.pop(context);
                          NavigationService().navigateTo(ChannelInfoScreen(
                            groupId: widget.chatId,
                            currentUser: userData!,
                          ));
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
                              widget.chatType == ChatType.group
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
                      await showClearChatDialog(context);
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
                  if (widget.chatType == ChatType.group)
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        // print(
                        //   "disAppearingMessagesTime<><>$disAppearingMessagesTime",
                        // );
                        Navigator.pop(context);
                        showDisappearingMessageTimerSheet(
                          context,
                          disAppearingMessagesTime,
                          (p0) async {
                            // ChatMessageModel
                            // print(chatCubit.state.createConversationModel.d)

                            String senderId = userDataCubit.state?.sId ??
                                (await chatCubit.dbHelper.getLoginData())
                                    ?.sId ??
                                "";
                            showMessage("updateMessageAutoDeleteTime call => ${{
                              "chatId": chatId,
                              "messageAutoDeleteTime": p0,
                              "messageId": DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              "userId": senderId
                            }}");

                            _socketService.sendEvent(
                                AppConstants.updateMessageAutoDeleteTime, {
                              "chatId": chatId,
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

                  if (widget.chatType == ChatType.group)
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Navigator.pop(context);
                        showCommonAlertDialog(
                          context: context,
                          title: widget.chatType == ChatType.group
                              ? S.of(context).leaveGroup
                              : S.of(context).leaveChannel,
                          subTitle: widget.chatType == ChatType.group
                              ? S.of(context).lblLeaveGroupSubTitle
                              : S.of(context).lblLeaveChannelSubTitle,
                          submitBtnText: S.of(context).yes,
                          onSubmit: () =>
                              homeCubit.leaveGroup(context, widget.chatId),
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
                                widget.chatType == ChatType.group
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
                      widget.chatType == ChatType.channel)
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Navigator.pop(context);
                        showCommonAlertDialog(
                          context: context,
                          title: widget.chatType == ChatType.group
                              ? S.of(context).deleteGroup
                              : S.of(context).deleteChannel,
                          subTitle: widget.chatType == ChatType.group
                              ? S.of(context).lblDeleteGroupSubTitle
                              : S.of(context).lblDeleteChannelSubTitle,
                          submitBtnText: S.of(context).delete,
                          onSubmit: () =>
                              homeCubit.deleteGroup(context, widget.chatId),
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
                                widget.chatType == ChatType.group
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
                      widget.chatType == ChatType.group &&
                      ((state.groupData?.participants ?? []).isNotEmpty &&
                          (state.groupData?.participants ?? []).length == 1 &&
                          ((state.groupData?.participants ?? []).first.id ==
                              (userData?.sId ?? ""))))
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Navigator.pop(context);
                        showCommonAlertDialog(
                          context: context,
                          title: widget.chatType == ChatType.group
                              ? S.of(context).deleteGroup
                              : S.of(context).deleteChannel,
                          subTitle: widget.chatType == ChatType.group
                              ? S.of(context).lblDeleteGroupSubTitle
                              : S.of(context).lblDeleteChannelSubTitle,
                          submitBtnText: S.of(context).delete,
                          onSubmit: () =>
                              homeCubit.deleteGroup(context, widget.chatId),
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
                                widget.chatType == ChatType.group
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
}
