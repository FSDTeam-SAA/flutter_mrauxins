import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/services/api_client.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';

class AvatarWidgets extends StatelessWidget {
  const AvatarWidgets(
      {super.key,
      this.height,
      this.width,
      required this.userPic,
      this.svgAvatar});
  final double? height;
  final double? width;
  final String userPic;
  final String? svgAvatar;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: height ?? 45.h,
      height: width ?? 45.h,
      decoration: BoxDecoration(
          image: (userPic).isEmpty
              ? null
              : DecorationImage(
                  image: CachedNetworkImageProvider(
                    "${Urls.mediaUrl}$userPic",
                  ),
                  fit: BoxFit.cover),
          color: AppColors.darkInputFill,
          shape: BoxShape.circle),
      child: (userPic).isNotEmpty
          ? null
          : Center(
              child: SvgImage(
                source: svgAvatar ?? SvgAssets.icPerson,
                color: AppColors.white,
              ),
            ),
    );
  }
}

class AvatarWidgetsForMemoryImage extends StatelessWidget {
  const AvatarWidgetsForMemoryImage(
      {super.key, this.height, this.width, required this.userPic});
  final double? height;
  final double? width;
  final Uint8List? userPic;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: height ?? 45.h,
      height: width ?? 45.h,
      decoration: BoxDecoration(
          image: userPic == null
              ? null
              : DecorationImage(
                  image: MemoryImage(
                    userPic!,
                  ),
                  fit: BoxFit.cover),
          color: AppColors.darkInputFill,
          shape: BoxShape.circle),
      child: userPic != null
          ? null
          : Center(
              child: SvgImage(
                source: SvgAssets.icPerson,
                color: AppColors.white,
              ),
            ),
    );
  }
}
