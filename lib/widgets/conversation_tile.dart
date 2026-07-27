import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/models/conversation_model.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/screens/chat_screen.dart';
import 'package:two_one_two_messenger/services/api_config.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/conversation_tile/conversation_tile_avatar.dart';
import 'package:two_one_two_messenger/widgets/conversation_tile/conversation_tile_options_sheet.dart';
import 'package:two_one_two_messenger/widgets/conversation_tile/conversation_tile_row.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.isGroup,
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: isGroup ? _buildGroupTile(context) : _buildDirectTile(context),
    );
  }

  String _resolveLastMessageSubtitle() {
    final content = conversationData.lastMessage?.content ?? "";
    return content.isNotEmpty
        ? content
        : conversationData.lastMessage?.systemMessage?.message ?? "";
  }

  Widget _buildGroupTile(BuildContext context) {
    final showImage = (conversationData.groupImage ?? "").isNotEmpty &&
        (conversationData.isGroupProfilePhoto ?? true);

    return ConversationTileRow(
      conversationId: conversationData.id ?? "",
      isArchive: isArchive,
      userId: user.sId ?? "",
      avatar: ConversationTileAvatar(
        imageUrl:
            showImage ? '${Urls.mediaUrl}${conversationData.groupImage ?? ""}' : "",
        fallbackIcon: conversationData.type == ChatType.channel
            ? SvgAssets.megaphone
            : SvgAssets.person2,
      ),
      title: conversationData.groupName ?? "",
      subtitle: _resolveLastMessageSubtitle(),
      unreadCount: conversationData.unreadMessageCount ?? 0,
      lastMessageTimestamp: conversationData.lastMessage?.createdAt,
      showTrailingSpacer: false,
      onLongPress: () => onLongPressConversation(
        context,
        isGroup: true,
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
              unreadMessageCount: conversationData.unreadMessageCount ?? 0,
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
              isShowProfileImage: conversationData.isProfilePhoto ?? true,
            ));
      },
    );
  }

  Widget _buildDirectTile(BuildContext context) {
    if (participantDetails == null) return const SizedBox();

    return ConversationTileRow(
      conversationId: conversationData.id ?? "",
      isArchive: isArchive,
      userId: user.sId ?? "",
      avatar: ConversationTileAvatar(
        imageUrl: participantDetails?.profilePicture != null
            ? '${Urls.mediaUrl}${participantDetails?.profilePicture}'
            : "",
        fallbackIcon: SvgAssets.icPerson,
      ),
      title: AppMethods.getNickNameForParticipateDetails(participantDetails),
      subtitle: _resolveLastMessageSubtitle(),
      unreadCount: conversationData.unreadMessageCount ?? 0,
      lastMessageTimestamp: conversationData.lastMessage?.createdAt,
      showTrailingSpacer: true,
      onLongPress: () => onLongPressConversation(
        context,
        isGroup: false,
        isAddContact: true,
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
              chatType: conversationData.type ?? ChatType.one_to_one,
              unreadMessageCount: conversationData.unreadMessageCount ?? 0,
              aesKey: conversationData.encryptedAESKey ?? "",
              sender: participantDetails,
              userName: participantDetails?.name ?? "",
              userId: participantDetails?.id ?? "",
              userPic: participantDetails?.profilePicture ?? "",
              chatId: conversationData.id ?? '',
              lastMessage: conversationData.lastMessage,
              isSendMessage: conversationData.isSendMessage ?? true,
              restrictContentSharing:
                  conversationData.restrictContentSharing ?? false,
              isShowProfileImage: conversationData.isProfilePhoto ?? true,
            ));
      },
    );
  }
}
