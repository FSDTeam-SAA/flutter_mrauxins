import 'dart:developer';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:two_one_two_messenger/models/stories_response.dart';
import 'package:two_one_two_messenger/services/api_config.dart';
import 'package:video_player/video_player.dart';

import '../services/api_client.dart';
import '../utils/utils.dart';
import 'view_stories_state.dart';

// class ViewStoriesCubit extends Cubit<ViewStoriesState> {
//   ApiClient apiClient;
//   CurrentUserStoriesResponse? currentUserStoriesResponse;
//   List<CurrentUserStoriesData> currentUserStoriesList = [];
//   VideoPlayerController? videoPlayerController;
//   File? videoThumbnail;
//   FlickManager? flickManager;
//   ChewieController? chewieController;
//   int currentIndex = 0;

//   ViewStoriesCubit(this.apiClient) : super(ViewStoriesInitial());

//   Future<void> getLoggedInUserStories(BuildContext context,
//       {Function()? callback}) async {
//     emit(ViewStoriesLoading());
//     try {
//       CurrentUserStoriesResponse response =
//           await apiClient.getLoggedInUserStories(context);
//       if (response.status == Utils.APISUCCESS) {
//         callback?.call();
//         currentUserStoriesResponse = response;
//         currentUserStoriesList = response.data!;
//         // log("getLoggedInUserStories ${jsonEncode(response.toJson())}");
//       }
//       emit(ViewStoriesSuccess());
//       emit(ViewStoriesLoaded(response, response.data!));
//     } catch (e) {
//       Utils.showSnackBar(
//         context,
//         e.toString().replaceAll("Exception: ", ""),
//       );
//       emit(ViewStoriesError(e.toString()));
//     }
//   }

//   Future<void> deleteStories(String storiesId, BuildContext context,
//       {Function()? callback}) async {
//     emit(ViewStoriesLoading());
//     try {
//       DeleteStoriesResponse response =
//           await apiClient.deleteStories(storiesId, context);
//       if (response.status == Utils.APISUCCESS) {
//         callback?.call();
//         currentUserStoriesList.removeWhere(
//           (element) => element.sId == storiesId,
//         );
//         emit(ViewStoriesSuccess());
//       } else {
//         emit(ViewStoriesSuccess());
//         emit(DeleteStoriesLoaded(response));
//       }
//     } catch (e) {
//       Utils.showSnackBar(
//         context,
//         e.toString().replaceAll("Exception: ", ""),
//       );
//       emit(ViewStoriesError(e.toString()));
//     }
//   }

//   Future<void> getVideoThumbnail(String url) async {
//     XFile thumbnailFile = await VideoThumbnail.thumbnailFile(
//       video: url,
//       thumbnailPath: (await getDownloadsDirectory())?.path,
//       imageFormat: ImageFormat.JPEG,
//       quality: 100,
//     );
//     showMessage("videothumbnailpath==> ${thumbnailFile.path}");
//     videoThumbnail = File(thumbnailFile.path);
//   }

//   void updateIndex(int index) {
//     currentIndex = index;
//   }

//   Future<void> initializeVideoPlayer(String videoPath) async {
//     String url = '${Urls.mediaUrl}$videoPath';
//     showMessage("Video Url ==> $url");
//     // await getVideoThumbnail(url);
//     // videoController = VideoPlayerController.networkUrl(Uri.parse(url))
//     //   ..initialize()
//     //       .then((_) {
//     //     videoController?.addListener(videoPlayerListener);
//     //     emit(VideoPlayerInitialized());
//     //   }).catchError((error) {
//     //     // Handle any errors during initialization
//     //     showMessage("Error initializing video: $error");
//     //     emit(ViewStoriesError("Error initializing video player"));
//     //   });

//     // flickManager = FlickManager(
//     //     videoPlayerController:
//     //     VideoPlayerController.networkUrl(Uri.parse(url)),
//     // );
//     // await flickManager!.flickVideoManager!.videoPlayerController!.initialize();

//     videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));

//     await videoPlayerController?.initialize().then((value) {
//       videoPlayerController?.addListener(videoPlayerListener);
//     }, onError: (o, s) {
//       showMessage("onERRR :: ${o.toString()}");
//       showMessage("onERRR :: ${s.toString()}");
//     });

//     chewieController = ChewieController(
//       videoPlayerController: videoPlayerController!,
//       autoPlay: false,
//       looping: false,
//       allowFullScreen: true,
//     );
//   }

//   // Listener to detect when the video completes
//   void videoPlayerListener() {
//     if (videoPlayerController != null) {
//       if (videoPlayerController!.value.position ==
//           videoPlayerController!.value.duration) {
//         emit(VideoPlayerCompleted());
//       }
//     }
//   }

