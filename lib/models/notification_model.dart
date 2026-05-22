// To parse this JSON data, do
//
//     final notificationsResponse = notificationsResponseFromJson(jsonString);

import 'dart:convert';

import 'package:two_one_two_messenger/models/chat_message_model.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

NotificationsResponse notificationsResponseFromJson(String str) =>
    NotificationsResponse.fromJson(json.decode(str));

String notificationsResponseToJson(NotificationsResponse data) =>
    json.encode(data.toJson());

class NotificationsResponse {
  final int? status;
  final String? message;
  final Data? data;

  NotificationsResponse({
    this.status,
    this.message,
    this.data,
  });

  NotificationsResponse copyWith({
    int? status,
    String? message,
    Data? data,
  }) =>
      NotificationsResponse(
        status: status ?? this.status,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) =>
      NotificationsResponse(
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
  final List<NotificationData>? notifications;
  final int? notificatinCount;
  final Pagination? pagination;

  Data({
    this.message,
    this.notifications,
    this.notificatinCount,
    this.pagination,
  });

  Data copyWith({
    String? message,
    List<NotificationData>? notifications,
    int? notificatinCount,
    Pagination? pagination,
  }) =>
      Data(
        message: message ?? this.message,
        notifications: notifications ?? this.notifications,
        notificatinCount: notificatinCount ?? this.notificatinCount,
        pagination: pagination ?? this.pagination,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        message: json["message"],
        notifications: json["notifications"] == null
            ? []
            : List<NotificationData>.from(json["notifications"]!
                .map((x) => NotificationData.fromJson(x))),
        notificatinCount: json["notificatinCount"],
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "notifications": notifications == null
            ? []
            : List<dynamic>.from(notifications!.map((x) => x.toJson())),
        "notificatinCount": notificatinCount,
        "pagination": pagination?.toJson(),
      };
}

class NotificationData {
  final String? id;
  final String? receiverId;
  final NotificationType? type;
  final bool? isRead;
  final DateTime? createdAt;
  final int? v;
  final Sender? sender;
  final GroupInfo? groupInfo;
  final String? content;
  NotificationData({
    this.id,
    this.receiverId,
    this.type,
    this.isRead,
    this.createdAt,
    this.content,
    this.v,
    this.sender,
    this.groupInfo,
  });

  /// **CopyWith for immutability**
  NotificationData copyWith({
    String? id,
    String? receiverId,
    NotificationType? type,
    bool? isRead,
    DateTime? createdAt,
    int? v,
    String? content,
    Sender? sender,
    GroupInfo? groupInfo,
  }) {
    return NotificationData(
      id: id ?? this.id,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      v: v ?? this.v,
      sender: sender ?? this.sender,
      groupInfo: groupInfo ?? this.groupInfo,
    );
  }

  /// **Factory Method for JSON Parsing**
  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json["_id"],
      receiverId: json["receiverId"],
      type: _parseNotificationType(json["type"]),
      isRead: json["isRead"],
      content: json["content"],
      createdAt: json["createdAt"] == null
          ? null
          : DateTime.parse(json["createdAt"]).toLocal(),
      v: json["__v"],
      sender: json["sender"] == null ? null : Sender.fromJson(json["sender"]),
      groupInfo: json["groupInfo"] == null
          ? null
          : GroupInfo.fromJson(json["groupInfo"]),
    );
  }

  /// **Convert Object to JSON**
  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "receiverId": receiverId,
      "type": type?.name, // Convert enum to string
      "isRead": isRead,
      "createdAt": createdAt?.toIso8601String(),
      "__v": v,
      "sender": sender?.toJson(),
      "groupInfo": groupInfo?.toJson(),
      "content": content,
    };
  }

  /// **Helper Function to Parse `NotificationType` Enum Safely**
  static NotificationType? _parseNotificationType(String? type) {
    if (type == null) return null;
    return NotificationType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => NotificationType.other, // Default case
    );
  }
}

class GroupInfo {
  final String? id;
  final String? groupName;
  final String? groupImage;

  GroupInfo({
    this.id,
    this.groupName,
    this.groupImage,
  });

  GroupInfo copyWith({
    String? id,
    String? groupName,
    String? groupImage,
  }) =>
      GroupInfo(
        id: id ?? this.id,
        groupName: groupName ?? this.groupName,
        groupImage: groupImage ?? this.groupImage,
      );

  factory GroupInfo.fromJson(Map<String, dynamic> json) => GroupInfo(
        id: json["_id"],
        groupName: json["groupName"],
        groupImage: json["groupImage"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "groupName": groupName,
        "groupImage": groupImage,
      };
}

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
