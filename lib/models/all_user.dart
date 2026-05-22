import 'package:equatable/equatable.dart';

import 'otp_verify.dart';

class AllUserResponse {
  int? status;
  String? message;
  AllUserData? data;

  AllUserResponse({this.status, this.message, this.data});

  AllUserResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? AllUserData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class AllUserData extends Equatable {
  final List<UserData>? users;
  final int? totalPages;
  final int? currentPage;
  final int? totalUsers;

  const AllUserData(
      {this.users, this.totalPages, this.currentPage, this.totalUsers});

  factory AllUserData.fromJson(Map<String, dynamic> json) {
    return AllUserData(
      users: json['users'] != null
          ? (json['users'] as List).map((v) => UserData.fromJson(v)).toList()
          : null,
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
      totalUsers: json['totalUsers'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users': users?.map((user) => user.toJson()).toList(),
      'totalPages': totalPages,
      'currentPage': currentPage,
      'totalUsers': totalUsers,
    };
  }

  AllUserData copyWith({
    List<UserData>? users,
    int? totalPages,
    int? currentPage,
    int? totalUsers,
  }) {
    return AllUserData(
      users: users ?? this.users,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      totalUsers: totalUsers ?? this.totalUsers,
    );
  }

  @override
  List<Object?> get props => [users, totalPages, currentPage, totalUsers];
}

class ContactUser extends Equatable {
  String? sId;
  String? email;
  String? phone;
  String? name;
  String? userName;
  bool? isOnline;
  String? lastSeen;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? profilePicture;
  String? bio;
  String? countryISOCode;
  String? countryCode;
  bool? isRegistered;
  String? chatId;
  bool? isBlocked;
  bool? youBlocked;
  int? messageAutoDeleteTime;
  String? nickName;
  bool? isActiveNickname;

  ContactUser({
    this.sId,
    this.email,
    this.phone,
    this.name,
    this.userName,
    this.isOnline,
    this.lastSeen,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.profilePicture,
    this.bio,
    this.countryISOCode,
    this.countryCode,
    this.isRegistered,
    this.chatId,
    this.isBlocked,
    this.youBlocked,
    this.messageAutoDeleteTime,
    this.nickName,
    this.isActiveNickname,
  });

  ContactUser copyWith({
    String? sId,
    String? email,
    String? phone,
    String? name,
    String? userName,
    bool? isOnline,
    String? lastSeen,
    String? createdAt,
    String? updatedAt,
    int? iV,
    String? profilePicture,
    String? bio,
    String? countryISOCode,
    String? countryCode,
    bool? isRegistered,
    String? chatId,
    bool? isBlocked,
    bool? youBlocked,
    int? messageAutoDeleteTime,
    String? nickName,
    bool? isActiveNickname,
  }) {
    return ContactUser(
      sId: sId ?? this.sId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      userName: userName ?? this.userName,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      iV: iV ?? this.iV,
      profilePicture: profilePicture ?? this.profilePicture,
      bio: bio ?? this.bio,
      countryISOCode: countryISOCode ?? this.countryISOCode,
      countryCode: countryCode ?? this.countryCode,
      isRegistered: isRegistered ?? this.isRegistered,
      chatId: chatId ?? this.chatId,
      isBlocked: isBlocked ?? this.isBlocked,
      youBlocked: youBlocked ?? this.youBlocked,
      messageAutoDeleteTime:
          messageAutoDeleteTime ?? this.messageAutoDeleteTime,
      nickName: nickName ?? this.nickName,
      isActiveNickname: isActiveNickname ?? this.isActiveNickname,
    );
  }

  ContactUser.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    email = json['email'];
    phone = json['phone'];
    name = json['name'];
    userName = json['userName'];
    isOnline = json['isOnline'];
    isRegistered = false;
    lastSeen = json['lastSeen'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json[' '];
    profilePicture = json['profilePicture'];
    bio = json['bio'];
    countryISOCode = json['countryISOCode'];
    countryCode = json['countryCode'];
    chatId = json["chatId"];
    isBlocked = json["isBlocked"];
    youBlocked = json["youBlocked"];
    messageAutoDeleteTime = json["messageAutoDeleteTime"];
    nickName = json["nickName"];
    isActiveNickname = json["isActiveNickname"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['email'] = email;
    data['phone'] = phone;
    data['name'] = name;
    data['userName'] = userName;
    data['isOnline'] = isOnline;
    data['isRegistered'] = isRegistered;
    data['lastSeen'] = lastSeen;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['profilePicture'] = profilePicture;
    data['bio'] = bio;
    data['countryISOCode'] = countryISOCode;
    data['countryCode'] = countryCode;
    data["chatId"] = chatId;
    data["isBlocked"] = isBlocked;
    data["youBlocked"] = youBlocked;
    data["messageAutoDeleteTime"] = messageAutoDeleteTime;
    data["nickName"] = nickName;
    data["isActiveNickname"] = isActiveNickname;

    return data;
  }

  ContactUser.fromDbJson(Map<String, dynamic> json) {
    sId = json['_id'];
    email = json['email'];
    phone = json['phone'];
    name = json['name'];
    userName = json['userName'];
    isOnline = json['isOnline'] == 1 ? true : false;
    isRegistered = json['isRegistered'] == 1 ? true : false;
    lastSeen = json['lastSeen'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    profilePicture = json['profilePicture'];
    bio = json['bio'];
    countryISOCode = json['countryISOCode'];
    countryCode = json['countryCode'];
    chatId = json['chatId'];
    isBlocked = json['isBlocked'] == 1 ? true : false;
    youBlocked = json['youBlocked'] == 1 ? true : false;
    messageAutoDeleteTime = json["messageAutoDeleteTime"];
    nickName = json["nickName"];
    isActiveNickname = json["isActiveNickname"] == 1 ? true : false;
  }

  Map<String, dynamic> toDbJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['email'] = email;
    data['phone'] = phone;
    data['name'] = name;
    data['userName'] = userName;
    data['isOnline'] = (isOnline ?? false) ? 1 : 0;
    data['isRegistered'] = (isRegistered ?? false) ? 1 : 0;
    data['lastSeen'] = lastSeen;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['profilePicture'] = profilePicture;
    data['bio'] = bio;
    data['countryISOCode'] = countryISOCode;
    data['countryCode'] = countryCode;
    data["chatId"] = chatId;
    data["isBlocked"] = (isBlocked ?? false) ? 1 : 0;
    data["youBlocked"] = (youBlocked ?? false) ? 1 : 0;
    data["messageAutoDeleteTime"] = messageAutoDeleteTime;
    data["nickName"] = nickName;
    data["isActiveNickname"] = (isActiveNickname ?? false) ? 1 : 0;
    return data;
  }

  @override
  List<Object?> get props => [
        sId,
        email,
        phone,
        name,
        userName,
        isOnline,
        lastSeen,
        createdAt,
        updatedAt,
        iV,
        profilePicture,
        bio,
        countryISOCode,
        countryCode,
        isRegistered,
        chatId,
        isBlocked,
        youBlocked,
        messageAutoDeleteTime,
        nickName,
        isActiveNickname
      ];
}
