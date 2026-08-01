import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

import 'api_client.dart';

class ChatClient {
  ChatClient(this._apiClient);

  final ApiClient _apiClient;

  Future<dynamic> getConversation({
    required BuildContext context,
    Map<String, dynamic>? params,
  }) =>
      _apiClient.getConversation(context: context, params: params);

  Future<dynamic> getConversationForForwadMessage(
    BuildContext context, {
    Map<String, dynamic>? params,
  }) =>
      _apiClient.getConversationForForwadMessage(
        context: context,
        params: params,
      );

  Future<dynamic> createConversion(String userId, BuildContext context) =>
      _apiClient.createConversion(userId, context);

  Future<dynamic> getChatMessages(
    String chatId,
    BuildContext context,
    String aesKey,
    Map<String, dynamic>? params,
  ) =>
      _apiClient.getChatMessages(chatId, context, aesKey, params);

  Future<dynamic> sentMessage(
    BuildContext context, {
    required int mediaType,
    required String type,
    required String messageId,
    required String messageTime,
    String? chatId,
    String? aesKey,
    String? content,
    String? replyToMessageId,
    List<XFile>? files,
    String? gifUrl,
    String? sizeForGIF,
    Function(double)? onProgress,
  }) =>
      _apiClient.sentMessage(
        context,
        mediaType: mediaType,
        type: type,
        messageId: messageId,
        messageTime: messageTime,
        chatId: chatId,
        aesKey: aesKey,
        content: content,
        replyToMessageId: replyToMessageId,
        files: files,
        gifUrl: gifUrl,
        sizeForGIF: sizeForGIF,
        onProgress: onProgress,
      );

  Future<dynamic> sentSaveMessage(
    BuildContext context, {
    required int mediaType,
    required String type,
    required String messageId,
    required String content,
    String? replyToMessageId,
    String? aesKey,
    List<XFile>? files,
    String? gifUrl,
    String? sizeForGIF,
  }) =>
      _apiClient.sentSaveMessage(
        context,
        mediaType: mediaType,
        type: type,
        messageId: messageId,
        content: content,
        replyToMessageId: replyToMessageId,
        aesKey: aesKey,
        files: files,
        gifUrl: gifUrl,
        sizeForGIF: sizeForGIF,
      );

  Future<dynamic> deleteChat({required String chatId}) =>
      _apiClient.deleteChat(chatId: chatId);

  Future<dynamic> clearChat(String chatId) => _apiClient.clearChat(chatId);

  Future<dynamic> saveMessage({
    required Map<String, dynamic> data,
    required BuildContext context,
  }) =>
      _apiClient.saveMessage(data: data, context: context);
}
