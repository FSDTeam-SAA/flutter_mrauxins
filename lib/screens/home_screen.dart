import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:two_one_two_messenger/GoogleAds/BannerAds/BannerAdManager.dart';
import 'package:two_one_two_messenger/cubit/home_state.dart';
import 'package:two_one_two_messenger/cubit/user_data_cubit.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/chat_message_model.dart';
import 'package:two_one_two_messenger/models/conversation_model.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/models/stories_response.dart';
import 'package:two_one_two_messenger/screens/archive_chats_screen.dart';
import 'package:two_one_two_messenger/screens/channel_info.dart';
import 'package:two_one_two_messenger/screens/groupCall.dart';
import 'package:two_one_two_messenger/screens/group_info.dart';
import 'package:two_one_two_messenger/screens/search_conversation_screen.dart';
import 'package:two_one_two_messenger/screens/search_screen.dart';
import 'package:two_one_two_messenger/screens/view_stories_screen.dart';
import 'package:two_one_two_messenger/screens/voice_call_page.dart';
import 'package:two_one_two_messenger/services/api_config.dart';
import 'package:two_one_two_messenger/services/notification_handler.dart';
import 'package:two_one_two_messenger/services/push_notifications.dart';
import 'package:two_one_two_messenger/services/socket_service.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/widgets/buttons.dart';
import 'package:two_one_two_messenger/widgets/conversation_tile.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';
import 'package:two_one_two_messenger/widgets/network_image.dart';
import 'package:two_one_two_messenger/widgets/refresh_indicator%20copy.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';

import '../cubit/home_cubit.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/text_style.dart';
import '../utils/utils.dart';
import '../widgets/appbar.dart';
import '../widgets/drawer.dart';
import 'chat_screen.dart';
import 'stories_view_screen.dart';

