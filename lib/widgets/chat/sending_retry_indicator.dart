import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/models/chat_message_model.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';

/// The sender-side "Sending.." shimmer + failed/stuck-pending retry icon,
/// shown once for the sender's side of the bubble and once (mirrored via
/// [active]) for the receiver's side. Live chat only - saved messages have
/// no upload lifecycle.
class SendingOrRetryIndicator extends StatelessWidget {
  const SendingOrRetryIndicator({
    super.key,
    required this.message,
    required this.active,
    required this.aesKey,
  });

  final MessageModel message;
  final bool active;
  final String? aesKey;

  @override
  Widget build(BuildContext context) {
    if (!active) return const SizedBox.shrink();

    final isPendingTimeout = message.uploadStatus ==
            MessageUploadStatus.pending &&
        message.createdAt != null &&
        DateTime.now().difference(message.createdAt!) >
            const Duration(minutes: 1);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!(message.isSent ?? true) &&
            message.uploadStatus != MessageUploadStatus.failed)
          Shimmer.fromColors(
            baseColor: AppColors.darkAppBar,
            highlightColor: AppColors.purpleText,
            child: Text(
              "Sending..",
              style: AppTextStyles.regular(
                  fontSize: 12.sp, color: AppColors.white.withValues(alpha: 0.65)),
            ),
          ),
        if (message.uploadStatus == MessageUploadStatus.failed ||
            isPendingTimeout)
          GestureDetector(
            onTap: () async {
              if (message.uploadStatus == MessageUploadStatus.failed) {
                await chatCubit.retryFailedMessage(
                    context: context,
                    message: message,
                    aesKey: aesKey,
                    from: "chat bubble Failed");
              } else if (isPendingTimeout) {
                await chatCubit.retryFailedMessage(
                    context: context,
                    message: message,
                    from: "chat bubble pending",
                    aesKey: aesKey);
              }
            },
            child: Icon(
              Icons.autorenew,
              color: AppColors.redColor,
            ),
          ),
      ],
    );
  }
}
