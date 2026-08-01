import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/common_res.dart';
import 'package:two_one_two_messenger/models/create_conversaion_model.dart';
import 'package:two_one_two_messenger/models/group_info_model.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/repository/group_repository.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

import 'group_state.dart';

/// Owns group/channel creation, settings, membership, and invite-link
/// management — extracted out of the former catch-all `HomeCubit`. Cross-domain
/// effects (refreshing the conversation list, clearing a deleted chat's local
/// history) are still triggered via the global `homeCubit` singleton, exactly
/// like every other cross-cubit call already in this codebase.
class GroupCubit extends Cubit<GroupState> {
  GroupCubit(this.repository) : super(GroupState.initial());

  final GroupRepository repository;

  Timer? debounceTimerSendMessage;
  Timer? debounceTimerShowProfilePhoto;

  void selectGroupImage(XFile? file) {
    emit(state.copyWith(selectedGroupPic: file));
  }

  bool addToGroup(UserData user, bool isSelected, int initialLength) {
    if (state.selectedUserForGroup.length + initialLength >= 20000) {
      return false;
    }
    Set<Participant> updatedUsers = Set.from(state.selectedUserForGroup);
    if (isSelected) {
      updatedUsers.removeWhere(
        (element) => element.id == user.sId,
      );
    } else {
      updatedUsers.add(Participant(
          id: user.sId,
          name: user.name,
          userName: user.userName,
          profilePicture: user.profilePicture,
          lastSeen: user.lastSeen == null
              ? null
              : DateTime.tryParse(user.lastSeen!)?.toLocal()));
    }
    emit(state.copyWith(selectedUserForGroup: updatedUsers));
    return true;
  }

  void removeSelectedGroupUser(String userId) {
    final updatedUsers = Set<Participant>.from(state.selectedUserForGroup)
      ..removeWhere((element) => element.id == userId);
    emit(state.copyWith(selectedUserForGroup: updatedUsers));
  }

  void clearSelectedGroupUsers() {
    emit(state.copyWith(selectedUserForGroup: {}));
  }

  void toggleSendMessage(bool value) {
    emit(state.copyWith(sendMessageForGroup: value));
  }

  void toggleSendMessageForUpdateGroup(
      BuildContext context, String groupId, bool value, ChatType chatType) {
    emit(state.copyWith(sendMessageForGroup: value));
    if (debounceTimerSendMessage != null) {
      debounceTimerSendMessage?.cancel();
    }
    debounceTimerSendMessage = Timer(
      Duration(seconds: 1),
      () async {
        await updateGroupForSendMessage(context, groupId, chatType);
      },
    );
  }

  void toggleShowProfilePhoto(bool value) {
    emit(state.copyWith(showProfilePhotoForGroup: value));
  }

  void toggleShowProfilePhotoForUpdate(
      BuildContext context, String groupId, bool value, ChatType chatType) {
    emit(state.copyWith(showProfilePhotoForGroup: value));

    if (debounceTimerShowProfilePhoto != null) {
      debounceTimerShowProfilePhoto?.cancel();
    }
    debounceTimerShowProfilePhoto = Timer(
      Duration(seconds: 1),
      () async {
        await updateGroupForShowProfilePhoto(context, groupId, chatType);
      },
    );
  }

  void togglePrivateGroup(bool value) {
    emit(state.copyWith(privateGroup: value));
  }

  void toggleHideMembersInfo(bool value) {
    emit(state.copyWith(hideMembersInfo: value));
  }

  void toggleHideNewMembersMessage(bool value) {
    emit(state.copyWith(hideNewMembersMessage: value));
  }

  void toggleRestrictContentSharing(bool value) {
    emit(state.copyWith(restrictContentSharing: value));
  }

  void toggleShowGroupProfilePhoto(bool value) {
    emit(state.copyWith(showGroupProfilePhoto: value));
  }

