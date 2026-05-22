import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';

class SvgImage extends StatelessWidget {
  final String source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color; // New: Option to recolor the SVG.
  final Alignment alignment; // New: Alignment of the image.
  final Clip clipBehavior; // New: Clip behavior.
  final String? semanticsLabel; // New: Accessibility label.

  const SvgImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
    this.alignment = Alignment.center, // Default alignment.
    this.clipBehavior = Clip.none, // Default clip behavior.
    this.semanticsLabel, // Optional label for accessibility.
  });

  @override
  Widget build(BuildContext context) {
    bool isNetwork = source.startsWith('http') || source.startsWith('https');

    return isNetwork
        ? SvgPicture.network(
            source,
            width: width,
            height: height,
            fit: fit,
            colorFilter: color != null
                ? ColorFilter.mode(color!, BlendMode.srcIn)
                : null,
            // color: color,
            alignment: alignment,
            clipBehavior: clipBehavior,
            semanticsLabel: semanticsLabel,
            placeholderBuilder: (context) =>
                const CustomLoadingWidget(), // Loading indicator
          )
        : SvgPicture.asset(
            source,
            width: width,
            height: height,
            fit: fit,
            colorFilter: color != null
                ? ColorFilter.mode(color!, BlendMode.srcIn)
                : null,
            // color: color,
            alignment: alignment,
            clipBehavior: clipBehavior,
            semanticsLabel: semanticsLabel,
          );
  }
}
