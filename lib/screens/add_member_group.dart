import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/cubit/home_cubit.dart';
import 'package:two_one_two_messenger/cubit/home_state.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/date_format.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/conversation_model.dart';
import 'package:two_one_two_messenger/models/group_info_model.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/avatar_widgets.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';

import '../widgets/appbar.dart';

enum _AddPeopleTab { contacts, recentChats }

class AddMemberGroupScreen extends StatefulWidget {
  const AddMemberGroupScreen({
    super.key,
    required this.admins,
    required this.onSubmit,
    required this.title,
    this.isGroup = true,
  });

  final List<Participant> admins;
  final Future<void> Function() onSubmit;
  final String title;
  final bool isGroup;

  @override
  State<AddMemberGroupScreen> createState() => _AddMemberGroupScreenState();
}

class _AddMemberGroupScreenState extends State<AddMemberGroupScreen> {
  static const int _memberLimit = 20000;

  final scrollController = ScrollController();
  final searchController = TextEditingController();
  Timer? _searchDebounce;
  _AddPeopleTab _selectedTab = _AddPeopleTab.contacts;

  @override
  void initState() {
    super.initState();
    homeCubit.clearSelectedGroupUsers();
    scrollController.addListener(_onScroll);
    fetchAllUsers();
    Future.microtask(() {
      if (mounted && (homeCubit.state.conversationModel?.data ?? []).isEmpty) {
        homeCubit.getConversation(context: context);
      }
    });
  }

  Future<void> fetchAllUsers({String name = ""}) async {
    await homeCubit.getAllUserData(
      context: context,
      isLoadMore: false,
      name: name,
      removedUsers: widget.admins,
    );
  }

