import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:two_one_two_messenger/database/message_db_repo.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/models/nick_name/nick_name_response.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/models/saved_messages.dart';
import 'package:two_one_two_messenger/models/toggle_nickname_response.dart';
import 'package:two_one_two_messenger/models/token_and_channel.dart';
import 'package:two_one_two_messenger/services/encryption_service.dart';
import 'package:two_one_two_messenger/services/pagination_handler.dart';
import 'package:two_one_two_messenger/services/socket_service.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/media_storage_helper.dart';

import '../database/local_db.dart';
import '../models/chat_message_model.dart';
import '../models/create_conversaion_model.dart';
import '../models/sent_message_model.dart';
import '../services/api_client.dart';
import '../utils/utils.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ApiClient apiClient;
  final DatabaseHelper dbHelper;
  final MessageRepository messageRepo;
  // final String currentUserId;

  // CreateConversionData conversionData = CreateConversionData();
  // List<ChatData> chatList = [];
  bool isChatPage = false;
  String chatId = '';
  final ImagePicker picker = ImagePicker();
  List<XFile> selectedFile = [];
  final _socketService = SocketService();

  ChatCubit(this.apiClient, this.dbHelper)
      : messageRepo = MessageRepository(dbHelper),
        super(ChatState.initial());

  void changeDropdownValue(String newValue) {
    // emit(newValue);
  }

  // void handleIsSendMessageValue(bool newValue,String isCallFrom) {
  //   emit(state.copyWith(isSendMessage: newValue));
  //   log("handleIsSendMessageValue $isCallFrom $newValue  ${state.isSendMessage}");
  // }

  void changeChatPageStatus(String chatId, bool isChat, String userId) {
    isChatPage = isChat;
    this.chatId = chatId;

    emit(state.copyWith(
      currentConversationId: chatId,
    ));
    final data = {"userId": userId, "chatId": chatId};
    showMessage("changeChatPageStatus $data");
    _socketService.sendEvent(AppConstants.chatClosed, data);
  }

  void updateOnlineLastStatus({required dynamic data}) {
    log("updateOnlineLastStatus ${data}");
    if (chatId.isNotEmpty) {
      ChatMessageModel? chatMessageModel = state.chatMessageModel;
      chatMessageModel = chatMessageModel?.copyWith(
          lastSeen: data["lastSeen"] == null
              ? null
              : DateTime.parse(data["lastSeen"]).toLocal(),
          isOnline: data["isOnline"]);

      showMessage("updateOnlineLastStatus ${chatMessageModel?.isOnline}");

      emit(state.copyWith(
          chatMessageModel: chatMessageModel,
          currentTypingusers: data["isOnline"] ? null : []));
    }
  }

  Future<void> createConversation(String userId, BuildContext context) async {
    emit(state.copyWith(createConversationState: LoadingState.loading));
    try {
      CreateConversionModel response =
          await apiClient.createConversion(userId, context);
      if (response.status == Utils.APISUCCESS) {
        emit(state.copyWith(
            createConversationState: LoadingState.success,
            currentConversationId: response.data!.id,
            createConversationModel: response.data!));
      } else {
        emit(state.copyWith(
          createConversationState: LoadingState.success,
        ));
      }
    } catch (e, st) {
      showMessage("Error createConversation $e,$st");
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""),
          seconds: 3);
      emit(state.copyWith(
          createConversationState: LoadingState.error,
          createConversationErrorMessage: e.toString()));
    }
  }

  Future<void> changeCallType({required CallType callType}) async {
    emit(state.copyWith(callType: callType));
  }

  Future<void> toggleSpeaker(bool value) async {
    emit(state.copyWith(isSpeaker: value));
  }

  Future<TokenAndChannel?> generateTokenAndChannelName(
      {required BuildContext context,
      required Map<String, dynamic> data,
      required String chatId}) async {
    try {
      final response = await apiClient.requestCall(
          chatId: chatId, data: data, context: context);
      if (response.status == Utils.APISUCCESS) {
        return TokenAndChannel.fromJson(response.data!.toJson());
      } else {
        showMessage(response.message ?? "");
        // showToast(response.message);
        return null;
      }
    } catch (e, st) {
      showMessage('generateTokenAndChannelName: $e, $st');
      // showToast(NameData.failedToGenerateToken);
      return null;
    }
  }

  Future<void> resetChatScreenState() async {
    emit(state.copyWith(
        chatLoadingState: LoadingState.success,
        chatMessageModel: ChatMessageModel(),
        chatList: Set.of([])));
    await Future.delayed(Durations.extralong1);
  }

  final PaginationController chatPaginationController =
      PaginationController(limit: 50);

  int chatCurrentPage = 1;
  int chatTotalPage = 1;
  // Future<void> getChatMessages(
  //     {required String chatId,
  //     required BuildContext context,
  //     required String aesKey,
  //     required String searchQuery,
  //     required bool isLoadMore}) async {
  //   try {
  //     Map<String, dynamic>? data = {
  //       'page': isLoadMore ? chatCurrentPage + 1 : 1,
  //       'search': searchQuery,
  //       "limit": 15
  //     };

  //     if (isLoadMore) {
  //       log("isLoadMore===$chatTotalPage $chatCurrentPage ${chatTotalPage > chatCurrentPage}");
  //       if (chatTotalPage < chatCurrentPage) return;
  //       emit(state.copyWith(chatMessageLoadingMore: isLoadMore));
  //     } else {
  //       chatTotalPage = 1;
  //       emit(state.copyWith(chatLoadingState: LoadingState.loading));
  //     }

  //     ChatMessageModelResponse response =
  //         await apiClient.getChatMessages(chatId, context, aesKey, data);
  //     if (response.status == Utils.APISUCCESS) {
  //       // ChatMessageModel chatData = ChatMessageModel.fromJson(response.data, aesKey)
  //       Set<MessageModel> newList = isLoadMore
  //           ? Set.from([
  //               ...state.chatList ?? Set.of([]),
  //               ...response.data?.messages ?? Set.of([])
  //             ].cast<MessageModel>())
  //           : response.data?.messages ?? Set.of([]);
  //       log("Get Message Pagination1111=== ${response.data?.pagination?.toJson()}");
  //       if (response.data?.pagination != null) {
  //         log("Get Message Pagination=== ${response.data?.pagination?.toJson()}");
  //         chatTotalPage = response.data!.pagination!.totalPages!;
  //         if (response.data!.pagination!.page! >
  //             response.data!.pagination!.totalPages!) {
  //           emit(state.copyWith(
  //               chatLoadingState: LoadingState.success,
  //               chatMessageLoadingMore: false));
  //           return;
  //         }

  //         chatCurrentPage = response.data!.pagination!.page!;
  //         log("isLoadMore=2==$chatTotalPage $chatCurrentPage ${chatTotalPage > chatCurrentPage}");
  //       } else {
  //         chatCurrentPage = 1;
  //         log("isLoadMore=3==$chatTotalPage $chatCurrentPage ${chatTotalPage > chatCurrentPage}");
  //       }
  //       emit(state.copyWith(
  //           chatLoadingState: LoadingState.success,
  //           chatMessageLoadingMore: false,
  //           chatMessageModel: response.data?.copyWith(messages: newList),
  //           chatList: newList));
  //     } else {
  //       emit(state.copyWith(
  //           chatLoadingState: LoadingState.success,
  //           chatMessageLoadingMore: false));
  //     }
  //   } catch (e, st) {
  //     Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""),
  //         seconds: 3);
  //     showMessage("getChatMessages $e $st");
  //     emit(state.copyWith(
  //         chatLoadingState: LoadingState.error,
  //         chatErrorMessage: e.toString()));
  //   }
  // }
  // Call this when app starts or when user opens the chat screen
  Future<void> checkAndRetryPendingMessages({
    required BuildContext context,
    required String chatId,
    required String aesKey,
  }) async {
    try {
      final currentUser = await dbHelper.getLoginData();
      if (currentUser == null) return;

      final pendingMessages = await messageRepo.getPendingUploads(
          userId: currentUser.sId!, chatId: chatId, aesKey: aesKey);

      for (final message in pendingMessages) {
        if (message.sender?.id == currentUser.sId) {
          print(
              "checkAndRetryPendingMessages>>>>${message.content} ==>$aesKey");
          await retryFailedMessage(
              context: context, // or pass context
              message: message,
              aesKey: aesKey, // or get from chat
              from: "checkAndRetryPendingMessages");
        }
      }
    } catch (e, st) {
      log("Error in checkAndRetryPendingMessages: ${e.toString()}\n$st");
    }
  }

  Future<void> getChatMessages({
    required String chatId,
    required BuildContext context,
    required String aesKey,
    required String searchQuery,
    required bool isLoadMore,
  }) async {
    try {
      // 1. Check if we should load more
      if (isLoadMore &&
          (!chatPaginationController.hasMore ||
              chatPaginationController.isFetching)) {
        return;
      }

      chatPaginationController.isFetching = true;

      // 2. Set loading states
      if (!isLoadMore) {
        chatPaginationController.reset();
        emit(state.copyWith(chatLoadingState: LoadingState.loading));
      } else {
        emit(state.copyWith(chatMessageLoadingMore: true));
      }

      final int currentPage =
          isLoadMore ? chatPaginationController.currentPage + 1 : 1;
      final currentUserId = AppPreference.getCurrentUserId();
      // 3. First load from local database
      final localMessages = await messageRepo.getMessages(
          chatId: chatId,
          userId: currentUserId,
          limit: chatPaginationController.limit,
          offset: (currentPage - 1) * chatPaginationController.limit,
          aesKey: aesKey);

      // 4. Immediately fetch from API without updating UI
      final Map<String, dynamic> apiParams = {
        'page': currentPage,
        'search': searchQuery,
        'limit': chatPaginationController.limit,
      };

      ChatMessageModelResponse? apiResponse;
      try {
        apiResponse =
            await apiClient.getChatMessages(chatId, context, aesKey, apiParams);
      } catch (e) {
        // API failed, proceed with local messages only
        debugPrint('API fetch failed: $e');
      }

      // 5. Process combined results
      Set<MessageModel> finalMessages = localMessages.toSet();
      bool hasMore = false;
      int page = currentPage;

      if (apiResponse != null && apiResponse.status == Utils.APISUCCESS) {
        // Save API messages to local DB
        await messageRepo.batchInsertMessages(
          messages: apiResponse.data?.messages?.toList() ?? [],
          userId: currentUserId,
        );

        // Get the most recent combined messages from local DB
        final updatedLocalMessages = await messageRepo.getMessages(
            chatId: chatId,
            userId: currentUserId,
            limit: chatPaginationController.limit,
            offset: (currentPage - 1) * chatPaginationController.limit,
            aesKey: aesKey);

        finalMessages = updatedLocalMessages.toSet();

        // Update pagination info from API
        if (apiResponse.data?.pagination != null) {
          hasMore = apiResponse.data!.pagination!.page! <
              apiResponse.data!.pagination!.totalPages!;
          page = apiResponse.data!.pagination!.page!;
        }
      }

      // 6. For load more, combine with existing messages
      if (isLoadMore) {
        finalMessages = {
          ...state.chatList ?? <MessageModel>{},
          ...finalMessages,
        };
      }

      // 7. Update pagination controller
      chatPaginationController.hasMore = hasMore;
      chatPaginationController.currentPage = page;

      // 8. Single state update with final messages
      emit(state.copyWith(
        chatLoadingState: LoadingState.success,
        chatMessageLoadingMore: false,
        chatMessageModel:
            (apiResponse?.data ?? state.chatMessageModel)?.copyWith(
          messages: finalMessages,
        ),
        chatList: finalMessages,
      ));
    } catch (e, st) {
      Utils.showSnackBar(
        context,
        e.toString().replaceAll("Exception: ", ""),
        seconds: 3,
      );

      emit(state.copyWith(
        chatLoadingState: state.chatList?.isNotEmpty ?? false
            ? LoadingState.success
            : LoadingState.error,
        chatErrorMessage:
            state.chatList?.isNotEmpty ?? true ? null : e.toString(),
        chatMessageLoadingMore: false,
      ));

      debugPrint("getChatMessages error: $e\n$st");
    } finally {
      chatPaginationController.isFetching = false;
    }
  }
  // Old GetMessage api
  // Future<void> getChatMessages({
  //   required String chatId,
  //   required BuildContext context,
  //   required String aesKey,
  //   required String searchQuery,
  //   required bool isLoadMore,
  // }) async {
  //   try {
  //     if (isLoadMore &&
  //         (!chatPaginationController.hasMore ||
  //             chatPaginationController.isFetching)) {
  //       return;
  //     }

  //     chatPaginationController.isFetching = true;

  //     if (!isLoadMore) {
  //       chatPaginationController.reset(); // Reset pagination on new search/load
  //       emit(state.copyWith(chatLoadingState: LoadingState.loading));
  //     } else {
  //       emit(state.copyWith(chatMessageLoadingMore: true));
  //     }

  //     final int currentPage =
  //         isLoadMore ? chatPaginationController.currentPage + 1 : 1;

  //     Map<String, dynamic> data = {
  //       'page': currentPage,
  //       'search': searchQuery,
  //       'limit': chatPaginationController.limit,
  //     };

  //     final ChatMessageModelResponse response =
  //         await apiClient.getChatMessages(chatId, context, aesKey, data);

  //     if (response.status == Utils.APISUCCESS) {
  //       final pagination = response.data?.pagination;
  //       final Set<MessageModel> newMessages = isLoadMore
  //           ? <MessageModel>{
  //               ...state.chatList ?? <MessageModel>{},
  //               ...response.data?.messages ?? <MessageModel>{}
  //             }
  //           : response.data?.messages ?? <MessageModel>{};

  //       if (pagination != null) {
  //         chatPaginationController.hasMore =
  //             pagination.page! < pagination.totalPages!;
  //         chatPaginationController.currentPage = pagination.page!;
  //       } else {
  //         chatPaginationController.hasMore = false;
  //         chatPaginationController.currentPage = 1;
  //       }
  //       print(
  //           "getChat Message = ${response.data?.isOnline} ${response.data?.lastSeen}");
  //       emit(state.copyWith(
  //         chatLoadingState: LoadingState.success,
  //         chatMessageLoadingMore: false,
  //         chatMessageModel: response.data?.copyWith(messages: newMessages),
  //         chatList: newMessages,
  //       ));
  //     } else {
  //       emit(state.copyWith(
  //         chatLoadingState: LoadingState.success,
  //         chatMessageLoadingMore: false,
  //       ));
  //     }
  //   } catch (e, st) {
  //     Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""),
  //         seconds: 3);
  //     emit(state.copyWith(
  //       chatLoadingState: LoadingState.error,
  //       chatErrorMessage: e.toString(),
  //       chatMessageLoadingMore: false,
  //     ));
  //     showMessage("getChatMessages $e\n$st");
  //   } finally {
  //     chatPaginationController.isFetching = false;
  //   }
  // }

  Future<void> rejectCall(
      {
      // required BuildContext context,
      required String chatId,
      required String callId,
      required int duration}) async {
    try {
      UserData? currentuser = await dbHelper.getLoginData();
      //  showMessage("onend call userid==${currentuser?.sId??""}");
      SocketService().emitEndCall({
        "user_id": currentuser?.sId,
        "duration": duration,
        "chat_id": chatId,
        "callId": callId,
      });
    } catch (e, st) {
      showMessage("Error in end Call $e, $st");
    }
  }

  Future<void> deleteChatMessages(
      {required String messageId,
      required String chatId,
      required int index,
      required BuildContext context,
      required bool deleteForEveryOne,
      Function(CommonMessageResponse)? callback}) async {
    try {
      if (messageId.isEmpty) {
        return;
      }
      Utils.showLoader();
      CommonMessageResponse response = await apiClient.deleteChatMessages(
          deleteForEveryOne: deleteForEveryOne,
          messageId: messageId,
          chatId: chatId,
          context: context);
      if (response.status == Utils.APISUCCESS) {
        List<MessageModel> updatedMessageList = List.from(state.chatList ?? []);
        updatedMessageList.removeAt(index);
        await messageRepo.deleteMessage(messageId: messageId);
        // callback?.call(response);
        emit(state.copyWith(
            chatList: updatedMessageList.toSet(),
            chatMessageModel: state.chatMessageModel
                ?.copyWith(messages: updatedMessageList.toSet())));
      }
    } catch (e) {
      // Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""),
      //     seconds: 3);
      List<MessageModel> updatedMessageList = List.from(state.chatList ?? []);
      updatedMessageList.removeAt(index);
      await messageRepo.deleteMessage(messageId: messageId);
      // callback?.call(response);
      emit(state.copyWith(
          chatList: updatedMessageList.toSet(),
          chatMessageModel: state.chatMessageModel
              ?.copyWith(messages: updatedMessageList.toSet())));
    } finally {
      Utils.hideLoader();
    }
  }

  Future<void> clearChat(String chatId,
      {Function(CommonMessageResponse)? callback}) async {
    try {
      log("clear chat -->$chatId");
      if (chatId.isEmpty) {
        return;
      }
      // Utils.showLoader();
      CommonMessageResponse response = await apiClient.clearChat(
        chatId,
      );
      if (response.status == Utils.APISUCCESS) {
        await messageRepo.clearChat(
          chatId: chatId,
        );
        emit(state.copyWith(
            chatList: Set.of([]),
            chatMessageModel:
                state.chatMessageModel?.copyWith(messages: Set.of([]))));
        callback?.call(response);
      }
    } catch (e, st) {
      // Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""),
      //     seconds: 3);
      showMessage("Error ==> $e $st");
    } finally {
      // Utils.hideLoader();
    }
  }

  Future<void> saveMessages(
      {required BuildContext context,
      required String messageId,
      required String chatId,
      required bool isTempMessage,
      void Function(CommonMessageResponse)? callback}) async {
    try {
      Map<String, dynamic> data = {};
      if (isTempMessage) {
        data = {
          "chatId": chatId,
          "tempMessageId": messageId,
          "isTempMessage": true
        };
      } else {
        data = {
          "messageId": messageId,
          "chatId": chatId,
          "isTempMessage": isTempMessage
        };
      }
      showMessage("saveMessages  DATA. $data");
      Utils.showLoader();
      CommonMessageResponse response =
          await apiClient.saveMessage(context: context, data: data);
      if (response.status == Utils.APISUCCESS) {
        callback?.call(response);
      }
    } catch (e, st) {
      showMessage("saveMessages errot $e, $st");
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""),
          seconds: 3);
    } finally {
      Utils.hideLoader();
    }
  }

  int saveMessagesCurrentPage = 1;
  Timer? debounceTimer;
  void onSearchSavedMessages(BuildContext context, String searchQuery) {
    if (debounceTimer != null) {
      debounceTimer!.cancel();
    }

    debounceTimer = Timer(
      Duration(seconds: 1),
      () {
        saveMessagesCurrentPage = 1;
        getSaveMessages(context, searchQuery: searchQuery, isLoadMore: false);
      },
    );
  }

  void handleSearchSavedMessage(BuildContext context, void Function() onTap) {
    emit(state.copyWith(isSearchSavedMessages: !state.isSearchSavedMessages));

    if (state.isSearchSavedMessages) {
      onTap.call();

      onSearchSavedMessages(context, "");
    }
  }

  Future<void> getSaveMessages(BuildContext context,
      {Function(CommonMessageResponse)? callback,
      required String searchQuery,
      required bool isLoadMore}) async {
    try {
      if ((state.savedMessagesData?.savedMessages ?? []).isEmpty) {
        emit(state.copyWith(savedMessageLoadingState: LoadingState.loading));
      }
      Map<String, dynamic>? data = {
        'page': isLoadMore ? saveMessagesCurrentPage + 1 : 1,
        'search': searchQuery,
      };

      if (isLoadMore) {
        emit(state.copyWith(savedMessageLoadingMore: isLoadMore));
      }
      GetSavedMessagesResponse response =
          await apiClient.getSaveMessages(context, data);
      if (response.status == Utils.APISUCCESS) {
        SavedMessagesData savedMessagesData =
            SavedMessagesData.fromJson(response.data!.toJson(), "");

        final newList = isLoadMore
            ? [
                ...state.savedMessagesData?.savedMessages ?? [],
                ...response.data?.savedMessages ?? []
              ].cast<SavedMessage>()
            : response.data?.savedMessages ?? [];
        if (response.data?.pagination != null) {
          if (response.data!.pagination!.page! >
              response.data!.pagination!.totalPages!) {
            emit(state.copyWith(
                savedMessageLoadingState: LoadingState.success,
                savedMessageLoadingMore: false));
            return;
          }

          saveMessagesCurrentPage = response.data!.pagination!.page!;
        } else {
          saveMessagesCurrentPage = 1;
        }
        emit(state.copyWith(
            savedMessageLoadingMore: false,
            savedMessagesData:
                savedMessagesData.copyWith(savedMessages: newList),
            savedMessageLoadingState: LoadingState.success));
      } else {
        emit(state.copyWith(
            savedMessageLoadingState: LoadingState.success,
            savedMessageLoadingMore: false));
      }
    } catch (e, st) {
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""),
          seconds: 3);
      showMessage("Error getSaveMessages $e $st");
      emit(state.copyWith(
          savedMessageLoadingState: LoadingState.error,
          savedMessageLoadingMore: false));
    } finally {
      Utils.hideLoader();
    }
  }

  Future<void> onReceivedMessage(
      BuildContext context, dynamic data, String userId, String aesKey) async {
    try {
      MessageModel chatData = MessageModel.fromJson(data, aesKey);
      showMessage("updateChatList and Emit==${{
        "userId": chatData.sender?.id,
        "chatId": chatData.chatId,
        "isChatOpen": true,
        "lastMessageId": chatData.messageId,
      }}==> ${chatData.toJson()}");
      final updatedMessageList = List<MessageModel>.from(state.chatList ?? []);
      if (updatedMessageList.isNotEmpty &&
          updatedMessageList[0].messageId == chatData.messageId) {
        showMessage(
            "updateChatList and Emit first ====> ${updatedMessageList[0].toJson()}");
        updatedMessageList[0] = chatData;
      } else {
        updatedMessageList.insert(0, chatData);
      }
      // 2. Save to local database first
      await messageRepo.saveMessage(chatData, AppPreference.getCurrentUserId());
      emit(state.copyWith(
          chatList: updatedMessageList.toSet(),
          chatMessageModel: state.chatMessageModel
              ?.copyWith(messages: updatedMessageList.toSet())));
      _socketService.sendEvent(AppConstants.emitMessageReadStatus, {
        "userId": userId,
        "chatId": chatData.chatId,
        "isChatOpen": true,
        "lastMessageId": chatData.messageId,
      });
    } catch (e, st) {
      // Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""),
      //     seconds: 3);
      showMessage("Error ==> $e $st");
    }
  }

  Future<void> onReceivedSystemMessage(
      BuildContext context, dynamic data, String userId, String aesKey) async {
    try {
      MessageModel chatData = MessageModel.fromJson(data, aesKey);
      showMessage("updateChatList and Emit====> ${chatData.toJson()}");
      final updatedMessageList = List<MessageModel>.from(state.chatList ?? []);
      updatedMessageList.insert(0, chatData);
      // 2. Save to local database first
      await messageRepo.saveMessage(chatData, AppPreference.getCurrentUserId());
      emit(state.copyWith(
          chatList: updatedMessageList.toSet(),
          chatMessageModel: state.chatMessageModel
              ?.copyWith(messages: updatedMessageList.toSet())));
    } catch (e, st) {
      // Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""),
      //     seconds: 3);
      showMessage("Error ==> ${e} $st");
    }
  }

  Future<void> onReceivedEditedMessage(
      BuildContext context, dynamic data, String userId, String aesKey) async {
    try {
      MessageModel chatData = MessageModel.fromJson(data, aesKey);

      final updatedMessageList =
          List<MessageModel>.from(state.chatList ?? []).map(
        (e) {
          if (chatData.messageId == e.messageId) {
            return e.copyWith(
                content: chatData.content,
                isEditedMessage: chatData.isEditedMessage);
          }
          return e;
        },
      );
      // 2. Save to local database first
      await messageRepo.saveMessage(chatData, AppPreference.getCurrentUserId());
      emit(state.copyWith(
          chatList: updatedMessageList.toSet(),
          chatMessageModel: state.chatMessageModel
              ?.copyWith(messages: updatedMessageList.toSet())));
    } catch (e) {
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""),
          seconds: 3);
      showMessage("Error ==> ${e.toString().replaceAll("Exception: ", "")}");
    }
  }

  Future<void> onReceivedReactMessage(
      BuildContext context, dynamic data, String aesKey) async {
    try {
      MessageModel chatData = MessageModel.fromJson(data, aesKey);

      final updatedMessageList =
          List<MessageModel>.from(state.chatList ?? []).map(
        (e) {
          if (chatData.messageId == e.messageId) {
            return e.copyWith(reactions: chatData.reactions);
          }
          return e;
        },
      );
      // if ((chatData.reactions ?? []).isNotEmpty) {
      await messageRepo.addReaction(
          messageId: chatData.messageId ?? "",
          reactions: chatData.reactions ?? [],
          userId: AppPreference.getCurrentUserId());
      // }
      emit(state.copyWith(
          chatList: updatedMessageList.toSet(),
          chatMessageModel: state.chatMessageModel
              ?.copyWith(messages: updatedMessageList.toSet())));
    } catch (e) {
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""),
          seconds: 3);
      showMessage("Error ==> ${e.toString().replaceAll("Exception: ", "")}");
    }
  }

  Future<void> onDeleteMessage(
    BuildContext context,
    String messageId,
  ) async {
    try {
      // MessageModel chatData = MessageModel.fromJson(data, aesKey);
      // showMessage("updateChatList and Emit==${{
      //   "userId": chatData.sender?.id,
      //   "chatId": chatData.chatId,
      //   "isChatOpen": true,
      //   "lastMessageId": chatData.messageId,
      // }}==> ${chatData.toJson()}");
      final updatedMessageList = List<MessageModel>.from(state.chatList ?? []);
      updatedMessageList.removeWhere(
        (element) => element.messageId == messageId,
      );
      await messageRepo.deleteMessage(
        messageId: messageId,
      );
      emit(state.copyWith(
          chatList: updatedMessageList.toSet(),
          chatMessageModel: state.chatMessageModel
              ?.copyWith(messages: updatedMessageList.toSet())));
    } catch (e) {
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""),
          seconds: 3);
      showMessage("Error ==> ${e.toString().replaceAll("Exception: ", "")}");
    }
  }

  void updateChatList(
      BuildContext context, dynamic data, String callFrom, String aesKey) {
    try {
      showMessage("updateChatList=====? $callFrom==> }");
      MessageModel chatData;
      if (data is MessageModel) {
        chatData = data;
      } else {
        chatData = MessageModel.fromJson(data, aesKey);
      }

      final updatedMessageList =
          List<MessageModel>.from(state.chatList ?? <MessageModel>{});
      int index = updatedMessageList.indexWhere(
        (element) => element.messageId == chatData.messageId,
      );
      if (index != -1) {
        updatedMessageList[index] = chatData;
      } else {
        updatedMessageList.insert(0, chatData);
      }

      emit(state.copyWith(
          chatList: updatedMessageList.toSet(),
          chatMessageModel: state.chatMessageModel
              ?.copyWith(messages: updatedMessageList.toSet())));
    } catch (e) {
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""),
          seconds: 3);
      showMessage("Error ==> ${e.toString().replaceAll("Exception: ", "")}");
    }
  }

