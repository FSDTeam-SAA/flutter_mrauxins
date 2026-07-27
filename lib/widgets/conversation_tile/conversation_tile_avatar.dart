import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/widgets/network_image.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';

class ConversationTileAvatar extends StatelessWidget {
  const ConversationTileAvatar({
    super.key,
    required this.imageUrl,
    required this.fallbackIcon,
  });

  /// Empty string means no image is available; the [fallbackIcon] is shown instead.
  final String imageUrl;
  final String fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.w,
      width: 50.w,
      decoration: BoxDecoration(
        color: AppColors.darkInputFill,
        shape: BoxShape.circle,
      ),
      child: imageUrl.isNotEmpty
          ? AppNetworkImage(
              imageUrl: imageUrl,
              borderRadius: BorderRadius.all(
                Radius.circular(50.r),
              ),
              fit: BoxFit.cover,
            )
          : Center(
              child: SvgImage(
                source: fallbackIcon,
                color: AppColors.white,
              ),
            ),
    );
  }
}
