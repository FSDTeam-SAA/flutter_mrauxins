import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/GoogleAds/BannerAds/BannerAdManager.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';

import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/appbar.dart';
import '../widgets/svg_images.dart';
import '../widgets/text_fields.dart';
import 'search/contacts_body.dart';
import 'search/database_body.dart';
import 'search/search_tab.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final searchController = TextEditingController();
  SearchTab _selectedTab = SearchTab.database;
  Timer? _searchDebounce;

  // Database tab state
  List<Map<String, dynamic>> _databaseResults = [];
  bool _databaseLoading = false;

  @override
  void initState() {
    super.initState();
    _searchDatabase("");
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      if (_selectedTab == SearchTab.database) {
        _searchDatabase(query);
      } else {
        homeCubit.onSearchContact(context, query);
      }
    });
  }

  void _searchDatabase(String query) {
    setState(() => _databaseLoading = true);
    homeCubit.apiClient.searchDatabase(search: query).then((results) {
      if (mounted) {
        final q = query.toLowerCase();
        final all = results.cast<Map<String, dynamic>>();
        final filtered = q.isEmpty
            ? all
            : all.where((item) {
                final name = (item['name'] ?? '').toString().toLowerCase();
                final userName =
                    (item['userName'] ?? '').toString().toLowerCase();
                return name.startsWith(q) || userName.startsWith(q);
              }).toList();
        setState(() {
          _databaseResults = filtered;
          _databaseLoading = false;
        });
      }
    }).catchError((_) {
      if (mounted) setState(() => _databaseLoading = false);
    });
  }

  void _switchTab(SearchTab tab) {
    if (tab == _selectedTab) return;
    setState(() {
      _selectedTab = tab;
      searchController.clear();
    });
    if (tab == SearchTab.contacts) {
      // Loads every device contact (registered + unregistered) — the
      // shared SQLite-backed path also used by the standalone Contacts
      // and Invite Friends screens.
      homeCubit.fetchContacts(context, "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        isBackShow: true,
        title: S.of(context).lblSearchUser,
        isActionsShow: false,
      ),
      bottomNavigationBar: const BannerAdManager(),
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Column(
          children: [
            SearchTabSwitcher(
              selectedTab: _selectedTab,
              onTabChanged: _switchTab,
            ),
            16.s,
            CustomTextField(
              controller: searchController,
              onChanged: _onSearchChanged,
              maxLines: 1,
              textInputAction: TextInputAction.go,
              label: _selectedTab == SearchTab.database
                  ? 'Search the 212 Database...'
                  : S.of(context).searchUsers,
              prefixIcon: SvgImage(
                source: SvgAssets.icSearch,
                fit: BoxFit.scaleDown,
                color: AppColors.white,
              ),
              validator: (_) => null,
            ),
            16.s,
            Expanded(
              child: _selectedTab == SearchTab.database
                  ? DatabaseBody(
                      results: _databaseResults,
                      isLoading: _databaseLoading,
                      searchQuery: searchController.text,
                    )
                  : const ContactsBody(),
            ),
          ],
        ),
      ),
    );
  }
}
