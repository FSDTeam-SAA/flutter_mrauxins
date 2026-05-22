import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/cubit/home_cubit.dart';
import 'package:two_one_two_messenger/cubit/home_state.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/group_info_model.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/app_check_box.dart';
import 'package:two_one_two_messenger/widgets/avatar_widgets.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';

import '../widgets/appbar.dart';

class AddMemberGroupScreen extends StatefulWidget {
  const AddMemberGroupScreen(
      {super.key,
      required this.admins,
      required this.onSubmit,
      required this.title});
  final List<Participant> admins;
  final Future<void> Function() onSubmit;
  final String title;
  @override
  State<AddMemberGroupScreen> createState() => _AddMemberGroupScreenState();
}

class _AddMemberGroupScreenState extends State<AddMemberGroupScreen> {
  final scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
    // scrollController.addListener(_onScroll);
    // homeCubit. fetchContacts("");
  }

  Future<void> init() async {
    // _focusNode.addListener(_handleFocusChange);
    // userData ??= await chatCubit.dbHelper.getLoginData();
    scrollController.addListener(_onScroll);
    await fetchAllUsers();
  }

  Future<void> fetchAllUsers() async {
    homeCubit.getAllUserData(
        context: context,
        isLoadMore: false,
        name: "",
        removedUsers: widget.admins);
  }

  Future<void> _onScroll() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      await homeCubit.getAllUserData(
          context: context,
          isLoadMore: true,
          name: "",
          removedUsers: widget.admins);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    // messageCon.dispose();
    // _focusNode.removeListener(_handleFocusChange);
    // _focusNode.dispose();
    super.dispose();
  }

  //  Future<void> _onScroll() async {
  //   if (scrollController.position.pixels ==
  //       scrollController.position.maxScrollExtent) {
  //    homeCubit.loadMoreContacts(searchController.text.trim());
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        isActionsShow: false,
        isBackShow: true,
        title: widget.title,
        subTitle: S.of(context).upTo200000Members,
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
      //   title: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           Text(
      //             AppConstants.sNewGroup,
      //             style: AppTextStyles.medium(fontSize: 20.sp),
      //           ),
      //           Text(AppConstants.upTo200000Members, style: AppTextStyles.medium(fontSize: 10.sp,color: AppColors.white.withOpacity(0.5))),
      //         ],
      //       )
      //  ,
      //   bottom: PreferredSize(
      //     preferredSize: const Size.fromHeight(1),
      //     // Adjust height of the divider
      //     child: Container(
      //       color: AppColors.darkAppBar, // Set divider color
      //       height: 1, // Divider thickness
      //     ),
      //   ),
      //   // actions: [
      //   //   GestureDetector(
      //   //     onTap: () {
      //   //         homeCubit. handleSearchContact(() => searchController.clear(),);

      //   //     },
      //   //     behavior: HitTestBehavior.translucent,
      //   //     child: BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
      //   //         return Padding(
      //   //           padding:  EdgeInsets.symmetric(horizontal: 8.0).copyWith(right: 16),
      //   //           child:state.searchContacts ?Icon(Icons.close ,size:  20.w,

      //   //             color: AppColors.white,): SvgImage(
      //   //             source: SvgAssets.icSearch,
      //   //             width: 20.w,
      //   //             height: 20.w,
      //   //             color: AppColors.white,
      //   //           ),
      //   //         );
      //   //       }
      //   //     ),
      //   //   ),
      //   // ],

      // ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await widget.onSubmit();
        },
        backgroundColor: AppColors.primaryColor,
        shape: CircleBorder(),
        child: Icon(
          Icons.arrow_forward,
          size: 30.h,
          color: AppColors.white,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 16.0.w).copyWith(top: 16.h),
            child: Text(
              S.of(context).whoWouldYouLikeToAdd,
              style: AppTextStyles.medium(
                fontSize: 18.sp,
                color: AppColors.purpleText,
              ),
            ),
          ),
          Expanded(child: _contactsList())
        ],
      ),
    );
  }

  Widget _contactsList() {
    // if (_permissionDenied) return Center(child: Text('Permission denied'));
    // if (_contacts == null) return Center(child: CustomLoadingWidget());
    return BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
      if (state.getAllUsersLoadingState == LoadingState.loading) {
        return Center(child: CustomLoadingWidget());
      } else if (state.getAllUsersLoadingState == LoadingState.success) {
        if ((state.allUserData?.users ?? []).isEmpty) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(S.of(context).noContactsFound),
          ));
        }
      }
      return ListView.separated(
        controller: scrollController,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: state.allUserData!.users!.length,
        itemBuilder: (context, i) {
          if (state.getAllUsersLoadMore &&
              i == state.allUserData!.users!.length - 1) {
            return Column(
              children: [
                contactTile(
                    context: context,
                    onTap: () {},
                    user: state.allUserData!.users![i]),
                CustomLoadingWidget()
              ],
            );
          }
          return contactTile(
              context: context,
              onTap: () {},
              user: state.allUserData!.users![i]);
        },
        separatorBuilder: (context, index) => Container(
          color: AppColors.darkAppBar, // Set divider color
          height: 1, // Divider thickness
        ),
      );
    });
  }

  Widget contactTile({
    required BuildContext context,
    required void Function() onTap,
    required UserData user,
  }) {
    return BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
      final bool isSelected = state.selectedUserForGroup.any(
        (element) => element.id == user.sId,
      );
      return GestureDetector(
        onTap: () {
          if (!homeCubit.addToGroup(user, isSelected, widget.admins.length)) {
            Utils.showSnackBar(
                context, S.of(context).groupMembersLimitrichMessage);
          }
        },
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0.w),
          child: Column(
            children: [
              17.s,
              Row(
                children: [
                  AvatarWidgets(
                    userPic: user.profilePicture ?? "",
                    height: 50,
                    width: 50,
                  ),
                  16.s,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // user.name ?? user.userName ?? "",
                          (user.isActiveNickname ?? false)
                              ? (user.nickName ??
                                  user.name ??
                                  user.userName ??
                                  "")
                              : (user.name ?? user.userName ?? ""),
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.medium(
                            fontSize: 18.sp,
                          ),
                        ),
                        6.s,
                        Text(
                          user.lastSeen == null
                              ? S.of(context).online
                              : "${S.of(context).sLastSeen} ${user.lastSeen?.toCustomFormat()}",
                          style: AppTextStyles.regular(
                              fontSize: 13.sp,
                              color: AppColors.white.withValues(alpha: 0.5)),
                        )
                      ],
                    ),
                  ),
                  AppCheckBox(
                    value: isSelected,
                    onChanged: (value) {
                      // homeCubit.addToGroup(user,isSelected);
                    },
                  )
                ],
              ),
              17.s,
            ],
          ),
        ),
      );
    });
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: CommonAppBar(
  //       isActionsShow: false,
  //       isBackShow: true,
  //     ),
  //     body: SafeArea(
  //       child: Padding(
  //         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
  //         child: ListView(
  //           children: [

  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}






  // Widget _contactsList() {
  //   // if (_permissionDenied) return Center(child: Text('Permission denied'));
  //   // if (_contacts == null) return Center(child: CustomLoadingWidget());
  //   return BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
  //     if (state.contactsLoadingState == LoadingState.loading) {
  //       return Center(child: CustomLoadingWidget());
  //     } else if (state.contactsLoadingState == LoadingState.success) {
  //       List<ContactUser> displayedContacts =
  //           List.from((state.displayedContacts ?? []));
  //       List<ContactUser> otherContact =
  //           List.from((state.otherContact ?? Set.of([])));

  //       if (displayedContacts.isEmpty && otherContact.isEmpty) {

  //         return Center(child: Text(AppConstants.noContactsFound));
  //       }
        
  //     }
  //     showMessage("other Users== ${(state.otherContact ?? Set.of([]))}");
  //     return Column(
  //       children: [
  //         ListView.builder(
  //           // controller: scrollController,
  //           physics: NeverScrollableScrollPhysics(),
  //           shrinkWrap: true,
  //           padding: EdgeInsets.zero,
  //           itemCount: state.displayedContacts.length,
  //           itemBuilder: (context, i) {
  //             ContactUser user = state.displayedContacts[i];

  //             return contactTile(context: context, onTap: () {}, user: user);
  //           },
  //         ),
  //         if ((state.otherContact ?? Set.of([])).isNotEmpty) ...[
  //           Padding(
  //             padding: const EdgeInsets.symmetric(vertical: 8.0),
  //             child:
  //                 Text(S.of(context).otherUsers, style: AppTextStyles.medium()),
  //           ),
  //           ListView.builder(
  //             shrinkWrap: true,
  //             physics: NeverScrollableScrollPhysics(),
  //             itemCount: (state.otherContact ?? Set.of([])).length,
  //             itemBuilder: (context, i) {
  //               ContactUser user = state.otherContact.elementAt(i);
  //               return contactTile(context: context, onTap: () {}, user: user);
  //             },
  //           ),
  //         ],
  //       ],
  //     );
  //   });
  // }

  // Widget contactTile({
  //   required BuildContext context,
  //   required void Function() onTap,
  //   required ContactUser user,
  // }) {
  //   return BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
  //     final bool isSelected = state.selectedUserForGroup.any(
  //       (element) => element.id == user.sId,
  //     );
  //     return GestureDetector(
  //       onTap: () {
  //         if (!homeCubit.addToGroup(user, isSelected, widget.admins.length)) {
  //           Utils.showSnackBar(
  //               context, AppConstants.groupMembersLimitrichMessage);
  //         }
  //       },
  //       behavior: HitTestBehavior.translucent,
  //       child: Padding(
  //         padding: EdgeInsets.symmetric(horizontal: 16.0.w),
  //         child: Column(
  //           children: [
  //             17.s,
  //             Row(
  //               children: [
  //                 AvatarWidgets(
  //                   userPic: user.profilePicture ?? "",
  //                   height: 50,
  //                   width: 50,
  //                 ),
  //                 16.s,
  //                 Expanded(
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         user.name ?? user.userName ?? "",
  //                         overflow: TextOverflow.ellipsis,
  //                         style: AppTextStyles.medium(
  //                           fontSize: 18.sp,
  //                         ),
  //                       ),
  //                       6.s,
  //                       Text(
  //                         "${S.of(context).sLastSeen} ${user.lastSeen?.toCustomFormat()}",
  //                         style: AppTextStyles.regular(
  //                             fontSize: 13.sp,
  //                             color: AppColors.white.withValues(alpha: 0.5)),
  //                       )
  //                     ],
  //                   ),
  //                 ),
  //                 AppCheckBox(
  //                   value: isSelected,
  //                   onChanged: (value) {
  //                     // homeCubit.addToGroup(user,isSelected);
  //                   },
  //                 )
  //               ],
  //             ),
  //             17.s,
  //           ],
  //         ),
  //       ),
  //     );
  //   });
  // }
