import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:two_one_two_messenger/models/common_res.dart';
import 'package:two_one_two_messenger/models/create_conversaion_model.dart';
import 'package:two_one_two_messenger/models/group_info_model.dart';

import '../main.dart';
import '../utils/logger.dart';
import '../utils/utils.dart';
import 'api_client.dart';
import 'api_config.dart';

/// Owns every group/channel/invite-link network call. Extracted out of the
/// monolithic [ApiClient] (which still owns the shared Dio instance, auth,
/// and token-refresh plumbing via its `get`/`post`/`put`/`delete`/
/// `postWithFormData`/`putWithFormData` helpers) so this domain can be
/// tested and evolved independently of the other ~50 unrelated endpoints
/// that used to live alongside it.
class GroupClient {
  GroupClient(this._apiClient);

  final ApiClient _apiClient;

  Future<bool> checkGroupInviteName(String name, String chatId) async {
    try {
      final response = await _apiClient.get(
        APIS.checkGroupInviteName,
        requiresToken: true,
        params: {'name': name, 'chatId': chatId},
      );
      return response.data['data']?['available'] != false;
    } catch (_) {
      // On any network/backend error, assume available so the UI is not
      // incorrectly blocked. A truly taken name will be rejected on save.
      return true;
    }
  }

  Future<CreateConversionModel> createGroup(
    BuildContext context, {
    required Map<String, dynamic> inputData,
    required List<XFile>? files,
  }) async {
    try {
      final response = await _apiClient.postWithFormData(
        APIS.createGroup,
        () async {
          FormData data = FormData.fromMap(inputData);

          // Add multiple files to FormData
          if (files != null && files.isNotEmpty) {
            for (int i = 0; i < files.length; i++) {
              final mimeType =
                  lookupMimeType(files[i].path) ?? 'application/octet-stream';
              final mimeTypeSplit = mimeType.split('/');
              data.files.add(MapEntry(
                'files',
                // The key on the server side (you may need to adjust this depending on your API)
                await MultipartFile.fromFile(files[i].path,
                    filename: files[i].path.split('/').last,
                    contentType: MediaType(mimeTypeSplit[0], mimeTypeSplit[1])),
              ));
            }
          }

          showMessage("Form data ==> ${data.fields}");
          return data;
        },
        requiresToken: true,
      );

      final createGroupResponse = CreateConversionModel.fromJson(response.data);
      return createGroupResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(e);
    }
  }

  Future<CreateConversionModel> updateGroup(
    BuildContext context, {
    required String groupId,
    required Map<String, dynamic> inputData,
    required List<XFile>? files,
  }) async {
    try {
      final response = await _apiClient.putWithFormData(
        "${APIS.updateGroup}$groupId",
        () async {
          FormData data = FormData.fromMap(inputData);

          // Add multiple files to FormData
          if (files != null && files.isNotEmpty) {
            for (int i = 0; i < files.length; i++) {
              final mimeType =
                  lookupMimeType(files[i].path) ?? 'application/octet-stream';
              final mimeTypeSplit = mimeType.split('/');
              data.files.add(MapEntry(
                'files',
                // The key on the server side (you may need to adjust this depending on your API)
                await MultipartFile.fromFile(files[i].path,
                    filename: files[i].path.split('/').last,
                    contentType: MediaType(mimeTypeSplit[0], mimeTypeSplit[1])),
              ));
            }
          }

          showMessage("Form data ==> ${data.fields}");
          return data;
        },
        requiresToken: true,
      );

      final createGroupResponse = CreateConversionModel.fromJson(response.data);
      return createGroupResponse; // Return the parsed response
    } on DioException catch (e, st) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage, $st');

      throw Exception(e);
    }
  }

  Future<GroupResponseModel> getGroupInfobyId(
      {required String groupId, required BuildContext context}) async {
    try {
      final response = await _apiClient.get(
        "${APIS.getGroupInfobyId}$groupId",
        requiresToken: true,
      );
      GroupResponseModel groupDetails =
          GroupResponseModel.fromJson(response.data);
      return groupDetails; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CommonResponseModel> assignAdminToGroup({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _apiClient.post(
        APIS.assignAdminToGroup,
        data,
        requiresToken: true,
      );
      CommonResponseModel res = CommonResponseModel.fromJson(response.data);
      return res; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CommonResponseModel> revokeGroupInviteLink({
    required String groupId,
  }) async {
    try {
      final response = await _apiClient.post(
        "${APIS.revokeGroupInviteLink}$groupId",
        {},
        requiresToken: true,
      );
      CommonResponseModel res = CommonResponseModel.fromJson(response.data);
      return res;
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CommonResponseModel> removeMemberToGroup({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _apiClient.post(
        APIS.removeMemberToGroup,
        data,
        requiresToken: true,
      );
      CommonResponseModel res = CommonResponseModel.fromJson(response.data);
      return res; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CommonResponseModel> addMemberToGroup({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _apiClient.post(
        APIS.addMemberToGroup,
        data,
        requiresToken: true,
      );
      CommonResponseModel res = CommonResponseModel.fromJson(response.data);
      return res; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CommonResponseModel> deleteGroup({
    required String groupId,
  }) async {
    try {
      final response = await _apiClient.delete(
        "${APIS.deleteGroup}$groupId",
        requiresToken: true,
      );
      CommonResponseModel res = CommonResponseModel.fromJson(response.data);
      return res; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(navigatorKey.currentContext!, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CommonResponseModel> leaveGroup({
    required String groupId,
  }) async {
    try {
      final response = await _apiClient.delete(
        "${APIS.leaveGroup}$groupId",
        requiresToken: true,
      );
      CommonResponseModel res = CommonResponseModel.fromJson(response.data);
      return res; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<List<dynamic>> searchDatabase({
    required String search,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _apiClient.get(
        APIS.searchDatabase,
        requiresToken: true,
        params: {"search": search, "page": page, "limit": limit},
      );
      final body = response.data;
      if (body['status'] == 1 && body['data'] is List) {
        return body['data'] as List<dynamic>;
      }
      return [];
    } on DioException catch (e) {
      AppLogger.logs('Error: ${e.response?.data['message']}');
      return [];
    }
  }

  Future<List<dynamic>> searchPublicGroups({
    required String search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        APIS.searchPublicGroups,
        requiresToken: true,
        params: {"search": search, "page": page, "limit": limit},
      );
      final body = response.data;
      if (body['status'] == 1 && body['data'] is List) {
        return body['data'] as List<dynamic>;
      }
      return [];
    } on DioException catch (e) {
      AppLogger.logs('Error: ${e.response?.data['message']}');
      return [];
    }
  }

  Future<CommonResponseModel> joinGroupByInvite({
    required String chatId,
    required String inviteLink,
  }) async {
    try {
      final response = await _apiClient.post(
        "${APIS.joinGroupByInvite}$chatId",
        {"inviteLink": inviteLink},
        requiresToken: true,
      );
      return CommonResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }
}
