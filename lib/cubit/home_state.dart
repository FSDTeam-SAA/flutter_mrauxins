import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:two_one_two_messenger/models/all_user.dart';
import 'package:two_one_two_messenger/models/call_history_model.dart';
import 'package:two_one_two_messenger/models/group_info_model.dart';
import 'package:two_one_two_messenger/models/notification_model.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import '../models/conversation_model.dart';
import '../models/stories_response.dart';

class HomeState extends Equatable {
  final TextEditingController groupNameController;

  // Global loading states
  final LoadingState homeLoadingState;
  final LoadingState storiesLoadingState;
  final LoadingState paginationLoadingState;
  final LoadingState getAllUsersLoadingState;
  final LoadingState getCallHistoryLoadingState;
  final LoadingState getAllNotificationsLoadingState;
  final LoadingState groupLoadingState;

  // Data-related states
  final AllUserData? allUserData;
  final Set<Participant> selectedUserForGroup;
  final GroupData? groupData;
  final ConversationModel? conversationModel;
  final ConversationModel? conversationModelForForwardMessages;
  final GetAllStoriesResponse? storiesModel;

  // UI & control flags
  final bool getAllUsersLoadMore;
  final bool showProfilePhotoForGroup;
  final bool sendMessageForGroup;
  final bool privateGroup;
  final bool hideMembersInfo;
  final bool hideNewMembersMessage;
  final bool restrictContentSharing;
  final bool showGroupProfilePhoto;
  final bool searchContacts;
  final bool searchNotifications;
  final bool getCallsHistoryLoadMore;
  final bool getAllNotificationLoadMore;

  // Contact-related states
  final List<ContactUser> displayedContacts;
  final Set<ContactUser> otherContact;
  final LoadingState contactsLoadingState;
  final int currentContactPage;
  final XFile? selectedGroupPic;

  // Call & notification history
  final List<CallHistoryList> callHistory;
  final List<NotificationData> allNotification;

  // Error messages for respective loading states
  final String? homeErrorMessage;
  final String? storiesErrorMessage;
  final int unreadNotificationCount;
  final bool userHaveStory;

  HomeState({
    TextEditingController? groupNameController,
    this.homeLoadingState = LoadingState.success,
    this.storiesLoadingState = LoadingState.success,
    this.paginationLoadingState = LoadingState.success,
    this.getAllUsersLoadingState = LoadingState.success,
    this.contactsLoadingState = LoadingState.success,
    this.groupLoadingState = LoadingState.success,
    this.getCallHistoryLoadingState = LoadingState.success,
    this.getAllNotificationsLoadingState = LoadingState.success,
    this.getCallsHistoryLoadMore = false,
    this.getAllNotificationLoadMore = false,
    this.getAllUsersLoadMore = false,
    this.showProfilePhotoForGroup = true,
    this.sendMessageForGroup = true,
    this.privateGroup = false,
    this.hideMembersInfo = false,
    this.hideNewMembersMessage = false,
    this.restrictContentSharing = false,
    this.showGroupProfilePhoto = true,
    this.searchContacts = false,
    this.searchNotifications = false,
    this.userHaveStory = false,
    this.currentContactPage = 1,
    this.unreadNotificationCount = 0,
    this.allUserData,
    this.groupData,
    this.conversationModel,
    this.conversationModelForForwardMessages,
    this.storiesModel,
    this.selectedGroupPic,
    this.displayedContacts = const [],
    this.callHistory = const [],
    this.allNotification = const [],
    this.homeErrorMessage,
    this.storiesErrorMessage,
    Set<Participant>? selectedUserForGroup,
    Set<ContactUser>? otherContact,
  })  : selectedUserForGroup = selectedUserForGroup ?? {},
        otherContact = otherContact ?? {},
        groupNameController = groupNameController ?? TextEditingController();

  /// Initial state factory
  factory HomeState.initial() {
    return HomeState();
  }

