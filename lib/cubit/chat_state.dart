import 'package:two_one_two_messenger/models/chat_message_model.dart';
import 'package:two_one_two_messenger/models/create_conversaion_model.dart';
import 'package:equatable/equatable.dart';
import 'package:two_one_two_messenger/models/saved_messages.dart';
import 'package:two_one_two_messenger/services/pagination_handler.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

class ChatState extends Equatable {
  // Loading states for different operations
  final LoadingState chatLoadingState;
  final LoadingState savedMessageLoadingState;
  final LoadingState createConversationState;
  final LoadingState sendMessageState;
  final CallType? callType;
  final bool isSpeaker;
  final bool isInCall;
  // final bool isSendMessage;
  final bool savedMessageLoadingMore;
  final bool chatMessageLoadingMore;
  final MessageModel? replyingToMessage;
  // Error messages for specific operations
  final String? chatErrorMessage;
  final String? createConversationErrorMessage;
  final String? sendMessageErrorMessage;
  final bool isSearchSavedMessages;
  // Data for conversations and messages
  final ChatMessageModel? chatMessageModel;
  final Set<MessageModel>? chatList;
  final SavedMessagesData? savedMessagesData;
  final CreateConversionData? createConversationModel;
  final List<TypingModel>? currentTypingusers;
  final String? currentConversationId;
  final SavedMessage? replyingToSavedMessage;
  final PaginationController chatPagination;
  ChatState(
      {this.isSpeaker = true,
      // this.isSendMessage = true,
      this.isInCall = false,
      this.chatLoadingState = LoadingState.success,
      this.savedMessageLoadingState = LoadingState.success,
      this.createConversationState = LoadingState.success,
      this.sendMessageState = LoadingState.success,
      this.chatErrorMessage,
      this.createConversationErrorMessage,
      this.sendMessageErrorMessage,
      this.chatList,
      this.replyingToMessage,
      this.savedMessagesData,
      this.createConversationModel,
      this.currentConversationId = '',
      this.currentTypingusers,
      this.callType,
      this.savedMessageLoadingMore = false,
      this.chatMessageLoadingMore = false,
      this.isSearchSavedMessages = false,
      this.replyingToSavedMessage,
      PaginationController? chatPagination,
      this.chatMessageModel})
      : chatPagination = chatPagination ?? PaginationController();

  // Initial state factory
  factory ChatState.initial() {
    return ChatState();
  }

  // CopyWith method for immutability
  ChatState copyWith(
      {bool? isSpeaker,
      bool? isInCall,
      // bool? isSendMessage,
      bool? isSearchSavedMessages,
      LoadingState? chatLoadingState,
      PaginationController? chatPagination,
      LoadingState? savedMessageLoadingState,
      bool? savedMessageLoadingMore,
      bool? chatMessageLoadingMore,
      LoadingState? createConversationState,
      LoadingState? sendMessageState,
      String? chatErrorMessage,
      String? createConversationErrorMessage,
      String? sendMessageErrorMessage,
      Set<MessageModel>? chatList,
      SavedMessagesData? savedMessagesData,
      CallType? callType,
      MessageModel? replyingToMessage,
      SavedMessage? replyingToSavedMessage,
      CreateConversionData? createConversationModel,
      String? currentConversationId,
      List<TypingModel>? currentTypingusers,
      ChatMessageModel? chatMessageModel}) {
    return ChatState(
      isSpeaker: isSpeaker ?? this.isSpeaker,
      isInCall: isInCall ?? this.isInCall,
      // isSendMessage: isSendMessage ?? this.isSendMessage,
      chatMessageLoadingMore:
          chatMessageLoadingMore ?? this.chatMessageLoadingMore,
      savedMessageLoadingMore:
          savedMessageLoadingMore ?? this.savedMessageLoadingMore,
      chatLoadingState: chatLoadingState ?? this.chatLoadingState,
      savedMessageLoadingState:
          savedMessageLoadingState ?? this.savedMessageLoadingState,
      createConversationState:
          createConversationState ?? this.createConversationState,
      sendMessageState: sendMessageState ?? this.sendMessageState,
      chatErrorMessage: chatErrorMessage ?? this.chatErrorMessage,
      createConversationErrorMessage:
          createConversationErrorMessage ?? this.createConversationErrorMessage,
      sendMessageErrorMessage:
          sendMessageErrorMessage ?? this.sendMessageErrorMessage,
      chatList: chatList ?? this.chatList,
      savedMessagesData: savedMessagesData ?? this.savedMessagesData,
      callType: callType ?? this.callType,
      createConversationModel:
          createConversationModel ?? this.createConversationModel,
      currentConversationId:
          currentConversationId ?? this.currentConversationId,
      currentTypingusers: currentTypingusers ?? this.currentTypingusers,
      replyingToMessage: replyingToMessage,
      replyingToSavedMessage: replyingToSavedMessage,
      chatMessageModel: chatMessageModel ?? this.chatMessageModel,
      chatPagination: chatPagination ?? this.chatPagination,
      isSearchSavedMessages:
          isSearchSavedMessages ?? this.isSearchSavedMessages,
    );
  }

