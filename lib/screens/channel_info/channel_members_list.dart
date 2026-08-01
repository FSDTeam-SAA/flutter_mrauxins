import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/date_format.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/group_info_model.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/utils/app_pop_up.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/avatar_widgets.dart';

import '../add_member_group.dart';

class ChannelMembersList extends StatelessWidget {
  const ChannelMembersList({
    super.key,
    required this.groupId,
    required this.currentUser,
    required this.participants,
    required this.isAdmin,
  });

  final String groupId;
  final UserData currentUser;
  final List<Participant> participants;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).subscribers,
                style: AppTextStyles.medium(
                    fontSize: 18.sp, color: AppColors.purpleText),
              ),
              if (isAdmin)
                GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      NavigationService().navigateTo(AddMemberGroupScreen(
                        title: S.of(context).addSubscribers,
                        admins: participants,
                        isGroup: false,
                        onSubmit: () =>
                            groupCubit.addMembersToGroup(context, groupId),
                      ));
                    },
                    child: Text(
                      S.of(context).addSubscribers,
                      style: AppTextStyles.medium(
                          fontSize: 18.sp, color: AppColors.purpleText),
                    ))
            ],
          ),
        ),
        ...participants.map(
          (participant) => _memberTile(
              context: context,
              groupId: groupId,
              currentUserIsAdmin: isAdmin,
              participant: participant),
        ),
      ],
    );
  }

  Widget _memberTile(
      {required BuildContext context,
      required bool currentUserIsAdmin,
      required String groupId,
      required Participant participant}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0.w),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.darkAppBar))),
      child: Column(
        children: [
          17.s,
          Row(
            children: [
              AvatarWidgets(
                userPic: participant.profilePicture ?? "",
                height: 50,
                width: 50,
              ),
              16.s,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            participant.id == currentUser.sId
                                ? S.of(context).you
                                : participant.name ?? "",
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.medium(
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                        4.s,
                        if (participant.isAdmin ?? false)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                                color: AppColors.purpleText,
                                borderRadius: BorderRadius.circular(16)),
                            child: Text(
                              S.of(context).admin,
                              style: AppTextStyles.regular(
                                  color: AppColors.textColorPrimary),
                            ),
                          )
                      ],
                    ),
                    6.s,
                    if (participant.lastSeen != null)
                      Text(
                        "${S.of(context).sLastSeen} ${participant.lastSeen?.formattedDateWithDayMonthAtTime}",
                        style: AppTextStyles.regular(
                            fontSize: 13.sp,
                            color: AppColors.white.withValues(alpha: 0.5)),
                      )
                  ],
                ),
              ),
              if ((participant.id != currentUser.sId) &&
                  !(participant.isCreator ?? false) &&
                  currentUserIsAdmin)
                buildOptionMenuForGroup(
                    context: context,
                    isAdmin: participant.isAdmin ?? false,
                    isGroup: false,
                    name: participant.name ?? "",
                    onSelected: (ctx, authority, userId, name, isGroup) =>
                        handleChannelMemberAction(
                            ctx, groupId, authority, userId, name, isGroup),
                    userId: participant.id ?? ""),
            ],
          ),
          17.s,
        ],
      ),
    );
  }
}

Future<void> _createAdmin(
    BuildContext context, String groupId, String userId) async {
  await groupCubit.assignAdminToGroup(
    context,
    {"chatId": groupId, "userId": userId, "removeFromAdmin": false},
  );
}

Future<void> _removeAdmin(
    BuildContext context, String groupId, String userId) async {
  await groupCubit.assignAdminToGroup(
    context,
    {"chatId": groupId, "userId": userId, "removeFromAdmin": true},
  );
}

Future<void> _removeMember(BuildContext context, String groupId,
    String userId, String name, bool isGroup) async {
  await groupCubit.removeMemberFromGroup(
      context,
      {
        "chatId": groupId,
        "memberId": userId,
      },
      name,
      false);
}

void handleChannelMemberAction(BuildContext context, String groupId,
    GroupAdminAthority authority, String userId, String name, bool isGroup) {
  switch (authority) {
    case GroupAdminAthority.createAdmin:
      _createAdmin(context, groupId, userId);
      break;
    case GroupAdminAthority.removeMember:
      _removeMember(context, groupId, userId, name, isGroup);
      break;
    case GroupAdminAthority.removeAdmin:
      _removeAdmin(context, groupId, userId);
      break;
  }
}
