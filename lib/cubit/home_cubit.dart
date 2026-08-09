import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:two_one_two_messenger/database/message_db_repo.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/all_user.dart';
import 'package:two_one_two_messenger/models/call_history_model.dart';
import 'package:two_one_two_messenger/models/chat_message_model.dart';
import 'package:two_one_two_messenger/models/common_res.dart';
import 'package:two_one_two_messenger/models/group_info_model.dart';
import 'package:two_one_two_messenger/models/notification_model.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/services/local_contact_service.dart';
import 'package:two_one_two_messenger/services/push_notifications.dart';
import 'package:two_one_two_messenger/services/socket_service.dart';
import 'package:two_one_two_messenger/utils/constants.dart';

import '../database/local_db.dart';
import '../models/conversation_model.dart';
import '../models/stories_response.dart';
import '../services/api_client.dart';
import '../utils/utils.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final ApiClient apiClient;
  final DatabaseHelper dbHelper;
  final MessageRepository messageRepo;
  // List<ConversationData> conversationList = [];
  // List<GetAllStoriesData> storiesList = [];
  // GetAllStoriesResponse? getAllStoriesResponse;
  int limit = 50;
  final ContactService contactService;
  bool isFetchingMore = false;
  List<ContactUser> _contacts = [];

  HomeCubit(this.apiClient, this.dbHelper, this.contactService)
      : messageRepo = MessageRepository(dbHelper),
        super(HomeState.initial());
  Future<void> resetState() async {
    emit(HomeState.initial());
    await Future.delayed(Durations.extralong1);
  }

  void changeDropdownValue(String newValue) {
    // emit(newValue);
  }
  void archiveChat(String userId, String chatId) {
    SocketService().sendEvent(
        AppConstants.archiveChat, {"userId": userId, "chatId": chatId});
  }

  void unArchiveChat(String userId, String chatId) {
    SocketService().sendEvent(
        AppConstants.unArchiveChat, {"userId": userId, "chatId": chatId});
  }

  void pinUnPinToggleChat(String userId, String chatId, bool isPin) {
    SocketService().sendEvent(AppConstants.pinUnpinConversation,
        {"userId": userId, "chatId": chatId, "isPin": isPin});
  }

