import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';

import '../utils/colors.dart';
import '../utils/utils.dart';

class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius? borderRadius;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(0),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        // cacheManager: DefaultCacheManager(),
        placeholder: (context, url) => Center(
          child: Container(
            width: width, // Customize the loader size
            height: height,
            decoration: BoxDecoration(color: AppColors.textColorSecondary),
          ),
        ),
        errorWidget: (context, url, error) => Center(
          child: Container(
            width: width, // Customize the loader size
            height: height,
            decoration: BoxDecoration(color: AppColors.textColorSecondary),
          ),
        ),
      ),
    );
  }
}
