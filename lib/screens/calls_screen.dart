import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/cubit/home_cubit.dart';
import 'package:two_one_two_messenger/cubit/home_state.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/date_format.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/call_history_model.dart';
import 'package:two_one_two_messenger/models/conversation_model.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/screens/chat_screen.dart';
import 'package:two_one_two_messenger/screens/groupCall.dart';
import 'package:two_one_two_messenger/screens/group_info.dart';
import 'package:two_one_two_messenger/screens/report_user_screen.dart';
import 'package:two_one_two_messenger/screens/user_profile.dart';
import 'package:two_one_two_messenger/screens/voice_call_page.dart';
import 'package:two_one_two_messenger/utils/app_dialoge.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/app_check_box.dart';
import 'package:two_one_two_messenger/widgets/avatar_widgets.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';

import '../widgets/appbar.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({
    super.key,
  });

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  final scrollController = ScrollController();
// TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    // userData ??= await chatCubit.dbHelper.getLoginData();
    scrollController.addListener(_onScroll);
    await fetchAllCallHistory();
  }

  Future<void> fetchAllCallHistory() async {
    homeCubit.getCallsHistory(
      context: context,
      isLoadMore: false,
    );
  }

  Set<String> selectedCalls = {}; // Track selected calls
  bool isSelectionMode = false; // Track if selection mode is active

  void toggleSelection(String callId) {
    setState(() {
      if (selectedCalls.contains(callId)) {
        selectedCalls.remove(callId);
      } else {
        selectedCalls.add(callId);
      }
      isSelectionMode = selectedCalls.isNotEmpty;
    });
  }

  void clearSelection() {
    setState(() {
      selectedCalls.clear();
      isSelectionMode = false;
    });
  }

  void deleteSelectedCalls() {
    // Implement call deletion logic using selectedCalls

    clearCallLog(
        onSubmit: () async {
          await homeCubit.clearCallLog(context, selectedCalls.toList());
          clearSelection();
        },
        title: S.of(context).delete_selected_calls_title,
        subTitle: S.of(context).delete_selected_calls_subtitle);
  }

  Future<void> _onScroll() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      await homeCubit.getCallsHistory(
        context: context,
        isLoadMore: true,
      );
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

  clearCallLog({
    required void Function() onSubmit,
    required String title,
    required String subTitle,
  }) {
    showCommonDeleteDialog(
        context: context, onSubmit: onSubmit, title: title, subTitle: subTitle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CommonAppBar(
          isActionsShow: true,
          isBackShow: true,
          title: isSelectionMode
              ? S.of(context).countSelected(selectedCalls.length)
              : S.of(context).sCalls,
          actions: [
            PopupMenuButton<String>(
              color: AppColors.dialogBg,
              icon: SvgImage(
                  source: SvgAssets.icMoreDots,
                  width: 18.w,
                  color: AppColors.white),
              onSelected: (value) {
                switch (value) {
                  case "clearCallLog":
                    clearCallLog(
                        onSubmit: () => homeCubit.clearCallLog(context, []),
                        title: S.of(context).clear_all_calls_subtitle,
                        subTitle: S.of(context).clear_all_calls_subtitle);

                    break;

                  case "deleteSelected":
                    deleteSelectedCalls();
                    break;
                  case "selecteAll":
                    setState(() {
                      // Assume all call IDs are available in state
                      selectedCalls.addAll(
                          homeCubit.state.callHistory.map((e) => e.id!));
                      isSelectionMode = true;
                    });
                    break;
                  default:
                    clearCallLog(
                        onSubmit: () => homeCubit.clearCallLog(context, []),
                        title: S.of(context).clear_all_calls_subtitle,
                        subTitle: S.of(context).clear_all_calls_subtitle);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: "clearCallLog",
                  child: Text(
                    S.of(context).clearCallLog,
                    style: AppTextStyles.regular(color: AppColors.white),
                  ),
                ),
                if (isSelectionMode)
                  PopupMenuItem<String>(
                    value: "deleteSelected",
                    child: Text(
                      S.of(context).deleteSelected,
                      style: AppTextStyles.regular(color: AppColors.white),
                    ),
                  )
                else
                  PopupMenuItem<String>(
                    value: "selecteAll",
                    child: Text(
                      S.of(context).selectAll,
                      style: AppTextStyles.regular(color: AppColors.white),
                    ),
                  ),
              ],
            )
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
        body: _callHistoryList());
  }

  Widget _callHistoryList() {
    return BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
      if (state.getCallHistoryLoadingState == LoadingState.loading) {
        return Center(child: CustomLoadingWidget());
      } else if (state.getCallHistoryLoadingState == LoadingState.success) {
        if ((state.callHistory).isEmpty) {
          return Center(child: Text(S.of(context).noCallHistoryFound));
        }
      }
      return ListView.separated(
        controller: scrollController,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: state.callHistory.length,
        itemBuilder: (context, i) {
          final call = state.callHistory[i];
          final isSelected = selectedCalls.contains(call.id);

          return Row(
            children: [
              if (isSelectionMode)
                Padding(
                  padding: EdgeInsets.only(left: 16.0.h),
                  child: AppCheckBox(
                    value: isSelected,
                    onChanged: (value) {
                      // homeCubit.addToGroup(user,isSelected);
                    },
                  ),
                ),
              Expanded(
                  child: (state.getCallsHistoryLoadMore &&
                          i == state.callHistory.length - 1)
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            callTile(
                              context: context,
                              callData: call,
                            ),
                            CustomLoadingWidget()
                          ],
                        )
                      : callTile(context: context, callData: call)),
            ],
          );
        },
        separatorBuilder: (context, index) => Container(
          color: AppColors.darkAppBar, // Set divider color
          height: 1, // Divider thickness
        ),
      );
    });
  }

  Widget callTile({
    required BuildContext context,
    // required void Function() onTap,
    required CallHistoryList callData,
  }) {
    return BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
      // final bool isSelected = state.selectedUserForGroup.any((element) => element.id==user.sId,);
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPress: () => toggleSelection(callData.id!),
        onTap: () {
          if (isSelectionMode) {
            toggleSelection(callData.id!);
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0.w),
          child: Column(
            children: [
              17.s,
              Row(
                children: [
                  AvatarWidgets(
                    userPic: (callData.callType == CallType.video ||
                            callData.callType == CallType.voice)
                        ? callData.sender?.profilePicture ?? ""
                        : callData.chatInfo?.groupImage ?? "",
                    svgAvatar: (callData.callType == CallType.video ||
                            callData.callType == CallType.voice)
                        ? SvgAssets.icPerson
                        : SvgAssets.person2,
                    height: 50,
                    width: 50,
                  ),
                  16.s,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (callData.callType == CallType.video ||
                                  callData.callType == CallType.voice)

                              // ? callData.sender?.name ?? ""
                              ? (callData.sender?.isActiveNickname ?? false)
                                  ? (callData.sender?.nickName ??
                                      callData.sender?.name ??
                                      "")
                                  : callData.sender?.name ?? ""
                              : callData.chatInfo?.groupName ?? "",
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.medium(
                            fontSize: 18.sp,
                          ),
                        ),
                        6.s,
                        Row(
                          children: [
                            if (callData.callDirection != null)
                              SvgImage(source: callData.callDirection!.icon),
                            Text(
                              callData.createdAt
                                      ?.formattedDateWithDayMonthYearAtTime ??
                                  "",
                              style: AppTextStyles.regular(
                                  color: AppColors.white.withAlpha(50)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        key: callData.globalKey,
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          _showPopupMenu(context, callData);
                        },
                        child: SvgImage(
                          source: SvgAssets.icMoreDots,
                          color: AppColors.white,
                          width: 18.w,
                        ),
                      ),
                      6.s,
                      if (callData.createdAt != null)
                        Text(
                          (callData.createdAt ?? DateTime.now())
                              .formatMessageTimestamp(),
                          style: AppTextStyles.regular(
                              fontSize: 12.sp,
                              color: AppColors.white.withAlpha(65)),
                        ),
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

  void _showPopupMenu(
    BuildContext context,
    CallHistoryList callData,
  ) {
    // showMessage("_showPopupMenu");
    final RenderBox? renderBox =
        callData.globalKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      Offset offset = renderBox.localToGlobal(Offset.zero);
      double left = offset.dx;
      double top = offset.dy + renderBox.size.height; // Position below the icon

      showMenu<String>(
        context: context,
        position: RelativeRect.fromLTRB(left, top, left + 100, top + 200),
        color: AppColors.secondaryBgColor,
        items: [
          if (callData.chatInfo != null)
            PopupMenuItem(
              value: 'message',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.message,
                    color: AppColors.white,
                  ),
                  8.s,
                  Text(S.of(context).message,
                      style: AppTextStyles.regular(fontSize: 16.sp)),
                ],
              ),
              onTap: () async {
                if (callData.chatInfo != null &&
                    callData.chatInfo!.type == ChatType.group) {
                  await chatCubit.resetChatScreenState();
                  NavigationService().navigateTo(
                    // chatId: callData.chatInfo?.id ?? '',
                    ChatScreen(
                      chatType: callData.chatInfo?.type ?? ChatType.group,
                      unreadMessageCount:
                          callData.chatInfo?.unreadMessageCount ?? 0,
                      aesKey: callData.chatInfo?.encryptedAESKey ?? "",
                      userName: callData.chatInfo?.groupName ?? "",
                      userId: "",
                      createdBy: callData.chatInfo?.createdBy,
                      userPic: callData.chatInfo?.groupImage ?? "",
                      chatId: callData.chatInfo?.id ?? '',
                      lastMessage: callData.chatInfo?.lastMessage,
                      isSendMessage: callData.chatInfo?.isSendMessage ?? true,
                      isShowProfileImage:
                          callData.chatInfo?.isProfilePhoto ?? true,
                    ),
                  );
                } else if (callData.sender != null &&
                    callData.chatInfo != null) {
                  ParticipantDetail sender =
                      ParticipantDetail.fromJson(callData.sender!.toJson());
                  await chatCubit.resetChatScreenState();
                  NavigationService().navigateTo(
                      // chatId: callData.chatInfo?.id ?? '',
                      ChatScreen(
                    chatType: callData.chatInfo?.type ?? ChatType.one_to_one,
                    unreadMessageCount:
                        callData.chatInfo?.unreadMessageCount ?? 0,
                    aesKey: callData.chatInfo?.encryptedAESKey ?? "",
                    sender: sender,
                    userName: sender.name ?? "",
                    userId: sender.id ?? "",
                    userPic: sender.profilePicture ?? "",
                    chatId: callData.chatInfo?.id ?? '',
                    lastMessage: callData.chatInfo?.lastMessage,
                    isSendMessage: callData.chatInfo?.isSendMessage ?? true,
                    isShowProfileImage:
                        callData.chatInfo?.isProfilePhoto ?? true,
                  ));
                }
              },
            ),
          if ((callData.callType == CallType.video_group_call ||
                  callData.callType == CallType.voice_group_call) &&
              callData.chatInfo != null &&
              callData.chatInfo?.id != null)
            PopupMenuItem(
              value: 'groupInfo',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgImage(
                    source: SvgAssets.icInfo,
                    color: AppColors.white,
                  ),
                  8.s,
                  Text(S.of(context).lblGroupInfo,
                      style: AppTextStyles.regular(fontSize: 16.sp)),
                ],
              ),
              onTap: () async {
                UserData? user = await homeCubit.dbHelper.getLoginData();

                if (user != null) {
                  NavigationService().navigateTo(GroupInfoScreen(
                    groupId: callData.chatInfo?.id ?? "",
                    currentUser: user,
                  ));
                }
              },
            ),
          PopupMenuItem(
            value: 'calls',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgImage(
                  source: SvgAssets.icCalls,
                  color: AppColors.white,
                ),
                8.s,
                Text(S.of(context).calls,
                    style: AppTextStyles.regular(fontSize: 16.sp)),
              ],
            ),
            onTap: () async {
              showMessage("call type =${callData.callType?.name}");
              if (callData.callType == null) return;
              if (callData.callType == CallType.video_group_call ||
                  callData.callType == CallType.voice_group_call) {
                NavigationService().navigateTo(GroupCallingPage(
                  callType: callData.callType!,
                  // callId: callData.callId,
                  currentConversationId: callData.chatInfo?.id ?? "",
                  image: callData.chatInfo?.groupImage ?? "",
                  receiverId: '',
                  name: callData.chatInfo?.groupName ?? '',
                  isActive: false,
                  from: "Call History",
                ));
              } else {
                showMessage("_initializeOutgoingCall==>=${callData.toJson()} ");
                // print(AppMethods.getNickName(callData.sender));
                NavigationService().navigateTo(CallingPage(
                  callType: callData.callType!,
                  currentConversationId: callData.chatInfo?.id ?? "",
                  image: callData.sender?.profilePicture ?? "",
                  receiverId: callData.sender?.id,
                  // name: callData.sender?.name ?? '',
                  name: AppMethods.getNickName(callData.sender),
                  isActive: false,
                  from: "Call History",
                ));
              }
            },
          ),
          if (!((callData.callType == CallType.video_group_call ||
                  callData.callType == CallType.voice_group_call) &&
              callData.chatInfo != null &&
              callData.chatInfo?.id != null))
            PopupMenuItem(
              value: "more",
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_right,
                    color: AppColors.white,
                  ),
                  // SvgImage(
                  //   source: SvgAssets.copy,
                  //   color: AppColors.white,
                  // ),
                  8.s,
                  Text(S.current.more, style: AppTextStyles.regular()),
                ],
              ),
              onTap: () {
                _showMoreMenu(context, callData, left, top);
              },
            ),
        ],
      ).then((value) {
        if (value != null) {
          showMessage("Selected: $value");
        }
      });
    }
  }

  Future<void> _showMoreMenu(BuildContext context, CallHistoryList callData,
      double left, double top) async {
    String? moreOption = await showMenu(
      context: context,
      color: AppColors.secondaryBgColor,
      position: RelativeRect.fromLTRB(left, top, left + 120, top + 200),
      items: [
        if ((callData.callType != CallType.video_group_call ||
                callData.callType != CallType.voice_group_call) &&
            callData.sender != null &&
            callData.sender?.isOnline != null)
          PopupMenuItem(
            value: 'viewContact',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgImage(
                  source: SvgAssets.icPerson,
                  color: AppColors.white,
                ),
                8.s,
                Text(S.of(context).viewContact,
                    style: AppTextStyles.regular(fontSize: 16.sp)),
              ],
            ),
            onTap: () {
              if (callData.sender != null &&
                  callData.sender?.isOnline != null) {
                log("sender ${callData.sender!.toJson()}");
                NavigationService().navigateTo(UserProfileScreen(
                  user: UserData.fromJson(callData.sender!.toJson()),
                ));
              }
            },
          ),
        // PopupMenuItem(
        //   value: 'invite_group',
        //   child: Row(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       Icon(
        //         Icons.group_add,
        //         color: AppColors.white,
        //       ),
        //       8.s,
        //       Text(S.of(context).inviteToGroup,
        //           style: AppTextStyles.regular(fontSize: 16.sp)),
        //     ],
        //   ),
        // ),
        // PopupMenuItem(
        //   value: 'invite_channel',
        //   child: Row(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       SvgImage(
        //         source: SvgAssets.megaphone,
        //         // color: AppColors.white,
        //       ),
        //       8.s,
        //       Text(S.of(context).inviteToGroup,
        //           style: AppTextStyles.regular(fontSize: 16.sp)),
        //     ],
        //   ),
        // ),
        PopupMenuItem(
          value: 'report',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.report,
                color: AppColors.white,
              ),
              8.s,
              Text(S.of(context).reportUser,
                  style: AppTextStyles.regular(fontSize: 16.sp)),
            ],
          ),
          onTap: () {
            NavigationService().navigateTo(ReportUserPage(
              onReport: (reason, description) async {
                showMessage("Report User $reason   $description");

                await homeCubit.reportUser(
                    userId: callData.sender?.id ?? "",
                    userName: callData.sender?.name ?? "",
                    reason: reason,
                    description: description,
                    context: context);
              },
            ));
          },
        ),
        PopupMenuItem(
          value: 'block',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.block,
                color: AppColors.white,
              ),
              8.s,
              Text(S.of(context).blockUser,
                  style: AppTextStyles.regular(fontSize: 16.sp)),
            ],
          ),
          onTap: () {
            showCommonBlockUserDialog(
                context: context,
                onSubmit: () {
                  homeCubit.blockedUser(
                    chatId: callData.chatInfo?.id ?? "",
                    userId: callData.sender?.id ?? "",
                    context: context,
                    callback: () async {
                      await fetchAllCallHistory();
                      if (isSelectionMode) {
                        clearSelection();
                      }
                      Utils.showSnackBar(
                          context,
                          S.of(context).blockUserSuccessfully(
                              callData.sender?.name ?? ""));
                    },
                  );
                },
                title: S.of(context).blockUserTitle,
                subTitle: S.of(context).blockUserSubtitle(
                    callData.sender?.name ?? S.of(context).blockedContacts));
          },
        ),
      ],
    );

    if (moreOption != null) {
      showMessage("Selected: $moreOption");
    }
  }
}