  void updateGroupSetting(
      BuildContext context, String groupId, ChatType chatType) {
    if (debounceTimerShowProfilePhoto != null) {
      debounceTimerShowProfilePhoto?.cancel();
    }
    debounceTimerShowProfilePhoto = Timer(
      Duration(seconds: 1),
      () async {
        await updateGroup(context, groupId, chatType,
            showSuccessMessage: false);
      },
    );
  }

  void cleanGroupData() {
    emit(state.copyWith(
        showProfilePhotoForGroup: true,
        sendMessageForGroup: true,
        privateGroup: false,
        hideMembersInfo: false,
        hideNewMembersMessage: false,
        restrictContentSharing: false,
        groupNameController: TextEditingController(),
        clearSelectedGroupPic: true,
        isUpdateGroupData: true,
        selectedUserForGroup: Set.of([])));
  }

  void cleanGroupDataInfo() {
    emit(state.copyWith(
        groupData: null,
        isUpdateGroupData: true,
        selectedUserForGroup: Set.of([])));
  }

  Future<void> createGroup(BuildContext context, ChatType chatType) async {
    Utils.showLoader();

    try {
      Map<String, dynamic> data = {
        "participants": jsonEncode(state.selectedUserForGroup
            .map(
              (e) => e.id,
            )
            .toList()),
        "groupName": state.groupNameController.text.trim(),
        "isProfilePhoto": state.showProfilePhotoForGroup,
        "isSendMessage":
            chatType == ChatType.group ? state.sendMessageForGroup : false,
        "privacy": state.privateGroup ? "private" : "public",
        "hideMembersInfo": state.hideMembersInfo,
        "hideNewMembersMessage": state.hideNewMembersMessage,
        "restrictContentSharing": state.restrictContentSharing,
        "isGroupProfilePhoto": state.showGroupProfilePhoto,
        "chatType": chatType.name,
      };

      CreateConversionModel response = await repository.createGroup(context,
          inputData: data,
          files: state.selectedGroupPic != null
              ? [state.selectedGroupPic!]
              : null);
      if (response.status == Utils.APISUCCESS) {
        cleanGroupData();

        NavigationService().popUntil();
        homeCubit.getConversation(context: context);
      } else {
        Utils.showSnackBar(context, response.message ?? "");
      }
    } catch (e, st) {
      Utils.showSnackBar(context, S.current.somethingWentWrongPleaseTryAgain,
          seconds: 3);
      showMessage("Error==> $e, $st");
    } finally {
      Utils.hideLoader();
    }
  }

  Future<void> updateGroupForSendMessage(
      BuildContext context, String groupId, ChatType chatType) async {
    Utils.showLoader();

    try {
      Map<String, dynamic> data = {
        "isSendMessage": state.sendMessageForGroup,
        "chatType": chatType.name
      };

      CreateConversionModel response = await repository.updateGroup(context,
          groupId: groupId,
          inputData: data,
          files: state.selectedGroupPic != null
              ? [state.selectedGroupPic!]
              : null);
      if (response.status == Utils.APISUCCESS) {
        getGroupInfobyId(context, groupId);
        homeCubit.getConversation(context: context);
      } else {
        Utils.showSnackBar(context, response.message ?? "", seconds: 3);
      }
    } catch (e) {
      Utils.showSnackBar(context, S.current.somethingWentWrongPleaseTryAgain,
          seconds: 3);
    } finally {
      Utils.hideLoader();
    }
  }

  Future<void> updateGroupForShowProfilePhoto(
      BuildContext context, String groupId, ChatType chatType) async {
    Utils.showLoader();

    try {
      Map<String, dynamic> data = {
        "isProfilePhoto": state.showProfilePhotoForGroup,
        "chatType": chatType.name
      };

      CreateConversionModel response = await repository.updateGroup(context,
          groupId: groupId,
          inputData: data,
          files: state.selectedGroupPic != null
              ? [state.selectedGroupPic!]
              : null);
      if (response.status == Utils.APISUCCESS) {
        getGroupInfobyId(context, groupId);
        homeCubit.getConversation(context: context);
      } else {
        Utils.showSnackBar(context, response.message ?? "", seconds: 3);
      }
    } catch (e) {
      Utils.showSnackBar(context, S.current.somethingWentWrongPleaseTryAgain,
          seconds: 3);
    } finally {
      Utils.hideLoader();
    }
  }

