import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/conversation_model.dart';
import 'package:two_one_two_messenger/screens/chat/chat_app_bar.dart';
import 'package:two_one_two_messenger/screens/chat/chat_input_bar.dart';
import 'package:two_one_two_messenger/screens/chat/chat_message_list.dart';
import 'package:two_one_two_messenger/screens/chat/chat_screen_data.dart';
import 'package:two_one_two_messenger/services/screen_protection_service.dart';
import 'package:two_one_two_messenger/services/socket_service.dart';

import '../cubit/chat_cubit.dart';
import '../cubit/typing_cubit.dart';
import '../cubit/user_data_cubit.dart';
import '../models/chat_message_model.dart';
import '../models/otp_verify.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/utils.dart';
import '../widgets/keyboard_safe_scaffold.dart';

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
  final bool restrictContentSharing;
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
    this.restrictContentSharing = false,
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

  // Live copy of widget.restrictContentSharing: admins can change the group
  // setting from the info screen while this chat is open beneath it.
  bool _restrictContentSharing = false;

  // The creator can still copy/forward/screenshot their own content even
  // while Restrict Content Sharing is on for everyone else.
  bool get _isChatCreator =>
      widget.createdBy != null && userData?.sId == widget.createdBy?.id;

  bool get _effectiveRestrictContentSharing =>
      _restrictContentSharing && !_isChatCreator;

  // True only when isSendMessage just flipped to false via the live socket
  // push (not on fresh screen entry) — drives which "can't send" notice
  // ChatInputBar shows. Reset whenever the screen re-syncs from a fetch.
  bool _permissionJustRevokedLive = false;

  final scrollController = ScrollController();
  final _scrollController = AutoScrollController(
    axis: Axis.vertical,
    // suggestedRowHeight: 200,
  );
  final SocketService _socketService = SocketService();
  late final TypingCubit _typingCubit;

  int disAppearingMessagesTime = 0;

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
    // A fresh call (retryCount == 0) is what the various tap handlers issue;
    // an in-progress highlight should ignore a second tap. Internal retries
    // (retryCount > 0) are this same operation continuing and must not be
    // blocked by the flag they themselves set below.
    if (retryCount == 0 && _isHighlightingMessage) return;
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

        final updatedList = (chatCubit.state.chatList ?? <dynamic>{}).toList();
        return onHighlightMessage(
          message,
          updatedList as List<MessageModel>,
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
    _typingCubit = context.read<TypingCubit>();
    _restrictContentSharing = widget.restrictContentSharing;
    showMessage("initState called${DateTime.now()} ${widget.chatId} ");
    init();
  }

  @override
  void dispose() {
    if (_effectiveRestrictContentSharing) {
      ScreenProtectionService.instance.disable();
    }
    disposeAllEvents();
    messageCon.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    showMessage("dispose called ${DateTime.now()} ${widget.chatId} ");

    super.dispose();
  }

  // Called when returning from the group/channel info screen, where an admin
  // may have changed Restrict Content Sharing (HomeCubit holds the value the
  // info screen loaded/edited).
  void _syncRestrictContentSharing(bool latest) {
    if (!mounted || latest == _restrictContentSharing) return;
    setState(() => _restrictContentSharing = latest);
    if (_effectiveRestrictContentSharing) {
      ScreenProtectionService.instance.enable();
    } else {
      ScreenProtectionService.instance.disable();
    }
  }

  void _onNickNameStatusChanged(bool newStatus) {
    setState(() {
      widget.sender?.isActiveNickname = newStatus;
    });
  }

  void _onNickNameChanged(
      {required String? newNickName, required bool? newStatus}) {
    setState(() {
      widget.sender?.nickName = newNickName;
      widget.sender?.isActiveNickname = newStatus;
    });
  }

  Future<void> init() async {
    try {
      _focusNode.addListener(_handleFocusChange);
      if (_effectiveRestrictContentSharing) {
        ScreenProtectionService.instance.enable();
      }
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
        _typingCubit.clearTypingList();
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
                groupCubit.state.groupData?.isSendMessage ?? true;
          });
        }
      }
    });
    _socketService.onAssignOrRemoveFromAdminToGroup((data) {
      log(":: onAssignOrRemoveFromAdminToGroup==> $data ${widget.userId} ${mounted && chatCubit.chatId == data["chatId"]}");
      if (widget.chatType == ChatType.group) {
        if (mounted && chatCubit.chatId == data["chatId"]) {
          if (!(groupCubit.state.groupData?.isSendMessage ?? true)) {
            setState(() {
              widget.isSendMessage = data["isAdmin"];
              log(":: onAssignOrRemoveFromAdminToGroup111111==> $data ${widget.isSendMessage} ");
            });
          }
        }
      }
    });
    _socketService.onGroupSendPermissionUpdated((data) {
      if (widget.chatType != ChatType.one_to_one &&
          mounted &&
          chatCubit.chatId == data["chatId"]) {
        final updated = data["isSendMessage"] ?? true;
        setState(() {
          widget.isSendMessage = updated;
          _permissionJustRevokedLive = !updated;
        });
      }
    });
    // Safety net for a missed/dropped permission-update event (e.g. socket
    // briefly disconnected while an admin toggled the setting): whenever the
    // socket (re)connects, re-fetch the group's current isSendMessage so a
    // stale input-bar state self-heals instead of requiring leave/re-enter.
    _socketService.onConnectionChange = _onSocketConnectionChange;
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
    _typingCubit.clearTypingList();
    _socketService.onUserTyping(
        // AppConstants.receivedTypingStatus,
        (data) {
      TypingModel newTypingModel = TypingModel.fromJson(data);
      showMessage(
          ":: USER Is Typing ${widget.chatId} ${newTypingModel.chatId == widget.chatId} $data");
      if (newTypingModel.chatId == widget.chatId) {
        _typingCubit.updateTypingList(newTypingModel);
      }
    });
  }

  void _onSocketConnectionChange(bool connected) {
    if (connected) _reconcileSendPermission();
  }

  Future<void> _reconcileSendPermission() async {
    if (!mounted ||
        widget.chatType == ChatType.one_to_one ||
        widget.chatId.isEmpty) {
      return;
    }
    await groupCubit.getGroupInfobyId(context, widget.chatId,
        isLoaderVisible: false);
    if (!mounted) return;
    final latest = groupCubit.state.groupData?.isSendMessage;
    // A reconciliation fetch reflects whatever is currently persisted, not
    // an event that "just happened" — always show the generic notice for it.
    if (latest != null && latest != widget.isSendMessage) {
      setState(() {
        widget.isSendMessage = latest;
        _permissionJustRevokedLive = false;
      });
    }
  }

  void disposeAllEvents() {
    if (identical(_socketService.onConnectionChange, _onSocketConnectionChange)) {
      _socketService.onConnectionChange = null;
    }
    _socketService.off(AppConstants.updateMessageStatus);
    _socketService.off(AppConstants.socketUserOnline);
    _socketService.off(AppConstants.userBlockedyou);
    _socketService.off(AppConstants.removeFromGroup);
    _socketService.off(AppConstants.addtoGroupGroup);
    _socketService.off(AppConstants.onAssignOrRemoveFromAdminToGroup);
    _socketService.off(AppConstants.groupSendPermissionUpdated);
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
        groupCubit.cleanGroupDataInfo();
      }
    }

    if (widget.chatId.isEmpty && (widget.chatType == ChatType.one_to_one)) {
      await chatCubit.createConversation(widget.userId, context).then(
            (value) {},
          );
      chatId = chatCubit.state.currentConversationId;
      final newChatId = chatCubit.state.currentConversationId ?? "";
      final newAesKey =
          chatCubit.state.createConversationModel?.encryptedAESKey ?? "";
      if (mounted) {
        setState(() {
          widget.chatId = newChatId;
          widget.aesKey = newAesKey;
        });
      } else {
        widget.chatId = newChatId;
        widget.aesKey = newAesKey;
      }
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
    } else if ((chatCubit.state.chatList ?? <dynamic>{}).isNotEmpty) {
      log("chatid lastmessage==> ${chatCubit.state.chatList!.first.toJson()}");
      // emitMessageReadStatus(true, chatCubit.state.chatMessageModel!.messages!.last.messageId ?? "");
    }

    if (widget.chatType != ChatType.one_to_one && userData != null) {
      if (widget.chatType == ChatType.group ||
          widget.chatType == ChatType.channel) {
        groupCubit.getGroupInfobyId(context, widget.chatId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatData = ChatScreenData(
      chatType: widget.chatType,
      chatId: widget.chatId,
      currentChatId: chatId,
      userId: widget.userId,
      userName: widget.userName,
      userPic: widget.userPic,
      aesKey: widget.aesKey,
      sender: widget.sender,
      isSendMessage: widget.isSendMessage,
      permissionJustRevokedLive: _permissionJustRevokedLive,
      isDeletedUser: widget.isDeletedUser,
      isShowProfileImage: widget.isShowProfileImage,
      restrictContentSharing: _effectiveRestrictContentSharing,
      userData: userData,
      disAppearingMessagesTime: disAppearingMessagesTime,
      groupMessageString: groupMessageString,
    );
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
      child: KeyboardSafeScaffold(
        backgroundColor: AppColors.scaffoldBgDark,
        appBar: ChatAppBar(
          data: chatData,
          onNickNameStatusChanged: _onNickNameStatusChanged,
          onNickNameChanged: _onNickNameChanged,
          onRestrictContentSharingChanged: _syncRestrictContentSharing,
        ),
        body: Column(
          children: [
            Expanded(
              child: RepaintBoundary(
                child: ChatMessageList(
                  data: chatData,
                  messageKeys: messageKeys,
                  highlightedMessageId: highlightedMessageId,
                  scrollController: _scrollController,
                  onHighlightMessage: onHighlightMessage,
                  onMessageListChanged: (list) => messageList = list,
                  onDisappearingMessagesTimeChanged: (time) =>
                      disAppearingMessagesTime = time,
                  onRefresh: () => getMessages(widget.chatId, widget.aesKey),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: ChatInputBar(
                data: chatData,
                messageCon: messageCon,
                focusNode: _focusNode,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
