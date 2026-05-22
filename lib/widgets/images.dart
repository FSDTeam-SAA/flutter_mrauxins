import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';

class CommonImage extends StatelessWidget {
  final String imagePath; // This can be a network URL or an asset path
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget Function(BuildContext, String)?
      errorWidget; // Custom error widget
  final Widget Function(BuildContext, String)?
      progressWidget; // Custom progress widget
  final Duration? cacheDuration; // Optional cache duration
  final EdgeInsetsGeometry? padding; // Padding around the image
  final EdgeInsetsGeometry? margin; // Margin around the image

  const CommonImage({
    super.key,
    required this.imagePath, // Path for both asset and network
    this.width,
    this.height,
    this.fit,
    this.errorWidget,
    this.progressWidget,
    this.cacheDuration, // Optional cache duration
    this.padding, // Optional padding
    this.margin, // Optional margin
  });

  @override
  Widget build(BuildContext context) {
    // Check if the path is a valid URL
    final isNetworkImage = Uri.parse(imagePath).isAbsolute;

    // Wrap with margin if provided
    return Container(
      margin: margin,
      padding: padding, // Apply padding if provided
      child: isNetworkImage
          ? CachedNetworkImage(
              imageUrl: imagePath,
              width: width,
              height: height,
              fit: fit ?? BoxFit.cover,
              placeholder: (context, url) => progressWidget != null
                  ? progressWidget!(context, url)
                  : defaultProgressWidget(
                      context, url), // Use progress widget or default
              errorWidget: errorWidget != null
                  ? (context, url, error) => errorWidget!(context, url)
                  : defaultErrorWidget, // Use error widget or default
              cacheKey: UniqueKey().toString(), // Optional cache key
              maxWidthDiskCache: 1000, // Optional, set max width for disk cache
              maxHeightDiskCache:
                  1000, // Optional, set max height for disk cache
            )
          : Image.asset(
              imagePath,
              width: width,
              height: height,
              fit: fit ?? BoxFit.cover,
            ),
    );
  }

  // Default progress indicator if not provided
  Widget defaultProgressWidget(BuildContext context, String url) {
    return const Center(
      child: CustomLoadingWidget(),
    );
  }

  // Default error widget if not provided
  Widget defaultErrorWidget(BuildContext context, String url, dynamic error) {
    return const Center(
      child: Icon(Icons.error, color: Colors.red),
    );
  }
}