// void updateTypingList( TypingModel newTypingModel) {

//    List<TypingModel> typingList = List<TypingModel>.from(state.currentTypingusers??[]);
//   // Remove elements that have a different chatId or are set to isTyping = false
//   typingList.removeWhere((element) =>
//       element.chatId != newTypingModel.chatId || element.isTypeing == false);

//   // If isTyping is true, add or update the typing model in the list
//   if (newTypingModel.isTypeing == true) {
//     // Check if the model already exists in the list
//     int index = typingList.indexWhere((element) => element.sender == newTypingModel.sender);

//     if (index != -1) {
//       // Update the existing model
//       typingList[index] = newTypingModel;
//     } else {
//       // Add a new model
//       typingList.add(newTypingModel);
//     }
//   }else{
//     typingList.removeWhere((element) =>
//       element.sender == newTypingModel.sender );
//   }
//   showMessage("updateTypingList==>${typingList.length}");
//   emit(state.copyWith(currentTypingusers: typingList));
// }

  void updateTypingList(TypingModel newTypingModel) {
    // Create a new list from the current state to avoid modifying the original reference
    List<TypingModel> typingList =
        List<TypingModel>.from(state.currentTypingusers ?? []);

    // Remove elements with different chatId or those with isTyping = false
    typingList.removeWhere((element) =>
        element.chatId != newTypingModel.chatId || element.isTyping == false);

    if (newTypingModel.isTyping == true) {
      // Check if the sender already exists in the list
      int index = typingList
          .indexWhere((element) => element.sender == newTypingModel.sender);

      if (index != -1) {
        // Update the existing typing model
        typingList[index] = newTypingModel;
      } else {
        // Add a new typing model
        typingList.add(newTypingModel);
      }
    } else {
      // Remove the typing model if isTyping is false
      typingList.removeWhere(
          (element) => element.sender?.id == newTypingModel.sender?.id);
    }

    showMessage("updateTypingList==1111>${typingList.length}");

    // Emit a new state only if there's an actual change
    if (!listEquals(state.currentTypingusers, typingList)) {
      emit(state.copyWith(
          currentTypingusers: List<TypingModel>.from(typingList)));
    }
  }

  void clearTypingList() {
    emit(state.copyWith(currentTypingusers: []));
  }

  void updateMessageFromChatList(
      BuildContext context, MessageModel message, String messageId) {
    Set<MessageModel> updatedMessages = (state.chatList ?? Set.of([])).map(
      (e) {
        if (e.id == messageId) {
          return message;
        }
        return e;
      },
    ).toSet();
    emit(state.copyWith(
        chatList: updatedMessages,
        chatMessageModel:
            state.chatMessageModel?.copyWith(messages: updatedMessages)));
  }

  Future<void> updateMessageStatus(
      {required BuildContext context, required String lastMsgId}) async {
    final updatedMessages = (state.chatList ?? Set.of([])).map((message) {
      // showMessage(
      //     "changeMessageStatus  ${message.messageId} ${message.isRead}");
      return message.uploadStatus == MessageUploadStatus.sent &&
              (message.isRead ?? false) == false
          ? message.copyWith(
              isRead: true,
            )
          : message;
    }).toSet();

    //  final messages = updatedMessage.map((e) => e.toString(),).toList();
// final updatedMessages = (state.chatList??[]).map((oldmessage) {
//   showMessage("send message=== >${oldmessage.messageId}  $updatedMessage  ${updatedMessage.contains( oldmessage.messageId)}");
//           if (!(oldmessage.isRead??true)&& updatedMessage.contains( oldmessage.messageId)) {
//         // Use the callback to update the message
//         showMessage("send message=== >${oldmessage.isRead}");
//         return oldmessage.copyWith(isRead: true);
//       }
//       return oldmessage;
//     }).toList();
    // await Future.delayed(Durations.extralong1);
    print("changeMessageStatus==> updateMessageStatus  ${lastMsgId}");
    emit(state.copyWith(chatList: updatedMessages));
  }

  void handleReplyMessage(MessageModel? message) {
    emit(state.copyWith(replyingToMessage: message));
  }

  void handleReplySavedMessage(SavedMessage? message) {
    emit(state.copyWith(replyingToSavedMessage: message));
  }

  void updateUploadProgress(String messageId, double progress) {
    final updatedMessages =
        (state.chatList ?? <MessageModel>{}).toList().map((msg) {
      if (msg.messageId == messageId) {
        return msg.copyWith(
          uploadProgress: progress,
          uploadStatus: progress == 0 ? MessageUploadStatus.uploading : null,
        );
      }
      return msg;
    }).toSet();

    emit(state.copyWith(chatList: updatedMessages));
  }

  Future<void> retryFailedMessage(
      {required BuildContext context,
      required MessageModel message,
      required String? aesKey,
      required String? from}) async {
    try {
      // Update retry state
      final currentUser = await dbHelper.getLoginData();
      if (currentUser == null) throw Exception('User not logged in');

      // 2. Handle reply message encryption if exists
      // if (replyMessage != null) {
      //   final replyMessageContent = encryptionHelper.encryptMessage(
      //       replyMessage.content ?? "", aesKey ?? "");
      //   replyMessage = replyMessage.copyWith(
      //       content: replyMessageContent, replyTo: null, resetReplyTo: true);
      // }

      // 3. Determine message type
      final mediaType = _getMediaTypeFromMessage(message);
      final mimeType = _getMimeTypeFromMessage(message);
      final encryptionHelper = EncryptionHelper();
      final encryptedContent = encryptionHelper.encryptMessage(
        message.content ?? "",
        aesKey ?? "",
      );
      print(
          "retryFailedMessage=> ${message.content} $aesKey  $mediaType $from");
      if (mediaType == 0) {
        // Save to local DB first

        // Send via socket
        print("retryFailedMessage=> ${message.content} $encryptedContent");
        _socketService.sendMessage({
          "chatId": chatId,
          "content": encryptedContent,
          "type": "text",
          "messageId": message.messageId,
          "sender": message.sender?.id,
          "createdAt": message.createdAt?.toUtc().toIso8601String(),
          if (message.replyTo != null)
            "replyToMessageId": message.replyTo?.messageId
        }, (responseData) async {
          if (responseData['resStatus'] == "success") {
            updateChatList(
                context,
                message.copyWith(uploadStatus: MessageUploadStatus.sent),
                "sendMessage text",
                aesKey ?? "");
            await messageRepo.saveMessage(
                message.copyWith(uploadStatus: MessageUploadStatus.sent),
                currentUser.sId!);
            print("sent message sucessfully>>");
          }
        });

        if (message.replyTo != null) {
          handleReplyMessage(null);
        }
        return;
      }

      await messageRepo.updateUploadStatus(
        messageId: message.messageId!,
        status: MessageUploadStatus.uploading,
        userId: (await dbHelper.getLoginData())?.sId ?? '',
      );

      // Update UI
      chatCubit.updateUploadProgress(message.messageId!, 0);

      // Determine media type from message

      // Prepare files if needed
      List<XFile>? files;
      if (message.files != null && message.files!.isNotEmpty) {
        files = await _prepareFilesForRetry(message.files!);
      }
      if (mediaType == 0) {
        return;
      }
      // Call the original upload method with retry flag
      await _uploadMediaMessage(
        message: message,
        mediaType: mediaType,
        type: message.type ?? 'image', // default to image if null
        chatId: message.chatId,
        encryptedContent: encryptedContent,
        files: files,
        aesKey: aesKey,
        gifUrl: message.files?.firstOrNull?.url,
        sizeForGIF: null, // adjust as needed
        replyMessage: message.replyTo,
        context: context,
        // isRetry: true,
        // messageTime: message.createdAt ?? DateTime.now(),
      );
    } catch (e, st) {
      log("Retry failed: ${e.toString()}\n$st");
      // await messageRepo.updateMessage(
      //   message.copyWith(
      //     retryState: MessageRetryState.pendingRetry,
      //   ),
      //   (await dbHelper.getLoginData())?.sId ?? '',
      // );
      await messageRepo.updateUploadStatus(
        messageId: message.messageId!,
        status: MessageUploadStatus.failed,
        userId: (await dbHelper.getLoginData())?.sId ?? '',
      );
    }
  }

  int _getMediaTypeFromMessage(MessageModel message) {
    switch (message.type) {
      case 'text':
        return 0;
      case 'image':
        return 1;
      case 'video':
        return 2;
      case 'audio':
        return 3;
      case 'gif':
        return 4;
      case 'pdf':
        return 5;
      default:
        return 6; // document
    }
  }

  MimeType _getMimeTypeFromMessage(MessageModel message) {
    switch (message.type) {
      case 'image':
        return MimeType.image;
      case 'video':
        return MimeType.video;
      case 'audio':
        return MimeType.audio;
      case 'gif':
        return MimeType.gif;
      case 'pdf':
        return MimeType.pdf;
      default:
        return MimeType.doc;
    }
  }

  // Future<List<XFile>> _prepareFilesForRetry(
  //     List<FileElement> fileElements) async {
  //   return await Future.wait(fileElements.map((e) async {
  //     if (e.file != null) return e.file!;
  //     if (e.localPath != null) return XFile(e.localPath!);
  //     throw Exception('No file available for retry');
  //   }));
  // }
  Future<List<XFile>> _prepareFilesForRetry(
      List<FileElement> fileElements) async {
    return await Future.wait(fileElements.map((e) async {
      // First try to get file from persistent storage
      if (e.localPath != null && await File(e.localPath!).exists()) {
        return XFile(e.localPath!);
      }

      // Fallback to original file reference if available
      if (e.file != null) {
        // Try to save it again to persistent storage
        final persistentPath = await MediaStorageHelper.saveMediaFile(e.file!);
        return XFile(persistentPath);
      }

      throw Exception('No file available for retry');
    }));
  }

  Future<void> sentMessage(
    BuildContext context, {
    required int mediaType,
    required MimeType mimeType,
    String? chatId,
    String? aesKey,
    String? content,
    List<XFile>? files,
    MessageModel? replyMessage,
    String? gifUrl,
    String? sizeForGIF,
  }) async {
    try {
      // 1. Get current user info
      final currentUser = await dbHelper.getLoginData();
      if (currentUser == null) throw Exception('User not logged in');

      final encryptionHelper = EncryptionHelper();
      final encryptedContent =
          encryptionHelper.encryptMessage(content ?? "", aesKey ?? "");

      // 2. Handle reply message encryption if exists
      if (replyMessage != null) {
        final replyMessageContent = encryptionHelper.encryptMessage(
            replyMessage.content ?? "", aesKey ?? "");
        replyMessage = replyMessage.copyWith(
            content: replyMessageContent, replyTo: null, resetReplyTo: true);
      }

      // 3. Determine message type
      final type = _getMessageType(mediaType, mimeType);
      final messageId = DateTime.now().microsecondsSinceEpoch.toString();

      // 4. Create message model based on media type
      MessageModel message;
      if (mediaType == 0) {
        // Text message
        message = MessageModel(
          chatId: chatId,
          messageId: messageId,
          content: encryptedContent,
          createdAt: DateTime.now(),
          isRead: false,
          isSent: true,
          type: "text",
          isDeleted: false,
          sender: await Utils.currentUserToSender(),
          id: messageId,
          replyTo: replyMessage,
          uploadStatus:
              MessageUploadStatus.pending, // Text is immediately "sent"
        );

        // Save to local DB first
        await messageRepo.saveMessage(
            MessageModel.fromJson(message.toJson(), aesKey ?? ""),
            currentUser.sId!);

        // Update UI immediately
        updateChatList(
            context, message.toJson(), "sendMessage text", aesKey ?? "");

        // Send via socket
        _socketService.sendMessage({
          "chatId": chatId,
          "content": encryptedContent,
          "type": "text",
          "messageId": messageId,
          "sender": currentUser.sId,
          "createdAt": message.createdAt?.toUtc().toIso8601String(),
          if (replyMessage != null) "replyToMessageId": replyMessage.messageId
        }, (responseData) async {
          if (responseData['resStatus'] == "success") {
            updateChatList(
                context,
                message
                    .copyWith(uploadStatus: MessageUploadStatus.sent)
                    .toJson(),
                "sendMessage text",
                aesKey ?? "");
            await messageRepo.saveMessage(
                MessageModel.fromJson(
                    message
                        .copyWith(uploadStatus: MessageUploadStatus.sent)
                        .toJson(),
                    aesKey ?? ""),
                currentUser.sId!);
            print("sent message sucessfully>>");
          } else if ((responseData['resStatus'] == "failed")) {
            updateChatList(
                context,
                message
                    .copyWith(uploadStatus: MessageUploadStatus.failed)
                    .toJson(),
                "sendMessage text",
                aesKey ?? "");
            await messageRepo.saveMessage(
                MessageModel.fromJson(
                    message
                        .copyWith(uploadStatus: MessageUploadStatus.failed)
                        .toJson(),
                    aesKey ?? ""),
                currentUser.sId!);
          }
        });

        if (replyMessage != null) {
          handleReplyMessage(null);
        }
        return;
      } else {
        // Media message
        if (files == null && encryptedContent == null) return;

        // Process media files
        List<FileElement> fileEle;
        if (type == "gif") {
          fileEle = [FileElement(url: gifUrl, fileName: "GIF")];
        } else {
          fileEle = await _processMediaFiles(files!);
        }

        // Create message with pending status
        message = MessageModel(
          chatId: chatId,
          messageId: messageId,
          content: encryptedContent,
          createdAt: DateTime.now(),
          isRead: false,
          isSent: false,
          type: type,
          isDeleted: false,
          sender: await Utils.currentUserToSender(),
          id: messageId,
          files: fileEle,
          replyTo: replyMessage,
          uploadStatus: MessageUploadStatus.pending,
          uploadProgress: 0,
        );

        // Save to local DB first
        await messageRepo.saveMessage(
            MessageModel.fromJson(message.toJson(), aesKey ?? ""),
            currentUser.sId!);

        // Update UI immediately
        chatCubit.updateChatList(
            context, message.toJson(), "sendMessage media", aesKey ?? "");

        // Start upload process
        _uploadMediaMessage(
          message: message,
          mediaType: mediaType,
          type: type,
          chatId: chatId,
          encryptedContent: encryptedContent,
          files: files,
          aesKey: aesKey,
          gifUrl: gifUrl,
          sizeForGIF: sizeForGIF,
          replyMessage: replyMessage,
          context: context,
          // messageTime: message.createdAt ?? DateTime.now(),
        );
      }
    } catch (e, st) {
      Utils.showSnackBar(
        context,
        e.toString().replaceAll("Exception: ", ""),
        seconds: 3,
      );
      log("Error in sentMessage: ${e.toString()}\n$st");
    } finally {
      if (mediaType != 0) {
        Utils.hideLoader();
      }
    }
  }

