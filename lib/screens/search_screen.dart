import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/GoogleAds/BannerAds/BannerAdManager.dart';
import 'package:two_one_two_messenger/cubit/home_cubit.dart';
import 'package:two_one_two_messenger/cubit/home_state.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/date_format.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/all_user.dart';
import 'package:two_one_two_messenger/models/conversation_model.dart';
import 'package:two_one_two_messenger/screens/channel_info.dart';
import 'package:two_one_two_messenger/screens/chat_screen.dart';
import 'package:two_one_two_messenger/screens/group_info.dart';
import 'package:two_one_two_messenger/services/api_config.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/widgets/avatar_widgets.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';

import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/text_style.dart';
import '../utils/utils.dart';
import '../widgets/appbar.dart';
import '../widgets/svg_images.dart';
import '../widgets/text_fields.dart';

enum _SearchTab { database, contacts }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final searchController = TextEditingController();
  final scrollController = ScrollController();
  _SearchTab _selectedTab = _SearchTab.database;
  Timer? _searchDebounce;

  // Database tab state
  List<Map<String, dynamic>> _databaseResults = [];
  bool _databaseLoading = false;

  // A-Z rail state (shared by both tabs)
  String _activeRailLetter = 'A';
  final _railKey = GlobalKey();
  final Map<String, GlobalKey> _sectionKeys = {};

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_updateActiveLetter);
    _searchDatabase("");
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      if (_selectedTab == _SearchTab.database) {
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

  void _switchTab(_SearchTab tab) {
    if (tab == _selectedTab) return;
    setState(() {
      _selectedTab = tab;
      searchController.clear();
      _activeRailLetter = 'A';
      _sectionKeys.clear();
    });
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
    if (tab == _SearchTab.contacts) {
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
            _tabSwitcher(),
            16.s,
            CustomTextField(
              controller: searchController,
              onChanged: _onSearchChanged,
              maxLines: 1,
              textInputAction: TextInputAction.go,
              label: _selectedTab == _SearchTab.database
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
              child: _selectedTab == _SearchTab.database
                  ? _databaseBody()
                  : _contactsBody(),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Tab Switcher ───
  Widget _tabSwitcher() {
    return Container(
      height: 42.h,
      decoration: BoxDecoration(
        color: AppColors.dialogBg,
        borderRadius: BorderRadius.circular(24.r),
        border:
            Border.all(color: const Color(0xFF86334D).withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          _tabButton(_SearchTab.database, 'Database'),
          _tabButton(_SearchTab.contacts, 'Contacts'),
        ],
      ),
    );
  }

  Widget _tabButton(_SearchTab tab, String label) {
    final isSelected = _selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchTab(tab),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF86334D) : Colors.transparent,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Text(
            label,
            style: AppTextStyles.medium(
              fontSize: 14.sp,
              color: isSelected
                  ? AppColors.white
                  : AppColors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  void _updateActiveLetter() {
    if (_sectionKeys.isEmpty) return;
    String? active;
    for (final entry in _sectionKeys.entries) {
      final ctx = entry.value.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final topY = box.localToGlobal(Offset.zero).dy;
      if (topY <= 260) active = entry.key;
    }
    if (active != null && active != _activeRailLetter) {
      setState(() => _activeRailLetter = active!);
    }
  }

  // ─── Shared A-Z grouping ───
  Map<String, List<T>> _groupByName<T>(
      List<T> items, String Function(T) nameOf) {
    final sorted = [...items]
      ..sort((a, b) => nameOf(a).toLowerCase().compareTo(nameOf(b).toLowerCase()));
    final grouped = <String, List<T>>{};
    for (final item in sorted) {
      final name = nameOf(item);
      final first = name.isEmpty ? '#' : name[0].toUpperCase();
      final key = RegExp(r'[A-Z]').hasMatch(first) ? first : '#';
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }

  Widget _groupedListWithRail<T>({
    required List<T> items,
    required String Function(T) nameOf,
    required Widget Function(T) tileBuilder,
    required Widget emptyState,
    ScrollController? controller,
  }) {
    if (items.isEmpty) return emptyState;

    final grouped = _groupByName(items, nameOf);
    final letters = grouped.keys.toList()..sort();

    for (final letter in letters) {
      _sectionKeys.putIfAbsent(letter, () => GlobalKey());
    }

    return Stack(
      children: [
        ListView.builder(
          controller: controller,
          padding: EdgeInsets.only(right: 24.w),
          itemCount: letters.length,
          itemBuilder: (context, index) {
            final letter = letters[index];
            final sectionItems = grouped[letter]!;
            _sectionKeys.putIfAbsent(letter, () => GlobalKey());

            return Column(
              key: _sectionKeys[letter],
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 6.h, bottom: 8.h),
                  child:
                      Text(letter, style: AppTextStyles.medium(fontSize: 13.sp)),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.dialogBg.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                        color: const Color(0xFF86334D).withValues(alpha: 0.35)),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sectionItems.length,
                    itemBuilder: (context, i) => tileBuilder(sectionItems[i]),
                    separatorBuilder: (_, __) => Padding(
                      padding: EdgeInsets.only(left: 58.w),
                      child: Divider(
                          height: 1, color: AppColors.white.withValues(alpha: 0.06)),
                    ),
                  ),
                ),
                12.s,
              ],
            );
          },
        ),
        Positioned(
          right: 2.w,
          top: 4.h,
          bottom: 8.h,
          child: _alphabetRail(letters),
        ),
      ],
    );
  }

  // ─── Database Tab ───
  Widget _databaseBody() {
    if (_databaseLoading && _databaseResults.isEmpty) {
      return const Center(child: CustomLoadingWidget());
    }
    return _groupedListWithRail<Map<String, dynamic>>(
      items: _databaseResults,
      nameOf: (item) => (item['name'] ?? '') as String,
      tileBuilder: _databaseResultTile,
      controller: scrollController,
      emptyState: Center(
        child: Text(
          searchController.text.isEmpty
              ? 'Search for public users, groups & channels'
              : S.of(context).noContactsFound,
          style: AppTextStyles.regular(
              fontSize: 14.sp, color: AppColors.white.withValues(alpha: 0.5)),
        ),
      ),
    );
  }

  Widget _databaseResultTile(Map<String, dynamic> item) {
    final resultType = item['resultType'] ?? 'user';
    final name = item['name'] ?? '';
    final image = item['profilePicture'] ?? item['groupImage'] ?? '';

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _onDatabaseItemTap(item),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
        child: Row(
          children: [
            AvatarWidgets(
              userPic: resultType == 'user' ? image : '${Urls.mediaUrl}$image',
              svgAvatar: resultType == 'channel'
                  ? SvgAssets.megaphone
                  : resultType == 'group'
                      ? SvgAssets.person2
                      : SvgAssets.icPerson,
              height: 42,
              width: 42,
            ),
            12.s,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.medium(fontSize: 15.sp)),
                  4.s,
                  Text(
                    _databaseSubtitle(item),
                    style: AppTextStyles.regular(
                        fontSize: 12.sp,
                        color: AppColors.white.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ),
            if (resultType != 'user' && (item['isMember'] ?? false))
              Text('Joined',
                  style:
                      AppTextStyles.regular(fontSize: 12.sp, color: Colors.green)),
          ],
        ),
      ),
    );
  }

  String _databaseSubtitle(Map<String, dynamic> item) {
    final type = item['resultType'] ?? 'user';
    if (type == 'user') {
      final isOnline = item['isOnline'] ?? false;
      if (isOnline) return S.of(context).online;
      final lastSeen = item['lastSeen'];
      if (lastSeen != null) {
        return "${S.of(context).sLastSeen}${DateTime.parse(lastSeen).toLocal().formattedDateWithDayMonthAtTime}";
      }
      return '';
    }
    final memberCount = item['memberCount'] ?? 0;
    return '${type == 'channel' ? 'Channel' : 'Group'} · $memberCount members';
  }

  Future<void> _onDatabaseItemTap(Map<String, dynamic> item) async {
    final type = item['resultType'] ?? 'user';
    final id = item['_id'] ?? '';
    if (id.isEmpty) return;

    if (type == 'user') {
      final sender = ParticipantDetail(
        id: id,
        name: item['name'],
        userName: item['userName'],
        profilePicture: item['profilePicture'],
        lastSeen: item['lastSeen'],
        isOnline: item['isOnline'],
      );
      await chatCubit.resetChatScreenState();
      NavigationService().replaceWith(ChatScreen(
        chatType: ChatType.one_to_one,
        sender: sender,
        unreadMessageCount: 0,
        userName: item['name'] ?? '',
        userId: id,
        userPic: item['profilePicture'] ?? '',
        chatId: '',
        aesKey: '',
        isSendMessage: true,
        isShowProfileImage: true,
      ));
    } else {
      final user = await homeCubit.dbHelper.getLoginData();
      if (user == null) return;
      if (type == 'channel') {
        NavigationService()
            .navigateTo(ChannelInfoScreen(currentUser: user, groupId: id));
      } else {
        NavigationService()
            .navigateTo(GroupInfoScreen(currentUser: user, groupId: id));
      }
    }
  }

  // ─── Contacts Tab ───
  // Shows every contact stored on the device (matched via saved phone
  // number or email), regardless of whether they have a registered 212
  // account. Registered contacts open a chat on tap; unregistered ones
  // show an "Invite Friend" action instead, matching the standalone
  // Contacts/Invite Friends screens.
  Widget _contactsBody() {
    return BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
      if (state.contactsLoadingState == LoadingState.loading) {
        return const Center(child: CustomLoadingWidget());
      }
      return _groupedListWithRail<ContactUser>(
        items: state.displayedContacts,
        nameOf: (u) => u.name ?? '',
        tileBuilder: _contactTile,
        controller: scrollController,
        emptyState: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(S.of(context).noContactsFound),
          ),
        ),
      );
    });
  }

  Widget _contactTile(ContactUser user) {
    final isRegistered = user.isRegistered ?? false;
    final phone = (user.phone ?? "").isEmpty
        ? ""
        : "${user.countryCode ?? ""}${user.phone ?? ""}";

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: isRegistered
          ? () async {
              ParticipantDetail sender =
                  ParticipantDetail.fromJson(user.toJson());
              await chatCubit.resetChatScreenState();
              NavigationService().replaceWith(ChatScreen(
                chatType: ChatType.one_to_one,
                sender: sender,
                unreadMessageCount: 0,
                userName: user.name ?? "",
                userId: user.sId ?? "",
                userPic: user.profilePicture ?? "",
                chatId: '',
                aesKey: '',
                isSendMessage: true,
                isShowProfileImage: true,
              ));
            }
          : null,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
        child: Row(
          children: [
            AvatarWidgets(
                userPic: user.profilePicture ?? "", height: 42, width: 42),
            12.s,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name ?? "Unknown",
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.medium(fontSize: 15.sp)),
                  4.s,
                  Text(
                    (user.isOnline ?? false)
                        ? S.of(context).online
                        : (user.lastSeen != null)
                            ? "${S.of(context).sLastSeen}${DateTime.parse(user.lastSeen!).toLocal().formattedDateWithDayMonthAtTime}"
                            : (isRegistered ? "" : phone),
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.regular(
                        fontSize: 12.sp,
                        color: AppColors.white.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ),
            if (!isRegistered)
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (phone.isNotEmpty) {
                    Utils.sendSMS(
                        phone,
                        Platform.isIOS
                            ? AppConstants.inviteLinkForIos
                            : AppConstants.inviteLinkForAndroid);
                  }
                },
                child: Text(
                  S.of(context).inviteFriend,
                  style: AppTextStyles.regular(
                      fontSize: 12.sp, color: AppColors.purpleText),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── A-Z Rail ───
  void _onRailInteraction(Offset globalPosition) {
    final railBox = _railKey.currentContext?.findRenderObject() as RenderBox?;
    if (railBox == null) return;
    final localY = railBox.globalToLocal(globalPosition).dy;
    final railHeight = railBox.size.height;
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ#';
    final index = (localY / railHeight * letters.length)
        .clamp(0, letters.length - 1)
        .toInt();
    final letter = letters[index];
    if (letter != _activeRailLetter) {
      setState(() => _activeRailLetter = letter);
    }
    _scrollToSection(letter);
  }

  String? _nearestSection(String letter) {
    if (_sectionKeys.isEmpty) return null;
    if (_sectionKeys.containsKey(letter)) return letter;
    const all = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ#';
    final pos = all.indexOf(letter);
    final sorted = _sectionKeys.keys.toList()..sort();
    String? lastBefore;
    for (final avail in sorted) {
      if (all.indexOf(avail) < pos) {
        lastBefore = avail;
      } else {
        break;
      }
    }
    return lastBefore ?? sorted.first;
  }

  void _scrollToSection(String letter) {
    final target = _nearestSection(letter);
    if (target == null) return;

    final key = _sectionKeys[target];

    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
      return;
    }

    if (!scrollController.hasClients) return;
    final sorted = _sectionKeys.keys.toList()..sort();
    final rank = sorted.indexOf(target);
    if (rank < 0) return;

    final maxExtent = scrollController.position.maxScrollExtent;
    final estimated =
        sorted.length <= 1 ? 0.0 : maxExtent * rank / (sorted.length - 1);
    scrollController.jumpTo(estimated.clamp(0.0, maxExtent));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final k = _sectionKeys[target];
      if (k?.currentContext != null) {
        Scrollable.ensureVisible(k!.currentContext!,
            duration: const Duration(milliseconds: 100));
      }
    });
  }

  Widget _alphabetRail(List<String> availableLetters) {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ#';
    return GestureDetector(
      key: _railKey,
      onVerticalDragUpdate: (d) => _onRailInteraction(d.globalPosition),
      onTapDown: (d) => _onRailInteraction(d.globalPosition),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: letters
            .split('')
            .map((letter) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    letter,
                    style: AppTextStyles.medium(
                      fontSize: 10.sp,
                      color: letter == _activeRailLetter
                          ? Colors.red
                          : availableLetters.contains(letter)
                              ? AppColors.white.withValues(alpha: 0.8)
                              : AppColors.white.withValues(alpha: 0.25),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
