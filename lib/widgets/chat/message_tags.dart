import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';

class EditedMessageTag extends StatelessWidget {
  const EditedMessageTag({super.key, required this.bgColor});
  final Color bgColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      padding: EdgeInsets.all(0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.edit_attributes,
            color: AppColors.white,
          ),
          8.s,
          Text(
            S.of(context).edited,
            style: AppTextStyles.regular(color: AppColors.purpleText),
          )
        ],
      ),
    );
  }
}

class ForwardMessageTag extends StatelessWidget {
  const ForwardMessageTag({super.key, required this.bgColor});
  final Color bgColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      padding: EdgeInsets.all(0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(math.pi),
            child: Icon(
              Icons.reply_outlined,
              color: AppColors.white,
            ),
          ),
          8.s,
          Text(
            S.of(context).forward,
            style: AppTextStyles.regular(color: AppColors.purpleText),
          )
        ],
      ),
    );
  }
}
