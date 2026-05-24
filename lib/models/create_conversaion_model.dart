class CreateConversionModel {
  int? status;
  String? message;
  CreateConversionData? data;

  CreateConversionModel({
    this.status,
    this.message,
    this.data,
  });

  factory CreateConversionModel.fromJson(Map<String, dynamic> json) =>
      CreateConversionModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : CreateConversionData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

// class CreateConversionData {
//   String? id;
//   bool? isGroup;
//   List<String>? participants;
//   List<dynamic>? admins;
//   DateTime? createdAt;
//   int? v;
//   String? lastMessage;

//   CreateConversionData({
//     this.id,
//     this.isGroup,
//     this.participants,
//     this.admins,
//     this.createdAt,
//     this.v,
//     this.lastMessage,
//   });

//   factory CreateConversionData.fromJson(Map<String, dynamic> json) => CreateConversionData(
//     id: json["_id"],
//     isGroup: json["isGroup"],
//     participants: json["participants"] == null ? [] : List<String>.from(json["participants"]!.map((x) => x)),
//     admins: json["admins"] == null ? [] : List<dynamic>.from(json["admins"]!.map((x) => x)),
//     createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
//     v: json["__v"],
//     lastMessage: json["lastMessage"],
//   );

//   Map<String, dynamic> toJson() => {
//     "_id": id,
//     "isGroup": isGroup,
//     "participants": participants == null ? [] : List<dynamic>.from(participants!.map((x) => x)),
//     "admins": admins == null ? [] : List<dynamic>.from(admins!.map((x) => x)),
//     "createdAt": createdAt?.toIso8601String(),
//     "__v": v,
//     "lastMessage": lastMessage,
//   };
// }

class CreateConversionData {
  final bool? isGroup;
  final List<String>? participants;
  final List<String>? admins;
  final String? groupName;
  final bool? isProfilePhoto;
  final bool? isSendMessage;
  final bool? hideMembersInfo;
  final bool? hideNewMembersMessage;
  final bool? restrictContentSharing;
  final String? id;
  final DateTime? createdAt;
  final String? groupImage;
  final String? encryptedAESKey;
  final int? v;
  int? messageAutoDeleteTime;
  DateTime? messageAutoDeleteStartTime;

  CreateConversionData({
    this.isGroup,
    this.participants,
    this.admins,
    this.groupName,
    this.isProfilePhoto,
    this.isSendMessage,
    this.hideMembersInfo,
    this.hideNewMembersMessage,
    this.restrictContentSharing,
    this.id,
    this.createdAt,
    this.groupImage,
    this.encryptedAESKey,
    this.v,
    this.messageAutoDeleteTime,
    this.messageAutoDeleteStartTime,
  });

  CreateConversionData copyWith({
    bool? isGroup,
    List<String>? participants,
    List<String>? admins,
    String? groupName,
    bool? isProfilePhoto,
    bool? isSendMessage,
    bool? hideMembersInfo,
    bool? hideNewMembersMessage,
    bool? restrictContentSharing,
    String? id,
    DateTime? createdAt,
    String? groupImage,
    String? encryptedAESKey,
    int? v,
    int? messageAutoDeleteTime,
    DateTime? messageAutoDeleteStartTime,
  }) =>
      CreateConversionData(
        isGroup: isGroup ?? this.isGroup,
        participants: participants ?? this.participants,
        admins: admins ?? this.admins,
        groupName: groupName ?? this.groupName,
        isProfilePhoto: isProfilePhoto ?? this.isProfilePhoto,
        isSendMessage: isSendMessage ?? this.isSendMessage,
        hideMembersInfo: hideMembersInfo ?? this.hideMembersInfo,
        hideNewMembersMessage:
            hideNewMembersMessage ?? this.hideNewMembersMessage,
        restrictContentSharing:
            restrictContentSharing ?? this.restrictContentSharing,
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        groupImage: groupImage ?? this.groupImage,
        encryptedAESKey: encryptedAESKey ?? this.encryptedAESKey,
        v: v ?? this.v,
        messageAutoDeleteTime:
            messageAutoDeleteTime ?? this.messageAutoDeleteTime,
        messageAutoDeleteStartTime:
            messageAutoDeleteStartTime ?? this.messageAutoDeleteStartTime,
      );

  factory CreateConversionData.fromJson(Map<String, dynamic> json) =>
      CreateConversionData(
        isGroup: json["isGroup"],
        participants: json["participants"] == null
            ? []
            : List<String>.from(json["participants"]!.map((x) => x
                // Participant.fromJson(x)
                )),
        admins: json["admins"] == null
            ? []
            : List<String>.from(json["admins"]!.map((x) => x)),
        groupName: json["groupName"],
        isProfilePhoto: json["isProfilePhoto"],
        isSendMessage: json["isSendMessage"],
        hideMembersInfo: json["hideMembersInfo"],
        hideNewMembersMessage: json["hideNewMembersMessage"],
        restrictContentSharing: json["restrictContentSharing"],
        id: json["_id"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]).toLocal(),
        groupImage: json["groupImage"],
        encryptedAESKey: json["encryptedAESKey"],
        v: json["__v"],
        messageAutoDeleteTime: json["messageAutoDeleteTime"],
        messageAutoDeleteStartTime: json["messageAutoDeleteStartTime"] == null
            ? null
            : DateTime.parse(json["messageAutoDeleteStartTime"]),
      );

  Map<String, dynamic> toJson() => {
        "isGroup": isGroup,
        "participants": participants == null
            ? []
            : List<dynamic>.from(participants!.map((x) => x
                //  x.toJson()
                )),
        "admins":
            admins == null ? [] : List<dynamic>.from(admins!.map((x) => x)),
        "groupName": groupName,
        "isProfilePhoto": isProfilePhoto,
        "isSendMessage": isSendMessage,
        "hideMembersInfo": hideMembersInfo,
        "hideNewMembersMessage": hideNewMembersMessage,
        "restrictContentSharing": restrictContentSharing,
        "_id": id,
        "createdAt": createdAt?.toIso8601String(),
        "groupImage": groupImage,
        "encryptedAESKey": encryptedAESKey,
        "__v": v,
        "messageAutoDeleteTime": messageAutoDeleteTime,
        "messageAutoDeleteStartTime":
            messageAutoDeleteStartTime?.toIso8601String(),
      };
}
