import 'dart:io';
import 'dart:math' as math;

import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_reactions/flutter_chat_reactions.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:two_one_two_messenger/cubit/saved_messages_cubit.dart';
import 'package:two_one_two_messenger/database/local_db.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/chat_message_model.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/models/saved_messages.dart';
import 'package:two_one_two_messenger/screens/forward_message_screen.dart';
import 'package:two_one_two_messenger/services/api_config.dart';
import 'package:two_one_two_messenger/utils/app_dialoge.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/custom_linkifire.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/avatar_widgets.dart';
import 'package:two_one_two_messenger/widgets/image_view_page.dart';
import 'package:two_one_two_messenger/widgets/media_upload_progress.dart';
import 'package:two_one_two_messenger/widgets/network_image.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';
import 'package:voice_message_package/voice_message_package.dart';

/// Shared across every message bubble on screen so `StackedReactions` (which
/// reads live from a `ReactionsController`) stays in sync without threading a
/// controller instance through every widget in the chat tree.
final ReactionsController _reactionsController =
    ReactionsController(currentUserId: AppPreference.getCurrentUserId());

/// The backend only tracks per-user reaction attribution server-side; the
/// wire format (and thus [MessageModel.reactions]) is a flat, unattributed
/// list of emoji. These placeholder [Reaction]s exist only so `StackedReactions`
/// can render the current emoji set - `userId` is never matched against the
/// real current user, so `hasUserReacted`/toggle-off never fires, which is
/// fine since the backend has no "remove reaction" capability either.
List<Reaction> _synthesizeReactions(List<String>? emojis) {
  if (emojis == null || emojis.isEmpty) return [];
  final now = DateTime.now();
  return [
    for (var i = 0; i < emojis.length; i++)
      Reaction(emoji: emojis[i], userId: 'unattributed-$i', timestamp: now),
  ];
}

class ChatBubble extends StatefulWidget {
  final MessageModel message;
  final bool isSender;
  final int index;
  final BuildContext mainContext;
  final bool isGroup;
  final bool isShowProfileImage;
  final bool isAccessToMessageUtilities;
  final bool restrictContentSharing;
  final VoidCallback onSwipe;
  final VoidCallback? onTapScroll;
  final String? aesKey;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isSender,
    required this.index,
    required this.mainContext,
    required this.isGroup,
    required this.isShowProfileImage,
    required this.onSwipe,
    required this.onTapScroll,
    this.isAccessToMessageUtilities = true,
    this.restrictContentSharing = false,
    required this.aesKey,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  Offset _lastTapPosition = Offset.zero;

  Future<void> onContextMenuTap(ChatMessageOption option) async {
    showMessage('Menu item: $option');
    final offset = _lastTapPosition;
    switch (option) {
      case ChatMessageOption.saveMessage:
        context.read<SavedMessagesCubit>().saveMessages(
              chatId: widget.message.chatId ?? "",
              context: context,
              isTempMessage: widget.message.id == widget.message.messageId,
              messageId: widget.message.id ?? '',
              callback: (response) {
                Utils.showSnackBar(context, response.message ?? '', seconds: 3);
              },
            );
        break;

      case ChatMessageOption.copy:
        if (widget.restrictContentSharing) return;
        Utils.copyToClipboard(context, widget.message.content ?? "");

        break;
      case ChatMessageOption.edit:
        showEditMessageDialog(context, widget.message, widget.aesKey!);
        break;
      case ChatMessageOption.pin:
        showMessage("TempMessage==> ${widget.message.toJson()}");
        if (widget.message.pinned ?? false) {
          chatCubit.unPinMessage(
              messageId: widget.message.messageId ?? "",
              chatId: widget.message.chatId ?? "");
        } else {
          chatCubit.pinMessage(
              messageId: widget.message.messageId ?? "",
              chatId: widget.message.chatId ?? "");
        }
        break;
      case ChatMessageOption.forward:
        if (widget.restrictContentSharing) return;
        if ((widget.aesKey ?? "").isNotEmpty) {
          showMessage("TempMessage==> ${widget.message.toJson()}");
          UserData? user = await homeCubit.dbHelper.getLoginData();
          NavigationService().navigateTo(ForwardMessageScreen(
              aesKey: widget.aesKey!,
              isFromSavedMessage: false,
              user: user,
              callback: () {},
              message: widget.message));
        }
        break;

      case ChatMessageOption.deleteMessage:
        if (widget.isSender &&
            Utils.canEditOrDeleteMessage(
                widget.message.createdAt ?? DateTime.now())) {
          buildDeleteMessagePopup(
              context: context,
              index: widget.index,
              offset: offset,
              isSender: widget.isSender,
              message: widget.message);
        } else {
          showDeleteMessageDialog(
              context: context,
              index: widget.index,
              message: widget.message,
              deleteForEveryOne: false,
              isFromSavedMessage: false);
        }
        break;
      case ChatMessageOption.reply:
      case ChatMessageOption.react:
        break;
    }
  }

  Widget _buildEmojiPicker(
      BuildContext context, void Function(String) onEmojiSelected) {
    return SizedBox(
      height: 310,
      child: Theme(
        data: ThemeData.dark(),
        child: EmojiPicker(
          onEmojiSelected: (category, emoji) => onEmojiSelected(emoji.emoji),
        ),
      ),
    );
  }

  Widget _buildMenuItemRow(MenuItem item, Widget icon, VoidCallback onTap) {
    final color = item.isDestructive ? AppColors.redColor : AppColors.white;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            IconTheme(data: IconThemeData(color: color), child: icon),
            8.s,
            Text(item.label, style: AppTextStyles.regular(color: color)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reactionMessageId =
        widget.message.messageId ?? widget.message.id ?? '';
    final bubbleChild = MessageWidget(
        message: widget.message,
        isSender: widget.isSender,
        index: widget.index,
        mainContext: widget.mainContext,
        isGroup: widget.isGroup,
        onSwipe: widget.onSwipe,
        isForDialog: false,
        isShowProfileImage: widget.isShowProfileImage,
        onTapScroll: widget.onTapScroll,
        aesKey: widget.aesKey);

    if (widget.message.uploadStatus == MessageUploadStatus.failed ||
        !(widget.message.isSent ?? true)) {
      return GestureDetector(
        onLongPressStart: (details) {
          if (widget.message.uploadStatus == MessageUploadStatus.failed) {
            showDeleteMessageDialog(
                context: context,
                index: widget.index,
                message: widget.message,
                deleteForEveryOne: false,
                isFromSavedMessage: false);
          }
        },
        child: bubbleChild,
      );
    }

    _reactionsController.loadReactions(
        reactionMessageId, _synthesizeReactions(widget.message.reactions));

    final Map<MenuItem, (ChatMessageOption, Widget)> menuItemData = {};
    void addMenuItem(ChatMessageOption option, String label,
        IconData materialIcon, Widget renderedIcon,
        {bool isDestructive = false}) {
      final item = MenuItem(
        label: label,
        icon: materialIcon,
        isDestructive: isDestructive,
      );
      menuItemData[item] = (option, renderedIcon);
    }

    addMenuItem(
      ChatMessageOption.saveMessage,
      S.current.saveMessage,
      Icons.bookmark_outline,
      SvgImage(source: SvgAssets.icBookmarks, color: AppColors.white),
    );
    if (!widget.restrictContentSharing &&
        (widget.message.type == 'text' || widget.message.type == 'mixed')) {
      addMenuItem(
        ChatMessageOption.copy,
        S.current.copy,
        Icons.copy,
        Icon(Icons.copy, color: AppColors.white),
      );
    }
    addMenuItem(
      ChatMessageOption.pin,
      (widget.message.pinned ?? false) ? S.current.unPin : S.current.pin,
      Icons.push_pin,
      Icon(
        (widget.message.pinned ?? false)
            ? CupertinoIcons.pin_slash_fill
            : CupertinoIcons.pin_fill,
        color: AppColors.white,
      ),
    );
    if (widget.aesKey != null && !widget.restrictContentSharing) {
      addMenuItem(
        ChatMessageOption.forward,
        S.current.forward,
        Icons.reply,
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(math.pi),
          child: Icon(Icons.reply_outlined, color: AppColors.white),
        ),
      );
    }
    if (widget.isSender) {
      if ((widget.message.type == 'text' || widget.message.type == 'mixed') &&
          (widget.aesKey ?? "").isNotEmpty &&
          widget.isAccessToMessageUtilities &&
          Utils.canEditOrDeleteMessage(
              widget.message.createdAt ?? DateTime.now(),
              timeLimitInMinutes: 300)) {
        addMenuItem(
          ChatMessageOption.edit,
          S.current.edit,
          Icons.edit,
          SvgImage(
              source: SvgAssets.icEdit,
              color: AppColors.white.withValues(alpha: 0.6)),
        );
      }
      addMenuItem(
        ChatMessageOption.deleteMessage,
        Utils.canEditOrDeleteMessage(widget.message.createdAt ?? DateTime.now())
            ? S.current.lblDeleteMessage
            : S.current.deleteForMe,
        Icons.delete,
        SvgImage(source: SvgAssets.icTrash, color: AppColors.redColor),
        isDestructive: true,
      );
    } else {
      addMenuItem(
        ChatMessageOption.deleteMessage,
        S.current.deleteForMe,
        Icons.delete,
        SvgImage(source: SvgAssets.icTrash, color: AppColors.redColor),
        isDestructive: true,
      );
    }

    return Listener(
      onPointerDown: (event) => _lastTapPosition = event.position,
      child: ChatMessageWrapper(
        messageId: reactionMessageId,
        controller: _reactionsController,
        alignment:
            widget.isSender ? Alignment.centerRight : Alignment.centerLeft,
        config: ChatReactionsConfig(
          dialogBackgroundColor: AppColors.dark,
          dialogBorderRadius: BorderRadius.circular(12),
          menuItems: menuItemData.keys.toList(),
          customMenuItemBuilder: (item, onTap) {
            final icon = menuItemData[item]?.$2 ?? const SizedBox.shrink();
            return _buildMenuItemRow(item, icon, onTap);
          },
          emojiPickerBuilder: _buildEmojiPicker,
        ),
        onReactionAdded: (emoji) {
          showMessage('reaction: $emoji');
          chatCubit.reactMessage(message: widget.message, reaction: emoji);
        },
        onMenuItemTapped: (menuItem) {
          showMessage('menu item: $menuItem');
          final option = menuItemData[menuItem]?.$1;
          if (option != null) onContextMenuTap(option);
        },
        child: bubbleChild,
      ),
    );
  }
}