  /// CopyWith method for immutability
  HomeState copyWith({
    LoadingState? homeLoadingState,
    LoadingState? storiesLoadingState,
    LoadingState? paginationLoadingState,
    LoadingState? getAllUsersLoadingState,
    LoadingState? contactsLoadingState,
    LoadingState? groupLoadingState,
    LoadingState? getCallHistoryLoadingState,
    LoadingState? getAllNotificationsLoadingState,
    bool? getAllUsersLoadMore,
    bool? showProfilePhotoForGroup,
    bool? sendMessageForGroup,
    bool? privateGroup,
    bool? hideMembersInfo,
    bool? hideNewMembersMessage,
    bool? restrictContentSharing,
    bool? showGroupProfilePhoto,
    bool? searchContacts,
    bool? searchNotifications,
    bool? userHaveStory,
    bool? getCallsHistoryLoadMore,
    bool? getAllNotificationLoadMore,
    String? homeErrorMessage,
    String? storiesErrorMessage,
    ConversationModel? conversationModel,
    ConversationModel? conversationModelForForwardMessages,
    GetAllStoriesResponse? storiesModel,
    List<ContactUser>? displayedContacts,
    Set<ContactUser>? otherContact,
    List<CallHistoryList>? callHistory,
    List<NotificationData>? allNotification,
    int? currentContactPage,
    XFile? selectedGroupPic,
    bool? clearSelectedGroupPic,
    AllUserData? allUserData,
    bool? isUpdateGroupData,
    GroupData? groupData,
    Set<Participant>? selectedUserForGroup,
    TextEditingController? groupNameController,
    int? unreadNotificationCount,
  }) {
    return HomeState(
      groupNameController: groupNameController ?? this.groupNameController,
      homeLoadingState: homeLoadingState ?? this.homeLoadingState,
      storiesLoadingState: storiesLoadingState ?? this.storiesLoadingState,
      paginationLoadingState:
          paginationLoadingState ?? this.paginationLoadingState,
      getAllUsersLoadingState:
          getAllUsersLoadingState ?? this.getAllUsersLoadingState,
      contactsLoadingState: contactsLoadingState ?? this.contactsLoadingState,
      groupLoadingState: groupLoadingState ?? this.groupLoadingState,
      getCallHistoryLoadingState:
          getCallHistoryLoadingState ?? this.getCallHistoryLoadingState,
      getAllNotificationsLoadingState: getAllNotificationsLoadingState ??
          this.getAllNotificationsLoadingState,
      getCallsHistoryLoadMore:
          getCallsHistoryLoadMore ?? this.getCallsHistoryLoadMore,
      getAllNotificationLoadMore:
          getAllNotificationLoadMore ?? this.getAllNotificationLoadMore,
      getAllUsersLoadMore: getAllUsersLoadMore ?? this.getAllUsersLoadMore,
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
      searchContacts: searchContacts ?? this.searchContacts,
      searchNotifications: searchNotifications ?? this.searchNotifications,
      currentContactPage: currentContactPage ?? this.currentContactPage,
      selectedGroupPic: (clearSelectedGroupPic ?? false)
          ? null
          : selectedGroupPic ?? this.selectedGroupPic,
      allUserData: allUserData ?? this.allUserData,
      groupData: (isUpdateGroupData ?? false)
          ? groupData
          : groupData ?? this.groupData,
      conversationModel: conversationModel ?? this.conversationModel,
      conversationModelForForwardMessages:
          conversationModelForForwardMessages ??
              this.conversationModelForForwardMessages,
      storiesModel: storiesModel ?? this.storiesModel,
      displayedContacts: displayedContacts ?? this.displayedContacts,
      otherContact: otherContact ?? this.otherContact,
      callHistory: callHistory ?? this.callHistory,
      allNotification: allNotification ?? this.allNotification,
      selectedUserForGroup: selectedUserForGroup ?? this.selectedUserForGroup,
      unreadNotificationCount:
          unreadNotificationCount ?? this.unreadNotificationCount,
      userHaveStory: userHaveStory ?? this.userHaveStory,
    );
  }