// Helper method to determine message type
  String _getMessageType(int mediaType, MimeType mimeType) {
    if (mediaType == 0) return "text";

    switch (mimeType) {
      case MimeType.image:
        return "image";
      case MimeType.video:
        return "video";
      case MimeType.audio:
        return "audio";
      case MimeType.gif:
        return "gif";
      case MimeType.pdf:
        return "pdf";
      default:
        return "document";
    }
  }

// Helper method to process media files
  Future<List<FileElement>> _processMediaFiles(List<XFile> files) async {
    return await Future.wait(
      files.map((e) async {
        final fileSize = await e.length();
        // Save to persistent storage immediately
        final persistentPath = await MediaStorageHelper.saveMediaFile(e);
        return FileElement(
          file: e, // Keep original reference for immediate use
          localPath: persistentPath, // Store persistent path
          fileSize: fileSize,
          fileName: e.name,
        );
      }),
    );
  }

// Helper method to save file locally
  Future<String> _saveFileLocally(XFile file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final savedFile = File(
        '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}_${file.name}');
    await savedFile.writeAsBytes(await file.readAsBytes());
    return savedFile.path;
  }

// Separate method for media upload process
  Future<void> _uploadMediaMessage({
    required MessageModel message,
    required int mediaType,
    required String type,
    required String? chatId,
    required String encryptedContent,
    required List<XFile>? files,
    required String? aesKey,
    required String? gifUrl,
    required String? sizeForGIF,
    required MessageModel? replyMessage,
    required BuildContext context,
    // required DateTime messageTime,
  }) async {
    try {
      // Update status to uploading in DB
      await messageRepo.updateUploadStatus(
        messageId: message.messageId!,
        status: MessageUploadStatus.uploading,
        userId: (await dbHelper.getLoginData())?.sId ?? '',
      );

      // Update UI with uploading status
      chatCubit.updateUploadProgress(message.messageId!, 0);
      String messageTime = message.createdAt?.toUtc().toIso8601String() ??
          DateTime.now().toUtc().toIso8601String();

      print("Message Time :->$messageTime");
      // Perform the actual upload
      final response = await apiClient.sentMessage(
        context,
        mediaType: mediaType,
        messageTime: messageTime,
        type: type,
        chatId: chatId,
        content: encryptedContent,
        files: files,
        aesKey: aesKey,
        gifUrl: gifUrl,
        sizeForGIF: sizeForGIF,
        messageId: message.messageId!,
        replyToMessageId: replyMessage?.messageId,
        onProgress: (progress) async {
          // Update progress in UI
          chatCubit.updateUploadProgress(message.messageId!, progress);

          // Update progress in DB (optional)
          messageRepo.updateUploadStatus(
            messageId: message.messageId!,
            status: MessageUploadStatus.uploading,
            progress: progress,
            userId: (await dbHelper.getLoginData())?.sId ?? '',
          );
        },
      );

      if (response.status == Utils.APISUCCESS) {
        // Update message in DB with server response
        await messageRepo.saveMessage(
            response.data!, (await dbHelper.getLoginData())?.sId ?? '');

        // Update UI with final message
        chatCubit.updateMessageFromChatList(
            context, response.data!, message.messageId!);

        // Mark as fully synced
        await messageRepo.updateUploadStatus(
          messageId: message.messageId!,
          status: MessageUploadStatus.sent,
          userId: (await dbHelper.getLoginData())?.sId ?? '',
        );

        emit(state.copyWith(
          replyingToMessage: null,
          sendMessageState: LoadingState.success,
        ));
      } else {
        throw Exception('Upload failed: ${response.message}');
      }
    } catch (e, st) {
      // Update status to failed in DB
      await messageRepo.updateUploadStatus(
        messageId: message.messageId!,
        status: MessageUploadStatus.failed,
        userId: (await dbHelper.getLoginData())?.sId ?? '',
      );
      chatCubit.updateMessageFromChatList(
          context,
          MessageModel.fromJson(
              message
                  .copyWith(uploadStatus: MessageUploadStatus.failed)
                  .toJson(),
              aesKey ?? ""),
          message.messageId!);
      // Update UI with failed status
      chatCubit.updateUploadProgress(
          message.messageId!, -1); // -1 indicates error

      print("Media upload failed: ${e.toString()}\n$st");
      Utils.showSnackBar(
        context,
        'Failed to upload media: ${e.toString().replaceAll("Exception: ", "")}',
        seconds: 3,
      );
    }
  }
