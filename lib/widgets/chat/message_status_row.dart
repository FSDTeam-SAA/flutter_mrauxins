import 'package:flutter/material.dart';
import 'package:flutter_chat_reactions/flutter_chat_reactions.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/models/chat_message_model.dart';
import 'package:two_one_two_messenger/models/saved_messages.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/widgets/chat/chat_reactions.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';

/// Reactions + full upload-state tick indicator for live chat: pending
/// (clock), failed (error), or sent (single/double tick based on read state).
class LiveMessageStatusRow extends StatelessWidget {
  const LiveMessageStatusRow({
    super.key,
    required this.message,
    required this.isSender,
  });

  final MessageModel message;
  final bool isSender;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 5,
      child: Row(
        children: [
          if ((message.reactions ?? []).isNotEmpty)
            StackedReactions(
              messageId: message.messageId ?? message.id ?? '',
              controller: chatReactionsController,
              size: 8,
              stackedValue: 4.0,
            ),
          4.s,
          if (isSender && message.uploadStatus == MessageUploadStatus.sent)
            SvgImage(
              source: (message.isRead ?? false)
                  ? SvgAssets.messageDoubleTick
                  : SvgAssets.messageSingleTick,
              fit: BoxFit.cover,
            ),
          if (isSender && message.uploadStatus != MessageUploadStatus.sent)
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.white),
              child: message.uploadStatus == MessageUploadStatus.uploading ||
                      message.uploadStatus == MessageUploadStatus.pending
                  ? Icon(
                      Icons.access_time,
                      size: 12,
                    )
                  : message.uploadStatus == MessageUploadStatus.failed
                      ? Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 12,
                        )
                      : SvgImage(
                          source: (message.isRead ?? false)
                              ? SvgAssets.messageDoubleTick
                              : SvgAssets.messageSingleTick,
                          fit: BoxFit.cover,
                        ),
            )
        ],
      ),
    );
  }
}

/// Reactions + simplified always-double-tick indicator for saved messages,
/// which have no upload lifecycle.
class SavedMessageStatusRow extends StatelessWidget {
  const SavedMessageStatusRow({
    super.key,
    required this.message,
    required this.isSender,
  });

  final SavedMessage message;
  final bool isSender;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 5,
      child: Row(
        children: [
          if ((message.messageDetails?.reactions ?? []).isNotEmpty)
            StackedReactions(
              messageId: message.messageId ?? message.id ?? '',
              controller: chatReactionsController,
              size: 8,
              stackedValue: 4.0,
            ),
          4.s,
          if (isSender)
            SvgImage(
              source: SvgAssets.messageDoubleTick,
              fit: BoxFit.cover,
            ),
        ],
      ),
    );
  }
}