  @override
  List<Object?> get props => [
        chatLoadingState,
        createConversationState,
        sendMessageState,
        savedMessageLoadingState,
        chatErrorMessage,
        savedMessagesData,
        createConversationErrorMessage,
        sendMessageErrorMessage,
        chatList,
        callType,
        // isSendMessage,
        isInCall,
        isSpeaker,
        createConversationModel,
        currentConversationId,
        currentTypingusers,
        chatMessageModel,
        savedMessageLoadingMore,
        chatMessageLoadingMore,
        isSearchSavedMessages,
        replyingToMessage,
        replyingToSavedMessage, chatPagination,
      ];
}

// import 'package:two_one_two_messenger/models/chat_message_model.dart';
// import 'package:two_one_two_messenger/models/create_conversaion_model.dart';
// import 'package:equatable/equatable.dart';
// import 'package:two_one_two_messenger/models/saved_messages.dart';
// import 'package:two_one_two_messenger/utils/utils.dart';

// class ChatState extends Equatable {
//   // Loading states for different operations
//   final LoadingState chatLoadingState;
//   final LoadingState savedMessageLoadingState;
//   final LoadingState createConversationState;
//   final LoadingState sendMessageState;
//   final CallType? callType;
//   final bool isSpeaker;
//   final bool isInCall;
//   final bool isSendMessage;
//   final bool savedMessageLoadingMore;
//   final bool chatMessageLoadingMore;
//   final MessageModel? replyingToMessage;
//   // Error messages for specific operations
//   final String? chatErrorMessage;
//   final String? createConversationErrorMessage;
//   final String? sendMessageErrorMessage;
//   final bool isSearchSavedMessages;
//   // Data for conversations and messages
//   final ChatMessageModel? chatMessageModel;
//   final Set<MessageModel>? chatList;
//   final SavedMessagesData? savedMessagesData;
//   final CreateConversionData? createConversationModel;
//   final List<TypingModel>? currentTypingusers;
//   final String? currentConversationId;
//   final SavedMessage? replyingToSavedMessage;
//   const ChatState(
//       {this.isSpeaker = true,
//       this.isSendMessage = true,
//       this.isInCall = false,
//       this.chatLoadingState = LoadingState.success,
//       this.savedMessageLoadingState = LoadingState.success,
//       this.createConversationState = LoadingState.success,
//       this.sendMessageState = LoadingState.success,
//       this.chatErrorMessage,
//       this.createConversationErrorMessage,
//       this.sendMessageErrorMessage,
//       this.chatList,
//       this.replyingToMessage,
//       this.savedMessagesData,
//       this.createConversationModel,
//       this.currentConversationId = '',
//       this.currentTypingusers,
//       this.callType,
//       this.savedMessageLoadingMore = false,
//       this.chatMessageLoadingMore = false,
//       this.isSearchSavedMessages = false,
//       this.replyingToSavedMessage,
//       this.chatMessageModel});

