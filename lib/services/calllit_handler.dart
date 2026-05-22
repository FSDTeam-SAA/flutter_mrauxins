import 'dart:convert';
import 'dart:developer';
// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:rxdart/rxdart.dart';
import 'package:two_one_two_messenger/database/local_db.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
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
    if (parsedData != null && parsedData["sender"] is String) {
      parsedData["sender"] = json.decode(parsedData["sender"]);
    }
    showMessage("handleIncomingCall==>parsedData ${jsonEncode(parsedData)}");
    CallKitParams callKitParams = CallKitParams(
      avatar: parsedData["sender"]["profilePicture"],
      appName: AppConstants.appName,
      duration: 30000,
      extra: parsedData,
      id: message.messageId,
      type: 0,
      textDecline: "Reject",
      textAccept: "Accept",
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
      log("FlutterCallkitIncoming listener == ${event.event.toString()}");
      showMessage(
          "FlutterCallkitIncoming listener name == ${event.body.toString()}");
// onCallAccepted(event.body);
      switch (event.event.name.split(".").last) {
        case 'ACTION_CALL_ACCEPT':
          onCallAccepted(event.body);
          break;

        case 'ACTION_CALL_DECLINE':
          onCallDeclined(event.body);
          break;
        case 'ACTION_CALL_ENDED':
          onCallEnded(event.body);
          break;
        default:
          log('Unhandled event: ${event.event.name}');
          break;
      }
    });
  }

  static void initializebackGround() {
    // FlutterCallkitIncoming.requestFullIntentPermission();
    FlutterCallkitIncoming.onEvent.listen((event) {
      if (event == null) return;
      print("FlutterCallkitIncoming listener == ${event.toString()}");
      log("FlutterCallkitIncoming listener == ${event.event.toString()}");
      showMessage(
          "FlutterCallkitIncoming listener name == ${event.body.toString()}");
// onCallAccepted(event.body);
      switch (event.event.name.split(".").last) {
        case 'ACTION_CALL_DECLINE':
          onCallDeclined(event.body);
          break;
        case 'ACTION_CALL_ENDED':
          onCallEnded(event.body);
          break;
        default:
          print('Unhandled event: ${event.event.name}');
          break;
      }
    });
  }

  static void onCallAccepted(Map<dynamic, dynamic> body) {
    // Navigate to custom call UI
    try {
      showMessage("FlutterCallkitIncoming Call accepted: ${body["extra"]}");
      // showMessage(
      //     "FlutterCallkitIncoming Call user_pic: ${body['extra']['agora_token']}");

      // Map<String, dynamic> data = body["extra"];
      Map<dynamic, dynamic> data = body["extra"];
      data["isActive"] = true;
      FireBaseNotification.selectNotificationSubject.add(data);
      // FireBaseNotification.selectNotificationSubject.add(body["extra"]);
    } catch (e, st) {
      showMessage("error ==>$e, $st");
    }
  }

  static Future<void> onCallDeclined(Map<dynamic, dynamic> body) async {
    // log("Call declined: $body");
    try {
      UserData? currentuser = await DatabaseHelper().getLoginData();
      final userId = currentuser?.sId ?? "";

      showMessage("onCallDeclined${body}");

      SocketService().connect();
      SocketService()
          .joinEvent(AppConstants.socketJoinChat, {"userId": userId});
      SocketService().emitEndCall({
        "user_id": userId,
        "duration": 0,
        "chat_id": body['extra']['chat_id'],
        "callId": body['extra']['callId']
      });

      await FlutterCallkitIncoming.endAllCalls();
      // log("Call declined: $body");
    } catch (e, st) {
      showMessage("error === > $e ,$st");
    }
  }

  static Future<void> onCallEnded(Map<dynamic, dynamic> body) async {
    showMessage("Call ended: $body");
    await FlutterCallkitIncoming.endAllCalls();
    // Handle call end
  }

  static Future getActiveCall() async {
    final calldata = await FlutterCallkitIncoming.activeCalls();
    showMessage("get call data==>$calldata");
    if (calldata == null || (calldata as List).isEmpty) return;
    Map<dynamic, dynamic> data = calldata[0]["extra"];
    data["isActive"] = true;
    FireBaseNotification.selectNotificationSubject.add(data);
    FlutterCallkitIncoming.endAllCalls();
    // showMessage("get call data==>${calldata[0]["extra"]}");
  }
}