//   void togglePlayPause() {
//     if (videoPlayerController != null) {
//       if (videoPlayerController!.value.isPlaying) {
//         videoPlayerController!.pause();
//         emit(VideoPlayerPaused());
//       } else {
//         videoPlayerController!.play();
//         emit(VideoPlayerPlaying());
//       }
//     }
//   }

//   // Method to dispose video controller
//   void disposeVideoPlayer() {
//     videoPlayerController?.removeListener(videoPlayerListener);
//     videoPlayerController?.dispose();
//     chewieController?.dispose();
//     // flickManager?.dispose();
//   }
// }

class ViewStoriesCubit extends Cubit<ViewStoriesState> {
  final ApiClient apiClient;
  VideoPlayerController? videoPlayerController;
  File? videoThumbnail;
  ChewieController? chewieController;
  int currentIndex = 0;

  ViewStoriesCubit(this.apiClient) : super(ViewStoriesState());

  Future<void> getLoggedInUserStories(BuildContext context,
      {Function()? callback}) async {
    emit(state.copyWith(loadingState: LoadingState.loading));
    try {
      CurrentUserStoriesResponse response =
          await apiClient.getLoggedInUserStories(context);
      if (response.status == Utils.APISUCCESS) {
        callback?.call();
        emit(state.copyWith(
          loadingState: LoadingState.success,
          currentUserStoriesResponse: response,
          currentUserStoriesList: response.data!,
        ));
      }
    } catch (e) {
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""));
      emit(state.copyWith(
          loadingState: LoadingState.error, errorMessage: e.toString()));
    }
  }

  Future<void> deleteStories(String storiesId, BuildContext context,
      {Function()? callback}) async {
    emit(state.copyWith(loadingState: LoadingState.loading));
    try {
      DeleteStoriesResponse response =
          await apiClient.deleteStories(storiesId, context);
      if (response.status == Utils.APISUCCESS) {
        List<CurrentUserStoriesData> currentUserStoriesList =
            List.from(state.currentUserStoriesList);
        int deletedIndex = state.currentUserStoriesList
            .indexWhere((story) => story.sId == storiesId);
        // Remove from list
        currentUserStoriesList.removeWhere((story) => story.sId == storiesId);

        // Ensure index does not reset, move to the next story
        if (deletedIndex < currentUserStoriesList.length) {
          currentIndex = deletedIndex; // Move to next story
        } else {
          currentIndex = currentUserStoriesList.isEmpty
              ? 0
              : currentUserStoriesList.length - 1;
        }
        log("current index == $currentIndex");
        callback?.call();

        emit(state.copyWith(
          loadingState: LoadingState.success,
          currentUserStoriesList: currentUserStoriesList,
        ));
      } else {
        emit(state.copyWith(
            loadingState: LoadingState.success,
            deleteStoriesResponse: response));
      }
    } catch (e) {
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""));
      emit(state.copyWith(
          loadingState: LoadingState.error, errorMessage: e.toString()));
    }
  }

  Future<void> getVideoThumbnail(String url) async {
    XFile thumbnailFile = await VideoThumbnail.thumbnailFile(
      video: url,
      thumbnailPath: (await getDownloadsDirectory())?.path,
      imageFormat: ImageFormat.JPEG,
      quality: 100,
    );
    videoThumbnail = File(thumbnailFile.path);
  }

  void updateIndex(int index) {
    currentIndex = index;
  }

  Future<void> initializeVideoPlayer(String videoPath) async {
    String url = '${Urls.mediaUrl}$videoPath';
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
    await videoPlayerController?.initialize().then((_) {
      videoPlayerController?.addListener(videoPlayerListener);
      emit(state.copyWith(isVideoInitialized: true));
    }).catchError((error) {
      emit(state.copyWith(
          loadingState: LoadingState.error,
          errorMessage: "Error initializing video player"));
    });

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController!,
      autoPlay: false,
      looping: false,
      allowFullScreen: true,
    );
  }

  void videoPlayerListener() {
    if (videoPlayerController != null) {
      if (videoPlayerController!.value.position ==
          videoPlayerController!.value.duration) {
        emit(state.copyWith(isVideoCompleted: true));
      }
    }
  }

  void togglePlayPause() {
    if (videoPlayerController != null) {
      if (videoPlayerController!.value.isPlaying) {
        videoPlayerController!.pause();
        emit(state.copyWith(isVideoPlaying: false));
      } else {
        videoPlayerController!.play();
        emit(state.copyWith(isVideoPlaying: true));
      }
    }
  }

  void disposeVideoPlayer() {
    videoPlayerController?.removeListener(videoPlayerListener);
    videoPlayerController?.dispose();
    chewieController?.dispose();
  }
}
