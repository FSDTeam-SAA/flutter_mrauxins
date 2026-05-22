import 'package:equatable/equatable.dart';

import 'otp_verify.dart';

// Create Stories
class CreateStoriesResponse {
  int? status;
  String? message;
  CreateStoriesData? data;

  CreateStoriesResponse({this.status, this.message, this.data});

  CreateStoriesResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null ? CreateStoriesData.fromJson(json['data']) : null;
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

class CreateStoriesData {
  String? userId;
  String? mediaUrl;
  String? mediaType;
  String? caption;
  String? expiresAt;
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? userName;
  String? profilePicture;

  CreateStoriesData(
      {this.userId,
      this.mediaUrl,
      this.mediaType,
      this.caption,
      this.expiresAt,
      this.sId,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.userName,
      this.profilePicture});

  CreateStoriesData.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    mediaUrl = json['mediaUrl'];
    mediaType = json['mediaType'];
    caption = json['caption'];
    expiresAt = json['expiresAt'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    userName = json['userName'];
    profilePicture = json['profilePicture'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['mediaUrl'] = mediaUrl;
    data['mediaType'] = mediaType;
    data['caption'] = caption;
    data['expiresAt'] = expiresAt;
    data['_id'] = sId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['userName'] = userName;
    data['profilePicture'] = profilePicture;
    return data;
  }
}

// Delete Stories
class DeleteStoriesResponse {
  int? status;
  String? message;

  DeleteStoriesResponse({this.status, this.message});

