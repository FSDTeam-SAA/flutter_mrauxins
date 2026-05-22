// import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:two_one_two_messenger/cubit/chat_cubit.dart';
import 'package:two_one_two_messenger/cubit/home_cubit.dart';
import 'package:two_one_two_messenger/models/conversation_model.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/screens/channel_info.dart';
import 'package:two_one_two_messenger/screens/chat_screen.dart';
import 'package:two_one_two_messenger/screens/groupCall.dart';
import 'package:two_one_two_messenger/screens/group_info.dart';
import 'package:two_one_two_messenger/screens/voice_call_page.dart';
import 'package:two_one_two_messenger/services/push_notifications.dart';
import 'package:two_one_two_messenger/services/socket_service.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

import '../utils/navigation.dart';

class NotificationHandler {
  static Future<void> handleNotification() async {
    await Permission.notification.request();

    // AwesomeNotifications().initialize(null, [

    //   NotificationChannel(
    //     channelKey: 'video_call_channel',
    //     channelName: 'Video Call Notifications',
    //     channelDescription: 'Notifications for active video calls',
    //     importance: NotificationImportance.High,
    //     defaultColor: AppColors.primaryColor,
    //     ledColor: Colors.white,
    //     channelShowBadge: true,
    //     locked: true,
    //   ),
    // ]);

    // await initPusher();
  }

