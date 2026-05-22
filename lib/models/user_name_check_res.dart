// To parse this JSON data, do
//
//     final userNameCheckRes = userNameCheckResFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

UserNameCheckRes userNameCheckResFromJson(String str) =>
    UserNameCheckRes.fromJson(json.decode(str));

String userNameCheckResToJson(UserNameCheckRes data) =>
    json.encode(data.toJson());

class UserNameCheckRes {
  final int status;
  final String message;
  final Data data;

  UserNameCheckRes({
    required this.status,
    required this.message,
    required this.data,
  });

  UserNameCheckRes copyWith({
    int? status,
    String? message,
    Data? data,
  }) =>
      UserNameCheckRes(
        status: status ?? this.status,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory UserNameCheckRes.fromJson(Map<String, dynamic> json) =>
      UserNameCheckRes(
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class Data {
  final String message;
  final bool isExist;

  Data({
    required this.message,
    required this.isExist,
  });

  Data copyWith({
    String? message,
    bool? isExist,
  }) =>
      Data(
        message: message ?? this.message,
        isExist: isExist ?? this.isExist,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        message: json["message"],
        isExist: json["isExist"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "isExist": isExist,
      };
}
