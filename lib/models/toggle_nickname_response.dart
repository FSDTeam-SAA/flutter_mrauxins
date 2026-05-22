// To parse this JSON data, do
//
//     final toggleNickNameResponse = toggleNickNameResponseFromJson(jsonString);

import 'dart:convert';

ToggleNickNameResponse toggleNickNameResponseFromJson(String str) =>
    ToggleNickNameResponse.fromJson(json.decode(str));

String toggleNickNameResponseToJson(ToggleNickNameResponse data) =>
    json.encode(data.toJson());

class ToggleNickNameResponse {
  int? status;
  String? message;
  ToggleNickNameData? data;

  ToggleNickNameResponse({
    this.status,
    this.message,
    this.data,
  });

  ToggleNickNameResponse copyWith({
    int? status,
    String? message,
    ToggleNickNameData? data,
  }) =>
      ToggleNickNameResponse(
        status: status ?? this.status,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory ToggleNickNameResponse.fromJson(Map<String, dynamic> json) =>
      ToggleNickNameResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : ToggleNickNameData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class ToggleNickNameData {
  String? nickname;
  bool? isActiveNickname;
  String? id;
  String? name;
  String? email;
  String? userName;
  bool? isVerified;
  String? providerName;
  bool? isOnline;
  dynamic lastSeen;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? bio;
  String? countryIsoCode;
  String? countryCode;
  bool? isProfileSetUp;
  bool? isStopNotification;
  bool? isMuteNotification;
  String? profilePrivacy;
  bool? isEmailVerify;
  bool? isPhoneVerify;

  ToggleNickNameData({
    this.nickname,
    this.isActiveNickname,
    this.id,
    this.name,
    this.email,
    this.userName,
    this.isVerified,
    this.providerName,
    this.isOnline,
    this.lastSeen,
    this.createdAt,
    this.updatedAt,
    this.bio,
    this.countryIsoCode,
    this.countryCode,
    this.isProfileSetUp,
    this.isStopNotification,
    this.isMuteNotification,
    this.profilePrivacy,
    this.isEmailVerify,
    this.isPhoneVerify,
  });

  ToggleNickNameData copyWith({
    String? nickname,
    bool? isActiveNickname,
    String? id,
    String? name,
    String? email,
    String? userName,
    bool? isVerified,
    String? providerName,
    bool? isOnline,
    dynamic lastSeen,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? bio,
    String? countryIsoCode,
    String? countryCode,
    bool? isProfileSetUp,
    bool? isStopNotification,
    bool? isMuteNotification,
    String? profilePrivacy,
    bool? isEmailVerify,
    bool? isPhoneVerify,
  }) =>
      ToggleNickNameData(
        nickname: nickname ?? this.nickname,
        isActiveNickname: isActiveNickname ?? this.isActiveNickname,
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        userName: userName ?? this.userName,
        isVerified: isVerified ?? this.isVerified,
        providerName: providerName ?? this.providerName,
        isOnline: isOnline ?? this.isOnline,
        lastSeen: lastSeen ?? this.lastSeen,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        bio: bio ?? this.bio,
        countryIsoCode: countryIsoCode ?? this.countryIsoCode,
        countryCode: countryCode ?? this.countryCode,
        isProfileSetUp: isProfileSetUp ?? this.isProfileSetUp,
        isStopNotification: isStopNotification ?? this.isStopNotification,
        isMuteNotification: isMuteNotification ?? this.isMuteNotification,
        profilePrivacy: profilePrivacy ?? this.profilePrivacy,
        isEmailVerify: isEmailVerify ?? this.isEmailVerify,
        isPhoneVerify: isPhoneVerify ?? this.isPhoneVerify,
      );

  factory ToggleNickNameData.fromJson(Map<String, dynamic> json) =>
      ToggleNickNameData(
        nickname: json["nickname"],
        isActiveNickname: json["is_active_nickname"],
        id: json["_id"],
        name: json["name"],
        email: json["email"],
        userName: json["userName"],
        isVerified: json["isVerified"],
        providerName: json["providerName"],
        isOnline: json["isOnline"],
        lastSeen: json["lastSeen"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        bio: json["bio"],
        countryIsoCode: json["countryISOCode"],
        countryCode: json["countryCode"],
        isProfileSetUp: json["isProfileSetUp"],
        isStopNotification: json["isStopNotification"],
        isMuteNotification: json["isMuteNotification"],
        profilePrivacy: json["profilePrivacy"],
        isEmailVerify: json["isEmailVerify"],
        isPhoneVerify: json["isPhoneVerify"],
      );

  Map<String, dynamic> toJson() => {
        "nickname": nickname,
        "is_active_nickname": isActiveNickname,
        "_id": id,
        "name": name,
        "email": email,
        "userName": userName,
        "isVerified": isVerified,
        "providerName": providerName,
        "isOnline": isOnline,
        "lastSeen": lastSeen,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "bio": bio,
        "countryISOCode": countryIsoCode,
        "countryCode": countryCode,
        "isProfileSetUp": isProfileSetUp,
        "isStopNotification": isStopNotification,
        "isMuteNotification": isMuteNotification,
        "profilePrivacy": profilePrivacy,
        "isEmailVerify": isEmailVerify,
        "isPhoneVerify": isPhoneVerify,
      };
}