//   Future<void> sentMessage(
//     BuildContext context, {
//     required int mediaType,
//     required MimeType mimeType,
//     String? chatId,
//     String? aesKey,
//     String? content,
//     List<XFile>? files,
//     MessageModel? replyMessage,
//     String? gifUrl,
//     String? sizeForGIF,
//     // Function(SentMessageModel? sentMessageModel)? callback,
//   }) async {
//     try {
//       final encryptionHelper = EncryptionHelper();
//       final encryptedContent =
//           encryptionHelper.encryptMessage(content ?? "", aesKey ?? "");
//       if (replyMessage != null) {
//         final replyMessageContent = encryptionHelper.encryptMessage(
//             replyMessage.content ?? "", aesKey ?? "");
//         replyMessage = replyMessage.copyWith(
//             content: replyMessageContent, replyTo: null, resetReplyTo: true);
//       }
//       String type = mediaType == 0
//           ? "text"
//           : MimeType.image == mimeType
//               ? "image"
//               : MimeType.video == mimeType
//                   ? "video"
//                   : MimeType.audio == mimeType
//                       ? "audio"
//                       : MimeType.gif == mimeType
//                           ? "gif"
//                           : MimeType.pdf == mimeType
//                               ? "pdf"
//                               : "document";
//       final String messageId = DateTime.now().microsecondsSinceEpoch.toString();
//       // if (mediaType != 0) {
//       //   Utils.showLoader();
//       // }

