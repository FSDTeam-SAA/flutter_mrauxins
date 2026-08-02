import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/GoogleAds/BannerAds/BannerAdManager.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';

import '../utils/colors.dart';
import '../widgets/appbar.dart';
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
    if (query.trim().isEmpty) {
      // Don't fetch or show anything until the user actually searches — the
      // results area shows a placeholder instead (see DatabaseBody).
      setState(() {
        _databaseResults = [];
        _databaseLoading = false;
      });
      return;
    }
    setState(() => _databaseLoading = true);
    groupCubit.repository.searchDatabase(search: query).then((results) {
      if (mounted) {
        final q = query.toLowerCase();
        final all = results.cast<Map<String, dynamic>>();
        final filtered = all.where((item) {
          final name = (item['name'] ?? '').toString().toLowerCase();
          final userName = (item['userName'] ?? '').toString().toLowerCase();
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
            SizedBox(
              height: 42.h,
              child: TextField(
                controller: searchController,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.go,
                style: AppTextStyles.regular(fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: _selectedTab == SearchTab.database
                      ? 'Search the 212 Database...'
                      : S.of(context).searchUsers,
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
