import 'dart:io';

import 'package:flutter/widgets.dart';

import 'api_client.dart';

class ProfileClient {
  ProfileClient(this._apiClient);

  final ApiClient _apiClient;

  Future<dynamic> getUserProfile() => _apiClient.getUserProfile();

  Future<dynamic> updateUserProfile({
    required Map<String, dynamic> data,
    required BuildContext context,
    File? file,
  }) =>
      _apiClient.updateUserProfile(
        data: data,
        context: context,
        file: file,
      );

  Future<dynamic> getAllUser(
    String name,
    int page,
    int limit, {
    required BuildContext context,
    required List<String> contactNumbers,
  }) =>
      _apiClient.getAllUser(
        name,
        page,
        limit,
        context,
        contactNumbers,
      );

  Future<dynamic> syncContact(BuildContext context) =>
      _apiClient.syncContact(context);

  Future<dynamic> blockedUser({
    required String chatId,
    required String userId,
    required BuildContext context,
  }) =>
      _apiClient.blockedUser(
        chatId: chatId,
        userId: userId,
        context: context,
      );

  Future<dynamic> unBlockedUser({
    required String userId,
    required BuildContext context,
  }) =>
      _apiClient.unBlockedUser(
        userId: userId,
        context: context,
      );

  Future<dynamic> getAllBlockedUser({required BuildContext context}) =>
      _apiClient.getAllBlockedUser(context: context);

  Future<dynamic> nickNameSet({
    required String contactUserId,
    required String nickName,
  }) =>
      _apiClient.nickNameSet(
        contactUserId: contactUserId,
        nickName: nickName,
      );

  Future<dynamic> toggleNickName({
    required String contactUserId,
    required bool isActiveNickname,
  }) =>
      _apiClient.toggleNickName(
        contactUserId: contactUserId,
        isActiveNickname: isActiveNickname,
      );
}
