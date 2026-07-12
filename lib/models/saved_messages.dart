// To parse this JSON data, do
//
//     final getSavedMessagesResponse = getSavedMessagesResponseFromJson(jsonString);

import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:two_one_two_messenger/models/chat_message_model.dart';

// GetSavedMessagesResponse getSavedMessagesResponseFromJson(String str) =>
//     GetSavedMessagesResponse.fromJson(json.decode(str));

String getSavedMessagesResponseToJson(GetSavedMessagesResponse data) =>
    json.encode(data.toJson());

class GetSavedMessagesResponse {
  final int? status;
  final String? message;
  final SavedMessagesData? data;

  GetSavedMessagesResponse({
    this.status,
    this.message,
    this.data,
  });

  GetSavedMessagesResponse copyWith({
    int? status,
    String? message,
    SavedMessagesData? data,
  }) =>
      GetSavedMessagesResponse(
        status: status ?? this.status,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory GetSavedMessagesResponse.fromJson(
          Map<String, dynamic> json, String aesKey) =>
      GetSavedMessagesResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : SavedMessagesData.fromJson(json["data"], aesKey),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class SavedMessagesData extends Equatable {
  final List<SavedMessage>? savedMessages;
  final List<SavedMessage>? pinnedSavedMessages;
  final Pagination? pagination;

  const SavedMessagesData({
    this.savedMessages,
    this.pinnedSavedMessages,
    this.pagination,
  });

  SavedMessagesData copyWith({
    List<SavedMessage>? savedMessages,
    List<SavedMessage>? pinnedSavedMessages,
    Pagination? pagination,
  }) =>
      SavedMessagesData(
        savedMessages: savedMessages ?? this.savedMessages,
        pinnedSavedMessages: pinnedSavedMessages ?? this.pinnedSavedMessages,
        pagination: pagination ?? this.pagination,
      );

  factory SavedMessagesData.fromJson(
          Map<String, dynamic> json, String aesKey) =>
      SavedMessagesData(
        savedMessages: json["savedMessages"] == null
            ? []
            : List<SavedMessage>.from(json["savedMessages"]!
                .map((x) => SavedMessage.fromJson(x, aesKey))),
        pinnedSavedMessages: json["pinnedMessages"] == null
            ? []
            : List<SavedMessage>.from(json["pinnedMessages"]!
                .map((x) => SavedMessage.fromJson(x, aesKey))),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "savedMessages": savedMessages == null
            ? []
            : List<dynamic>.from(savedMessages!.map((x) => x.toJson())),
        "pinnedMessages": pinnedSavedMessages == null
            ? []
            : List<dynamic>.from(pinnedSavedMessages!.map((x) => x.toJson())),
        "pagination": pagination?.toJson(),
      };

  @override
  List<Object?> get props => [savedMessages, pinnedSavedMessages, pagination];
}

class Pagination extends Equatable {
  final int? total;
  final int? page;
  final int? limit;
  final int? totalPages;

  const Pagination({
    this.total,
    this.page,
    this.limit,
    this.totalPages,
  });

  Pagination copyWith({
    int? total,
    int? page,
    int? limit,
    int? totalPages,
  }) =>
      Pagination(
        total: total ?? this.total,
        page: page ?? this.page,
        limit: limit ?? this.limit,
        totalPages: totalPages ?? this.totalPages,
      );

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        total: json["total"],
        page: json["page"],
        limit: json["limit"],
        totalPages: json["totalPages"],
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "page": page,
        "limit": limit,
        "totalPages": totalPages,
      };

  @override

  List<Object?> get props => [total, page, limit, totalPages];
}

class SavedMessage extends Equatable {
  final String? id;
  final String? messageId;
  final MessageModel? messageDetails;
  final Sender? senderDetails;

  const SavedMessage({
    this.id,
    this.messageId,
    this.messageDetails,
    this.senderDetails,
  });

  SavedMessage copyWith({
    String? id,
    String? messageId,
    MessageModel? messageDetails,
    Sender? senderDetails,
  }) =>
      SavedMessage(
        id: id ?? this.id,
        messageId: messageId ?? this.messageId,
        messageDetails: messageDetails ?? this.messageDetails,
        senderDetails: senderDetails ?? this.senderDetails,
      );

  factory SavedMessage.fromJson(Map<String, dynamic> json, String aesKey) =>
      SavedMessage(
        id: json["_id"],
        messageId: json["messageId"],
        messageDetails: json["messageDetails"] == null
            ? null
            : MessageModel.fromJson(json["messageDetails"], aesKey),
        senderDetails: json["senderDetails"] == null
            ? null
            : Sender.fromJson(json["senderDetails"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "messageId": messageId,
        "messageDetails": messageDetails?.toJson(),
        "senderDetails": senderDetails?.toJson(),
      };

  @override

  List<Object?> get props => [id, messageId, messageDetails, senderDetails];
}

// class MessageDetails {
//     final String? chatId;
//     final String? content;
//     final String? type;
//     final List<dynamic>? fileIds;
//     final DateTime? createdAt;

//     MessageDetails({
//         this.chatId,
//         this.content,
//         this.type,
//         this.fileIds,
//         this.createdAt,
//     });

//     MessageDetails copyWith({
//         String? chatId,
//         String? content,
//         String? type,
//         List<dynamic>? fileIds,
//         DateTime? createdAt,
//     }) =>
//         MessageDetails(
//             chatId: chatId ?? this.chatId,
//             content: content ?? this.content,
//             type: type ?? this.type,
//             fileIds: fileIds ?? this.fileIds,
//             createdAt: createdAt ?? this.createdAt,
//         );

//     factory MessageDetails.fromJson(Map<String, dynamic> json) => MessageDetails(
//         chatId: json["chatId"],
//         content: json["content"],
//         type: json["type"],
//         fileIds: json["fileIds"] == null ? [] : List<dynamic>.from(json["fileIds"]!.map((x) => x)),
//         createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
//     );

//     Map<String, dynamic> toJson() => {
//         "chatId": chatId,
//         "content": content,
//         "type": type,
//         "fileIds": fileIds == null ? [] : List<dynamic>.from(fileIds!.map((x) => x)),
//         "createdAt": createdAt?.toIso8601String(),
//     };
// }

