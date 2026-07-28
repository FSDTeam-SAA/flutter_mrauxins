import 'package:two_one_two_messenger/models/chat_message_model.dart';
import 'package:two_one_two_messenger/models/create_conversaion_model.dart';
import 'package:equatable/equatable.dart';
import 'package:two_one_two_messenger/services/pagination_handler.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

class ChatState extends Equatable {
  // Loading states for different operations
  final LoadingState chatLoadingState;
  final LoadingState createConversationState;
  final LoadingState sendMessageState;
  // final bool isSendMessage;
  final bool chatMessageLoadingMore;
  final MessageModel? replyingToMessage;
  // Error messages for specific operations
  final String? chatErrorMessage;
  final String? createConversationErrorMessage;
  final String? sendMessageErrorMessage;
  // Data for conversations and messages
  final ChatMessageModel? chatMessageModel;
  final Set<MessageModel>? chatList;
  final CreateConversionData? createConversationModel;
  final String? currentConversationId;
  final PaginationController chatPagination;
  ChatState(
      {// this.isSendMessage = true,
      this.chatLoadingState = LoadingState.success,
      this.createConversationState = LoadingState.success,
      this.sendMessageState = LoadingState.success,
      this.chatErrorMessage,
      this.createConversationErrorMessage,
      this.sendMessageErrorMessage,
      this.chatList,
      this.replyingToMessage,
      this.createConversationModel,
      this.currentConversationId = '',
      this.chatMessageLoadingMore = false,
      PaginationController? chatPagination,
      this.chatMessageModel})
      : chatPagination = chatPagination ?? PaginationController();

  // Initial state factory
  factory ChatState.initial() {
    return ChatState();
  }

  // CopyWith method for immutability
  ChatState copyWith(
      {// bool? isSendMessage,
      LoadingState? chatLoadingState,
      PaginationController? chatPagination,
      bool? chatMessageLoadingMore,
      LoadingState? createConversationState,
      LoadingState? sendMessageState,
      String? chatErrorMessage,
      String? createConversationErrorMessage,
      String? sendMessageErrorMessage,
      Set<MessageModel>? chatList,
      MessageModel? replyingToMessage,
      CreateConversionData? createConversationModel,
      String? currentConversationId,
      ChatMessageModel? chatMessageModel}) {
    return ChatState(
      // isSendMessage: isSendMessage ?? this.isSendMessage,
      chatMessageLoadingMore:
          chatMessageLoadingMore ?? this.chatMessageLoadingMore,
      chatLoadingState: chatLoadingState ?? this.chatLoadingState,
      createConversationState:
          createConversationState ?? this.createConversationState,
      sendMessageState: sendMessageState ?? this.sendMessageState,
      chatErrorMessage: chatErrorMessage ?? this.chatErrorMessage,
      createConversationErrorMessage:
          createConversationErrorMessage ?? this.createConversationErrorMessage,
      sendMessageErrorMessage:
          sendMessageErrorMessage ?? this.sendMessageErrorMessage,
      chatList: chatList ?? this.chatList,
      createConversationModel:
          createConversationModel ?? this.createConversationModel,
      currentConversationId:
          currentConversationId ?? this.currentConversationId,
      replyingToMessage: replyingToMessage,
      chatMessageModel: chatMessageModel ?? this.chatMessageModel,
      chatPagination: chatPagination ?? this.chatPagination,
    );
  }

  @override
  List<Object?> get props => [
        chatLoadingState,
        createConversationState,
        sendMessageState,
        chatErrorMessage,
        createConversationErrorMessage,
        sendMessageErrorMessage,
        chatList,
        // isSendMessage,
        createConversationModel,
        currentConversationId,
        chatMessageModel,
        chatMessageLoadingMore,
        replyingToMessage,
        chatPagination,
      ];
}
