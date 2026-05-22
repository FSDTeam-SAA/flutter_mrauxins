import 'dart:convert';

import 'package:two_one_two_messenger/GoogleAds/config_model.dart';

TokenAndChannelResponse tokenAndChannelResponseFromJson(String str) =>
    TokenAndChannelResponse.fromJson(json.decode(str));

String tokenAndChannelResponseToJson(TokenAndChannelResponse data) =>
    json.encode(data.toJson());

class TokenAndChannelResponse {
  final int? status;
  final String? message;
  final TokenAndChannel? data;

  TokenAndChannelResponse({
    this.status,
    this.message,
    this.data,
  });

  TokenAndChannelResponse copyWith({
    int? status,
    String? message,
    TokenAndChannel? data,
  }) =>
      TokenAndChannelResponse(
        status: status ?? this.status,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory TokenAndChannelResponse.fromJson(Map<String, dynamic> json) =>
      TokenAndChannelResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : TokenAndChannel.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class TokenAndChannel {
  final String? token;
  final String? channelName;
  final String? appId;
  final String? callId;

  TokenAndChannel({
    this.token,
    this.channelName,
    this.appId,
    this.callId,
  });

  TokenAndChannel copyWith({
    String? token,
    String? channelName,
    String? appId,
    String? callId,
  }) =>
      TokenAndChannel(
        token: token ?? this.token,
        channelName: channelName ?? this.channelName,
        appId: appId ?? this.appId,
        callId: callId ?? this.callId,
      );

  factory TokenAndChannel.fromJson(Map<String, dynamic> json) =>
      TokenAndChannel(
          token: json["token"],
          channelName: json["channelName"],
          appId: json["APP_ID"],
          callId: json["callId"]);

  Map<String, dynamic> toJson() => {
        "token": token,
        "channelName": channelName,
        "APP_ID": appId,
        "callId": callId
      };
}

class GetAgoraAppId {
  final int? status;
  final String? message;
  final AppId? data;

  GetAgoraAppId({
    this.status,
    this.message,
    this.data,
  });

  GetAgoraAppId copyWith({
    int? status,
    String? message,
    AppId? data,
  }) =>
      GetAgoraAppId(
        status: status ?? this.status,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory GetAgoraAppId.fromJson(Map<String, dynamic> json) => GetAgoraAppId(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : AppId.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class AppId {
  final String? appId;
  final ConfigModel? adsConfig;

  AppId({
    this.appId,
    this.adsConfig,
  });

  AppId copyWith({String? appId, ConfigModel? adsConfig}) =>
      AppId(appId: appId ?? this.appId, adsConfig: adsConfig ?? this.adsConfig);

  factory AppId.fromJson(Map<String, dynamic> json) => AppId(
      appId: json["APP_ID"],
      adsConfig: json["ads_config"] == null
          ? ConfigModel.fromJson(json = {
              "admob_appopen": "ca-app-pub-3940256099942544/9257395921",
              "admob_interstital": "ca-app-pub-3940256099942544/1033173712",
              "admob_interstital_reward":
                  "ca-app-pub-3940256099942544/5354046379",
              "admob_reward": "ca-app-pub-3940256099942544/5224354917",
              "admob_banner": "ca-app-pub-3940256099942544/6300978111",
              "admob_native": "ca-app-pub-3940256099942544/2247696110",
              "admanager_appopen": "/6499/example/app-open",
              "admanager_interstital": "/6499/example/interstitial",
              "admanager_interstital_reward":
                  "/21775744923/example/rewarded_interstitial",
              "admanager_reward": "/6499/example/rewarded",
              "admanager_banner": "/6499/example/banner",
              "admanager_native": "/6499/example/native",
              "ads_show": "on",
              "activity_show": "on",
              "ad_blocker": "off",
              "appopen": "on",
              "extra_activity": 4,
              "interstitial_extra_adcount": "2",
              "interstitial_count": "1",
              "interstitial_backcount": "1",
              "interstitial_start_screen_ad": "on",
              "appopen_type": "admob",
              "ad_appopen": [
                "admob",
              ],
              "ad_inter": [
                "admob",
              ],
              "ad_inter_reward": [
                "admob",
              ],
              "ad_native": [
                "admob",
              ],
              "ad_banner": [
                "admob",
              ],
              "ad_reward": [
                "admob",
              ]
            })
          : ConfigModel.fromJson(json["ads_config"]));

  Map<String, dynamic> toJson() => {
        "APP_ID": appId,
        "ads_config": adsConfig?.toJson(),
      };
}