  DeleteStoriesResponse.fromJson(Map<String, dynamic> json) {
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

// Get logged in user Stories
class CurrentUserStoriesResponse {
  int? status;
  String? code;
  String? message;
  List<CurrentUserStoriesData>? data;

  CurrentUserStoriesResponse({this.status, this.code, this.message, this.data});

  CurrentUserStoriesResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = <CurrentUserStoriesData>[];
      json['data'].forEach((v) {
        data!.add(CurrentUserStoriesData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['code'] = code;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CurrentUserStoriesData {
  String? sId;
  String? mediaUrl;
  String? caption;
  String? mediaType;
  String? expiresAt;
  DateTime? createdAt;
  StoryCreatorDetails? storyCreatorDetails;
  List<UserData>? viewersDetails;
  int? viewerCount;
  int? duration;

  CurrentUserStoriesData(
      {this.sId,
      this.mediaUrl,
      this.caption,
      this.mediaType,
      this.expiresAt,
      this.createdAt,
      this.storyCreatorDetails,
      this.viewersDetails,
      this.viewerCount,
      this.duration = 5});

  CurrentUserStoriesData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    mediaUrl = json['mediaUrl'];
    caption = json['caption'];
    mediaType = json['mediaType'];
    expiresAt = json['expiresAt'];
    createdAt =
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]).toLocal();
    storyCreatorDetails = json['storyCreatorDetails'] != null
        ? StoryCreatorDetails.fromJson(json['storyCreatorDetails'])
        : null;
    if (json['viewersDetails'] != null) {
      viewersDetails = <UserData>[];
      json['viewersDetails'].forEach((v) {
        viewersDetails!.add(UserData.fromJson(v));
      });
    }
    viewerCount = json['viewerCount'];
    duration = json['duration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['mediaUrl'] = mediaUrl;
    data['caption'] = caption;
    data['mediaType'] = mediaType;
    data['expiresAt'] = expiresAt;
    data['createdAt'] = createdAt?.toIso8601String();
    if (storyCreatorDetails != null) {
      data['storyCreatorDetails'] = storyCreatorDetails!.toJson();
    }
    if (viewersDetails != null) {
      data['viewersDetails'] = viewersDetails!.map((v) => v.toJson()).toList();
    }
    data['viewerCount'] = viewerCount;
    data['duration'] = duration;
    return data;
  }
}

class StoryCreatorDetails {
  String? sId;
  String? userName;
  String? profilePicture;

  StoryCreatorDetails({this.sId, this.userName, this.profilePicture});

  StoryCreatorDetails.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userName = json['userName'];
    profilePicture = json['profilePicture'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['userName'] = userName;
    data['profilePicture'] = profilePicture;
    return data;
  }
}

// Get All Stories
class GetAllStoriesResponse {
  final int? status;
  final String? message;
  final List<GetAllStoriesData>? data;
  final Pagination? pagination;

  GetAllStoriesResponse({
    this.status,
    this.message,
    this.data,
    this.pagination,
  });
  GetAllStoriesResponse copyWith({
    int? status,
    String? message,
    List<GetAllStoriesData>? data,
    Pagination? pagination,
  }) {
    return GetAllStoriesResponse(
      status: status ?? this.status,
      message: message ?? this.message,
      data: data ?? this.data,
      pagination: pagination ?? this.pagination,
    );
  }

  factory GetAllStoriesResponse.fromJson(Map<String, dynamic> json) {
    final nestedData =
        json['data'] as Map<String, dynamic>?; // Extract inner 'data' object

    return GetAllStoriesResponse(
      status: json['status'] as int?,
      message: json['message'] as String?,
      data: (nestedData?['data'] as List<dynamic>?)
          ?.map((e) => GetAllStoriesData.fromJson(e))
          .toList(),
      pagination: nestedData?['pagination'] != null
          ? Pagination.fromJson(nestedData?['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': {
        'data': data?.map((e) => e.toJson()).toList(),
        'pagination': pagination?.toJson(),
      },
    };
  }
}

class GetAllStoriesData extends Equatable {
  UserData? userDetails;
  List<Stories>? stories;

  GetAllStoriesData({this.userDetails, this.stories});

  GetAllStoriesData.fromJson(Map<String, dynamic> json) {
    userDetails = json['userDetails'] != null
        ? UserData.fromJson(json['userDetails'])
        : null;
    if (json['stories'] != null) {
      stories = <Stories>[];
      json['stories'].forEach((v) {
        stories!.add(Stories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (userDetails != null) {
      data['userDetails'] = userDetails!.toJson();
    }
    if (stories != null) {
      data['stories'] = stories!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  GetAllStoriesData copyWith({
    UserData? userDetails,
    List<Stories>? stories,
  }) {
    return GetAllStoriesData(
      userDetails: userDetails ?? this.userDetails,
      stories: stories ?? this.stories,
    );
  }

  @override
  List<Object?> get props => [userDetails, stories];
}

// class UserDetails {
//   String? sId;
//   String? userName;
//   String? profilePicture;

//   UserDetails({this.sId, this.userName, this.profilePicture});

//   UserDetails.fromJson(Map<String, dynamic> json) {
//     sId = json['_id'];
//     userName = json['userName'];
//     profilePicture = json['profilePicture'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['_id'] = sId;
//     data['userName'] = userName;
//     data['profilePicture'] = profilePicture;
//     return data;
//   }
// }

class Stories extends Equatable {
  String? sId;
  String? mediaUrl;
  String? mediaType;
  String? caption;
  UserData? userDetails;
  int? viewers;
  int? duration;
  DateTime? createdAt;

  Stories({
    this.sId,
    this.mediaUrl,
    this.mediaType,
    this.caption,
    this.userDetails,
    this.duration = 5,
    this.viewers,
    this.createdAt,
  });

  Stories.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    mediaUrl = json['mediaUrl'];
    mediaType = json['mediaType'];
    caption = json['caption'];
    userDetails = json['userDetails'] != null
        ? UserData.fromJson(json['userDetails'])
        : null;
    viewers = json['viewers'];
    duration = json['duration'];
    createdAt = json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]).toLocal();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['mediaUrl'] = mediaUrl;
    data['mediaType'] = mediaType;
    data['caption'] = caption;
    if (userDetails != null) {
      data['userDetails'] = userDetails!.toJson();
    }
    data['viewers'] = viewers;
    data['duration'] = duration;
    data['createdAt'] = createdAt?.toIso8601String();

    return data;
  }

  @override
  List<Object?> get props => [
        sId,
        mediaUrl,
        mediaType,
        caption,
        userDetails,
        duration,
        viewers,
        createdAt
      ];
}

class Pagination {
  int? total;
  int? page;
  int? limit;
  int? totalPages;

  Pagination({this.total, this.page, this.limit, this.totalPages});

  Pagination.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    page = json['page'];
    limit = json['limit'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    data['page'] = page;
    data['limit'] = limit;
    data['totalPages'] = totalPages;
    return data;
  }
}

// Viewer Stories Update Response
class ViewStoriesUpdateResponse {
  int? status;
  String? message;

  ViewStoriesUpdateResponse({this.status, this.message});

  ViewStoriesUpdateResponse.fromJson(Map<String, dynamic> json) {
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
