import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_reactions/flutter_chat_reactions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:two_one_two_messenger/cubit/saved_messages_cubit.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/chat_message_model.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/screens/forward_message_screen.dart';
import 'package:two_one_two_messenger/utils/app_dialoge.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/chat/chat_menu_widgets.dart';
import 'package:two_one_two_messenger/widgets/chat/chat_reactions.dart';
import 'package:two_one_two_messenger/widgets/chat/message_bubble.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';

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

  @override
  Widget build(BuildContext context) {
    final reactionMessageId =
        widget.message.messageId ?? widget.message.id ?? '';
    final bubbleChild = MessageBubble(
        message: widget.message,
        isSender: widget.isSender,
        isGroup: widget.isGroup,
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

    chatReactionsController.loadReactions(
        reactionMessageId, synthesizeReactions(widget.message.reactions));

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
      SvgImage(source: SvgAssets.icBookmarks, color: AppColors.dark),
    );
    if (!widget.restrictContentSharing &&
        (widget.message.type == 'text' || widget.message.type == 'mixed')) {
      addMenuItem(
        ChatMessageOption.copy,
        S.current.copy,
        Icons.copy,
        Icon(Icons.copy, color: AppColors.dark),
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
        color: AppColors.dark,
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
          child: Icon(Icons.reply_outlined, color: AppColors.dark),
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
              color: AppColors.dark.withValues(alpha: 0.6)),
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
        controller: chatReactionsController,
        alignment:
            widget.isSender ? Alignment.centerRight : Alignment.centerLeft,
        config: ChatReactionsConfig(
          dialogBackgroundColor: AppColors.dark,
          dialogBorderRadius: BorderRadius.circular(12),
          menuItems: menuItemData.keys.toList(),
          customMenuItemBuilder: (item, onTap) {
            final icon = menuItemData[item]?.$2 ?? const SizedBox.shrink();
            return buildChatMenuItemRow(item, icon, onTap);
          },
          emojiPickerBuilder: buildChatEmojiPicker,
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