  void clearSelectedGroupPic() {
    emit(state.copyWith(clearSelectedGroupPic: true));
  }

  Future<void> updateGroup(
      BuildContext context, String groupId, ChatType chatType,
      {bool showSuccessMessage = true}) async {
    Utils.showLoader();

    try {
      Map<String, dynamic> data = {
        "groupName": state.groupNameController.text.trim(),
        "isProfilePhoto": state.showProfilePhotoForGroup,
        "isSendMessage": state.sendMessageForGroup,
        "privacy": state.privateGroup ? "private" : "public",
        "hideMembersInfo": state.hideMembersInfo,
        "hideNewMembersMessage": state.hideNewMembersMessage,
        "restrictContentSharing": state.restrictContentSharing,
        "isGroupProfilePhoto": state.showGroupProfilePhoto,
        "chatType": chatType.name
      };

      CreateConversionModel response = await repository.updateGroup(context,
          groupId: groupId,
          inputData: data,
          files: state.selectedGroupPic != null
              ? [state.selectedGroupPic!]
              : null);
      if (response.status == Utils.APISUCCESS) {
        getGroupInfobyId(context, groupId);
        if (state.selectedGroupPic != null) {
          clearSelectedGroupPic();
        }
        if (showSuccessMessage) {
          Utils.showSnackBar(context,
              S.current.groupOrChannelUpdateSuccessfully(chatType.name));
        }
        homeCubit.getConversation(context: context);
      } else {
        Utils.showSnackBar(context, response.message ?? "", seconds: 3);
      }
    } catch (e, st) {
      log("Error ==>updateGroup $e $st");
      Utils.showSnackBar(context, S.current.somethingWentWrongPleaseTryAgain,
          seconds: 3);
    } finally {
      Utils.hideLoader();
    }
  }

  Future<void> getGroupInfobyId(BuildContext context, String groupId,
      {bool? isLoaderVisible}) async {
    try {
      if (isLoaderVisible ?? true) {
        emit(state.copyWith(
            groupLoadingState: LoadingState.loading, groupData: GroupData()));
      }
      GroupResponseModel response = await repository.getGroupInfobyId(
          context: context, groupId: groupId);
      if (response.status == Utils.APISUCCESS) {
        state.groupNameController.text = response.groupData?.groupName ?? "";
        emit(state.copyWith(
            groupLoadingState: LoadingState.success,
            showProfilePhotoForGroup: response.groupData?.isProfilePhoto,
            sendMessageForGroup: response.groupData?.isSendMessage,
            privateGroup: response.groupData?.privacy == "private",
            hideMembersInfo: response.groupData?.hideMembersInfo,
            hideNewMembersMessage: response.groupData?.hideNewMembersMessage,
            restrictContentSharing: response.groupData?.restrictContentSharing,
            showGroupProfilePhoto:
                response.groupData?.isGroupProfilePhoto ?? true,
            groupData: response.groupData,
            selectedUserForGroup:
                Set.from((response.groupData?.participants ?? []).map(
              (e) => e,
            ))));
      } else {
        emit(state.copyWith(groupLoadingState: LoadingState.success));
      }
    } catch (e, st) {
      showMessage("Error in getGroupInfobyId==> $e, $st");
      emit(state.copyWith(groupLoadingState: LoadingState.error));
    }
  }

