import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:two_one_two_messenger/database/local_db.dart';
import 'package:two_one_two_messenger/services/api_config.dart';
import 'package:two_one_two_messenger/utils/constants.dart';

import '../utils/utils.dart';

// class SocketService {
//   // Singleton instance
//   static final SocketService _instance = SocketService._internal();

//   // Factory constructor to return the same instance
//   factory SocketService() => _instance;

//   // Private constructor
//   SocketService._internal();

//   late IO.Socket _socket;

//   IO.Socket get socket => _socket;

//   Function(bool isConnected)? onConnectionChange;
//   bool _isConnected = false;
//   // Initialize the socket
//   void connect() {
//     try {
//       // _socket = IO.io(Urls.baseURL, <String, dynamic>{
//       //   'transports': ['websocket'],
//       //   'autoConnect': true,
//       // });

//       _socket = IO.io(
//           Urls.baseURL,
//           IO.OptionBuilder()
//               .setTransports(['websocket']) // for Flutter or Dart VM
//               .enableAutoConnect()
//               .setReconnectionDelay(2000)
//               .build());

//       _socket.onConnect(
//         (data) {
//           showMessage(":::: Socket Connected ::::");
//           _isConnected = true;
//           showMessage("✅ Socket Connected");
//           onConnectionChange?.call(true);
//         },
//       );

//       _socket.onDisconnect((_) {
//         showMessage(':::: Disconnected from socket server');
//         _isConnected = false;
//         showMessage("❌ Socket Disconnected");
//         onConnectionChange?.call(false);
//       });

//       _socket!.onReconnect((_) async {
//         showMessage("🔄 Socket Reconnected");
//         UserData? user = await DatabaseHelper().getLoginData();
//         if ((user?.sId ?? "").isNotEmpty) {
//           joinEvent(AppConstants.socketJoinChat, {"userId": user?.sId});
//         }
//       });
//       _socket.connect();
//     } on Exception catch (e) {
//       _socket.onConnectError(
//         (data) {
//           showMessage("Error:::::SOCKET CONNECTION::$data");
//         },
//       );
//     }
//   }

//   //Join chat
//   // socket.emit('joinChat', {"userId": userData?.sId});
//   void joinEvent(String event, dynamic data) {
//     showMessage(":::: Join chat $data");
//     _socket.emit(event, data);
//   }

//   // New method to listen for 'user-online' event
//   void onUserOnline(String event, Function(dynamic) callback) {
//     showMessage(":::: USER Is Online Socket");
//     _socket.on(event, callback);
//   }

//   // Send data
//   void sendEvent(String event, dynamic data) {
//     showMessage("sendEvent $event==> ${data}");
//     _socket.emit(event, data);
//   }

//   void editMessage(dynamic data) {
//     showMessage("editMessage ==> ${data}");
//     _socket.emit(AppConstants.editMessageEvent, data);
//   }

//   void editSavedMessage(dynamic data) {
//     showMessage("editSavedMessage ==> ${data}");
//     _socket.emit(AppConstants.editSavedMessageEvent, data);
//   }

//   void reactMessageEvent(dynamic data) {
//     showMessage("reactMessageEvent ==> ${data}");
//     _socket.emit(AppConstants.reactMessageEvent, data);
//   }

//   void reactSavedMessageEvent(dynamic data) {
//     showMessage("reactSavedMessageEvent ==> ${data}");
//     _socket.emit(AppConstants.reactSavedMessageEvent, data);
//   }

//   void forwardMessage(dynamic data) {
//     showMessage("forwardMessage ==> ${data}");
//     _socket.emit(AppConstants.forwardMessage, data);
//   }
//   void forwardSavedMessage(dynamic data) {
//     showMessage("forwardSavedMessage ==> ${data}");
//     _socket.emit(AppConstants.forwardSavedMessage, data);
//   }
//   void logout(dynamic data) {
//     showMessage("logout ==> ${data}");
//     _socket.emit(AppConstants.logout, data);
//   }

//   // void onEditMessage(Function(dynamic) callback) {
//   //   _socket.on(AppConstants.editMessageEvent, callback);
//   // }

//   void setUnreadNotificationCount(dynamic data) {
//     showMessage("sendEvent ==> ${data}");
//     _socket.emit(AppConstants.setUnreadNotificationCount, data);
//   }

//   // Listen to events
//   void receiveMessage(String event, Function(dynamic) callback) {
//     _socket.on(event, callback);
//   }

