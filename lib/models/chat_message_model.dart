import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:two_one_two_messenger/models/saved_messages.dart';
import 'package:two_one_two_messenger/services/encryption_service.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

class ChatMessageModelResponse {
  final int? status;
  final String? message;
  final ChatMessageModel? data;

  ChatMessageModelResponse({
    this.status,
    this.message,
    this.data,
  });

  ChatMessageModelResponse copyWith({
    int? status,
    String? message,
    ChatMessageModel? data,
  }) =>
      ChatMessageModelResponse(
        status: status ?? this.status,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory ChatMessageModelResponse.fromJson(
          Map<String, dynamic> json, String aesKey) =>
      ChatMessageModelResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : ChatMessageModel.fromJson(json["data"], aesKey),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class ChatMessageModel extends Equatable {
  final Set<MessageModel>? messages;
  final Set<MessageModel>? pinnedMessages;
  final DateTime? lastSeen;
  final bool? isOnline;
  final bool? isBlocked;
  final bool? youBlocked;
  final bool? removeFromChat;
  final bool? otherUserRemoveFromChat;
  final Pagination? pagination;

  const ChatMessageModel({
    this.messages,
    this.pinnedMessages,
    this.lastSeen,
    this.isOnline,
    this.isBlocked,
    this.youBlocked,
    this.removeFromChat,
    this.otherUserRemoveFromChat,
    this.pagination,
  });

  ChatMessageModel copyWith({
    Set<MessageModel>? messages,
    Set<MessageModel>? pinnedMessages,
    DateTime? lastSeen,
    bool? isOnline,
    bool? isBlocked,
    bool? youBlocked,
    bool? removeFromChat,
    bool? otherUserRemoveFromChat,
    Pagination? pagination,
  }) =>
      ChatMessageModel(
        messages: messages ?? this.messages,
        pinnedMessages: pinnedMessages ?? this.pinnedMessages,
        lastSeen: lastSeen ?? this.lastSeen,
        isOnline: isOnline ?? this.isOnline,
        isBlocked: isBlocked ?? this.isBlocked,
        youBlocked: youBlocked ?? this.youBlocked,
        removeFromChat: removeFromChat ?? this.removeFromChat,
        otherUserRemoveFromChat:
            otherUserRemoveFromChat ?? this.otherUserRemoveFromChat,
        pagination: pagination ?? this.pagination,
      );

  factory ChatMessageModel.fromJson(Map<String, dynamic> json, String aesKey) {
    print("ChatMessageModel==> ${json["otherUserRemoveFromChat"]}");
    return ChatMessageModel(
      messages: json["messages"] == null
          ? Set.of([])
          : Set<MessageModel>.from(
              json["messages"]!.map((x) => MessageModel.fromJson(x, aesKey))),
      pinnedMessages: json["pinnedMessages"] == null
          ? Set.of([])
          : Set<MessageModel>.from(json["pinnedMessages"]!
              .map((x) => MessageModel.fromJson(x, aesKey))),
      lastSeen: json["lastSeen"] == null
          ? null
          : DateTime.parse(json["lastSeen"]).toLocal(),
      isOnline: json["isOnline"] ?? false,
      isBlocked: json["isBlocked"] ?? false,
      youBlocked: json["youBlocked"] ?? false,
      removeFromChat: json["removeFromChat"] ?? false,
      otherUserRemoveFromChat: json["otherUserRemoveFromChat"] ?? false,
      pagination: json["pagination"] == null
          ? null
          : Pagination.fromJson(json["pagination"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "messages": messages == null
            ? []
            : List<dynamic>.from(messages!.map((x) => x.toJson())),
        "pinnedMessages": pinnedMessages == null
            ? []
            : List<dynamic>.from(pinnedMessages!.map((x) => x.toJson())),
        "lastSeen": lastSeen?.toIso8601String(),
        "isOnline": isOnline,
        "isBlocked": isBlocked,
        "youBlocked": youBlocked,
        "removeFromChat": removeFromChat,
        "otherUserRemoveFromChat": otherUserRemoveFromChat,
        "pagination": pagination?.toJson(),
      };

  @override
  List<Object?> get props => [
        isOnline,
        lastSeen,
        messages,
        isBlocked,
        youBlocked,
        pinnedMessages,
        removeFromChat,
        pagination,
        otherUserRemoveFromChat,
      ];
}

String messageModelToJson(MessageModel data) => json.encode(data.toJson());

class MessageModel extends Equatable {
  final String? chatId;
  final Sender? sender;
  final String? content;
  final String? type;
  final bool? isDeleted;
  final List<String>? deletedFor;
  final List<String>? reactions;
  final bool? isRead;
  final bool? isSent;
  final bool? forwarded;
  final bool? isEditedMessage;
  final bool? pinned;
  final String? id;
  final String? messageId;
  final int? disAppearingMessages;
  final DateTime? createdAt;
  final List<String>? fileIds;
  final List<FileElement>? files;
  final MessageModel? replyTo;
  final GlobalKey key;
  final SystemMessage? systemMessage;
  final double? uploadProgress;
  final String? localPath;
  final MessageUploadStatus? uploadStatus;

  MessageModel({
    this.chatId,
    this.sender,
    this.content,
    this.type,
    this.isDeleted,
    this.deletedFor,
    this.isRead,
    this.isSent,
    this.uploadProgress,
    this.forwarded,
    this.isEditedMessage,
    this.pinned,
    this.id,
    this.messageId,
    this.createdAt,
    this.fileIds,
    this.files,
    this.disAppearingMessages,
    this.replyTo,
    this.reactions,
    this.systemMessage,
    this.localPath,
    this.uploadStatus,
  }) : key = GlobalKey(); // Initialize GlobalKey;

  MessageModel copyWith(
          {String? chatId,
          Sender? sender,
          String? content,
          String? localPath,
          String? type,
          bool? isDeleted,
          bool? forwarded,
          bool? isEditedMessage,
          List<String>? deletedFor,
          bool? isRead,
          bool? isSent,
          bool? pinned,
          String? id,
          int? disAppearingMessages,
          String? messageId,
          DateTime? createdAt,
          List<String>? fileIds,
          List<String>? reactions,
          List<FileElement>? files,
          MessageModel? replyTo,
          SystemMessage? systemMessage,
          double? uploadProgress,
          MessageUploadStatus? uploadStatus,
          bool? resetReplyTo}) =>
      MessageModel(
        chatId: chatId ?? this.chatId,
        sender: sender ?? this.sender,
        content: content ?? this.content,
        localPath: localPath ?? this.localPath,
        type: type ?? this.type,
        isDeleted: isDeleted ?? this.isDeleted,
        deletedFor: deletedFor ?? this.deletedFor,
        isRead: isRead ?? this.isRead,
        isSent: isSent ?? this.isSent,
        uploadProgress: uploadProgress ?? this.uploadProgress,
        forwarded: forwarded ?? this.forwarded,
        isEditedMessage: isEditedMessage ?? this.isEditedMessage,
        pinned: pinned ?? this.pinned,
        id: id ?? this.id,
        disAppearingMessages: disAppearingMessages ?? this.disAppearingMessages,
        messageId: messageId ?? this.messageId,
        createdAt: createdAt ?? this.createdAt,
        fileIds: fileIds ?? this.fileIds,
        files: files ?? this.files,
        reactions: reactions ?? this.reactions,
        systemMessage: systemMessage ?? this.systemMessage,
        uploadStatus: uploadStatus ?? this.uploadStatus,
        replyTo: (resetReplyTo ?? false) ? replyTo : replyTo ?? this.replyTo,
      );

  factory MessageModel.fromJson(Map<String, dynamic> json, String aesKey) {
    showMessage("messageId replyTo Type ${json["replyTo"].runtimeType}}");
    showMessage("messageId systemMessage Type ${json["systemMessage"].runtimeType}}");
    showMessage("messageId systemMessage Message ${json["systemMessage"]}}");
    // String decryptedAESKey = "";
    String decryptedContent = "";
    if (aesKey.isEmpty) {
      decryptedContent = json["content"] ?? "";
    } else if (((json["content"] as String?) ?? "").isNotEmpty) {
      final encryptionService = EncryptionHelper();

      // decryptedAESKey = encryptionService.decryptAESKey(
      //   aesKey,
      // );

      decryptedContent =
          encryptionService.decryptMessage(json['content'], aesKey);

      // showMessage(
      //     "SentMessageModel in message ${json['content']} == $decryptedContent");
    }
    // print("SentMessageModel in message ${json["upload_status"]}");
    showMessage(
        "messageId XYX in messageId ${json["messageId"]} _IDD ${json["_id"]}");

    return MessageModel(
      chatId: json["chatId"],
      sender: json["sender"] == null ? null : Sender.fromJson(json["sender"]),
      content: decryptedContent,
      type: json["type"],
      uploadProgress: json["uploadProgress"],
      disAppearingMessages: json["disAppearingMessages"],
      isDeleted: json["isDeleted"],
      deletedFor: json["deletedFor"] == null
          ? []
          : List<String>.from(json["deletedFor"]!.map((x) => x)),
      isRead: json["isRead"],
      isSent: json["isSent"] ?? true,
      forwarded: json["forwarded"],
      isEditedMessage: json["isEditedMessage"],
      pinned: json["pinned"],
      id: json["_id"],
      messageId: json["messageId"],
      createdAt: json["createdAt"] == null
          ? null
          : DateTime.parse(json["createdAt"]).toLocal(),
      fileIds: json["fileIds"] == null
          ? []
          : List<String>.from(json["fileIds"]!.map((x) => x)),
      reactions: json["reactOnMessage"] == null
          ? []
          : List<String>.from(json["reactOnMessage"]!.map((x) => x)),
      // reactions: json["reactions"] == null
      //     ? []
      //     : List<String>.from(json["reactions"]!.map((x) => x)),
      files: json["files"] == null
          ? []
          : List<FileElement>.from(
              json["files"]!.map((x) => FileElement.fromJson(x))),
      replyTo: json["replyTo"] == null
          ? null
          : MessageModel.fromJson(json["replyTo"], aesKey),
      systemMessage: json["systemMessage"] == null
          ? null
          : SystemMessage.fromJson(json["systemMessage"]),
      localPath: json["local_path"],
      uploadStatus: MessageUploadStatus.values.firstWhere(
        (element) => element.name == json["upload_status"],
        orElse: () => MessageUploadStatus.sent,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        "chatId": chatId,
        "sender": sender?.toJson(),
        "content": content,
        "type": type,
        "disAppearingMessages": disAppearingMessages,
        "isDeleted": isDeleted,
        "uploadProgress": uploadProgress,
        "deletedFor": deletedFor == null
            ? []
            : List<dynamic>.from(deletedFor!.map((x) => x)),
        "reactions": reactions == null
            ? []
            : List<dynamic>.from(reactions!.map((x) => x)),
        "isRead": isRead,
        "isSent": isSent,
        "messageId": messageId,
        "forwarded": forwarded,
        "isEditedMessage": isEditedMessage,
        "pinned": pinned,
        "_id": id,
        "createdAt": createdAt?.toIso8601String(),
        "replyTo": replyTo?.toJson(),
        "systemMessage": systemMessage?.toJson(),
        "fileIds":
            fileIds == null ? [] : List<dynamic>.from(fileIds!.map((x) => x)),
        "files": files == null
            ? []
            : List<dynamic>.from(files!.map((x) => x.toJson())),
        "local_path": localPath,
        "upload_status": uploadStatus?.name,
      };

  @override
  List<Object?> get props => [
        id,
        chatId,
        reactions,
        content,
        isRead,
        messageId,
        createdAt,
        isDeleted,
        disAppearingMessages,
        replyTo,
        systemMessage,
        pinned,
        forwarded,
        isEditedMessage,
        isSent,
        uploadProgress,
        uploadStatus,
        localPath
      ];
}

class FileElement {
  final String? url;
  final String? fileName;
  final int? fileSize;
  final String? mimeType;
  final String? localPath;
  final String? id;
  final XFile? file;

  FileElement(
      {this.url,
      this.fileName,
      this.fileSize,
      this.localPath,
      this.mimeType,
      this.id,
      this.file});

  FileElement copyWith({
    String? url,
    String? fileName,
    int? fileSize,
    String? mimeType,
    String? localPath,
    String? id,
    XFile? file,
  }) =>
      FileElement(
        url: url ?? this.url,
        fileName: fileName ?? this.fileName,
        fileSize: fileSize ?? this.fileSize,
        localPath: localPath ?? this.localPath,
        mimeType: mimeType ?? this.mimeType,
        id: id ?? this.id,
        file: file,
      );

  factory FileElement.fromJson(Map<String, dynamic> json) => FileElement(
        url: json["url"],
        fileName: json["fileName"],
        fileSize: json["fileSize"],
        mimeType: json["mimeType"],
        localPath: json["localPath"],
        id: json["_id"],
        file: json["file"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "fileName": fileName,
        "fileSize": fileSize,
        "localPath": localPath,
        "mimeType": mimeType,
        "_id": id,
        "file": file,
      };
  Map<String, dynamic> toDbJson() => {
        "url": url,
        "fileName": fileName,
        "fileSize": fileSize,
        "localPath": localPath,
        "mimeType": mimeType,
        "_id": id,
        // "file": file,
      };
}

class Sender {
  String? id;
  String? userName;
  String? name;
  String? profilePicture;
  String? lastSeen;
  String? bio;
  String? email;
  bool? isOnline;
  String? countryISOCode;
  String? countryCode;
  String? profilePrivacy;
  String? nickName;
  bool? isActiveNickname;
  Sender({
    this.id,
    this.userName,
    this.name,
    this.profilePicture,
    this.lastSeen,
    this.bio,
    this.email,
    this.isOnline,
    this.countryISOCode,
    this.countryCode,
    this.profilePrivacy,
    this.nickName,
    this.isActiveNickname,
  });

  factory Sender.fromJson(Map<String, dynamic> json) => Sender(
        id: json["_id"],
        userName: json["userName"],
        name: json["name"],
        profilePicture: json["profilePicture"],
        lastSeen: json['lastSeen'],
        bio: json['bio'],
        email: json['email'],
        isOnline: json['isOnline'],
        countryISOCode: json['countryISOCode'],
        countryCode: json['countryCode'],
        profilePrivacy: json['profilePrivacy'],
        nickName: json["nickName"],
        isActiveNickname: json["isActiveNickname"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userName": userName,
        "name": name,
        "profilePicture": profilePicture,
        "lastSeen": lastSeen,
        "bio": bio,
        "email": email,
        "isOnline": isOnline,
        "countryISOCode": countryISOCode,
        "countryCode": countryCode,
        "profilePrivacy": profilePrivacy,
        "nickName": nickName,
        "isActiveNickname": isActiveNickname,
      };
}

// Delete/Clear Chat Message Response
class CommonMessageResponse {
  int? status;
  String? message;

  CommonMessageResponse({this.status, this.message});

  CommonMessageResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}

class TypingModel extends Equatable {
  final String? chatType;
  final String? chatId;
  final Sender? sender;
  final bool? isTyping;

  const TypingModel({
    this.chatType,
    this.chatId,
    this.sender,
    this.isTyping,
  });

  TypingModel copyWith({
    String? chatType,
    String? chatId,
    Sender? sender,
    bool? isTypeing,
  }) =>
      TypingModel(
        chatType: chatType ?? this.chatType,
        chatId: chatId ?? this.chatId,
        sender: sender ?? this.sender,
        isTyping: isTypeing ?? this.isTyping,
      );

  factory TypingModel.fromJson(Map<String, dynamic> json) => TypingModel(
        chatType: json["chatType"],
        chatId: json["chatId"],
        sender: json["sender"] != null ? Sender.fromJson(json["sender"]) : null,
        isTyping: json["isTyping"],
      );

  Map<String, dynamic> toJson() => {
        "chatType": chatType,
        "chatId": chatId,
        "sender": sender?.toJson(),
        "isTyping": isTyping,
      };

  @override
  List<Object?> get props => [chatId, sender, isTyping, chatType];
}

SystemMessage systemMessageFromJson(String str) =>
    SystemMessage.fromJson(json.decode(str));

String systemMessageToJson(SystemMessage data) => json.encode(data.toJson());

class SystemMessage {
  final String name;
  final String phone;
  final String profilePicture;
  final String userId;
  final String message;

  SystemMessage({
    required this.name,
    required this.phone,
    required this.profilePicture,
    required this.userId,
    required this.message,
  });

  SystemMessage copyWith({
    String? name,
    String? phone,
    String? profilePicture,
    String? userId,
    String? message,
  }) =>
      SystemMessage(
        name: name ?? this.name,
        phone: phone ?? this.phone,
        profilePicture: profilePicture ?? this.profilePicture,
        userId: userId ?? this.userId,
        message: message ?? this.message,
      );

  factory SystemMessage.fromJson(Map<String, dynamic> json) => SystemMessage(
        name: json["name"] ?? "",
        phone: json["phone"] ?? "",
        profilePicture: json["profilePicture"] ?? "",
        userId: json["_id"] ?? "",
        message: json["message"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "phone": phone,
        "profilePicture": profilePicture,
        "_id": userId,
        "message": message,
      };
}

enum MessageUploadStatus { pending, uploading, sent, failed }
