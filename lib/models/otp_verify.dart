import 'package:equatable/equatable.dart';
import 'package:two_one_two_messenger/models/all_user.dart';

class OtpVerifyResponse {
  int? status;
  String? message;
  OtpVerifyData? data;

  OtpVerifyResponse({this.status, this.message, this.data});

  OtpVerifyResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? OtpVerifyData.fromJson(json['data']) : null;
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

class GetProfileResponse {
  int? status;
  String? message;
  UserData? data;

  GetProfileResponse({this.status, this.message, this.data});

  GetProfileResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? UserData.fromJson(json['data']) : null;
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

class OtpVerifyData {
  String? token;
  String? refreshToken;
  UserData? user;

  OtpVerifyData({this.token, this.user});

  OtpVerifyData.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    refreshToken = json['refresh_token'];
    user = json['user'] != null ? UserData.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['refresh_token'] = refreshToken;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class UserData extends Equatable {
  String? sId;
  String? email;
  String? phone;
  String? name;
  String? userName;
  bool? isVerified;
  String? providerId;
  String? providerName;
  bool? isOnline;
  String? lastSeen;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? otp;
  String? otpExpiry;
  String? profilePicture;
  String? publicKey;
  String? privateKey;
  String? bio;
  String? countryISOCode;
  String? countryCode;
  String? profilePrivacy;
  bool? isProfileSetUp;
  bool? isStopNotification;
  bool? isMuteNotification;
  bool? isPhoneVerify;
  bool? isEmailVerify;
  String? chatId;
  bool? isBlocked;
  bool? youBlocked;
  int? messageAutoDeleteTime;
  String? nickName;
  bool? isActiveNickname;

  UserData(
      {this.sId,
      this.email,
      this.phone,
      this.name,
      this.userName,
      this.isVerified,
      this.providerId,
      this.providerName,
      this.isOnline,
      this.lastSeen,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.otp,
      this.otpExpiry,
      this.profilePicture,
      this.bio,
      this.countryISOCode,
      this.countryCode,
      this.isProfileSetUp,
      this.isStopNotification,
      this.isMuteNotification,
      this.publicKey,
      this.privateKey,
      this.profilePrivacy,
      this.isEmailVerify,
      this.isPhoneVerify,
      this.chatId,
      this.isBlocked,
      this.youBlocked,
      this.messageAutoDeleteTime,
      this.nickName,
      this.isActiveNickname});

  /// **CopyWith Method for Immutability**
  UserData copyWith(
      {String? sId,
      String? email,
      String? phone,
      String? name,
      String? userName,
      bool? isVerified,
      String? providerId,
      String? providerName,
      bool? isOnline,
      String? lastSeen,
      String? createdAt,
      String? updatedAt,
      int? iV,
      String? otp,
      String? otpExpiry,
      String? profilePicture,
      String? bio,
      String? countryISOCode,
      String? countryCode,
      String? publicKey,
      String? privateKey,
      String? profilePrivacy,
      bool? isProfileSetUp,
      bool? isStopNotification,
      bool? isMuteNotification,
      bool? isPhoneVerify,
      bool? isEmailVerify,
      String? chatId,
      bool? isBlocked,
      bool? youBlocked,
      int? messageAutoDeleteTime,
      String? nickName,
      bool? isActiveNickname}) {
    return UserData(
        sId: sId ?? this.sId,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        name: name ?? this.name,
        userName: userName ?? this.userName,
        isVerified: isVerified ?? this.isVerified,
        providerId: providerId ?? this.providerId,
        providerName: providerName ?? this.providerName,
        isOnline: isOnline ?? this.isOnline,
        lastSeen: lastSeen ?? this.lastSeen,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        iV: iV ?? this.iV,
        otp: otp ?? this.otp,
        otpExpiry: otpExpiry ?? this.otpExpiry,
        profilePicture: profilePicture ?? this.profilePicture,
        bio: bio ?? this.bio,
        profilePrivacy: profilePrivacy ?? this.profilePrivacy,
        publicKey: publicKey ?? this.publicKey,
        privateKey: privateKey ?? this.privateKey,
        countryISOCode: countryISOCode ?? this.countryISOCode,
        countryCode: countryCode ?? this.countryCode,
        isProfileSetUp: isProfileSetUp ?? this.isProfileSetUp,
        isStopNotification: isStopNotification ?? this.isStopNotification,
        isMuteNotification: isMuteNotification ?? this.isMuteNotification,
        isEmailVerify: isEmailVerify ?? this.isEmailVerify,
        isPhoneVerify: isPhoneVerify ?? this.isPhoneVerify,
        chatId: chatId ?? this.chatId,
        isBlocked: isBlocked ?? this.isBlocked,
        youBlocked: youBlocked ?? this.youBlocked,
        messageAutoDeleteTime:
            messageAutoDeleteTime ?? this.messageAutoDeleteTime,
        nickName: nickName ?? this.nickName,
        isActiveNickname: isActiveNickname ?? this.isActiveNickname);
  }

  UserData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    email = json['email'];
    phone = json['phone'];
    name = json['name'];
    userName = json['userName'];
    isVerified = json['isVerified'];
    providerId = json['providerId'].toString();
    providerName = json['providerName'];
    isOnline = json['isOnline'];
    lastSeen = json['lastSeen'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    otp = json['otp'].toString();
    otpExpiry = json['otpExpiry'];
    profilePicture = json['profilePicture'];
    bio = json['bio'];
    countryISOCode = json['countryISOCode'];
    countryCode = json['countryCode'];
    isProfileSetUp = json["isProfileSetUp"];
    isStopNotification = json["isStopNotification"];
    isMuteNotification = json["isMuteNotification"];
    isEmailVerify = json["isEmailVerify"];
    isPhoneVerify = json["isPhoneVerify"];
    publicKey = json["publicKey"];
    privateKey = json["privateKey"];
    profilePrivacy = json["profilePrivacy"];
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
    data['isVerified'] = isVerified;
    data['isProfileSetUp'] = isProfileSetUp;
    data['isStopNotification'] = isStopNotification;
    data['isMuteNotification'] = isMuteNotification;
    data['isPhoneVerify'] = isPhoneVerify;
    data['isEmailVerify'] = isEmailVerify;
    data['providerId'] = providerId;
    data['providerName'] = providerName;
    data['isOnline'] = isOnline;
    data['lastSeen'] = lastSeen;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['otp'] = otp;
    data['otpExpiry'] = otpExpiry;
    data['profilePicture'] = profilePicture;
    data['bio'] = bio;
    data['countryISOCode'] = countryISOCode;
    data['countryCode'] = countryCode;
    data['publicKey'] = publicKey;
    data['privateKey'] = privateKey;
    data['profilePrivacy'] = profilePrivacy;
    data["chatId"] = chatId;
    data["isBlocked"] = isBlocked;
    data["youBlocked"] = youBlocked;
    data["messageAutoDeleteTime"] = messageAutoDeleteTime;
    data["nickName"] = nickName;
    data["isActiveNickname"] = isActiveNickname;

    return data;
  }

  UserData.fromDbJson(Map<String, dynamic> json) {
    sId = json['_id'];
    email = json['email'];
    phone = json['phone'];
    name = json['name'];
    userName = json['userName'];
    isVerified = json['isVerified'] == 1 ? true : false;
    isProfileSetUp = json['isProfileSetUp'] == 1 ? true : false;
    isStopNotification = json['isStopNotification'] == 1 ? true : false;
    isMuteNotification = json['isMuteNotification'] == 1 ? true : false;
    isPhoneVerify = json['isPhoneVerify'] == 1 ? true : false;
    isEmailVerify = json['isEmailVerify'] == 1 ? true : false;
    providerId = json['providerId'].toString();
    providerName = json['providerName'];
    isOnline = json['isOnline'] == 1 ? true : false;
    lastSeen = json['lastSeen'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    profilePicture = json['profilePicture'];
    bio = json['bio'];
    countryISOCode = json['countryISOCode'];
    countryCode = json['countryCode'];
    publicKey = json['publicKey'];
    privateKey = json['privateKey'];
    profilePrivacy = json['profilePrivacy'];
    chatId = json["chatId"];
    isBlocked = json["isBlocked"] == 1 ? true : false;
    youBlocked = json["youBlocked"] == 1 ? true : false;
    messageAutoDeleteTime = json['messageAutoDeleteTime'];
  }

  factory UserData.fromContactUser(ContactUser contact) {
    return UserData(
      sId: contact.sId,
      email: contact.email,
      phone: contact.phone,
      name: contact.name,
      userName: contact.userName,
      isOnline: contact.isOnline,
      lastSeen: contact.lastSeen,
      createdAt: contact.createdAt,
      updatedAt: contact.updatedAt,
      iV: contact.iV,
      profilePicture: contact.profilePicture,
      bio: contact.bio,
      countryISOCode: contact.countryISOCode,
      countryCode: contact.countryCode,
      messageAutoDeleteTime: contact.messageAutoDeleteTime,
      nickName: contact.nickName,
      isActiveNickname: contact.isActiveNickname,
    );
  }

  Map<String, dynamic> toDbJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['email'] = email;
    data['phone'] = phone;
    data['name'] = name;
    data['userName'] = userName;
    data['isVerified'] = (isVerified ?? false) ? 1 : 0;
    data['isProfileSetUp'] = (isProfileSetUp ?? false) ? 1 : 0;
    data['isStopNotification'] = (isStopNotification ?? false) ? 1 : 0;
    data['isMuteNotification'] = (isMuteNotification ?? false) ? 1 : 0;
    data['isPhoneVerify'] = (isPhoneVerify ?? false) ? 1 : 0;
    data['isEmailVerify'] = (isEmailVerify ?? false) ? 1 : 0;
    data['providerId'] = providerId;
    data['providerName'] = providerName;
    data['isOnline'] = (isOnline ?? false) ? 1 : 0;
    data['lastSeen'] = lastSeen;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['profilePicture'] = profilePicture;
    data['bio'] = bio;
    data['countryISOCode'] = countryISOCode;
    data['countryCode'] = countryCode;
    data['publicKey'] = publicKey;
    data['privateKey'] = privateKey;
    data['profilePrivacy'] = profilePrivacy;
    data['chatId'] = chatId;
    data['isBlocked'] = (isBlocked ?? false) ? 1 : 0;
    data['youBlocked'] = (youBlocked ?? false) ? 1 : 0;
    data['messageAutoDeleteTime'] = messageAutoDeleteTime;
    return data;
  }

  @override
  List<Object?> get props => [
        sId,
        email,
        phone,
        name,
        userName,
        isVerified,
        providerId,
        providerName,
        isOnline,
        lastSeen,
        createdAt,
        updatedAt,
        iV,
        otp,
        otpExpiry,
        profilePicture,
        bio,
        countryISOCode,
        countryCode,
        isProfileSetUp,
        isStopNotification,
        isMuteNotification,
        isEmailVerify,
        isPhoneVerify,
        publicKey,
        privateKey,
        profilePrivacy,
        chatId,
        isBlocked,
        youBlocked,
        nickName,
        isActiveNickname
      ];
}
