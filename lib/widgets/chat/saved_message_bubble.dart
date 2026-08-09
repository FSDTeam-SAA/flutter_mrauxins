import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/models/saved_messages.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/widgets/avatar_widgets.dart';
import 'package:two_one_two_messenger/widgets/chat/audio_bubble.dart';
import 'package:two_one_two_messenger/widgets/chat/document_bubble.dart';
import 'package:two_one_two_messenger/widgets/chat/gif_bubble.dart';
import 'package:two_one_two_messenger/widgets/chat/image_bubble.dart';
import 'package:two_one_two_messenger/widgets/chat/message_status_row.dart';
import 'package:two_one_two_messenger/widgets/chat/text_bubble.dart';
import 'package:two_one_two_messenger/widgets/chat/video_bubble.dart';

/// Saved-message bubble content. Successor of the old `SavedMessageWidget`.
/// Saved messages have no upload lifecycle, so unlike [MessageBubble] there
/// is no retry indicator - only a sender-side "Sending.." shimmer.
class SavedMessageWidget extends StatelessWidget {
  const SavedMessageWidget({
    super.key,
    required this.message,
    required this.isSender,
    required this.isGroup,
    required this.isForDialog,
    required this.onTapScroll,
  });

  final SavedMessage message;
  final bool isSender;
  final bool isGroup;
  final bool isForDialog;
  final VoidCallback? onTapScroll;

  @override
  Widget build(BuildContext context) {
    final details = message.messageDetails;
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
                      if ((details?.pinned ?? false) && isSender)
                        Icon(
                          Icons.push_pin,
                          color: AppColors.cardBGColor,
                        ),
                      if (!(details?.isSent ?? true) && isSender)
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
                              if (details?.type == 'text' ||
                                  details?.type == 'mixed')
                                TextBubble(
                                  message: details!,
                                  isSender: isSender,
                                  isGroup: isGroup,
                                  isForDialog: isForDialog,
                                  onTapScroll: onTapScroll,
                                  maxWidthFraction: 0.75,
                                )
                              else if ((details?.type == 'gif') &&
                                  (details?.files != null &&
                                      (details!.files ?? []).isNotEmpty))
                                GifBubble(
                                  message: details,
                                  isSender: isSender,
                                  isGroup: isGroup,
                                  onTapScroll: onTapScroll,
                                  widthFraction: 1.0,
                                )
                              else if ((details?.type == 'image') &&
                                  (details?.files != null &&
                                      details!.files!.isNotEmpty))
                                ImageBubble(
                                  message: details,
                                  isSender: isSender,
                                  isGroup: isGroup,
                                  onTapScroll: onTapScroll,
                                  widthFraction: 1.0,
                                  showUploadProgress: false,
                                  fileSizeFallback: 1000,
                                )
                              else if (details?.type == 'video' &&
                                  details?.files != null &&
                                  details!.files!.isNotEmpty)
                                VideoBubble(
                                  message: details,
                                  isSender: isSender,
                                  isGroup: isGroup,
                                  onTapScroll: onTapScroll,
                                  widthFraction: 1.0,
                                  actionRowSpacer: SizedBox(height: 10.h),
                                  actionRowMainAxisSize: MainAxisSize.max,
                                )
                              else if (details?.type == 'audio' &&
                                  details?.files != null &&
                                  details!.files!.isNotEmpty)
                                AudioBubble(
                                  message: details,
                                  isSender: isSender,
                                  isGroup: isGroup,
                                  onTapScroll: onTapScroll,
                                  maxHeightFraction: 0.5,
                                  useAsymmetricRadius: true,
                                )
                              else if (((details?.type == 'document' ||
                                      details?.type == 'pdf') &&
                                  (details?.files != null &&
                                      details!.files!.isNotEmpty)))
                                DocumentBubble(
                                  message: details,
                                  isSender: isSender,
                                  isGroup: isGroup,
                                  onTapScroll: onTapScroll,
                                  maxWidthFraction: 0.7,
                                )
                            ],
                          ),
                          SavedMessageStatusRow(
                            message: message,
                            isSender: isSender,
                          ),
                        ],
                      ),
                      if ((details?.pinned ?? false) && (!isSender))
                        Icon(
                          Icons.push_pin,
                          color: AppColors.cardBGColor,
                        ),
                    ],
                  ),
                ],
              ),
              if (details?.createdAt != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    DateFormat.jm().format(details?.createdAt ?? DateTime.now()),
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
