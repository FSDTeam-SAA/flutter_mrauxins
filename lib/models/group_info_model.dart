// To parse this JSON data, do
//
//     final groupResponseModel = groupResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:equatable/equatable.dart';

GroupResponseModel groupResponseModelFromJson(String str) =>
    GroupResponseModel.fromJson(json.decode(str));

String groupResponseModelToJson(GroupResponseModel data) =>
    json.encode(data.toJson());

class GroupResponseModel {
  final int? status;
  final String? message;
  final GroupData? groupData;

  GroupResponseModel({
    this.status,
    this.message,
    this.groupData,
  });

  GroupResponseModel copyWith({
    int? status,
    String? message,
    GroupData? groupData,
  }) =>
      GroupResponseModel(
        status: status ?? this.status,
        message: message ?? this.message,
        groupData: groupData ?? this.groupData,
      );

  factory GroupResponseModel.fromJson(Map<String, dynamic> json) =>
      GroupResponseModel(
        status: json["status"],
        message: json["message"],
        groupData:
            json["data"] == null ? null : GroupData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": groupData?.toJson(),
      };
}

class GroupData extends Equatable {
  final String? groupId;
  final String? groupName;
  final bool? isAdmin;
  final String? groupImage;
  final DateTime? createdAt;
  final List<Participant>? participants;
  final List<Participant>? admins;
  final bool? isProfilePhoto;
  final bool? isSendMessage;
  final bool? hideMembersInfo;
  final bool? hideNewMembersMessage;
  final bool? restrictContentSharing;
  final bool? isGroupProfilePhoto;
  final bool? isCreatedBy;
//  final String? createdBy;
  final String? privacy;
  final String? inviteLink;
  final int? participantCount;
  const GroupData({
    this.groupId,
    this.groupName,
    this.isAdmin,
    this.groupImage,
    this.createdAt,
    this.participants,
    this.admins,
    this.isProfilePhoto,
    this.isSendMessage,
    this.hideMembersInfo,
    this.hideNewMembersMessage,
    this.restrictContentSharing,
    this.isGroupProfilePhoto,
    this.isCreatedBy,
    this.inviteLink,
    this.privacy,
    this.participantCount,
  });

  GroupData copyWith({
    String? groupId,
    String? groupName,
    bool? isAdmin,
    String? groupImage,
    DateTime? createdAt,
    List<Participant>? participants,
    List<Participant>? admins,
    bool? isProfilePhoto,
    bool? isSendMessage,
    bool? hideMembersInfo,
    bool? hideNewMembersMessage,
    bool? restrictContentSharing,
    bool? isGroupProfilePhoto,
    bool? isCreatedBy,
    String? privacy,
    String? inviteLink,
    int? participantCount,
  }) =>
      GroupData(
          groupId: groupId ?? this.groupId,
          groupName: groupName ?? this.groupName,
          isAdmin: isAdmin ?? this.isAdmin,
          groupImage: groupImage ?? this.groupImage,
          createdAt: createdAt ?? this.createdAt,
          participants: participants ?? this.participants,
          admins: admins ?? this.admins,
          isProfilePhoto: isProfilePhoto ?? this.isProfilePhoto,
          isSendMessage: isSendMessage ?? this.isSendMessage,
          hideMembersInfo: hideMembersInfo ?? this.hideMembersInfo,
          hideNewMembersMessage:
              hideNewMembersMessage ?? this.hideNewMembersMessage,
          restrictContentSharing:
              restrictContentSharing ?? this.restrictContentSharing,
          isGroupProfilePhoto:
              isGroupProfilePhoto ?? this.isGroupProfilePhoto,
          isCreatedBy: isCreatedBy ?? this.isCreatedBy,
          privacy: privacy ?? this.privacy,
          inviteLink: inviteLink ?? this.inviteLink,
          participantCount: participantCount ?? this.participantCount);

  factory GroupData.fromJson(Map<String, dynamic> json) => GroupData(
        groupId: json["groupId"],
        groupName: json["groupName"],
        isAdmin: json["isAdmin"],
        groupImage: json["groupImage"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]).toLocal(),
        participants: json["participants"] == null
            ? []
            : List<Participant>.from(
                json["participants"]!.map((x) => Participant.fromJson(x))),
        admins: json["admins"] == null
            ? []
            : List<Participant>.from(
                json["admins"]!.map((x) => Participant.fromJson(x))),
        isProfilePhoto: json["isProfilePhoto"],
        isSendMessage: json["isSendMessage"],
        hideMembersInfo: json["hideMembersInfo"],
        hideNewMembersMessage: json["hideNewMembersMessage"],
        restrictContentSharing: json["restrictContentSharing"],
        isGroupProfilePhoto: json["isGroupProfilePhoto"],
        isCreatedBy: json["isCreatedBy"],
        privacy: json["privacy"],
        inviteLink: json["inviteLink"],
        participantCount: json["participantCount"],
      );

  Map<String, dynamic> toJson() => {
        "groupId": groupId,
        "groupName": groupName,
        "isAdmin": isAdmin,
        "groupImage": groupImage,
        "createdAt": createdAt?.toIso8601String(),
        "participants": participants == null
            ? []
            : List<dynamic>.from(participants!.map((x) => x.toJson())),
        "admins": admins == null
            ? []
            : List<dynamic>.from(admins!.map((x) => x.toJson())),
        "isProfilePhoto": isProfilePhoto,
        "isSendMessage": isSendMessage,
        "hideMembersInfo": hideMembersInfo,
        "hideNewMembersMessage": hideNewMembersMessage,
        "restrictContentSharing": restrictContentSharing,
        "isGroupProfilePhoto": isGroupProfilePhoto,
        "isCreatedBy": isCreatedBy,
        "privacy": privacy,
        "inviteLink": inviteLink
      };
  @override
  List<Object?> get props => [
        groupId,
        isAdmin,
        groupImage,
        groupName,
        createdAt,
        participants,
        admins,
        isProfilePhoto,
        isSendMessage,
        hideMembersInfo,
        hideNewMembersMessage,
        restrictContentSharing,
        isGroupProfilePhoto,
        privacy,
        inviteLink,
        participantCount,
      ];
}

class Participant {
  final String? id;
  final String? profilePicture;
  final String? userName;
  final String? name;
  final DateTime? lastSeen;
  final bool? isAdmin;
  final bool? isCreator;
  Participant(
      {this.id,
      this.profilePicture,
      this.userName,
      this.lastSeen,
      this.isAdmin,
      this.name,
      this.isCreator});

  Participant copyWith({
    String? id,
    String? profilePicture,
    String? userName,
    DateTime? lastSeen,
    bool? isAdmin,
    bool? isCreator,
    String? name,
  }) =>
      Participant(
        id: id ?? this.id,
        profilePicture: profilePicture ?? this.profilePicture,
        isAdmin: isAdmin ?? this.isAdmin,
        userName: userName ?? this.userName,
        lastSeen: lastSeen ?? this.lastSeen,
        name: name ?? this.name,
        isCreator: isCreator ?? this.isCreator,
      );

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
        id: json["_id"],
        profilePicture: json["profilePicture"],
        name: json["name"],
        userName: json["userName"],
        isAdmin: json["isAdmin"],
        isCreator: json["isCreator"],
        lastSeen: json["lastSeen"] == null
            ? null
            : DateTime.parse(json["lastSeen"]).toLocal(),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "profilePicture": profilePicture,
        "userName": userName,
        "isAdmin": isAdmin,
        "isCreator": isCreator,
        "name": name,
        "lastSeen": lastSeen?.toIso8601String(),
      };
}