  Future<void> _onScroll() async {
    if (_selectedTab != _AddPeopleTab.contacts) return;
    if (!scrollController.hasClients) return;
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 80.h) {
      await homeCubit.getAllUserData(
        context: context,
        isLoadMore: true,
        name: searchController.text.trim(),
        removedUsers: widget.admins,
      );
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      if (_selectedTab == _AddPeopleTab.contacts) {
        fetchAllUsers(name: value.trim());
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        isActionsShow: false,
        isBackShow: true,
        title: widget.title,
        subTitle: 'Up to $_memberLimit Members',
      ),
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            final selected = state.selectedUserForGroup.toList();

            return Column(
              children: [
                _topActionRow(selected.length),
                _tabs(),
                _searchField(),
                if (selected.isNotEmpty) _selectedPeopleStrip(selected),
                Expanded(child: _peopleBody(state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _topActionRow(int selectedCount) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          _circleIconButton(
            icon: Icons.close,
            onTap: () => NavigationService().goBack(),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Add people',
                  style: AppTextStyles.medium(fontSize: 15.sp),
                ),
                2.s,
                Text(
                  '$selectedCount/$_memberLimit',
                  style: AppTextStyles.regular(
                    fontSize: 11.sp,
                    color: AppColors.white.withValues(alpha: 0.58),
                  ),
                ),
              ],
            ),
          ),
          _circleIconButton(
            icon: Icons.chevron_right,
            onTap: widget.onSubmit,
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 34.w,
        height: 34.w,
        decoration: BoxDecoration(
          color: AppColors.darkInputFill.withValues(alpha: 0.65),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white.withValues(alpha: 0.24)),
        ),
        child: Icon(icon, color: AppColors.white, size: 22.sp),
      ),
    );
  }

  Widget _tabs() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        height: 40.h,
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppColors.darkInputFill.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            _tabButton(_AddPeopleTab.contacts, 'Contacts'),
            _tabButton(_AddPeopleTab.recentChats, 'Recent Chats'),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(_AddPeopleTab tab, String label) {
    final isSelected = _selectedTab == tab;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: () {
          setState(() => _selectedTab = tab);
          if (tab == _AddPeopleTab.contacts) {
            fetchAllUsers(name: searchController.text.trim());
          }
        },
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

  Widget _searchField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
      child: SizedBox(
        height: 42.h,
        child: TextField(
          controller: searchController,
          onChanged: _onSearchChanged,
          style: AppTextStyles.regular(fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: _selectedTab == _AddPeopleTab.contacts
                ? 'Search contacts...'
                : 'Search recent chats...',
            hintStyle: AppTextStyles.regular(
              fontSize: 14.sp,
              color: AppColors.white.withValues(alpha: 0.45),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.white,
              size: 20.sp,
            ),
            suffixIcon: searchController.text.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      searchController.clear();
                      _onSearchChanged('');
                      setState(() {});
                    },
                    icon: Icon(Icons.close,
                        color: AppColors.white.withValues(alpha: 0.65),
                        size: 18.sp),
                  ),
            filled: true,
            fillColor: const Color(0xFF2B1F25),
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: BorderSide(
                color: const Color(0xFF86334D).withValues(alpha: 0.45),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: BorderSide(
                color: const Color(0xFF86334D).withValues(alpha: 0.45),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: BorderSide(
                color: const Color(0xFFB94768).withValues(alpha: 0.75),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectedPeopleStrip(List<Participant> selected) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.dialogBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF86334D).withValues(alpha: 0.45),
        ),
      ),
      height: 90.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: selected.length,
        separatorBuilder: (_, __) => 10.s,
        itemBuilder: (context, index) {
          final person = selected[index];
          final name = person.name ?? person.userName ?? '';

          return SizedBox(
            width: 58.w,
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AvatarWidgets(
                      userPic: person.profilePicture ?? '',
                      height: 42,
                      width: 42,
                    ),
                    Positioned(
                      right: -4.w,
                      top: -4.h,
                      child: GestureDetector(
                        onTap: () =>
                            homeCubit.removeSelectedGroupUser(person.id ?? ''),
                        child: Container(
                          width: 17.w,
                          height: 17.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFA51B2A),
                          ),
                          child: Icon(Icons.close,
                              size: 12.sp, color: AppColors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                6.s,
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.regular(fontSize: 11.sp),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _peopleBody(HomeState state) {
    if (_selectedTab == _AddPeopleTab.recentChats) {
      final people = _recentChatUsers(state);
      return _peopleList(people, isLoading: false);
    }

    if (state.getAllUsersLoadingState == LoadingState.loading) {
      return const Center(child: CustomLoadingWidget());
    }

    return _peopleList(
      state.allUserData?.users ?? [],
      isLoading: state.getAllUsersLoadMore,
    );
  }

  Widget _peopleList(List<UserData> people, {required bool isLoading}) {
    final filtered = _filterPeople(people);
    final grouped = _groupPeople(filtered);
    final letters = grouped.keys.toList()..sort();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(S.of(context).noContactsFound),
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          controller:
              _selectedTab == _AddPeopleTab.contacts ? scrollController : null,
          padding: EdgeInsets.fromLTRB(16.w, 0, 28.w, 20.h),
          itemCount: letters.length + (isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= letters.length) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: const Center(child: CustomLoadingWidget()),
              );
            }

            final letter = letters[index];
            final group = grouped[letter] ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 6.h, bottom: 8.h),
                  child: Text(
                    letter,
                    style: AppTextStyles.medium(fontSize: 13.sp),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.dialogBg.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: const Color(0xFF86334D).withValues(alpha: 0.35),
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: group.length,
                    itemBuilder: (context, i) => contactTile(
                      context: context,
                      user: group[i],
                    ),
                    separatorBuilder: (_, __) => Padding(
                      padding: EdgeInsets.only(left: 58.w),
                      child: Divider(
                        height: 1,
                        color: AppColors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                ),
                12.s,
              ],
            );
          },
        ),
        Positioned(
          right: 6.w,
          top: 4.h,
          bottom: 8.h,
          child: _alphabetRail(),
        ),
      ],
    );
  }

  Widget _alphabetRail() {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ#';

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: letters
          .split('')
          .map(
            (letter) => Text(
              letter,
              style: AppTextStyles.medium(
                fontSize: 10.sp,
                color: letter == 'A'
                    ? Colors.red
                    : AppColors.white.withValues(alpha: 0.5),
              ),
            ),
          )
          .toList(),
    );
  }

  List<UserData> _filterPeople(List<UserData> people) {
    final query = searchController.text.trim().toLowerCase();
    final existingIds = widget.admins.map((e) => e.id).toSet();
    final seen = <String>{};

    return people.where((user) {
      final id = user.sId ?? '';
      if (id.isEmpty || existingIds.contains(id) || seen.contains(id)) {
        return false;
      }
      seen.add(id);
      if (query.isEmpty || _selectedTab == _AddPeopleTab.contacts) {
        return true;
      }
      return _displayName(user).toLowerCase().contains(query);
    }).toList();
  }

  Map<String, List<UserData>> _groupPeople(List<UserData> people) {
    final grouped = <String, List<UserData>>{};
    final sorted = [...people]
      ..sort((a, b) => _displayName(a).compareTo(_displayName(b)));

    for (final user in sorted) {
      final name = _displayName(user);
      final first = name.isEmpty ? '#' : name[0].toUpperCase();
      final key = RegExp(r'[A-Z]').hasMatch(first) ? first : '#';
      grouped.putIfAbsent(key, () => []).add(user);
    }

    return grouped;
  }

  List<UserData> _recentChatUsers(HomeState state) {
    final conversations = state.conversationModel?.data ?? [];
    return conversations
        .where((chat) => chat.type == ChatType.one_to_one)
        .expand((chat) => chat.participantDetails ?? <ParticipantDetail>[])
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

  Widget contactTile({
    required BuildContext context,
    required UserData user,
  }) {
    return BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
      final bool isSelected = state.selectedUserForGroup.any(
        (element) => element.id == user.sId,
      );
      final displayName = _displayName(user);

      return InkWell(
        onTap: () {
          if (!homeCubit.addToGroup(user, isSelected, widget.admins.length)) {
            Utils.showSnackBar(
                context, S.of(context).groupMembersLimitrichMessage);
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
          child: Row(
            children: [
              AvatarWidgets(
                userPic: user.profilePicture ?? "",
                height: 42,
                width: 42,
              ),
              12.s,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.medium(fontSize: 14.sp),
                    ),
                    if (user.lastSeen != null) ...[
                      5.s,
                      Text(
                        "${S.of(context).sLastSeen} ${_lastSeenLabel(user.lastSeen)}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.regular(
                          fontSize: 11.sp,
                          color: AppColors.white.withValues(alpha: 0.48),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _selectionCircle(isSelected),
            ],
          ),
        ),
      );
    });
  }

  Widget _selectionCircle(bool isSelected) {
    return Container(
      width: 21.w,
      height: 21.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? const Color(0xFF8E1830) : Colors.transparent,
        border: Border.all(
          color: isSelected
              ? AppColors.white.withValues(alpha: 0.45)
              : AppColors.primaryColor,
        ),
      ),
      child: isSelected
          ? Icon(Icons.check, size: 14.sp, color: AppColors.white)
          : null,
    );
  }

  String _displayName(UserData user) {
    if (user.isActiveNickname ?? false) {
      return user.nickName ?? user.name ?? user.userName ?? '';
    }
    return user.name ?? user.userName ?? '';
  }

  String _lastSeenLabel(String? value) {
    if (value == null || value.isEmpty) return '';
    final parsed = DateTime.tryParse(value);
    return parsed == null
        ? value
        : parsed.toLocal().formattedDateWithDayMonthAtTime;
  }
}
