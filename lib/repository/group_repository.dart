import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:two_one_two_messenger/models/common_res.dart';
import 'package:two_one_two_messenger/models/create_conversaion_model.dart';
import 'package:two_one_two_messenger/models/group_info_model.dart';
import 'package:two_one_two_messenger/services/group_client.dart';

/// Thin seam between [GroupCubit] and [GroupClient] — gives the cubit a
/// stable interface decoupled from the client's raw HTTP/multipart details,
/// and a single place to fake responses from in tests.
class GroupRepository {
  GroupRepository(this._client);

  final GroupClient _client;

  Future<bool> checkGroupInviteName(String name, String chatId) =>
      _client.checkGroupInviteName(name, chatId);

  Future<CreateConversionModel> createGroup(
    BuildContext context, {
    required Map<String, dynamic> inputData,
    required List<XFile>? files,
  }) =>
      _client.createGroup(context, inputData: inputData, files: files);

  Future<CreateConversionModel> updateGroup(
    BuildContext context, {
    required String groupId,
    required Map<String, dynamic> inputData,
    required List<XFile>? files,
  }) =>
      _client.updateGroup(context,
          groupId: groupId, inputData: inputData, files: files);

  Future<GroupResponseModel> getGroupInfobyId(
          {required String groupId, required BuildContext context}) =>
      _client.getGroupInfobyId(groupId: groupId, context: context);

  Future<CommonResponseModel> assignAdminToGroup(
          {required Map<String, dynamic> data}) =>
      _client.assignAdminToGroup(data: data);

  Future<CommonResponseModel> revokeGroupInviteLink({required String groupId}) =>
      _client.revokeGroupInviteLink(groupId: groupId);

  Future<CommonResponseModel> removeMemberToGroup(
          {required Map<String, dynamic> data}) =>
      _client.removeMemberToGroup(data: data);

  Future<CommonResponseModel> addMemberToGroup(
          {required Map<String, dynamic> data}) =>
      _client.addMemberToGroup(data: data);

  Future<CommonResponseModel> deleteGroup({required String groupId}) =>
      _client.deleteGroup(groupId: groupId);

  Future<CommonResponseModel> leaveGroup({required String groupId}) =>
      _client.leaveGroup(groupId: groupId);

  Future<List<dynamic>> searchDatabase(
          {required String search, int page = 1, int limit = 50}) =>
      _client.searchDatabase(search: search, page: page, limit: limit);

  Future<List<dynamic>> searchPublicGroups(
          {required String search, int page = 1, int limit = 20}) =>
      _client.searchPublicGroups(search: search, page: page, limit: limit);

  Future<CommonResponseModel> joinGroupByInvite(
          {required String chatId, required String inviteLink}) =>
      _client.joinGroupByInvite(chatId: chatId, inviteLink: inviteLink);
}