//       if (mediaType == 0) {
//         MessageModel message = MessageModel(
//             chatId: chatId,
//             messageId: messageId,
//             content: encryptedContent,
//             createdAt: DateTime.now(),
//             isRead: false,
//             isSent: true,
//             type: "text",
//             isDeleted: false,
//             sender: await Utils.currentUserToSender(),
//             id: messageId,
//             replyTo: replyMessage);

//         chatCubit.updateChatList(
//             context, message.toJson(), "sendMessage test", aesKey ?? "");
//       } else {
//         // emit(state.copyWith(sendMessageState: LoadingState.loading));
//         if (files == null && encryptedContent == null) {
//           // Utils.hideLoader();
//           return;
//         }
//         List<FileElement> fileEle;

//         if (type == "gif") {
//           fileEle = [FileElement(url: gifUrl, fileName: "GIF")];
//         } else {
//           fileEle = await Future.wait(
//             files!.map(
//               (e) async => FileElement(
//                 file: e,
//                 fileSize: await e.length(),
//               ),
//             ),
//           );
//         }
//         MessageModel message = MessageModel(
//             chatId: chatId,
//             messageId: messageId,
//             content: encryptedContent,
//             createdAt: DateTime.now(),
//             isRead: false,
//             isSent: false,
//             type: type,
//             isDeleted: false,
//             sender: await Utils.currentUserToSender(),
//             id: messageId,
//             files: fileEle,
//             replyTo: replyMessage);

