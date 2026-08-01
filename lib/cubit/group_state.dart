import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:two_one_two_messenger/models/group_info_model.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

class GroupState extends Equatable {
  final TextEditingController groupNameController;

  final LoadingState groupLoadingState;

  final GroupData? groupData;
  final Set<Participant> selectedUserForGroup;

  final bool showProfilePhotoForGroup;
  final bool sendMessageForGroup;
  final bool privateGroup;
  final bool hideMembersInfo;
  final bool hideNewMembersMessage;
  final bool restrictContentSharing;
  final bool showGroupProfilePhoto;

  final XFile? selectedGroupPic;

  GroupState({
    TextEditingController? groupNameController,
    this.groupLoadingState = LoadingState.success,
    this.showProfilePhotoForGroup = true,
    this.sendMessageForGroup = true,
    this.privateGroup = false,
    this.hideMembersInfo = false,
    this.hideNewMembersMessage = false,
    this.restrictContentSharing = false,
    this.showGroupProfilePhoto = true,
    this.groupData,
    this.selectedGroupPic,
    Set<Participant>? selectedUserForGroup,
  })  : selectedUserForGroup = selectedUserForGroup ?? {},
        groupNameController = groupNameController ?? TextEditingController();

  factory GroupState.initial() => GroupState();

  GroupState copyWith({
    LoadingState? groupLoadingState,
    bool? showProfilePhotoForGroup,
    bool? sendMessageForGroup,
    bool? privateGroup,
    bool? hideMembersInfo,
    bool? hideNewMembersMessage,
    bool? restrictContentSharing,
    bool? showGroupProfilePhoto,
    XFile? selectedGroupPic,
    bool? clearSelectedGroupPic,
    bool? isUpdateGroupData,
    GroupData? groupData,
    Set<Participant>? selectedUserForGroup,
    TextEditingController? groupNameController,
  }) {
    return GroupState(
      groupNameController: groupNameController ?? this.groupNameController,
      groupLoadingState: groupLoadingState ?? this.groupLoadingState,
      showProfilePhotoForGroup:
          showProfilePhotoForGroup ?? this.showProfilePhotoForGroup,
      sendMessageForGroup: sendMessageForGroup ?? this.sendMessageForGroup,
      privateGroup: privateGroup ?? this.privateGroup,
      hideMembersInfo: hideMembersInfo ?? this.hideMembersInfo,
      hideNewMembersMessage:
          hideNewMembersMessage ?? this.hideNewMembersMessage,
      restrictContentSharing:
          restrictContentSharing ?? this.restrictContentSharing,
      showGroupProfilePhoto:
          showGroupProfilePhoto ?? this.showGroupProfilePhoto,
      selectedGroupPic: (clearSelectedGroupPic ?? false)
          ? null
          : selectedGroupPic ?? this.selectedGroupPic,
      groupData: (isUpdateGroupData ?? false)
          ? groupData
          : groupData ?? this.groupData,
      selectedUserForGroup: selectedUserForGroup ?? this.selectedUserForGroup,
    );
  }

  @override
  List<Object?> get props => [
        groupNameController,
        groupLoadingState,
        showProfilePhotoForGroup,
        sendMessageForGroup,
        privateGroup,
        hideMembersInfo,
        hideNewMembersMessage,
        restrictContentSharing,
        showGroupProfilePhoto,
        selectedGroupPic,
        groupData,
        selectedUserForGroup,
      ];
}
