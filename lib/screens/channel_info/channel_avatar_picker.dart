import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/image_picker.dart';
import 'package:two_one_two_messenger/widgets/avatar_widgets.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';

class ChannelAvatarPicker extends StatelessWidget {
  const ChannelAvatarPicker({
    super.key,
    required this.selectedGroupPic,
    required this.groupImage,
    required this.isAdmin,
  });

  final XFile? selectedGroupPic;
  final String? groupImage;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 150.h,
          child: Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              color: AppColors.darkAppBar,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.darkAppBar, width: 4.w),
            ),
            child: selectedGroupPic != null
                ? CircleAvatar(
                    radius: 60.r,
                    backgroundImage: FileImage(File(selectedGroupPic!.path)),
                    // Use FileImage for circular display
                    backgroundColor: Colors
                        .transparent, // Set background to transparent if needed
                  )
                : (groupImage ?? "").isNotEmpty
                    ? AvatarWidgets(
                        userPic: groupImage ?? "",
                        height: 120,
                        width: 120,
                      )
                    : Center(
                        child: SvgImage(
                          source: SvgAssets.icNewGroup,
                          width: 50.w,
                          color: AppColors.white,
                        ),
                      ),
          ),
        ),
        if (isAdmin)
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: GestureDetector(
              onTap: () {
                showCustomImageOptionPickerDialog(
                    context: context, onImagePicked: homeCubit.selectGroupImage);
              },
              child: CircleAvatar(
                radius: 15.r,
                backgroundColor: AppColors.primaryColor,
                child: SvgImage(
                  source: SvgAssets.icCamera,
                  width: 15.w,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
