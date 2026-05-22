import 'package:flutter/material.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';

class CircularMediaUploadProgress extends StatelessWidget {
  final double progress;
  final double width;
  final double height;

  const CircularMediaUploadProgress({
    super.key,
    required this.progress,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).toStringAsFixed(0);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 5,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
          Text(
            '$percentage%',
            style: AppTextStyles.baseStyle(),
          )
        ],
      ),
    );
  }
}