class MessageWidget extends StatefulWidget {
  MessageModel message;
  final bool isSender;
  final bool isForDialog;
  final int index;
  final BuildContext mainContext;
  final bool isGroup;
  final bool isShowProfileImage;
  final bool isFromSavedMessage;
  final VoidCallback onSwipe;
  final VoidCallback? onTapScroll;
  final String? aesKey;

  MessageWidget({
    super.key,
    required this.message,
    required this.isSender,
    required this.isShowProfileImage,
    required this.isForDialog,
    required this.index,
    required this.mainContext,
    required this.isGroup,
    required this.onSwipe,
    required this.onTapScroll,
    this.isFromSavedMessage = false,
    required this.aesKey,
  });

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.w * 0.9,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment:
            widget.isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: widget.isSender
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!widget.isSender &&
                      widget.isGroup &&
                      widget.isShowProfileImage) ...[
                    AvatarWidgets(
                      userPic: widget.message.sender?.profilePicture ?? "",
                      height: 40.h,
                      width: 40.h,
                    ),
                    10.s
                  ],
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if ((widget.message.pinned ?? false) && widget.isSender)
                        Icon(
                          Icons.push_pin,
                          color: AppColors.cardBGColor,
                        ),
                      if (!(widget.message.isSent ?? true) &&
                          widget.isSender &&
                          widget.message.uploadStatus !=
                              MessageUploadStatus.failed)
                        Shimmer.fromColors(
                          baseColor: AppColors.darkAppBar,
                          highlightColor: AppColors.purpleText,
                          child: Text(
                            "Sending..",
                            style: AppTextStyles.regular(
                                fontSize: 12.sp,
                                color: AppColors.white.withValues(alpha: 0.65)),
                          ),
                        ),
                      if (widget.isSender &&
                          (widget.message.uploadStatus ==
                                  MessageUploadStatus.failed ||
                              (widget.message.uploadStatus ==
                                      MessageUploadStatus.pending &&
                                  widget.message.createdAt != null &&
                                  widget.message.createdAt != null &&
                                  DateTime.now().difference(
                                          widget.message.createdAt!) >
                                      Duration(minutes: 1))))
                        GestureDetector(
                          onTap: () async {
                            // debugPrint(
                            //     "onTap Message==>${widget.message.createdAt!.add(Duration(minutes: 1))} ${widget.message.uploadStatus == MessageUploadStatus.failed || (widget.message.uploadStatus == MessageUploadStatus.pending && widget.message.createdAt != null && DateTime.now().difference(widget.message.createdAt!) > Duration(minutes: 1))}");
                            if (widget.message.uploadStatus ==
                                MessageUploadStatus.failed) {
                              await chatCubit.retryFailedMessage(
                                  context: context,
                                  message: widget.message,
                                  aesKey: widget.aesKey,
                                  from: "chat bubble Failed");
                            } else if (widget.message.uploadStatus ==
                                    MessageUploadStatus.pending &&
                                widget.message.createdAt != null &&
                                widget.message.createdAt != null &&
                                DateTime.now()
                                        .difference(widget.message.createdAt!) >
                                    Duration(minutes: 1)) {
                              await chatCubit.retryFailedMessage(
                                  context: context,
                                  message: widget.message,
                                  from: "chat bubble pending",
                                  aesKey: widget.aesKey);
                            }
                          },
                          child: Icon(
                            Icons.autorenew,
                            color: AppColors.redColor,
                          ),
                        ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            children: [
                              if (widget.message.type == 'text' ||
                                  widget.message.type == 'mixed') ...[
                                Container(
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.65),
                                  margin: EdgeInsets.symmetric(vertical: 5.h),
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: widget.isSender
                                        ? AppColors.primaryColor
                                        : AppColors.darkInputFill,
                                    borderRadius: BorderRadius.only(
                                      topLeft: widget.isSender
                                          ? Radius.circular(14.r)
                                          : Radius.circular(0.r),
                                      topRight: Radius.circular(14.r),
                                      bottomLeft: Radius.circular(14.r),
                                      bottomRight: widget.isSender
                                          ? Radius.circular(0.r)
                                          : Radius.circular(14.r),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (widget.isGroup &&
                                          !widget.isSender) ...[
                                        Text(
                                          AppMethods.getNickName(
                                              widget.message.sender),
                                          // widget.message.sender?.name ?? "",
                                          style: AppTextStyles.regular(
                                              color: AppColors.purpleText),
                                        ),
                                        SizedBox(
                                          height: 5.h,
                                        )
                                      ],
                                      if (widget.message.forwarded ?? false)
                                        ForwardMessageTag(
                                          bgColor: widget.isSender
                                              ? AppColors.primaryColor
                                                  .withAlpha(200)
                                              : AppColors.darkInputFill
                                                  .withAlpha(200),
                                        ),
                                      if (widget.message.isEditedMessage ??
                                          false)
                                        EditedMessageTag(
                                          bgColor: widget.isSender
                                              ? AppColors.primaryColor
                                                  .withAlpha(200)
                                              : AppColors.darkInputFill
                                                  .withAlpha(200),
                                        ),
                                      if (widget.message.replyTo != null)
                                        ReplyMessageView(
                                            onTapScroll: widget.onTapScroll,
                                            bgColor: widget.isSender
                                                ? AppColors.primaryColor
                                                    .withAlpha(200)
                                                : AppColors.darkInputFill
                                                    .withAlpha(200),
                                            isSender: widget.isSender,
                                            message: widget.message.replyTo!),
                                      Linkify(
                                        onOpen: Utils.onOpenLink,
                                        text: widget.message.content ?? '',

                                        maxLines: widget.isForDialog ? 5 : null,
                                        linkifiers: [
                                          CustomLinkifier(),
                                          // DomainLinkifier(),
                                          UrlLinkifier(),
                                          EmailLinkifier()
                                        ],
                                        // enableInteractiveSelection: false,
                                        // selectionControls:
                                        //     MaterialTextSelectionControls(),
                                        options: LinkifyOptions(
                                            humanize: true, removeWww: true),
                                        linkStyle: AppTextStyles.regular(
                                          fontSize: 14.sp,
                                          color: widget.isSender
                                              ? AppColors.purpleText
                                              : AppColors.purpleText,
                                        ).copyWith(
                                            decoration:
                                                TextDecoration.underline),
                                        // softWrap: true,

                                        style: AppTextStyles.regular(
                                          fontSize: 14.sp,
                                          color: widget.isSender
                                              ? AppColors.white
                                              : AppColors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ] else if (((widget.message.type == 'gif') &&
                                  (widget.message.files != null &&
                                      widget.message.files!.isNotEmpty))) ...[
                                Container(
                                  width: context.w * 0.65,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: widget.isSender
                                        ? AppColors.primaryColor
                                        : AppColors.darkInputFill,
                                    borderRadius: BorderRadius.only(
                                      topLeft: widget.isSender
                                          ? Radius.circular(14.r)
                                          : Radius.circular(0.r),
                                      topRight: Radius.circular(14.r),
                                      bottomLeft: Radius.circular(14.r),
                                      bottomRight: widget.isSender
                                          ? Radius.circular(0.r)
                                          : Radius.circular(14.r),
                                    ),
                                  ),
                                  constraints: BoxConstraints(
                                      maxWidth: context.w * 0.75,
                                      maxHeight: context.h * 0.5),
                                  margin: EdgeInsets.symmetric(vertical: 5.h),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (widget.isGroup &&
                                          !widget.isSender) ...[
                                        Text(
                                          // widget.message.sender?.name ?? "",
                                          AppMethods.getNickName(
                                              widget.message.sender),

                                          style: AppTextStyles.regular(
                                              color: AppColors.purpleText),
                                        ),
                                        SizedBox(
                                          height: 5.h,
                                        )
                                      ],
                                      if (widget.message.forwarded ?? false)
                                        ForwardMessageTag(
                                          bgColor: widget.isSender
                                              ? AppColors.primaryColor
                                                  .withAlpha(200)
                                              : AppColors.darkInputFill
                                                  .withAlpha(200),
                                        ),
                                      if (widget.message.isEditedMessage ??
                                          false)
                                        EditedMessageTag(
                                          bgColor: widget.isSender
                                              ? AppColors.primaryColor
                                                  .withAlpha(200)
                                              : AppColors.darkInputFill
                                                  .withAlpha(200),
                                        ),
                                      if (widget.message.replyTo != null)
                                        ReplyMessageView(
                                            onTapScroll: widget.onTapScroll,
                                            bgColor: widget.isSender
                                                ? AppColors.primaryColor
                                                    .withAlpha(200)
                                                : AppColors.darkInputFill
                                                    .withAlpha(200),
                                            isSender: widget.isSender,
                                            message: widget.message.replyTo!),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(MaterialPageRoute(
                                              builder: (context) => ImageViewPage(
                                                  title: widget.message.files!
                                                          .first.fileName ??
                                                      'GIF',
                                                  imageFile: null,
                                                  imageUrl: widget.message
                                                          .files!.first.url!
                                                          .startsWith("https:")
                                                      ? '${widget.message.files!.first.url}'
                                                      : '${Urls.mediaUrl}${widget.message.files!.first.url}')));
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 74.h,
                                              height: 74.h,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(9)),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(9),
                                                child: AppNetworkImage(
                                                  key: ValueKey(widget.message
                                                          .files!.first.url ??
                                                      DateTime.now()
                                                          .toIso8601String()),
                                                  fit: BoxFit.cover,
                                                  imageUrl: widget.message
                                                          .files!.first.url!
                                                          .startsWith("https:")
                                                      ? '${widget.message.files!.first.url}'
                                                      : '${Urls.mediaUrl}${widget.message.files!.first.url}',
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10.w,
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${widget.message.files!.first.fileName}",
                                                    style:
                                                        AppTextStyles.regular(
                                                      fontSize: 14.sp,
                                                      color: widget.isSender
                                                          ? AppColors.white
                                                          : AppColors.white,
                                                    ).copyWith(height: 1.36),
                                                  ),
                                                  SizedBox(
                                                    height: 3.h,
                                                  ),
                                                  Text(
                                                    Utils.formatFileSize(widget
                                                            .message
                                                            .files!
                                                            .first
                                                            .fileSize ??
                                                        0),
                                                    style:
                                                        AppTextStyles.regular(
                                                      fontSize: 14.sp,
                                                      color: widget.isSender
                                                          ? AppColors.white
                                                          : AppColors.white,
                                                    ).copyWith(height: 1.36),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ] else if (((widget.message.type == 'image') &&
                                  (widget.message.files != null &&
                                      widget.message.files!.isNotEmpty))) ...[
                                Container(
                                  width: context.w * 0.65,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: widget.isSender
                                        ? AppColors.primaryColor
                                        : AppColors.darkInputFill,
                                    borderRadius: BorderRadius.only(
                                      topLeft: widget.isSender
                                          ? Radius.circular(14.r)
                                          : Radius.circular(0.r),
                                      topRight: Radius.circular(14.r),
                                      bottomLeft: Radius.circular(14.r),
                                      bottomRight: widget.isSender
                                          ? Radius.circular(0.r)
                                          : Radius.circular(14.r),
                                    ),
                                  ),
                                  constraints: BoxConstraints(
                                      maxWidth: context.w * 0.75,
                                      maxHeight: context.h * 0.5),
                                  margin: EdgeInsets.symmetric(vertical: 5.h),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (widget.isGroup &&
                                          !widget.isSender) ...[
                                        Text(
                                          AppMethods.getNickName(
                                              widget.message.sender),
                                          // widget.message.sender?.name ?? "",
                                          style: AppTextStyles.regular(
                                              color: AppColors.purpleText),
                                        ),
                                        SizedBox(
                                          height: 5.h,
                                        )
                                      ],
                                      if (widget.message.forwarded ?? false)
                                        ForwardMessageTag(
                                          bgColor: widget.isSender
                                              ? AppColors.primaryColor
                                                  .withAlpha(200)
                                              : AppColors.darkInputFill
                                                  .withAlpha(200),
                                        ),
                                      if (widget.message.isEditedMessage ??
                                          false)
                                        EditedMessageTag(
                                          bgColor: widget.isSender
                                              ? AppColors.primaryColor
                                                  .withAlpha(200)
                                              : AppColors.darkInputFill
                                                  .withAlpha(200),
                                        ),
                                      if (widget.message.replyTo != null)
                                        ReplyMessageView(
                                            onTapScroll: widget.onTapScroll,
                                            bgColor: widget.isSender
                                                ? AppColors.primaryColor
                                                    .withAlpha(200)
                                                : AppColors.darkInputFill
                                                    .withAlpha(200),
                                            isSender: widget.isSender,
                                            message: widget.message.replyTo!),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ImageViewPage(
                                                          title:
                                                              // widget.message.files!
                                                              //         .first.fileName ??
                                                              S
                                                                  .of(context)
                                                                  .image,
                                                          imageFile: widget
                                                                      .message
                                                                      .files!
                                                                      .first
                                                                      .file !=
                                                                  null
                                                              ? File(widget
                                                                  .message
                                                                  .files!
                                                                  .first
                                                                  .file!
                                                                  .path)
                                                              : null,
                                                          imageUrl: (widget
                                                                          .message
                                                                          .files!
                                                                          .first
                                                                          .url ??
                                                                      "")
                                                                  .isEmpty
                                                              ? ""
                                                              : widget
                                                                      .message
                                                                      .files!
                                                                      .first
                                                                      .url!
                                                                      .startsWith(
                                                                          "https:")
                                                                  ? '${widget.message.files!.first.url}'
                                                                  : '${Urls.mediaUrl}${widget.message.files!.first.url}')));
                                        },
                                        child: Row(
                                          children: [
                                            Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                if (widget.message
                                                        .uploadProgress !=
                                                    null)
                                                  Positioned.fill(
                                                    child:
                                                        CircularMediaUploadProgress(
                                                      width: 74.h,
                                                      height: 74.h,
                                                      progress: widget.message
                                                          .uploadProgress!,
                                                    ),
                                                  ),
                                                Container(
                                                  width: 74.h,
                                                  height: 74.h,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              9)),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            9),
                                                    child: widget.message.files!
                                                                .first.file !=
                                                            null
                                                        ? Image.file(
                                                            File(widget
                                                                .message
                                                                .files!
                                                                .first
                                                                .file!
                                                                .path),
                                                            fit: BoxFit.cover,
                                                          )
                                                        : AppNetworkImage(
                                                            key: ValueKey(widget
                                                                    .message
                                                                    .files!
                                                                    .first
                                                                    .url ??
                                                                DateTime.now()
                                                                    .toIso8601String()),
                                                            fit: BoxFit.cover,
                                                            imageUrl: (widget
                                                                            .message
                                                                            .files!
                                                                            .first
                                                                            .url ??
                                                                        "")
                                                                    .isEmpty
                                                                ? ""
                                                                : (widget.message.files!.first.url ??
                                                                            "")
                                                                        .startsWith(
                                                                            "https:")
                                                                    ? '${widget.message.files!.first.url}'
                                                                    : '${Urls.mediaUrl}${widget.message.files!.first.url}',
                                                          ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 10.w,
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    S.of(context).image,
                                                    // "${widget.message.files!.first.fileName}",
                                                    style:
                                                        AppTextStyles.regular(
                                                      fontSize: 14.sp,
                                                      color: widget.isSender
                                                          ? AppColors.white
                                                          : AppColors.white,
                                                    ).copyWith(height: 1.36),
                                                  ),
                                                  SizedBox(
                                                    height: 3.h,
                                                  ),
                                                  Text(
                                                    Utils.formatFileSize(widget
                                                            .message
                                                            .files!
                                                            .first
                                                            .fileSize ??
                                                        10000),
                                                    style:
                                                        AppTextStyles.regular(
                                                      fontSize: 14.sp,
                                                      color: widget.isSender
                                                          ? AppColors.white
                                                          : AppColors.white,
                                                    ).copyWith(height: 1.36),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ] else if ((widget.message.type == 'video' &&
                                      widget.message.files != null &&
                                      (widget.message.files ?? []).isNotEmpty)
                                  //     &&
                                  // (widget.message.files?.first.url?.endsWith('.mp4') == true ||
                                  //     widget.message.files?.first.url?.endsWith('.mov') ==
                                  //         true ||
                                  //     widget.message.files?.first.url?.endsWith('.avi') ==
                                  //         true)
                                  ) ...[
                                Container(
                                  // width: context.w,
                                  constraints: BoxConstraints(
                                      maxWidth: context.w * 0.75,
                                      maxHeight: context.h * 0.7),
                                  margin: EdgeInsets.symmetric(vertical: 5.h),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: widget.isSender
                                          ? AppColors.primaryColor
                                          : AppColors.darkInputFill,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (widget.isGroup &&
                                          !widget.isSender) ...[
                                        Text(
                                          AppMethods.getNickName(
                                              widget.message.sender),
                                          // widget.message.sender?.name ?? "",
                                          style: AppTextStyles.regular(
                                              color: AppColors.purpleText),
                                        ),
                                        SizedBox(
                                          height: 5.h,
                                        )
                                      ],
                                      if (widget.message.forwarded ?? false)
                                        ForwardMessageTag(
                                          bgColor: widget.isSender
                                              ? AppColors.primaryColor
                                                  .withAlpha(200)
                                              : AppColors.darkInputFill
                                                  .withAlpha(200),
                                        ),
                                      if (widget.message.isEditedMessage ??
                                          false)
                                        EditedMessageTag(
                                          bgColor: widget.isSender
                                              ? AppColors.primaryColor
                                                  .withAlpha(200)
                                              : AppColors.darkInputFill
                                                  .withAlpha(200),
                                        ),
                                      if (widget.message.replyTo != null)
                                        ReplyMessageView(
                                            onTapScroll: widget.onTapScroll,
                                            bgColor: widget.isSender
                                                ? AppColors.primaryColor
                                                    .withAlpha(200)
                                                : AppColors.darkInputFill
                                                    .withAlpha(200),
                                            isSender: widget.isSender,
                                            message: widget.message.replyTo!),
                                      GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          if (widget.message.files
                                                      ?.isNotEmpty !=
                                                  null &&
                                              widget.message.files?.first.url
                                                      ?.isNotEmpty !=
                                                  null) {
                                            EasyLauncher.url(
                                                url:
                                                    '${Urls.mediaUrl}${widget.message.files?.first.url}',
                                                mode: Mode.inAppBrowser);
                                          }
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(S.of(context).video,
                                                style: AppTextStyles.medium(
                                                  color: AppColors.white,
                                                ),
                                                textScaler:
                                                    const TextScaler.linear(
                                                        0.9)),
                                            10.h.s,
                                            SvgImage(
                                              source: SvgAssets.icVideoOutline,
                                              color: AppColors.white,
                                              height: 20.h,
                                              width: 20.w,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ] else if ((widget.message.type == 'audio' &&
                                      widget.message.files != null &&
                                      widget.message.files!.isNotEmpty)
                                  //     &&
                                  // (widget.message.files?.first.url
                                  //             ?.endsWith('.mp3') ==
                                  //         true ||
                                  //     widget.message.files?.first.url
                                  //             ?.endsWith('.aac') ==
                                  //         true)
                                  ) ...[
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 5.h),
                                  constraints: BoxConstraints(
                                      maxWidth: context.w * 0.75,
                                      maxHeight: context.h * 0.7),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: widget.isSender
                                          ? AppColors.primaryColor
                                          : AppColors.darkInputFill,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (widget.isGroup &&
                                          !widget.isSender) ...[
                                        Text(
                                          AppMethods.getNickName(
                                              widget.message.sender),
                                          // widget.message.sender?.name ?? "",
                                          style: AppTextStyles.regular(
                                              color: AppColors.purpleText),
                                        ),
                                        SizedBox(
                                          height: 5.h,
                                        )
                                      ],
                                      if (widget.message.forwarded ?? false)
                                        ForwardMessageTag(
                                          bgColor: widget.isSender
                                              ? AppColors.primaryColor
                                                  .withAlpha(200)
                                              : AppColors.darkInputFill
                                                  .withAlpha(200),
                                        ),
                                      if (widget.message.isEditedMessage ??
                                          false)
                                        EditedMessageTag(
                                          bgColor: widget.isSender
                                              ? AppColors.primaryColor
                                                  .withAlpha(200)
                                              : AppColors.darkInputFill
                                                  .withAlpha(200),
                                        ),
                                      if (widget.message.replyTo != null)
                                        ReplyMessageView(
                                            onTapScroll: widget.onTapScroll,
                                            bgColor: widget.isSender
                                                ? AppColors.primaryColor
                                                    .withAlpha(200)
                                                : AppColors.darkInputFill
                                                    .withAlpha(200),
                                            isSender: widget.isSender,
                                            message: widget.message.replyTo!),
                                      VoiceMessageView(
                                        activeSliderColor:
                                            AppColors.primaryColor,
                                        circlesColor: AppColors.primaryColor,
                                        counterTextStyle: AppTextStyles.regular(
                                            color: AppColors.black,
                                            fontSize: 11),
                                        controller: widget.message.files?.first
                                                    .file !=
                                                null
                                            ? VoiceController(
                                                audioSrc:
                                                    "${widget.message.files?.first.file!.path}",
                                                maxDuration:
                                                    Duration(minutes: 5),
                                                isFile: true,
                                                onComplete: () {},
                                                onPause: () {},
                                                onPlaying: () {})
                                            : VoiceController(
                                                audioSrc:
                                                    "${Urls.mediaUrl}${widget.message.files?.first.url}",
                                                maxDuration:
                                                    Duration(minutes: 5),
                                                isFile: false,
                                                onComplete: () {},
                                                onPause: () {},
                                                onPlaying: () {}),
                                      ),
                                    ],
                                  ),
                                )
                              ] else if (((widget.message.type == 'document' ||
                                      widget.message.type == 'pdf') &&
                                  (widget.message.files != null &&
                                      widget.message.files!.isNotEmpty))) ...[
                                Container(
                                  // width: context.w,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: widget.isSender
                                          ? AppColors.primaryColor
                                          : AppColors.darkInputFill,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (widget.isGroup &&
                                          !widget.isSender) ...[
                                        Text(
                                          AppMethods.getNickName(
                                              widget.message.sender),
                                          // widget.message.sender?.name ?? "",
                                          style: AppTextStyles.regular(
                                              color: AppColors.purpleText),
                                        ),
                                        SizedBox(
                                          height: 5.h,
                                        )
                                      ],
                                      if (widget.message.forwarded ?? false)
                                        ForwardMessageTag(
                                          bgColor: widget.isSender
                                              ? AppColors.primaryColor
                                                  .withAlpha(200)
                                              : AppColors.darkInputFill
                                                  .withAlpha(200),
                                        ),
                                      if (widget.message.isEditedMessage ??
                                          false)
                                        EditedMessageTag(
                                          bgColor: widget.isSender
                                              ? AppColors.primaryColor
                                                  .withAlpha(200)
                                              : AppColors.darkInputFill
                                                  .withAlpha(200),
                                        ),
                                      if (widget.message.replyTo != null)
                                        ReplyMessageView(
                                            onTapScroll: widget.onTapScroll,
                                            bgColor: widget.isSender
                                                ? AppColors.primaryColor
                                                    .withAlpha(200)
                                                : AppColors.darkInputFill
                                                    .withAlpha(200),
                                            isSender: widget.isSender,
                                            message: widget.message.replyTo!),
                                      GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          if (widget.message.files?.first.url
                                                  ?.isNotEmpty !=
                                              null) {
                                            EasyLauncher.url(
                                                url:
                                                    "${Urls.mediaUrl}${widget.message.files?.first.url}",
                                                mode: Mode.inAppBrowser);
                                          }
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(S.of(context).document,
                                                style: AppTextStyles.medium(
                                                  color: AppColors.white,
                                                ),
                                                textScaler:
                                                    const TextScaler.linear(
                                                        0.9)),
                                            SizedBox(width: 20.w),
                                            SvgImage(
                                              source:
                                                  SvgAssets.icDocumentOutline,
                                              color: AppColors.white,
                                              height: 20.h,
                                              width: 20.w,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ]
                            ],
                          ),
                          Positioned(
                            bottom: 0,
                            right: 5,
                            child: Row(
                              children: [
                                if ((widget.message.reactions ?? []).isNotEmpty)
                                  StackedReactions(
                                    messageId: widget.message.messageId ??
                                        widget.message.id ??
                                        '',
                                    controller: _reactionsController,
                                    size: 8,
                                    stackedValue:
                                        4.0, // Value used to calculate the horizontal offset of each reaction
                                  ),
                                4.s,
                                if (widget.isSender &&
                                    widget.message.uploadStatus ==
                                        MessageUploadStatus.sent)
                                  SvgImage(
                                    source: (widget.message.isRead ?? false)
                                        ? SvgAssets.messageDoubleTick
                                        : SvgAssets.messageSingleTick,
                                    // : (widget.message.isSent ?? true)
                                    //     ? SvgAssets.messageSingleTick
                                    //     : SvgAssets.messageSentPendingIcon,
                                    // width: 20,
                                    // height: 20,
                                    fit: BoxFit.cover,
                                  ),
                                if (widget.isSender &&
                                    widget.message.uploadStatus !=
                                        MessageUploadStatus.sent)
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.white),
                                    child: widget.message.uploadStatus ==
                                                MessageUploadStatus.uploading ||
                                            widget.message.uploadStatus ==
                                                MessageUploadStatus.pending
                                        ? Icon(
                                            Icons.access_time,
                                            size: 12,
                                          )
                                        : widget.message.uploadStatus ==
                                                MessageUploadStatus.failed
                                            ? Icon(
                                                Icons.error_outline,
                                                color: Colors.red,
                                                size: 12,
                                              )
                                            : SvgImage(
                                                source:
                                                    (widget.message.isRead ??
                                                            false)
                                                        ? SvgAssets
                                                            .messageDoubleTick
                                                        : SvgAssets
                                                            .messageSingleTick,
                                                // : (widget.message.isSent ?? true)
                                                //     ? SvgAssets.messageSingleTick
                                                //     : SvgAssets.messageSentPendingIcon,
                                                // width: 20,
                                                // height: 20,
                                                fit: BoxFit.cover,
                                              ),
                                  )
                              ],
                            ),
                          ),
                        ],
                      ),
                      if ((widget.message.pinned ?? false) &&
                          (!widget.isSender))
                        Icon(
                          Icons.push_pin,
                          color: AppColors.cardBGColor,
                        ),
                      if (!(widget.message.isSent ?? true) &&
                          (!widget.isSender) &&
                          widget.message.uploadStatus !=
                              MessageUploadStatus.failed)
                        Shimmer.fromColors(
                          baseColor: AppColors.darkAppBar,
                          highlightColor: AppColors.purpleText,
                          child: Text(
                            "Sending..",
                            style: AppTextStyles.regular(
                                fontSize: 12.sp,
                                color: AppColors.white.withValues(alpha: 0.65)),
                          ),
                        ),
                      if (!widget.isSender &&
                          (widget.message.uploadStatus ==
                                  MessageUploadStatus.failed ||
                              (widget.message.uploadStatus ==
                                      MessageUploadStatus.pending &&
                                  widget.message.createdAt != null &&
                                  widget.message.createdAt != null &&
                                  DateTime.now().difference(
                                          widget.message.createdAt!) >
                                      Duration(minutes: 1))))
                        GestureDetector(
                          onTap: () async {
                            // debugPrint(
                            //     "onTap Message==>${widget.message.createdAt!.add(Duration(minutes: 1))} ${widget.message.uploadStatus == MessageUploadStatus.failed || (widget.message.uploadStatus == MessageUploadStatus.pending && widget.message.createdAt != null && DateTime.now().difference(widget.message.createdAt!) > Duration(minutes: 1))}");
                            if (widget.message.uploadStatus ==
                                MessageUploadStatus.failed) {
                              await chatCubit.retryFailedMessage(
                                  context: context,
                                  message: widget.message,
                                  aesKey: widget.aesKey,
                                  from: "chat bubble Failed");
                            } else if (widget.message.uploadStatus ==
                                    MessageUploadStatus.pending &&
                                widget.message.createdAt != null &&
                                widget.message.createdAt != null &&
                                DateTime.now()
                                        .difference(widget.message.createdAt!) >
                                    Duration(minutes: 1)) {
                              await chatCubit.retryFailedMessage(
                                  context: context,
                                  message: widget.message,
                                  from: "chat bubble pending",
                                  aesKey: widget.aesKey);
                            }
                          },
                          child: Icon(
                            Icons.autorenew,
                            color: AppColors.redColor,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              if (widget.message.createdAt != null)
                Align(
                  alignment: widget.isSender
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      DateFormat.jm()
                          .format((widget.message.createdAt ?? DateTime.now())),
                      style: AppTextStyles.regular(
                          fontSize: 12.sp,
                          color: AppColors.white.withValues(alpha: 0.65)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatBubbleForSavedMessage extends StatefulWidget {
  final SavedMessage message;
  final bool isSender;
  final int index;
  final BuildContext mainContext;
  final bool isGroup;
  final String currentUserId;
  final VoidCallback? onTapScroll;
  const ChatBubbleForSavedMessage({
    super.key,
    required this.message,
    required this.isSender,
    required this.index,
    required this.mainContext,
    required this.isGroup,
    required this.currentUserId,
    required this.onTapScroll,
    //  this.isFromSavedMessage=false,
  });

  @override
  State<ChatBubbleForSavedMessage> createState() =>
      _ChatBubbleForSavedMessageState();
}

class _ChatBubbleForSavedMessageState extends State<ChatBubbleForSavedMessage> {
  Future<void> onContextMenuTap(ChatMessageOption option) async {
    showMessage('Menu item: $option');

    switch (option) {
      case ChatMessageOption.copy:
        Utils.copyToClipboard(
            context, widget.message.messageDetails?.content ?? "");

        break;
      case ChatMessageOption.edit:
        showEditSavedMessageDialog(
          context,
          widget.message,
        );
        break;
      case ChatMessageOption.pin:
        showMessage("TempMessage==> ${widget.message.toJson()}");
        if (widget.message.messageDetails?.pinned ?? false) {
          context.read<SavedMessagesCubit>().unPinSavedMessage(
              messageId: widget.message.messageId ?? "",
              userId: widget.currentUserId ?? "");
        } else {
          context.read<SavedMessagesCubit>().pinSavedMessage(
              messageId: widget.message.messageId ?? "",
              userId: widget.currentUserId ?? "");
        }
        break;
      case ChatMessageOption.forward:
        showMessage("TempMessage==> ${widget.message.toJson()}");
        UserData? user = await homeCubit.dbHelper.getLoginData();
        NavigationService().navigateTo(ForwardMessageScreen(
            aesKey: "",
            user: user,
            isFromSavedMessage: true,
            callback: () {},
            message: widget.message.messageDetails!));

        break;

      case ChatMessageOption.deleteMessage:
        showDeleteMessageDialog(
            context: context,
            index: widget.index,
            savedMessage: widget.message,
            message: widget.message.messageDetails,
            deleteForEveryOne: false,
            isFromSavedMessage: true);
        break;
      case ChatMessageOption.reply:
      case ChatMessageOption.react:
      case ChatMessageOption.saveMessage:
        break;
    }
  }

  Widget _buildEmojiPicker(
      BuildContext context, void Function(String) onEmojiSelected) {
    return SizedBox(
      height: 310,
      child: Theme(
        data: ThemeData.dark(),
        child: EmojiPicker(
          onEmojiSelected: (category, emoji) => onEmojiSelected(emoji.emoji),
        ),
      ),
    );
  }

  Widget _buildMenuItemRow(MenuItem item, Widget icon, VoidCallback onTap) {
    final color = item.isDestructive ? AppColors.redColor : AppColors.white;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            IconTheme(data: IconThemeData(color: color), child: icon),
            8.s,
            Text(item.label, style: AppTextStyles.regular(color: color)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reactionMessageId =
        widget.message.messageId ?? widget.message.id ?? '';
    final bubbleChild = SavedMessageWidget(
        message: widget.message,
        isForDialog: false,
        isSender: widget.isSender,
        index: widget.index,
        mainContext: widget.mainContext,
        onTapScroll: widget.onTapScroll,
        isGroup: widget.isGroup);

    if (!(widget.message.messageDetails?.isSent ?? true)) {
      return bubbleChild;
    }

    _reactionsController.loadReactions(reactionMessageId,
        _synthesizeReactions(widget.message.messageDetails?.reactions));

    final Map<MenuItem, (ChatMessageOption, Widget)> menuItemData = {};
    void addMenuItem(ChatMessageOption option, String label,
        IconData materialIcon, Widget renderedIcon,
        {bool isDestructive = false}) {
      final item = MenuItem(
        label: label,
        icon: materialIcon,
        isDestructive: isDestructive,
      );
      menuItemData[item] = (option, renderedIcon);
    }

    if (widget.message.messageDetails?.type == 'text' ||
        widget.message.messageDetails?.type == 'mixed') {
      addMenuItem(
        ChatMessageOption.copy,
        S.current.copy,
        Icons.copy,
        Icon(Icons.copy, color: AppColors.white),
      );
    }
    addMenuItem(
      ChatMessageOption.pin,
      (widget.message.messageDetails?.pinned ?? false)
          ? S.current.unPin
          : S.current.pin,
      Icons.push_pin,
      Icon(
        (widget.message.messageDetails?.pinned ?? false)
            ? CupertinoIcons.pin_slash_fill
            : CupertinoIcons.pin_fill,
        color: AppColors.white,
      ),
    );
    addMenuItem(
      ChatMessageOption.forward,
      S.current.forward,
      Icons.reply,
      Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(math.pi),
        child: Icon(Icons.reply_outlined, color: AppColors.white),
      ),
    );
    if (widget.isSender &&
        (widget.message.messageDetails?.type == 'text' ||
            widget.message.messageDetails?.type == 'mixed')) {
      addMenuItem(
        ChatMessageOption.edit,
        S.current.edit,
        Icons.edit,
        SvgImage(
            source: SvgAssets.icEdit,
            color: AppColors.white.withValues(alpha: 0.6)),
      );
    }
    addMenuItem(
      ChatMessageOption.deleteMessage,
      S.current.lblDeleteMessage,
      Icons.delete,
      SvgImage(source: SvgAssets.icTrash, color: AppColors.redColor),
      isDestructive: true,
    );

    return ChatMessageWrapper(
      messageId: reactionMessageId,
      controller: _reactionsController,
      alignment: widget.isSender ? Alignment.centerRight : Alignment.centerLeft,
      config: ChatReactionsConfig(
        dialogBackgroundColor: AppColors.dark,
        dialogBorderRadius: BorderRadius.circular(12),
        menuItems: menuItemData.keys.toList(),
        customMenuItemBuilder: (item, onTap) {
          final icon = menuItemData[item]?.$2 ?? const SizedBox.shrink();
          return _buildMenuItemRow(item, icon, onTap);
        },
        emojiPickerBuilder: _buildEmojiPicker,
      ),
      onReactionAdded: (emoji) {
        showMessage('reaction: $emoji');
        context
            .read<SavedMessagesCubit>()
            .reactSavedMessage(message: widget.message, reaction: emoji);
      },
      onMenuItemTapped: (menuItem) {
        showMessage('menu item: $menuItem');
        final option = menuItemData[menuItem]?.$1;
        if (option != null) onContextMenuTap(option);
      },
      child: bubbleChild,
    );
  }
}

class SavedMessageWidget extends StatelessWidget {
  final SavedMessage message;
  final bool isSender;
  final int index;
  final BuildContext mainContext;
  final bool isGroup;
  final bool isForDialog;
  // final bool isFromSavedMessage;
  final VoidCallback? onTapScroll;
  const SavedMessageWidget({
    super.key,
    required this.message,
    required this.isSender,
    required this.index,
    required this.mainContext,
    required this.isGroup,
    required this.isForDialog,
    required this.onTapScroll,
    //  this.isFromSavedMessage=false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isSender && isGroup) ...[
                    AvatarWidgets(
                      userPic: message.senderDetails?.profilePicture ?? "",
                      height: 40.h,
                      width: 40.h,
                    ),
                    10.s
                  ],
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if ((message.messageDetails?.pinned ?? false) && isSender)
                        // Icon(
                        //   Icons.push_pin,
                        //   color: AppColors.cardBGColor,
                        // ),
                        if (!(message.messageDetails?.isSent ?? true) &&
                            isSender)
                          Shimmer.fromColors(
                            baseColor: AppColors.darkAppBar,
                            highlightColor: AppColors.purpleText,
                            child: Text(
                              "Sending..",
                              style: AppTextStyles.regular(
                                  fontSize: 12.sp,
                                  color:
                                      AppColors.white.withValues(alpha: 0.65)),
                            ),
                          ),
                      Stack(
                        children: [
                          Column(
                            children: [
                              if (message.messageDetails?.type == 'text' ||
                                  message.messageDetails?.type == 'mixed') ...[
                                Container(
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.75),
                                  margin: EdgeInsets.symmetric(vertical: 5.h),
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: isSender
                                        ? AppColors.primaryColor
                                        : AppColors.darkInputFill,
                                    borderRadius: BorderRadius.only(
                                      topLeft: isSender
                                          ? Radius.circular(14.r)
                                          : Radius.circular(0.r),
                                      topRight: Radius.circular(14.r),
                                      bottomLeft: Radius.circular(14.r),
                                      bottomRight: isSender
                                          ? Radius.circular(0.r)
                                          : Radius.circular(14.r),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (isGroup && !isSender) ...[
                                        Text(
                                          AppMethods.getNickName(message
                                                  .messageDetails?.sender) ??
                                              // message.messageDetails?.sender
                                              //         ?.name ??
                                              "",
                                          style: AppTextStyles.regular(
                                              color: AppColors.purpleText),
                                        ),
                                        SizedBox(
                                          height: 5.h,
                                        )
                                      ],
                                      if (message.messageDetails?.forwarded ??
                                          false)
                                        ForwardMessageTag(
                                          bgColor: isSender
                                              ? AppColors.primaryColor
                                                  .withAlpha(200)
                                              : AppColors.darkInputFill
                                                  .withAlpha(200),
                                        ),
                                      if (message.messageDetails
                                              ?.isEditedMessage ??
                                          false)
                                        EditedMessageTag(
                                          bgColor: isSender
                                              ? AppColors.primaryColor
                                                  .withAlpha(200)
                                              : AppColors.darkInputFill
                                                  .withAlpha(200),
                                        ),
                                      if (message.messageDetails?.replyTo !=
                                          null)
                                        ReplyMessageView(
                                            onTapScroll: onTapScroll,
                                            bgColor: isSender
                                                ? AppColors.primaryColor
                                                    .withAlpha(200)
                                                : AppColors.darkInputFill
                                                    .withAlpha(200),
                                            isSender: isSender,
                                            message: message
                                                .messageDetails!.replyTo!),
                                      Linkify(
                                        onOpen: Utils.onOpenLink,
                                        text: message.messageDetails?.content ??
                                            '',
                                        maxLines: isForDialog ? 5 : null,
                                        linkifiers: [
                                          CustomLinkifier(),
                                          UrlLinkifier(),
                                          EmailLinkifier()
                                        ],
                                        linkStyle: AppTextStyles.regular(
                                          fontSize: 14.sp,
                                          color: AppColors.purpleText,
                                        ).copyWith(
                                            decoration:
                                                TextDecoration.underline),
                                        style: AppTextStyles.regular(
                                          fontSize: 14.sp,
                                          color: isSender
                                              ? AppColors.white
                                              : AppColors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ] else if (((message.messageDetails?.type ==
                                      'gif') &&
                                  (message.messageDetails?.files != null &&
                                      (message.messageDetails!.files ?? [])
                                          .isNotEmpty))) ...[
                                Container(
                                  width: context.w,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isSender
                                        ? AppColors.primaryColor
                                        : AppColors.darkInputFill,
                                    borderRadius: BorderRadius.only(
                                      topLeft: isSender
                                          ? Radius.circular(14.r)
                                          : Radius.circular(0.r),
                                      topRight: Radius.circular(14.r),
                                      bottomLeft: Radius.circular(14.r),
                                      bottomRight: isSender
                                          ? Radius.circular(0.r)
                                          : Radius.circular(14.r),
                                    ),
                                  ),
                                  constraints: BoxConstraints(
                                      maxWidth: context.w * 0.75,
                                      maxHeight: context.h * 0.5),
                                  margin: EdgeInsets.symmetric(vertical: 5.h),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (isGroup && !isSender) ...[
                                        Text(
                                          AppMethods.getNickName(message
                                                  .messageDetails?.sender) ??
                                              // message.messageDetails?.sender
                                              //         ?.name ??
                                              "",
                                          style: AppTextStyles.regular(
                                              color: AppColors.purpleText),
                                        ),
                                        SizedBox(
                                          height: 5.h,
                                        )
                                      ],
                                      if (message.messageDetails?.forwarded ??
                                          false)
                                        ForwardMessageTag(
                                          bgColor: isSender
                                              ? AppColors.primaryColor
                                                  .withAlpha(200)
                                              : AppColors.darkInputFill
                                                  .withAlpha(200),
                                        ),
                                      if (message.messageDetails
                                              ?.isEditedMessage ??
                                          false)
                                        EditedMessageTag(
                                          bgColor: isSender
                                              ? AppColors.primaryColor
                                                  .withAlpha(200)
                                              : AppColors.darkInputFill
                                                  .withAlpha(200),
                                        ),
                                      if (message.messageDetails?.replyTo !=
                                          null)
                                        ReplyMessageView(
                                            onTapScroll: onTapScroll,
                                            bgColor: isSender
                                                ? AppColors.primaryColor
                                                    .withAlpha(200)
                                                : AppColors.darkInputFill
                                                    .withAlpha(200),
                                            isSender: isSender,
                                            message: message
                                                .messageDetails!.replyTo!),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ImageViewPage(
                                                          title: message
                                                                  .messageDetails
                                                                  ?.files!
                                                                  .first
                                                                  .fileName ??
                                                              'GIF',
                                                          imageUrl: (message
                                                                          .messageDetails!
                                                                          .files!
                                                                          .first
                                                                          .url ??
                                                                      "")
                                                                  .isEmpty
                                                              ? ""
                                                              : message
                                                                      .messageDetails!
                                                                      .files!
                                                                      .first
                                                                      .url!
                                                                      .startsWith(
                                                                          "https:")
                                                                  ? '${message.messageDetails?.files!.first.url}'
                                                                  : '${Urls.mediaUrl}${message.messageDetails?.files!.first.url}')));
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 74.h,
                                              height: 74.h,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(9)),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(9),
                                                child: AppNetworkImage(
                                                  key: ValueKey(message
                                                          .messageDetails!
                                                          .files!
                                                          .first
                                                          .url ??
                                                      DateTime.now()
                                                          .toIso8601String()),
                                                  fit: BoxFit.cover,
                                                  imageUrl: (message
                                                                  .messageDetails!
                                                                  .files!
                                                                  .first
                                                                  .url ??
                                                              "")
                                                          .isEmpty
                                                      ? ""
                                                      : message.messageDetails!
                                                              .files!.first.url!
                                                              .startsWith(
                                                                  "https:")
                                                          ? '${message.messageDetails?.files!.first.url}'
                                                          : '${Urls.mediaUrl}${message.messageDetails?.files!.first.url}',
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10.w,
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${message.messageDetails?.files!.first.fileName}",
                                                    style:
                                                        AppTextStyles.regular(
                                                      fontSize: 14.sp,
                                                      color: isSender
                                                          ? AppColors.white
                                                          : AppColors.white,
                                                    ).copyWith(height: 1.36),
                                                  ),
                                                  SizedBox(
                                                    height: 3.h,
                                                  ),
                                                  Text(
                                                    Utils.formatFileSize(message
                                                            .messageDetails
                                                            ?.files!
                                                            .first
                                                            .fileSize ??
                                                        0),
                                                    style:
                                                        AppTextStyles.regular(
                                                      fontSize: 14.sp,
                                                      color: isSender
                                                          ? AppColors.white
                                                          : AppColors.white,
                                                    ).copyWith(height: 1.36),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ] else if (((message.messageDetails?.type ==
                                          'image') &&
                                      (message.messageDetails?.files != null &&
                                          message.messageDetails!.files!
                                              .isNotEmpty))
                                  //  &&
                                  //     (message.messageDetails?.files?.first.url?.endsWith('.png') == true ||
                                  //         message.messageDetails?.files?.first.url?.endsWith('.jpg') ==
                                  //             true ||
                                  //         message.messageDetails?.files?.first.url?.endsWith('.jpeg') ==
                                  //             true)
                                  ) ...[
                                Container(
                                  width: context.w,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isSender
                                        ? AppColors.primaryColor
                                        : AppColors.darkInputFill,
                                    borderRadius: BorderRadius.only(
                                      topLeft: isSender
                                          ? Radius.circular(14.r)
                                          : Radius.circular(0.r),
                                      topRight: Radius.circular(14.r),
                                      bottomLeft: Radius.circular(14.r),
                                      bottomRight: isSender
                                          ? Radius.circular(0.r)
                                          : Radius.circular(14.r),
                                    ),
                                  ),
                                  constraints: BoxConstraints(
                                      maxWidth: context.w * 0.75,
                                      maxHeight: context.h * 0.5),
                                  margin: EdgeInsets.symmetric(vertical: 5.h),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (isGroup && !isSender) ...[
                                        Text(
                                          message.messageDetails?.sender
                                                  ?.name ??
                                              "",
                                          style: AppTextStyles.regular(
                                              color: AppColors.purpleText),
                                        ),
                                        SizedBox(
                                          height: 5.h,
                                        )
                                      ],
                                      if (message.messageDetails?.forwarded ??
                                          false)
                                        ForwardMessageTag(
                                          bgColor: isSender
                                              ? AppColors.primaryColor
                                                  .withAlpha(200)
                                              : AppColors.darkInputFill
                                                  .withAlpha(200),
                                        ),
                                      if (message.messageDetails
                                              ?.isEditedMessage ??
                                          false)
                                        EditedMessageTag(
                                          bgColor: isSender
                                              ? AppColors.primaryColor
                                                  .withAlpha(200)
                                              : AppColors.darkInputFill
                                                  .withAlpha(200),
                                        ),
                                      if (message.messageDetails?.replyTo !=
                                          null)
                                        ReplyMessageView(
                                            onTapScroll: onTapScroll,
                                            bgColor: isSender
                                                ? AppColors.primaryColor
                                                    .withAlpha(200)
                                                : AppColors.darkInputFill
                                                    .withAlpha(200),
                                            isSender: isSender,
                                            message: message
                                                .messageDetails!.replyTo!),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ImageViewPage(
                                                          title:
                                                              //  message
                                                              //         .messageDetails
                                                              //         ?.files!
                                                              //         .first
                                                              //         .fileName ??
                                                              S
                                                                  .of(context)
                                                                  .image,
                                                          imageFile: message
                                                                      .messageDetails!
                                                                      .files!
                                                                      .first
                                                                      .file !=
                                                                  null
                                                              ? File(message
                                                                  .messageDetails!
                                                                  .files!
                                                                  .first
                                                                  .file!
                                                                  .path)
                                                              : null,
                                                          imageUrl: message
                                                                  .messageDetails!
                                                                  .files!
                                                                  .first
                                                                  .url!
                                                                  .startsWith(
                                                                      "https:")
                                                              ? '${message.messageDetails?.files!.first.url}'
                                                              : '${Urls.mediaUrl}${message.messageDetails?.files!.first.url}')));
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 74.h,
                                              height: 74.h,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(9)),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(9),
                                                child: message
                                                            .messageDetails!
                                                            .files!
                                                            .first
                                                            .file !=
                                                        null
                                                    ? Image.file(
                                                        File(message
                                                            .messageDetails!
                                                            .files!
                                                            .first
                                                            .file!
                                                            .path),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : AppNetworkImage(
                                                        key: ValueKey(message
                                                                .messageDetails!
                                                                .files!
                                                                .first
                                                                .url ??
                                                            DateTime.now()
                                                                .toIso8601String()),
                                                        fit: BoxFit.cover,
                                                        imageUrl: message
                                                                .messageDetails!
                                                                .files!
                                                                .first
                                                                .url!
                                                                .startsWith(
                                                                    "https:")
                                                            ? '${message.messageDetails?.files!.first.url}'
                                                            : '${Urls.mediaUrl}${message.messageDetails?.files!.first.url}',
                                                      ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10.w,
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    S.of(context).image,
                                                    // "${message.messageDetails?.files!.first.fileName ?? "Image"}",
                                                    style:
                                                        AppTextStyles.regular(
                                                      fontSize: 14.sp,
                                                      color: isSender
                                                          ? AppColors.white
                                                          : AppColors.white,
                                                    ).copyWith(height: 1.36),
                                                  ),
                                                  SizedBox(
                                                    height: 3.h,
                                                  ),
                                                  Text(
                                                    Utils.formatFileSize(message
                                                            .messageDetails
                                                            ?.files!
                                                            .first
                                                            .fileSize ??
                                                        1000),
                                                    style:
                                                        AppTextStyles.regular(
                                                      fontSize: 14.sp,
                                                      color: isSender
                                                          ? AppColors.white
                                                          : AppColors.white,
                                                    ).copyWith(height: 1.36),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ] else if ((message.messageDetails?.type ==
                                          'video' &&
                                      message.messageDetails?.files != null &&
                                      message.messageDetails!.files!.isNotEmpty)
                                  // &&
                                  //     (message.messageDetails?.files?.first.url?.endsWith('.mp4') == true ||
                                  //         message.messageDetails?.files?.first.url?.endsWith('.mov') ==
                                  //             true ||
                                  //         message.messageDetails?.files?.first.url?.endsWith('.avi') ==
                                  //             true)
                                  ) ...[
                                Container(
                                  width: context.w,
                                  constraints: BoxConstraints(
                                      maxWidth: context.w * 0.75,
                                      maxHeight: context.h * 0.7),
                                  margin: EdgeInsets.symmetric(vertical: 5.h),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: isSender
                                          ? AppColors.primaryColor
                                          : AppColors.darkInputFill,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (isGroup && !isSender) ...[
                                        Text(
                                          message.messageDetails?.sender
                                                  ?.name ??
                                              "",
                                          style: AppTextStyles.regular(
                                              color: AppColors.purpleText),
                                        ),
                                        SizedBox(
                                          height: 5.h,
                                        )
                                      ],
                                      if (message.messageDetails?.forwarded ??
                                          false)
                                        ForwardMessageTag(
                                          bgColor: isSender
                                              ? AppColors.primaryColor
                                                  .withAlpha(200)
                                              : AppColors.darkInputFill
                                                  .withAlpha(200),
                                        ),
                                      if (message.messageDetails
                                              ?.isEditedMessage ??
                                          false)
                                        EditedMessageTag(
                                          bgColor: isSender
                                              ? AppColors.primaryColor
                                                  .withAlpha(200)
                                              : AppColors.darkInputFill
                                                  .withAlpha(200),
                                        ),
                                      if (message.messageDetails?.replyTo !=
                                          null)
                                        ReplyMessageView(
                                            onTapScroll: onTapScroll,
                                            bgColor: isSender
                                                ? AppColors.primaryColor
                                                    .withAlpha(200)
                                                : AppColors.darkInputFill
                                                    .withAlpha(200),
                                            isSender: isSender,
                                            message: message
                                                .messageDetails!.replyTo!),
                                      GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          if (message.messageDetails?.files
                                                      ?.isNotEmpty !=
                                                  null &&
                                              message.messageDetails?.files
                                                      ?.first.url?.isNotEmpty !=
                                                  null) {
                                            EasyLauncher.url(
                                                url:
                                                    '${Urls.mediaUrl}${message.messageDetails?.files?.first.url}',
                                                mode: Mode.inAppBrowser);
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(S.of(context).video,
                                                style: AppTextStyles.medium(
                                                  color: AppColors.white,
                                                ),
                                                textScaler:
                                                    const TextScaler.linear(
                                                        0.9)),
                                            SizedBox(height: 10.h),
                                            SvgImage(
                                              source: SvgAssets.icVideoOutline,
                                              color: AppColors.white,
                                              height: 20.h,
                                              width: 20.w,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ] else if ((message.messageDetails?.type ==
                                          'audio' &&
                                      message.messageDetails?.files != null &&
                                      message.messageDetails!.files!.isNotEmpty)
                                  // &&
                                  //     (message.messageDetails?.files?.first.url?.endsWith('.mp3') == true ||
                                  //         message.messageDetails?.files?.first.url?.endsWith('.aac') ==
                                  //             true)
                                  ) ...[
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 5.h),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isSender
                                        ? AppColors.primaryColor
                                        : AppColors.darkInputFill,
                                    borderRadius: BorderRadius.only(
                                      topLeft: isSender
                                          ? Radius.circular(14.r)
                                          : Radius.circular(0.r),
                                      topRight: Radius.circular(14.r),
                                      bottomLeft: Radius.circular(14.r),
                                      bottomRight: isSender
                                          ? Radius.circular(0.r)
                                          : Radius.circular(14.r),
                                    ),
                                  ),
                                  constraints: BoxConstraints(
                                      maxWidth: context.w * 0.75,
                                      maxHeight: context.h * 0.5),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (isGroup && !isSender) ...[
                                        Text(
                                          message.messageDetails?.sender
                                                  ?.name ??
                                              "",
                                          style: AppTextStyles.regular(
                                              color: AppColors.purpleText),
                                        ),
                                        SizedBox(
                                          height: 5.h,
                                        )
                                      ],
                                      if (message.messageDetails?.forwarded ??
                                          false)
                                        ForwardMessageTag(
                                          bgColor: isSender
                                              ? AppColors.primaryColor
                                                  .withAlpha(200)
                                              : AppColors.darkInputFill
                                                  .withAlpha(200),
                                        ),
                                      if (message.messageDetails
                                              ?.isEditedMessage ??
                                          false)
                                        EditedMessageTag(
                                          bgColor: isSender
                                              ? AppColors.primaryColor
                                                  .withAlpha(200)
                                              : AppColors.darkInputFill
                                                  .withAlpha(200),
                                        ),
                                      if (message.messageDetails?.replyTo !=
                                          null)
                                        ReplyMessageView(
                                            onTapScroll: onTapScroll,
                                            bgColor: isSender
                                                ? AppColors.primaryColor
                                                    .withAlpha(200)
                                                : AppColors.darkInputFill
                                                    .withAlpha(200),
                                            isSender: isSender,
                                            message: message
                                                .messageDetails!.replyTo!),
                                      VoiceMessageView(
                                        activeSliderColor:
                                            AppColors.primaryColor,
                                        circlesColor: AppColors.primaryColor,
                                        counterTextStyle: AppTextStyles.regular(
                                            color: AppColors.black,
                                            fontSize: 11),
                                        controller: message.messageDetails
                                                    ?.files?.first.file !=
                                                null
                                            ? VoiceController(
                                                audioSrc:
                                                    "${message.messageDetails?.files?.first.file?.path}",
                                                maxDuration:
                                                    Duration(minutes: 5),
                                                isFile: true,
                                                onComplete: () {},
                                                onPause: () {},
                                                onPlaying: () {})
                                            : VoiceController(
                                                audioSrc:
                                                    "${Urls.mediaUrl}${message.messageDetails?.files?.first.url}",
                                                maxDuration:
                                                    Duration(minutes: 5),
                                                isFile: false,
                                                onComplete: () {},
                                                onPause: () {},
                                                onPlaying: () {}),
                                      ),
                                    ],
                                  ),
                                )
                              ] else if (((message.messageDetails?.type ==
                                              'document' ||
                                          message.messageDetails?.type ==
                                              'pdf') &&
                                      (message.messageDetails?.files != null &&
                                          message.messageDetails!.files!
                                              .isNotEmpty))
                                  //             &&
                                  // (message.messageDetails?.files?.first.url
                                  //             ?.endsWith('.pdf') ==
                                  //         true ||
                                  //     message.messageDetails?.files?.first.url
                                  //             ?.endsWith('.doc') ==
                                  //         true ||
                                  //     message.messageDetails?.files?.first.url
                                  //             ?.endsWith('.docx') ==
                                  //         true)
                                  ) ...[
                                Container(
                                  // width: context.w,
                                  constraints:
                                      BoxConstraints(maxWidth: context.w * 0.7),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: isSender
                                          ? AppColors.primaryColor
                                          : AppColors.darkInputFill,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (isGroup && !isSender) ...[
                                        Text(
                                          message.messageDetails?.sender
                                                  ?.name ??
                                              "",
                                          style: AppTextStyles.regular(
                                              color: AppColors.purpleText),
                                        ),
                                        SizedBox(
                                          height: 5.h,
                                        )
                                      ],
                                      if (message.messageDetails?.forwarded ??
                                          false)
                                        ForwardMessageTag(
                                          bgColor: isSender
                                              ? AppColors.primaryColor
                                                  .withAlpha(200)
                                              : AppColors.darkInputFill
                                                  .withAlpha(200),
                                        ),
                                      if (message.messageDetails
                                              ?.isEditedMessage ??
                                          false)
                                        EditedMessageTag(
                                          bgColor: isSender
                                              ? AppColors.primaryColor
                                                  .withAlpha(200)
                                              : AppColors.darkInputFill
                                                  .withAlpha(200),
                                        ),
                                      if (message.messageDetails?.replyTo !=
                                          null)
                                        ReplyMessageView(
                                            onTapScroll: onTapScroll,
                                            bgColor: isSender
                                                ? AppColors.primaryColor
                                                    .withAlpha(200)
                                                : AppColors.darkInputFill
                                                    .withAlpha(200),
                                            isSender: isSender,
                                            message: message
                                                .messageDetails!.replyTo!),
                                      GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          if (message.messageDetails?.files
                                                  ?.first.url?.isNotEmpty !=
                                              null) {
                                            EasyLauncher.url(
                                                url:
                                                    "${Urls.mediaUrl}${message.messageDetails?.files?.first.url}",
                                                mode: Mode.inAppBrowser);
                                          }
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(S.of(context).document,
                                                style: AppTextStyles.medium(
                                                  color: AppColors.white,
                                                ),
                                                textScaler:
                                                    const TextScaler.linear(
                                                        0.9)),
                                            SizedBox(width: 20.w),
                                            SvgImage(
                                              source:
                                                  SvgAssets.icDocumentOutline,
                                              color: AppColors.white,
                                              height: 20.h,
                                              width: 20.w,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ]
                            ],
                          ),
                          Positioned(
                            bottom: 0,
                            right: 5,
                            child: Row(
                              children: [
                                if ((message.messageDetails?.reactions ?? [])
                                    .isNotEmpty)
                                  StackedReactions(
                                    messageId:
                                        message.messageId ?? message.id ?? '',
                                    controller: _reactionsController,
                                    size: 8,
                                    stackedValue:
                                        4.0, // Value used to calculate the horizontal offset of each reaction
                                  ),
                                4.s,
                                if (isSender)
                                  SvgImage(
                                    source:
                                        // (message.messageDetails?.isRead ?? false)?
                                        SvgAssets.messageDoubleTick
                                    // : SvgAssets.messageSingleTick
                                    ,
                                    // width: 20,
                                    // height: 20,
                                    fit: BoxFit.cover,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if ((message.messageDetails?.pinned ?? false) &&
                          (!isSender))
                        Icon(
                          Icons.push_pin,
                          color: AppColors.cardBGColor,
                        ),
                      // if (message.messageDetails?.createdAt != null &&
                      //     (!isSender))
                      //   Column(
                      //     mainAxisAlignment: MainAxisAlignment.end,
                      //     children: [
                      //       Padding(
                      //         padding:
                      //             const EdgeInsets.symmetric(horizontal: 4.0),
                      //         child: Text(
                      //           DateFormat.jm().format(
                      //               message.messageDetails?.createdAt ??
                      //                   DateTime.now()),
                      //           style: AppTextStyles.regular(
                      //               fontSize: 12.sp,
                      //               color: AppColors.white.withValues(alpha:0.65)),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                    ],
                  ),
                ],
              ),
              if (message.messageDetails?.createdAt != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    DateFormat.jm().format(
                        message.messageDetails?.createdAt ?? DateTime.now()),
                    style: AppTextStyles.regular(
                        fontSize: 12.sp,
                        color: AppColors.white.withValues(alpha: 0.65)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReplyMessageView extends StatelessWidget {
  const ReplyMessageView({
    super.key,
    required this.message,
    required this.isSender,
    required this.onTapScroll,
    this.bgColor,
  });
  final MessageModel message;
  final Color? bgColor;
  final bool isSender;

  final VoidCallback? onTapScroll;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTapScroll,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: EdgeInsets.symmetric(vertical: 5.h).copyWith(top: 0),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: bgColor ?? AppColors.darkInputFill,
          border: Border(
              left: BorderSide(
                  width: 3,
                  color:
                      isSender ? AppColors.greenColor : AppColors.purpleText)),
          borderRadius: BorderRadius.all(Radius.circular(14.r)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.45,
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75),
                    child: Text(
                      // isSender ? S.of(context).you : message.sender?.name ?? "",
                      isSender
                          ? S.of(context).you
                          : AppMethods.getNickName(message.sender),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: AppTextStyles.medium(
                          color: isSender
                              ? AppColors.greenColor
                              : AppColors.purpleText),
                    ),
                  ),
                  Linkify(
                    onOpen: Utils.onOpenLink,
                    text: message.content ?? "",
                    maxLines: 5,
                    linkifiers: [
                      CustomLinkifier(),
                      UrlLinkifier(),
                      EmailLinkifier()
                    ],
                    // maxLines: 1,
                    // overflow: TextOverflow.ellipsis,
                    linkStyle: AppTextStyles.regular(
                      fontSize: 14.sp,
                      color: AppColors.purpleText,
                    ).copyWith(decoration: TextDecoration.underline),
                    // softWrap: true,
                    style:
                        AppTextStyles.regular(color: AppColors.textColorHint),
                  ),
                ],
              ),
            ),
            8.s,
            if (((message.type == 'image') &&
                    (message.files != null && (message.files ?? []).isNotEmpty))
                //      &&
                // (message.files?.first.url?.endsWith('.png') == true ||
                //     message.files?.first.url?.endsWith('.jpg') == true ||
                //     message.files?.first.url?.endsWith('.jpeg') == true)
                )
              Container(
                width: 40.h,
                height: 40.h,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(9)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: AppNetworkImage(
                    key: ValueKey(message.files!.first.url ??
                        DateTime.now().toIso8601String()),
                    fit: BoxFit.cover,
                    imageUrl: '${Urls.mediaUrl}${message.files!.first.url}',
                  ),
                ),
              ),
            if (((message.type == 'gif') &&
                (message.files != null && (message.files ?? []).isNotEmpty)))
              Container(
                width: 40.h,
                height: 40.h,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(9)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: AppNetworkImage(
                    key: ValueKey(message.files!.first.url ??
                        DateTime.now().toIso8601String()),
                    fit: BoxFit.cover,
                    imageUrl: message.files!.first.url!.startsWith("https:")
                        ? '${message.files!.first.url}'
                        : '${Urls.mediaUrl}${message.files!.first.url}',
                  ),
                ),
              )
            else if ((message.type == 'video' &&
                    message.files != null &&
                    (message.files ?? []).isNotEmpty)
                //     &&
                // (message.files?.first.url?.endsWith('.mp4') == true ||
                //     message.files?.first.url?.endsWith('.mov') == true ||
                //     message.files?.first.url?.endsWith('.avi') == true)
                )
              SvgImage(
                source: SvgAssets.icVideoOutline,
                color: AppColors.white,
                height: 20.h,
                width: 20.w,
              )
            else if ((message.type == 'audio' &&
                    message.files != null &&
                    (message.files ?? []).isNotEmpty) &&
                (message.files?.first.url?.endsWith('.mp3') == true ||
                    message.files?.first.url?.endsWith('.aac') == true))
              SvgImage(
                source: SvgAssets.icMicrophone,
                color: AppColors.white,
                height: 20.h,
                width: 20.w,
              )
            else if (((message.type == 'document' || message.type == 'pdf') &&
                    (message.files != null && (message.files ?? []).isNotEmpty))
                //     &&
                // (message.files?.first.url?.endsWith('.pdf') == true ||
                //     message.files?.first.url?.endsWith('.doc') == true ||
                //     message.files?.first.url?.endsWith('.docx') == true)
                )
              SvgImage(
                source: SvgAssets.icDocumentOutline,
                color: AppColors.white,
                height: 20.h,
                width: 20.w,
              ),
          ],
        ),
      ),
    );
  }
}

