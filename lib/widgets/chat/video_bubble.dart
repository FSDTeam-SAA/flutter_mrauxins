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

class VideoBubble extends StatelessWidget {
  const VideoBubble({
    super.key,
    required this.message,
    required this.isSender,
    required this.isGroup,
    required this.onTapScroll,
    required this.widthFraction,
    required this.actionRowSpacer,
    required this.actionRowMainAxisSize,
  });

  final MessageModel message;
  final bool isSender;
  final bool isGroup;
  final VoidCallback? onTapScroll;

  /// null on the live-chat variant (no fixed width, sizes to content up to
  /// the maxWidth constraint); 1.0 on the saved-message variant (full width).
  final double? widthFraction;

  /// Live chat uses `10.h.s` (a real Gap, spaces the row's main axis).
  /// Saved messages use `SizedBox(height: 10.h)` (no horizontal effect in a
  /// Row) - a pre-existing inconsistency, reproduced verbatim rather than
  /// silently corrected.
  final Widget actionRowSpacer;
  final MainAxisSize actionRowMainAxisSize;

  @override
  Widget build(BuildContext context) {
    final file = message.files?.first;
    return Container(
      width: widthFraction == null ? null : context.w * widthFraction!,
      constraints:
          BoxConstraints(maxWidth: context.w * 0.75, maxHeight: context.h * 0.7),
      margin: EdgeInsets.symmetric(vertical: 5.h),
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
              if (message.files?.isNotEmpty != null &&
                  message.files?.first.url?.isNotEmpty != null) {
                EasyLauncher.url(
                    url: '${Urls.mediaUrl}${file?.url}',
                    mode: Mode.inAppBrowser);
              }
            },
            child: Row(
              mainAxisSize: actionRowMainAxisSize,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(S.of(context).video,
                    style: AppTextStyles.medium(
                      color: AppColors.white,
                    ),
                    textScaler: const TextScaler.linear(0.9)),
                actionRowSpacer,
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
    );
  }
}
