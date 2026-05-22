// Typing indicator bubble
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/avatar_widgets.dart';

class TypingIndicatorBubble extends StatefulWidget {
  final ChatType chatType;
  final String profilePic;
  const TypingIndicatorBubble({
    super.key,
    required this.chatType,
    required this.profilePic,
  });
  @override
  _TypingIndicatorBubbleState createState() => _TypingIndicatorBubbleState();
}

class _TypingIndicatorBubbleState extends State<TypingIndicatorBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation1, _animation2, _animation3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation1 = ColorTween(begin: Colors.grey[400], end: Colors.grey[600])
        .animate(_controller);
    _animation2 =
        ColorTween(begin: Colors.grey[400], end: Colors.grey[600]).animate(
      CurvedAnimation(
          parent: _controller,
          curve: Interval(0.2, 0.8, curve: Curves.easeInOut)),
    );
    _animation3 =
        ColorTween(begin: Colors.grey[400], end: Colors.grey[600]).animate(
      CurvedAnimation(
          parent: _controller,
          curve: Interval(0.4, 1.0, curve: Curves.easeInOut)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          if (widget.chatType != ChatType.one_to_one)
            AvatarWidgets(
              userPic: widget.profilePic,
              height: 40.h,
              width: 40.h,
            ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.darkInputFill,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0.r),
                topRight: Radius.circular(28.r),
                bottomLeft: Radius.circular(14.r),
                bottomRight: Radius.circular(28.r),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDot(_animation1.value!),
                        SizedBox(width: 5),
                        _buildDot(_animation2.value!),
                        SizedBox(width: 5),
                        _buildDot(_animation3.value!),
                        SizedBox(width: 5),
                        _buildDot(
                            _animation1.value!), // Fourth dot with same effect
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