class EditedMessageTag extends StatelessWidget {
  const EditedMessageTag({super.key, required this.bgColor});
  final Color bgColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      padding: EdgeInsets.all(0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.edit_attributes,
            color: AppColors.white,
          ),
          8.s,
          Text(
            S.of(context).edited,
            style: AppTextStyles.regular(color: AppColors.purpleText),
          )
        ],
      ),
    );
  }
}

class ForwardMessageTag extends StatelessWidget {
  const ForwardMessageTag({super.key, required this.bgColor});
  final Color bgColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      padding: EdgeInsets.all(0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(math.pi),
            child: Icon(
              Icons.reply_outlined,
              color: AppColors.white,
            ),
          ),
          8.s,
          Text(
            S.of(context).forward,
            style: AppTextStyles.regular(color: AppColors.purpleText),
          )
        ],
      ),
    );
  }
}

class ForwadedMessageView extends StatelessWidget {
  const ForwadedMessageView({
    super.key,
    required this.message,
    // required this.isSender,
    // required this.onTapScroll,
    this.bgColor,
  });
  final MessageModel message;
  final Color? bgColor;
  // final bool isSender;
  // final VoidCallback? onTapScroll;
  @override
  Widget build(BuildContext context) {
    return Container(
      // constraints:
      //     BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      // margin: EdgeInsets.symmetric(vertical: 5.h).copyWith(top: 0),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: bgColor ?? AppColors.darkInputFill,
        // border: Border(
        //     left: BorderSide(
        //         width: 3,
        //         color:
        //             isSender ? AppColors.greenColor : AppColors.purpleText)),
        borderRadius: BorderRadius.all(Radius.circular(14.r)),
      ),
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        children: [
          if (((message.type == 'image') &&
                  (message.files != null && (message.files ?? []).isNotEmpty))
              //     &&
              // (message.files?.first.url?.endsWith('.png') == true ||
              //     message.files?.first.url?.endsWith('.jpg') == true ||
              //     message.files?.first.url?.endsWith('.jpeg') == true)
              )
            Container(
              width: 40.h,
              height: 40.h,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(9)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: AppNetworkImage(
                  key: ValueKey(message.files!.first.url ??
                      DateTime.now().toIso8601String()),
                  fit: BoxFit.cover,
                  imageUrl: '${Urls.mediaUrl}${message.files!.first.url}',
                ),
              ),
            ),
          if (((message.type == 'gif') &&
              (message.files != null && (message.files ?? []).isNotEmpty)))
            Container(
              width: 40.h,
              height: 40.h,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(9)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: AppNetworkImage(
                  key: ValueKey(message.files!.first.url ??
                      DateTime.now().toIso8601String()),
                  fit: BoxFit.cover,
                  imageUrl: (message.files?.first.url ?? "").isEmpty
                      ? ""
                      : message.files!.first.url!.startsWith("https:")
                          ? '${message.files!.first.url}'
                          : '${Urls.mediaUrl}${message.files!.first.url}',
                ),
              ),
            )
          else if ((message.type == 'video' &&
                  message.files != null &&
                  (message.files ?? []).isNotEmpty)
              //     &&
              // (message.files?.first.url?.endsWith('.mp4') == true ||
              //     message.files?.first.url?.endsWith('.mov') == true ||
              //     message.files?.first.url?.endsWith('.avi') == true)
              )
            SvgImage(
              source: SvgAssets.icVideoOutline,
              color: AppColors.white,
              height: 20.h,
              width: 20.w,
            )
          else if ((message.type == 'audio' &&
                  message.files != null &&
                  (message.files ?? []).isNotEmpty)
              //     &&
              // (message.files?.first.url?.endsWith('.mp3') == true ||
              //     message.files?.first.url?.endsWith('.aac') == true)
              )
            SvgImage(
              source: SvgAssets.icMicrophone,
              color: AppColors.white,
              height: 20.h,
              width: 20.w,
            )
          else if (((message.type == 'document' || message.type == 'pdf') &&
                  (message.files != null && (message.files ?? []).isNotEmpty))
              //      &&
              // (message.files?.first.url?.endsWith('.pdf') == true ||
              //     message.files?.first.url?.endsWith('.doc') == true ||
              //     message.files?.first.url?.endsWith('.docx') == true)
              )
            SvgImage(
              source: SvgAssets.icDocumentOutline,
              color: AppColors.white,
              height: 20.h,
              width: 20.w,
            ),
          8.s,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Linkify(
                onOpen: Utils.onOpenLink,
                text: message.content ?? "",
                maxLines: 5,
                linkifiers: [
                  CustomLinkifier(),
                  UrlLinkifier(),
                  EmailLinkifier()
                ],
                linkStyle: AppTextStyles.regular(
                  fontSize: 14.sp,
                  color: AppColors.purpleText,
                ).copyWith(decoration: TextDecoration.underline),
                // softWrap: true,
                style: AppTextStyles.regular(color: AppColors.textColorHint),
              ),
            ),
          ),
          //  Expanded(
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text(
          //         S.of(context).forwardTo,
          //         style: AppTextStyles.regular(),
          //       ),
          //       Padding(
          //         padding: const EdgeInsets.symmetric(vertical: 8.0),
          //         child: Text(
          //           message.content ?? "",
          //           softWrap: true,
          //           style:
          //               AppTextStyles.regular(color: AppColors.textColorHint),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
