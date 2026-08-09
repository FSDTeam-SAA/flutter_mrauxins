import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/models/chat_message_model.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/chat/chat_media_url.dart';
import 'package:two_one_two_messenger/widgets/chat/message_header.dart';
import 'package:two_one_two_messenger/widgets/image_view_page.dart';
import 'package:two_one_two_messenger/widgets/network_image.dart';

class GifBubble extends StatelessWidget {
  const GifBubble({
    super.key,
    required this.message,
    required this.isSender,
    required this.isGroup,
    required this.onTapScroll,
    required this.widthFraction,
  });

  final MessageModel message;
  final bool isSender;
  final bool isGroup;
  final VoidCallback? onTapScroll;
  final double widthFraction;

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
                      title: file.fileName ?? 'GIF',
                      imageFile: null,
                      imageUrl: resolveChatMediaUrl(file.url))));
            },
            child: Row(
              children: [
                Container(
                  width: 74.h,
                  height: 74.h,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(9)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: AppNetworkImage(
                      key: ValueKey(
                          file.url ?? DateTime.now().toIso8601String()),
                      fit: BoxFit.cover,
                      imageUrl: resolveChatMediaUrl(file.url),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${file.fileName}",
                        style: AppTextStyles.regular(
                          fontSize: 14.sp,
                          color: AppColors.white,
                        ).copyWith(height: 1.36),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        Utils.formatFileSize(file.fileSize ?? 0),
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