// Future<void> updateConversationList(BuildContext context, String conversationId, ChatData lastMessage){}
  Future<void> getConversation({
    required BuildContext context,
    String? searchTerm,
  }) async {
    if (state.conversationModel == null ||
        (state.conversationModel?.data ?? []).isEmpty) {
      emit(state.copyWith(homeLoadingState: LoadingState.loading));
    }
    try {
      Map<String, dynamic>? params = {};
      if ((searchTerm ?? "").isNotEmpty) {
        params["searchTerm"] = searchTerm;
      }

      ConversationModel response =
          await apiClient.getConversation(context: context, params: params);

      if (response.status == Utils.APISUCCESS) {
        emit(state.copyWith(
            homeLoadingState: LoadingState.success,
            conversationModel: response));
        // conversationList = response.data??[];
      } else {
        emit(state.copyWith(
          homeLoadingState: LoadingState.success,
        ));
      }
    } catch (e, st) {
      Utils.showSnackBar(context, S.current.somethingWentWrongPleaseTryAgain);
      showMessage("Error in get Conversation == $e ,$st");
      emit(state.copyWith(
          homeErrorMessage: e.toString(),
          homeLoadingState: LoadingState.error));
    }
  }

  Future<void> getConversationForForwadMessage({
    required BuildContext context,
    String? searchTerm,
  }) async {
    if (state.conversationModelForForwardMessages == null ||
        (state.conversationModelForForwardMessages?.data ?? []).isEmpty) {
      emit(state.copyWith(homeLoadingState: LoadingState.loading));
    }
    try {
      Map<String, dynamic>? params = {};
      if ((searchTerm ?? "").isNotEmpty) {
        params["searchTerm"] = searchTerm;
      }

      ConversationModel response = await apiClient
          .getConversationForForwadMessage(context: context, params: params);

      if (response.status == Utils.APISUCCESS) {
        emit(state.copyWith(
            homeLoadingState: LoadingState.success,
            conversationModelForForwardMessages: response));
        // conversationList = response.data??[];
      } else {
        emit(state.copyWith(
          homeLoadingState: LoadingState.success,
        ));
      }
    } catch (e, st) {
      Utils.showSnackBar(context, S.current.somethingWentWrongPleaseTryAgain);
      showMessage("Error in get Conversation == $e ,$st");
      emit(state.copyWith(
          homeErrorMessage: e.toString(),
          homeLoadingState: LoadingState.error));
    }
  }

  Future<void> getAgoraAppId() async {
    final response = await apiClient.getAppIdForAgora();
    if (response.status == Utils.APISUCCESS) {
      await AppPreference.setAgoraAppId(response.data?.appId ?? "");
    }
  }

  // Independent of getAgoraAppId on purpose: this used to run as a tail end
  // of that method with no error handling, so a failure fetching the Agora
  // app id (an unrelated call) silently aborted FCM token registration too.
  // Call both from HomeScreen's init, unawaited, so one can never block the
  // other.
  Future<void> registerFcmTokenForCurrentUser() async {
    try {
      final userId = AppPreference.getCurrentUserId();
      if (userId.isEmpty) return;
      final newToken = await FireBaseNotification().getToken();
      if (newToken.isEmpty) return;
      await FireBaseNotification().updateFcmToken(apiClient, {
        "userId": userId,
        "deviceToken": newToken,
        "deviceType": Platform.isAndroid ? 'Android' : 'ios',
      });
    } catch (e, st) {
      debugPrint("Error registering FCM token ==>$e  $st");
      FirebaseCrashlytics.instance.recordError(e, st);
    }
  }

  Future<void> updateConversationById({
    required MessageModel lastMessage,
  }) async {
    final updatedConversationList =
        List<ConversationData>.from(state.conversationModel?.data ?? []).map(
      (e) {
        if (e.id == lastMessage.chatId) {
          return e.copyWith(
            lastMessage: LastMessage(
                content: lastMessage.content,
                createdAt: lastMessage.createdAt,
                id: lastMessage.id,
                sender: lastMessage.sender),
            // unreadMessageCount: (e.unreadMessageCount??0)+1
          );
        } else {
          return e;
        }
      },
    ).toList();
    final updateConversation =
        state.conversationModel?.copyWith(data: updatedConversationList);
    emit(state.copyWith(conversationModel: updateConversation));
  }

  Future<void> getStoriesData(int page, BuildContext context) async {
    emit(state.copyWith(storiesLoadingState: LoadingState.loading));
    try {
      storyCubit.getLoggedInUserStories(context).then(
        (value) {
          emit(state.copyWith(
              userHaveStory:
                  storyCubit.state.currentUserStoriesList.isNotEmpty));
        },
      );
      GetAllStoriesResponse response =
          await apiClient.getStoriesData(page, limit, context);
      if (response.status == Utils.APISUCCESS) {
        emit(state.copyWith(
          storiesLoadingState: LoadingState.success,
          storiesModel: response,
        ));
      } else {
        emit(state.copyWith(storiesLoadingState: LoadingState.success));
      }
      // emit(
      //   state.copyWith(storiesLoadingState: LoadingState.success,storiesModel: response,)
      //  );
      // emit(StoriesLoaded(response, storiesList));
    } catch (e, st) {
      // Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""));
      showMessage("Error in getStoriesData==> $e, $st");
      emit(state.copyWith(
          storiesErrorMessage: e.toString(),
          storiesLoadingState: LoadingState.error));
    }
  }

  Future<void> refreshStoriesData(BuildContext context) async {
    // emit(state.copyWith(storiesLoadingState: LoadingState.loading));
    try {
      if ((state.storiesModel?.data ?? []).isEmpty) return;
      GetAllStoriesResponse response =
          await apiClient.getStoriesData(1, limit, context);
      if (response.status == Utils.APISUCCESS) {
        emit(state.copyWith(
          storiesLoadingState: LoadingState.success,
          storiesModel: response,
        ));
      } else {
        emit(state.copyWith(storiesLoadingState: LoadingState.success));
      }
      // emit(
      //   state.copyWith(storiesLoadingState: LoadingState.success,storiesModel: response,)
      //  );
      // emit(StoriesLoaded(response, storiesList));
    } catch (e, st) {
      // Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""));
      showMessage("Error in getStoriesData==> $e, $st");
      emit(state.copyWith(
          storiesErrorMessage: e.toString(),
          storiesLoadingState: LoadingState.error));
    }
  }

  Future<void> fetchStoriesMoreData(int page, BuildContext context) async {
    showMessage("fetchStoriesMoreData==> $page ,$isFetchingMore");
    if (isFetchingMore) return;
    isFetchingMore = true;

    try {
      if (page > state.storiesModel!.pagination!.totalPages!) {
        return;
      }

      emit(state.copyWith(paginationLoadingState: LoadingState.loading));
      GetAllStoriesResponse response =
          await apiClient.getStoriesData(page, limit, context);
      if (response.status == Utils.APISUCCESS) {
        List<GetAllStoriesData> updatedList = (state.storiesModel?.data ?? []);
        updatedList.addAll(response.data!);

        GetAllStoriesResponse updateStoryResponse =
            state.storiesModel!.copyWith(data: updatedList);
        emit(state.copyWith(
            paginationLoadingState: LoadingState.success,
            storiesModel: updateStoryResponse));
      } else {
        emit(state.copyWith(
          paginationLoadingState: LoadingState.success,
        ));
      }
    } catch (e) {
      Utils.showSnackBar(context, S.current.somethingWentWrongPleaseTryAgain);
      emit(state.copyWith(
          paginationLoadingState: LoadingState.error,
          storiesErrorMessage: e.toString()));
    } finally {
      isFetchingMore = false;
    }
  }

  Future<void> fetchContactsForSync(BuildContext context) async {
    try {
      final response = await apiClient.syncContact(context);

      if (response.status == Utils.APISUCCESS) {
        // await contactService.syncApiUsersWithContacts(
        //   context: context,
        //   searchQuery: "",
        //   page: 1,
        //   limit: 10000,
        //   removedUsers: [],
        // );
      } else {
        // Utils.showSnackBar(context, message);
      }
    } catch (e, st) {
      log("Error while Sync Contact $e $st");
    }
  }

