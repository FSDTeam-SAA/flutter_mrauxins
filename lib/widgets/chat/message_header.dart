import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/models/chat_message_model.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/chat/message_tags.dart';
import 'package:two_one_two_messenger/widgets/reply_message_view.dart';

/// The nickname/forwarded/edited/reply-preview block shown at the top of
/// every message-type bubble. Identical for every message type, so each
/// per-type bubble renders this once instead of repeating it inline.
class MessageHeader extends StatelessWidget {
  const MessageHeader({
    super.key,
    required this.message,
    required this.isSender,
    required this.isGroup,
    required this.onTapScroll,
  });

  final MessageModel? message;
  final bool isSender;
  final bool isGroup;
  final VoidCallback? onTapScroll;

  @override
  Widget build(BuildContext context) {
    final bgColor = isSender
        ? AppColors.primaryColor.withAlpha(200)
        : AppColors.darkInputFill.withAlpha(200);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isGroup && !isSender) ...[
          Text(
            AppMethods.getNickName(message?.sender),
            style: AppTextStyles.regular(color: AppColors.purpleText),
          ),
          SizedBox(height: 5.h),
        ],
        if (message?.forwarded ?? false) ForwardMessageTag(bgColor: bgColor),
        if (message?.isEditedMessage ?? false)
          EditedMessageTag(bgColor: bgColor),
        if (message?.replyTo != null)
          ReplyMessageView(
            onTapScroll: onTapScroll,
            bgColor: bgColor,
            isSender: isSender,
            message: message!.replyTo!,
          ),
      ],
    );
  }
}
