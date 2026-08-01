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
import 'group_info_tab.dart';

class GroupMembersSection extends StatelessWidget {
  const GroupMembersSection({
    super.key,
    required this.groupId,
    required this.currentUser,
    required this.participants,
    required this.admins,
    required this.isAdmin,
    required this.selectedTab,
    required this.onTabSelected,
  });

  final String groupId;
  final UserData currentUser;
  final List<Participant> participants;
  final List<Participant> admins;
  final bool isAdmin;
  final GroupInfoTab selectedTab;
  final ValueChanged<GroupInfoTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final selectedPeople =
        selectedTab == GroupInfoTab.members ? participants : admins;

    return Column(
      children: [
        _peopleTabs(),
        26.s,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedTab == GroupInfoTab.members
                    ? S.of(context).groupMembers
                    : S.of(context).admin,
                style: AppTextStyles.medium(
                  fontSize: 18.sp,
                  color: AppColors.purpleText,
                ),
              ),
              if (isAdmin && selectedTab == GroupInfoTab.members)
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    NavigationService().navigateTo(
                      AddMemberGroupScreen(
                        title: S.of(context).addMembers,
                        admins: participants,
                        isGroup: true,
                        onSubmit: () =>
                            groupCubit.addMembersToGroup(context, groupId),
                      ),
                    );
                  },
                  child: Text(
                    S.of(context).addMembers,
                    style: AppTextStyles.medium(
                      fontSize: 16.sp,
                      color: AppColors.purpleText,
                    ),
                  ),
                )
            ],
          ),
        ),
        if (selectedPeople.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 28.h),
            child: Text(
              selectedTab == GroupInfoTab.members
                  ? 'No members to show'
                  : 'No admins to show',
              style: AppTextStyles.regular(
                fontSize: 14.sp,
                color: AppColors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
        ...selectedPeople.map(
          (participant) => _memberTile(
            context: context,
            currentUserIsAdmin: isAdmin,
            participant: participant,
            forceAdminBadge: selectedTab == GroupInfoTab.admins,
          ),
        ),
      ],
    );
  }

  Widget _peopleTabs() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        height: 42.h,
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppColors.darkInputFill.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.36),
          ),
        ),
        child: Row(
          children: [
            _tabButton(GroupInfoTab.members, 'Members'),
            _tabButton(GroupInfoTab.admins, 'Admins'),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(GroupInfoTab tab, String label) {
    final isSelected = selectedTab == tab;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: () => onTabSelected(tab),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF68283B) : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
            border: isSelected
                ? Border.all(
                    color: const Color(0xFFC13C61).withValues(alpha: 0.8),
                  )
                : null,
          ),
          child: Text(
            label,
            style: AppTextStyles.regular(
              fontSize: 13.sp,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _memberTile(
      {required BuildContext context,
      required bool currentUserIsAdmin,
      required Participant participant,
      bool forceAdminBadge = false}) {
    final isParticipantAdmin =
        forceAdminBadge || (participant.isAdmin ?? false);

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
                        if (isParticipantAdmin)
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
                    isAdmin: isParticipantAdmin,
                    isGroup: true,
                    name: participant.name ?? "",
                    onSelected: (ctx, authority, userId, name, isGroup) =>
                        handleGroupMemberAction(
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
      true);
}

void handleGroupMemberAction(BuildContext context, String groupId,
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
