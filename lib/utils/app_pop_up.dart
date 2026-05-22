import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';

PopupMenuButton<MessageOption> buildOptionMenu(
    {required BuildContext context, void Function(MessageOption)? onSelected}) {
  return PopupMenuButton<MessageOption>(
    color: AppColors.dialogBg,
    icon: SvgImage(
        source: SvgAssets.icMoreDots, width: 18.w, color: AppColors.white),
    onSelected: onSelected,
    itemBuilder: (BuildContext context) => <PopupMenuEntry<MessageOption>>[
      PopupMenuItem<MessageOption>(
        value: MessageOption.clearChat,
        child: Text(
          S.of(context).clearChat,
          style: AppTextStyles.regular(color: AppColors.white),
        ),
      ),
    ],
  );
}

PopupMenuButton<MessageOption> buildClearNotiFicationMenu(
    {required BuildContext context, void Function(MessageOption)? onSelected}) {
  return PopupMenuButton<MessageOption>(
    color: AppColors.dialogBg,
    icon: SvgImage(
        source: SvgAssets.icMoreDots, width: 18.w, color: AppColors.white),
    onSelected: onSelected,
    itemBuilder: (BuildContext context) => <PopupMenuEntry<MessageOption>>[
      PopupMenuItem<MessageOption>(
        value: MessageOption.clearChat,
        child: Text(
          S.of(context).clearNotification,
          style: AppTextStyles.regular(color: AppColors.white),
        ),
      ),
    ],
  );
}

void chatOptionpopUpMenu({
  required BuildContext context,
  required List<ChatOption> options,
  required Offset offset,
}) {
  showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, -50, 0),
      color: AppColors.secondaryBgColor,
      items: options
          .map(
            (chatOption) => PopupMenuItem<String>(
              value: chatOption.value,
              onTap: chatOption.onTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  chatOption.icon,
                  8.s,
                  Text(chatOption.name,
                      style: AppTextStyles.regular(fontSize: 16.sp)),
                ],
              ),
            ),
          )
          .toList()
      // [

      //           PopupMenuItem<ChatOption>(
      //   value: MessageOption.viewContact,
      //   child: Row(
      //     children: [
      //       SvgImage(
      //         source: SvgAssets.icPerson,
      //         color: AppColors.white,
      //       ),
      //       8.s,
      //       Text(S.current.viewContact, style: AppTextStyles.regular()),
      //     ],
      //   ),
      //   onTap: () {

      //   },
      // ),
      //       ]
      );
}

PopupMenuButton<GroupAdminAthority> buildOptionMenuForGroup({
  required BuildContext context,
  required void Function(BuildContext, GroupAdminAthority, String, String, bool)
      onSelected,
  required String userId,
  required String name,
  required bool isGroup,
  required bool isAdmin,
}) {
  return PopupMenuButton<GroupAdminAthority>(
    color: AppColors.dialogBg,
    icon: SvgImage(
      source: SvgAssets.icMoreDots,
      width: 18.w,
      color: AppColors.white,
    ),
    onSelected: (selectedAuthority) {
      // handleGroupAction(selectedAuthority);
      onSelected(context, selectedAuthority, userId, name, isGroup);
    },
    itemBuilder: (BuildContext context) => isAdmin
        ? [
            PopupMenuItem<GroupAdminAthority>(
              value: GroupAdminAthority.removeAdmin,
              child: Row(
                children: [
                  SvgImage(
                    source:
                        GroupAdminAthority.removeAdmin.icon, // ✅ Now this works
                    width: 18.w,
                    color: AppColors.white,
                  ),
                  8.s,
                  Text(
                    GroupAdminAthority.removeAdmin.name,
                    style: AppTextStyles.regular(color: AppColors.white),
                  ),
                ],
              ),
            )
          ]
        : isGroup
            ? GroupAdminAthority.values
                .where((ele) => ele != GroupAdminAthority.removeAdmin)
                .map((e) => PopupMenuItem<GroupAdminAthority>(
                      value: e,
                      child: Row(
                        children: [
                          SvgImage(
                            source: e.icon, // ✅ Now this works
                            width: 18.w,
                            color: AppColors.white,
                          ),
                          8.s,
                          Text(
                            e.name,
                            style:
                                AppTextStyles.regular(color: AppColors.white),
                          ),
                        ],
                      ),
                    ))
                .toList()
            : [
                PopupMenuItem<GroupAdminAthority>(
                  value: GroupAdminAthority.removeMember,
                  child: Row(
                    children: [
                      SvgImage(
                        source: GroupAdminAthority
                            .removeMember.icon, // ✅ Now this works
                        width: 18.w,
                        color: AppColors.white,
                      ),
                      8.s,
                      Text(
                        GroupAdminAthority.removeMember.name,
                        style: AppTextStyles.regular(color: AppColors.white),
                      ),
                    ],
                  ),
                )
              ],
  );
}