//   void onEditMessage(Function(dynamic) callback) {
//     _socket.on(AppConstants.onEditMessage, callback);
//   }

//   void onError(Function(dynamic) callback) {
//     _socket.on(AppConstants.errorMessage, callback);
//   }

//   void onUnArchiveChat(Function(dynamic) callback) {
//     _socket.on(AppConstants.onUnArchiveChat, callback);
//   }

//   void onArchiveChat(Function(dynamic) callback) {
//     _socket.on(AppConstants.onArchiveChat, callback);
//   }

//   void onEditSavedMessage(Function(dynamic) callback) {
//     _socket.on(AppConstants.onEditSavedMessage, callback);
//   }

//   void onReactMessageEvent(Function(dynamic) callback) {
//     _socket.on(AppConstants.onReactMessageEvent, callback);
//   }

//   void onReactSavedMessageEvent(Function(dynamic) callback) {
//     _socket.on(AppConstants.onReactSavedMessageEvent, callback);
//   }

//   void deleteMessage(Function(dynamic) callback) {
//     _socket.on(AppConstants.deleteMessageEveryone, callback);
//   }

//   void onSavedMessage(Function(dynamic) callback) {
//     _socket.on(AppConstants.onMessageSaved, callback);
//   }

//   void changeMessageStatus(String event, Function(dynamic) callback) {
//     _socket.on(event, callback);
//   }

//   void onBlockUser(Function(dynamic) callback) {
//     _socket.on(AppConstants.userBlockedyou, callback);
//   }

//   void onRemoveUser(Function(dynamic) callback) {
//     showMessage("removeFromGroup");
//     _socket.on(AppConstants.removeFromGroup, callback);
//   }

//   void onAddedToGroup(Function(dynamic) callback) {
//     showMessage("onAddedToGroup");
//     _socket.on(AppConstants.addtoGroupGroup, callback);
//   }

//   void onAssignOrRemoveFromAdminToGroup(Function(dynamic) callback) {
//     _socket.on(AppConstants.onAssignOrRemoveFromAdminToGroup, callback);
//   }

//   void onPinnedMessage(Function(dynamic) callback) {
//     _socket.on(AppConstants.onPinedMessage, callback);
//   }

//   void onPinnedSavedMessage(Function(dynamic) callback) {
//     _socket.on(AppConstants.onPinnedSavedMessage, callback);
//   }

//   void onUnPinnedMessage(Function(dynamic) callback) {
//     _socket.on(AppConstants.onUnPinedMessage, callback);
//   }

//   void onUnPinnedSavedMessage(Function(dynamic) callback) {
//     _socket.on(AppConstants.onUnPinedSasvedMessage, callback);
//   }

//   void onUserTyping(String event, Function(dynamic) callback) {
//     showMessage(":::: USER Is Online Socket");
//     _socket.on(event, callback);
//   }

//   void onReceiveCall(Function(dynamic) callback) {
//     showMessage(":::: onReceiveCall");
//     _socket.on(AppConstants.receiveCall, callback);
//   }

//   void onUpdateNotificationCount(Function(dynamic) callback) {
//     showMessage(":::: onUpdateNotificationCount");
//     _socket.on(AppConstants.getUnreadNotificationCount, callback);
//   }

//   void onEndCall(Function(dynamic) callback) {
//     showMessage(":::: onEndCall");
//     _socket.on(AppConstants.onEndCall, callback);
//   }

//   // Disconnect the socket
//   void disconnect() {
//     _socket.disconnect();
//   }
// }

class SocketService {
  // Singleton instance with lazy initialization
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  // Socket and state variables
  late IO.Socket _socket;
  bool _isConnected = false;
  // final Logger _logger = Logger();
  final Map<String, List<Function(dynamic)>> _listeners = {};
  Function(bool isConnected)? onConnectionChange;

  // Getters
  IO.Socket get socket => _socket;
  bool get isConnected => _isConnected;

  /// Initializes and connects the socket
  void connect() {
    try {
      _socket = IO.io(
        Urls.baseURL,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .setReconnectionDelay(1000)
            .setReconnectionAttempts(1000)
            .build(),
      );

      _setupConnectionHandlers();
      _socket.connect();
    } catch (e) {
      showMessage(
        'Socket connection error',
      );
    }
  }