const List<String> list = <String>['5', '10', '15', '20', 'All'];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  // User? user;
  final ScrollController _scrollController = ScrollController();
  int currentPage = 1;
  UserData? user;
  AppLifecycleState? _previousLifecycleState;
  final SocketService _socketService = SocketService();
  final NotificationService _notificationService = NotificationService();
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    onInit();

    // Fetch login data when the widget is initialized
    // context.read<LoginCubit>().getLoginData();
  }

  @override
  void dispose() {
    try {
      print("dispose==> emitUserOnlineStatus==>${{
        "userId": user?.sId,
        "isOnline": false,
      }} ");
      _stopHeartBeat();

      disposeAllEvents();
      _notificationService.dispose();
      super.dispose();
    } catch (e, st) {
      print("Dispose error $e $st");
    }

    _handleAsyncDisposeTasks();
  }

  Future<void> _handleAsyncDisposeTasks() async {
    try {
      debugPrint("Setting user offline status");
      await emitUserOnlineStatus(false);
      user = null;
    } catch (e, st) {
      debugPrint("Error in async dispose tasks: $e\n$st");
    }
  }

  Future<void> onInit() async {
    user ??= await homeCubit.dbHelper.getLoginData();
    homeCubit.fetchContactsForSync(context);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        context.read<HomeCubit>().fetchStoriesMoreData(currentPage, context);
        currentPage++;
      }
    });
    adConfigCubit.fetchConfig();
    homeCubit.getAgoraAppId();
    _notificationService.initialize(
      user: user,
      homeCubit: homeCubit,
      chatCubit: chatCubit,
      socketService: _socketService,
    );
    // _handleNotificationClick();
    fetchData();

    // showMessage("user Id==>${user?.sId}");
    _socketService
        .joinEvent(AppConstants.socketJoinChat, {"userId": user?.sId});
    _socketService.setUnreadNotificationCount({"userId": user?.sId});
    _socketService.receiveMessage(
      // AppConstants.socketReceiveMessage,

      (data) {
        // showMessage("DATATAreceiveMessage>>>>.${data.runtimeType}");
        MessageModel message =
            MessageModel.fromJson(data, data["encryptedAESKey"] ?? "");
        // showMessage("user Id==>${chatCubit.chatId == message.chatId}");
        showMessage(
            "receiveMessag>> Data:::: chat id${chatCubit.chatId} =${chatCubit.chatId == message.chatId}  $data");
        if (chatCubit.chatId == message.chatId) {
          if (mounted) {
            chatCubit.onReceivedMessage(
                context, data, user?.sId ?? "", data["encryptedAESKey"] ?? "");
          }
        } else {
          fetchConversationData();
          refreshStoriesData();
          // homeCubit.updateConversationById(lastMessage: message);
        }
      },
    );
    _socketService.receiveSystemMessage(
      // AppConstants.receiveSystemMessage,
      (data) {
        MessageModel message =
            MessageModel.fromJson(data, data["encryptedAESKey"] ?? "");
        // showMessage("user Id==>${chatCubit.chatId == message.chatId}");
        showMessage(
            "receiveMessag>> Data:::: chat id${chatCubit.chatId} =${chatCubit.chatId == message.chatId}  $data");
        if (chatCubit.chatId == message.chatId) {
          if (mounted) {
            chatCubit.onReceivedSystemMessage(
                context, data, user?.sId ?? "", data["encryptedAESKey"] ?? "");
          }
        } else {
          fetchConversationData();
          // homeCubit.updateConversationById(lastMessage: message);
        }
      },
    );

    _socketService.onUnArchiveChat(
      (data) async {
        showMessage("un chatArchived==> $data");
        await fetchConversationData();
      },
    );
    _socketService.onArchiveChat(
      (data) async {
        showMessage("chatArchived==> $data");
        await fetchConversationData();
      },
    );
    _socketService.onError(
      (data) {
        showMessage("receiveMessag>> Data::::$data");
        if (data["message"] != null) return;
        // Utils.showSnackBar(context, data["message"]);
      },
    );

    _socketService.onEditMessage(
      (data) {
        showMessage("receiveMessag>> Data::::$data");
        MessageModel message =
            MessageModel.fromJson(data, data["encryptedAESKey"] ?? "");
        // showMessage("user Id==>${chatCubit.chatId == message.chatId}");
        if (chatCubit.chatId == message.chatId) {
          if (mounted) {
            chatCubit.onReceivedEditedMessage(
                context, data, user?.sId ?? "", data["encryptedAESKey"] ?? "");
          }
        } else {
          // fetchConversationData();
          // homeCubit.updateConversationById(lastMessage: message);
        }
      },
    );
    _socketService.onReactMessageEvent(
      (data) {
        showMessage("onReactMessageEvent>> Data::::$data");
        MessageModel message =
            MessageModel.fromJson(data, data["encryptedAESKey"] ?? "");
        // showMessage("user Id==>${chatCubit.chatId == message.chatId}");
        if (chatCubit.chatId == message.chatId) {
          if (mounted) {
            chatCubit.onReceivedReactMessage(
                context, data, data["encryptedAESKey"] ?? "");
          }
        } else {
          // fetchConversationData();
          // homeCubit.updateConversationById(lastMessage: message);
        }
      },
    );

    _socketService.deleteMessage(
      (data) {
        showMessage("receiveMessag>> Data::::$data");

        // showMessage("user Id==>${chatCubit.chatId == message.chatId}");
        if (chatCubit.chatId == data["chatId"]) {
          if (mounted) {
            chatCubit.onDeleteMessage(context, data["messageId"]);
          }
        } else {
          fetchConversationData();
          // homeCubit.updateConversationById(lastMessage: message);
        }
      },
    );
    _socketService.onUpdateNotificationCount(
      (data) {
        showMessage("onUpdateNotificationCount==> $data");
        homeCubit.updateNotificationCount(data["unreadCount"]);
      },
    );

    _socketService.onReceiveCall(
      (callData) {
        try {
          showMessage(":: OnReceiveCall $callData");
          CallType callType = CallType.values.firstWhere(
            (element) => element.name == callData["call_type"],
          );
          if (callType == CallType.video_group_call ||
              callType == CallType.voice_group_call) {
            NavigationService().navigateTo(GroupCallingPage(
              token: callData["token"],
              callId: callData["callId"],
              channelName: callData["channel_name"],
              callType: callType,
              name: callData["groupName"] ?? "",
              image: callData["groupImage"] ?? "",
              receiverId: callData["participantId"],
              from: "home screen backgraound",
              currentConversationId: callData["chat_id"],
            ));
          } else {
            NavigationService().navigateTo(CallingPage(
              token: callData["token"],
              channelName: callData["channel_name"],
              callType: callType,
              name: callData["sender"]["name"], // userName
              image: callData["sender"]["profilePicture"] ?? "",
              receiverId: callData["participantId"],
              from: "notification handler",
              callId: callData["callId"],
              currentConversationId: callData["chat_id"],
            ));
          }
        } catch (e, st) {
          showMessage("Error ==> $e, $st");
        }
      },
    );

    _socketService.onPinConvesation(
      (p0) async {
        showMessage("onPinConvesation DATA ==> $p0");
        await fetchConversationData();
      },
    );

    _socketService.onMuteConvesation(
      (p0) async {
        showMessage("onMuteConvesation DATA ==> $p0");
        await fetchConversationData();
      },
    );

    print("init ==> emitUserOnlineStatus==>${{
      "userId": user?.sId,
      "isOnline": true,
    }} ");
    emitUserOnlineStatus(true);
    _startHeartBeat();
  }

  Future<void> _handleNotificationClick() async {
    FireBaseNotification.selectNotificationSubject.stream
        .distinct() // Only emit when the value changes
        .listen(
      (event) async {
        log("_handleCallKit called==>$event ==>${DateTime.now}");
        print("_handleCallKit-->${event['type']} ${DateTime.now}");
        final notificationId =
            NotificationDebouncer.generateNotificationId(event);

        // Skip if this notification was recently processed
        if (!NotificationDebouncer.shouldProcess(notificationId)) {
          debugPrint('Skipping duplicate notification: $notificationId');
          return;
        }
        if (event.containsKey('type')) {
          // _socketService
          //     .joinEvent(AppConstants.socketJoinChat, {"userId": user?.sId});
          if (event['type'] == "chat_message") {
            Utils.showLoader();
            await Future.delayed(Durations.extralong4);
            ChatType chatType = event["chatType"] != null
                ? ChatType.values.firstWhere(
                    (element) => element.name == event["chatType"],
                  )
                : ChatType.one_to_one;

            if (chatType != ChatType.one_to_one) {
              if (event.containsKey("groupInfo") &&
                  event["groupInfo"] is String) {
                event["groupInfo"] = json.decode(event["groupInfo"]);
              }
              FireBaseNotification().cancelAllLocalNotification();
              NavigationService().popUntil();
              await chatCubit.resetChatScreenState();
              Utils.hideLoader();
              NavigationService().navigateToChat(ChatScreen(
                chatType: chatType,
                unreadMessageCount: 0,
                userName: event["groupInfo"]["groupName"],
                userId: event["sender"]["_id"],
                userPic: event["groupInfo"]["groupImage"] ?? "",
                chatId: event["chat_id"],
                aesKey: event["encryptedAESKey"],
                isSendMessage: event["groupInfo"]["isSendMessage"] ?? true,
                isShowProfileImage:
                    event["groupInfo"]["isProfilePhoto"] ?? true,
                lastMessage: LastMessage(
                    content: event["content"],
                    messageId: event["temp_message_id"]),
              ));
            } else {
              ParticipantDetail sender =
                  ParticipantDetail.fromJson(event["sender"]);
              FireBaseNotification().cancelAllLocalNotification();
              NavigationService().popUntil();
              await chatCubit.resetChatScreenState();

              Utils.hideLoader();
              NavigationService().navigateToChat(
                  // chatId:  event["chat_id"],
                  ChatScreen(
                chatType: chatType,
                unreadMessageCount: 0,
                sender: sender,
                userName: event["sender"]["name"],
                userId: event["sender"]["_id"],
                userPic: event["sender"]["profilePicture"] ?? "",
                chatId: event["chat_id"],
                isSendMessage: true,
                aesKey: event["encryptedAESKey"],
                isShowProfileImage: true,
                lastMessage: LastMessage(
                    content: event["content"],
                    messageId: event["temp_message_id"]),
              ));
            }
          } else if (event["type"] == "agora_call_invitation" &&
              event["call_type"] != null) {
            CallType callType = CallType.values.firstWhere(
              (element) => element.name == event["call_type"],
            );

            NavigationService().popUntil();
            await Future.delayed(Durations.long1);
            if (callType == CallType.video_group_call ||
                callType == CallType.voice_group_call) {
              showMessage("inComming Call $callType==> $event");
              NavigationService().navigateTo(GroupCallingPage(
                token: event["token"],
                channelName: event["channel_name"],
                callType: callType,
                callId: event["callId"],
                name: event["groupName"] ?? "",
                image: event["groupImage"] ?? "",
                receiverId: (event["receiver_id"] != null &&
                        (event["receiver_id"].toString()).isNotEmpty)
                    ? event["receiver_id"]
                    : user?.sId ?? "",
                from: "home screen backgraound",
                isActive: event["isActive"] ?? true,
                currentConversationId: event["chat_id"],
              ));
            } else {
              print("DATA>>>>>>>>>> ******$event");
              print("NAME>>>>>>>*****. ${event["sender"]["name"]}");
              NavigationService().navigateTo(CallingPage(
                token: event["token"],
                channelName: event["channel_name"],
                callType: callType,
                callId: event["callId"],
                name: event["sender"]["name"], //userName
                image: event["sender"]["profilePicture"] ?? "",
                receiverId: (event["receiver_id"] != null &&
                        (event["receiver_id"].toString()).isNotEmpty)
                    ? event["receiver_id"]
                    : user?.sId ?? "",
                from: "home screen backgraound",
                isActive: event["isActive"] ?? true,
                currentConversationId: event["chat_id"],
              ));
            }
          } else if (event["type"] == NotificationType.group_invite.name ||
              event["type"] == NotificationType.create_new_group.name ||
              event["type"] == NotificationType.assign_admin.name ||
              event["type"] == NotificationType.delete_group.name ||
              event["type"] == NotificationType.removed_group.name ||
              event["type"] == NotificationType.removed_member_group.name ||
              event["type"] == NotificationType.new_group_created.name ||
              event["type"] == NotificationType.leave_group.name) {
            UserData? user = await homeCubit.dbHelper.getLoginData();
            if (user == null) return;
            NavigationService().navigateTo(GroupInfoScreen(
              currentUser: user,
              groupId: event["chat_id"] ?? "",
            ));
          } else if (event["type"] == NotificationType.channel_mention.name ||
              event["type"] == NotificationType.create_new_channel.name ||
              event["type"] == NotificationType.channel_invite.name ||
              event["type"] == NotificationType.removed_channel.name ||
              event["type"] == NotificationType.leave_channel.name ||
              event["type"] == NotificationType.delete_channel.name ||
              event["type"] == NotificationType.removed_member_channel.name) {
            UserData? user = await homeCubit.dbHelper.getLoginData();
            if (user == null) return;
            NavigationService().navigateTo(ChannelInfoScreen(
              currentUser: user,
              groupId: event["chat_id"] ?? "",
            ));
          }
        } else {
          debugPrint("No route specified in the message data.");
        }
      },
    );
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _previousLifecycleState = state;
        _startHeartBeat();
        if (_previousLifecycleState != AppLifecycleState.inactive) {
          showMessage("App is in the foreground (resumed).");

          emitUserOnlineStatus(true);
        }
        break;
      case AppLifecycleState.inactive:
        showMessage("App is inactive.");
// prefs.setBool("call_when_background", true);
        // emitUserOnlineStatus(false);
        _stopHeartBeat();
        break;
      case AppLifecycleState.paused:
        _previousLifecycleState = state;
        showMessage("App is in the background (paused).");
        emitUserOnlineStatus(false);
        break;
      case AppLifecycleState.detached:
        showMessage("App is detached.");
        _previousLifecycleState = state;
        emitUserOnlineStatus(false);
        break;
      case AppLifecycleState.hidden:
        showMessage("App is hidden.");
        _previousLifecycleState = state;
        emitUserOnlineStatus(false);
    }
  }

  fetchStoriesData() async {
    await homeCubit.getStoriesData(currentPage, context);
    if (currentPage == 1) {
      currentPage++;
    }
  }

  refreshStoriesData() async {
    // if ((homeCubit.state.storiesModel?.data ?? []).isNotEmpty
    //     // &&(homeCubit.state.storiesModel?.data ?? []).any((element) {
    //     // },)
    //     ) {
    await homeCubit.refreshStoriesData(context);
    currentPage = 1;
    // }
  }

  Future<void> fetchConversationData() async {
    await context.read<HomeCubit>().getConversation(context: context);
    showMessage("state ==> ${context.read<HomeCubit>().state}");
  }

  Future<void> fetchData() async {
    currentPage = 1;
    fetchStoriesData();
    await fetchConversationData();
  }

  Future<void> emitUserOnlineStatus(bool isOnline) async {
    if (!isOnline) {
      _stopHeartBeat();
    }
    print("emitUserOnlineStatus==>${{
      "userId": user?.sId,
      "isOnline": isOnline,
    }} ");
    _socketService.sendEvent(AppConstants.emitUserOnlinestatus, {
      "userId": user?.sId,
      "isOnline": isOnline,
    });
  }

  Timer? _heartBeatTimer;
  void _startHeartBeat() {
    _heartBeatTimer?.cancel();
    print("_start HeartBeat");
    _heartBeatTimer = Timer.periodic(Duration(seconds: 55), (timer) {
      print("_start HeartBeat==>");
      _socketService.sendHeartBeat({"userId": user?.sId});
    });
  }

  void _stopHeartBeat() {
    _heartBeatTimer?.cancel();
    _heartBeatTimer = null;
    print("_stop HeartBeat");
  }

  void disposeAllEvents() {
    _socketService.off(AppConstants.socketReceiveMessage);
    _socketService.off(AppConstants.receiveSystemMessage);
    _socketService.off(AppConstants.onUnArchiveChat);
    _socketService.off(AppConstants.onArchiveChat);
    _socketService.off(AppConstants.errorMessage);
    _socketService.off(AppConstants.onEditMessage);
    _socketService.off(AppConstants.onReactMessageEvent);
    _socketService.off(AppConstants.deleteMessageEveryone);
    _socketService.off(AppConstants.getUnreadNotificationCount);
    _socketService.off(AppConstants.receiveCall);
  }

  @override
  Widget build(BuildContext context) {
    user = context.watch<UserDataCubit>().state;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        final shouldPop = await Utils.showBackDialog(context) ?? false;

        if (context.mounted && shouldPop) {
          await emitUserOnlineStatus(false);
          disposeAllEvents();
          user = null;
          _stopHeartBeat();
          exit(0);
        }
      },
      child: Scaffold(
        endDrawer: CustomDrawer(),
        bottomNavigationBar: const BannerAdManager(),
        appBar: CommonAppBar(
          automaticallyImplyLeading: false,
          title: AppConstants.messenger,
          onSearch: () {
            NavigationService().navigateTo(SearchConversationScreen(
              user: user,
            ));
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primaryColor,
          shape: CircleBorder(),
          onPressed: () {
            NavigationService().navigateTo(SearchScreen());
          },
          child: SvgImage(
            source: SvgAssets.icAddRounded,
            width: 30.w,
            height: 30.h,
            color: AppColors.white,
          ),
        ),
        body: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: CustomRefreshIndicator(
            onRefresh: fetchData,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    S.of(context).todayStories,
                    style: AppTextStyles.medium(
                      fontSize: 16.sp,
                      color: AppColors.purpleText,
                    ),
                  ),
                ),
                Container(
                  height: 94.h,
                  padding: EdgeInsets.all(8.h),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // GestureDetector(
                        //   // onTap: () => NavigationService().navigateTo(Routes.viewStories),
                        //   onTap: () =>
                        //       NavigationService().navigateTo(CreateStoriesScreen()),
                        //   child: Padding(
                        //     padding: EdgeInsets.symmetric(horizontal: 8.w),
                        //     child: Column(
                        //       children: [
                        //         Container(
                        //           width: 70.w,
                        //           height: 70.w,
                        //           decoration: BoxDecoration(
                        //             color: AppColors.darkInputFill,
                        //             shape: BoxShape.circle,
                        //           ),
                        //           child: Center(
                        //             child: SvgImage(
                        //               source: SvgAssets.icAddRounded,
                        //               width: 30.w,
                        //               height: 30.h,
                        //               color: AppColors.white,
                        //             ),
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        BlocBuilder<HomeCubit, HomeState>(
                            builder: (context, state) {
                          if (state.userHaveStory) {
                            return GestureDetector(
                              onTap: () {
                                // try {
                                //   int? i = null;
                                //   final p = i! * 2;
                                // } catch (e, st) {
                                //   FirebaseCrashlytics.instance.recordError(e, st);
                                // }
                                NavigationService()
                                    .navigateTo(ViewStoriesScreen());
                              },
                              child: Padding(
                                // width: 85.h,
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 70.h,
                                      height: 70.h,
                                      decoration: BoxDecoration(
                                        color: AppColors.darkInputFill,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: AppColors.greenColor,
                                            width: 2.w),
                                      ),
                                      child: ClipOval(
                                        child: (user?.profilePicture != null)
                                            ? AppNetworkImage(
                                                imageUrl:
                                                    '${Urls.mediaUrl}${user?.profilePicture}')
                                            : Center(
                                                child: SvgImage(
                                                  source: SvgAssets.icPerson,
                                                  color: AppColors.white,
                                                ),
                                              ),
                                      ),
                                    ),
                                    Container(
                                      width: 70.h,
                                      height: 70.h,
                                      decoration: BoxDecoration(
                                        color: AppColors.darkInputFill
                                            .withAlpha(150),
                                        border: Border.all(
                                            color: AppColors.greenColor,
                                            width: 2.w),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: SvgImage(
                                          source: SvgAssets.icAddRounded,
                                          width: 30.h,
                                          height: 30.h,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return GestureDetector(
                              onTap: () => NavigationService()
                                  .navigateTo(ViewStoriesScreen()),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 70.h,
                                      height: 70.h,
                                      decoration: BoxDecoration(
                                        color: AppColors.darkInputFill,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: SvgImage(
                                          source: SvgAssets.icAddRounded,
                                          width: 30.h,
                                          height: 30.h,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        }),
                        BlocBuilder<HomeCubit, HomeState>(
                          builder: (context, state) {
                            // final cubit = context.read<HomeCubit>();
                            if (state.storiesLoadingState ==
                                LoadingState.loading) {
                              return Center(child: CustomLoadingWidget());
                            } else if (state.storiesLoadingState ==
                                    LoadingState.success &&
                                (state.storiesModel?.data ?? []).isNotEmpty) {
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                primary: false,
                                itemCount: state.storiesModel!.data!.length,
                                itemBuilder: (context, index) {
                                  if (index ==
                                      state.storiesModel!.data!.length) {
                                    return SizedBox(
                                      height: 70.h,
                                      width: 70.h,
                                      child: Center(
                                        child: CustomLoadingWidget(),
                                      ),
                                    );
                                  }

                                  final data = state.storiesModel!.data![index];
                                  if (state.paginationLoadingState ==
                                          LoadingState.loading &&
                                      index ==
                                          state.storiesModel!.data!.length -
                                              1) {
                                    return Row(
                                      children: [
                                        storyWidget(
                                            data: data,
                                            onTap: () {
                                              NavigationService()
                                                  .navigateTo(StoriesViewScreen(
                                                storiesList:
                                                    state.storiesModel!.data!,
                                                index: index,
                                              ));
                                            }),
                                        CustomLoadingWidget()
                                      ],
                                    );
                                  }
                                  return storyWidget(
                                      data: data,
                                      onTap: () {
                                        NavigationService()
                                            .navigateTo(StoriesViewScreen(
                                          storiesList:
                                              state.storiesModel!.data!,
                                          index: index,
                                        ));
                                      });
                                },
                              );
                            } else if (state.storiesLoadingState ==
                                LoadingState.error) {
                              return Center(
                                child: GestureDetector(
                                  onTap: () {
                                    fetchStoriesData();
                                  },
                                  child: Container(
                                    width: 70.h,
                                    height: 70.h,
                                    decoration: BoxDecoration(
                                      color: AppColors.darkInputFill,
                                      shape: BoxShape.circle,
                                    ),
                                    child: ClipOval(
                                      child: Center(
                                          child: Icon(
                                        Icons.refresh,
                                        color: AppColors.cardBGColor,
                                      )),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return SizedBox.shrink();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    S.of(context).recentMessage,
                    style: AppTextStyles.medium(
                      fontSize: 16.sp,
                      color: AppColors.purpleText,
                    ),
                  ),
                ),
                10.h.s,
                BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
                  if ((state.conversationModel?.archiveChats ?? []).isEmpty) {
                    return SizedBox();
                  }
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (user != null) {
                        NavigationService().navigateTo(ArchiveChats(
                          user: user!,
                        ));
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 50.w,
                            width: 50.w,
                            decoration: BoxDecoration(
                              color: AppColors.darkInputFill,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.archive,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 15.w),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    S.of(context).archiveChats ?? "",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style:
                                        AppTextStyles.medium(fontSize: 16.sp),
                                  ),
                                  SizedBox(height: 5.h),
                                  Text(
                                    S.of(context).numberOfArchiveChats((state
                                                .conversationModel
                                                ?.archiveChats ??
                                            [])
                                        .length),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        AppTextStyles.regular(fontSize: 12.sp),
                                  ),
                                ]),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                10.h.s,
                Expanded(
                  child: BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, state) {
                      if (state.homeLoadingState == LoadingState.loading) {
                        return Center(child: CustomLoadingWidget());
                      } else if (state.homeLoadingState ==
                          LoadingState.success) {
                        if ((state.conversationModel?.data ?? []).isEmpty) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                  child: Text(
                                S.of(context).noConversationsFound,
                                style: AppTextStyles.regular(fontSize: 14.sp),
                              )),
                              20.s,
                              CustomButton(
                                  onPressed: () {
                                    fetchData();
                                  },
                                  child: Text(
                                    S.of(context).refresh,
                                    style:
                                        AppTextStyles.regular(fontSize: 14.sp),
                                  ))
                            ],
                          );
                        }

                        return SlidableAutoCloseBehavior(
                          child: ListView.separated(
                            separatorBuilder: (context, index) => Divider(
                              color: AppColors.dividerColor,
                              height: 1.h,
                            ),
                            itemCount: state.conversationModel!.data!.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              ParticipantDetail? participant;
                              bool isGroup =
                                  state.conversationModel!.data![index].type !=
                                      ChatType.one_to_one;
                              if (!isGroup) {
                                try {
                                  participant = state.conversationModel
                                      ?.data?[index].participantDetails
                                      ?.firstWhere(
                                          (element) => element.id != user?.sId);
                                } catch (e) {
                                  participant = null;
                                }
                              }
                              if (user == null) return SizedBox();
                              return ConversationTile(
                                user: user!,
                                isGroup: isGroup,
                                isArchive: false,
                                conversationData:
                                    state.conversationModel!.data![index],
                                participantDetails: participant,
                              );

                              // Padding(
                              //   padding: EdgeInsets.symmetric(
                              //       horizontal: 16.w, vertical: 16.h),
                              //   child: isGroup
                              //       ? GestureDetector(
                              //           behavior: HitTestBehavior.translucent,
                              //           onLongPress: () {
                              //             CustomAlertDialog(
                              //               context: context,
                              //               icon: Icon(
                              //                 Icons.archive,
                              //                 color: AppColors.white,
                              //               ),
                              //               title: S
                              //                   .of(context)
                              //                   .areYouSureToWantToArchiveThisChat,
                              //               buttonText: S.current.yes,
                              //               onPressed: () {
                              //                 homeCubit.archiveChat(
                              //                     user?.sId ?? "",
                              //                     state.conversationModel!
                              //                             .data![index].id ??
                              //                         "");
                              //               },
                              //             );
                              //           },
                              //           onTap: () {
                              //             NavigationService().navigateTo(ChatScreen(
                              //               chatType: state.conversationModel!
                              //                       .data![index].type ??
                              //                   ChatType.group,
                              //               unreadMessageCount: state
                              //                       .conversationModel
                              //                       ?.data?[index]
                              //                       .unreadMessageCount ??
                              //                   0,
                              //               aesKey: state
                              //                       .conversationModel
                              //                       ?.data?[index]
                              //                       .encryptedAESKey ??
                              //                   "",
                              //               userName: state.conversationModel!
                              //                       .data![index].groupName ??
                              //                   "",
                              //               userId: "",
                              //               createdBy: state.conversationModel
                              //                   ?.data?[index].createdBy,
                              //               userPic: state.conversationModel!
                              //                       .data![index].groupImage ??
                              //                   "",
                              //               chatId: state.conversationModel!
                              //                       .data![index].id ??
                              //                   '',
                              //               lastMessage: state.conversationModel
                              //                   ?.data?[index].lastMessage,
                              //               isSendMessage: state.conversationModel
                              //                       ?.data?[index].isSendMessage ??
                              //                   true,
                              //               isShowProfileImage: state
                              //                       .conversationModel
                              //                       ?.data?[index]
                              //                       .isProfilePhoto ??
                              //                   true,
                              //             ));
                              //           },
                              //           child: Row(
                              //             children: [
                              //               Container(
                              //                 height: 50.w,
                              //                 width: 50.w,
                              //                 decoration: BoxDecoration(
                              //                   color: AppColors.darkInputFill,
                              //                   shape: BoxShape.circle,
                              //                 ),
                              //                 child: ((state
                              //                                 .conversationModel
                              //                                 ?.data?[index]
                              //                                 .groupImage ??
                              //                             "")
                              //                         .isNotEmpty)
                              //                     ? AppNetworkImage(
                              //                         imageUrl:
                              //                             '${Urls.mediaUrl}${state.conversationModel?.data?[index].groupImage ?? ""}' ??
                              //                                 '',
                              //                         borderRadius:
                              //                             BorderRadius.all(
                              //                           Radius.circular(50.r),
                              //                         ),
                              //                         fit: BoxFit.cover,
                              //                       )
                              //                     : Center(
                              //                         child: SvgImage(
                              //                           source: SvgAssets.icPerson,
                              //                           color: AppColors.white,
                              //                         ),
                              //                       ),
                              //               ),
                              //               SizedBox(width: 15.w),
                              //               Expanded(
                              //                 child: Column(
                              //                     crossAxisAlignment:
                              //                         CrossAxisAlignment.start,
                              //                     children: [
                              //                       Text(
                              //                         state
                              //                                 .conversationModel
                              //                                 ?.data?[index]
                              //                                 .groupName ??
                              //                             "",
                              //                         style: AppTextStyles.medium(
                              //                             fontSize: 16.sp),
                              //                       ),
                              //                       SizedBox(height: 5.h),
                              //                       Text(
                              //                         state
                              //                                 .conversationModel!
                              //                                 .data![index]
                              //                                 .lastMessage
                              //                                 ?.content ??
                              //                             '',
                              //                         maxLines: 2,
                              //                         overflow:
                              //                             TextOverflow.ellipsis,
                              //                         style: AppTextStyles.regular(
                              //                             fontSize: 12.sp),
                              //                       ),
                              //                     ]),
                              //               ),
                              //               Column(
                              //                 children: [
                              //                   (state
                              //                                   .conversationModel
                              //                                   ?.data?[index]
                              //                                   .unreadMessageCount ??
                              //                               0) ==
                              //                           0
                              //                       ? SizedBox(
                              //                           height: 22.w,
                              //                           width: 22.w,
                              //                         )
                              //                       : Container(
                              //                           height: 22.w,
                              //                           width: 22.w,
                              //                           decoration: BoxDecoration(
                              //                               shape: BoxShape.circle,
                              //                               color: AppColors
                              //                                   .primaryColor),
                              //                           alignment: Alignment.center,
                              //                           child: Text(
                              //                             "${state.conversationModel?.data?[index].unreadMessageCount ?? 0}",
                              //                             style:
                              //                                 AppTextStyles.medium(
                              //                                     fontSize: 12.sp,
                              //                                     color: AppColors
                              //                                         .white),
                              //                           ),
                              //                         ),
                              //                   SizedBox(height: 10.h),
                              //                   Text(
                              //                     (state
                              //                                 .conversationModel!
                              //                                 .data![index]
                              //                                 .lastMessage
                              //                                 ?.createdAt ??
                              //                             DateTime.now())
                              //                         .formatMessageTimestamp(),
                              //                     style: AppTextStyles.regular(
                              //                         fontSize: 12.sp,
                              //                         color: AppColors.white
                              //                             .withOpacity(0.65)),
                              //                   ),
                              //                 ],
                              //               )
                              //             ],
                              //           ),
                              //         )
                              //       : GestureDetector(
                              //           behavior: HitTestBehavior.translucent,
                              //           onLongPress: () {
                              //             CustomAlertDialog(
                              //               context: context,
                              //               icon: Icon(
                              //                 Icons.archive,
                              //                 color: AppColors.white,
                              //               ),
                              //               title: S
                              //                   .of(context)
                              //                   .areYouSureToWantToArchiveThisChat,
                              //               buttonText: S.current.yes,
                              //               onPressed: () {
                              //                 homeCubit.archiveChat(
                              //                     user?.sId ?? "",
                              //                     state.conversationModel!
                              //                             .data![index].id ??
                              //                         "");
                              //               },
                              //             );
                              //           },
                              //           child: Column(
                              //             children: List.generate(
                              //               participantList.length,
                              //               (ind) => GestureDetector(
                              //                 behavior: HitTestBehavior.translucent,
                              //                 onTap: () {
                              //                   // showMessage(
                              //                   //     "lastMessahge=== ${state.conversationModel?.data?[index].lastMessage?.toJson()}");
                              //                   NavigationService()
                              //                       .navigateTo(ChatScreen(
                              //                     chatType: state.conversationModel!
                              //                             .data![index].type ??
                              //                         ChatType.one_to_one,
                              //                     unreadMessageCount: state
                              //                             .conversationModel
                              //                             ?.data?[index]
                              //                             .unreadMessageCount ??
                              //                         0,
                              //                     aesKey: state
                              //                             .conversationModel
                              //                             ?.data?[index]
                              //                             .encryptedAESKey ??
                              //                         "",
                              //                     sender: participantList[ind],
                              //                     userName:
                              //                         participantList[ind].name ??
                              //                             "",
                              //                     userId:
                              //                         participantList[ind].id ?? "",
                              //                     userPic: participantList[ind]
                              //                             .profilePicture ??
                              //                         "",
                              //                     chatId: state.conversationModel!
                              //                             .data![index].id ??
                              //                         '',
                              //                     lastMessage: state
                              //                         .conversationModel
                              //                         ?.data?[index]
                              //                         .lastMessage,
                              //                     isSendMessage: state
                              //                             .conversationModel
                              //                             ?.data?[index]
                              //                             .isSendMessage ??
                              //                         true,
                              //                     isShowProfileImage: state
                              //                             .conversationModel
                              //                             ?.data?[index]
                              //                             .isProfilePhoto ??
                              //                         true,
                              //                   ));
                              //                 },
                              //                 child: Row(
                              //                   children: [
                              //                     Container(
                              //                       height: 50.w,
                              //                       width: 50.w,
                              //                       decoration: BoxDecoration(
                              //                         color:
                              //                             AppColors.darkInputFill,
                              //                         shape: BoxShape.circle,
                              //                       ),
                              //                       child: (participantList[ind]
                              //                                   .profilePicture !=
                              //                               null)
                              //                           ? AppNetworkImage(
                              //                               imageUrl:
                              //                                   '${Urls.mediaUrl}${participantList[ind].profilePicture}' ??
                              //                                       '',
                              //                               borderRadius:
                              //                                   BorderRadius.all(
                              //                                 Radius.circular(50.r),
                              //                               ),
                              //                               fit: BoxFit.cover,
                              //                             )
                              //                           : Center(
                              //                               child: SvgImage(
                              //                                 source: SvgAssets
                              //                                     .icPerson,
                              //                                 color:
                              //                                     AppColors.white,
                              //                               ),
                              //                             ),
                              //                     ),
                              //                     SizedBox(width: 15.w),
                              //                     Expanded(
                              //                       child: Column(
                              //                           crossAxisAlignment:
                              //                               CrossAxisAlignment
                              //                                   .start,
                              //                           children: [
                              //                             Text(
                              //                               participantList[ind]
                              //                                       .name ??
                              //                                   '',
                              //                               style: AppTextStyles
                              //                                   .medium(
                              //                                       fontSize:
                              //                                           16.sp),
                              //                             ),
                              //                             SizedBox(height: 5.h),
                              //                             Text(
                              //                               state
                              //                                       .conversationModel!
                              //                                       .data![index]
                              //                                       .lastMessage
                              //                                       ?.content ??
                              //                                   '',
                              //                               maxLines: 2,
                              //                               overflow: TextOverflow
                              //                                   .ellipsis,
                              //                               style: AppTextStyles
                              //                                   .regular(
                              //                                       fontSize:
                              //                                           12.sp),
                              //                             ),
                              //                           ]),
                              //                     ),
                              //                     4.w.s,
                              //                     Column(
                              //                       children: [
                              //                         (state
                              //                                         .conversationModel
                              //                                         ?.data?[index]
                              //                                         .unreadMessageCount ??
                              //                                     0) ==
                              //                                 0
                              //                             ? SizedBox(
                              //                                 height: 22.w,
                              //                                 width: 22.w,
                              //                               )
                              //                             : Container(
                              //                                 height: 22.w,
                              //                                 width: 22.w,
                              //                                 decoration: BoxDecoration(
                              //                                     shape: BoxShape
                              //                                         .circle,
                              //                                     color: AppColors
                              //                                         .primaryColor),
                              //                                 alignment:
                              //                                     Alignment.center,
                              //                                 child: Text(
                              //                                   "${state.conversationModel?.data?[index].unreadMessageCount ?? 0}",
                              //                                   style: AppTextStyles
                              //                                       .medium(
                              //                                           fontSize:
                              //                                               12.sp,
                              //                                           color: AppColors
                              //                                               .white),
                              //                                 ),
                              //                               ),
                              //                         SizedBox(height: 10.h),
                              //                         Text(
                              //                           (state
                              //                                       .conversationModel!
                              //                                       .data![index]
                              //                                       .lastMessage
                              //                                       ?.createdAt ??
                              //                                   DateTime.now())
                              //                               .formatMessageTimestamp(),
                              //                           style:
                              //                               AppTextStyles.regular(
                              //                                   fontSize: 12.sp,
                              //                                   color: AppColors
                              //                                       .white
                              //                                       .withOpacity(
                              //                                           0.65)),
                              //                         ),
                              //                       ],
                              //                     )
                              //                   ],
                              //                 ),
                              //               ),
                              //             ),
                              //           ),
                              //         ),
                              // );
                            },
                          ),
                        );
                      } else if (state.homeLoadingState == LoadingState.error) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(child: Text(S.of(context).pleaseTryAgain)),
                            20.s,
                            CustomButton(
                                onPressed: () {
                                  fetchConversationData();
                                },
                                child: Text(
                                  S.of(context).refresh,
                                  style: AppTextStyles.baseStyle(),
                                ))
                          ],
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                  ),
                ),
                // SizedBox(height: 20.h),
                // BlocBuilder<HomeCubit, HomeState>(
                //     // buildWhen: (previous, current) =>
                //     //     current is HomeLoading ||
                //     //     current is HomeLoaded ||
                //     //     current is HomeError,
                //     builder: (context, state) {
                //   if ((state.conversationModel?.archiveChats ?? []).isEmpty) {
                //     return SizedBox();
                //   }
                //   return Padding(
                //     padding: EdgeInsets.symmetric(horizontal: 16.w),
                //     child: Text(
                //       S.of(context).archiveChats,
                //       style: AppTextStyles.medium(
                //         fontSize: 16.sp,
                //         color: AppColors.purpleText,
                //       ),
                //     ),
                //   );
                // }),
                // SizedBox(height: 10.h),
                // Expanded(
                //   child: BlocBuilder<HomeCubit, HomeState>(
                //     // buildWhen: (previous, current) =>
                //     //     current is HomeLoading ||
                //     //     current is HomeLoaded ||
                //     //     current is HomeError,
                //     builder: (context, state) {
                //       if (state.homeLoadingState == LoadingState.loading) {
                //         return Center(child: CustomLoadingWidget());
                //       } else if (state.homeLoadingState == LoadingState.success) {
                //         if ((state.conversationModel?.archiveChats ?? [])
                //             .isEmpty) {
                //           return SizedBox();
                //         }

                //         return ListView.separated(
                //           separatorBuilder: (context, index) => Divider(
                //             color: AppColors.dividerColor,
                //             height: 1.h,
                //           ),
                //           itemCount:
                //               state.conversationModel!.archiveChats!.length,
                //           shrinkWrap: true,
                //           itemBuilder: (context, index) {
                //             List<ParticipantDetail> participantList = [];
                //             bool isGroup = state.conversationModel!
                //                     .archiveChats![index].type !=
                //                 ChatType.one_to_one;
                //             if (!isGroup) {
                //               participantList = state.conversationModel!
                //                       .archiveChats![index].participantDetails
                //                       ?.where(
                //                           (element) => element.id != user?.sId)
                //                       .toList() ??
                //                   [];
                //             }

                //             return Padding(
                //               padding: EdgeInsets.symmetric(
                //                   horizontal: 16.w, vertical: 16.h),
                //               child: isGroup
                //                   ? GestureDetector(
                //                       behavior: HitTestBehavior.translucent,
                //                       onTap: () {
                //                         NavigationService().navigateTo(ChatScreen(
                //                           chatType: state.conversationModel!
                //                                   .archiveChats![index].type ??
                //                               ChatType.group,
                //                           unreadMessageCount: state
                //                                   .conversationModel
                //                                   ?.archiveChats?[index]
                //                                   .unreadMessageCount ??
                //                               0,
                //                           aesKey: state
                //                                   .conversationModel
                //                                   ?.archiveChats?[index]
                //                                   .encryptedAESKey ??
                //                               "",
                //                           userName: state
                //                                   .conversationModel!
                //                                   .archiveChats![index]
                //                                   .groupName ??
                //                               "",
                //                           userId: "",
                //                           createdBy: state.conversationModel
                //                               ?.archiveChats?[index].createdBy,
                //                           userPic: state
                //                                   .conversationModel!
                //                                   .archiveChats![index]
                //                                   .groupImage ??
                //                               "",
                //                           chatId: state.conversationModel!
                //                                   .archiveChats![index].id ??
                //                               '',
                //                           lastMessage: state.conversationModel
                //                               ?.archiveChats?[index].lastMessage,
                //                           isSendMessage: state
                //                                   .conversationModel
                //                                   ?.archiveChats?[index]
                //                                   .isSendMessage ??
                //                               true,
                //                           isShowProfileImage: state
                //                                   .conversationModel
                //                                   ?.archiveChats?[index]
                //                                   .isProfilePhoto ??
                //                               true,
                //                         ));
                //                       },
                //                       child: Row(
                //                         children: [
                //                           Container(
                //                             height: 50.w,
                //                             width: 50.w,
                //                             decoration: BoxDecoration(
                //                               color: AppColors.darkInputFill,
                //                               shape: BoxShape.circle,
                //                             ),
                //                             child: ((state
                //                                             .conversationModel
                //                                             ?.archiveChats?[index]
                //                                             .groupImage ??
                //                                         "")
                //                                     .isNotEmpty)
                //                                 ? AppNetworkImage(
                //                                     imageUrl:
                //                                         '${Urls.mediaUrl}${state.conversationModel?.archiveChats?[index].groupImage ?? ""}' ??
                //                                             '',
                //                                     borderRadius:
                //                                         BorderRadius.all(
                //                                       Radius.circular(50.r),
                //                                     ),
                //                                     fit: BoxFit.cover,
                //                                   )
                //                                 : Center(
                //                                     child: SvgImage(
                //                                       source: SvgAssets.icPerson,
                //                                       color: AppColors.white,
                //                                     ),
                //                                   ),
                //                           ),
                //                           SizedBox(width: 15.w),
                //                           Expanded(
                //                             child: Column(
                //                                 crossAxisAlignment:
                //                                     CrossAxisAlignment.start,
                //                                 children: [
                //                                   Text(
                //                                     state
                //                                             .conversationModel
                //                                             ?.archiveChats?[index]
                //                                             .groupName ??
                //                                         "",
                //                                     style: AppTextStyles.medium(
                //                                         fontSize: 16.sp),
                //                                   ),
                //                                   SizedBox(height: 5.h),
                //                                   Text(
                //                                     state
                //                                             .conversationModel!
                //                                             .archiveChats![index]
                //                                             .lastMessage
                //                                             ?.content ??
                //                                         '',
                //                                     maxLines: 2,
                //                                     overflow:
                //                                         TextOverflow.ellipsis,
                //                                     style: AppTextStyles.regular(
                //                                         fontSize: 12.sp),
                //                                   ),
                //                                 ]),
                //                           ),
                //                           Column(
                //                             children: [
                //                               (state
                //                                               .conversationModel
                //                                               ?.archiveChats?[
                //                                                   index]
                //                                               .unreadMessageCount ??
                //                                           0) ==
                //                                       0
                //                                   ? SizedBox(
                //                                       height: 22.w,
                //                                       width: 22.w,
                //                                     )
                //                                   : Container(
                //                                       height: 22.w,
                //                                       width: 22.w,
                //                                       decoration: BoxDecoration(
                //                                           shape: BoxShape.circle,
                //                                           color: AppColors
                //                                               .primaryColor),
                //                                       alignment: Alignment.center,
                //                                       child: Text(
                //                                         "${state.conversationModel?.archiveChats?[index].unreadMessageCount ?? 0}",
                //                                         style:
                //                                             AppTextStyles.medium(
                //                                                 fontSize: 12.sp,
                //                                                 color: AppColors
                //                                                     .white),
                //                                       ),
                //                                     ),
                //                               SizedBox(height: 10.h),
                //                               Text(
                //                                 (state
                //                                             .conversationModel!
                //                                             .archiveChats![index]
                //                                             .lastMessage
                //                                             ?.createdAt ??
                //                                         DateTime.now())
                //                                     .formatMessageTimestamp(),
                //                                 style: AppTextStyles.regular(
                //                                     fontSize: 12.sp,
                //                                     color: AppColors.white
                //                                         .withOpacity(0.65)),
                //                               ),
                //                             ],
                //                           )
                //                         ],
                //                       ),
                //                     )
                //                   : Column(
                //                       children: List.generate(
                //                         participantList.length,
                //                         (ind) => GestureDetector(
                //                           behavior: HitTestBehavior.translucent,
                //                           onTap: () {
                //                             // showMessage(
                //                             //     "lastMessahge=== ${state.conversationModel?.data?[index].lastMessage?.toJson()}");
                //                             NavigationService()
                //                                 .navigateTo(ChatScreen(
                //                               chatType: state
                //                                       .conversationModel!
                //                                       .archiveChats![index]
                //                                       .type ??
                //                                   ChatType.one_to_one,
                //                               unreadMessageCount: state
                //                                       .conversationModel
                //                                       ?.archiveChats?[index]
                //                                       .unreadMessageCount ??
                //                                   0,
                //                               aesKey: state
                //                                       .conversationModel
                //                                       ?.archiveChats?[index]
                //                                       .encryptedAESKey ??
                //                                   "",
                //                               sender: participantList[ind],
                //                               userName:
                //                                   participantList[ind].name ?? "",
                //                               userId:
                //                                   participantList[ind].id ?? "",
                //                               userPic: participantList[ind]
                //                                       .profilePicture ??
                //                                   "",
                //                               chatId: state.conversationModel!
                //                                       .archiveChats![index].id ??
                //                                   '',
                //                               lastMessage: state
                //                                   .conversationModel
                //                                   ?.archiveChats?[index]
                //                                   .lastMessage,
                //                               isSendMessage: state
                //                                       .conversationModel
                //                                       ?.archiveChats?[index]
                //                                       .isSendMessage ??
                //                                   true,
                //                               isShowProfileImage: state
                //                                       .conversationModel
                //                                       ?.archiveChats?[index]
                //                                       .isProfilePhoto ??
                //                                   true,
                //                             ));
                //                           },
                //                           child: Row(
                //                             children: [
                //                               Container(
                //                                 height: 50.w,
                //                                 width: 50.w,
                //                                 decoration: BoxDecoration(
                //                                   color: AppColors.darkInputFill,
                //                                   shape: BoxShape.circle,
                //                                 ),
                //                                 child: (participantList[ind]
                //                                             .profilePicture !=
                //                                         null)
                //                                     ? AppNetworkImage(
                //                                         imageUrl:
                //                                             '${Urls.mediaUrl}${participantList[ind].profilePicture}' ??
                //                                                 '',
                //                                         borderRadius:
                //                                             BorderRadius.all(
                //                                           Radius.circular(50.r),
                //                                         ),
                //                                         fit: BoxFit.cover,
                //                                       )
                //                                     : Center(
                //                                         child: SvgImage(
                //                                           source:
                //                                               SvgAssets.icPerson,
                //                                           color: AppColors.white,
                //                                         ),
                //                                       ),
                //                               ),
                //                               SizedBox(width: 15.w),
                //                               Expanded(
                //                                 child: Column(
                //                                     crossAxisAlignment:
                //                                         CrossAxisAlignment.start,
                //                                     children: [
                //                                       Text(
                //                                         participantList[ind]
                //                                                 .name ??
                //                                             '',
                //                                         style:
                //                                             AppTextStyles.medium(
                //                                                 fontSize: 16.sp),
                //                                       ),
                //                                       SizedBox(height: 5.h),
                //                                       Text(
                //                                         state
                //                                                 .conversationModel!
                //                                                 .archiveChats![
                //                                                     index]
                //                                                 .lastMessage
                //                                                 ?.content ??
                //                                             '',
                //                                         maxLines: 2,
                //                                         overflow:
                //                                             TextOverflow.ellipsis,
                //                                         style:
                //                                             AppTextStyles.regular(
                //                                                 fontSize: 12.sp),
                //                                       ),
                //                                     ]),
                //                               ),
                //                               4.w.s,
                //                               Column(
                //                                 children: [
                //                                   (state
                //                                                   .conversationModel
                //                                                   ?.archiveChats?[
                //                                                       index]
                //                                                   .unreadMessageCount ??
                //                                               0) ==
                //                                           0
                //                                       ? SizedBox(
                //                                           height: 22.w,
                //                                           width: 22.w,
                //                                         )
                //                                       : Container(
                //                                           height: 22.w,
                //                                           width: 22.w,
                //                                           decoration: BoxDecoration(
                //                                               shape:
                //                                                   BoxShape.circle,
                //                                               color: AppColors
                //                                                   .primaryColor),
                //                                           alignment:
                //                                               Alignment.center,
                //                                           child: Text(
                //                                             "${state.conversationModel?.archiveChats?[index].unreadMessageCount ?? 0}",
                //                                             style: AppTextStyles
                //                                                 .medium(
                //                                                     fontSize:
                //                                                         12.sp,
                //                                                     color: AppColors
                //                                                         .white),
                //                                           ),
                //                                         ),
                //                                   SizedBox(height: 10.h),
                //                                   Text(
                //                                     (state
                //                                                 .conversationModel!
                //                                                 .archiveChats![
                //                                                     index]
                //                                                 .lastMessage
                //                                                 ?.createdAt ??
                //                                             DateTime.now())
                //                                         .formatMessageTimestamp(),
                //                                     style: AppTextStyles.regular(
                //                                         fontSize: 12.sp,
                //                                         color: AppColors.white
                //                                             .withOpacity(0.65)),
                //                                   ),
                //                                 ],
                //                               )
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                     ),
                //             );
                //           },
                //         );
                //       } else if (state.homeLoadingState == LoadingState.error) {
                //         return Column(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             Center(child: Text(S.of(context).pleaseTryAgain)),
                //             20.s,
                //             CustomButton(
                //                 onPressed: () {
                //                   fetchConversationData();
                //                 },
                //                 child: Text(
                //                   AppConstants.refresh,
                //                   style: AppTextStyles.baseStyle(),
                //                 ))
                //           ],
                //         );
                //       } else {
                //         return SizedBox.shrink();
                //       }
                //     },
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget storyWidget({
    required void Function()? onTap,
    required GetAllStoriesData data,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        // width: 85.h,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          children: [
            Container(
              width: 70.h,
              height: 70.h,
              decoration: BoxDecoration(
                color: AppColors.darkInputFill,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryColor, width: 2.w),
              ),
              child: ClipOval(
                child: (data.userDetails?.profilePicture != null)
                    ? AppNetworkImage(
                        imageUrl:
                            '${Urls.mediaUrl}${data.userDetails?.profilePicture}')
                    : Center(
                        child: SvgImage(
                          source: SvgAssets.icPerson,
                          color: AppColors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
