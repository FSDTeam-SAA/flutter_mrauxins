import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:two_one_two_messenger/models/nick_name/nick_name_response.dart';
import 'package:two_one_two_messenger/models/toggle_nickname_response.dart';

import '../services/api_client.dart';
import '../utils/utils.dart';

class NicknameCubit extends Cubit<void> {
  final ApiClient apiClient;

  NicknameCubit(this.apiClient) : super(null);

  Future<void> setNickname({
    required BuildContext context,
    required String contactUserId,
    required String nickName,
    Function(SetNicknameResponse)? callback,
  }) async {
    try {
      if (contactUserId.isEmpty) {
        return;
      }
      Utils.showLoader();
      SetNicknameResponse response = await apiClient.nickNameSet(
        contactUserId: contactUserId,
        nickName: nickName,
      );
      if (response.status == Utils.APISUCCESS) {
        callback?.call(response);
      }
    } catch (e, st) {
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""),
          seconds: 3);
      showMessage("Error ==> $e $st");
    } finally {
      Utils.hideLoader();
    }
  }

  Future<void> toggleNickname({
    required BuildContext context,
    required String contactUserId,
    required bool isActiveNickname,
    Function(ToggleNickNameResponse)? callback,
  }) async {
    try {
      if (contactUserId.isEmpty) {
        return;
      }
      Utils.showLoader();
      ToggleNickNameResponse response = await apiClient.toggleNickName(
          contactUserId: contactUserId, isActiveNickname: isActiveNickname);
      if (response.status == Utils.APISUCCESS) {
        callback?.call(response);
      }
    } catch (e, st) {
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""));
      showMessage("Error ==> $e $st");
    } finally {
      Utils.hideLoader();
    }
  }
}
