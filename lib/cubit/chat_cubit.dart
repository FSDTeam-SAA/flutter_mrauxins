import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:two_one_two_messenger/database/message_db_repo.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/services/encryption_service.dart';
import 'package:two_one_two_messenger/services/pagination_handler.dart';
import 'package:two_one_two_messenger/services/socket_service.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/media_storage_helper.dart';

import '../database/local_db.dart';
import '../models/chat_message_model.dart';
import '../models/create_conversaion_model.dart';
import '../services/api_client.dart';
import '../utils/utils.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ApiClient apiClient;
  final DatabaseHelper dbHelper;
  final MessageRepository messageRepo;
  // final String currentUserId;

  bool isChatPage = false;
  String chatId = '';
  final _socketService = SocketService();

  ChatCubit(this.apiClient, this.dbHelper)
      : messageRepo = MessageRepository(dbHelper),
        super(ChatState.initial());

  void changeDropdownValue(String newValue) {
    // emit(newValue);
  }

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
    log("updateOnlineLastStatus $data");
    if (chatId.isNotEmpty) {
      ChatMessageModel? chatMessageModel = state.chatMessageModel;
      chatMessageModel = chatMessageModel?.copyWith(
          lastSeen: data["lastSeen"] == null
              ? null
              : DateTime.parse(data["lastSeen"]).toLocal(),
          isOnline: data["isOnline"]);

      showMessage("updateOnlineLastStatus ${chatMessageModel?.isOnline}");

      emit(state.copyWith(chatMessageModel: chatMessageModel));
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

  Future<void> resetChatScreenState() async {
    emit(state.copyWith(
        chatLoadingState: LoadingState.success,
        chatMessageModel: ChatMessageModel(),
        chatList: <MessageModel>{}));
    await Future.delayed(Durations.extralong1);
  }

  final PaginationController chatPaginationController =
      PaginationController(limit: 50);

  int chatCurrentPage = 1;
  int chatTotalPage = 1;
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
          debugPrint(
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
            chatList: <MessageModel>{},
            chatMessageModel:
                state.chatMessageModel?.copyWith(messages: <MessageModel>{})));
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
      showMessage("Error ==> $e $st");
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

  void updateMessageFromChatList(
      BuildContext context, MessageModel message, String messageId) {
    Set<MessageModel> updatedMessages =
        (state.chatList ?? <MessageModel>{}).map(
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
    final updatedMessages = (state.chatList ?? <MessageModel>{}).map((message) {
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
    debugPrint("changeMessageStatus==> updateMessageStatus  $lastMsgId");
    emit(state.copyWith(chatList: updatedMessages));
  }

  void handleReplyMessage(MessageModel? message) {
    emit(state.copyWith(replyingToMessage: message));
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
      debugPrint(
          "retryFailedMessage=> ${message.content} $aesKey  $mediaType $from");
      if (mediaType == 0) {
        // Save to local DB first

        // Send via socket
        debugPrint("retryFailedMessage=> ${message.content} $encryptedContent");
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
            debugPrint("sent message sucessfully>>");
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

      // Conversation creation can fail/lag (e.g. network blip) leaving
      // chatId/aesKey empty; encrypting with an empty key crashes deep in
      // EncryptionHelper, so bail out early with a clear message instead.
      if ((chatId ?? "").isEmpty || (aesKey ?? "").isEmpty) {
        Utils.showSnackBar(
          context,
          "Couldn't send message, please try again",
          seconds: 3,
        );
        return;
      }

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
            debugPrint("sent message sucessfully>>");
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

      debugPrint("Message Time :->$messageTime");
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

      debugPrint("Media upload failed: ${e.toString()}\n$st");
      Utils.showSnackBar(
        context,
        'Failed to upload media: ${e.toString().replaceAll("Exception: ", "")}',
        seconds: 3,
      );
    }
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

  void unPinMessage({required String messageId, required String chatId}) {
    SocketService().sendEvent(AppConstants.unPinedMessage, {
      "messageId": messageId,
      "chatId": chatId,
    });
  }

  void onUnPinnedMessage({required String chatId, required String messageId}) {
    ChatMessageModel? chatMessageModel = state.chatMessageModel;
    if (chatMessageModel != null) {
      List<MessageModel> pinMessages =
          List.from(chatMessageModel.pinnedMessages ?? []);

      List<MessageModel> chatMessages =
          (chatMessageModel.messages ?? <dynamic>{}).isEmpty
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
          (chatMessageModel.messages ?? <dynamic>{}).isEmpty
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

}
