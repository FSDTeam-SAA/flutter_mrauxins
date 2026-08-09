import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/models/chat_message_model.dart';
import 'package:two_one_two_messenger/services/api_config.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/custom_linkifire.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/chat/chat_media_url.dart';
import 'package:two_one_two_messenger/widgets/network_image.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';

class ForwadedMessageView extends StatelessWidget {
  const ForwadedMessageView({
    super.key,
    required this.message,
    this.bgColor,
  });
  final MessageModel message;
  final Color? bgColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: bgColor ?? AppColors.darkInputFill,
        borderRadius: BorderRadius.all(Radius.circular(14.r)),
      ),
      child: Row(
        children: [
          if (((message.type == 'image') &&
              (message.files != null && (message.files ?? []).isNotEmpty)))
            Container(
              width: 40.h,
              height: 40.h,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(9)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: AppNetworkImage(
                  key: ValueKey(message.files!.first.url ??
                      DateTime.now().toIso8601String()),
                  fit: BoxFit.cover,
                  imageUrl: '${Urls.mediaUrl}${message.files!.first.url}',
                ),
              ),
            ),
          if (((message.type == 'gif') &&
              (message.files != null && (message.files ?? []).isNotEmpty)))
            Container(
              width: 40.h,
              height: 40.h,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(9)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: AppNetworkImage(
                  key: ValueKey(message.files!.first.url ??
                      DateTime.now().toIso8601String()),
                  fit: BoxFit.cover,
                  imageUrl: (message.files?.first.url ?? "").isEmpty
                      ? ""
                      : resolveChatMediaUrl(message.files!.first.url),
                ),
              ),
            )
          else if ((message.type == 'video' &&
              message.files != null &&
              (message.files ?? []).isNotEmpty))
            SvgImage(
              source: SvgAssets.icVideoOutline,
              color: AppColors.white,
              height: 20.h,
              width: 20.w,
            )
          else if ((message.type == 'audio' &&
              message.files != null &&
              (message.files ?? []).isNotEmpty))
            SvgImage(
              source: SvgAssets.icMicrophone,
              color: AppColors.white,
              height: 20.h,
              width: 20.w,
            )
          else if (((message.type == 'document' || message.type == 'pdf') &&
              (message.files != null && (message.files ?? []).isNotEmpty)))
            SvgImage(
              source: SvgAssets.icDocumentOutline,
              color: AppColors.white,
              height: 20.h,
              width: 20.w,
            ),
          8.s,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Linkify(
                onOpen: Utils.onOpenLink,
                text: message.content ?? "",
                maxLines: 5,
                linkifiers: [
                  CustomLinkifier(),
                  UrlLinkifier(),
                  EmailLinkifier()
                ],
                linkStyle: AppTextStyles.regular(
                  fontSize: 14.sp,
                  color: AppColors.purpleText,
                ).copyWith(decoration: TextDecoration.underline),
                style: AppTextStyles.regular(color: AppColors.textColorHint),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
