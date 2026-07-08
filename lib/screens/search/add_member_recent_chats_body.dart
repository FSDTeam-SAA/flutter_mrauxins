import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/cubit/home_state.dart';
import 'package:two_one_two_messenger/models/all_user.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/conversation_model.dart';
import 'package:two_one_two_messenger/utils/constants.dart';

import 'search_widgets.dart';
import 'add_member_widgets.dart';

class AddMemberRecentChatsBody extends StatelessWidget {
  final HomeState state;
  final Function(UserData, bool) onContactTap;
  final String searchQuery;
  final String currentUserId;
  final List<Participant> admins;

  const AddMemberRecentChatsBody({
    super.key,
    required this.state,
    required this.onContactTap,
    required this.searchQuery,
    required this.currentUserId,
    required this.admins,
  });

  @override
  Widget build(BuildContext context) {
    final people = _recentChatUsers();
    final filtered = _filterPeople(people);

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(S.of(context).noContactsFound),
        ),
      );
    }

    return GroupedListWithRail<UserData>(
      items: filtered,
      nameOf: _displayName,
      tileBuilder: (user) {
        final isSelected = state.selectedUserForGroup.any(
          (element) => element.id == user.sId,
        );
        return AddMemberContactTile(
          user: user,
          isSelected: isSelected,
          onTap: () => onContactTap(user, isSelected),
        );
      },
      emptyState: Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(S.of(context).noContactsFound),
        ),
      ),
    );
  }

  List<UserData> _recentChatUsers() {
    final conversations = state.conversationModel?.data ?? [];
    return conversations
        .where((chat) => chat.type == ChatType.one_to_one)
        .expand((chat) => chat.participantDetails ?? <ParticipantDetail>[])
        .where((p) => p.id != currentUserId)
        .map(
          (participant) => UserData(
            sId: participant.id,
            name: participant.name,
            userName: participant.userName,
            profilePicture: participant.profilePicture,
            lastSeen: participant.lastSeen,
            isOnline: participant.isOnline,
            nickName: participant.nickName,
            isActiveNickname: participant.isActiveNickname,
          ),
        )
        .toList();
  }

  List<UserData> _filterPeople(List<UserData> people) {
    final query = searchQuery.trim().toLowerCase();
    final existingIds = admins.map((e) => e.id).toSet();
    final seen = <String>{};

    return people.where((user) {
      final id = user.sId ?? '';
      if (id.isEmpty ||
          id == currentUserId ||
          existingIds.contains(id) ||
          seen.contains(id)) {
        return false;
      }
      seen.add(id);
      if (query.isEmpty) {
        return true;
      }
      return _displayName(user).toLowerCase().startsWith(query);
    }).toList();
  }

  String _displayName(UserData user) {
    if (user.isActiveNickname ?? false) {
      return user.nickName ?? user.name ?? user.userName ?? '';
    }
    return user.name ?? user.userName ?? '';
  }
}
