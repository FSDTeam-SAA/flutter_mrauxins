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
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/avatar_widgets.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';

class InviteFriendScreen extends StatefulWidget {
  const InviteFriendScreen({super.key});

  @override
  State<InviteFriendScreen> createState() => _InviteFriendScreenState();
}

class _InviteFriendScreenState extends State<InviteFriendScreen> {
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
      // The outer Scaffold in main.dart already sets
      // resizeToAvoidBottomInset: false. Matching it here avoids this
      // Scaffold independently reacting to raw per-frame keyboard-inset
      // updates while the outer one doesn't — that mismatch produced a
      // hairline seam on keyboard close. Search lives in the AppBar, so the
      // keyboard can simply overlay the list instead of resizing for it.
      resizeToAvoidBottomInset: false,
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
                          S.of(context).sInviteFriends,
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
      body: _contactsList(),
      bottomNavigationBar: const BannerAdManager(),
      bottomSheet: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 59.h,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
                color: AppColors.secondaryBgColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(8.r))),
            child: Center(
                child: Text(
              S.of(context).selectContactToInviteThem,
              style: AppTextStyles.medium(fontSize: 14.sp),
            )),
          ),
        ],
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
        if ((state.displayedContacts ?? []).isEmpty) {
          return Center(child: Text(S.of(context).noContactsFound));
        }
      }
      return ListView.separated(
        controller: scrollController,
        shrinkWrap: true,
        padding: EdgeInsets.only(bottom: 60.h, right: 16.w, left: 16.w),
        itemCount: state.displayedContacts.length,
        itemBuilder: (context, i) {
          if (!(state.displayedContacts[i].isRegistered ?? false)) {
            ContactUser user = state.displayedContacts[i];
            String phone = (user.phone ?? "").isEmpty
                ? ""
                : "${user.countryCode ?? ""}${user.phone ?? ""}";
            return contactTile(
                context: context,
                onTap: () {},
                isRegistered: user.isRegistered ?? false,
                profilePic: user.profilePicture ?? "",
                name: user.name ?? "",
                phone: phone,
                lastSeen: user.lastSeen != null
                    ? DateTime.parse(user.lastSeen!).toLocal()
                    : null);
          } else {
            return SizedBox();
          }
        },
        separatorBuilder: (context, index) => Container(
          color: AppColors.darkAppBar, // Set divider color
          height: 1, // Divider thickness
        ),
      );
    });
  }

  Widget contactTile(
      {required BuildContext context,
      required void Function() onTap,
      required String name,
      required String phone,
      required String profilePic,
      required bool isRegistered,
      required DateTime? lastSeen}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Column(
        children: [
          16.s,
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
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.medium(
                        fontSize: 18.sp,
                      ),
                    ),
                    6.s,
                    Text(
                      (lastSeen != null)
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
                )
            ],
          ),
          16.s,
        ],
      ),
    );
  }
}
