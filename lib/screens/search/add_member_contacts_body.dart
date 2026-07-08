import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/cubit/home_state.dart';
import 'package:two_one_two_messenger/models/all_user.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';
import 'package:two_one_two_messenger/models/conversation_model.dart';

import 'search_widgets.dart';
import 'add_member_widgets.dart';

class AddMemberContactsBody extends StatefulWidget {
  final HomeState state;
  final ScrollController scrollController;
  final VoidCallback onScrollNearEnd;
  final Function(UserData, bool) onContactTap;
  final String searchQuery;
  final String currentUserId;
  final List<Participant> admins;

  const AddMemberContactsBody({
    super.key,
    required this.state,
    required this.scrollController,
    required this.onScrollNearEnd,
    required this.onContactTap,
    required this.searchQuery,
    required this.currentUserId,
    required this.admins,
  });

  @override
  State<AddMemberContactsBody> createState() => _AddMemberContactsBodyState();
}

class _AddMemberContactsBodyState extends State<AddMemberContactsBody> {
  @override
  Widget build(BuildContext context) {
    if (widget.state.getAllUsersLoadingState == LoadingState.loading) {
      return const Center(child: CustomLoadingWidget());
    }

    final people = widget.state.allUserData?.users ?? [];
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
      scrollController: widget.scrollController,
      onScrollNearEnd: widget.onScrollNearEnd,
      isLoadingMore: widget.state.getAllUsersLoadMore,
      tileBuilder: (user) {
        final isSelected = widget.state.selectedUserForGroup.any(
          (element) => element.id == user.sId,
        );
        return AddMemberContactTile(
          user: user,
          isSelected: isSelected,
          onTap: () => widget.onContactTap(user, isSelected),
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

  List<UserData> _filterPeople(List<UserData> people) {
    final query = widget.searchQuery.trim().toLowerCase();
    final existingIds = widget.admins.map((e) => e.id).toSet();
    final seen = <String>{};

    return people.where((user) {
      final id = user.sId ?? '';
      if (id.isEmpty ||
          id == widget.currentUserId ||
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
