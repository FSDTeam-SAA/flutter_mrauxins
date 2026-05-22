import 'dart:async';
import 'dart:convert';
import 'dart:developer' as debugPrints;
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:two_one_two_messenger/cubit/chat_cubit.dart';
import 'package:two_one_two_messenger/cubit/chat_state.dart';
import 'package:two_one_two_messenger/database/local_db.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/models/token_and_channel.dart';
import 'package:two_one_two_messenger/services/push_notifications.dart';
import 'package:two_one_two_messenger/services/socket_service.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/toggle_beep_sound.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/avatar_widgets.dart';
import 'package:two_one_two_messenger/widgets/buttons.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';

class CallingPage extends StatefulWidget {
  const CallingPage({
    super.key,
    required this.name,
    required this.image,
    required this.callType,
    required this.from,
    this.callId,
    this.token,
    this.channelName,
    this.receiverId,
    this.isActive,
    required this.currentConversationId,
  });
  final String name;
  final String image;
  final String from;
  final CallType callType;
  final String? token;
  final String? channelName;
  final String? receiverId;
  final String? callId;
  final bool? isActive;
  final String currentConversationId;

  @override
  State<CallingPage> createState() => _CallingPageState();
}

class _CallingPageState extends State<CallingPage> with WidgetsBindingObserver {
  RtcEngine? _engine;
  int? remoteUid;
  int? _startTime;
  int? _remainingTime;
  String? _formattedTime;
  Timer? _timer;
  bool isAccepted = false;
  TokenAndChannel? tokenAndChannel;
  int? _streamId;
  bool isMute = false;
  bool isDisableVideo = false;
  bool remoteIsMuted = false;
  bool remoteIsDisableVideo = false;
  String callId = "";
  Timer? _callTimeoutTimer;
  // bool isVideoCall = false;
  AppLifecycleState? _previousLifecycleState;
  final SocketService _socketService = SocketService();
  @override
  void initState() {
    debugPrints.log(
        "in side init ==== from${widget.from}==>${widget.channelName} ${widget.token}");

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      chatCubit.changeCallType(callType: widget.callType);
      callId = widget.callId ?? "";
      onCallEnd();
      if (widget.callType == CallType.voice) {
        chatCubit.toggleSpeaker(false);
      } else {
        chatCubit.toggleSpeaker(true);
      }

      if (widget.token == null || widget.channelName == null) {
        _initializeCall();
      } else if (widget.isActive ?? false) {
        setState(() {
          isAccepted = true;
        });
        _initializeCall();
      } else {
        debugPrints.log("Call ring start =====");
        _startRinging();
      }
    });
    super.initState();
  }

  Future<void> onCallEnd() async {
    try {
      _socketService.onEndCall(
        (data) async {
          showMessage("onEndCall $data");
          UserData? currentUser = await chatCubit.dbHelper.getLoginData();
//         if(data["user_id"]==currentUser?.sId)
//  {
          await FlutterCallkitIncoming.endAllCalls();
          _endCall();
          NavigationService().popUntil();
          // }
        },
      );
    } catch (e, st) {
      showMessage("Error in end call $e $st");
    }
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        if (_previousLifecycleState != AppLifecycleState.inactive) {
          _removeCallNotification();
          handleLocalVideoStream(true);
        }
        break;
      case AppLifecycleState.inactive:
        showMessage("App is CallingPage inactive.");
// prefs.setBool("call_when_background", true);
        break;
      case AppLifecycleState.paused:
        showMessage("App is CallingPage  in the background (paused).");
        _previousLifecycleState = state;
        handleLocalVideoStream(false);
        _showCallNotification();
        break;
      case AppLifecycleState.detached:
        showMessage("App is  CallingPage detached.");
        _previousLifecycleState = state;
        handleLocalVideoStream(false);
        _endCall();
        break;
      case AppLifecycleState.hidden:
        showMessage("App is  CallingPage hidden.");
        _previousLifecycleState = state;
        handleLocalVideoStream(false);
    }
    // _previousLifecycleState = state;
  }

  Future<void> _showCallNotification() async {
    FireBaseNotification().showLocalCallNotification();

    // await AwesomeNotifications().createNotification(
    //   content: NotificationContent(
    //     id: 1,
    //     channelKey: 'video_call_channel',
    //     title: 'Call is Active',
    //     body: 'Your video call is still active.',
    //     notificationLayout: NotificationLayout.Default,
    //     autoDismissible: false,
    //     locked: true, // Ensures the notification can't be dismissed
    //   ),
    // );
  }

  Future<void> _removeCallNotification() async {
    FireBaseNotification().cancelLocalNotification(1);
  }

  void cancelCallTimeout() {
    _callTimeoutTimer?.cancel();
  }

  void startCallTimeout() {
    _callTimeoutTimer = Timer(Duration(seconds: 40), () async {
      await chatCubit.rejectCall(
        // context: context,
        chatId: widget.currentConversationId,
        duration: 0,
        callId: callId,
      );
      NavigationService().goBack();
    });
  }

  handleLocalVideoStream(bool isShow) {
    try {
      if (chatCubit.state.callType == CallType.video) {
        if (mounted && _engine != null) {
          showMessage("App is  CallingPage handleLocalVideoStream $isShow");
          setState(() {
            isDisableVideo = !isShow;
            _engine?.muteLocalVideoStream(!isShow);
          });
        }
      }
    } catch (e, st) {
      showMessage("Error App is  CallingPage handleLocalVideoStream $e,$st");
    }
  }

  Future<void> _initializeCall() async {
    try {
      await _initializeAgora();
      showMessage("_initializeIncomingCall ${widget.token}");
      if (widget.token != null) {
        debugPrints.log("_initializeIncomingCall");
        await _initializeIncomingCall();
      } else {
        await _initializeOutgoingCall();
        startCallTimeout();
      }
    } catch (e) {
      showMessage('Error initializing call: $e');
    }
  }

  Future<void> _initializeAgora() async {
    try {
      final appId = AppPreference.getAgoraAppId();
      // AppPreference.getAgoraAppId();
      showMessage("Agora App ID is $appId");
      if (appId == null || appId.isEmpty) {
        showMessage("Agora App ID is missing or invalid!");
        // throw Exception('Agora App ID is missing or invalid!');

        Navigator.pop(context);
        Utils.showSnackBar(
            context, "Something went wrong!, Sorry, Call is not connected");
        return;
      }

      await getCameraAndMicrophonePermission(context: context);

      _engine = createAgoraRtcEngine();
      await _engine?.initialize(RtcEngineContext(appId: appId));
      await _engine
          ?.setChannelProfile(ChannelProfileType.channelProfileCommunication);
      await _engine?.setAudioProfile(
          profile: AudioProfileType.audioProfileDefault,
          scenario: AudioScenarioType.audioScenarioGameStreaming);
      await _engine?.enableAudio();

      if (widget.callType == CallType.video) {
        await _engine?.enableVideo();
      } else {
        await _engine?.enableAudio();
      }

      await _createDataStream();

      _engine?.registerEventHandler(
        RtcEngineEventHandler(
          onConnectionLost: (connection) {
            showMessage(
                "connectionStateType channelId:: ${connection.channelId}");
            showMessage(
                "connectionStateType channelId:: ${connection.localUid}");
          },
          onRemoteAudioStats: (connection, stats) {
            showMessage(
                "onRemoteAudioStats channelId:: ${connection.channelId}");
            showMessage(
                "onRemoteAudioStats channelId:: ${connection.localUid}");
          },
          onRtcStats: (connection, stats) {
            showMessage("onRtcStats channelId:: ${connection.channelId}");
            showMessage("onRtcStats channelId:: ${stats.toJson()}");
          },
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            showMessage('onJoinChannelSuccess: $elapsed');
            showMessage('onJoinChannelSuccess: ${connection.channelId}');
          },
          onUserJoined: (connection, remoteId, _) {
            if (widget.token != null) {
              _stopRinging();
            }
            showMessage('onUserJoined: $connection');
            showMessage('onUserJoined: $remoteId');
            setState(() {
              remoteUid = remoteId;
              _startTime = DateTime.now().millisecondsSinceEpoch;
              _remainingTime = 0;
              _formattedTime = _formatTime(_remainingTime!);
              cancelCallTimeout();
              _startTimer();
            });
          },
          onUserOffline: (connection, reason, _) async {
            showMessage('onUserOffline: $connection');
            showMessage('onUserOffline: $reason');
            NavigationService().popUntil();
            // showToast('Call Disconnect');

            setState(() {
              remoteUid = null;
            });
          },
          onStreamMessage: (RtcConnection connection, int uid, int streamId,
              Uint8List data, int length, int sentTs) async {
            final message = String.fromCharCodes(data);
            showMessage('Received message: $message from user $uid');

            if (message == 'video') {
              await _engine?.setCameraCapturerConfiguration(
                const CameraCapturerConfiguration(
                  cameraDirection:
                      CameraDirection.cameraFront, // Force front camera
                ),
              );

              chatCubit.changeCallType(callType: CallType.video);
              _engine?.enableVideo();
              chatCubit.toggleSpeaker(true);
              _engine?.setEnableSpeakerphone(true);
            } else if (message == 'voice') {
              chatCubit.changeCallType(callType: CallType.voice);
              _engine?.disableVideo();
              chatCubit.toggleSpeaker(false);
              _engine?.setEnableSpeakerphone(false);
            }
          },
          onStreamMessageError: (RtcConnection connection, int uid,
              int streamId, ErrorCodeType error, int missed, int cached) {
            showMessage('Stream message error: $error');
          },
          onUserMuteAudio: (RtcConnection connection, int uid, bool muted) {
            showMessage('onUserMuted: $uid muted: $muted');
            if (uid == remoteUid) {
              setState(() {
                remoteIsMuted = muted;
              });
            }
          },
          onUserMuteVideo: (RtcConnection connection, int uid, bool muted) {
            showMessage('onUserMuted: $uid muted: $muted');
            if (uid == remoteUid) {
              setState(() {
                remoteIsDisableVideo = muted;
              });
            }
          },
          onError: (error, error2) {
            showMessage('onError: $error');
            showMessage('onError: $error2');
          },
          onLeaveChannel: (connection, stats) async {
            if (widget.token != null) {
              _stopRinging();
            }
            cancelCallTimeout();
            if (widget.token == null) {
              // Map<String, dynamic> data = {"duration":stats.duration};
              // String formatedData = json.encode(data);
              FlutterCallkitIncoming.endAllCalls();
              // if (widget.callType == CallType.video) {
              //   chatCubit.sendMessage(
              //       mediaType: _formattedTime != null ? 6 : 8,
              //       message: _formattedTime != null
              //           ? stats.duration.toString()
              //           : "missed video call");
              // } else {
              //   chatCubit.sendMessage(
              //       mediaType: _formattedTime != null ? 7 : 9,
              //       message: _formattedTime != null
              //           ? stats.duration.toString()
              //           : "missed voice call");
              // }
              await chatCubit.rejectCall(
                  // context: context,
                  callId: callId,
                  chatId: widget.currentConversationId,
                  duration: _startTime == null
                      ? 0
                      : ((DateTime.now().millisecondsSinceEpoch -
                              (_startTime ??
                                  DateTime.now().millisecondsSinceEpoch)) ~/
                          1000));
            }
          },
          onUserEnableVideo: (connection, remoteUid, enabled) {
            showMessage('onUserEnableVideo: ${connection.toJson()}');
            showMessage('onUserEnableVideo: $remoteUid');
            showMessage('onUserEnableVideo: $enabled');
            setState(() {
              // isVideoCall = enabled;
            });
          },
          onUserStateChanged: (connection, remoteUid, state) {
            showMessage('onUserStateChanged: ${state}');
          },
        ),
      );
    } catch (e, stacktrace) {
      showMessage('Error initializing Agora: $e');
      showMessage('Error initializing Agora stacktrace: $stacktrace');
      rethrow;
    }
  }

  Future<void> _initializeOutgoingCall() async {
    try {
      showMessage(
          "_initializeOutgoingCall==>type=${widget.callType.name} ChatId=${widget.currentConversationId}");
      tokenAndChannel = await chatCubit.generateTokenAndChannelName(
          context: context,
          data: {
            "type": widget.callType.name,
            "groupName": "",
            "groupImage": "",
          },
          chatId: widget.currentConversationId);
      showMessage("_initializeOutgoingCall==> ${tokenAndChannel?.toJson()}");
      if (tokenAndChannel?.token == null ||
          tokenAndChannel?.channelName == null) {
        Navigator.pop(context);
        return;
      }
      callId = tokenAndChannel?.callId ?? "";
      final localUid = Random().nextInt(100000);

      await _engine?.joinChannel(
        token: tokenAndChannel?.token ?? '',
        channelId: tokenAndChannel?.channelName ?? 'default_channel',
        uid: localUid,
        options: const ChannelMediaOptions(
            autoSubscribeAudio: true,
            publishMicrophoneTrack: true,
            autoSubscribeVideo: true,
            clientRoleType: ClientRoleType.clientRoleBroadcaster),
      );
    } catch (e) {
      showMessage('Error initializing outgoing call: $e');
    }
  }

  Future<void> _initializeIncomingCall() async {
    try {
      if (widget.token == null || widget.channelName == null) {
        showMessage('Invalid channel name or token for incoming call');
        return;
      }

      final localUid = Random().nextInt(100000);

      ConnectionStateType? connectionStateType =
          await _engine?.getConnectionState();
      showMessage(
          "connectionStateType :: ${connectionStateType?.name} token ${widget.token} channel Name ${widget.channelName}");
      showMessage(
          'connectionStateType :: ${connectionStateType?.name} token ${widget.token} channel Name ${widget.channelName}');
      await _engine?.joinChannel(
        token: widget.token ?? '',
        channelId: widget.channelName ?? '',
        uid: localUid,
        options: const ChannelMediaOptions(
            autoSubscribeAudio: true,
            publishMicrophoneTrack: true,
            autoSubscribeVideo: true,
            clientRoleType: ClientRoleType.clientRoleBroadcaster),
      );
    } catch (e) {
      showMessage('Error initializing incoming call: $e');
    }
  }

  Future<void> _createDataStream() async {
    try {
      _streamId = await _engine?.createDataStream(
        const DataStreamConfig(syncWithAudio: true, ordered: true),
      );
      showMessage('Data stream created with ID: $_streamId');
    } catch (e) {
      showMessage('Error creating data stream: $e');
    }
  }

  Future<void> _sendCallTypeChange(CallType callType) async {
    if (_streamId == null) return;

    try {
      final message = callType == CallType.video ? 'video' : 'voice';
      final data = Uint8List.fromList(utf8.encode(message));
      await _engine?.sendStreamMessage(
        streamId: _streamId!,
        data: data,
        length: message.codeUnits.length,
      );
      showMessage('Sent call type change: $message');
    } catch (e) {
      showMessage('Error sending call type change: $e');
    }
  }

  Future<void> _startTimer() async {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime =
            (DateTime.now().millisecondsSinceEpoch - _startTime!) ~/ 1000;
        _formattedTime = _formatTime(_remainingTime!);
      });
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    seconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _endCall() async {
    try {
      await _engine?.leaveChannel();
      _engine?.release();
      _stopRinging();
      cancelCallTimeout();
      showMessage('Call ended');
      await FlutterCallkitIncoming.endAllCalls();
    } catch (e) {
      showMessage('Error ending call: $e');
    }
  }

  Future<void> _startRinging() async {
    ToggleSound.callRingEnable();
    // Timer.periodic(Duration(seconds: 3), (timer) {
    //   ToggleSound.callRingEnable();
    //   if(isAccepted){
    //     _stopRinging();
    //     return;
    //   }
    // }
    // );
    // while(true){
    //   if(isAccepted){
    //     _stopRinging();
    //   }
    // }
  }

  Future<void> _stopRinging() async {
    ToggleSound.callRingDisable();
  }

  @override
  void dispose() {
    // _stopRinging();
    _endCall();
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // debugPrints.log("FlutterCallkitIncoming =====> $isAccepted");
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        return PopScope(
          canPop: _engine != null || widget.token == null,
          child: Scaffold(
            body: Stack(
              children: [
                if (state.callType == CallType.video &&
                    _engine != null &&
                    remoteUid != null) ...[
                  AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: _engine!,
                      canvas: VideoCanvas(uid: remoteUid),
                      connection: RtcConnection(
                          channelId: widget.channelName ??
                              tokenAndChannel?.channelName),
                    ),
                  ),
                ],
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.transparent
                      ],
                    ),
                  ),
                ),
                Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    titleSpacing: 0,
                    centerTitle: false,
                    forceMaterialTransparency: true,
                    automaticallyImplyLeading: false,
                    leading: CupertinoButton(
                      onPressed: () async {
                        _endCall();
                        await chatCubit.rejectCall(
                            // context: context,
                            chatId: widget.currentConversationId,
                            callId: callId,
                            duration: 0);
                        Navigator.pop(context);
                      },
                      child: SvgImage(
                          source: SvgAssets.icArrowBack,
                          width: 20.w,
                          color: AppColors.white),
                    ),
                    title: Text(
                      widget.name,
                      style: AppTextStyles.medium(fontSize: 16.sp),
                    ),
                    actions: [
                      if (state.callType == CallType.video)
                        CupertinoButton(
                            child: Icon(CupertinoIcons.switch_camera,
                                color: context.theme.dividerColor),
                            onPressed: () {
                              _engine?.switchCamera();
                            })
                    ],
                  ),
                  body: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (state.callType == CallType.voice ||
                              (state.callType == CallType.video &&
                                  _engine == null)) ...[
                            const Spacer(),
                            AvatarGlow(
                                glowCount: 2,
                                glowRadiusFactor: 0.15,
                                glowColor: context.theme.dividerColor,
                                curve: Curves.decelerate,
                                child: AvatarWidgets(
                                  userPic: widget.image,
                                  width: context.w * 0.4,
                                  height: context.w * 0.4,
                                )
                                // Container(
                                //   width: context.w * 0.4,
                                //   height: context.w * 0.4,
                                //   constraints: const BoxConstraints(
                                //       maxWidth: 300, maxHeight: 300),
                                //   decoration: BoxDecoration(
                                //     shape: BoxShape.circle,
                                //     color: context.theme.dividerColor
                                //         .withValues(alpha:0.05),
                                //     image: widget.image.isEmpty?null: DecorationImage(
                                //         image: CachedNetworkImageProvider(
                                //             widget.image),
                                //         fit: BoxFit.cover),
                                //   ),
                                // ),
                                ),
                            if (remoteIsMuted) ...[
                              50.s,
                              CircleAvatar(
                                backgroundColor: Colors.white12,
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Icon(
                                    Icons.mic_off_rounded,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            ],
                          ] else if (state.callType == CallType.video &&
                              _engine != null) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: context.w * 0.3,
                                  height: context.w * 0.4,
                                  constraints: const BoxConstraints(
                                      maxWidth: 300, maxHeight: 400),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          blurRadius: 10,
                                          color: Colors.black
                                              .withValues(alpha: 0.1))
                                    ],
                                    color:
                                        context.theme.scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        AgoraVideoView(
                                            controller: VideoViewController(
                                                rtcEngine: _engine!,
                                                canvas: VideoCanvas(uid: 0),
                                                useAndroidSurfaceView: true,
                                                useFlutterTexture: true)),
                                        if (isDisableVideo)
                                          BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaX: 5, sigmaY: 5),
                                              child: Center()),
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                            children: [
                                              if (isMute)
                                                Icon(
                                                  Icons.mic_off_rounded,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                              5.s,
                                              if (isDisableVideo)
                                                Icon(
                                                  Icons.videocam_off_rounded,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Spacer(),
                                if (remoteIsDisableVideo) ...[
                                  CircleAvatar(
                                    backgroundColor: Colors.white12,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Icon(
                                        Icons.videocam_off_rounded,
                                        color:
                                            Colors.white.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                  5.s
                                ],
                                if (remoteIsMuted)
                                  CircleAvatar(
                                    backgroundColor: Colors.white12,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Icon(
                                        Icons.mic_off_rounded,
                                        color:
                                            Colors.white.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                          const Spacer(flex: 5),
                          if (!isAccepted &&
                              widget.token != null &&
                              widget.channelName != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    child: Text(
                                      S.of(context).accept,
                                      style: AppTextStyles.medium(
                                        fontSize: 16.sp,
                                        color: AppColors.white,
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isAccepted = true;
                                      });
                                      _stopRinging();
                                      _initializeCall();
                                    },
                                  ),
                                ),
                                13.s,
                                Expanded(
                                  child: CustomButton(
                                    onPressed: () async {
                                      await _endCall();
                                      await chatCubit.rejectCall(
                                        // context: context,
                                        duration: 0,
                                        callId: callId,
                                        chatId: widget.currentConversationId,
                                      );
                                      Navigator.pop(context);
                                    },
                                    backgroundColor: Colors.red.shade700,
                                    child: Text(
                                      S.of(context).reject,
                                      style: AppTextStyles.medium(
                                        fontSize: 16.sp,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            IntrinsicWidth(
                              child: Column(
                                children: [
                                  if (_formattedTime != null)
                                    Text(
                                      _formattedTime!,
                                      style: AppTextStyles.medium(
                                        fontSize: 16.sp,
                                        color: AppColors.white,
                                      ),
                                    )
                                  else
                                    Text(S.of(context).connecting),
                                  13.s,
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      if (state.callType == CallType.video) ...[
                                        Tooltip(
                                          message: isDisableVideo
                                              ? S.of(context).disableVideo
                                              : S.of(context).enableVideo,
                                          child: CupertinoButton(
                                            onPressed: () {
                                              setState(() {
                                                isDisableVideo =
                                                    !isDisableVideo;
                                                _engine?.muteLocalVideoStream(
                                                    isDisableVideo);
                                              });
                                            },
                                            padding: EdgeInsets.zero,
                                            child: Container(
                                                padding:
                                                    const EdgeInsets.all(15),
                                                decoration: BoxDecoration(
                                                    color: isDisableVideo
                                                        ? AppColors.primaryColor
                                                        : Colors.white,
                                                    shape: BoxShape.circle),
                                                child: Icon(
                                                    Icons.videocam_off_rounded,
                                                    color: isDisableVideo
                                                        ? AppColors.white
                                                        : context.theme
                                                            .scaffoldBackgroundColor
                                                            .withValues(
                                                                alpha:
                                                                    isDisableVideo
                                                                        ? 1
                                                                        : 0.5))),
                                          ),
                                        ),
                                        // 5.s,
                                      ],
                                      Tooltip(
                                        message: isMute
                                            ? 'Mute Audio'
                                            : 'Unmute Audio',
                                        child: CupertinoButton(
                                          onPressed: () {
                                            setState(() {
                                              isMute = !isMute;
                                              _engine?.muteLocalAudioStream(
                                                  isMute);
                                            });
                                          },
                                          padding: EdgeInsets.zero,
                                          child: Container(
                                              padding: const EdgeInsets.all(15),
                                              decoration: BoxDecoration(
                                                  color: isMute
                                                      ? AppColors.primaryColor
                                                      : Colors.white,
                                                  shape: BoxShape.circle),
                                              child: Icon(Icons.mic_off_rounded,
                                                  color: isMute
                                                      ? AppColors.white
                                                      : context.theme
                                                          .scaffoldBackgroundColor
                                                          .withValues(
                                                              alpha: isMute
                                                                  ? 1
                                                                  : 0.5))),
                                        ),
                                      ),
                                      // 5.s,
                                      CupertinoButton(
                                        onPressed: () {
                                          try {
                                            if (state.callType ==
                                                CallType.video) {
                                              chatCubit.changeCallType(
                                                  callType: CallType.voice);
                                              _engine?.disableVideo();
                                              _sendCallTypeChange(
                                                  CallType.voice);
                                              chatCubit.toggleSpeaker(false);
                                              _engine?.setEnableSpeakerphone(
                                                  false);
                                            } else {
                                              chatCubit.changeCallType(
                                                  callType: CallType.video);
                                              _engine?.enableVideo();
                                              _sendCallTypeChange(
                                                  CallType.video);
                                              chatCubit.toggleSpeaker(true);
                                              _engine
                                                  ?.setEnableSpeakerphone(true);
                                            }
                                            showMessage(
                                                "onPressed while change camera==>${state.callType}");
                                          } catch (e, st) {
                                            showMessage(
                                                "Error while change camera==>$e, $st");
                                          }
                                        },
                                        padding: EdgeInsets.zero,
                                        child: Container(
                                          padding: const EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                              color: AppColors.primaryColor,
                                              shape: BoxShape.circle),
                                          child: SvgImage(
                                              height: 24,
                                              width: 24,
                                              source: state.callType ==
                                                      CallType.video
                                                  ? SvgAssets.circlePhone
                                                  : SvgAssets.icVideoOutline,
                                              color: AppColors.white),
                                        ),
                                      ),
                                      // 5.s,
                                      CupertinoButton(
                                        onPressed: () async {
                                          await chatCubit
                                              .toggleSpeaker(!state.isSpeaker);
                                          _engine?.setEnableSpeakerphone(
                                              !state.isSpeaker);
                                        },
                                        padding: EdgeInsets.zero,
                                        child: Container(
                                          padding: const EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                              color: state.isSpeaker
                                                  ? AppColors.primaryColor
                                                  : Colors.white,
                                              shape: BoxShape.circle),
                                          child: SvgImage(
                                            source: SvgAssets.speacker,
                                            height: 24,
                                            width: 24,
                                            color: state.isSpeaker
                                                ? AppColors.white
                                                : AppColors.seondaryIconColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  (13 * 2).s,
                                  CustomButton(
                                    onPressed: _engine != null ||
                                            widget.token == null
                                        ? () async {
                                            // chatCubit.callReject(
                                            //     context: context,reciverID:);

                                            try {
                                              await chatCubit.rejectCall(
                                                // context: context,
                                                chatId: widget
                                                    .currentConversationId,
                                                duration: 0,
                                                callId: callId,
                                              );
                                              NavigationService().popUntil();
                                            } catch (e, st) {
                                              showMessage(
                                                  "Error while End call==>$e, $st");
                                            }
                                          }
                                        : () {},
                                    backgroundColor: Colors.red.shade600,
                                    child: Text(
                                      S.of(context).endCall,
                                      style: AppTextStyles.medium(
                                        fontSize: 16.sp,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<void> getCameraAndMicrophonePermission(
    {required BuildContext context}) async {
  try {
    // Loader.show();

    await Permission.camera.request();
    await Permission.microphone.request();

    // while(true){
    //   final permission = await Permission.camera.request();
    //   if(permission == PermissionStatus.granted || permission == PermissionStatus.limited){
    //     break;
    //   }
    //   Loader.hide();
    //   if(permission == PermissionStatus.permanentlyDenied) {
    //     await CustomAlertDialog(
    //       context: context,
    //       icon: Assets.icon.svg.cameraOutline,
    //       title: 'Permission Required',
    //       description: 'Camera permission is required to call.',
    //       buttonText: 'Enable Permission',
    //       onPressed: openAppSettings
    //     );
    //     Loader.show();
    //     await Future.delayed(Duration(seconds: 1));
    //     final isCamera = await Permission.camera.request().isGranted;
    //     if(isCamera) {
    //       break;
    //     }
    //   } else{
    //     await Permission.camera.request();
    //     Loader.show();
    //   }
    // }
    //
    // while(true){
    //   final permission = await Permission.microphone.request();
    //   if(permission == PermissionStatus.granted || permission == PermissionStatus.limited){
    //     break;
    //   }
    //   Loader.hide();
    //   if(permission == PermissionStatus.permanentlyDenied) {
    //     await CustomAlertDialog(
    //       context: context,
    //       icon: Assets.icon.svg.microphoneCircleOutline,
    //       title: 'Permission Required',
    //       description: 'Microphone permission is required to call.',
    //       buttonText: 'Enable Permission',
    //       onPressed: openAppSettings
    //     );
    //     Loader.show();
    //     await Future.delayed(Duration(seconds: 1));
    //     final isCamera = await Permission.microphone.request().isGranted;
    //     if(isCamera) {
    //       break;
    //     }
    //   } else{
    //     await Permission.microphone.request();
    //     Loader.show();
    //   }
    // }
  } catch (e) {
    showMessage('$e');
  } finally {
    // Loader.hide();
  }
}
