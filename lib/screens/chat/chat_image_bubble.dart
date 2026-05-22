import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatImageBubble extends StatelessWidget {
  final String imagePath;

  const ChatImageBubble({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.h),
        child: Image.asset(
          imagePath,
          height: 150.h,
          width: 150.w,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