  @override
  List<Object?> get props => [
        groupNameController,
        homeLoadingState,
        storiesLoadingState,
        paginationLoadingState,
        getAllUsersLoadingState,
        contactsLoadingState,
        groupLoadingState,
        getCallHistoryLoadingState,
        getAllNotificationsLoadingState,
        getCallsHistoryLoadMore,
        getAllNotificationLoadMore,
        getAllUsersLoadMore,
        otherContact,
        showProfilePhotoForGroup,
        sendMessageForGroup,
        privateGroup,
        hideMembersInfo,
        hideNewMembersMessage,
        restrictContentSharing,
        showGroupProfilePhoto,
        searchContacts,
        searchNotifications,
        homeErrorMessage,
        storiesErrorMessage,
        conversationModel,
        conversationModelForForwardMessages,
        storiesModel,
        currentContactPage,
        displayedContacts,
        callHistory,
        allNotification,
        selectedGroupPic,
        allUserData,
        groupData,
        selectedUserForGroup,
        unreadNotificationCount,
        userHaveStory
      ];
}

// class HomeState extends Equatable {
//   final TextEditingController groupNameController;

//   // Global loading state
//   final LoadingState homeLoadingState;
//   final LoadingState storiesLoadingState;
//   final LoadingState paginationLoadingState;
//   final LoadingState getAllUsersLoadingState;
//   final LoadingState getCallHistoryLoadingState;
//     final LoadingState getAllNotificationsLoadingState;
//  final LoadingState groupLoadingState;
//   final AllUserData? allUserData;
//   final Set<Participant> selectedUserForGroup;
//   final bool getAllUsersLoadMore;
// final bool showProfilePhotoForGroup;
// final bool sendMessageForGroup;
// final GroupData? groupData;
//   // Error messages for respective loading states
//   final String? homeErrorMessage;
//   final String? storiesErrorMessage;

//   // Data for conversations and stories
//   final ConversationModel? conversationModel;
//   final GetAllStoriesResponse? storiesModel;
//   final int currentContactPage;
//   final XFile? selectedGroupPic;

//   // Contact-related states
//   final List<Contact> displayedContacts;
//   final bool searchContacts;
//    final bool searchNotifications;
//   final LoadingState contactsLoadingState;
// final List<CallHistory> callHistory;
// final List<NotificationData> allNotification;
// final bool getCallsHistoryLoadMore; final bool getAllNotificationLoadMore;
//    HomeState({
//   TextEditingController? groupNameController,
//   this.homeLoadingState = LoadingState.success,
//   this.storiesLoadingState = LoadingState.success,
//   this.paginationLoadingState = LoadingState.success,
//   this.getAllUsersLoadingState = LoadingState.success,
//   this.contactsLoadingState = LoadingState.success,
//   this.groupLoadingState= LoadingState.success,
//   this.getCallHistoryLoadingState=LoadingState.success,
//   this.homeErrorMessage,
//   this.storiesErrorMessage,
//   this.conversationModel,
//   this.storiesModel,
//   this.selectedGroupPic,
//   this.displayedContacts = const [],
//   Set<Participant>? selectedUserForGroup,  // Remove direct assignment
//   this.searchContacts = false,
//   this.searchNotifications=false,
//   this.currentContactPage = 1,
//   this.allUserData,
//   this.groupData,
//   this.getAllUsersLoadMore = false,  this.showProfilePhotoForGroup = true,
//     this.sendMessageForGroup = true,
// })  : selectedUserForGroup = selectedUserForGroup ?? {},  // Initialize properly
//       groupNameController = groupNameController ?? TextEditingController();

//   // Initial state factory
//   factory HomeState.initial() {
//     return HomeState();
//   }