//   // Initial state factory
//   factory ChatState.initial() {
//     return const ChatState();
//   }

//   // CopyWith method for immutability
//   ChatState copyWith(
//       {bool? isSpeaker,
//       bool? isInCall,
//       bool? isSendMessage,
//       bool? isSearchSavedMessages,
//       LoadingState? chatLoadingState,
//       LoadingState? savedMessageLoadingState,
//       bool? savedMessageLoadingMore,
//       bool? chatMessageLoadingMore,
//       LoadingState? createConversationState,
//       LoadingState? sendMessageState,
//       String? chatErrorMessage,
//       String? createConversationErrorMessage,
//       String? sendMessageErrorMessage,
//       Set<MessageModel>? chatList,
//       SavedMessagesData? savedMessagesData,
//       CallType? callType,
//       MessageModel? replyingToMessage,
//       SavedMessage? replyingToSavedMessage,
//       CreateConversionData? createConversationModel,
//       String? currentConversationId,
//       List<TypingModel>? currentTypingusers,
//       ChatMessageModel? chatMessageModel}) {
//     return ChatState(
//       isSpeaker: isSpeaker ?? this.isSpeaker,
//       isInCall: isInCall ?? this.isInCall,
//       isSendMessage: isSendMessage ?? this.isSendMessage,
//       chatMessageLoadingMore:
//           chatMessageLoadingMore ?? this.chatMessageLoadingMore,
//       savedMessageLoadingMore:
//           savedMessageLoadingMore ?? this.savedMessageLoadingMore,
//       chatLoadingState: chatLoadingState ?? this.chatLoadingState,
//       savedMessageLoadingState:
//           savedMessageLoadingState ?? this.savedMessageLoadingState,
//       createConversationState:
//           createConversationState ?? this.createConversationState,
//       sendMessageState: sendMessageState ?? this.sendMessageState,
//       chatErrorMessage: chatErrorMessage ?? this.chatErrorMessage,
//       createConversationErrorMessage:
//           createConversationErrorMessage ?? this.createConversationErrorMessage,
//       sendMessageErrorMessage:
//           sendMessageErrorMessage ?? this.sendMessageErrorMessage,
//       chatList: chatList ?? this.chatList,
//       savedMessagesData: savedMessagesData ?? this.savedMessagesData,
//       callType: callType ?? this.callType,
//       createConversationModel:
//           createConversationModel ?? this.createConversationModel,
//       currentConversationId:
//           currentConversationId ?? this.currentConversationId,
//       currentTypingusers: currentTypingusers ?? this.currentTypingusers,
//       replyingToMessage: replyingToMessage,
//       replyingToSavedMessage: replyingToSavedMessage,
//       chatMessageModel: chatMessageModel ?? this.chatMessageModel,
//       isSearchSavedMessages:
//           isSearchSavedMessages ?? this.isSearchSavedMessages,
//     );
//   }

//   @override
//   List<Object?> get props => [
//         chatLoadingState,
//         createConversationState,
//         sendMessageState,
//         savedMessageLoadingState,
//         chatErrorMessage,
//         savedMessagesData,
//         createConversationErrorMessage,
//         sendMessageErrorMessage,
//         chatList,
//         callType,
//         isSendMessage,
//         isInCall,
//         isSpeaker,
//         createConversationModel,
//         currentConversationId,
//         currentTypingusers,
//         chatMessageModel,
//         savedMessageLoadingMore,
//         chatMessageLoadingMore,
//         isSearchSavedMessages,
//         replyingToMessage,
//         replyingToSavedMessage,
//       ];
// }
