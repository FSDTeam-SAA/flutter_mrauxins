import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/models/saved_messages.dart';
import 'package:two_one_two_messenger/services/socket_service.dart';
import 'package:two_one_two_messenger/utils/constants.dart';

import '../database/local_db.dart';
import '../models/chat_message_model.dart';
import '../models/sent_message_model.dart';
import '../services/api_client.dart';
import '../utils/utils.dart';
import 'saved_messages_state.dart';

class SavedMessagesCubit extends Cubit<SavedMessagesState> {
  final ApiClient apiClient;
  final DatabaseHelper dbHelper;
  final _socketService = SocketService();

  SavedMessagesCubit(this.apiClient, this.dbHelper)
      : super(const SavedMessagesState());

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

  void handleReplySavedMessage(SavedMessage? message) {
    emit(state.copyWith(replyingToSavedMessage: message));
  }

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

      showMessage("sent message requiest ==>${mimeType.name}  $content");
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
          savedMessageLoadingState: LoadingState.success,
        ));
      }
    } catch (e, st) {
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""),
          seconds: 3);
      log("sent Message==$e $st");
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
        showMessage("deleteSavedMessages==>$messageId");
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

  void pinSavedMessage({required String messageId, required String userId}) {
    SocketService().sendEvent(AppConstants.pinedSavedMessage, {
      "messageId": messageId,
      "userId": userId,
    });
  }

  void unPinSavedMessage({required String messageId, required String userId}) {
    SocketService().sendEvent(AppConstants.unPinedSavedMessage, {
      "messageId": messageId,
      "userId": userId,
    });
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
}
