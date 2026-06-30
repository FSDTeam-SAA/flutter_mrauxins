import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:two_one_two_messenger/models/chat_message_model.dart';
import 'package:two_one_two_messenger/services/encryption_service.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

class ConversationModel extends Equatable {
  int? status;
  String? message;
  List<ConversationData>? data;
  List<ConversationData>? archiveChats;

  ConversationModel({
    this.status,
    this.message,
    this.data,
    this.archiveChats,
  });
  ConversationModel copyWith({
    int? status,
    String? message,
    List<ConversationData>? data,
    List<ConversationData>? archiveChats,
  }) {
    return ConversationModel(
      status: status ?? this.status,
      message: message ?? this.message,
      data: data ?? this.data,
      archiveChats: archiveChats ?? this.archiveChats,
    );
  }

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      ConversationModel(
        status: json["status"],
        message: json["message"],
        data: json["data"]["chats"] == null ||
                (json["data"]["chats"] is! List) ||
                (json["data"]["chats"] as List).isEmpty
            ? []
            : List<ConversationData>.from(json["data"]["chats"]!
                .map((x) => ConversationData.fromJson(x))),
        archiveChats: json["data"]["archivedChats"] == null ||
                (json["data"]["archivedChats"] is! List) ||
                (json["data"]["archivedChats"] as List).isEmpty
            ? []
            : List<ConversationData>.from(json["data"]["archivedChats"]!
                .map((x) => ConversationData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "archivedChats": archiveChats == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };

  @override
  List<Object?> get props => [data, archiveChats];
}

class ConversationData extends Equatable {
  final String? id;
  final ChatType? type;
  final DateTime? createdAt;
  final List<ParticipantDetail>? participantDetails;
  final LastMessage? lastMessage;
  final int? unreadMessageCount;
  final bool? isProfilePhoto;
  final bool? isSendMessage;
  final bool? hideMembersInfo;
  final bool? hideNewMembersMessage;
  final bool? restrictContentSharing;
  final bool? isGroupProfilePhoto;
  final String? groupName;
  final String? groupImage;
  final String? privacy;
  final ParticipantDetail? createdBy;
  final String? inviteLink;
  final String? encryptedAESKey;
  bool? isPinned;
  // DateTime? pinnedAt;
  bool? isNotificationMute;
  bool? markMessageAsUnread;

  ConversationData({
    this.id,
    this.type,
    this.createdAt,
    this.participantDetails,
    this.lastMessage,
    this.unreadMessageCount,
    this.isProfilePhoto,
    this.isSendMessage,
    this.hideMembersInfo,
    this.hideNewMembersMessage,
    this.restrictContentSharing,
    this.isGroupProfilePhoto,
    this.groupName,
    this.groupImage,
    this.inviteLink,
    this.privacy,
    this.createdBy,
    this.encryptedAESKey,
    this.isPinned,

    // this.pinnedAt,
    this.isNotificationMute,
    this.markMessageAsUnread,
  });

  ConversationData copyWith({
    String? id,
    ChatType? type,
    DateTime? createdAt,
    List<ParticipantDetail>? participantDetails,
    LastMessage? lastMessage,
    int? unreadMessageCount,
    bool? isProfilePhoto,
    bool? isSendMessage,
    bool? hideMembersInfo,
    bool? hideNewMembersMessage,
    bool? restrictContentSharing,
    bool? isGroupProfilePhoto,
    String? groupName,
    String? groupImage,
    String? privacy,
    String? inviteLink,
    String? encryptedAESKey,
    ParticipantDetail? createdBy,
    bool? isPinned,
    // DateTime? pinnedAt,
    bool? isNotificationMute,
    bool? markMessageAsUnread,
  }) =>
      ConversationData(
        id: id ?? this.id,
        type: type ?? this.type,
        createdAt: createdAt ?? this.createdAt,
        participantDetails: participantDetails ?? this.participantDetails,
        lastMessage: lastMessage ?? this.lastMessage,
        unreadMessageCount: unreadMessageCount ?? this.unreadMessageCount,
        isProfilePhoto: isProfilePhoto ?? this.isProfilePhoto,
        isSendMessage: isSendMessage ?? this.isSendMessage,
        hideMembersInfo: hideMembersInfo ?? this.hideMembersInfo,
        hideNewMembersMessage:
            hideNewMembersMessage ?? this.hideNewMembersMessage,
        restrictContentSharing:
            restrictContentSharing ?? this.restrictContentSharing,
        isGroupProfilePhoto:
            isGroupProfilePhoto ?? this.isGroupProfilePhoto,
        groupName: groupName ?? this.groupName,
        groupImage: groupImage ?? this.groupImage,
        privacy: privacy ?? this.privacy,
        inviteLink: inviteLink ?? this.inviteLink,
        createdBy: createdBy ?? this.createdBy,
        encryptedAESKey: encryptedAESKey ?? this.encryptedAESKey,
        isPinned: isPinned ?? this.isPinned,
        // pinnedAt: pinnedAt ?? this.pinnedAt,
        isNotificationMute: isNotificationMute ?? this.isNotificationMute,
        markMessageAsUnread: markMessageAsUnread ?? this.markMessageAsUnread,
      );

  factory ConversationData.fromJson(Map<String, dynamic> json) {
    log("last message  ${json["unreadMessageCount"]}");
    return ConversationData(
      id: json["_id"],
      type: json["type"] != null
          ? ChatType.values.firstWhere(
              (element) => element.name == json["type"],
            )
          : ChatType.one_to_one,
      createdAt: json["createdAt"] == null
          ? null
          : DateTime.parse(json["createdAt"]).toLocal(),
      participantDetails: json["participantDetails"] == null
          ? []
          : List<ParticipantDetail>.from(json["participantDetails"]!
              .map((x) => ParticipantDetail.fromJson(x))),
      lastMessage: json["lastMessage"] == null
          ? null
          // : json["lastMessage"]["_id"] == null
          //     ? null
          : LastMessage.fromJson(json["lastMessage"], json["encryptedAESKey"]),
      unreadMessageCount: json["unreadMessageCount"],
      isProfilePhoto: json["isProfilePhoto"],
      isSendMessage: json["isSendMessage"],
      hideMembersInfo: json["hideMembersInfo"],
      hideNewMembersMessage: json["hideNewMembersMessage"],
      restrictContentSharing: json["restrictContentSharing"],
      isGroupProfilePhoto: json["isGroupProfilePhoto"],
      groupName: json["groupName"],
      groupImage: json["groupImage"],
      privacy: json["privacy"],
      inviteLink: json["inviteLink"],
      encryptedAESKey: json["encryptedAESKey"],
      createdBy: json["createdBy"] != null
          ? ParticipantDetail.fromJson(json["createdBy"])
          : null,
      isPinned: json["isPinned"],
      // pinnedAt:
      // json["pinnedAt"] == null ? null : DateTime.parse(json["pinnedAt"]),
      isNotificationMute: json['isNotificationMute'],
      markMessageAsUnread: json['markMessageAsUnread'],
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "type": type,
        "createdAt": createdAt?.toIso8601String(),
        "participantDetails": participantDetails == null
            ? []
            : List<dynamic>.from(participantDetails!.map((x) => x.toJson())),
        "lastMessage": lastMessage?.toJson(),
        "unreadMessageCount": unreadMessageCount,
        "isProfilePhoto": isProfilePhoto,
        "isSendMessage": isSendMessage,
        "hideMembersInfo": hideMembersInfo,
        "hideNewMembersMessage": hideNewMembersMessage,
        "restrictContentSharing": restrictContentSharing,
        "isGroupProfilePhoto": isGroupProfilePhoto,
        "groupName": groupName,
        "groupImage": groupImage,
        "privacy": privacy,
        "inviteLink": inviteLink,
        "encryptedAESKey": encryptedAESKey,
        "createdBy": createdBy?.toJson(),
        "isPinned": isPinned,
        // "pinnedAt": pinnedAt?.toIso8601String(),
        "isNotificationMute": isNotificationMute,
        "markMessageAsUnread": markMessageAsUnread,
      };
  @override
  List<Object?> get props => [
        id,
        type,
        createdAt,
        participantDetails,
        lastMessage,
        unreadMessageCount,
        groupName,
        groupImage,
        isProfilePhoto,
        isSendMessage,
        hideMembersInfo,
        hideNewMembersMessage,
        restrictContentSharing,
        isGroupProfilePhoto,
        inviteLink,
        encryptedAESKey,
        privacy,
        isPinned,
        // pinnedAt,
        isNotificationMute
      ];
}

class LastMessage {
  String? id;
  String? messageId;
  String? content;
  Sender? sender;
  DateTime? createdAt;
  final SystemMessage? systemMessage;
  LastMessage({
    this.id,
    this.content,
    this.sender,
    this.createdAt,
    this.messageId,
    this.systemMessage,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json, String aesKey) {
    String decryptedAESKey = "";
    String decryptedContent = "";
    if (aesKey.isEmpty || (json["content"] == null)) {
      decryptedContent = json["content"] ?? "";
    } else {
      final encryptionService = EncryptionHelper();
      // decryptedAESKey = encryptionService.decryptAESKey(
      //   aesKey,
      // );

      decryptedContent =
          encryptionService.decryptMessage(json['content'], aesKey);
    }
    return LastMessage(
      id: json["_id"],
      messageId: json["messageId"],
      content: decryptedContent,
      sender: json["sender"] == null ? null : Sender.fromJson(json["sender"]),
      systemMessage: json["systemMessage"] == null
          ? null
          : SystemMessage.fromJson(json["systemMessage"]),
      createdAt: json["createdAt"] == null
          ? null
          : DateTime.parse(json["createdAt"]).toLocal(),
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "content": content,
        "sender": sender?.toJson(),
        "createdAt": createdAt?.toIso8601String(),
        "messageId": messageId,
        "systemMessage": systemMessage?.toJson(),
      };
}

class ParticipantDetail {
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

  ParticipantDetail({
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

  factory ParticipantDetail.fromJson(Map<String, dynamic> json) =>
      ParticipantDetail(
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
