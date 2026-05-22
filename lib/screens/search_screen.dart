import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
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
import 'package:two_one_two_messenger/models/group_info_model.dart';
import 'package:two_one_two_messenger/screens/chat_screen.dart';
import 'package:two_one_two_messenger/screens/new_group.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/widgets/avatar_widgets.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';

import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../models/otp_verify.dart';
import '../services/api_client.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/text_style.dart';
import '../utils/utils.dart';
import '../widgets/appbar.dart';
import '../widgets/network_image.dart';
import '../widgets/svg_images.dart';
import '../widgets/text_fields.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
    homeCubit.fetchContacts(context, "");
  }

  Future<void> _onScroll() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      homeCubit.loadMoreContacts(context, searchController.text.trim());
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
      // AppBar(
      //   backgroundColor: AppColors.dark,
      //   leading: IconButton(
      //     onPressed: () async {
      //       await NavigationService().goBack();
      //     },
      //     icon: SvgImage(
      //         source: SvgAssets.icArrowBack,
      //         width: 20.w,
      //         color: AppColors.white),
      //   ),
      //   titleSpacing: 0.w,
      //   title: BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
      //     return state.searchContacts
      //         ? TextFormField(
      //             controller: searchController,
      //             onChanged: (query) {
      //               homeCubit.onSearchContact(query);
      //             },
      //             autofocus: true,
      //             decoration: InputDecoration(
      //               hintText: AppConstants.sSearchContacts,
      //               border: InputBorder.none,
      //               filled: false,
      //             ),
      //           )
      //         : Row(
      //             children: [
      //               Column(
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: [
      //                   Text(
      //                     AppConstants.sContacts,
      //                     style: AppTextStyles.medium(fontSize: 20.sp),
      //                   ),
      //                 ],
      //               ),
      //             ],
      //           );
      //   }),
      //   bottom: PreferredSize(
      //     preferredSize: const Size.fromHeight(1),
      //     // Adjust height of the divider
      //     child: Container(
      //       color: AppColors.darkAppBar, // Set divider color
      //       height: 1, // Divider thickness
      //     ),
      //   ),
      //   actions: [
      //     GestureDetector(
      //       onTap: () {
      //         homeCubit.handleSearchContact(
      //           () => searchController.clear(),
      //         );
      //       },
      //       behavior: HitTestBehavior.translucent,
      //       child: BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
      //         return Padding(
      //           padding:
      //               EdgeInsets.symmetric(horizontal: 8.0).copyWith(right: 16),
      //           child: state.searchContacts
      //               ? Icon(
      //                   Icons.close,
      //                   size: 20.w,
      //                   color: AppColors.white,
      //                 )
      //               : SvgImage(
      //                   source: SvgAssets.icSearch,
      //                   width: 20.w,
      //                   height: 20.w,
      //                   color: AppColors.white,
      //                 ),
      //         );
      //       }),
      //     ),
      //   ],
      // ),

      bottomNavigationBar: const BannerAdManager(),
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: ListView(
          controller: scrollController,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: searchController,
              onChanged: (query) {
                homeCubit.onSearchContact(context, query);
              },
              maxLines: 1, textInputAction: TextInputAction.go,
              label: S.of(context).searchUsers,
              prefixIcon: SvgImage(
                source: SvgAssets.icSearch,
                fit: BoxFit.scaleDown,
                color: AppColors.white,
              ),
              // onChanged: (value) => _onSearchTextChange(value, context),
              validator: (value) {
                return null;
              },
            ),
            24.s,
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
                onTap: () async {
                  await FlutterContacts.openExternalInsert().then(
                    (value) {
                      homeCubit.fetchContactsForSync(context);
                    },
                  );
                  homeCubit.fetchContacts(
                      context, searchController.text.trim());
                },
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
            // Text(
            //   S.of(context).sortedByLastSeenTime,
            //   style: AppTextStyles.medium(
            //     fontSize: 18.sp,
            //     color: AppColors.purpleText,
            //   ),
            // ),
            // 22.s,
            _contactsList()
          ],
        ),
      ),
    );
  }

  Widget _contactsList() {
    // if (_permissionDenied) return Center(child: Text('Permission denied'));
    // if (_contacts == null) return Center(child: CustomLoadingWidget());
    return BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
      if (state.contactsLoadingState == LoadingState.loading) {
        return Center(child: CustomLoadingWidget());
      } else if (state.contactsLoadingState == LoadingState.success) {
        if ((state.displayedContacts ?? []).isEmpty &&
            (state.otherContact ?? Set.of([])).isEmpty) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(S.of(context).noContactsFound),
          ));
        }
      }
      // print("other Users== ${(state.otherContact ?? Set.of([]))}");
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.builder(
            // controller: scrollController,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: state.displayedContacts.length,
            itemBuilder: (context, i) {
              ContactUser user = state.displayedContacts[i];
              String phone = (user.phone ?? "").isEmpty
                  ? ""
                  : "${user.countryCode ?? ""}${user.phone ?? ""}";
              return contactTile(
                  context: context,
                  onTap: () async {
                    if (user.isRegistered ?? false) {
                      showMessage("call ===>");
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
                  },
                  isRegistered: user.isRegistered ?? false,
                  profilePic: user.profilePicture ?? "",
                  name: user.name ?? "",
                  phone: phone,
                  isOnline: user.isOnline ?? false,
                  lastSeen: user.lastSeen != null
                      ? DateTime.parse(user.lastSeen!).toLocal()
                      : null);
            },
          ),
          if ((state.otherContact ?? Set.of([])).isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(S.of(context).publicUsers,
                  style: AppTextStyles.medium()),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: (state.otherContact ?? Set.of([])).length,
              itemBuilder: (context, i) {
                ContactUser user = state.otherContact.elementAt(i);
                return contactTile(
                  context: context,
                  onTap: () async {
                    // Add your onTap functionality here
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
                  },
                  isRegistered: user.isRegistered ?? false,
                  profilePic: user.profilePicture ?? "",
                  name: user.name ?? "",
                  phone: "",
                  isOnline: user.isOnline ?? false,
                  lastSeen: user.lastSeen != null
                      ? DateTime.parse(user.lastSeen!).toLocal()
                      : null, // Non-registered users may not have last seen
                );
              },
            ),
          ],
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
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Row(
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
                        name,
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
                                : (isRegistered)
                                    ? ""
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
                  )
              ],
            ),
          ),
          16.s,
        ],
      ),
    );
  }
}
// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController _searchUserController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   int currentPage = 1;
//   final int limit = 10;
//   List<UserData> user = [];

