import 'package:two_one_two_messenger/models/chat_message_model.dart';

class SentMessageModel {
  int? status;
  String? message;
  MessageModel? data;

  SentMessageModel({
    this.status,
    this.message,
    this.data,
  });

  factory SentMessageModel.fromJson(Map<String, dynamic> json, String aesKey) {
    // showMessage("SentMessageModel   $aesKey");
    return SentMessageModel(
      status: json["status"],
      message: json["message"],
      data: json["data"] == null
          ? null
          : MessageModel.fromJson(json["data"], aesKey),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class SentMessageData {
  String? userName;
  String? profilePicture;
  String? name;
  String? chatId;
  String? sender;
  String? content;
  String? type;
  List<dynamic>? fileIds;
  bool? isDeleted;
  List<dynamic>? deletedFor;
  bool? isRead;
  String? id;
  DateTime? createdAt;

  SentMessageData({
    this.userName,
    this.profilePicture,
    this.name,
    this.chatId,
    this.sender,
    this.content,
    this.type,
    this.fileIds,
    this.isDeleted,
    this.deletedFor,
    this.isRead,
    this.id,
    this.createdAt,
  });

  factory SentMessageData.fromJson(Map<String, dynamic> json) =>
      SentMessageData(
        userName: json["userName"],
        profilePicture: json["profilePicture"],
        name: json["name"],
        chatId: json["chatId"],
        sender: json["sender"],
        content: json["content"],
        type: json["type"],
        fileIds: json["fileIds"] == null
            ? []
            : List<dynamic>.from(json["fileIds"]!.map((x) => x)),
        isDeleted: json["isDeleted"],
        deletedFor: json["deletedFor"] == null
            ? []
            : List<dynamic>.from(json["deletedFor"]!.map((x) => x)),
        isRead: json["isRead"],
        id: json["_id"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]).toLocal(),
      );

  Map<String, dynamic> toJson() => {
        "userName": userName,
        "profilePicture": profilePicture,
        "name": name,
        "chatId": chatId,
        "sender": sender,
        "content": content,
        "type": type,
        "fileIds":
            fileIds == null ? [] : List<dynamic>.from(fileIds!.map((x) => x)),
        "isDeleted": isDeleted,
        "deletedFor": deletedFor == null
            ? []
            : List<dynamic>.from(deletedFor!.map((x) => x)),
        "isRead": isRead,
        "_id": id,
        "createdAt": createdAt?.toIso8601String(),
      };
}
