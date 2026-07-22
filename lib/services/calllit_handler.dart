import 'dart:convert';
import 'dart:developer';

// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:two_one_two_messenger/database/local_db.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/services/push_notifications.dart';
import 'package:two_one_two_messenger/services/socket_service.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

@pragma('vm:entry-point')
class CallKitEventHandler {
  static Future<void> handleIncomingCall(RemoteMessage message) async {
    Map<String, dynamic> parsedData = message.data;
    if (parsedData.containsKey("sender") &&
        parsedData["sender"] is String &&
        parsedData["sender"].isNotEmpty) {
      parsedData["sender"] = json.decode(parsedData["sender"]);
    }

    // Fix 'sender' field, as it's a string containing JSON
    if (parsedData["sender"] is String) {
      parsedData["sender"] = json.decode(parsedData["sender"]);
    }
    showMessage("handleIncomingCall==>parsedData ${jsonEncode(parsedData)}");
    CallKitParams callKitParams = CallKitParams(
      avatar: parsedData["sender"]["profilePicture"],
      appName: AppConstants.appName,
      duration: 30000,
      extra: parsedData,
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: 0,
      nameCaller: (parsedData["call_type"] == CallType.video_group_call.name ||
              parsedData["call_type"] == CallType.voice_group_call.name)
          ? "Group Call '${parsedData["groupName"]}'"
          : parsedData["sender"]["name"],
      android: const AndroidParams(
          isCustomNotification: true,
          isShowLogo: false,
          isShowFullLockedScreen: true,
          ringtonePath: 'system_ringtone_default',
          backgroundColor: '#2c255f',
          // backgroundUrl: 'https://i.pravatar.cc/500',
          actionColor: '#3E5EFE',
          textColor: '#ffffff',
          incomingCallNotificationChannelName: "Incoming Call",
          missedCallNotificationChannelName: "Missed Call",
          textAccept: "Accept",
          textDecline: "Reject",
          isShowCallID: false),
      ios: IOSParams(
        // iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );
    // AwesomeNotifications().cancelAll();
    FireBaseNotification().cancelAllLocalNotification();
    await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
    CallKitEventHandler.initializebackGround();
  }

  static void initialize() {
    // FlutterCallkitIncoming. requestFullIntentPermission();
    FlutterCallkitIncoming.onEvent.listen((event) {
      if (event == null) return;
      log("FlutterCallkitIncoming listener == ${event.toString()}");
      switch (event) {
        case CallEventActionCallAccept(:final callKitParams):
          onCallAccepted(callKitParams);
        case CallEventActionCallDecline(:final callKitParams):
          onCallDeclined(callKitParams);
        case CallEventActionCallEnded(:final callKitParams):
          onCallEnded(callKitParams);
        default:
          log('Unhandled event: ${event.eventName}');
      }
    });
  }

  static void initializebackGround() {
    // FlutterCallkitIncoming.requestFullIntentPermission();
    FlutterCallkitIncoming.onEvent.listen((event) {
      if (event == null) return;
      if (kDebugMode) {
        print("FlutterCallkitIncoming listener == ${event.toString()}");
      }
      switch (event) {
        case CallEventActionCallDecline(:final callKitParams):
          onCallDeclined(callKitParams);
        case CallEventActionCallEnded(:final callKitParams):
          onCallEnded(callKitParams);
        default:
          if (kDebugMode) {
            print('Unhandled event: ${event.eventName}');
          }
      }
    });
  }

  static void onCallAccepted(CallKitParams callKitParams) {
    // Navigate to custom call UI
    try {
      showMessage(
          "FlutterCallkitIncoming Call accepted: ${callKitParams.extra}");

      Map<dynamic, dynamic> data =
          Map<dynamic, dynamic>.from(callKitParams.extra ?? {});
      data["isActive"] = true;
      FireBaseNotification.selectNotificationSubject.add(data);
    } catch (e, st) {
      if (kDebugMode) {
        print("error ==>$e, $st");
      }
    }
  }

  static Future<void> onCallDeclined(CallKitParams callKitParams) async {
    try {
      UserData? currentuser = await DatabaseHelper().getLoginData();
      final userId = currentuser?.sId ?? "";

      showMessage("onCallDeclined${callKitParams.extra}");

      SocketService().connect();
      SocketService()
          .joinEvent(AppConstants.socketJoinChat, {"userId": userId});
      SocketService().emitEndCall({
        "user_id": userId,
        "duration": 0,
        "chat_id": callKitParams.extra?['chat_id'],
        "callId": callKitParams.extra?['callId']
      });

      await FlutterCallkitIncoming.endAllCalls();
    } catch (e, st) {
      showMessage("error === > $e ,$st");
    }
  }

  static Future<void> onCallEnded(CallKitParams callKitParams) async {
    showMessage("Call ended: ${callKitParams.extra}");
    await FlutterCallkitIncoming.endAllCalls();
    // Handle call end
  }

  static Future getActiveCall() async {
    final calldata = await FlutterCallkitIncoming.activeCalls();
    showMessage("get call data==>$calldata");
    if (calldata.isEmpty) return;
    Map<dynamic, dynamic> data =
        Map<dynamic, dynamic>.from(calldata[0].extra ?? {});
    data["isActive"] = true;
    FireBaseNotification.selectNotificationSubject.add(data);
    FlutterCallkitIncoming.endAllCalls();
  }
}