  Future<void> assignAdminToGroup(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      Utils.showLoader();
      CommonResponseModel response =
          await repository.assignAdminToGroup(data: data);
      if (response.status == Utils.APISUCCESS) {
        Utils.showSnackBar(context, response.message ?? "");
        await getGroupInfobyId(context, data["chatId"],
            isLoaderVisible: false);
      }
    } catch (e, st) {
      showMessage("Error in assignAdminToGroup==> $e, $st");
    } finally {
      Utils.hideLoader();
    }
  }

  Future<void> revokeGroupInviteLink(
      BuildContext context, String groupId) async {
    try {
      Utils.showLoader();
      CommonResponseModel response =
          await repository.revokeGroupInviteLink(groupId: groupId);
      if (!context.mounted) return;
      if (response.status == Utils.APISUCCESS) {
        Utils.showSnackBar(context, response.message ?? "");
        await getGroupInfobyId(context, groupId, isLoaderVisible: false);
        if (!context.mounted) return;
        homeCubit.getConversation(context: context);
      } else {
        Utils.showSnackBar(context, response.message ?? "", seconds: 3);
      }
    } catch (e, st) {
      showMessage("Error in revokeGroupInviteLink==> $e, $st");
      if (context.mounted) {
        Utils.showSnackBar(context, S.current.somethingWentWrongPleaseTryAgain,
            seconds: 3);
      }
    } finally {
      Utils.hideLoader();
    }
  }

  Future<void> addMembersToGroup(BuildContext context, String groupId) async {
    try {
      Utils.showLoader();
      final data = {
        "groupId": groupId,
        "newMembers":
            state.selectedUserForGroup.map((e) => e.id).toList()
      };
      CommonResponseModel response =
          await repository.addMemberToGroup(data: data);
      if (response.status == Utils.APISUCCESS) {
        emit(state.copyWith(selectedUserForGroup: Set.of([])));
        Navigator.pop(context);
        await getGroupInfobyId(context, groupId, isLoaderVisible: false);
      }
    } catch (e, st) {
      showMessage("Error in addMembersToGroup==> $e, $st");
    } finally {
      Utils.hideLoader();
    }
  }

  Future<void> removeMemberFromGroup(BuildContext context,
      Map<String, dynamic> data, String name, bool isGroup) async {
    try {
      Utils.showLoader();
      CommonResponseModel response =
          await repository.removeMemberToGroup(data: data);
      if (response.status == Utils.APISUCCESS) {
        showMessage("removeMemberFromGroup  Suceess");
        Utils.showSnackBar(
            context,
            S.current.memberRemovedFromTheGroupOrChannel(
                name, isGroup ? S.current.group : S.current.channel));
        await getGroupInfobyId(context, data["chatId"],
            isLoaderVisible: false);
      }
    } catch (e, st) {
      showMessage("Error in getGroupInfobyId==> $e, $st");
    } finally {
      Utils.hideLoader();
    }
  }

  Future<void> deleteGroup(BuildContext context, String groupId) async {
    try {
      Utils.showLoader();
      CommonResponseModel response =
          await repository.deleteGroup(groupId: groupId);
      if (response.status == Utils.APISUCCESS) {
        NavigationService().popUntil();
        await homeCubit.messageRepo.clearChat(
          chatId: groupId,
        );
        homeCubit.getConversation(context: context);
        Utils.showSnackBar(context, response.message ?? "");
      } else {
        Utils.showSnackBar(
            context, response.message ?? S.current.deleteGroupAuthority);
      }
    } catch (e, st) {
      showMessage("Error in getGroupInfobyId==> $e, $st");
    } finally {
      Utils.hideLoader();
    }
  }

  Future<void> leaveGroup(BuildContext context, String groupId) async {
    try {
      Utils.showLoader();
      CommonResponseModel response =
          await repository.leaveGroup(groupId: groupId);
      if (response.status == Utils.APISUCCESS) {
        NavigationService().popUntil();
        await homeCubit.getConversation(context: context);
        Utils.showSnackBar(context, response.message ?? "");
      }
    } catch (e, st) {
      showMessage("Error in getGroupInfobyId==> $e, $st");
    } finally {
      Utils.hideLoader();
    }
  }
}
