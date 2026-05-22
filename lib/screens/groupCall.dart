import 'dart:async';
import 'dart:convert';
import 'dart:developer' as prints;
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:avatar_glow/avatar_glow.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:two_one_two_messenger/cubit/chat_cubit.dart';
import 'package:two_one_two_messenger/cubit/chat_state.dart';
import 'package:two_one_two_messenger/database/local_db.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/models/token_and_channel.dart';
import 'package:two_one_two_messenger/services/api_client.dart';
import 'package:two_one_two_messenger/services/push_notifications.dart';
import 'package:two_one_two_messenger/services/socket_service.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/toggle_beep_sound.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/buttons.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';

class GroupCallingPage extends StatefulWidget {
  const GroupCallingPage({
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
  final bool? isActive;
  final String? callId;
  final String currentConversationId;

  @override
  State<GroupCallingPage> createState() => _GroupCallingPageState();
}

class _GroupCallingPageState extends State<GroupCallingPage>
    with WidgetsBindingObserver {
  RtcEngine? _engine;
  // int? remoteUid;
  List<int> remoteUids = [];
  int? _startTime;
  int? _remainingTime;
  String? _formattedTime;
  Timer? _timer;
  bool isAccepted = false;
  TokenAndChannel? tokenAndChannel;
  int? _streamId;
  bool isMute = false;
  bool isDisableVideo = false;
  // bool remoteIsMuted = false;
  // bool remoteIsDisableVideo = false;
  Map<int, bool> remoteMuteStatus = {}; // Tracks user audio mute state
  Map<int, bool> remoteVideoStatus = {}; // Tracks user video mute state
  String callId = "";
  // bool isVideoCall = false;
  AppLifecycleState? _previousLifecycleState;
  final SocketService _socketService = SocketService();
  UserData? currentUser;
  Timer? _callTimeoutTimer;
  @override
  void initState() {
    onInit();
    super.initState();
  }

  Future<void> onInit() async {
    prints.log("in side init ==== from${widget.from} ${widget.token}");

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      chatCubit.changeCallType(callType: widget.callType);
      onCallEnd();
      callId = widget.callId ?? "";

      if (widget.callType == CallType.voice ||
          widget.callType == CallType.voice_group_call) {
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
        prints.log("Call ring start =====");
        _startRinging();
      }
    });
    currentUser = await chatCubit.dbHelper.getLoginData();
    if (mounted) {
      setState(() {});
    }
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

  handleLocalVideoStream(bool isShow) {
    try {
      if (chatCubit.state.callType == CallType.video_group_call) {
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
      showMessage("_initializeIncomingCall  CALLID ${widget.callId} ");

      if (widget.token != null) {
        prints.log("_initializeIncomingCall");
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

      if (widget.callType == CallType.video_group_call) {
        await _engine?.enableVideo();
      } else {
        await _engine?.enableAudio();
      }

      if (mounted) {
        setState(() {});
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
          // onUserJoined: (connection, remoteId, _) {
          //   if (widget.token != null) {
          //     _stopRinging();
          //   }
          //   showMessage('onUserJoined: $connection');
          //   showMessage('onUserJoined: $remoteId');
          //   setState(() {
          //     remoteUid = remoteId;
          //     _startTime = DateTime.now().millisecondsSinceEpoch;
          //     _remainingTime = 0;
          //     _formattedTime = _formatTime(_remainingTime!);
          //     _startTimer();
          //   });
          // },
          onUserJoined: (RtcConnection connection, int remoteId, _) {
            if (widget.token != null) {
              _stopRinging();
            }
            showMessage('User joined: $remoteId');
// connection
            setState(() {
              if (!remoteUids.contains(remoteId)) {
                remoteUids.add(remoteId); // ✅ Store multiple users
              }
              _startTime = DateTime.now().millisecondsSinceEpoch;
              _remainingTime = 0;
              _formattedTime = _formatTime(_remainingTime!);
              cancelCallTimeout();
              _startTimer();
            });
          },

          // onUserOffline: (connection, reason, _) async {
          //   showMessage('onUserOffline: $connection');
          //   showMessage('onUserOffline: $reason');
          //   NavigationService(). popUntil();
          //   // showToast('Call Disconnect');

          //   setState(() {
          //     remoteUid = null;
          //   });
          // },
          onUserOffline: (RtcConnection connection, remoteUid, reson) async {
            showMessage('User left: $remoteUid');

            setState(() {
              remoteUids.remove(remoteUid); // ✅ Remove user
            });
            showMessage('User left: ${remoteUids}');
            if (remoteUids.isEmpty) {
              await FlutterCallkitIncoming.endAllCalls();
              _endCall();
              NavigationService().popUntil();
            }
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

              chatCubit.changeCallType(callType: CallType.video_group_call);
              _engine?.enableVideo();
              chatCubit.toggleSpeaker(true);
              _engine?.setEnableSpeakerphone(true);
            } else if (message == 'voice') {
              chatCubit.changeCallType(callType: CallType.voice_group_call);
              _engine?.disableVideo();
              chatCubit.toggleSpeaker(false);
              _engine?.setEnableSpeakerphone(false);
            }
          },
          onStreamMessageError: (RtcConnection connection, int uid,
              int streamId, ErrorCodeType error, int missed, int cached) {
            showMessage('Stream message error: $error');
          },
          // onUserMuteAudio: (RtcConnection connection, int uid, bool muted) {
          //   showMessage('onUserMuted: $uid muted: $muted');
          //   if (uid == remoteUid) {
          //     setState(() {
          //       remoteIsMuted = muted;
          //     });
          //   }
          // },
          onUserMuteAudio: (RtcConnection connection, int uid, bool muted) {
            showMessage('User $uid audio muted: $muted');

            setState(() {
              remoteMuteStatus[uid] =
                  muted; // ✅ Store mute status for each user
            });
          },

          // onUserMuteVideo: (RtcConnection connection, int uid, bool muted) {
          //   showMessage('onUserMuted: $uid muted: $muted');
          //   if (uid == remoteUid) {
          //     setState(() {
          //       remoteIsDisableVideo = muted;
          //     });
          //   }
          // },
          onUserMuteVideo: (RtcConnection connection, int uid, bool muted) {
            showMessage('User $uid video muted: $muted');

            setState(() {
              remoteVideoStatus[uid] =
                  muted; // ✅ Store video mute status for each user
            });
          },

          onError: (error, error2) {
            showMessage('onError: $error');
            showMessage('onError: $error2');
          },
          onLeaveChannel: (connection, stats) async {
            if (widget.token != null) {
              _stopRinging();
            }
            showMessage("onLeaveChannel call");
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
              showMessage(
                  "on Leave channel --> ${_startTime == null ? 0 : ((DateTime.now().millisecondsSinceEpoch - (_startTime ?? DateTime.now().millisecondsSinceEpoch)) ~/ 1000)}");
              await chatCubit.rejectCall(
                  // context: context,
                  chatId: widget.currentConversationId,
                  callId: callId,
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

  // Future<void> _initializeOutgoingCall() async {
  //   try {
  //     tokenAndChannel = await chatCubit.generateTokenAndChannelName(context: context,
  //         callType: widget.callType, chatId: widget.currentConversationId);

  //     if (tokenAndChannel?.token == null ||
  //         tokenAndChannel?.channelName == null) {
  //       Navigator.pop(context);
  //       return;
  //     }

  //     final localUid = Random().nextInt(100000);

  //     await _engine?.joinChannel(
  //       token: tokenAndChannel?.token ?? '',
  //       channelId: tokenAndChannel?.channelName ?? 'default_channel',
  //       uid: localUid,
  //       options: const ChannelMediaOptions(
  //           autoSubscribeAudio: true,
  //           publishMicrophoneTrack: true,
  //           autoSubscribeVideo: true,
  //           clientRoleType: ClientRoleType.clientRoleBroadcaster),
  //     );
  //      } catch (e) {
  //     showMessage('Error initializing outgoing call: $e');
  //   }
  // }

  Future<void> _initializeOutgoingCall() async {
    try {
      tokenAndChannel = await chatCubit.generateTokenAndChannelName(
          context: context,
          data: {
            "type": widget.callType.name,
            "groupName": widget.name,
            "groupImage": widget.image,
          },
          chatId: widget.currentConversationId);

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
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );

      showMessage("Joined channel: ${tokenAndChannel?.channelName}");
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
      if ((widget.callId ?? "").isNotEmpty) {
        _socketService.sendEvent(AppConstants.joinCall, {
          {
            "callId": widget.callId ?? "",
            "userId": AppPreference.getCurrentUserId()
          }
        });
      }
      await _engine?.joinChannel(
        token: widget.token ?? '',
        channelId: widget.channelName ?? '',
        uid: localUid,
        options: const ChannelMediaOptions(
          autoSubscribeAudio: true,
          publishMicrophoneTrack: true,
          autoSubscribeVideo: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );

      showMessage("Joined channel: ${widget.channelName}");
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
      final message = callType == CallType.video_group_call ? 'video' : 'voice';
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
    return BlocBuilder<ChatCubit, ChatState>(builder: (context, state) {
      return PopScope(
        canPop: _engine != null || widget.token == null,
        child: Scaffold(
          // backgroundColor: Colors.transparent,
          appBar: AppBar(
            titleSpacing: 0,
            centerTitle: false,
            forceMaterialTransparency: true,
            automaticallyImplyLeading: false,
            leading: CupertinoButton(
              onPressed: () async {
                _endCall();
                await chatCubit.rejectCall(
                    callId: callId,
                    // context: context,
                    chatId: widget.currentConversationId,
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
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              // Adjust height of the divider
              child: Container(
                color: AppColors.darkAppBar, // Set divider color
                height: 1, // Divider thickness
              ),
            ),
            actions: [
              if (state.callType == CallType.video_group_call)
                CupertinoButton(
                    child: Icon(CupertinoIcons.switch_camera,
                        color: context.theme.dividerColor),
                    onPressed: () {
                      _engine?.switchCamera();
                    })
            ],
          ),
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if ((state.callType == CallType.voice_group_call ||
                        state.callType == CallType.video_group_call) &&
                    _engine == null)
                  Expanded(
                      child: Column(
                    children: [
                      30.s,
                      AvatarGlow(
                        glowCount: 2,
                        glowRadiusFactor: 0.15,
                        glowColor: context.theme.dividerColor,
                        curve: Curves.decelerate,
                        child: Container(
                          width: context.w * 0.4,
                          height: context.w * 0.4,
                          constraints: const BoxConstraints(
                              maxWidth: 300, maxHeight: 300),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.theme.dividerColor.withOpacity(0.05),
                            image: widget.image.isNotEmpty
                                ? DecorationImage(
                                    image: CachedNetworkImageProvider(
                                        widget.image),
                                    fit: BoxFit.cover)
                                : null,
                          ),
                          child: widget.image.isEmpty
                              ? Center(
                                  child: SvgImage(
                                      source: SvgAssets.person2,
                                      fit: BoxFit.contain,
                                      // height: 32,
                                      // width: 32,
                                      color: AppColors.white),
                                )
                              : null,
                        ),
                      ),
                      // if (remoteIsMuted) ...[
                      //   50.s,
                      //   CircleAvatar(
                      //     backgroundColor: Colors.white12,
                      //     child: Padding(
                      //       padding: const EdgeInsets.all(5),
                      //       child: Icon(
                      //         Icons.mic_off_rounded,
                      //         color: Colors.white.withOpacity(0.7),
                      //       ),
                      //     ),
                      //   ),
                      // ],
                    ],
                  )),

                if (state.callType == CallType.voice_group_call &&
                    _engine != null)
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: _buildVoiceCallUI(),
                  )),

                if (state.callType == CallType.video_group_call &&
                    _engine != null)
                  Expanded(child: _buildVideoGrid()),
                // Spacer(),
                SizedBox(
                    width: double.infinity, child: _buildCallControls(state)),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildVideoGrid() {
    List<Widget> remainingUsers = remoteUids.map((uid) {
      return _renderRemoteVideo(uid);
    }).toList();

    return StaggeredGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 2,
      crossAxisSpacing: 8,
      children: [
        StaggeredGridTile.count(
          crossAxisCellCount: 2,
          mainAxisCellCount: 2,
          child: _renderLocalPreview(),
        ),
        ...remainingUsers.map(
          (e) => StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: e,
          ),
        ),
      ],
    );

    // return GridView.builder(
    //   shrinkWrap: true,
    //   itemCount: videoViews.length,

    //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //     crossAxisCount: videoViews.length <= 2 ? 1 : 2,
    //     crossAxisSpacing: 8,
    //     mainAxisSpacing: 8,
    //   ),
    //   itemBuilder: (context, index) {
    //     return videoViews[index];
    //   },
    // );
  }

  Widget _renderLocalPreview() {
    return Container(
      height: context.h * 0.3,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r)),
      child: Stack(
        children: [
          AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: _engine!,
              canvas: VideoCanvas(uid: 0),
            ),
          ),
          if (isDisableVideo)
            BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Center()),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
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
    );
  }

  Widget _renderRemoteVideo(int uid) {
    bool isMuted = remoteMuteStatus[uid] ?? false;
    bool isVideoMuted = remoteVideoStatus[uid] ?? false;

    return Container(
      height: context.w * 0.3,
      width: context.w * 0.4,
      clipBehavior: Clip.hardEdge,
      constraints: BoxConstraints(maxHeight: 133, maxWidth: 191),
      // margin: EdgeInsets.only(bottom: 10,),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r), color: AppColors.dialogBg),

      child: Stack(
        alignment: Alignment.topRight,
        children: [
          isVideoMuted
              ? Center(child: _buildAvatarPlaceholder(uid))
              : AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: _engine!,
                    canvas: VideoCanvas(uid: uid),
                    connection: RtcConnection(
                        channelId:
                            widget.channelName ?? tokenAndChannel?.channelName),
                  ),
                ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isMuted)
                  Icon(
                    Icons.mic_off_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                5.s,
                if (isVideoMuted)
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
    );
  }

  Widget _buildVoiceCallUI() {
    // List<Widget> userTiles = [];
    prints.log(
        "build Voice call ui  =>${(currentUser?.profilePicture ?? "").isNotEmpty ? "${Urls.mediaUrl}${currentUser?.profilePicture ?? ""}" : ""}");
    // // ✅ Add current user at the top (Full-width row)
    // userTiles.add(
    //   Padding(
    //     padding: const EdgeInsets.only(bottom: 10.0),
    //     child: _buildUserVoiceTile(
    //       uid: 0,
    //       imageUrl: widget.image,
    //       name: widget.name,
    //       isMuted: isMute,
    //       // isCurrentUser: true, // Pass a flag to style it differently
    //     ),
    //   ),
    // );

    // ✅ Add remaining users
    List<Widget> remainingUsers = remoteUids.map((uid) {
      return _buildUserVoiceTile(
        uid: uid,
        imageUrl: '',
        name: '',
        isMuted: remoteMuteStatus[uid] ?? false,
        // isCurrentUser: false,
      );
    }).toList();
    showMessage("end call object==> _buildVoiceCallUI");
    return StaggeredGrid.count(
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        StaggeredGridTile.count(
          crossAxisCellCount: 3,
          mainAxisCellCount: 2,
          child: _buildUserVoiceTile(
            uid: 0,
            imageUrl: (currentUser?.profilePicture ?? "").isNotEmpty
                ? "${Urls.mediaUrl}${currentUser?.profilePicture ?? ""}"
                : "",
            name: currentUser?.name ?? "",
            isMuted: isMute,
            // isCurrentUser: true, // Pass a flag to style it differently
          ),
        ),
        ...remainingUsers.map(
          (e) => StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 2,
            child: e,
          ),
        ),
      ],
    );

    // return Column(
    //   crossAxisAlignment: CrossAxisAlignment.center,
    //   children: [
    //     // ✅ Display current user in full width
    //     SizedBox(width: double.infinity, child: userTiles[0]),

    //     // ✅ Grid for remaining users (3 per row)
    //     // Expanded(
    //     //   child: GridView.builder(
    //     //     shrinkWrap: true,

    //     //     physics: NeverScrollableScrollPhysics(), // No scrolling, use full height
    //     //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //     //       crossAxisCount: 3, // Max 3 per row
    //     //       childAspectRatio: 1, // Make it square
    //     //     ),
    //     //     itemCount: userTiles.length - 1, // Exclude current user
    //     //     itemBuilder: (context, index) => userTiles[index + 1], // Start from 2nd user
    //     //   ),
    //     // ),

    //     if (remainingUsers.isNotEmpty)
    //       Expanded(
    //           child: Wrap(
    //         alignment: WrapAlignment.center,
    //         direction: Axis.horizontal,
    //         children: remainingUsers,
    //       )

    //           ),
    //   ],
    // );
  }

// Widget _buildVoiceCallUI() {
//   return GridView.builder(
//     shrinkWrap: true,
//     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//       crossAxisCount: remoteUids.length < 2 ? 1 : 2, // Adjust for 1-on-1 or group
//     ),
//     itemCount: remoteUids.length + 1, // +1 for local user
//     itemBuilder: (context, index) {
//       if (index == 0) {
//         return _buildUserVoiceTile(
//           uid: 0,
//           imageUrl: widget.image,
//           name: widget.name,
//           isMuted: isMute,
//         );
//       } else {
//         int remoteUid = remoteUids[index - 1];
//         return _buildUserVoiceTile(
//           uid: remoteUid,
//           imageUrl: "",
//           name: "",
//           isMuted: remoteMuteStatus[remoteUid] ?? false,
//         );
//       }
//     },
//   );
// }
  Widget _buildUserVoiceTile({
    required int uid,
    required String imageUrl,
    required String name,
    required bool isMuted,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              clipBehavior: Clip.hardEdge,
              // padding: EdgeInsets.all(8),
              constraints: const BoxConstraints(maxWidth: 150, maxHeight: 150),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.theme.dividerColor.withOpacity(0.05),
                image: imageUrl.isEmpty
                    ? null
                    : DecorationImage(
                        image: CachedNetworkImageProvider(imageUrl),
                        fit: BoxFit.cover),
              ),
              child: imageUrl.isNotEmpty
                  ? null
                  : Center(
                      child: SvgImage(
                        source: SvgAssets.icPerson,
                        fit: BoxFit.contain,
                        height: 35,
                        width: 35,
                      ),
                    ),
            ),
            if (name.isNotEmpty) 8.s,
            if (name.isNotEmpty)
              Text(
                name,
                style: AppTextStyles.regular(),
              )
          ],
        ),
        if (isMuted)
          Positioned(
            bottom: 5,
            right: 5,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: Colors.red,
              child: Icon(Icons.mic_off, color: Colors.white, size: 14),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatarPlaceholder(int uid) {
    return SvgImage(
      source: SvgAssets.icPerson,
      fit: BoxFit.contain,
      height: 30,
      width: 30,
    );
  }

  Widget _buildMuteIcon() {
    return Positioned(
      top: 10,
      right: 10,
      child: Icon(Icons.mic_off, color: Colors.red, size: 20),
    );
  }

  Widget _buildVideoOffIcon() {
    return Positioned(
      top: 10,
      left: 10,
      child: Icon(Icons.videocam_off, color: Colors.red, size: 20),
    );
  }

  Widget _buildCallControls(ChatState state) {
    if (!isAccepted && widget.token != null && widget.channelName != null) {
      return Row(
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
                  callId: callId,
                  duration: 0,
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
      );
    } else {
      return IntrinsicWidth(
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (state.callType == CallType.video_group_call) ...[
                  Tooltip(
                    message: isDisableVideo
                        ? S.of(context).disableVideo
                        : S.of(context).enableVideo,
                    child: CupertinoButton(
                      onPressed: () {
                        setState(() {
                          isDisableVideo = !isDisableVideo;
                          _engine?.muteLocalVideoStream(isDisableVideo);
                        });
                      },
                      padding: EdgeInsets.zero,
                      child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: isDisableVideo
                                  ? AppColors.primaryColor
                                  : Colors.white,
                              shape: BoxShape.circle),
                          child: Icon(Icons.videocam_off_rounded,
                              color: isDisableVideo
                                  ? AppColors.white
                                  : context.theme.scaffoldBackgroundColor
                                      .withOpacity(isDisableVideo ? 1 : 0.5))),
                    ),
                  ),
                  // 5.s,
                ],
                Tooltip(
                  message: isMute ? 'Mute Audio' : 'Unmute Audio',
                  child: CupertinoButton(
                    onPressed: () {
                      setState(() {
                        isMute = !isMute;
                        _engine?.muteLocalAudioStream(isMute);
                      });
                    },
                    padding: EdgeInsets.zero,
                    child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color:
                                isMute ? AppColors.primaryColor : Colors.white,
                            shape: BoxShape.circle),
                        child: Icon(Icons.mic_off_rounded,
                            color: isMute
                                ? AppColors.white
                                : context.theme.scaffoldBackgroundColor
                                    .withOpacity(isMute ? 1 : 0.5))),
                  ),
                ),
                // 5.s,
                CupertinoButton(
                  onPressed: () {
                    try {
                      if (state.callType == CallType.video_group_call) {
                        chatCubit.changeCallType(
                            callType: CallType.voice_group_call);
                        _engine?.disableVideo();
                        _sendCallTypeChange(CallType.voice_group_call);
                        chatCubit.toggleSpeaker(false);
                        _engine?.setEnableSpeakerphone(false);
                      } else {
                        chatCubit.changeCallType(
                            callType: CallType.video_group_call);
                        _engine?.enableVideo();
                        _sendCallTypeChange(CallType.video_group_call);
                        chatCubit.toggleSpeaker(true);
                        _engine?.setEnableSpeakerphone(true);
                      }
                      showMessage(
                          "onPressed while change camera==>${state.callType}");
                    } catch (e, st) {
                      showMessage("Error while change camera==>$e, $st");
                    }
                  },
                  padding: EdgeInsets.zero,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: AppColors.primaryColor, shape: BoxShape.circle),
                    child: SvgImage(
                        height: 24,
                        width: 24,
                        source: state.callType == CallType.video_group_call
                            ? SvgAssets.circlePhone
                            : SvgAssets.icVideoOutline,
                        color: AppColors.white),
                  ),
                ),
                // 5.s,
                CupertinoButton(
                  onPressed: () async {
                    await chatCubit.toggleSpeaker(!state.isSpeaker);
                    _engine?.setEnableSpeakerphone(!state.isSpeaker);
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
              onPressed: _engine != null || widget.token == null
                  ? () async {
                      // chatCubit.callReject(
                      //     context: context,reciverID:);

                      prints.log("end call ${_engine} ${widget.token}");
                      try {
                        // _engine = null;
                        await chatCubit.rejectCall(
                          // context: context,
                          callId: callId,
                          chatId: widget.currentConversationId,
                          duration: 0,
                        );
                        // _engine = null;
                        NavigationService().popUntil();
                      } catch (e, st) {
                        showMessage("Error while End call==>$e, $st");
                      }
                    }
                  : () {
                      prints.log("end call ${_engine} ${widget.token}");
                    },
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
      );
    }

    // Row(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   children: [
    //     IconButton(
    //       icon: Icon(isMute ? Icons.mic_off : Icons.mic),
    //       onPressed: () {
    //         setState(() {
    //           isMute = !isMute;
    //           _engine?.muteLocalAudioStream(isMute);
    //         });
    //       },
    //     ),
    //     IconButton(
    //       icon: Icon(Icons.call_end, color: Colors.red),
    //       onPressed: () {
    //         Navigator.pop(context);
    //       },
    //     ),
    //     if (widget.callType == CallType.video)
    //       IconButton(
    //         icon: Icon(isDisableVideo ? Icons.videocam_off : Icons.videocam),
    //         onPressed: () {
    //           setState(() {
    //             isDisableVideo = !isDisableVideo;
    //             _engine?.muteLocalVideoStream(isDisableVideo);
    //           });
    //         },
    //       ),
    //   ],
    // );
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