  // static Future<void> initPusher() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final channelName = prefs.getString('notification_channel_name');
  //   final eventName = prefs.getString('notification_broadcast_name');
  //   final userId = prefs.getString('user_id');
  //
  //   if (channelName != null && eventName != null) {
  //     await pusher.init(
  //       apiKey: '3fb7db7c0df9ff9fcb09',
  //       cluster: 'ap2',
  //       onEvent: (event) async {
  //         // showLog('ParsedData event: $event');
  //         try {
  //           showLog(
  //               "on Message received == 1>${appCubit.state.unreadNotificationCount} channelName ${event.channelName} $channelName  eventName ${event.eventName}$eventName");
  //           showLog(
  //               "on Message received == --->${appCubit.state.unreadNotificationCount} ${appCubit.state.currentConversationId} ");
  //
  //           final parsedData = event.data is String
  //               ? jsonDecode(event.data)
  //               : event.data as Map<Object?, Object?>;
  //           appCubit.changeScheduleButtonState(
  //               parsedData["hide_appointment_button"]);
  //           showLog("parsedData==>$parsedData");
  //           if (event.channelName == channelName &&
  //               event.eventName == eventName) {
  //             await appCubit.fetchNotifications(
  //                 isLoader: false, isLoadMore: false);
  //             showLog(
  //                 "on Message received == 2>${appCubit.state.unreadNotificationCount}");
  //             await appCubit.updateUnreadNotificationCountValue(
  //                 appCubit.state.unreadNotificationCount + 1);
  //             showLog(
  //                 "on Message received == 2>${appCubit.state.unreadNotificationCount}");
  //             if (parsedData != null) {
  //               final message = parsedData['message'] ?? 'Default message';
  //               if (appCubit.state.isChatPage == false ||
  //                   (!event.eventName
  //                       .contains(chatCubit.state.currentConversationId!))) {
  //                 await AwesomeNotifications().createNotification(
  //                   content: NotificationContent(
  //                     id: 0,
  //                     channelKey: 'basic_channel',
  //                     title: message,
  //                     body: 'You have a new notification.',
  //                     notificationLayout: NotificationLayout.Default,
  //                   ),
  //                 );
  //               }
  //             } else {
  //               showLog('Failed to parse event data');
  //             }
  //           } else if (event.channelName == 'agora_call_channel' &&
  //               userId != null &&
  //               event.eventName.contains(userId) &&
  //               !(event.eventName.contains("reject_call_"))) {
  //             showLog("${!(event.eventName.contains("reject_call_"))}");
  //             log("on Message received == 3>${event.data}");
  //             final parsedData = event.data is String
  //                 ? jsonDecode(event.data)
  //                 : event.data as Map<Object?, Object?>;
  //             final type = parsedData['type'];
  //             final token = parsedData['token'];
  //             final channelName = parsedData['channel_name'];
  //             final firstName = parsedData['user_details']['first_name'];
  //             final receiverId = parsedData['user_details']['user_id'];
  //             final profilePicture =
  //                 parsedData['user_details']['profile_picture'];
  //             showMessage("out side call page=== navigation");
  //             showMessage(
  //                 "currentState context === ${navigatorKey.currentState?.context}");
  //             showMessage("currentState === ${navigatorKey.currentState}");
  //             await prefs.reload();
  //             final isCallFromBackground =
  //                 prefs.getBool("call_when_background") ?? false;
  //             log("FlutterCallkitIncoming--> $isCallFromBackground in side calling ${event.data}");
  //
  //             if (isCallFromBackground) return;
  //             //  prefs.setBool("call_when_background", false);
  //
  //             // final callStateManager = CallStateManager();
  //
  //             // if (!callStateManager.isCallActive) {
  //             //   callStateManager.setCallActive(true);
  //             showMessage("onCall $channelName $parsedData");
  //             showLog("onCall $channelName $parsedData");
  //             navigationPush(CallingPage(
  //               token: token,
  //               channelName: channelName,
  //               callType: type == '2' ? CallType.video : CallType.voice,
  //               name: firstName,
  //               image: profilePicture,
  //               receiverId: receiverId.toString(),
  //               from: "notification handler",
  //             ));
  //             // }
  //           } else if (event.channelName == 'chat_message' &&
  //               chatCubit.state.currentConversationId != null &&
  //               event.eventName
  //                   .contains(chatCubit.state.currentConversationId!)) {
  //             showMessage("parse data is ======= $parsedData");
  //             showLog(
  //                 "after cut the call on complete appointment========$event");
  //             showLog(
  //                 "on Message received == 4>${appCubit.state.unreadNotificationCount} ${chatCubit.state.currentConversationId} ");
  //             final messageData = parsedData['message'];
  //             showMessage(
  //                 "messageData['sender_id'] is user id$messageData  ${(messageData != null && userId != messageData['sender_id'].toString())} ${userId}=======${messageData['sender_id']}");
  //             // showMessage("messageData['sender_id'] is =======${messageData['sender_id'].runtimeType}");
  //             // showMessage("messageData['sender_id'] is =======${messageData}");
  //             // if (messageData != null && userId != parsedData['sender_id'].toString()) {
  //             if (messageData != null &&
  //                 userId != messageData['sender_id'].toString()) {
  //               final newMessage = MessageModel(
  //                   isRead: 0,
  //                   message: messageData['message'],
  //                   id: messageData['id'] is int
  //                       ? messageData['id']
  //                       : int.parse(messageData['id'].toString()),
  //                   senderId: messageData['sender_id'] is int
  //                       ? messageData['sender_id']
  //                       : int.parse(messageData['sender_id'].toString()),
  //                   updatedAt: DateTime.parse(messageData['updated_at']),
  //                   createdAt: DateTime.parse(messageData['created_at']),
  //                   type: MessageType.received,
  //                   mediaType: messageData['media_type'],
  //                   media: messageData['media'],
  //                   workplaceId: messageData['workplace_id'],
  //                   appointmentDate: messageData['appointment_date'],
  //                   appointmentTime: messageData['appointment_time'],
  //                   appointmentPurpose: messageData['appointment_purpose'],
  //                   appointmentId: messageData['appointment_id'],
  //                   isForAppointment: messageData['is_for_appointment'],
  //                   rescheduleButton: parsedData['reschedule_button'],
  //                   appointmentType: messageData['appointment_type'],
  //                   msgID: messageData['msg_id'],
  //                   hideCancelButton: messageData['hide_cancel_button']);
  //
  //               List<MessageModel> updatedMessages = <MessageModel>[
  //                 newMessage,
  //                 ...chatCubit.state.chatMessageResponse?.message ?? [],
  //               ];
  //               if (parsedData['previous_message_id'] != null) {
  //                 final previousMessageId = parsedData['previous_message_id']
  //                         is int
  //                     ? parsedData['previous_message_id']
  //                     : int.parse(parsedData['previous_message_id'].toString());
  //
  //                 // Update hideCancelButton in updatedMessages
  //                 updatedMessages = <MessageModel>[
  //                   newMessage,
  //                   ...chatCubit.state.chatMessageResponse?.message ?? [],
  //                 ].map((message) {
  //                   if (message.id == previousMessageId) {
  //                     message.hideCancelButton =
  //                         parsedData['hide_cancel_button'];
  //                     return message;
  //                   }
  //                   return message;
  //                 }).toList();
  //               }
  //               if (parsedData['appointment_id'] != null &&
  //                   parsedData['chat_message_id'] != null) {
  //                 final chatMessageId = parsedData['chat_message_id'] is int
  //                     ? parsedData['chat_message_id']
  //                     : int.parse(parsedData['chat_message_id'].toString());
  //
  //                 updatedMessages = updatedMessages.map((message) {
  //                   if (message.id == chatMessageId) {
  //                     message.appointmentId = parsedData['appointment_id']
  //                             is int
  //                         ? parsedData['appointment_id']
  //                         : int.parse(parsedData['appointment_id'].toString());
  //                   }
  //                   return message;
  //                 }).toList();
  //               }
  //
  //               // chatCubit.changeChatMessageResponse();
  //               // showMessage("updated msg list is ====== ${{updatedMessages[updatedMessages.length-2].hideCancelButton, updatedMessages[updatedMessages.length-2].msgID}}");
  //               // showMessage("updated msg list is ====== ${{updatedMessages[updatedMessages.length-1].hideCancelButton, updatedMessages[updatedMessages.length-1].msgID}}");
  //               chatCubit.changeChatMessageResponse(
  //                   value: chatCubit.state.chatMessageResponse
  //                       ?.copyWith(messages: updatedMessages));
  //
  //               // await AwesomeNotifications().createNotification(
  //               //   content: NotificationContent(
  //               //     id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
  //               //     channelKey: 'basic_channel',
  //               //     title: 'New Message',
  //               //     body: newMessage.message?.isEmpty == true ? null : newMessage.message,
  //               //     notificationLayout: NotificationLayout.Default,
  //               //     autoDismissible: true,
  //               //     actionType: ActionType.DismissAction,
  //               //   ),
  //               // );
  //             } else {
  //               showLog('Failed to parse message data');
  //             }
  //           } else if (event.channelName == "agora_call_channel" &&
  //               event.eventName == 'reject_call_$userId') {
  //             showLog(
  //                 "reject call is called ${navigatorKey.currentState?.canPop()}");
  //             // Close the calling screen
  //             if ((navigatorKey.currentState?.canPop() ?? false)) {
  //               navigatorKey.currentState?.pop();
  //             }
  //           }
  //           if (event.channelName == 'chat_message' &&
  //               event.eventName.contains("reject_call_")) {
  //             if (navigatorKey.currentState != null) {
  //               final int role = prefs.getInt('role') ?? 0;
  //               showLog(
  //                   "after cut the call on complete appointment========$role ${role == 1} $event");
  //               if (role == 1) {
  //                 Future.delayed(
  //                   Duration(
  //                     seconds: 2,
  //                   ),
  //                   () async {
  //                     await appCubit.fetchPastAppointments(
  //                         context: navigatorKey.currentState!.context,
  //                         isLoadMore: false,
  //                         changeIndex: false);
  //                     if ((appCubit.state.pastAppointmentResponse?.list ?? [])
  //                         .isNotEmpty) {
  //                       showLog(
  //                           "confirm Appoinment  ${appCubit.state.pastAppointmentResponse!.list.first}");
  //                       Appointment appointment =
  //                           appCubit.state.pastAppointmentResponse!.list.first;
  //                       showLog("confirm Appoinment  ${appointment.patientId}");
  //                       CustomAlertDialog(
  //                           context: navigatorKey.currentState!.context,
  //                           icon: Assets.icon.svg.tickOutline,
  //                           title: "Complite Appointment",
  //                           description:
  //                               "Are you want to complite this Appointment ${appointment.name}",
  //                           buttonText: NameData.complete,
  //                           onPressed: () {
  //                             appCubit.confrimAppointment(
  //                                 context: navigatorKey.currentState!.context,
  //                                 appointmentId: appointment.id.toString(),
  //                                 onSuccess: () async {},
  //                                 patientId: appointment.patientId!.toString());
  //                           });
  //                     }
  //                   },
  //                 );
  //               }
  //             }
  //           }
  //           if ((appCubit.state.currentConversationId ?? "").isEmpty &&
  //               event.channelName == 'chat_message' &&
  //               event.eventName.contains('conversation_')) {
  //             await appCubit.fetchHomePageChatList(
  //                 context: navigatorKey.currentContext,
  //                 isLoadMore: false,
  //                 isShowLoader: false);
  //           }
  //           showLog("-----------event ------ ${event.toString()}");
  //         } catch (e, st) {
  //           showLog("Error: notification_handler-- event ------ $e ,$st");
  //         }
  //       },
  //       onConnectionStateChange: (state1, state2) {
  //         showLog('Connection state: $state1\n\n$state2');
  //       },
  //       onError: (error, value, dynamic) {
  //         showLog('Pusher Error: $error\n\n$value\n\n$dynamic');
  //       },
  //     );
  //     await pusher.connect();
  //     await pusher.subscribe(channelName: channelName);
  //     await pusher.subscribe(channelName: 'agora_call_channel');
  //     await pusher.subscribe(channelName: 'chat_message');
  //   }
  // }
  //
  // static Future<void> disconnectPusher() async {
  //   await pusher.disconnect();
  // }
}