  /// Sets up all connection-related event handlers
  void _setupConnectionHandlers() {
    _socket.onConnect((_) {
      _isConnected = true;
      if (kDebugMode) {
        print('✅ Socket connected');
      }
      onConnectionChange?.call(true);
    });

    _socket.onDisconnect((_) {
      _isConnected = false;
      if (kDebugMode) {
        print('❌ Socket disconnected');
      }
      onConnectionChange?.call(false);
    });

    _socket.onReconnect((_) async {
      if (kDebugMode) {
        print('🔄 Socket reconnected');
      }
      final user = await DatabaseHelper().getLoginData();
      if ((user?.sId ?? "").isNotEmpty) {
        joinEvent(AppConstants.socketJoinChat, {"userId": user?.sId});
      }
    });

    _socket.onConnectError((err) {
      if (kDebugMode) {
        print('Socket connection error');
      }
      _socket.connect();
    });
    _socket.onclose((reason) {
      showMessage('Socket closed $reason');
    });

    _socket.onPing((ping) {
      showMessage('Socket ping $ping');
    });
    _socket.onPong((pong) {
      showMessage('Socket pong $pong');
    });
    _socket.onError((err) {
      showMessage(
        'Socket error',
      );
    });
  }

  /// Joins a chat/room
  void joinEvent(String event, dynamic data) {
    _logEvent('Join event', event, data);
    _socket.emit(event, data);
  }

  /// Sends a generic event
  void sendEvent(String event, dynamic data) {
    _logEvent('Send event', event, data);
    _socket.emitWithAck(
      event,
      data,
    );
  }

  /// Sends a generic event
  void sendMessage(dynamic data, Function(dynamic) ackCallback) {
    _logEvent('Send event', AppConstants.sendMessage, data);
    _socket.emitWithAck(AppConstants.sendMessage, data, ack: (data) {
      debugPrint("Send Message==> $data");
      ackCallback(data);
    });
  }

  /// Message-related methods
  void editMessage(dynamic data) =>
      _emitWithLog('Edit message', AppConstants.editMessageEvent, data);
  void editSavedMessage(dynamic data) => _emitWithLog(
      'Edit saved message', AppConstants.editSavedMessageEvent, data);
  void reactMessageEvent(dynamic data) =>
      _emitWithLog('React message', AppConstants.reactMessageEvent, data);
  void reactSavedMessageEvent(dynamic data) => _emitWithLog(
      'React saved message', AppConstants.reactSavedMessageEvent, data);
  void forwardMessage(dynamic data) =>
      _emitWithLog('Forward message', AppConstants.forwardMessage, data);
  void forwardSavedMessage(dynamic data) => _emitWithLog(
      'Forward saved message', AppConstants.forwardSavedMessage, data);
  void logout(dynamic data) =>
      _emitWithLog('Logout', AppConstants.logout, data);
  void setUnreadNotificationCount(dynamic data) => _emitWithLog(
      'Set unread count', AppConstants.setUnreadNotificationCount, data);
  void sendHeartBeat(dynamic data) =>
      _emitWithLog('Send HeartBeat', AppConstants.heartBeat, data);
  void emitEndCall(dynamic data) {
    if (onCallEndedTimer != null) {
      onCallEndedTimer?.cancel();
    }
    onCallEndedTimer = Timer(
      Duration(milliseconds: 800),
      () {
        _emitWithLog('End Call', AppConstants.emitEndCall, data);
      },
    );
  }

  void emitpinUnpinConversation(dynamic data) => _emitWithLog(
        'Pin UnPin Conversation',
        AppConstants.pinUnpinConversation,
        data,
      );

  void emitMuteUnmuteConversation(dynamic data) => _emitWithLog(
        'Mute Unmute Conversation',
        AppConstants.pinUnpinConversation,
        data,
      );

  void emitMarkMessageAsUnread(dynamic data) => _emitWithLog(
        'markMessageAsUnread  Conversation',
        AppConstants.markMessageAsUnread,
        data,
      );

  /// Registers event listeners with automatic disposal tracking
  void on(String event, Function(dynamic) callback) {
    void listener(data) {
      try {
        _logEvent('Received event', event, data);
        callback(data);
      } catch (e, st) {
        showMessage(
          'Error in socket listener $e, $st',
        );
      }
    }

    _socket.on(event, listener);
    _listeners.putIfAbsent(event, () => []).add(listener);
  }

  Timer? onCallEndedTimer;

