import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

import 'api_client.dart';

class AuthClient {
  AuthClient(this._apiClient);

  final ApiClient _apiClient;

  Future<dynamic> sendOtp(String email, BuildContext context) =>
      _apiClient.sendOtp(email, context);

  Future<dynamic> otpVerify(
    String text,
    String otp,
    String fcmToken,
    String countryISOCode,
    String countryCode,
    BuildContext context,
  ) =>
      _apiClient.otpVerify(
        text,
        otp,
        fcmToken,
        countryISOCode,
        countryCode,
        context,
      );

  Future<dynamic> socialLoginVerify({
    required String text,
    required SignInProvider provider,
    required String providerId,
    required String fcmToken,
    required BuildContext context,
    required String name,
    required String photoUrl,
    required String phone,
  }) =>
      _apiClient.socialLoginVerify(
        text: text,
        provider: provider,
        providerId: providerId,
        name: name,
        fcmToken: fcmToken,
        context: context,
        photoUrl: photoUrl,
        phone: phone,
      );

  Future<dynamic> refreshToken(
    Future<Response> Function() request,
    bool requiresToken,
  ) =>
      _apiClient.refreshToken(request, requiresToken);

  Future<dynamic> deleteToken(
    String userId,
    String token,
    BuildContext context,
  ) =>
      _apiClient.deleteToken(userId, token, context);
}
