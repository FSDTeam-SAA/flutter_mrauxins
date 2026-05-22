import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:two_one_two_messenger/database/local_db.dart';
import 'package:two_one_two_messenger/models/common_res.dart';
import 'package:two_one_two_messenger/screens/groupCall.dart';
import 'package:two_one_two_messenger/screens/voice_call_page.dart';
import 'package:two_one_two_messenger/services/api_client.dart';
import 'package:two_one_two_messenger/services/calllit_handler.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

import '../extension/bloc.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    showMessage("back ground shoe data is === ${message.toMap().toString()}");
    if (message.data['type'] == 'agora_call_invitation') {
      debugPrint("back ground shoe data is data=== ${message.data}");
      await CallKitEventHandler.handleIncomingCall(message);
    } else if (message.data['type'] == 'agora_end_call') {
      debugPrint("agora_end_call=== ${message.data}");
      await FlutterCallkitIncoming.endAllCalls();
    }
//   else if(message.data['type'] == 'chat'&&(message.notification?.body == 'missed voice call'||message.notification?.body == 'missed video call')){
// await FlutterCallkitIncoming.endAllCalls();
//   }
    else if (message.data["sub_type"] != null) {}
  } catch (e, st) {
    showMessage("error==> $e, $st");
  }
}

class FireBaseNotification {
  static final FireBaseNotification _fireBaseNotification =
      FireBaseNotification.init();
  static final BehaviorSubject<Map<dynamic, dynamic>>
      selectNotificationSubject = BehaviorSubject<Map<dynamic, dynamic>>();

  factory FireBaseNotification() {
    return _fireBaseNotification;
  }

  FireBaseNotification.init();

