import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';

import '../utils/colors.dart';
import '../utils/utils.dart';

class AppVideoThumbnail extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius? borderRadius;

  const AppVideoThumbnail({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Utils().getVideoThumbnail(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              width: 24.w, // Customize the loader size
              height: 24.h,
              child: CustomLoadingWidget(
                color: AppColors.white, // Adjust thickness
              ),
            ),
          );
        } else if (snapshot.hasError ||
            snapshot.data == null ||
            snapshot.data!.path.isEmpty) {
          return Icon(Icons.error, color: AppColors.redColor);
        } else {
          return Image.file(
            File(snapshot.data!.path),
            width: width,
            height: height,
            fit: fit,
          );
        }
      },
    );
  }
}