// class CallStateManager {
//   static final CallStateManager _instance = CallStateManager._internal();
//   factory CallStateManager() => _instance;
//   CallStateManager._internal();

//   bool isCallActive = false; // Tracks if a call is already active
//   bool isCallScreenVisible = false; // Tracks if the call screen is visible

//   void setCallActive(bool isActive) {
//     isCallActive = isActive;
//   }

//   void setCallScreenVisible(bool isVisible) {
//     isCallScreenVisible = isVisible;
//   }
// }

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  StreamSubscription<Map<dynamic, dynamic>>? _notificationSubscription;

  Future<void> initialize({
    required UserData? user,
    required HomeCubit homeCubit,
    required ChatCubit chatCubit,
    required SocketService socketService,
  }) async {
    // Cancel any existing subscription

    dispose();
    user ??= await homeCubit.dbHelper.getLoginData();
    _notificationSubscription =
        FireBaseNotification.selectNotificationSubject.stream
            .distinct() // Only emit when the value changes
            .listen(
      (event) async {
        log("_handleCallKit called==>$event ==>${DateTime.now}");
        debugPrint("_handleCallKit-->${event['type']} ${DateTime.now}");
        if (event == null) return;
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

  void dispose() {
    _notificationSubscription?.cancel();
    _notificationSubscription = null;
  }
}