//   Future<void> fetchContacts(String searchQuery) async {
//     if (searchQuery.isEmpty) {
//       emit(state.copyWith(searchContacts: false));
//        await contactService.fetchAndStoreLocalContacts();
//    _contacts = await contactService.getAllLocalContacts();
//     }else{
//        _contacts = await contactService.getAllLocalContacts();
//     }

//     _paginateContacts(searchQuery);
//   }

//   void _paginateContacts(String searchQuery) {
//     int startIndex = (state.currentContactPage - 1) * limit;
//     int endIndex = startIndex + limit;

//     final displayedContacts = contactService.searchContacts(context, searchQuery, page, limit)

//     _contacts
//         .where((c) => c.name != null)
//         .where((c) => c.name!.toLowerCase().contains(searchQuery.toLowerCase()))
//         .skip(startIndex)
//         .take(limit)
//         .toList();

// contactService.

//     final existingPhones = state.displayedContacts.map((c) => c.phone).toSet();
//     final newContacts = displayedContacts
//         .where((c) => !existingPhones.contains(c.phone))
//         .toList();

//     emit(state.copyWith(
//       contactsLoadingState: LoadingState.success,
//       displayedContacts: [...state.displayedContacts, ...newContacts],
//     ));
//   }

//   void loadMoreContacts(String searchQuery) {
//     if ((state.currentContactPage * limit) < _contacts.length) {
//       emit(state.copyWith(currentContactPage: state.currentContactPage + 1));
//       _paginateContacts(searchQuery);
//     }
//   }

// Future<void> listionAndChangeStoryUserProfile(){

