import 'package:equatable/equatable.dart';
import '../models/stories_response.dart';

abstract class BannerLoadState {}

// class BannerLoadInitial extends BannerLoadState {}

class BannerLoadLoading extends BannerLoadState {}

class BannerLoadLoaded extends BannerLoadState {}

// class StoriesSuccess extends StoriesState {
//   StoriesSuccess();
// }

// class StoriesLoaded extends StoriesState {
//   final List<GetAllStoriesData> stories;
//   final int currentIndex;

//   StoriesLoaded(this.stories, this.currentIndex);
// }

// class StoriesProgressUpdated extends StoriesState {
//   final double progress;

//   StoriesProgressUpdated(this.progress);
// }

// class StoriesCompleted extends StoriesState {}

// class StoriesError extends StoriesState {
//   final String message;
//   StoriesError(this.message);
// }

// class StoriesEmpty extends StoriesState {}

class StoriesState extends Equatable {
  final List<GetAllStoriesData> stories;
  final int currentIndex;
  // final int bannerAdsLoadCount;
  final double progress;
  final String? errorMessage;
  final bool isLoading;
  final bool isCompleted;
  final bool isEmpty;

  const StoriesState({
    this.stories = const [],
    this.currentIndex = 0,
    // this.bannerAdsLoadCount = 0,
    this.progress = 0.0,
    this.errorMessage,
    this.isLoading = false,
    this.isCompleted = false,
    this.isEmpty = false,
  });

  // ✅ CopyWith method for immutability
  StoriesState copyWith({
    List<GetAllStoriesData>? stories,
    int? currentIndex,
    int? bannerAdsLoadCount,
    double? progress,
    String? errorMessage,
    bool? isLoading,
    bool? isCompleted,
    bool? isEmpty,
  }) {
    return StoriesState(
      stories: stories ?? this.stories,
      currentIndex: currentIndex ?? this.currentIndex,
      // bannerAdsLoadCount: bannerAdsLoadCount ?? this.bannerAdsLoadCount,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
      isEmpty: isEmpty ?? this.isEmpty,
    );
  }

  // ✅ Initial State
  factory StoriesState.initial() => const StoriesState();
  @override
  List<Object?> get props => [
        stories,
        currentIndex,
        progress,
        errorMessage,
        isLoading,
        isCompleted,
        // bannerAdsLoadCount,
        isEmpty
      ];
}
