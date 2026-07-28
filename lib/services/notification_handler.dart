// import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:two_one_two_messenger/cubit/chat_cubit.dart';
import 'package:two_one_two_messenger/cubit/home_cubit.dart';
import 'package:two_one_two_messenger/models/conversation_model.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/screens/channel_info.dart';
import 'package:two_one_two_messenger/screens/chat_screen.dart';
import 'package:two_one_two_messenger/screens/groupCall.dart';
import 'package:two_one_two_messenger/screens/group_info.dart';
import 'package:two_one_two_messenger/screens/voice_call_page.dart';
import 'package:two_one_two_messenger/main.dart';
import 'package:two_one_two_messenger/services/push_notifications.dart';
import 'package:two_one_two_messenger/services/socket_service.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

import '../utils/navigation.dart';

class NotificationHandler {
  static Future<void> handleNotification() async {}
}

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
                restrictContentSharing:
                    event["groupInfo"]["restrictContentSharing"] ?? false,
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
          } else if (event["type"] == "update_available") {
            final url = event["url"];
            if (url is String && url.isNotEmpty) {
              Utils.launchUrlHelper(url, navigatorKey.currentState!.context);
            }
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
