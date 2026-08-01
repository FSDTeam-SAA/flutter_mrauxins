import 'package:equatable/equatable.dart';
import 'package:two_one_two_messenger/models/all_user.dart';
import 'package:two_one_two_messenger/models/call_history_model.dart';
import 'package:two_one_two_messenger/models/notification_model.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import '../models/conversation_model.dart';
import '../models/stories_response.dart';

class HomeState extends Equatable {
  // Global loading states
  final LoadingState homeLoadingState;
  final LoadingState storiesLoadingState;
  final LoadingState paginationLoadingState;
  final LoadingState getAllUsersLoadingState;
  final LoadingState getCallHistoryLoadingState;
  final LoadingState getAllNotificationsLoadingState;

  // Data-related states
  final AllUserData? allUserData;
  final ConversationModel? conversationModel;
  final ConversationModel? conversationModelForForwardMessages;
  final GetAllStoriesResponse? storiesModel;

  // UI & control flags
  final bool getAllUsersLoadMore;
  final bool searchContacts;
  final bool searchNotifications;
  final bool getCallsHistoryLoadMore;
  final bool getAllNotificationLoadMore;

  // Contact-related states
  final List<ContactUser> displayedContacts;
  final Set<ContactUser> otherContact;
  final LoadingState contactsLoadingState;
  final int currentContactPage;

  // Call & notification history
  final List<CallHistoryList> callHistory;
  final List<NotificationData> allNotification;

  // Error messages for respective loading states
  final String? homeErrorMessage;
  final String? storiesErrorMessage;
  final int unreadNotificationCount;
  final bool userHaveStory;

  HomeState({
    this.homeLoadingState = LoadingState.success,
    this.storiesLoadingState = LoadingState.success,
    this.paginationLoadingState = LoadingState.success,
    this.getAllUsersLoadingState = LoadingState.success,
    this.contactsLoadingState = LoadingState.success,
    this.getCallHistoryLoadingState = LoadingState.success,
    this.getAllNotificationsLoadingState = LoadingState.success,
    this.getCallsHistoryLoadMore = false,
    this.getAllNotificationLoadMore = false,
    this.getAllUsersLoadMore = false,
    this.searchContacts = false,
    this.searchNotifications = false,
    this.userHaveStory = false,
    this.currentContactPage = 1,
    this.unreadNotificationCount = 0,
    this.allUserData,
    this.conversationModel,
    this.conversationModelForForwardMessages,
    this.storiesModel,
    this.displayedContacts = const [],
    this.callHistory = const [],
    this.allNotification = const [],
    this.homeErrorMessage,
    this.storiesErrorMessage,
    Set<ContactUser>? otherContact,
  }) : otherContact = otherContact ?? {};

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
    LoadingState? getCallHistoryLoadingState,
    LoadingState? getAllNotificationsLoadingState,
    bool? getAllUsersLoadMore,
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
    AllUserData? allUserData,
    int? unreadNotificationCount,
  }) {
    return HomeState(
      homeLoadingState: homeLoadingState ?? this.homeLoadingState,
      storiesLoadingState: storiesLoadingState ?? this.storiesLoadingState,
      paginationLoadingState:
          paginationLoadingState ?? this.paginationLoadingState,
      getAllUsersLoadingState:
          getAllUsersLoadingState ?? this.getAllUsersLoadingState,
      contactsLoadingState: contactsLoadingState ?? this.contactsLoadingState,
      getCallHistoryLoadingState:
          getCallHistoryLoadingState ?? this.getCallHistoryLoadingState,
      getAllNotificationsLoadingState: getAllNotificationsLoadingState ??
          this.getAllNotificationsLoadingState,
      getCallsHistoryLoadMore:
          getCallsHistoryLoadMore ?? this.getCallsHistoryLoadMore,
      getAllNotificationLoadMore:
          getAllNotificationLoadMore ?? this.getAllNotificationLoadMore,
      getAllUsersLoadMore: getAllUsersLoadMore ?? this.getAllUsersLoadMore,
      searchContacts: searchContacts ?? this.searchContacts,
      searchNotifications: searchNotifications ?? this.searchNotifications,
      currentContactPage: currentContactPage ?? this.currentContactPage,
      allUserData: allUserData ?? this.allUserData,
      conversationModel: conversationModel ?? this.conversationModel,
      conversationModelForForwardMessages:
          conversationModelForForwardMessages ??
              this.conversationModelForForwardMessages,
      storiesModel: storiesModel ?? this.storiesModel,
      displayedContacts: displayedContacts ?? this.displayedContacts,
      otherContact: otherContact ?? this.otherContact,
      callHistory: callHistory ?? this.callHistory,
      allNotification: allNotification ?? this.allNotification,
      unreadNotificationCount:
          unreadNotificationCount ?? this.unreadNotificationCount,
      userHaveStory: userHaveStory ?? this.userHaveStory,
    );
  }

  @override
  List<Object?> get props => [
        homeLoadingState,
        storiesLoadingState,
        paginationLoadingState,
        getAllUsersLoadingState,
        contactsLoadingState,
        getCallHistoryLoadingState,
        getAllNotificationsLoadingState,
        getCallsHistoryLoadMore,
        getAllNotificationLoadMore,
        getAllUsersLoadMore,
        otherContact,
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
        allUserData,
        unreadNotificationCount,
        userHaveStory
      ];
}