// }
  Future<void> fetchContacts(BuildContext context, String searchQuery) async {
    emit(state.copyWith(contactsLoadingState: LoadingState.loading));
    if (searchQuery.isEmpty) {
      emit(state.copyWith(searchContacts: false));
      await contactService.fetchAndStoreLocalContacts();

      // Collect device contact phone numbers from SQLite to send to the backend.
      // The backend uses these to find only users whose phone matches a saved contact.
      final List<ContactUser> deviceContacts = await dbHelper.getAllContacts();
      final List<String> contactNumbers = deviceContacts
          .map((c) => c.phone ?? "")
          .where((p) => p.isNotEmpty)
          .toList();

      await contactService.syncApiUsersWithContacts(
        context: context,
        searchQuery: "",
        contactNumbers: contactNumbers,
        page: 1,
        limit: 10000,
        removedUsers: [],
      );
    }

    await _paginateContacts(context, searchQuery, isApiCallRequired: true);
  }

  Future<void> _paginateContacts(BuildContext context, String searchQuery,
      {bool isApiCallRequired = false, isFromScroll = false}) async {
    int startIndex = (state.currentContactPage - 1) * limit;

    // 1️⃣ Fetch paginated contacts from the local database
    List<ContactUser> localContacts = await contactService.searchContacts(
        context, searchQuery, state.currentContactPage, limit);

    // 2️⃣ If enough local results are found, return them immediately
    // if (localContacts.length >= limit || searchQuery.isEmpty) {
    //   emit(state.copyWith(
    //     contactsLoadingState: LoadingState.success,
    //     displayedContacts: <ContactUser>{
    //       ...state.displayedContacts,
    //       ...localContacts
    //     }.toList(),
    //   ));
    //   return;
    // }

    // // 3️⃣ If not enough results, call the API and update the local database
    // if (isApiCallRequired) {
    //   await contactService.syncApiUsersWithContacts(
    //     context: context,
    //     searchQuery: searchQuery,
    //     page: state.currentContactPage,
    //     limit: limit,
    //     removedUsers: [],
    //   );

    //   // 4️⃣ Fetch the updated contacts from the local database
    //   List<ContactUser> updatedContacts = await contactService.searchContacts(
    //       context, searchQuery, state.currentContactPage, limit);

    //   emit(state.copyWith(
    //     contactsLoadingState: LoadingState.success,
    //     displayedContacts: [...state.displayedContacts, ...updatedContacts],
    //   ));
    // }
    if (!isFromScroll) {
      List<ContactUser> otherUser = [];
      if (searchQuery.isNotEmpty) {
        otherUser = await contactService.syncApiUsersWithContacts(
          context: context,
          searchQuery: searchQuery,
          page: state.currentContactPage,
          limit: limit,
          removedUsers: [],
          contactNumbers: [],
        );
      }
      showMessage("other Users== ${otherUser.length}");
      emit(state.copyWith(
        contactsLoadingState: LoadingState.success,
        displayedContacts: <ContactUser>{
          ...state.displayedContacts,
          ...localContacts
        }.toList(),
        otherContact: Set.from(otherUser),
      ));
    } else {
      //showMessage("other Users== ${otherUser.length}");
      emit(state.copyWith(
        contactsLoadingState: LoadingState.success,
        displayedContacts: <ContactUser>{
          ...state.displayedContacts,
          ...localContacts
        }.toList(),
        // otherContact: Set.from(otherUser),
      ));
    }
  }

  // Future<void> _paginateContacts(BuildContext context, String searchQuery,
  //     {bool isApiCallRequired = false}) async {
  //   int startIndex = (state.currentContactPage - 1) * limit;

  //   // 1️⃣ Fetch paginated contacts from the local database
  //   List<ContactUser> localContacts = await contactService.searchContacts(
  //       context, searchQuery, state.currentContactPage, limit);

  //   // 2️⃣ If enough local results are found, return them immediately
  //   if (localContacts.length >= limit || searchQuery.isEmpty) {
  //     emit(state.copyWith(
  //       contactsLoadingState: LoadingState.success,
  //       displayedContacts: <ContactUser>{
  //         ...state.displayedContacts,
  //         ...localContacts
  //       }.toList(),
  //     ));
  //     return;
  //   }

  //   // // 3️⃣ If not enough results, call the API and update the local database
  //   // if (isApiCallRequired) {
  //   //   await contactService.syncApiUsersWithContacts(
  //   //     context: context,
  //   //     searchQuery: searchQuery,
  //   //     page: state.currentContactPage,
  //   //     limit: limit,
  //   //     removedUsers: [],
  //   //   );

  //   //   // 4️⃣ Fetch the updated contacts from the local database
  //   //   List<ContactUser> updatedContacts = await contactService.searchContacts(
  //   //       context, searchQuery, state.currentContactPage, limit);

  //   //   emit(state.copyWith(
  //   //     contactsLoadingState: LoadingState.success,
  //   //     displayedContacts: [...state.displayedContacts, ...updatedContacts],
  //   //   ));
  //   // }

  //   emit(state.copyWith(
  //     contactsLoadingState: LoadingState.success,
  //     displayedContacts:
  //         <ContactUser>{...state.displayedContacts, ...localContacts}.toList(),
  //   ));
  // }

  void loadMoreContacts(BuildContext context, String searchQuery) {
    emit(state.copyWith(currentContactPage: state.currentContactPage + 1));
    _paginateContacts(context, searchQuery,
        isApiCallRequired: true, isFromScroll: true);
  }

  Timer? debounceTimer;

  void onSearchNotifications({
    required BuildContext context,
    required String searchQuery,
  }) {
    if (debounceTimer != null) {
      debounceTimer!.cancel();
    }

    debounceTimer = Timer(
      Duration(seconds: 1),
      () {
        getNotifications(
            context: context, isLoadMore: false, searchQuery: searchQuery);
      },
    );
  }

  void handleSearchNotifications(BuildContext context, void Function() onTap) {
    emit(state.copyWith(searchNotifications: !state.searchNotifications));

    // if (state.searchNotifications) {
    onTap();
    getNotifications(context: context, isLoadMore: false, searchQuery: '');
    // }
  }

  void onSearchContact(
    BuildContext context,
    String query,
  ) {
    if (debounceTimer != null) {
      debounceTimer!.cancel();
    }

    debounceTimer = Timer(
      Duration(seconds: 1),
      () {
        emit(state.copyWith(currentContactPage: 1, displayedContacts: []));
        _paginateContacts(context, query, isApiCallRequired: true);
      },
    );
  }

  void handleSearchContact(BuildContext context, void Function() onTap) {
    emit(state.copyWith(searchContacts: !state.searchContacts));

    if (state.searchContacts) {
      onTap.call();
      _paginateContacts(context, "");
    }
  }

