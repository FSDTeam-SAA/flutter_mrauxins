import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/chat_message_model.dart';
import 'package:two_one_two_messenger/services/api_config.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/chat/message_header.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';

class DocumentBubble extends StatelessWidget {
  const DocumentBubble({
    super.key,
    required this.message,
    required this.isSender,
    required this.isGroup,
    required this.onTapScroll,
    required this.maxWidthFraction,
  });

  final MessageModel message;
  final bool isSender;
  final bool isGroup;
  final VoidCallback? onTapScroll;

  /// null on the live-chat variant (unbounded width); 0.7 on the
  /// saved-message variant.
  final double? maxWidthFraction;

  @override
  Widget build(BuildContext context) {
    final file = message.files?.first;
    return Container(
      constraints: maxWidthFraction == null
          ? null
          : BoxConstraints(maxWidth: context.w * maxWidthFraction!),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: isSender ? AppColors.primaryColor : AppColors.darkInputFill,
          borderRadius: BorderRadius.circular(10)),
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
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (message.files?.first.url?.isNotEmpty != null) {
                EasyLauncher.url(
                    url: "${Urls.mediaUrl}${file?.url}",
                    mode: Mode.inAppBrowser);
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(S.of(context).document,
                    style: AppTextStyles.medium(
                      color: AppColors.white,
                    ),
                    textScaler: const TextScaler.linear(0.9)),
                SizedBox(width: 20.w),
                SvgImage(
                  source: SvgAssets.icDocumentOutline,
                  color: AppColors.white,
                  height: 20.h,
                  width: 20.w,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
