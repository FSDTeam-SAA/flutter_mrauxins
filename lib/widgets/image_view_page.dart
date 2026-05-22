// ignore_for_file: deprecated_member_use
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../utils/colors.dart';
import 'appbar.dart';

class ImageViewPage extends StatelessWidget {
  const ImageViewPage(
      {super.key, required this.title, required this.imageUrl, this.imageFile});

  final String title;
  final String imageUrl;
  final File? imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: title,
        isBackShow: true,
        isActionsShow: false,
      ),
      body: PhotoView(
        wantKeepAlive: true,
        backgroundDecoration: BoxDecoration(color: Colors.transparent),
        imageProvider: imageFile != null
            ? FileImage(imageFile!)
            : CachedNetworkImageProvider(imageUrl),
        loadingBuilder: (context, event) {
          if (event == null) return const Center();
          final progress = event.expectedTotalBytes != null
              ? event.cumulativeBytesLoaded / event.expectedTotalBytes!
              : 0.0;
          return Center(
              child: CircularProgressIndicator(
                  value: progress, color: AppColors.primaryColor));
        },
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered,
        initialScale: PhotoViewComputedScale.contained,
      ),
    );
  }
}
