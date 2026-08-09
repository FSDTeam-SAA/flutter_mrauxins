import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/chat_message_model.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/chat/chat_media_url.dart';
import 'package:two_one_two_messenger/widgets/chat/message_header.dart';
import 'package:two_one_two_messenger/widgets/image_view_page.dart';
import 'package:two_one_two_messenger/widgets/media_upload_progress.dart';
import 'package:two_one_two_messenger/widgets/network_image.dart';

class ImageBubble extends StatelessWidget {
  const ImageBubble({
    super.key,
    required this.message,
    required this.isSender,
    required this.isGroup,
    required this.onTapScroll,
    required this.widthFraction,
    required this.showUploadProgress,
    required this.fileSizeFallback,
  });

  final MessageModel message;
  final bool isSender;
  final bool isGroup;
  final VoidCallback? onTapScroll;
  final double widthFraction;
  final bool showUploadProgress;
  final int fileSizeFallback;

  @override
  Widget build(BuildContext context) {
    final file = message.files!.first;
    return Container(
      width: context.w * widthFraction,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isSender ? AppColors.primaryColor : AppColors.darkInputFill,
        borderRadius: BorderRadius.only(
          topLeft: isSender ? Radius.circular(14.r) : Radius.circular(0.r),
          topRight: Radius.circular(14.r),
          bottomLeft: Radius.circular(14.r),
          bottomRight: isSender ? Radius.circular(0.r) : Radius.circular(14.r),
        ),
      ),
      constraints:
          BoxConstraints(maxWidth: context.w * 0.75, maxHeight: context.h * 0.5),
      margin: EdgeInsets.symmetric(vertical: 5.h),
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
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ImageViewPage(
                      title: S.of(context).image,
                      imageFile: file.file != null
                          ? File(file.file!.path)
                          : null,
                      imageUrl: resolveChatMediaUrl(file.url))));
            },
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (showUploadProgress && message.uploadProgress != null)
                      Positioned.fill(
                        child: CircularMediaUploadProgress(
                          width: 74.h,
                          height: 74.h,
                          progress: message.uploadProgress!,
                        ),
                      ),
                    Container(
                      width: 74.h,
                      height: 74.h,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: file.file != null
                            ? Image.file(
                                File(file.file!.path),
                                fit: BoxFit.cover,
                              )
                            : AppNetworkImage(
                                key: ValueKey(file.url ??
                                    DateTime.now().toIso8601String()),
                                fit: BoxFit.cover,
                                imageUrl: resolveChatMediaUrl(file.url),
                              ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).image,
                        style: AppTextStyles.regular(
                          fontSize: 14.sp,
                          color: AppColors.white,
                        ).copyWith(height: 1.36),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        Utils.formatFileSize(file.fileSize ?? fileSizeFallback),
                        style: AppTextStyles.regular(
                          fontSize: 14.sp,
                          color: AppColors.white,
                        ).copyWith(height: 1.36),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
