import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:two_one_two_messenger/cubit/home_cubit.dart';
import 'package:two_one_two_messenger/cubit/home_state.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/conversation_model.dart';
import 'package:two_one_two_messenger/models/all_user.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

import '../widgets/appbar.dart';
import 'search/add_member_tab.dart';
import 'search/add_member_widgets.dart';
import 'search/add_member_contacts_body.dart';
import 'search/add_member_recent_chats_body.dart';

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
  AddPeopleTab _selectedTab = AddPeopleTab.contacts;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    homeCubit.clearSelectedGroupUsers();
    fetchAllUsers();
    _loadCurrentUserId();
    Future.microtask(() {
      if (mounted && (homeCubit.state.conversationModel?.data ?? []).isEmpty) {
        homeCubit.getConversation(context: context);
      }
    });
  }

  Future<void> _loadCurrentUserId() async {
    final user = await homeCubit.dbHelper.getLoginData();
    if (mounted) setState(() => _currentUserId = user?.sId);
  }

  Future<void> fetchAllUsers({String name = ""}) async {
    await homeCubit.getAllUserData(
      context: context,
      isLoadMore: false,
      name: name,
      removedUsers: widget.admins,
    );
  }

  Future<void> _onScrollNearEnd() async {
    if (_selectedTab != AddPeopleTab.contacts) return;
    await homeCubit.getAllUserData(
      context: context,
      isLoadMore: true,
      name: searchController.text.trim(),
      removedUsers: widget.admins,
    );
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      if (_selectedTab == AddPeopleTab.contacts) {
        fetchAllUsers(name: value.trim());
      } else {
        setState(() {});
      }
    });
  }

  void _onContactTap(UserData user, bool isSelected) {
    if (!homeCubit.addToGroup(user, isSelected, widget.admins.length)) {
      Utils.showSnackBar(
          context, S.of(context).groupMembersLimitrichMessage);
    }
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
                AddMemberTopActionRow(
                  selectedCount: selected.length,
                  memberLimit: _memberLimit,
                  onClose: () => NavigationService().goBack(),
                  onSubmit: widget.onSubmit,
                ),
                AddMemberTabSwitcher(
                  selectedTab: _selectedTab,
                  onTabChanged: (tab) {
                    setState(() => _selectedTab = tab);
                    if (tab == AddPeopleTab.contacts) {
                      fetchAllUsers(name: searchController.text.trim());
                    }
                  },
                ),
                AddMemberSearchField(
                  controller: searchController,
                  onChanged: _onSearchChanged,
                  hintText: _selectedTab == AddPeopleTab.contacts
                      ? 'Search contacts...'
                      : 'Search recent chats...',
                  onClear: () {
                    _onSearchChanged('');
                    setState(() {});
                  },
                ),
                if (selected.isNotEmpty)
                  SelectedPeopleStrip(
                    selected: selected,
                    onRemove: (id) => homeCubit.removeSelectedGroupUser(id),
                  ),
                Expanded(
                  child: _selectedTab == AddPeopleTab.recentChats
                      ? AddMemberRecentChatsBody(
                          state: state,
                          onContactTap: _onContactTap,
                          searchQuery: searchController.text,
                          currentUserId: _currentUserId ?? '',
                          admins: widget.admins,
                        )
                      : AddMemberContactsBody(
                          state: state,
                          scrollController: scrollController,
                          onScrollNearEnd: _onScrollNearEnd,
                          onContactTap: _onContactTap,
                          searchQuery: searchController.text,
                          currentUserId: _currentUserId ?? '',
                          admins: widget.admins,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