// Future<void> getAllUserData(
//       ) async {
//     emit(state.copyWith());
//     try {
//       AllUserResponse response = await apiClient.getAllUser(name, page, limit,context);
//       if (response.status == Utils.APISUCCESS) {
//         allUsers = response.data!.users!;
//         totalPage = response.data!.totalPages!;
//         callback?.call();
//       }
//       emit(SearchSuccess());
//       emit(SearchLoaded(response, allUsers, totalPage));
//     } catch (e) {
//       Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""));
//       emit(SearchError(e.toString()));
//     }
//   }
  int getAllUserCurrentPage = 1;
  Future<void> getAllUserData({
    required String name,
    required BuildContext context,
    required bool isLoadMore,
    required List<Participant> removedUsers,
  }) async {
    try {
      if ((state.allUserData?.users ?? []).isEmpty) {
        emit(state.copyWith(getAllUsersLoadingState: LoadingState.loading));
      }

      if (isLoadMore) {
        emit(state.copyWith(getAllUsersLoadMore: isLoadMore));
      }

      final List<ContactUser> deviceContacts = await dbHelper.getAllContacts();
      final List<String> contactNumbers = deviceContacts
          .map((c) => c.phone ?? "")
          .where((p) => p.isNotEmpty)
          .toList();

      AllUserResponse response = await apiClient.getAllUser(
          name, isLoadMore ? getAllUserCurrentPage + 1 : 1, limit, context, contactNumbers);
      if (response.status == Utils.APISUCCESS) {
        AllUserData allUserData = AllUserData.fromJson(response.data!.toJson());
        // ✅ Extract user IDs from removedUsers
        final removedUserIds =
            removedUsers.map((participant) => participant.id).toSet();

        final newList = (isLoadMore
                ? [
                    ...(state.allUserData?.users ?? []),
                    ...response.data?.users ?? []
                  ].cast<UserData>()
                : response.data?.users ?? [])
            .where((user) =>
                !removedUserIds.contains(user.sId)) // ✅ Filter removed users
            .toList();
        if (isLoadMore && response.data?.currentPage != null) {
          if (response.data!.currentPage! > response.data!.totalPages!) {
            emit(state.copyWith(
                getAllUsersLoadingState: LoadingState.success,
                getAllUsersLoadMore: false));
            return;
          }

          getAllUserCurrentPage = response.data!.currentPage!;
        } else {
          getAllUserCurrentPage = 1;
        }
        emit(state.copyWith(
            getAllUsersLoadMore: false,
            allUserData: allUserData.copyWith(users: newList),
            getAllUsersLoadingState: LoadingState.success));
      } else {
        emit(state.copyWith(
            getAllUsersLoadingState: LoadingState.success,
            getAllUsersLoadMore: false));
      }
    } catch (e, st) {
      // Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""),
      //     seconds: 3);
      showMessage("Error all Users== $e, $st");
      showMessage("Error==> $e, $st");
      emit(state.copyWith(
          getAllUsersLoadingState: LoadingState.error,
          getAllUsersLoadMore: false));
    } finally {}
  }

  Future<void> deleteChat(BuildContext context, String chatId) async {
    try {
      // emit(state.copyWith(groupLoadingState: LoadingState.loading));
      Utils.showLoader();
      CommonResponseModel response = await apiClient.deleteChat(chatId: chatId);
      if (response.status == Utils.APISUCCESS) {
        await messageRepo.clearChat(
          chatId: chatId,
        );
        getConversation(context: context);
        Utils.showSnackBar(context, response.message ?? "");
      }
    } catch (e, st) {
      showMessage("Error in getGroupInfobyId==> $e, $st");
      // emit(state.copyWith(groupLoadingState: LoadingState.error));
    } finally {
      Utils.hideLoader();
    }
  }

  int getAllCallsCurrentPage = 1;
  Future<void> getCallsHistory({
    required BuildContext context,
    required bool isLoadMore,
  }) async {
    try {
      if ((state.callHistory ?? []).isEmpty) {
        emit(state.copyWith(getCallHistoryLoadingState: LoadingState.loading));
      }

      if (isLoadMore) {
        emit(state.copyWith(getCallsHistoryLoadMore: isLoadMore));
      }
      CallHistoryResponse response = await apiClient.getAllCallsHistory(
          isLoadMore ? getAllCallsCurrentPage + 1 : 1, limit, context);
      if (response.status == Utils.APISUCCESS) {
        final newList = (isLoadMore
                ? [
                    ...(state.callHistory ?? []),
                    ...response.data?.callHistoryList ?? []
                  ].cast<CallHistoryList>()
                : response.data?.callHistoryList ?? [])
            .toList();
        if (isLoadMore && response.data?.pagination?.currentPage != null) {
          if (response.data!.pagination!.currentPage! >
              response.data!.pagination!.totalPages!) {
            emit(state.copyWith(
                getCallHistoryLoadingState: LoadingState.success,
                getCallsHistoryLoadMore: false));
            return;
          }

          getAllCallsCurrentPage = response.data!.pagination!.currentPage!;
        } else {
          getAllCallsCurrentPage = 1;
        }
        emit(state.copyWith(
            getCallsHistoryLoadMore: false,
            callHistory: newList,
            getCallHistoryLoadingState: LoadingState.success));
      } else {
        emit(state.copyWith(
            getCallHistoryLoadingState: LoadingState.success,
            getCallsHistoryLoadMore: false));
      }
    } catch (e, st) {
      showMessage("Error in getCallsHistory==> $e, $st");
      emit(state.copyWith(
          getCallHistoryLoadingState: LoadingState.error,
          getCallsHistoryLoadMore: false));
    } finally {}
  }

  int getNotificationsCurrentPage = 1;
  Future<void> getNotifications({
    required BuildContext context,
    required bool isLoadMore,
    required String searchQuery,
  }) async {
    try {
      if ((state.allNotification ?? []).isEmpty) {
        emit(state.copyWith(
            getAllNotificationsLoadingState: LoadingState.loading));
      }

      if (isLoadMore) {
        emit(state.copyWith(getAllNotificationLoadMore: isLoadMore));
      }

      final Map<String, dynamic> params = {
        "page": isLoadMore ? getNotificationsCurrentPage + 1 : 1,
        "limit": limit,
        "search": searchQuery
      };
      NotificationsResponse response = await apiClient.getAllNotifications(
          queryparams: params, context: context);
      if (response.status == Utils.APISUCCESS) {
        final newList = (isLoadMore
                ? [
                    ...(state.allNotification ?? []),
                    ...response.data?.notifications ?? []
                  ].cast<NotificationData>()
                : response.data?.notifications ?? [])
            .toList();
        if (isLoadMore && response.data?.pagination?.currentPage != null) {
          if (response.data!.pagination!.currentPage! >
              response.data!.pagination!.totalPages!) {
            emit(state.copyWith(
                getAllNotificationsLoadingState: LoadingState.success,
                getAllNotificationLoadMore: false));
            return;
          }

          getNotificationsCurrentPage = response.data!.pagination!.currentPage!;
        } else {
          getNotificationsCurrentPage = 1;
        }
        emit(state.copyWith(
            getAllNotificationLoadMore: false,
            allNotification: newList,
            getAllNotificationsLoadingState: LoadingState.success));
      } else {
        emit(state.copyWith(
            getAllNotificationsLoadingState: LoadingState.success,
            getAllNotificationLoadMore: false));
      }
    } catch (e, st) {
      showMessage("Error getNotifications==> $e, $st");
      emit(state.copyWith(
          getAllNotificationsLoadingState: LoadingState.error,
          getAllNotificationLoadMore: false));
    } finally {}
  }

  void updateNotificationCount(int count) {
    emit(state.copyWith(unreadNotificationCount: count));
  }

  Future<void> respondToInvite(
      BuildContext context, String notificationId, String action) async {
    if (state.respondingInviteIds.contains(notificationId)) return;

    emit(state.copyWith(
        respondingInviteIds: {...state.respondingInviteIds, notificationId}));

    try {
      final updatedNotification = await apiClient.respondToInvite(
        notificationId: notificationId,
        action: action,
      );

      final updatedList = state.allNotification
          .map((notification) => notification.id == notificationId
              ? notification.copyWith(
                  status: updatedNotification.status,
                  content: updatedNotification.content,
                )
              : notification)
          .toList();

      emit(state.copyWith(
        allNotification: updatedList,
        respondingInviteIds: {...state.respondingInviteIds}
          ..remove(notificationId),
      ));
    } catch (e, st) {
      showMessage("Error respondToInvite==> $e, $st");
      Utils.showSnackBar(context, S.of(context).somethingWentWrong);
      emit(state.copyWith(
        respondingInviteIds: {...state.respondingInviteIds}
          ..remove(notificationId),
      ));
    }
  }

  Future<void> clearCallLog(
      BuildContext context, List<String> callIdList) async {
    try {
      // emit(state.copyWith(groupLoadingState: LoadingState.loading));
      Utils.showLoader();
      CommonMessageResponse response =
          await apiClient.clearCallLogs(callIdList);
      if (response.status == Utils.APISUCCESS) {
        getCallsHistory(context: context, isLoadMore: false);
        // Utils.showSnackBar(context, response.message??"");
      } else {
        // emit(state.copyWith(groupLoadingState: LoadingState.success));
      }
    } catch (e, st) {
      showMessage("Error in getGroupInfobyId==> $e, $st");
      // emit(state.copyWith(groupLoadingState: LoadingState.error));
    } finally {
      Utils.hideLoader();
    }
  }

  Future<void> blockedUser(
      {required String chatId,
      required String userId,
      required BuildContext context,
      required void Function() callback}) async {
    try {
      // emit(state.copyWith(groupLoadingState: LoadingState.loading));
      Utils.showLoader();

      CommonResponseModel response = await apiClient.blockedUser(
          chatId: chatId, userId: userId, context: context);
      if (response.status == Utils.APISUCCESS) {
        log("block user done ${response.toJson()}");
        callback.call();
      } else {
        // emit(state.copyWith(groupLoadingState: LoadingState.success));
      }
    } catch (e, st) {
      showMessage("Error in getGroupInfobyId==> $e, $st");
      // emit(state.copyWith(groupLoadingState: LoadingState.error));
    } finally {
      Utils.hideLoader();
    }
  }

  Future<void> unBlockedUser(
      {required String userId,
      required BuildContext context,
      required void Function() callback}) async {
    try {
      // emit(state.copyWith(groupLoadingState: LoadingState.loading));
      Utils.showLoader();
      CommonResponseModel response =
          await apiClient.unBlockedUser(userId: userId, context: context);
      if (response.status == Utils.APISUCCESS) {
        callback.call();
        // Utils.showSnackBar(context, response.message??"");
      } else {
        // emit(state.copyWith(groupLoadingState: LoadingState.success));
      }
    } catch (e, st) {
      showMessage("Error in getGroupInfobyId==> $e, $st");
      // emit(state.copyWith(groupLoadingState: LoadingState.error));
    } finally {
      Utils.hideLoader();
    }
  }

  Future<void> reportUser({
    required String userId,
    required String userName,
    required String reason,
    required String description,
    required BuildContext context,
    // required void Function() callback
  }) async {
    try {
      // emit(state.copyWith(groupLoadingState: LoadingState.loading));
      Utils.showLoader();
      Map<String, dynamic> data = {
        "reportedUser": userId,
        "reason": reason,
        "description": description
      };
      CommonResponseModel response =
          await apiClient.reportUser(data: data, context: context);
      if (response.status == Utils.APISUCCESS) {
        Utils.showSnackBar(
            context, S.current.youHaveSuccesfullyRepoartuser(userName));
      } else {
        Utils.showSnackBar(context, response.message ?? "");
      }
    } catch (e, st) {
      showMessage("Error in getGroupInfobyId==> $e, $st");
      Utils.showSnackBar(context, S.current.somethingWentWrongPleaseTryAgain);
      // emit(state.copyWith(groupLoadingState: LoadingState.error));
    } finally {
      Utils.hideLoader();
    }
  }

  Future<void> clearAllNotification(
      {Function(CommonResponseModel)? callback}) async {
    try {
      Utils.showLoader();
      CommonResponseModel response = await apiClient.clearAllNotification();
      if (response.status == Utils.APISUCCESS) {
        emit(state.copyWith(
            getAllNotificationLoadMore: false,
            allNotification: [],
            getAllNotificationsLoadingState: LoadingState.success));
        callback?.call(response);
      }
    } catch (e, st) {
      // Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""),
      //     seconds: 3);
      showMessage("Error ==> $e $st");
    } finally {
      Utils.hideLoader();
    }
  }

  void toggleBlockUnBlock({required int index, required bool youBlocked}) {
    state.displayedContacts[index].youBlocked = youBlocked;
  }

  void updateChatDisAppear({required int index, required int timeValue}) {
    state.displayedContacts[index].messageAutoDeleteTime = timeValue;
  }

  void updateNickNameFromContact({
    required int index,
    required String? nickName,
    required bool? isActiveNickname,
    required ContactUser contactUser,
  }) {
    //  state.displayedContacts[index].nickName = nickName;
    List<ContactUser> displayedContacts = List.from(state.displayedContacts);
    // displayedContacts[index].nickName = nickName;
    ContactUser updatedContactUser = contactUser.copyWith(
      nickName: nickName,
      isActiveNickname: isActiveNickname,
    );
    displayedContacts[index] = updatedContactUser;
    emit(state.copyWith(displayedContacts: displayedContacts));
  }

  void updateStatusFromContact({
    required int index,
    required bool newStatus,
    required ContactUser contactUser,
  }) {
    List<ContactUser> displayedContacts = List.from(state.displayedContacts);
    // displayedContacts[index].nickName = nickName;
    ContactUser updatedContactUser =
        contactUser.copyWith(isActiveNickname: newStatus);
    displayedContacts[index] = updatedContactUser;
    emit(state.copyWith(displayedContacts: displayedContacts));
  }
}