//   @override
//   void initState() {
//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels ==
//           _scrollController.position.maxScrollExtent) {
//         context.read<SearchCubit>().fetchMoreData(
//             _searchUserController.text, currentPage, limit, context);
//         currentPage++;
//       }
//     });

//     _fetchInitialData();
//     super.initState();
//   }

//   void _fetchInitialData() {
//     context.read<SearchCubit>().getAllUserData(
//         _searchUserController.text.trim(), currentPage, limit, context);
//     if (currentPage == 1) {
//       currentPage++;
//     }
//   }

//   void _onSearchTextChange(String name, BuildContext context) {
//     // Fetch data on enter key or when user stops typing
//     if (_searchUserController.text.isNotEmpty) {
//       Future.delayed(const Duration(milliseconds: 500), () {
//         final searchText = _searchUserController.text.trim();
//         context
//             .read<SearchCubit>()
//             .getAllUserData(searchText, 1, limit, context);
//       });
//     } else {
//       _fetchInitialData();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CommonAppBar(
//         isBackShow: true,
//         title: AppConstants.lblSearchUser,
//         isActionsShow: false,
//       ),
//       bottomNavigationBar: const BannerAdManager(),
//       body: SafeArea(
//         child: Column(
//           children: [
//             SizedBox(height: 10.h),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.w),
//               child: CustomTextField(
//                 controller: _searchUserController,
//                 label: S.of(context).searchUsers,
//                 prefixIcon: SvgImage(
//                   source: SvgAssets.icSearch,
//                   fit: BoxFit.scaleDown,
//                   color: AppColors.white,
//                 ),
//                 onChanged: (value) => _onSearchTextChange(value, context),
//                 validator: (value) {
//                   return null;
//                 },
//               ),
//             ),
//             24.s,
//             buildNewItem(
//                 context: context,
//                 onTap: () {
//                   homeCubit.cleanGroupData();
//                   NavigationService().navigateTo(NewGroupScreen(
//                     isGroup: true,
//                   ));
//                 },
//                 icon: SvgAssets.person2,
//                 title: S.of(context).newGroup),
//             24.s,
//             buildNewItem(
//                 context: context,
//                 onTap: () async {
//                   await FlutterContacts.openExternalInsert().then(
//                     (value) {
//                       homeCubit.fetchContactsForSync(context);
//                     },
//                   );
//                   context
//                       .read<SearchCubit>()
//                       .getAllUserData("", 1, limit, context);
//                 },
//                 icon: SvgAssets.icInviteFriends,
//                 title: S.of(context).newContacts),
//             24.s,
//             buildNewItem(
//                 context: context,
//                 onTap: () {
//                   homeCubit.cleanGroupData();
//                   NavigationService().navigateTo(NewGroupScreen(
//                     isGroup: false,
//                   ));
//                 },
//                 icon: SvgAssets.megaphone,
//                 title: S.of(context).newChannel),
//             24.s,
//             BlocBuilder<SearchCubit, SearchState>(
//               builder: (contextSearch, searchState) {
//                 if (searchState is SearchLoading) {
//                   return Expanded(
//                     child: Center(
//                       child: CustomLoadingWidget(
//                         color: AppColors.white,
//                       ),
//                     ),
//                   );
//                 } else if (searchState is SearchLoaded) {
//                   return Expanded(
//                     child: searchState.allUser.isNotEmpty
//                         ? ListView.separated(
//                             controller: _scrollController,
//                             itemCount: searchState.allUser.length + 1,
//                             itemBuilder: (context, index) {
//                               if (index == searchState.allUser.length) {
//                                 // if(searchState.totalPage > currentPage) {
//                                 //   return const Center(
//                                 //       child: CustomLoadingWidget());
//                                 // } else {
//                                 //   return SizedBox.shrink();
//                                 // }
//                                 return BlocBuilder<SearchCubit, SearchState>(
//                                   builder: (context, state) {
//                                     return state is SearchLoading
//                                         ? const Center(
//                                             child: CustomLoadingWidget())
//                                         : const SizedBox.shrink();
//                                   },
//                                 );
//                               }