  late FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  StreamController<ReceivedNotification>
      get didReceiveLocalNotificationStream =>
          StreamController<ReceivedNotification>.broadcast();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void firebaseCloudMessagingLSetup(ApiClient apiClient) async {
    try {
      showMessage('FireBaseNotification firebaseCloudMessagingLSetup START');
      if (Platform.isIOS) {
        await firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      await firebaseMessaging.getToken().then((token) async {
        await AppPreference.setString(
            LocalDbConstants.firebaseToken, token ?? "");

        showMessage('FCM TOKEN to be Registered: $token');
      });
    } catch (e, st) {
      showMessage('Error :::: FCM TOKEN $e St ::: $st');
    }

    firebaseMessaging.onTokenRefresh.listen(
      (newToken) {
        if (AppPreference.getCurrentUserId().isNotEmpty) {
          updateFcmToken(apiClient, {
            "userId": AppPreference.getCurrentUserId(),
            "deviceToken": newToken,
            "deviceType": Platform.isAndroid ? 'Android' : 'ios',
          });
        }
      },
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Get any messages which caused the application to open from a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    // If the message also contains a data property with a "type" of "chat",

    showMessage(
        'FireBaseNotification initialMessage data: ${initialMessage?.data}');
    if (initialMessage != null) {
      showMessage(
          'FireBaseNotification initialMessage data: ${initialMessage.data}');
      try {
        if (initialMessage.data != {}) {
          if (Platform.isIOS) {
            await Future.delayed(Durations.long1);
          }
          _handleMessageClick(initialMessage, "terminated_click");
        }
      } catch (e, st) {
        showMessage("Error :: $e --- $st");
      }
    }

    // Fired when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      showMessage('FireBaseNotification onMessage data: ${message.data}');
      log('FireBaseNotification onMessage data: ${message.data}');
      // debugPrint('FirebaseMessaging onMessage ${message.toMap()}');
      // if (message.data != {}) {
      //   PayloadData notificationPayload =
      //       PayloadData.fromJson(jsonDecode(message.data['payloadData']));
      //   onTapNotification(notificationPayload);
      // }
      try {
        if (message.data != {}) {
          // if (Platform.isAndroid) {
          await _showForegroundNotification(message);
        }
        // }
      } catch (e, st) {
        showMessage('Error =>FirebaseMessaging onMessage $e ==$st');
      }
    });

    // Fired  when a user onTap a notification message displayed via FCM
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      showMessage('Got a message, app is in the foreground! ${message.data}');
      try {
        if (message.data != {}) {
          _handleMessageClick(message, "background_click");
        }
      } catch (e, st) {
        showMessage("Error == $e, $st");
      }
    });

    showMessage('FireBaseNotification firebaseCloudMessagingLSetup END');
  }

  Future<String> getToken() async {
    String token = await firebaseMessaging.getToken() ?? "";
    await AppPreference.setString(LocalDbConstants.firebaseToken, token);
    log('TOKEN to be Registered: $token');

    return token;
  }

  Future<void> setUpLocalNotification() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');
    DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestBadgePermission: false,
      requestAlertPermission: false,

      // onDidReceiveLocalNotification:
      //     (int id, String? title, String? body, String? payload) async {
      //   didReceiveLocalNotificationStream.add(
      //     ReceivedNotification(
      //       id: id.toString(),
      //       title: title,
      //       body: body,
      //       payload: payload,
      //     ),
      //   );
      // },
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse payload) {
        /// working on this notification function
        showMessage('onDidReceiveNotificationResponse :: $payload');
        try {
          final playLoadData = (payload.payload?.isNotEmpty ?? false)
              ? (jsonDecode(payload.payload ?? ""))
              : {};
          showMessage(
              "onDidReceiveNotificationResponse playLoadData $playLoadData");
          if (playLoadData != {}) {
            if (playLoadData["type"] != "agora_call_invitation") {
              debugPrint(
                  "onDidReceiveNotificationResponse playLoadData Local notification $playLoadData");
              selectNotificationSubject.add(playLoadData);
              //  _handleMessageClick(message, "background_click");
            }
          }
        } catch (e, st) {
          showMessage("onDidReceiveNotificationResponse error $e || Stack $st");
        }
      },
    );
  }

  void cancelAllLocalNotification() {
    flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> updateFcmToken(
      ApiClient apiClient, Map<String, dynamic> data) async {
    try {
      CommonResponseModel? response = await apiClient.updateFcmToken(data);
      if (response?.status == Utils.APISUCCESS) {
        await AppPreference.setString(
            LocalDbConstants.firebaseToken, data["deviceToken"]);
      }
    } catch (e, st) {
      debugPrint("Error ==>$e  $st");
    }
  }

  void cancelLocalNotification(int id) {
    flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    try {
      showMessage("in side show notification ==========");

      Map<String, dynamic> parsedData = message.data;
      if (parsedData.containsKey("sender") &&
          parsedData["sender"] is String &&
          parsedData["sender"].isNotEmpty) {
        parsedData["sender"] = json.decode(parsedData["sender"]);
      }

      // Fix 'sender' field, as it's a string containing JSON
      if (parsedData["data"] != null &&
          parsedData["data"]["sender"] is String) {
        parsedData["data"]["sender"] =
            json.decode(parsedData["data"]["sender"]);
      }
      final String encodedMessage = json.encode({
        'messageId': message.messageId,
        'data': parsedData,
        'timestamp': DateTime.now().toIso8601String(),
      });
      showMessage("in side show notification parseData ==========$parsedData");
      showMessage(
          "in side show notification parseData ==========${parsedData["type"]}");
      showMessage("In Side show notification ==> $encodedMessage");
      // showMessage("in side show notification body is  ==========${appCubit.state.currentConversationId} ${message.data}");
      if (parsedData["type"] == "agora_call_invitation") {
        showMessage(":: OnReceiveCall $parsedData");
        CallType callType = CallType.values.firstWhere(
          (element) => element.name == parsedData["call_type"],
        );
        if (callType == CallType.video_group_call ||
            callType == CallType.voice_group_call) {
          NavigationService().navigateTo(GroupCallingPage(
            token: parsedData["token"],
            callId: parsedData["callId"],
            channelName: parsedData["channel_name"],
            callType: callType,
            name: parsedData["groupName"] ?? "",
            image: parsedData["groupImage"] ?? "",
            receiverId: parsedData["participantId"],
            from: "home screen backgraound",
            currentConversationId: parsedData["chat_id"],
          ));
        } else {
          NavigationService().navigateTo(CallingPage(
            token: parsedData["token"],
            channelName: parsedData["channel_name"],
            callType: callType,
            name: parsedData["sender"]["name"],
            image: parsedData["sender"]["profilePicture"] ?? "",
            receiverId: parsedData["participantId"],
            from: "notification handler",
            callId: parsedData["callId"],
            currentConversationId: parsedData["chat_id"],
          ));
        }
        FlutterCallkitIncoming.endAllCalls();
        return;
      }
      if (parsedData["type"] == "agora_end_call") {
        FlutterCallkitIncoming.endAllCalls();
        return;
      }
      if (parsedData["type"] == "chat_message") {
        if (chatCubit.isChatPage == false ||
            chatCubit.chatId != message.data['chat_id']) {
          _showLocalNotification(message, parsedData);
        }
      } else if (parsedData["type"] != "agora_call_invitation") {
        _showLocalNotification(message, parsedData);
      }
    } catch (e, st) {
      debugPrint('Error showing notification: $e $st');
    }
  }

  void _showLocalNotification(
      RemoteMessage message, Map<String, dynamic> payloadData) async {
    RemoteNotification? notification = message.notification;
    showMessage(
        'LocalNotification showNotification Offline payload==> ${message.data}');
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'high_importance_channel', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            // ongoing: true,

            styleInformation: BigTextStyleInformation('',
                // htmlFormatTitle: true,
                htmlFormatContentTitle: true),
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(
        presentSound: true,
        presentBadge: true,
        presentAlert: true,
        presentBanner: true,
        presentList: true,
      ),
    );
    await flutterLocalNotificationsPlugin.show(
        0, notification!.title, notification.body, platformChannelSpecifics,
        payload: jsonEncode(payloadData));
  }

  Future<void> showLocalCallNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'video_call_channel', // Channel ID
      'Video Call Notifications', // Channel Name
      channelDescription: 'Notifications for active video calls',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true, // Ensures notification is NOT dismissible
      autoCancel: false, // Prevents auto-dismiss
    );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      1, // Notification ID
      'Call is Active', // Title
      'Your video call is still active.', // Body
      platformChannelSpecifics,
    );
  }

  Future<void> _handleMessageClick(RemoteMessage message, String type) async {
    Map<String, dynamic> parsedData = message.data;
    if (parsedData.containsKey("sender") && parsedData["sender"] is String) {
      parsedData["sender"] = json.decode(parsedData["sender"]);
    }

    // Fix 'sender' field, as it's a string containing JSON
    if (parsedData["data"] != null &&
        parsedData["data"]["sender"] is String &&
        parsedData["data"]["sender"].isNotEmpty) {
      parsedData["data"]["sender"] = json.decode(parsedData["data"]["sender"]);
    }
    final String encodedMessage = json.encode({
      'messageId': message.messageId,
      'data': parsedData,
      'type': type,
      'timestamp': DateTime.now().toIso8601String(),
    });

    showMessage("encodedMessage ==> $encodedMessage");

    // Add the encoded message to the stream
    // _messageClickController.add(encodedMessage);
    showMessage("message.data is ====== ${message.data}");
    showMessage("message.data.type is ====== ${message.data['type']}");
    showMessage("Type is ====== $type");

    if (parsedData["type"] != "agora_call_invitation") {
      selectNotificationSubject.add(parsedData);
    } else if (Platform.isIOS &&
        parsedData["type"] == "agora_call_invitation") {
      parsedData["isActive"] = false;
      selectNotificationSubject.add(parsedData);
    }

    // Extract the data and handle navigation
    // if (parsedData.containsKey('type')) {
    //   if (parsedData['type'] == "chat_message") {
    //   NavigationService().popUntil();
    //     await Future.delayed(Durations.long1);

    //     NavigationService().navigateTo(ChatScreen(unreadMessageCount: 0,
    //       userName: parsedData["sender"]["userName"],
    //       userId: parsedData["sender"]["_id"],
    //       userPic: parsedData["sender"]["profilePicture"]??"",
    //       chatId: message.data["chat_id"],
    //     ));
    //   }

    //   showMessage("msg click ==== ${message.data}");

    // } else {
    //   debugPrint("No route specified in the message data.");
    // }
  }

  // void onTapNotification(PayloadData payloadData) {
  //   ApiLog.addLog(
  //       'Notification onTapNotification payloadData: ${payloadData.toJson()}');
  //   showMessage(
  //       'Notification onTapNotification payloadData: ${payloadData.toJson()}');
  //   if (payloadData.redirect?.isNotEmpty ?? false) {
  //     selectNotificationSubject.add(payloadData);
  //   }
  // }
}

class ReceivedNotification {
  String? id;
  String? title;
  String? body;
  String? payload;
  String? groupKey;

  ReceivedNotification(
      {this.id, this.title, this.body, this.payload, this.groupKey});
}

class NotificationDebouncer {
  static final Map<String, DateTime> _lastProcessedNotifications = {};
  static const Duration debounceDuration = Duration(seconds: 2);

  static bool shouldProcess(String notificationId) {
    final now = DateTime.now();
    final lastProcessed = _lastProcessedNotifications[notificationId];

    if (lastProcessed == null ||
        now.difference(lastProcessed) > debounceDuration) {
      _lastProcessedNotifications[notificationId] = now;
      return true;
    }
    return false;
  }

  static String generateNotificationId(Map<dynamic, dynamic> event) {
    // Create a unique ID based on the notification content
    return '${event['chat_id']}_${event['temp_message_id'] ?? event['timestamp']}';
  }
}
