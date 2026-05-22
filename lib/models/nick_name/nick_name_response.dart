// To parse this JSON data, do
//
//     final setNicknameResponse = setNicknameResponseFromJson(jsonString);

import 'dart:convert';

SetNicknameResponse setNicknameResponseFromJson(String str) =>
    SetNicknameResponse.fromJson(json.decode(str));

String setNicknameResponseToJson(SetNicknameResponse data) =>
    json.encode(data.toJson());

class SetNicknameResponse {
  int? status;
  Message? message;

  SetNicknameResponse({
    this.status,
    this.message,
  });

  factory SetNicknameResponse.fromJson(Map<String, dynamic> json) =>
      SetNicknameResponse(
        status: json["status"],
        message:
            json["message"] == null ? null : Message.fromJson(json["message"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message?.toJson(),
      };
}

class Message {
  String? nickName;
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
  bool? isActiveNickname;

  Message({
    this.nickName,
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
    this.isActiveNickname,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        nickName: json["nickName"],
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
        isActiveNickname: json["isActiveNickname"],
      );

  Map<String, dynamic> toJson() => {
        "nickName": nickName,
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
        "isActiveNickname": isActiveNickname
      };
}
