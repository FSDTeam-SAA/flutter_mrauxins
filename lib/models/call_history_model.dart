// To parse this JSON data, do
//
//     final callHistoryResponse = callHistoryResponseFromJson(jsonString);

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:two_one_two_messenger/models/chat_message_model.dart';
import 'package:two_one_two_messenger/models/conversation_model.dart';
import 'package:two_one_two_messenger/models/group_info_model.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

CallHistoryResponse callHistoryResponseFromJson(String str) =>
    CallHistoryResponse.fromJson(json.decode(str));

String callHistoryResponseToJson(CallHistoryResponse data) =>
    json.encode(data.toJson());

class CallHistoryResponse {
  final int? status;
  final String? message;
  final Data? data;

  CallHistoryResponse({
    this.status,
    this.message,
    this.data,
  });

  CallHistoryResponse copyWith({
    int? status,
    String? message,
    Data? data,
  }) =>
      CallHistoryResponse(
        status: status ?? this.status,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory CallHistoryResponse.fromJson(Map<String, dynamic> json) =>
      CallHistoryResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  final String? message;
  final List<CallHistoryList>? callHistoryList;
  final Pagination? pagination;

  Data({
    this.message,
    this.callHistoryList,
    this.pagination,
  });

  Data copyWith({
    String? message,
    List<CallHistoryList>? callHistoryList,
    Pagination? pagination,
  }) =>
      Data(
        message: message ?? this.message,
        callHistoryList: callHistoryList ?? this.callHistoryList,
        pagination: pagination ?? this.pagination,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        message: json["message"],
        callHistoryList: json["callHistoryList"] == null
            ? []
            : List<CallHistoryList>.from(json["callHistoryList"]!
                .map((x) => CallHistoryList.fromJson(x))),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "callHistoryList": callHistoryList == null
            ? []
            : List<dynamic>.from(callHistoryList!.map((x) => x.toJson())),
        "pagination": pagination?.toJson(),
      };
}

class CallHistoryList {
  final String? id;
  final ConversationData? chatInfo;
  final String? callId;
  final CallType? callType;
  final Sender? sender;
  final bool? isEnded;
  final String? status;
  final int? duration;
  final CallStatus? callDirection;
  final DateTime? createdAt;
  final GlobalKey globalKey;
  CallHistoryList({
    this.id,
    this.chatInfo,
    this.callId,
    this.callType,
    this.sender,
    this.isEnded,
    this.status,
    this.duration,
    this.callDirection,
    this.createdAt,
    GlobalKey? globalKey,
  }) : globalKey = globalKey ?? GlobalKey();

  CallHistoryList copyWith({
    String? id,
    ConversationData? chatInfo,
    String? callId,
    CallType? callType,
    Sender? sender,
    bool? isEnded,
    String? status,
    int? duration,
    CallStatus? callDirection,
    DateTime? createdAt,
  }) =>
      CallHistoryList(
        id: id ?? this.id,
        chatInfo: chatInfo ?? this.chatInfo,
        callId: callId ?? this.callId,
        callType: callType ?? this.callType,
        sender: sender ?? this.sender,
        isEnded: isEnded ?? this.isEnded,
        status: status ?? this.status,
        duration: duration ?? this.duration,
        callDirection: callDirection ?? this.callDirection,
        createdAt: createdAt ?? this.createdAt,
      );

  factory CallHistoryList.fromJson(Map<String, dynamic> json) {
    // log("CallHistoryList created At ${json["createdAt"]} sender ${json["sender"]}");
    return CallHistoryList(
      id: json["_id"],
      chatInfo: json["chatInfo"] == null
          ? null
          : ConversationData.fromJson(json["chatInfo"]),
      callId: json["callId"],
      callType: json["callType"] != null
          ? CallType.values.firstWhere(
              (element) => element.name == json["callType"],
            )
          : null,
      sender: json["sender"] == null ? null : Sender.fromJson(json["sender"]),
      isEnded: json["isEnded"],
      callDirection: json["callDirection"] != null
          ? CallStatus.values.firstWhere(
              (element) => element.name == json["callDirection"],
            )
          : null,
      duration: json["duration"],
      status: json["callStatus"],
      createdAt: json["createdAt"] == null
          ? null
          : DateTime.parse(json["createdAt"]).toLocal(),
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "chatInfo": chatInfo?.toJson(),
        "callId": callId,
        "callType": callType?.name,
        "sender": sender?.toJson(),
        "isEnded": isEnded,
        "callStatus": status,
        "duration": duration,
        "callDirection": callDirection?.name,
        "createdAt": createdAt?.toIso8601String(),
      };
}

// class ChatInfo {
//   final String? id;
//   final String? groupName;
//   final String? groupImage;

//   ChatInfo({
//     this.id,
//     this.groupName,
//     this.groupImage,
//   });

//   ChatInfo copyWith({
//     String? id,
//     String? groupName,
//     String? groupImage,
//   }) =>
//       ChatInfo(
//         id: id ?? this.id,
//         groupName: groupName ?? this.groupName,
//         groupImage: groupImage ?? this.groupImage,
//       );

//   factory ChatInfo.fromJson(Map<String, dynamic> json) => ChatInfo(
//         id: json["_id"],
//         groupName: json["groupName"],
//         groupImage: json["groupImage"],
//       );

//   Map<String, dynamic> toJson() => {
//         "_id": id,
//         "groupName": groupName,
//         "groupImage": groupImage,
//       };
// }

class Pagination {
  final int? totalPages;
  final int? currentPage;
  final int? limit;

  Pagination({
    this.totalPages,
    this.currentPage,
    this.limit,
  });

  Pagination copyWith({
    int? totalPages,
    int? currentPage,
    int? limit,
  }) =>
      Pagination(
        totalPages: totalPages ?? this.totalPages,
        currentPage: currentPage ?? this.currentPage,
        limit: limit ?? this.limit,
      );

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        totalPages: json["totalPages"],
        currentPage: json["currentPage"],
        limit: json["limit"],
      );

  Map<String, dynamic> toJson() => {
        "totalPages": totalPages,
        "currentPage": currentPage,
        "limit": limit,
      };
}
