import 'package:two_one_two_messenger/models/conversation_model.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

/// Bundles the chat screen's shared, read-only config so ChatAppBar,
/// ChatMessageList, ChatInputBar, and showDraggableBottomSheet each take one
/// `data:` object instead of repeating the same ten-plus named params.
/// Mutable/identity plumbing (scrollController, messageKeys, messageCon,
/// focusNode) and callbacks stay as separate params — they aren't display
/// data, and bundling them here would blur ownership.
class ChatScreenData {
  final ChatType chatType;
  final String chatId;
  final String? currentChatId;
  final String userId;
  final String userName;
  final String userPic;
  final String aesKey;
  final ParticipantDetail? sender;
  final bool isSendMessage;
  final bool isDeletedUser;
  final bool isShowProfileImage;
  final bool restrictContentSharing;
  final UserData? userData;
  final int disAppearingMessagesTime;
  final String groupMessageString;

  const ChatScreenData({
    required this.chatType,
    required this.chatId,
    required this.currentChatId,
    required this.userId,
    required this.userName,
    required this.userPic,
    required this.aesKey,
    required this.sender,
    required this.isSendMessage,
    required this.isDeletedUser,
    required this.isShowProfileImage,
    required this.restrictContentSharing,
    required this.userData,
    required this.disAppearingMessagesTime,
    required this.groupMessageString,
  });
}