//         chatCubit.updateChatList(
//             context, message.toJson(), "sendMessage media", aesKey ?? "");
//       }

//       String senderId = (userDataCubit.state?.sId ?? "").isEmpty
//           ? (await dbHelper.getLoginData())?.sId ?? ""
//           : userDataCubit.state?.sId ?? "";
//       if (mediaType == 0 && senderId.isNotEmpty) {
//         _socketService.sendEvent(AppConstants.sendMessage, {
//           "chatId": chatId,
//           "content": encryptedContent,
//           "type": "text",
//           "messageId": messageId,
//           "sender": senderId,
//           if (replyMessage != null) "replyToMessageId": replyMessage.messageId
//         });
//         if (replyMessage != null) {
//           handleReplyMessage(null);
//         }
//         return;
//       }
//       showMessage(
//           "sent message requiest 1==>$messageId   ${mimeType.name} $aesKey ${encryptedContent}");
//       SentMessageModel response = await apiClient.sentMessage(
//         context,
//         mediaType: mediaType,
//         type: type,
//         chatId: chatId,
//         content: encryptedContent,
//         files: files,
//         aesKey: aesKey,
//         gifUrl: gifUrl,
//         sizeForGIF: sizeForGIF,
//         messageId: messageId,
//         replyToMessageId:
//             (replyMessage != null) ? replyMessage.messageId : null,
//         onProgress: (progress) {
//           chatCubit.updateUploadProgress(messageId, progress);
//         },
//       );
//       if (response.status == Utils.APISUCCESS) {
//         if (response.data != null) {
//           updateMessageFromChatList(context, response.data!, messageId);
//         }
// //         else if (response.data != null) {
// // // callback?.call(response);
// //           showMessage("sent message responce ==>${response.data?.toJson()}");
// //           updateChatList(
// //               context, response.data, "sendMessage media", aesKey ?? "");
// //         }

