import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/stories_response.dart';
import '../services/api_client.dart';
import '../utils/utils.dart';
import 'stories_state.dart';

class StoriesCubit extends Cubit<StoriesState> {
  final ApiClient apiClient;
  AnimationController? animationController;
  PageController pageController = PageController();
  List<GetAllStoriesData> stories = [];
  int currentPage = 1;

  int currentIndex = 0;
  bool dragEnded = true;
  bool isLoadingMore = false;

  StoriesCubit(this.apiClient) : super(StoriesState.initial());

  Future<void> viewerStoriesUpdate(
    String storiesId,
    BuildContext context, {
    Function(ViewStoriesUpdateResponse)? callback,
  }) async {
    try {
      context.read<BannerLoadCubit>().emit(BannerLoadLoading());
      context.read<BannerLoadCubit>().emit(BannerLoadLoaded());

      ViewStoriesUpdateResponse response =
          await apiClient.viewerStoriesUpdate(storiesId, context);
      if (response.status == Utils.APISUCCESS) {
        callback?.call(response);
      }
    } catch (e) {
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""));
    }
  }

  void initializeAnimation(TickerProvider tickerProvider) {
    animationController = AnimationController(
      vsync: tickerProvider,
      duration: Duration(seconds: 2),
    );
    animationController?.addListener(_animationListener);
  }

  void _animationListener() {
    if (animationController?.value == 1) {
      moveForward();
    }
    emit(state.copyWith(progress: animationController!.value)
        // StoriesProgressUpdated(animationController!.value)
        );
  }

  void loadStories(List<GetAllStoriesData> storiesList, int index) {
    stories = storiesList ?? [];
    currentIndex = index ?? 0;
    pageController = PageController(initialPage: currentIndex);
    emit(state.copyWith(
      stories: stories,
      currentIndex: currentIndex,
      isCompleted: false,
    )
        // StoriesLoaded(stories, currentIndex)
        );
  }

  Future<void> fetchMoreStories(BuildContext context) async {
    if (isLoadingMore) return; // Prevent multiple API calls at the same time
    isLoadingMore = true;

    try {
      currentPage += 1;
      GetAllStoriesResponse response =
          await apiClient.getStoriesData(currentPage, 50, context);
      if (response.status == Utils.APISUCCESS) {
        final newStories = response.data ?? [];
        final updatedStories = List<GetAllStoriesData>.from(state.stories)
          ..addAll(newStories);
        emit(state.copyWith(
          stories: updatedStories,
        ));
      }
    } catch (e) {
      // Handle error
      showMessage('Error fetching more stories: $e');
    } finally {
      isLoadingMore = false;
    }
  }

  void onHorizontalDragUpdate(d) {
    if (!dragEnded) {
      dragEnded = true;
      if (d.delta.dx < -5) {
        moveForward();
      } else if (d.delta.dx > 5) {
        moveBackward();
      }
    }
  }

  void onHorizontalDragStart(d) {
    dragEnded = false;
  }

  void onHorizontalDragEnd(d) {
    dragEnded = true;
  }

  void moveForward() {
    showMessage("moveForward == $currentIndex ${stories.length - 1}");
    if (currentIndex < stories.length - 1) {
      currentIndex++;
      pageController.animateToPage(
        currentIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      emit(state.copyWith(currentIndex: currentIndex));
    } else {
      emit(state.copyWith(isCompleted: true));
    }
  }

  void resetStroryState() {
    emit(state.copyWith(
        isCompleted: false, progress: 0, currentIndex: 0, stories: []));
  }

  void moveBackward() {
    if (currentIndex > 0) {
      currentIndex--;
      pageController.animateToPage(
        currentIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      emit(state.copyWith(currentIndex: currentIndex));
    }
  }

  void dispose() {
    pageController.dispose();
    animationController?.dispose();
    resetStroryState();
  }
}

class BannerLoadCubit extends Cubit<BannerLoadState> {
  BannerLoadCubit() : super(BannerLoadLoaded());
}
