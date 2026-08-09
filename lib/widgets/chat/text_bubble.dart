import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/models/chat_message_model.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/custom_linkifire.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/chat/message_header.dart';

class TextBubble extends StatelessWidget {
  const TextBubble({
    super.key,
    required this.message,
    required this.isSender,
    required this.isGroup,
    required this.isForDialog,
    required this.onTapScroll,
    required this.maxWidthFraction,
  });

  final MessageModel message;
  final bool isSender;
  final bool isGroup;
  final bool isForDialog;
  final VoidCallback? onTapScroll;
  final double maxWidthFraction;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: context.w * maxWidthFraction),
      margin: EdgeInsets.symmetric(vertical: 5.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isSender ? AppColors.primaryColor : AppColors.darkInputFill,
        borderRadius: BorderRadius.only(
          topLeft: isSender ? Radius.circular(14.r) : Radius.circular(0.r),
          topRight: Radius.circular(14.r),
          bottomLeft: Radius.circular(14.r),
          bottomRight: isSender ? Radius.circular(0.r) : Radius.circular(14.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MessageHeader(
            message: message,
            isSender: isSender,
            isGroup: isGroup,
            onTapScroll: onTapScroll,
          ),
          Linkify(
            onOpen: Utils.onOpenLink,
            text: message.content ?? '',
            maxLines: isForDialog ? 5 : null,
            linkifiers: [
              CustomLinkifier(),
              UrlLinkifier(),
              EmailLinkifier(),
            ],
            options: LinkifyOptions(humanize: true, removeWww: true),
            linkStyle: AppTextStyles.regular(
              fontSize: 14.sp,
              color: AppColors.purpleText,
            ).copyWith(decoration: TextDecoration.underline),
            style: AppTextStyles.regular(
              fontSize: 14.sp,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
