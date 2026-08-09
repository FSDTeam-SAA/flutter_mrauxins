import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_reactions/flutter_chat_reactions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:two_one_two_messenger/cubit/saved_messages_cubit.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/models/saved_messages.dart';
import 'package:two_one_two_messenger/screens/forward_message_screen.dart';
import 'package:two_one_two_messenger/utils/app_dialoge.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/chat/chat_menu_widgets.dart';
import 'package:two_one_two_messenger/widgets/chat/chat_reactions.dart';
import 'package:two_one_two_messenger/widgets/chat/saved_message_bubble.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';

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
              userId: widget.currentUserId);
        } else {
          context.read<SavedMessagesCubit>().pinSavedMessage(
              messageId: widget.message.messageId ?? "",
              userId: widget.currentUserId);
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

  @override
  Widget build(BuildContext context) {
    final reactionMessageId =
        widget.message.messageId ?? widget.message.id ?? '';
    final bubbleChild = SavedMessageWidget(
        message: widget.message,
        isForDialog: false,
        isSender: widget.isSender,
        onTapScroll: widget.onTapScroll,
        isGroup: widget.isGroup);

    if (!(widget.message.messageDetails?.isSent ?? true)) {
      return bubbleChild;
    }

    chatReactionsController.loadReactions(reactionMessageId,
        synthesizeReactions(widget.message.messageDetails?.reactions));

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
        Icon(Icons.copy, color: AppColors.dark),
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
        color: AppColors.dark,
      ),
    );
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
    if (widget.isSender &&
        (widget.message.messageDetails?.type == 'text' ||
            widget.message.messageDetails?.type == 'mixed')) {
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
      S.current.lblDeleteMessage,
      Icons.delete,
      SvgImage(source: SvgAssets.icTrash, color: AppColors.redColor),
      isDestructive: true,
    );

    return ChatMessageWrapper(
      messageId: reactionMessageId,
      controller: chatReactionsController,
      alignment: widget.isSender ? Alignment.centerRight : Alignment.centerLeft,
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