//   // CopyWith method for immutability
//   HomeState copyWith({
//     LoadingState? homeLoadingState, LoadingState?groupLoadingState,
//      Set<Participant>? selectedUserForGroup,
//      TextEditingController? groupNameController,
//     LoadingState? storiesLoadingState,
//     LoadingState? paginationLoadingState,
//     LoadingState? getAllUsersLoadingState,
//     LoadingState? contactsLoadingState,
//     LoadingState? getCallHistoryLoadingState,
//     String? homeErrorMessage,
//     String? storiesErrorMessage,
//     ConversationModel? conversationModel,
//     GetAllStoriesResponse? storiesModel,
//     List<Contact>? displayedContacts,
//     bool? searchContacts,bool?searchNotifications,
//     int? currentContactPage,
//     XFile? selectedGroupPic,
//     bool? clearSelectedGroupPic,
//     AllUserData? allUserData,
//     bool? getAllUsersLoadMore,   bool? showProfilePhotoForGroup,
// bool? getCallsHistoryLoadMore, bool? getAllNotificationLoadMore,
// bool? getCallsHistoryLoadMore, bool? getAllNotificationLoadMore,

//     bool? sendMessageForGroup,
//     bool? isUpdateGroupData,
//     GroupData? groupData,
//   }) {
//     return HomeState(
//      groupNameController:groupNameController??this.groupNameController,
//       homeLoadingState: homeLoadingState ?? this.homeLoadingState,
//       storiesLoadingState: storiesLoadingState ?? this.storiesLoadingState,
//       paginationLoadingState: paginationLoadingState ?? this.paginationLoadingState,
//       getAllUsersLoadingState: getAllUsersLoadingState ?? this.getAllUsersLoadingState,
//       contactsLoadingState: contactsLoadingState ?? this.contactsLoadingState,
//       getCallHistoryLoadingState:getCallHistoryLoadingState??this.getCallHistoryLoadingState,
//       homeErrorMessage: homeErrorMessage ?? this.homeErrorMessage,
//       storiesErrorMessage: storiesErrorMessage ?? this.storiesErrorMessage,
//       conversationModel: conversationModel ?? this.conversationModel,
//       storiesModel: storiesModel ?? this.storiesModel,
//       displayedContacts: displayedContacts ?? this.displayedContacts,
//       searchContacts: searchContacts ?? this.searchContacts,
//       currentContactPage: currentContactPage ?? this.currentContactPage,
//       selectedGroupPic:(clearSelectedGroupPic??false)?null: selectedGroupPic ?? this.selectedGroupPic,
//       allUserData: allUserData ?? this.allUserData,
//       getAllUsersLoadMore: getAllUsersLoadMore ?? this.getAllUsersLoadMore,
//       selectedUserForGroup:selectedUserForGroup??this.selectedUserForGroup,showProfilePhotoForGroup: showProfilePhotoForGroup ?? this.showProfilePhotoForGroup,
//       sendMessageForGroup: sendMessageForGroup ?? this.sendMessageForGroup,
//     groupData:(isUpdateGroupData??false)?groupData:groupData??this.groupData,
//     groupLoadingState:groupLoadingState??this.groupLoadingState,
//     searchNotifications:searchNotifications??this.searchNotifications,
//     );
//   }

//   @override
//   List<Object?> get props => [
//         homeLoadingState,
//         storiesLoadingState,
//         paginationLoadingState,
//         getAllUsersLoadingState,
//         contactsLoadingState,getCallHistoryLoadingState,
//         homeErrorMessage,
//         storiesErrorMessage,
//         conversationModel,
//         storiesModel,
//         currentContactPage,
//         displayedContacts,
//         searchContacts,
//         selectedGroupPic,
//         allUserData,
//         getAllUsersLoadMore,
//         selectedUserForGroup, showProfilePhotoForGroup,
//         sendMessageForGroup,
//         groupData,
//         groupLoadingState,searchNotifications
//       ];
// }
