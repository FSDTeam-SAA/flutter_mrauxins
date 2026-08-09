import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
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

class ReplyMessageView extends StatelessWidget {
  const ReplyMessageView({
    super.key,
    required this.message,
    required this.isSender,
    required this.onTapScroll,
    this.bgColor,
  });
  final MessageModel message;
  final Color? bgColor;
  final bool isSender;

  final VoidCallback? onTapScroll;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTapScroll,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: EdgeInsets.symmetric(vertical: 5.h).copyWith(top: 0),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: bgColor ?? AppColors.darkInputFill,
          border: Border(
              left: BorderSide(
                  width: 3,
                  color:
                      isSender ? AppColors.greenColor : AppColors.purpleText)),
          borderRadius: BorderRadius.all(Radius.circular(14.r)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.45,
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75),
                    child: Text(
                      isSender
                          ? S.of(context).you
                          : AppMethods.getNickName(message.sender),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: AppTextStyles.medium(
                          color: isSender
                              ? AppColors.greenColor
                              : AppColors.purpleText),
                    ),
                  ),
                  Linkify(
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
                    style:
                        AppTextStyles.regular(color: AppColors.textColorHint),
                  ),
                ],
              ),
            ),
            8.s,
            if (((message.type == 'image') &&
                (message.files != null && (message.files ?? []).isNotEmpty)))
              Container(
                width: 40.h,
                height: 40.h,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(9)),
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
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(9)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: AppNetworkImage(
                    key: ValueKey(message.files!.first.url ??
                        DateTime.now().toIso8601String()),
                    fit: BoxFit.cover,
                    imageUrl: resolveChatMediaUrl(message.files!.first.url),
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
                    (message.files ?? []).isNotEmpty) &&
                (message.files?.first.url?.endsWith('.mp3') == true ||
                    message.files?.first.url?.endsWith('.aac') == true))
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
          ],
        ),
      ),
    );
  }
}