  /// Specific event listener methods
  void onUserOnline(Function(dynamic) callback) =>
      on(AppConstants.socketUserOnline, callback);
  void onEditMessage(Function(dynamic) callback) =>
      on(AppConstants.onEditMessage, callback);
  void onError(Function(dynamic) callback) =>
      on(AppConstants.errorMessage, callback);
  void onUnArchiveChat(Function(dynamic) callback) =>
      on(AppConstants.onUnArchiveChat, callback);
  void onArchiveChat(Function(dynamic) callback) =>
      on(AppConstants.onArchiveChat, callback);
  void onEditSavedMessage(Function(dynamic) callback) =>
      on(AppConstants.onEditSavedMessage, callback);
  void onReactMessageEvent(Function(dynamic) callback) =>
      on(AppConstants.onReactMessageEvent, callback);
  void onReactSavedMessageEvent(Function(dynamic) callback) =>
      on(AppConstants.onReactSavedMessageEvent, callback);
  void deleteMessage(Function(dynamic) callback) =>
      on(AppConstants.deleteMessageEveryone, callback);
  void onSavedMessage(Function(dynamic) callback) =>
      on(AppConstants.onMessageSaved, callback);
  void changeMessageStatus(Function(dynamic) callback) =>
      on(AppConstants.updateMessageStatus, callback);
  void onBlockUser(Function(dynamic) callback) =>
      on(AppConstants.userBlockedyou, callback);
  void onRemoveUser(Function(dynamic) callback) =>
      on(AppConstants.removeFromGroup, callback);
  void onAddedToGroup(Function(dynamic) callback) =>
      on(AppConstants.addtoGroupGroup, callback);
  void onAssignOrRemoveFromAdminToGroup(Function(dynamic) callback) =>
      on(AppConstants.onAssignOrRemoveFromAdminToGroup, callback);
  void onPinnedMessage(Function(dynamic) callback) =>
      on(AppConstants.onPinedMessage, callback);
  void onPinnedSavedMessage(Function(dynamic) callback) =>
      on(AppConstants.onPinnedSavedMessage, callback);
  void onUnPinnedMessage(Function(dynamic) callback) =>
      on(AppConstants.onUnPinedMessage, callback);
  void onUnPinnedSavedMessage(Function(dynamic) callback) =>
      on(AppConstants.onUnPinedSasvedMessage, callback);
  void onUserTyping(Function(dynamic) callback) =>
      on(AppConstants.receivedTypingStatus, callback);
  void onReceiveCall(Function(dynamic) callback) =>
      on(AppConstants.receiveCall, callback);
  void onUpdateNotificationCount(Function(dynamic) callback) =>
      on(AppConstants.getUnreadNotificationCount, callback);
  void onEndCall(Function(dynamic) callback) {
    on(AppConstants.onEndCall, callback);
  }

  void onPinConvesation(Function(dynamic) callback) {
    on(AppConstants.pinConvesation, callback);
  }

  void onMuteConvesation(Function(dynamic) callback) {
    on(AppConstants.muteConvesation, callback);
  }

  void onGroupSendPermissionUpdated(Function(dynamic) callback) =>
      on(AppConstants.groupSendPermissionUpdated, callback);

  void receiveMessage(Function(dynamic) callback) =>
      on(AppConstants.socketReceiveMessage, callback);
  void receiveSystemMessage(Function(dynamic) callback) =>
      on(AppConstants.receiveSystemMessage, callback);

  /// Removes specific listeners for an event
  void off(String event, [Function(dynamic)? callback]) {
    final listeners = _listeners[event];
    if (listeners == null) return;

    if (callback == null) {
      // Remove all listeners for this event
      for (final listener in listeners) {
        _socket.off(event, listener);
      }
      _listeners.remove(event);
    } else {
      // Find and remove specific listener
      final index = listeners.indexWhere((l) => l == callback);
      if (index != -1) {
        _socket.off(event, listeners[index]);
        listeners.removeAt(index);
      }
    }
  }

  /// Cleans up all socket resources
  void dispose() {
    // Remove all listeners
    for (final entry in _listeners.entries) {
      for (final listener in entry.value) {
        _socket.off(entry.key, listener);
      }
    }
    _listeners.clear();

    // Disconnect socket
    _socket.disconnect();
    _socket.clearListeners();
    _isConnected = false;
  }

  /// Helper method for logging and emitting events
  void _emitWithLog(String action, String event, dynamic data) {
    _logEvent(action, event, data);
    _socket.emit(event, data);
  }

  /// Standardized event logging
  void _logEvent(String action, String event, dynamic data) {
    showMessage('$action: $event => ${data.toString()}');
  }
}
