import 'package:equatable/equatable.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

import '../models/stories_response.dart';

// abstract class ViewStoriesState {}

// class ViewStoriesInitial extends ViewStoriesState {}

// class ViewStoriesLoading extends ViewStoriesState {}

// class ViewStoriesSuccess extends ViewStoriesState {
//   ViewStoriesSuccess();
// }

// class ViewStoriesLoaded extends ViewStoriesState {
//   final CurrentUserStoriesResponse createStoriesResponse;
//   List<CurrentUserStoriesData> currentUserStoriesList;
//   ViewStoriesLoaded(this.createStoriesResponse, this.currentUserStoriesList);
// }

// class DeleteStoriesLoaded extends ViewStoriesState {
//   final DeleteStoriesResponse deleteStoriesResponse;
//   DeleteStoriesLoaded(this.deleteStoriesResponse);
// }

// class ViewStoriesError extends ViewStoriesState {
//   final String message;
//   ViewStoriesError(this.message);
// }

// class ViewStoriesEmpty extends ViewStoriesState {}

// class VideoPlayerInitialized extends ViewStoriesState {}
// class VideoPlayerPaused extends ViewStoriesState {}
// class VideoPlayerPlaying extends ViewStoriesState {}
// class VideoPlayerCompleted extends ViewStoriesState {}

class ViewStoriesState extends Equatable {
  final LoadingState loadingState;
  final CurrentUserStoriesResponse? currentUserStoriesResponse;
  final List<CurrentUserStoriesData> currentUserStoriesList;
  final DeleteStoriesResponse? deleteStoriesResponse;
  final String? errorMessage;
  final bool isVideoInitialized;
  final bool isVideoPlaying;
  final bool isVideoCompleted;

  const ViewStoriesState({
    this.loadingState = LoadingState.success,
    this.currentUserStoriesResponse,
    this.currentUserStoriesList = const [],
    this.deleteStoriesResponse,
    this.errorMessage,
    this.isVideoInitialized = false,
    this.isVideoPlaying = false,
    this.isVideoCompleted = false,
  });

  ViewStoriesState copyWith({
    LoadingState? loadingState,
    CurrentUserStoriesResponse? currentUserStoriesResponse,
    List<CurrentUserStoriesData>? currentUserStoriesList,
    DeleteStoriesResponse? deleteStoriesResponse,
    String? errorMessage,
    bool? isVideoInitialized,
    bool? isVideoPlaying,
    bool? isVideoCompleted,
  }) {
    return ViewStoriesState(
      loadingState: loadingState ?? this.loadingState,
      currentUserStoriesResponse:
          currentUserStoriesResponse ?? this.currentUserStoriesResponse,
      currentUserStoriesList:
          currentUserStoriesList ?? this.currentUserStoriesList,
      deleteStoriesResponse:
          deleteStoriesResponse ?? this.deleteStoriesResponse,
      errorMessage: errorMessage ?? this.errorMessage,
      isVideoInitialized: isVideoInitialized ?? this.isVideoInitialized,
      isVideoPlaying: isVideoPlaying ?? this.isVideoPlaying,
      isVideoCompleted: isVideoCompleted ?? this.isVideoCompleted,
    );
  }

  @override
  List<Object?> get props => [
        loadingState,
        currentUserStoriesResponse,
        currentUserStoriesList,
        deleteStoriesResponse,
        errorMessage,
        isVideoInitialized,
        isVideoPlaying,
        isVideoCompleted,
      ];
}
