import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/models/chat_message_model.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/avatar_widgets.dart';
import 'package:two_one_two_messenger/widgets/chat/audio_bubble.dart';
import 'package:two_one_two_messenger/widgets/chat/document_bubble.dart';
import 'package:two_one_two_messenger/widgets/chat/gif_bubble.dart';
import 'package:two_one_two_messenger/widgets/chat/image_bubble.dart';
import 'package:two_one_two_messenger/widgets/chat/message_status_row.dart';
import 'package:two_one_two_messenger/widgets/chat/sending_retry_indicator.dart';
import 'package:two_one_two_messenger/widgets/chat/text_bubble.dart';
import 'package:two_one_two_messenger/widgets/chat/video_bubble.dart';

/// Live-chat message bubble content: avatar, pin icon, sending/retry
/// indicator, the type-specific bubble body, and the timestamp. Successor of
/// the old `MessageWidget` - carried no mutable state, so this is a plain
/// StatelessWidget rather than a State-backed one.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isSender,
    required this.isShowProfileImage,
    required this.isForDialog,
    required this.isGroup,
    required this.onTapScroll,
    required this.aesKey,
  });

  final MessageModel message;
  final bool isSender;
  final bool isForDialog;
  final bool isGroup;
  final bool isShowProfileImage;
  final VoidCallback? onTapScroll;
  final String? aesKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.w * 0.9,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isSender && isGroup && isShowProfileImage) ...[
                    AvatarWidgets(
                      userPic: message.sender?.profilePicture ?? "",
                      height: 40.h,
                      width: 40.h,
                    ),
                    10.s
                  ],
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if ((message.pinned ?? false) && isSender)
                        Icon(
                          Icons.push_pin,
                          color: AppColors.cardBGColor,
                        ),
                      SendingOrRetryIndicator(
                        message: message,
                        active: isSender,
                        aesKey: aesKey,
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            children: [
                              if (message.type == 'text' ||
                                  message.type == 'mixed')
                                TextBubble(
                                  message: message,
                                  isSender: isSender,
                                  isGroup: isGroup,
                                  isForDialog: isForDialog,
                                  onTapScroll: onTapScroll,
                                  maxWidthFraction: 0.65,
                                )
                              else if ((message.type == 'gif') &&
                                  (message.files != null &&
                                      message.files!.isNotEmpty))
                                GifBubble(
                                  message: message,
                                  isSender: isSender,
                                  isGroup: isGroup,
                                  onTapScroll: onTapScroll,
                                  widthFraction: 0.65,
                                )
                              else if ((message.type == 'image') &&
                                  (message.files != null &&
                                      message.files!.isNotEmpty))
                                ImageBubble(
                                  message: message,
                                  isSender: isSender,
                                  isGroup: isGroup,
                                  onTapScroll: onTapScroll,
                                  widthFraction: 0.65,
                                  showUploadProgress: true,
                                  fileSizeFallback: 10000,
                                )
                              else if (message.type == 'video' &&
                                  message.files != null &&
                                  (message.files ?? []).isNotEmpty)
                                VideoBubble(
                                  message: message,
                                  isSender: isSender,
                                  isGroup: isGroup,
                                  onTapScroll: onTapScroll,
                                  widthFraction: null,
                                  actionRowSpacer: 10.h.s,
                                  actionRowMainAxisSize: MainAxisSize.min,
                                )
                              else if (message.type == 'audio' &&
                                  message.files != null &&
                                  message.files!.isNotEmpty)
                                AudioBubble(
                                  message: message,
                                  isSender: isSender,
                                  isGroup: isGroup,
                                  onTapScroll: onTapScroll,
                                  maxHeightFraction: 0.7,
                                  useAsymmetricRadius: false,
                                )
                              else if (((message.type == 'document' ||
                                      message.type == 'pdf') &&
                                  (message.files != null &&
                                      message.files!.isNotEmpty)))
                                DocumentBubble(
                                  message: message,
                                  isSender: isSender,
                                  isGroup: isGroup,
                                  onTapScroll: onTapScroll,
                                  maxWidthFraction: null,
                                )
                            ],
                          ),
                          LiveMessageStatusRow(
                            message: message,
                            isSender: isSender,
                          ),
                        ],
                      ),
                      if ((message.pinned ?? false) && (!isSender))
                        Icon(
                          Icons.push_pin,
                          color: AppColors.cardBGColor,
                        ),
                      SendingOrRetryIndicator(
                        message: message,
                        active: !isSender,
                        aesKey: aesKey,
                      ),
                    ],
                  ),
                ],
              ),
              if (message.createdAt != null)
                Align(
                  alignment:
                      isSender ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      DateFormat.jm().format((message.createdAt ?? DateTime.now())),
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