//         emit(state.copyWith(
//           replyingToMessage: null,
//           sendMessageState: LoadingState.success,
//         ));
//       }
//     } catch (e, st) {
//       Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""),
//           seconds: 3);
//       // emit(SentMessageError(e.toString()));
//       log("sent Message==${e} $st");
//     } finally {
//       if (mediaType != 0) {
//         Utils.hideLoader();
//       }
//     }
//   }

  Future<void> sentSaveMessage(
    BuildContext context, {
    required int mediaType,
    required MimeType mimeType,
    required String content,
    List<XFile>? files,
    SavedMessage? replyMessage,
    String? gifUrl,
    String? sizeForGIF,
    // Function(SentMessageModel? sentMessageModel)? callback,
  }) async {
    try {
      String type = mediaType == 0
          ? "text"
          : MimeType.image == mimeType
              ? "image"
              : MimeType.video == mimeType
                  ? "video"
                  : MimeType.audio == mimeType
                      ? "audio"
                      : MimeType.gif == mimeType
                          ? "gif"
                          : MimeType.pdf == mimeType
                              ? "pdf"
                              : "document";
      final String messageId = DateTime.now().millisecondsSinceEpoch.toString();
      // if (mediaType != 0) {
      //   Utils.showLoader();
      // }
      String senderId = userDataCubit.state?.sId ?? "";
      if (senderId.isEmpty) {
        final userData = await dbHelper.getLoginData();
        senderId = userData?.sId ?? "";
      }
      if (mediaType == 0) {
        MessageModel message = MessageModel(
          chatId: "",
          messageId: messageId,
          content: content,
          createdAt: DateTime.now(),
          isRead: false,
          type: "text",
          isDeleted: false,
          sender: await Utils.currentUserToSender(),
          id: messageId,
          replyTo: replyMessage?.messageDetails,
        );
        // log("message  ${message.toJson()}");
        SavedMessage savedMessage = SavedMessage(
            id: messageId,
            messageDetails: message,
            messageId: messageId,
            senderDetails: message.sender);
        List<SavedMessage> updateList =
            List.from((state.savedMessagesData?.savedMessages ?? []));
        updateList.insert(0, savedMessage);

        if (state.savedMessagesData != null) {
          emit(state.copyWith(
              savedMessagesData: state.savedMessagesData!
                  .copyWith(savedMessages: updateList)));
        } else {
          emit(state.copyWith(
              savedMessagesData:
                  SavedMessagesData().copyWith(savedMessages: updateList)));
        }

        if (senderId.isNotEmpty) {
          _socketService.sendEvent(AppConstants.sendSavedMessage, {
            "sender": senderId,
            "messageId": messageId,
            "content": content,
            "type": "text",
            if (replyMessage != null) "replyToMessageId": replyMessage.messageId
          });
          showMessage("Send Saved Message Event = = ${{
            "sender": senderId,
            "messageId": messageId,
            "content": content,
            "type": "text"
          }}");
          if (replyMessage != null) {
            handleReplySavedMessage(null);
          }
          return;
        }
      } else {
        if (files == null && content == null) {
          // Utils.hideLoader();
          return;
        }
        List<FileElement> fileEle;

        if (type == "gif") {
          fileEle = [FileElement(url: gifUrl, fileName: "GIF")];
        } else {
          fileEle = await Future.wait(
            files!.map(
              (e) async => FileElement(
                file: e,
                fileSize: await e.length(),
              ),
            ),
          );
        }
        MessageModel message = MessageModel(
          chatId: "",
          messageId: messageId,
          content: content,
          createdAt: DateTime.now(),
          isRead: false,
          type: type,
          isDeleted: false,
          sender: await Utils.currentUserToSender(),
          id: messageId,
          files: fileEle,
          replyTo: replyMessage?.messageDetails,
        );
        // log("message  ${message.toJson()}");
        SavedMessage savedMessage = SavedMessage(
            id: messageId,
            messageDetails: message,
            messageId: messageId,
            senderDetails: message.sender);
        List<SavedMessage> updateList =
            List.from((state.savedMessagesData?.savedMessages ?? []));
        updateList.insert(0, savedMessage);

        if (state.savedMessagesData != null) {
          emit(state.copyWith(
              savedMessagesData: state.savedMessagesData!
                  .copyWith(savedMessages: updateList)));
        } else {
          emit(state.copyWith(
              savedMessagesData:
                  SavedMessagesData().copyWith(savedMessages: updateList)));
        }
        if (replyMessage != null) {
          handleReplySavedMessage(null);
        }
      }

      if (files == null && content == null) {
        // Utils.hideLoader();
        return;
      }

      showMessage("sent message requiest ==>${mimeType.name}  ${content}");
      SentMessageModel response = await apiClient.sentSaveMessage(context,
          mediaType: mediaType,
          type: type,
          // chatId: chatId,
          content: content,
          files: files,
          gifUrl: gifUrl,
          sizeForGIF: sizeForGIF,
          messageId: messageId,
          replyToMessageId:
              (replyMessage != null) ? replyMessage.messageId : null);
      if (response.status == Utils.APISUCCESS) {
        if (mediaType != 0 && response.data != null) {
          showMessage(
              "sent save message responce ==>${response.data?.toJson()}");
          SavedMessage savedMessage = SavedMessage(
              id: messageId,
              messageDetails: response.data,
              messageId: messageId,
              senderDetails: response.data?.sender);
          List<SavedMessage> updateList =
              List.from((state.savedMessagesData?.savedMessages ?? []).map(
            (e) {
              if (e.id == savedMessage.id) {
                return savedMessage;
              }
              return e;
            },
          ));

          // updateList.insert(0, savedMessage);

          emit(state.copyWith(
              replyingToSavedMessage: null,
              savedMessagesData: state.savedMessagesData!
                  .copyWith(savedMessages: updateList)));
        }

        emit(state.copyWith(
          sendMessageState: LoadingState.success,
        ));
      }
    } catch (e, st) {
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""),
          seconds: 3);
      log("sent Message==${e} $st");
      // emit(SentMessageError(e.toString()));
    } finally {
      if (mediaType != 0) {
        Utils.hideLoader();
      }
    }
  }

  Future<void> clearAllSavedMessages(BuildContext context,
      {Function(CommonMessageResponse)? callback}) async {
    try {
      Utils.showLoader();
      CommonMessageResponse response =
          await apiClient.clearAllSavedMessages(context);
      if (response.status == Utils.APISUCCESS) {
        callback?.call(response);
        emit(state.copyWith(
            savedMessagesData:
                state.savedMessagesData?.copyWith(savedMessages: [])));
      }
    } catch (e) {
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""),
          seconds: 3);
    } finally {
      Utils.hideLoader();
    }
  }

  Future<void> deleteSavedMessages(
      String messageId, int index, BuildContext context,
      {Function(CommonMessageResponse)? callback}) async {
    try {
      if (messageId.isEmpty) {
        return;
      }
      Utils.showLoader();
      CommonMessageResponse response = await apiClient.deleteSavedMessages(
          messageId: messageId, context: context);
      if (response.status == Utils.APISUCCESS) {
        SavedMessagesData savedMessagesData =
            SavedMessagesData.fromJson(state.savedMessagesData!.toJson(), "");
        List<SavedMessage> updatedMessageList =
            savedMessagesData.savedMessages ?? [];
        updatedMessageList.removeAt(index);
        savedMessagesData.copyWith(savedMessages: updatedMessageList);
        callback?.call(response);
        emit(state.copyWith(savedMessagesData: savedMessagesData));
        showMessage("deleteSavedMessages==>${messageId}");
      }
    } catch (e) {
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""),
          seconds: 3);
    } finally {
      Utils.hideLoader();
    }
  }

  void editSavedMessage({
    required SavedMessage message,
    required String newText,
    required void Function() callback,
  }) {
    // final encryptionHelper = EncryptionHelper();
    // final encryptedContent =
    //     encryptionHelper.encryptMessage(newText ?? "", aesKey ?? "");
    Map<String, dynamic> data = {
      "messageId": message.messageId,
      "editedContent": newText,
      "userId": message.senderDetails?.id
    };
    // showMessage("edited message == $data");
    SocketService().editSavedMessage(data);
    callback.call();
  }

  void updateSavedMessageList(message) {
    if ((state.savedMessagesData?.savedMessages ?? []).isEmpty) return;
    SavedMessagesData savedMessagesData = state.savedMessagesData!;
    List<SavedMessage> updatedMessageList =
        (savedMessagesData.savedMessages ?? []).map(
      (e) {
        if (e.messageId == message["messageId"]) {
          return SavedMessage.fromJson(message["message"], "");
        }
        return e;
      },
    ).toList();
    savedMessagesData =
        savedMessagesData.copyWith(savedMessages: updatedMessageList);
    emit(state.copyWith(savedMessagesData: savedMessagesData));
  }

  void onEditSaveMessage(Map<String, dynamic> message) {
    if ((state.savedMessagesData?.savedMessages ?? []).isEmpty) return;

    SavedMessagesData savedMessagesData = state.savedMessagesData!;
    SavedMessage updatedMessage = SavedMessage.fromJson(message, "");
    log("updateSavedMessageList inner 1111${updatedMessage.toJson()}");
    List<SavedMessage> updatedMessageList =
        savedMessagesData.savedMessages!.map(
      (e) {
        if (e.messageId == updatedMessage.messageId) {
          log("updateSavedMessageList inner ${updatedMessage.toJson()}");
          return e.copyWith(
              messageDetails: e.messageDetails?.copyWith(
                  content: updatedMessage.messageDetails?.content,
                  isEditedMessage: updatedMessage
                      .messageDetails?.isEditedMessage)); // Ensure correct path
        }
        return e;
      },
    ).toList();

    // Ensure a new instance is created
    SavedMessagesData newSavedMessagesData =
        savedMessagesData.copyWith(savedMessages: updatedMessageList);

    emit(state.copyWith(savedMessagesData: newSavedMessagesData));
  }

  void onReactSavedMessage(Map<String, dynamic> message) {
    if ((state.savedMessagesData?.savedMessages ?? []).isEmpty) return;

    SavedMessagesData savedMessagesData = state.savedMessagesData!;
    SavedMessage updatedMessage = SavedMessage.fromJson(message, "");
    log("updateSavedMessageList inner 1111${updatedMessage.toJson()}");
    List<SavedMessage> updatedMessageList =
        savedMessagesData.savedMessages!.map(
      (e) {
        if (e.messageId == updatedMessage.messageId) {
          log("updateSavedMessageList inner ${updatedMessage.toJson()}");
          return e.copyWith(
              messageDetails: e.messageDetails?.copyWith(
            reactions: updatedMessage.messageDetails?.reactions,
          )); // Ensure correct path
        }
        return e;
      },
    ).toList();

    // Ensure a new instance is created
    SavedMessagesData newSavedMessagesData =
        savedMessagesData.copyWith(savedMessages: updatedMessageList);

    emit(state.copyWith(savedMessagesData: newSavedMessagesData));
  }

  Future<void> editMessage(
      {required MessageModel message,
      required String newText,
      required void Function() callback,
      required String aesKey}) async {
    final encryptionHelper = EncryptionHelper();
    final encryptedContent =
        encryptionHelper.encryptMessage(newText ?? "", aesKey ?? "");
    Map<String, dynamic> data = {
      "messageId": message.messageId,
      "editedContent": encryptedContent,
      "chatId": message.chatId,
      "userId": message.sender?.id
    };
    // showMessage("edited message == $data");
    SocketService().editMessage(data);
    // await messageRepo.saveMessage(message, AppPreference.getCurrentUserId());
    callback.call();
  }

  Future<void> reactMessage({
    required MessageModel message,
    required String reaction,
    // required void Function() callback,
  }) async {
    List<String> reactions = message.reactions ?? [];
    UserData? user = await dbHelper.getLoginData();
    reactions.add(reaction);
    Map<String, dynamic> data = {
      "messageId": message.messageId,
      "reactions": [reaction],
      "chatId": message.chatId,
      "userId": user?.sId ?? "",
    };
    // showMessage("edited message == $data");
    SocketService().reactMessageEvent(data);
    // callback.call();
  }

  Future<void> reactSavedMessage({
    required SavedMessage message,
    required String reaction,
    // required void Function() callback,
  }) async {
    List<String> reactions = message.messageDetails?.reactions ?? [];
    UserData? user = await dbHelper.getLoginData();
    reactions.add(reaction);
    Map<String, dynamic> data = {
      "messageId": message.messageId,
      "reactions": reactions,
      "userId": user?.sId ?? "",
    };
    // showMessage("edited message == $data");
    SocketService().reactSavedMessageEvent(data);
    // callback.call();
  }

  void handleUnblockUser(bool value) {
    emit(state.copyWith(
        chatMessageModel: state.chatMessageModel?.copyWith(youBlocked: value)));
  }

  void handleWhenUserBlouckedYou(bool value) {
    emit(state.copyWith(
        chatMessageModel: state.chatMessageModel?.copyWith(isBlocked: value)));
  }

  void handleWhenUserRemoveFromGroup() {
    emit(state.copyWith(
        chatMessageModel:
            state.chatMessageModel?.copyWith(removeFromChat: true)));
  }

  void handleWhenUserAddedToGroup(Map<String, dynamic> data) {
    emit(state.copyWith(
        chatMessageModel: state.chatMessageModel?.copyWith(
      removeFromChat: false,
    )));
  }

  void pinMessage({required String messageId, required String chatId}) {
    SocketService().sendEvent(AppConstants.pinedMessage, {
      "messageId": messageId,
      "chatId": chatId,
    });
  }

  void pinSavedMessage({required String messageId, required String userId}) {
    SocketService().sendEvent(AppConstants.pinedSavedMessage, {
      "messageId": messageId,
      "userId": userId,
    });
  }

  void unPinMessage({required String messageId, required String chatId}) {
    SocketService().sendEvent(AppConstants.unPinedMessage, {
      "messageId": messageId,
      "chatId": chatId,
    });
  }

  void unPinSavedMessage({required String messageId, required String userId}) {
    SocketService().sendEvent(AppConstants.unPinedSavedMessage, {
      "messageId": messageId,
      "userId": userId,
    });
  }

  void onUnPinnedMessage({required String chatId, required String messageId}) {
    ChatMessageModel? chatMessageModel = state.chatMessageModel;
    if (chatMessageModel != null) {
      List<MessageModel> pinMessages =
          List.from(chatMessageModel.pinnedMessages ?? []);

      List<MessageModel> chatMessages =
          (chatMessageModel.messages ?? Set.of([])).isEmpty
              ? []
              : List.from(chatMessageModel.messages!.toList());

      pinMessages.removeWhere((message) => message.messageId == messageId);

      // Update pinned status in chatMessages list
      chatMessages = chatMessages.map((message) {
        if (message.messageId == messageId) {
          return message.copyWith(
              pinned: false); // Assuming you have a copyWith method
        }
        return message;
      }).toList();
      chatMessageModel = chatMessageModel.copyWith(
          pinnedMessages: pinMessages.toSet(), messages: chatMessages.toSet());
      emit(state.copyWith(
          chatMessageModel: chatMessageModel,
          chatList: chatMessageModel.messages));
    }
  }

  void onPinnedMessage({required chatId, required String messageId}) {
    ChatMessageModel? chatMessageModel = state.chatMessageModel;
    if (chatMessageModel != null) {
      List<MessageModel> pinMessages =
          List.from(chatMessageModel.pinnedMessages ?? []);

      List<MessageModel> chatMessages =
          (chatMessageModel.messages ?? Set.of([])).isEmpty
              ? []
              : List.from(chatMessageModel.messages!.toList());

      MessageModel? pinnedMessages;
      // Update pinned status in chatMessages list
      chatMessages = chatMessages.map((message) {
        if (message.messageId == messageId) {
          pinnedMessages = message.copyWith(pinned: true);

          return pinnedMessages!; // Assuming you have a copyWith method
        }
        return message;
      }).toList();

      pinMessages.add(pinnedMessages!);
      chatMessageModel = chatMessageModel.copyWith(
          pinnedMessages: pinMessages.toSet(), messages: chatMessages.toSet());
      emit(state.copyWith(
          chatMessageModel: chatMessageModel,
          chatList: chatMessageModel.messages));
    }
  }

  void onPinnedSavedMessage({required String messageId}) {
    SavedMessagesData? savedMessageModel = state.savedMessagesData;
    if (savedMessageModel != null) {
      List<SavedMessage> pinSavedMessages =
          List.from(savedMessageModel.pinnedSavedMessages ?? []);

      List<SavedMessage> savedMessages =
          List.from(savedMessageModel.savedMessages ?? []);

      SavedMessage? pinnedMessage;
      // Update pinned status in chatMessages list
      savedMessages = savedMessages.map((message) {
        if (message.messageId == messageId) {
          MessageModel? msg = message.messageDetails?.copyWith(pinned: true);
          pinnedMessage = message.copyWith(messageDetails: msg);

          return pinnedMessage!; // Assuming you have a copyWith method
        }
        return message;
      }).toList();

      pinSavedMessages.add(pinnedMessage!);
      savedMessageModel = savedMessageModel.copyWith(
          pinnedSavedMessages: pinSavedMessages.toSet().toList(),
          savedMessages: savedMessages.toSet().toList());
      emit(state.copyWith(
        savedMessagesData: savedMessageModel,
      ));
    }
  }

  void onUnPinnedSavedMessage({required String messageId}) {
    SavedMessagesData? savedMessageModel = state.savedMessagesData;
    if (savedMessageModel != null) {
      List<SavedMessage> pinSavedMessages =
          List.from(savedMessageModel.pinnedSavedMessages ?? []);

      List<SavedMessage> savedMessages =
          List.from(savedMessageModel.savedMessages ?? []);
      pinSavedMessages.removeWhere((message) => message.messageId == messageId);

      // Update pinned status in chatMessages list
      savedMessages = savedMessages.map((message) {
        if (message.messageId == messageId) {
          MessageModel? msg = message.messageDetails?.copyWith(pinned: false);
          return message.copyWith(messageDetails: msg);

          // Assuming you have a copyWith method
        }
        return message;
      }).toList();

      savedMessageModel = savedMessageModel.copyWith(
          pinnedSavedMessages: pinSavedMessages.toSet().toList(),
          savedMessages: savedMessages.toSet().toList());
      emit(state.copyWith(
        savedMessagesData: savedMessageModel,
      ));
    }
  }

  Future<void> setNickname({
    required BuildContext context,
    required String contactUserId,
    required String nickName,
    Function(SetNicknameResponse)? callback,
  }) async {
    try {
      log("contactUserId -->$contactUserId  Name > $nickName");
      if (contactUserId.isEmpty) {
        return;
      }
      Utils.showLoader();
      SetNicknameResponse response = await apiClient.nickNameSet(
        contactUserId: contactUserId,
        nickName: nickName,
      );
      if (response.status == Utils.APISUCCESS) {
        // await messageRepo.clearChat(
        //   chatId: chatId,
        // );
        // emit(state.copyWith(
        //     chatList: Set.of([]),
        //     chatMessageModel:
        //         state.chatMessageModel?.copyWith(messages: Set.of([]))));

        // emit(state.copyWith(
        //     chatList: Set.of([]),
        //     chatMessageModel:
        //         state.chatMessageModel?.copyWith(messages: Set.of([]))));
        callback?.call(response);
      }
    } catch (e, st) {
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""),
          seconds: 3);
      showMessage("Error ==> $e $st");
    } finally {
      Utils.hideLoader();
    }
  }

  Future<void> toggleNickname({
    required BuildContext context,
    required String contactUserId,
    required bool isActiveNickname,
    Function(ToggleNickNameResponse)? callback,
  }) async {
    try {
      log("toggleNickname contactUserId -->$contactUserId ");
      if (contactUserId.isEmpty) {
        return;
      }
      Utils.showLoader();
      ToggleNickNameResponse response = await apiClient.toggleNickName(
        contactUserId: contactUserId,
        isActiveNickname: isActiveNickname
      );
      if (response.status == Utils.APISUCCESS) {
        // await messageRepo.clearChat(
        //   chatId: chatId,
        // );
        // emit(state.copyWith(
        //     chatList: Set.of([]),
        //     chatMessageModel:
        //         state.chatMessageModel?.copyWith(messages: Set.of([]))));

        // emit(state.copyWith(
        //     chatList: Set.of([]),
        //     chatMessageModel:
        //         state.chatMessageModel?.copyWith(messages: Set.of([]))));
        callback?.call(response);
      }
    } catch (e, st) {
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""));
      showMessage("Error ==> $e $st");
    } finally {
      Utils.hideLoader();
    }
  }
}
