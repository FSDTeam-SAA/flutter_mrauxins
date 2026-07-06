import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:two_one_two_messenger/GoogleAds/BannerAds/BannerAdManager.dart';
import 'package:two_one_two_messenger/cubit/chat_cubit.dart';
import 'package:two_one_two_messenger/cubit/home_cubit.dart';
import 'package:two_one_two_messenger/cubit/home_state.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/date_format.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/all_user.dart';
import 'package:two_one_two_messenger/models/conversation_model.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/screens/chat_screen.dart';
import 'package:two_one_two_messenger/screens/new_group.dart';
import 'package:two_one_two_messenger/screens/report_user_screen.dart';
import 'package:two_one_two_messenger/screens/user_profile.dart';
import 'package:two_one_two_messenger/screens/voice_call_page.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/alert_dialog.dart';
import 'package:two_one_two_messenger/widgets/avatar_widgets.dart';
import 'package:two_one_two_messenger/widgets/buttons.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';

import '../cubit/chat_state.dart';
import '../utils/app_dialoge.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  // final _socketService = SocketService();

  String _activeRailLetter = 'A';
  final GlobalKey _railKey = GlobalKey();
  final Map<String, GlobalKey> _sectionKeys = {};

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
    // homeCubit.fetchContactsForSync(context);
    homeCubit.fetchContacts(context, "");
  }

  Future<void> _onScroll() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      homeCubit.loadMoreContacts(context, searchController.text.trim());
    }
    _updateActiveLetter();
  }

  void _updateActiveLetter() {
    if (_sectionKeys.isEmpty) return;
    String? active;
    // Walk all section keys; the last one whose top has scrolled at or above
    // a threshold near the top of the visible list area is the active letter.
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

  // Groups contacts alphabetically, preserving each contact's original index
  // in displayedContacts so that updateNickNameFromContact still works correctly.
  Map<String, List<MapEntry<int, ContactUser>>> _groupContactsWithIndices(
      List<ContactUser> contacts) {
    final indexed = contacts.asMap().entries.toList()
      ..sort((a, b) => (a.value.name ?? '')
          .toLowerCase()
          .compareTo((b.value.name ?? '').toLowerCase()));
    final grouped = <String, List<MapEntry<int, ContactUser>>>{};
    for (final entry in indexed) {
      final name = entry.value.name ?? '';
      final first = name.isEmpty ? '#' : name[0].toUpperCase();
      final letter = RegExp(r'[A-Z]').hasMatch(first) ? first : '#';
      grouped.putIfAbsent(letter, () => []).add(entry);
    }
    return grouped;
  }

  void _onRailInteraction(Offset globalPosition) {
    final railBox =
        _railKey.currentContext?.findRenderObject() as RenderBox?;
    if (railBox == null) return;
    final localY = railBox.globalToLocal(globalPosition).dy;
    final railHeight = railBox.size.height;
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ#';
    final idx =
        (localY / railHeight * letters.length).clamp(0, letters.length - 1).toInt();
    final letter = letters[idx];
    if (letter != _activeRailLetter) {
      setState(() => _activeRailLetter = letter);
    }
    _scrollToSection(letter);
  }

  // Returns the last available section that comes at or before [letter]
  // alphabetically, or the first section if none precede it.
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

    // Fast path: section widget already built in the viewport area
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
      return;
    }

    // Section not yet built — estimate position, jump, then fine-tune.
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
            .map(
              (letter) => Padding(
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
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> _onNewContactsTap() async {
    bool granted = false;
    try {
      granted = await FlutterContacts.requestPermission();
    } catch (e) {
      if (!mounted) return;
      Utils.showSnackBar(context, S.of(context).somethingWentWrongPleaseTryAgain);
      return;
    }
    if (!mounted) return;

    if (!granted) {
      await CustomAlertDialog(
        context: context,
        icon: SvgImage(
          source: SvgAssets.icSettings,
          color: AppColors.white,
          height: 28.w,
          width: 28.w,
        ),
        title: S.of(context).permissionRequired,
        description: S.of(context).askContactPermission,
        buttonText: S.of(context).openSetting,
        onPressed: () => openAppSettings(),
      );
      return;
    }

    try {
      await FlutterContacts.openExternalInsert();
      if (!mounted) return;
      await homeCubit.fetchContactsForSync(context);
      if (!mounted) return;
      await homeCubit.fetchContacts(context, searchController.text.trim());
    } catch (e) {
      if (!mounted) return;
      Utils.showSnackBar(
          context, S.of(context).somethingWentWrongPleaseTryAgain);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        leading: IconButton(
          onPressed: () async {
            await NavigationService().goBack();
          },
          icon: SvgImage(
              source: SvgAssets.icArrowBack,
              width: 20.w,
              color: AppColors.white),
        ),
        titleSpacing: 0.w,
        title: BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
          return state.searchContacts
              ? TextFormField(
                  controller: searchController,
                  onChanged: (query) {
                    homeCubit.onSearchContact(context, query);
                  },
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: S.of(context).sSearchContacts,
                    border: InputBorder.none,
                    filled: false,
                  ),
                )
              : Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).sContacts,
                          style: AppTextStyles.medium(fontSize: 20.sp),
                        ),
                      ],
                    ),
                  ],
                );
        }),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          // Adjust height of the divider
          child: Container(
            color: AppColors.darkAppBar, // Set divider color
            height: 1, // Divider thickness
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              homeCubit.handleSearchContact(
                context,
                () => searchController.clear(),
              );
            },
            behavior: HitTestBehavior.translucent,
            child: BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
              return Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.0).copyWith(right: 16),
                child: state.searchContacts
                    ? Icon(
                        Icons.close,
                        size: 20.w,
                        color: AppColors.white,
                      )
                    : SvgImage(
                        source: SvgAssets.icSearch,
                        width: 20.w,
                        height: 20.w,
                        color: AppColors.white,
                      ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: const BannerAdManager(),
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildNewItem(
                context: context,
                onTap: () {
                  homeCubit.cleanGroupData();
                  NavigationService().navigateTo(NewGroupScreen(
                    isGroup: true,
                  ));
                },
                icon: SvgAssets.person2,
                title: S.of(context).newGroup),
            24.s,
            buildNewItem(
                context: context,
                onTap: () => _onNewContactsTap(),
                icon: SvgAssets.icInviteFriends,
                title: S.of(context).newContacts),
            24.s,
            buildNewItem(
                context: context,
                onTap: () {
                  homeCubit.cleanGroupData();
                  NavigationService().navigateTo(NewGroupScreen(
                    isGroup: false,
                  ));
                },
                icon: SvgAssets.megaphone,
                title: S.of(context).newChannel),
            40.s,
            Text(
              S.of(context).sortedByLastSeenTime,
              style: AppTextStyles.medium(
                fontSize: 18.sp,
                color: AppColors.purpleText,
              ),
            ),
            22.s,
            Expanded(child: _contactsList())
          ],
        ),
      ),
    );
  }

  Widget _contactsList() {
    return BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
      if (state.contactsLoadingState == LoadingState.loading) {
        return const Center(child: CustomLoadingWidget());
      }
      if (state.displayedContacts.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(S.of(context).noContactsFound),
          ),
        );
      }

      final grouped = _groupContactsWithIndices(state.displayedContacts);
      final letters = grouped.keys.toList()..sort();

      // Pre-populate ALL section keys before the ListView renders them so
      // _nearestSection can locate any letter even when it is off-screen.
      for (final letter in letters) {
        _sectionKeys.putIfAbsent(letter, () => GlobalKey());
      }

      return Stack(
        children: [
          ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(right: 24.w, bottom: 20.h),
            itemCount: letters.length,
            itemBuilder: (context, i) {
              final letter = letters[i];
              final entries = grouped[letter] ?? [];
              _sectionKeys.putIfAbsent(letter, () => GlobalKey());

              return Column(
                key: _sectionKeys[letter],
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 8.h, bottom: 6.h),
                    child: Text(
                      letter,
                      style: AppTextStyles.medium(
                        fontSize: 13.sp,
                        color: AppColors.purpleText,
                      ),
                    ),
                  ),
                  ...entries.map((entry) {
                    final user = entry.value;
                    final originalIndex = entry.key;
                    final phone = (user.phone ?? "").isEmpty
                        ? ""
                        : "${user.countryCode ?? ""}${user.phone ?? ""}";
                    return contactTile(
                      context: context,
                      onTap: () => gotoChatScreen(user),
                      isRegistered: user.isRegistered ?? false,
                      profilePic: user.profilePicture ?? "",
                      name: user.name ?? "Unknown",
                      phone: phone,
                      isOnline: user.isOnline ?? false,
                      lastSeen: user.lastSeen != null
                          ? DateTime.parse(user.lastSeen!).toLocal()
                          : null,
                      contactUser: user,
                      index: originalIndex,
                    );
                  }),
                  8.s,
                ],
              );
            },
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: _alphabetRail(letters),
          ),
        ],
      );
    });
  }

  Widget buildNewItem(
      {required BuildContext context,
      required void Function() onTap,
      required String icon,
      required String title}) {
    return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.translucent,
        child: Row(
          children: [
            SvgImage(
              source: icon,
            ),
            18.s,
            Text(
              title,
              style: AppTextStyles.medium(fontSize: 20.sp),
            )
          ],
        ));
  }

  Widget contactTile({
    required BuildContext context,
    required void Function() onTap,
    required String name,
    required String phone,
    required String profilePic,
    required bool isRegistered,
    required bool isOnline,
    required DateTime? lastSeen,
    required ContactUser? contactUser,
    required int index,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return Column(
            children: [
              Row(
                children: [
                  AvatarWidgets(
                    userPic: profilePic,
                    height: 50,
                    width: 50,
                  ),
                  16.s,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (state.displayedContacts[index].isActiveNickname ??
                                  false)
                              ? (state.displayedContacts[index].nickName ??
                                  state.displayedContacts[index].name ??
                                  "")
                              : name,
                          // name,
                          // contactUser?.nickName ?? contactUser?.name ?? "",
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.medium(
                            fontSize: 18.sp,
                          ),
                        ),
                        6.s,
                        Text(
                          isOnline
                              ? S.of(context).online
                              : (lastSeen != null)
                                  ? "${S.of(context).sLastSeen}${lastSeen.formattedDateWithDayMonthAtTime}"
                                  : phone,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.regular(
                              fontSize: 13.sp,
                              color: AppColors.white.withValues(alpha: 0.5)),
                        )
                      ],
                    ),
                  ),
                  16.s,
                  if ((!isRegistered))
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
                            fontSize: 13.sp, color: AppColors.purpleText),
                      ),
                    ),
                  if (isRegistered && contactUser != null) //
                    _buildOptionView(contactUser: contactUser, index: index)
                ],
              ),
              16.s,
            ],
          );
        },
      ),
    );
  }

  Widget _buildOptionView(
      {required ContactUser contactUser, required int index}) {
    return PopupMenuButton<String>(
      color: AppColors.darkAppBar,
      icon: Icon(
        Icons.more_vert,
        color: Colors.white,
      ),
      // onSelected: (value) {
      //   if (value == 'clearChat') {
      //     // Your clear chat logic
      //   }
      // },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'viewContact',
          child: Row(
            children: [
              SvgImage(
                source: SvgAssets.icPerson,
                color: AppColors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  S.of(context).viewContact,
                  style: AppTextStyles.regular(fontSize: 16.sp),
                ),
              ),
            ],
          ),
          onTap: () {
            debugPrint("ContactUserId ${contactUser.sId}");
            // ContactUser contact = ContactUser(...); // populated contact
            UserData user = UserData.fromContactUser(contactUser);
            NavigationService().navigateTo(
              UserProfileScreen(
                user: user,
                onNickNameChange: ({required newNickName, required newStatus}) {
                  homeCubit.updateNickNameFromContact(
                    index: index,
                    nickName: newNickName,
                    contactUser: contactUser,
                    isActiveNickname: newStatus,
                  );
                },
                // onNickNameChange: (newNickName) {
                //   homeCubit.updateNickNameFromContact(
                //     index: index,
                //     nickName: newNickName,
                //     contactUser: contactUser,
                //   );
                // },
                onNickNameStatusChangge: (newStatus) {
                  homeCubit.updateStatusFromContact(
                    index: index,
                    newStatus: newStatus,
                    contactUser: contactUser,
                  );
                },
              ),
            );
          },
        ),
        // if (contactUser.chatId != null)
        PopupMenuItem<String>(
          value: 'sendMessage',
          child: Row(
            children: [
              Icon(Icons.message, color: AppColors.white, size: 24),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(
                S.of(context).sendMessage,
                style: AppTextStyles.regular(fontSize: 16.sp),
              )),
            ],
          ),
          onTap: () => gotoChatScreen(contactUser),
        ),

        if (contactUser.chatId != null)
          PopupMenuItem<String>(
            value: 'audioCall',
            child: Row(
              children: [
                Icon(Icons.call, color: AppColors.white, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    S.of(context).call,
                    style: AppTextStyles.regular(fontSize: 16.sp),
                  ),
                ),
              ],
            ),
            onTap: () => onClickAudioVideoCall(
              contactUser: contactUser,
              callType: CallType.voice,
            ),
          ),

        if (contactUser.chatId != null)
          PopupMenuItem<String>(
            value: 'videoCall',
            child: Row(
              children: [
                Icon(Icons.video_call, color: AppColors.white, size: 24),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(
                  S.of(context).videoCall,
                  style: AppTextStyles.regular(fontSize: 16.sp),
                )),
              ],
            ),
            onTap: () => onClickAudioVideoCall(
                contactUser: contactUser, callType: CallType.video),
          ),

        // if (contactUser.chatId != null)
        //   PopupMenuItem<String>(
        //     value: 'disapperingMessages',
        //     child: Row(
        //       children: [
        //         Icon(Icons.timer, color: AppColors.white, size: 24),
        //         const SizedBox(width: 8),
        //         Expanded(
        //             child: Text(
        //           S.of(context).disappearingMessage,
        //           style: AppTextStyles.regular(fontSize: 16.sp),
        //         )),
        //       ],
        //     ),
        //     onTap: () {
        //       final chatId = contactUser.chatId;

        //       if (chatId == null) {
        //         Utils.showSnackBar(context, "Conversation not Started");
        //         return;
        //       }
        //       // debugPrint("TIME p0");
        //       // debugPrint(
        //       //     "contactUser.messageAutoDeleteTime ${contactUser.messageAutoDeleteTime}");
        //       showDisappearingMessageTimerSheet(
        //         context,
        //         contactUser.messageAutoDeleteTime ?? 0,
        //         (p0) async {
        //           String senderId = userDataCubit.state?.sId ??
        //               (await chatCubit.dbHelper.getLoginData())?.sId ??
        //               "";
        //           showMessage("updateMessageAutoDeleteTime call => ${{
        //             "chatId": chatId,
        //             "messageAutoDeleteTime": p0,
        //             "messageId":
        //                 DateTime.now().millisecondsSinceEpoch.toString(),
        //             "userId": senderId
        //           }}");

        //           _socketService
        //               .sendEvent(AppConstants.updateMessageAutoDeleteTime, {
        //             "chatId": chatId,
        //             "messageAutoDeleteTime": p0,
        //             "messageId":
        //                 DateTime.now().millisecondsSinceEpoch.toString(),
        //             "userId": senderId
        //           });
        //           homeCubit.updateChatDisAppear(index: index, timeValue: p0);
        //         },
        //       );
        //     },
        //   ),
        PopupMenuItem<String>(
          value: 'reportUser',
          child: Row(
            children: [
              Icon(Icons.report, color: AppColors.white, size: 24),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(
                S.of(context).reportUser,
                style: AppTextStyles.regular(fontSize: 16.sp),
              )),
            ],
          ),
          onTap: () {
            NavigationService().navigateTo(ReportUserPage(
              onReport: (reason, description) async {
                showMessage("Report User $reason   $description");
                final userId = contactUser.sId;
                if (userId != null) {
                  await homeCubit.reportUser(
                    userId: contactUser.sId ?? "",
                    userName: contactUser.userName ?? "",
                    reason: reason,
                    description: description,
                    context: context,
                  );
                }
              },
            ));
          },
        ),
        if (contactUser.chatId != null)
          PopupMenuItem<String>(
            value: 'blockedUser',
            child: Row(
              children: [
                Icon(
                  (contactUser.youBlocked ?? false)
                      ? Icons.person_off
                      : Icons.block,
                  color: AppColors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    (contactUser.youBlocked ?? false)
                        ? S.of(context).unBlockUser
                        : S.of(context).blockUser,
                    style: AppTextStyles.regular(fontSize: 16.sp),
                  ),
                ),
              ],
            ),
            onTap: () {
              final chatId = contactUser.chatId;

              if (chatId == null) {
                Utils.showSnackBar(context, "Conversation not Started");
                return;
              }

              if ((contactUser.youBlocked ?? false)) {
                showCommonBlockUserDialog(
                    context: context,
                    icon: Icons.person_off,
                    onSubmit: () {
                      homeCubit.unBlockedUser(
                        userId: contactUser.sId ?? "",
                        context: context,
                        callback: () async {
                          homeCubit.toggleBlockUnBlock(
                            index: index,
                            youBlocked: false,
                          );
                          Utils.showSnackBar(
                            context,
                            S.of(context).unblockUserSuccessfully(
                                contactUser.name ?? ""),
                          );
                          // homeCubit.fetchContacts(context, "");
                        },
                      );
                    },
                    title: S.of(context).unblockUserTitle,
                    subTitle: S
                        .of(context)
                        .unblockUserSubtitle(contactUser.name ?? ""));
              } else {
                showCommonBlockUserDialog(
                  context: context,
                  onSubmit: () {
                    homeCubit.blockedUser(
                      chatId: chatId,
                      // ??
                      //     chatCubit.state.currentConversationId ??
                      //     widget.chatId,
                      userId: contactUser.sId ?? "",
                      context: context,
                      callback: () async {
                        // chatCubit.handleUnblockUser(true);
                        homeCubit.toggleBlockUnBlock(
                            index: index, youBlocked: true);
                        Utils.showSnackBar(
                            context,
                            S
                                .of(context)
                                .blockUserSuccessfully(contactUser.name ?? ""));
                        // homeCubit.fetchContacts(context, "");
                      },
                    );
                  },
                  title: S.of(context).blockUserTitle,
                  subTitle: S.of(context).blockUserSubtitle(
                      contactUser.name ?? S.of(context).blockedContacts),
                );
              }
            },
          ),
        // if (contactUser.chatId != null)
        //   PopupMenuItem<String>(
        //     value: 'clearChat',
        //     child: Row(
        //       children: [
        //         SvgImage(
        //           source: SvgAssets.clearChat,
        //           color: AppColors.white,
        //         ),
        //         const SizedBox(width: 8),
        //         Expanded(
        //             child: Text(
        //           S.of(context).clearChat,
        //           style: AppTextStyles.regular(fontSize: 16.sp),
        //         )),
        //       ],
        //     ),
        //     onTap: () async {
        //       String? chatId = contactUser.chatId;
        //       // debugPrint("ChatId >> ${contactUser.chatId.toString()}");
        //       if (chatId == null) {
        //         Utils.showSnackBar(context, "Conversation not Started");
        //         return;
        //       }
        //       await showClearChatDialog(context, chatId: chatId);
        //       // Navigator.pop(context);
        //     },
        //   ),
      ],
    );
  }

  Future<void> showClearChatDialog(BuildContext context,
      {required String chatId}) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return BlocBuilder<ChatCubit, ChatState>(
            builder: (contextMessage, state) {
          return Dialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26.r),
            ), //this right here
            child: SizedBox(
              width: double.infinity,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.dark,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        S.of(context).clearChat,
                        style: AppTextStyles.medium(fontSize: 20.sp),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        S.of(context).lblClearChatSubTitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.regular(
                            fontSize: 14.sp,
                            color: AppColors.textColorSecondary),
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: CustomButton(
                              onPressed: () async =>
                                  await NavigationService().goBack(),
                              backgroundColor: AppColors.btnGrey,
                              child: Text(
                                S.of(context).cancel,
                                style: AppTextStyles.medium(
                                  fontSize: 16.sp,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: CustomButton(
                              onPressed: () async {
                                await chatCubit.clearChat(
                                  chatId,
                                  callback: (response) {
                                    Navigator.of(context).pop();
                                    Utils.showSnackBar(
                                        context, response.message ?? '',
                                        seconds: 3);
                                  },
                                );
                                await context
                                    .read<HomeCubit>()
                                    .getConversation(context: context);
                              },
                              child: Text(
                                S.of(context).clear,
                                style: AppTextStyles.medium(
                                  fontSize: 16.sp,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  void gotoChatScreen(ContactUser user) async {
    if (user.isRegistered ?? false) {
      debugPrint("userChatId >> ${user.chatId}");
      showMessage("call ===>");
      ParticipantDetail sender = ParticipantDetail.fromJson(user.toJson());
      showMessage("call ===>  ${sender.toJson()}");
      await chatCubit.resetChatScreenState();
      NavigationService().replaceWith(
        ChatScreen(
          chatType: ChatType.one_to_one,
          sender: sender,
          unreadMessageCount: 0,
          // userName: user.name ?? "",
          userName: (user.isActiveNickname ?? false)
              ? (user.nickName ?? "")
              : (user.name ?? ""),
          // userName: (user.nickName ?? ""),
          userId: user.sId ?? "",
          userPic: user.profilePicture ?? "",
          chatId: '',
          aesKey: '',
          isSendMessage: true,
          isShowProfileImage: true,
        ),
      );
    }
  }

  void onClickAudioVideoCall({
    required ContactUser contactUser,
    required CallType callType,
  }) {
    NavigationService().navigateTo(
      CallingPage(
        callType: callType,
        currentConversationId: contactUser.chatId ?? "",
        image: contactUser.profilePicture ?? "",
        receiverId: contactUser.sId,
        name: (contactUser.isActiveNickname ?? false)
            ? (contactUser.nickName ?? contactUser.name ?? "")
            : (contactUser.name ?? ""),
        isActive: false,
        from: "chatPage",
      ),
    );
  }
}
