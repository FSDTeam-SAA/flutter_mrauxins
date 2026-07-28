import 'package:equatable/equatable.dart';
import 'package:two_one_two_messenger/models/saved_messages.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

class SavedMessagesState extends Equatable {
  final LoadingState savedMessageLoadingState;
  final bool savedMessageLoadingMore;
  final bool isSearchSavedMessages;
  final SavedMessagesData? savedMessagesData;
  final SavedMessage? replyingToSavedMessage;

  const SavedMessagesState({
    this.savedMessageLoadingState = LoadingState.success,
    this.savedMessageLoadingMore = false,
    this.isSearchSavedMessages = false,
    this.savedMessagesData,
    this.replyingToSavedMessage,
  });

  SavedMessagesState copyWith({
    LoadingState? savedMessageLoadingState,
    bool? savedMessageLoadingMore,
    bool? isSearchSavedMessages,
    SavedMessagesData? savedMessagesData,
    SavedMessage? replyingToSavedMessage,
  }) {
    return SavedMessagesState(
      savedMessageLoadingState:
          savedMessageLoadingState ?? this.savedMessageLoadingState,
      savedMessageLoadingMore:
          savedMessageLoadingMore ?? this.savedMessageLoadingMore,
      isSearchSavedMessages:
          isSearchSavedMessages ?? this.isSearchSavedMessages,
      savedMessagesData: savedMessagesData ?? this.savedMessagesData,
      replyingToSavedMessage: replyingToSavedMessage,
    );
  }

  @override
  List<Object?> get props => [
        savedMessageLoadingState,
        savedMessageLoadingMore,
        isSearchSavedMessages,
        savedMessagesData,
        replyingToSavedMessage,
      ];
}
