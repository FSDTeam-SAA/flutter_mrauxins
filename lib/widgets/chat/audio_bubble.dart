import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/models/chat_message_model.dart';
import 'package:two_one_two_messenger/services/api_config.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/chat/message_header.dart';
import 'package:voice_message_package/voice_message_package.dart';

class AudioBubble extends StatelessWidget {
  const AudioBubble({
    super.key,
    required this.message,
    required this.isSender,
    required this.isGroup,
    required this.onTapScroll,
    required this.maxHeightFraction,
    required this.useAsymmetricRadius,
  });

  final MessageModel message;
  final bool isSender;
  final bool isGroup;
  final VoidCallback? onTapScroll;

  /// 0.7 on the live-chat variant, 0.5 on the saved-message variant.
  final double maxHeightFraction;

  /// Live chat uses BorderRadius.circular(10) here; saved messages use the
  /// asymmetric per-corner radius every other bubble type uses. A
  /// pre-existing inconsistency, reproduced verbatim.
  final bool useAsymmetricRadius;

  @override
  Widget build(BuildContext context) {
    final file = message.files?.first;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.h),
      constraints: BoxConstraints(
          maxWidth: context.w * 0.75, maxHeight: context.h * maxHeightFraction),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isSender ? AppColors.primaryColor : AppColors.darkInputFill,
        borderRadius: useAsymmetricRadius
            ? BorderRadius.only(
                topLeft: isSender ? Radius.circular(14.r) : Radius.circular(0.r),
                topRight: Radius.circular(14.r),
                bottomLeft: Radius.circular(14.r),
                bottomRight:
                    isSender ? Radius.circular(0.r) : Radius.circular(14.r),
              )
            : BorderRadius.circular(10),
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
          VoiceMessageView(
            activeSliderColor: AppColors.primaryColor,
            circlesColor: AppColors.primaryColor,
            counterTextStyle:
                AppTextStyles.regular(color: AppColors.black, fontSize: 11),
            controller: file?.file != null
                ? VoiceController(
                    audioSrc: "${file?.file!.path}",
                    maxDuration: Duration(minutes: 5),
                    isFile: true,
                    onComplete: () {},
                    onPause: () {},
                    onPlaying: () {})
                : VoiceController(
                    audioSrc: "${Urls.mediaUrl}${file?.url}",
                    maxDuration: Duration(minutes: 5),
                    isFile: false,
                    onComplete: () {},
                    onPause: () {},
                    onPlaying: () {}),
          ),
        ],
      ),
    );
  }
}
