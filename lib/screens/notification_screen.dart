import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:two_one_two_messenger/cubit/home_cubit.dart';
import 'package:two_one_two_messenger/cubit/home_state.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/date_format.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/notification_model.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/screens/calls_screen.dart';
import 'package:two_one_two_messenger/screens/channel_info.dart';
import 'package:two_one_two_messenger/screens/group_info.dart';
import 'package:two_one_two_messenger/utils/app_pop_up.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/avatar_widgets.dart';
import 'package:two_one_two_messenger/widgets/buttons.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    // _focusNode.addListener(_handleFocusChange);
    // userData ??= await chatCubit.dbHelper.getLoginData();
    scrollController.addListener(_onScroll);
    await fetchAllNotifications();
  }

  Future<void> fetchAllNotifications() async {
    homeCubit.getNotifications(
        context: context,
        isLoadMore: false,
        searchQuery: searchController.text.trim());
    homeCubit.updateNotificationCount(0);
  }

  Future<void> _onScroll() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      await homeCubit.getNotifications(
          context: context,
          isLoadMore: true,
          searchQuery: searchController.text.trim());
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
        // The outer Scaffold in main.dart already sets
        // resizeToAvoidBottomInset: false. Matching it here avoids this
        // Scaffold independently reacting to raw per-frame keyboard-inset
        // updates while the outer one doesn't — that mismatch produced a
        // hairline seam on keyboard close. Search lives in the AppBar, so
        // the keyboard can simply overlay the list instead of resizing.
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
            return state.searchNotifications
                ? TextFormField(
                    controller: searchController,
                    onChanged: (query) {
                      homeCubit.onSearchNotifications(
                          context: context, searchQuery: query);
                    },
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: S.of(context).sSearchNotifications,
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
                            S.of(context).notifications,
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
                homeCubit.handleSearchNotifications(
                  context,
                  () => searchController.clear(),
                );
              },
              behavior: HitTestBehavior.translucent,
              child:
                  BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.0).copyWith(right: 16),
                  child: state.searchNotifications
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
            buildClearNotiFicationMenu(
              context: context,
              onSelected: (item) {
                showClearNotificationDialog(context);
              },
            ),
          ],
        ),

        //  floatingActionButton: FloatingActionButton(onPressed: () async {

        //  }, backgroundColor: AppColors.primaryColor,
        //       shape: CircleBorder(),

        //     child:   Icon(
        //                             Icons.arrow_forward,
        //                               size: 30.h,
        //                               color: AppColors.white,
        //                             ),
        //       ),
        body: _notificationsList()
        //  Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Padding(
        //   padding:  EdgeInsets.symmetric(horizontal: 16.0.w).copyWith(top: 16.h),
        //       child: Text(
        //         AppConstants.whoWouldYouLikeToAdd,
        //         style: AppTextStyles.medium(
        //           fontSize: 18.sp,
        //           color: AppColors.purpleText,
        //         ),
        //       ),
        //     ),

        //     Expanded(
        //       child:_contactsList()

        //     )
        //   ],
        // ),
        );
  }

  Widget _notificationsList() {
    // if (_permissionDenied) return Center(child: Text('Permission denied'));
    // if (_contacts == null) return Center(child: CustomLoadingWidget());
    return BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
      if (state.getAllNotificationsLoadingState == LoadingState.loading) {
        return Center(child: CustomLoadingWidget());
      } else if (state.getAllNotificationsLoadingState ==
          LoadingState.success) {
        if ((state.allNotification ?? []).isEmpty) {
          return Center(
              child: Text(
            S.of(context).noNotificationsFound,
            style: AppTextStyles.medium(),
          ));
        }
      }
      return ListView.separated(
        controller: scrollController,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: state.allNotification.length,
        itemBuilder: (context, i) {
          if (state.getAllNotificationLoadMore &&
              i == state.allNotification.length - 1) {
            return Column(
              children: [
                notificationTile(
                    context: context,
                    onTap: () {},
                    notification: state.allNotification[i]),
                CustomLoadingWidget()
              ],
            );
          }
          return notificationTile(
              context: context,
              onTap: () {},
              notification: state.allNotification[i]);
        },
        separatorBuilder: (context, index) => Container(
          color: AppColors.darkAppBar, // Set divider color
          height: 1, // Divider thickness
        ),
      );
    });
  }

  Widget notificationTile({
    required BuildContext context,
    required void Function() onTap,
    required NotificationData notification,
  }) {
    return BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
      // final bool isSelected = state.selectedUserForGroup.any((element) => element.id==user.sId,);
      return GestureDetector(
        onTap: () async {
          if (notification.type == NotificationType.group_invite ||
              notification.type == NotificationType.create_new_group ||
              notification.type == NotificationType.assign_admin ||
              notification.type == NotificationType.delete_group ||
              notification.type == NotificationType.removed_group ||
              notification.type == NotificationType.removed_member_group ||
              notification.type == NotificationType.new_group_created ||
              notification.type == NotificationType.leave_group) {
            UserData? user = await homeCubit.dbHelper.getLoginData();
            if (user == null) return;
            NavigationService().navigateTo(GroupInfoScreen(
              currentUser: user,
              groupId: notification.groupInfo?.id ?? "",
            ));
          } else if (notification.type == NotificationType.channel_mention ||
              notification.type == NotificationType.create_new_channel ||
              notification.type == NotificationType.channel_invite ||
              notification.type == NotificationType.removed_channel ||
              notification.type == NotificationType.leave_channel ||
              notification.type == NotificationType.delete_channel ||
              notification.type == NotificationType.removed_member_channel) {
            UserData? user = await homeCubit.dbHelper.getLoginData();
            if (user == null) return;
            NavigationService().navigateTo(ChannelInfoScreen(
              currentUser: user,
              groupId: notification.groupInfo?.id ?? "",
            ));
          } else if (notification.type == NotificationType.voice ||
              notification.type == NotificationType.video ||
              notification.type == NotificationType.video_group_call ||
              notification.type == NotificationType.voice_group_call) {
            NavigationService().navigateTo(CallsScreen());
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
                  if (notification.type == NotificationType.voice_group_call ||
                      notification.type == NotificationType.video_group_call ||
                      notification.type == NotificationType.assign_admin ||
                      notification.type == NotificationType.create_new_group ||
                      notification.type == NotificationType.delete_group ||
                      notification.type == NotificationType.group_invite ||
                      notification.type == NotificationType.removed_group ||
                      notification.type == NotificationType.channel_mention)
                    AvatarWidgets(
                      userPic: notification.groupInfo == null
                          ? notification.sender?.profilePicture ?? ""
                          : notification.groupInfo?.groupImage ?? "",
                      svgAvatar: (notification.type ==
                              NotificationType.channel_mention)
                          ? SvgAssets.megaphone
                          : SvgAssets.person2,
                      height: 50,
                      width: 50,
                    )
                  else
                    AvatarWidgets(
                      userPic: notification.sender?.profilePicture ?? "",
                      height: 50,
                      width: 50,
                    ),
                  16.s,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (notification.type ==
                                NotificationType.voice_group_call ||
                            notification.type ==
                                NotificationType.video_group_call ||
                            notification.type ==
                                NotificationType.assign_admin ||
                            notification.type ==
                                NotificationType.create_new_group ||
                            notification.type ==
                                NotificationType.delete_group ||
                            notification.type ==
                                NotificationType.group_invite ||
                            notification.type ==
                                NotificationType.removed_group ||
                            notification.type ==
                                NotificationType.channel_mention)
                          Text(
                            notification.groupInfo == null
                                ? notification.sender?.name ??
                                    notification.sender?.userName ??
                                    ""
                                : notification.groupInfo?.groupName ?? "",
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.medium(
                              fontSize: 18.sp,
                            ),
                          )
                        else
                          Text(
                            AppMethods.getNickName(notification.sender),
                            // notification.sender?.name ??
                            //     notification.sender?.userName ??
                            //     "",
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.medium(
                              fontSize: 18.sp,
                            ),
                          ),
                        6.s,
                        // Text("${AppConstants.sLastSeen} ${user.lastSeen?.toCustomFormat()}",style: AppTextStyles.regular(
                        //     fontSize: 13.sp,color: AppColors.white.withValues(alpha: 0.5)
                        //   ),)
                        if (notification.type ==
                                NotificationType.voice_group_call ||
                            notification.type == NotificationType.voice ||
                            notification.type == NotificationType.video ||
                            notification.type ==
                                NotificationType.video_group_call)
                          Row(
                            children: [
                              // SvgImage(source: SvgAssets.arrowGreenUp),
                              Text(
                                notification.createdAt
                                        ?.formattedDateWithDayMonthYearAtTime ??
                                    "",
                                style: AppTextStyles.regular(
                                    color: AppColors.white.withAlpha(50)),
                              ),
                            ],
                          )
                        else
                          Text(
                            notification.content ?? "",
                            style: AppTextStyles.regular(
                                color: AppColors.white.withAlpha(50)),
                          ),
                        if ((notification.type ==
                                    NotificationType.group_invite ||
                                notification.type ==
                                    NotificationType.channel_invite) &&
                            notification.status == InviteStatus.pending)
                          Padding(
                            padding: EdgeInsets.only(top: 10.h),
                            child: Builder(builder: (context) {
                              final bool isResponding = state
                                  .respondingInviteIds
                                  .contains(notification.id ?? "");
                              return Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 32.h,
                                      child: OutlinedButton(
                                        onPressed: isResponding
                                            ? null
                                            : () {
                                                homeCubit.respondToInvite(
                                                    context,
                                                    notification.id ?? "",
                                                    "reject");
                                              },
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                              color: AppColors.redColor),
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                          ),
                                        ),
                                        child: isResponding
                                            ? SizedBox(
                                                height: 16.h,
                                                width: 16.h,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: AppColors.redColor,
                                                ),
                                              )
                                            : Text(
                                                S.of(context).reject,
                                                style: AppTextStyles.medium(
                                                  fontSize: 12.sp,
                                                  color: AppColors.redColor,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  8.w.s,
                                  Expanded(
                                    child: SizedBox(
                                      height: 32.h,
                                      child: ElevatedButton(
                                        onPressed: isResponding
                                            ? null
                                            : () {
                                                homeCubit.respondToInvite(
                                                    context,
                                                    notification.id ?? "",
                                                    "accept");
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryColor,
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                          ),
                                        ),
                                        child: isResponding
                                            ? SizedBox(
                                                height: 16.h,
                                                width: 16.h,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: AppColors.white,
                                                ),
                                              )
                                            : Text(
                                                S.of(context).accept,
                                                style: AppTextStyles.medium(
                                                  fontSize: 12.sp,
                                                  color: AppColors.white,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (notification.type ==
                              NotificationType.voice_group_call ||
                          notification.type == NotificationType.voice ||
                          notification.type == NotificationType.video ||
                          notification.type ==
                              NotificationType.video_group_call)
                        SvgImage(
                          source: SvgAssets.icContact,
                          color: AppColors.white,
                          height: 28,
                          width: 28,
                        ),
                      6.s,
                      Text(
                        DateFormat.jm()
                            .format(notification.createdAt ?? DateTime.now()),
                        style: AppTextStyles.regular(
                            fontSize: 12.sp,
                            color: AppColors.white.withAlpha(75)),
                      )
                    ],
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

  void showClearNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return BlocBuilder<HomeCubit, HomeState>(
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
                        S.of(context).clearNotification,
                        style: AppTextStyles.medium(fontSize: 20.sp),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        S.of(context).clearNotificationSubTitle,
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
                                NavigationService().goBack();
                                homeCubit.clearAllNotification(
                                  callback: (response) {
                                    Utils.showSnackBar(
                                        context, response.message ?? '',
                                        seconds: 3);
                                  },
                                );
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
}
