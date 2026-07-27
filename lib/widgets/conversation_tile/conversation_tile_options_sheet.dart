import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';

void onLongPressConversation(
  BuildContext context, {
  required bool isGroup,
  required bool isAddContact,
  required bool isMute,
  required bool isLockChat,
  required bool isAlredyinFavorites,
  required bool isBlocked,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.scaffoldBgDark,
    builder: (context) {
      return SafeArea(
        child: SingleChildScrollView(
          child: Wrap(
            children: [
              if (!isGroup && isAddContact)
                BottomSheetTile(
                  title: "Add to contacts",
                  icon: Icons.person_add,
                  onTap: () => Navigator.pop(context),
                ),
              BottomSheetTile(
                title: isMute ? "UnMute" : "Mute",
                icon: isMute ? Icons.volume_up : Icons.volume_off,
                onTap: () {},
              ),
              BottomSheetTile(
                icon: isLockChat ? Icons.lock : Icons.lock_open,
                title: isLockChat ? "UnLock chat" : "Lock chat",
                onTap: () {},
              ),
              BottomSheetTile(
                icon: Icons.clear_rounded,
                title: "Clear chat",
                onTap: () {},
              ),
              BottomSheetTile(
                icon: Icons.favorite_border_outlined,
                title: isAlredyinFavorites
                    ? "Remove from Favourites"
                    : "Add to Favourites",
                onTap: () {},
              ),
              BottomSheetTile(
                icon: Icons.group_add,
                title: "Add to list",
                onTap: () {},
              ),
              BottomSheetTile(
                icon: Icons.block,
                title: isBlocked ? "UnBlock" : "Block",
                color: Colors.red,
                onTap: () {},
              ),
              BottomSheetTile(
                icon: Icons.delete_forever,
                title: "Delete Chat",
                color: Colors.red,
                onTap: () {},
              ),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Close",
                    style: AppTextStyles.medium(color: AppColors.buttonColor),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}

class BottomSheetTile extends StatelessWidget {
  final String title;
  final void Function()? onTap;
  final IconData? icon;
  final Color? color;
  final bool isShowDivider;
  const BottomSheetTile({
    super.key,
    required this.title,
    this.onTap,
    this.icon,
    this.color,
    this.isShowDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          splashColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
          title: Text(
            title,
            style: AppTextStyles.regular(
              fontSize: 16.sp,
              color: color ?? AppColors.white,
            ),
          ),
          trailing: Icon(
            icon ?? Icons.person_add_alt_1_outlined,
            color: color ?? Colors.white,
          ),
          onTap: onTap,
        ),
        Visibility(
          visible: isShowDivider,
          child: Divider(
            color: AppColors.dividerColor,
            height: 0,
          ),
        )
      ],
    );
  }
}
