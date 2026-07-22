import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
    } else {
      // Every other data-only push (chat message, reaction, group/channel
      // event, etc.) — mirrors the non-call branch of
      // _showForegroundNotification, minus the "chat already open"
      // suppression check, which reads app-UI state (chatCubit) that
      // doesn't exist in this background isolate and would crash on
      // first access. Without this branch, any such push arriving while
      // the app is backgrounded or killed was previously dropped silently.
      final fcm = FireBaseNotification();
      await fcm._ensureLocalNotificationsInitialized();
      final parsedData =
          _decodeSenderField(Map<String, dynamic>.from(message.data));
      await fcm._showLocalNotification(message, parsedData);
    }
  } catch (e, st) {
    showMessage("error==> $e, $st");
    FirebaseCrashlytics.instance.recordError(e, st);
  }
}

// Decodes the 'sender' field (and nested data.sender) from their raw
// FCM-transported JSON-string form into a Map. Mutates and returns the
// same map. Shared by the foreground, background, and notification-tap
// handling paths so the three don't drift out of sync with each other.
Map<String, dynamic> _decodeSenderField(Map<String, dynamic> parsedData) {
  if (parsedData["sender"] is String &&
      (parsedData["sender"] as String).isNotEmpty) {
    parsedData["sender"] = json.decode(parsedData["sender"]);
  }
  if (parsedData["data"] is Map &&
      parsedData["data"]["sender"] is String &&
      (parsedData["data"]["sender"] as String).isNotEmpty) {
    parsedData["data"]["sender"] = json.decode(parsedData["data"]["sender"]);
  }
  return parsedData;
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
        await firebaseMessaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
        // Wait for APNS token — iOS requires it before FCM can generate a token
        String? apnsToken;
        for (int i = 0; i < 10; i++) {
          apnsToken = await firebaseMessaging.getAPNSToken();
          if (apnsToken != null) break;
          await Future.delayed(const Duration(seconds: 1));
        }
        showMessage('APNS Token: $apnsToken');
      }

      final token = await firebaseMessaging.getToken();
      if (token != null && token.isNotEmpty) {
        await AppPreference.setString(LocalDbConstants.firebaseToken, token);
        showMessage('FCM TOKEN to be Registered: $token');

        // Send token to backend immediately if user is logged in
        final userId = AppPreference.getCurrentUserId();
        if (userId.isNotEmpty) {
          updateFcmToken(apiClient, {
            "userId": userId,
            "deviceToken": token,
            "deviceType": Platform.isAndroid ? 'Android' : 'ios',
          });
        }
      } else {
        showMessage('FCM TOKEN is null — APNS may not be configured');
      }
    } catch (e, st) {
      showMessage('Error :::: FCM TOKEN $e St ::: $st');
      FirebaseCrashlytics.instance.recordError(e, st);
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

    // NOTE: onBackgroundMessage is registered early in main(), before this
    // setup runs, so the handler is wired up even if this async setup is
    // still in flight (e.g. waiting on the iOS permission dialog) when the
    // app gets backgrounded.

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
        if (initialMessage.data.isNotEmpty) {
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
        if (message.data.isNotEmpty) {
          // if (Platform.isAndroid) {
          await _showForegroundNotification(message);
        }
        // }
      } catch (e, st) {
        showMessage('Error =>FirebaseMessaging onMessage $e ==$st');
        FirebaseCrashlytics.instance.recordError(e, st);
      }
    });

    // Fired  when a user onTap a notification message displayed via FCM
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      showMessage('Got a message, app is in the foreground! ${message.data}');
      try {
        if (message.data.isNotEmpty) {
          _handleMessageClick(message, "background_click");
        }
      } catch (e, st) {
        showMessage("Error == $e, $st");
        FirebaseCrashlytics.instance.recordError(e, st);
      }
    });

    showMessage('FireBaseNotification firebaseCloudMessagingLSetup END');
  }

  Future<String> getToken() async {
    if (Platform.isIOS) {
      String? apns = await firebaseMessaging.getAPNSToken();
      if (apns == null) {
        for (int i = 0; i < 5; i++) {
          await Future.delayed(const Duration(seconds: 1));
          apns = await firebaseMessaging.getAPNSToken();
          if (apns != null) break;
        }
      }
    }
    String token = await firebaseMessaging.getToken() ?? "";
    await AppPreference.setString(LocalDbConstants.firebaseToken, token);
    log('TOKEN to be Registered: $token');

    return token;
  }

  // Covers both iOS authorization status and Android 13+'s runtime
  // POST_NOTIFICATIONS permission.
  Future<bool> isNotificationPermissionGranted() async {
    final settings = await firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<void> setUpLocalNotification() async {
    // Do NOT request iOS notification permission here. FirebaseMessaging.
    // requestPermission() (called from firebaseCloudMessagingLSetup above)
    // must be the only thing that requests iOS notification authorization —
    // see the warning comment in notification_handler.dart. A second,
    // independent requestPermissions() call from this plugin previously
    // raced with it and left the APNs token permanently unset.
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    await _ensureLocalNotificationsInitialized();
  }

  bool _localNotificationsInitialized = false;

  // Initializes the local-notifications plugin without requesting any
  // permission. Safe to call from a background isolate (a fresh FireBase
  // Notification singleton there has never had this run), where requesting
  // permission is neither possible nor necessary — permission is already
  // granted via the foreground/main-isolate flow above by the time any
  // notification needs to be shown.
  Future<void> _ensureLocalNotificationsInitialized() async {
    if (_localNotificationsInitialized) return;

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
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse payload) {
        /// working on this notification function
        showMessage('onDidReceiveNotificationResponse :: $payload');
        try {
          final playLoadData = (payload.payload?.isNotEmpty ?? false)
              ? (jsonDecode(payload.payload ?? ""))
              : {};
          showMessage(
              "onDidReceiveNotificationResponse playLoadData $playLoadData");
          if (playLoadData.isNotEmpty) {
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
    _localNotificationsInitialized = true;
  }

  void cancelAllLocalNotification() {
    flutterLocalNotificationsPlugin.cancelAll();
  }

  static const int _fcmRegistrationMaxAttempts = 3;

  // Single, consolidated entry point for registering/refreshing the FCM
  // token with the backend. Retries a bounded number of times with a short
  // backoff; if every attempt fails, marks the registration as pending so
  // ConnectivityCubit's reconnect listener (wired in main.dart) can retry it
  // later instead of the registration silently never happening.
  Future<void> updateFcmToken(
      ApiClient apiClient, Map<String, dynamic> data) async {
    for (int attempt = 1; attempt <= _fcmRegistrationMaxAttempts; attempt++) {
      try {
        CommonResponseModel? response = await apiClient.updateFcmToken(data);
        if (response?.status == Utils.APISUCCESS) {
          await AppPreference.setString(
              LocalDbConstants.firebaseToken, data["deviceToken"]);
          await AppPreference.setBoolean(
              LocalDbConstants.fcmRegistrationPending,
              value: false);
          return;
        }
        debugPrint(
            "updateFcmToken attempt $attempt did not succeed: ${response?.status}");
      } catch (e, st) {
        debugPrint("Error ==>$e  $st (attempt $attempt)");
        FirebaseCrashlytics.instance.recordError(e, st);
      }
      if (attempt < _fcmRegistrationMaxAttempts) {
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    await AppPreference.setBoolean(LocalDbConstants.fcmRegistrationPending,
        value: true);
  }

  // Called from ConnectivityCubit's "back online" listener. Re-attempts a
  // previously failed token registration rather than waiting for the user
  // to next fully restart the app.
  Future<void> retryPendingFcmRegistration(ApiClient apiClient) async {
    if (!AppPreference.getBoolean(LocalDbConstants.fcmRegistrationPending)) {
      return;
    }
    final userId = AppPreference.getCurrentUserId();
    final token = AppPreference.getFCMToken();
    if (userId.isEmpty || token.isEmpty) return;
    await updateFcmToken(apiClient, {
      "userId": userId,
      "deviceToken": token,
      "deviceType": Platform.isAndroid ? 'Android' : 'ios',
    });
  }

  void cancelLocalNotification(int id) {
    flutterLocalNotificationsPlugin.cancel(id: id);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    try {
      showMessage("in side show notification ==========");

      Map<String, dynamic> parsedData = _decodeSenderField(message.data);
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
          await _showLocalNotification(message, parsedData);
        }
      } else if (parsedData["type"] != "agora_call_invitation") {
        await _showLocalNotification(message, parsedData);
      }
    } catch (e, st) {
      debugPrint('Error showing notification: $e $st');
      FirebaseCrashlytics.instance.recordError(e, st);
    }
  }

  Future<void> _showLocalNotification(
      RemoteMessage message, Map<String, dynamic> payloadData) async {
    RemoteNotification? notification = message.notification;
    final title = notification?.title ?? payloadData["title"] ?? "The 212";
    final body = notification?.body ??
        payloadData["body"] ??
        payloadData["content"] ??
        "";
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
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: title,
        body: body,
        notificationDetails: platformChannelSpecifics,
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
      id: 1, // Notification ID
      title: 'Call is Active',
      body: 'Your video call is still active.',
      notificationDetails: platformChannelSpecifics,
    );
  }

  Future<void> _handleMessageClick(RemoteMessage message, String type) async {
    Map<String, dynamic> parsedData = _decodeSenderField(message.data);
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
