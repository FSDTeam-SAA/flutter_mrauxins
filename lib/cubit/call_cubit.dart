import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:two_one_two_messenger/database/local_db.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/models/token_and_channel.dart';
import 'package:two_one_two_messenger/services/socket_service.dart';

import '../services/api_client.dart';
import '../utils/utils.dart';
import 'call_state.dart';

class CallCubit extends Cubit<CallState> {
  final ApiClient apiClient;
  final DatabaseHelper dbHelper;

  CallCubit(this.apiClient, this.dbHelper) : super(const CallState());

  Future<void> changeCallType({required CallType callType}) async {
    emit(state.copyWith(callType: callType));
  }

  Future<void> toggleSpeaker(bool value) async {
    emit(state.copyWith(isSpeaker: value));
  }

  Future<TokenAndChannel?> generateTokenAndChannelName(
      {required BuildContext context,
      required Map<String, dynamic> data,
      required String chatId}) async {
    try {
      final response = await apiClient.requestCall(
          chatId: chatId, data: data, context: context);
      if (response.status == Utils.APISUCCESS) {
        return TokenAndChannel.fromJson(response.data!.toJson());
      } else {
        showMessage(response.message ?? "");
        return null;
      }
    } catch (e, st) {
      showMessage('generateTokenAndChannelName: $e, $st');
      return null;
    }
  }

  Future<void> rejectCall(
      {required String chatId,
      required String callId,
      required int duration}) async {
    try {
      UserData? currentuser = await dbHelper.getLoginData();
      SocketService().emitEndCall({
        "user_id": currentuser?.sId,
        "duration": duration,
        "chat_id": chatId,
        "callId": callId,
      });
    } catch (e, st) {
      showMessage("Error in end Call $e, $st");
    }
  }
}