//                               UserData user = searchState.allUser[index];

//                               return buildListTile(
//                                   name: user.userName ?? '',
//                                   subTittle:
//                                       '${S.of(context).sLastSeen} ${user.lastSeen?.toCustomFormat()}',
//                                   image: user.profilePicture != null
//                                       ? '${Urls.mediaUrl}${user.profilePicture}'
//                                       : '',
//                                   onTap: () {
//                                     showMessage("call ===>");
//                                     ParticipantDetail sender =
//                                         ParticipantDetail.fromJson(
//                                             user.toJson());
//                                     NavigationService().replaceWith(ChatScreen(
//                                       chatType: ChatType.one_to_one,
//                                       sender: sender,
//                                       unreadMessageCount: 0,
//                                       userName: user.userName ?? "",
//                                       userId: user.sId ?? "",
//                                       userPic: user.profilePicture ?? "",
//                                       chatId: '',
//                                       aesKey: '',
//                                       isSendMessage: true,
//                                       isShowProfileImage: true,
//                                     ));
//                                   });
//                             },
//                             separatorBuilder: (context, index) {
//                               return Divider(
//                                 height: 0,
//                                 color: AppColors.darkAppBar,
//                               );
//                             },
//                           )
//                         : Center(
//                             child: Text(
//                               'No data found',
//                               style: AppTextStyles.regular(fontSize: 16.sp),
//                             ),
//                           ),
//                   );
//                 } else if (searchState is SearchError) {
//                   return Expanded(
//                       child: Center(child: Text(searchState.message)));
//                 } else {
//                   return Container();
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildNewItem(
//       {required BuildContext context,
//       required void Function() onTap,
//       required String icon,
//       required String title}) {
//     return GestureDetector(
//         onTap: onTap,
//         behavior: HitTestBehavior.translucent,
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16.w),
//           child: Row(
//             children: [
//               SvgImage(
//                 source: icon,
//               ),
//               18.s,
//               Text(
//                 title,
//                 style: AppTextStyles.medium(fontSize: 20.sp),
//               )
//             ],
//           ),
//         ));
//   }

//   Widget buildListTile({
//     required String image,
//     required String name,
//     required String subTittle,
//     required Function() onTap,
//   }) {
//     return GestureDetector(
//       behavior: HitTestBehavior.translucent,
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
//         child: Row(
//           children: [
//             Container(
//               width: 60.w,
//               height: 60.h,
//               clipBehavior: Clip.hardEdge,
//               decoration: BoxDecoration(
//                 color: AppColors.darkInputFill,
//                 shape: BoxShape.circle,
//               ),
//               child: image.isEmpty
//                   ? Center(
//                       child: SvgImage(
//                         source: SvgAssets.icPerson,
//                         color: AppColors.white,
//                       ),
//                     )
//                   : AppNetworkImage(
//                       imageUrl: image,
//                     ),
//             ),
//             SizedBox(
//               width: 16.w,
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: AppTextStyles.medium(
//                     fontSize: 16.sp,
//                   ),
//                 ),
//                 SizedBox(
//                   height: 8.h,
//                 ),
//                 Text(
//                   subTittle,
//                   style: AppTextStyles.regular(
//                       fontSize: 12.sp, color: AppColors.textColorThird),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

// }
