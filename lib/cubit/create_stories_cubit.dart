import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:two_one_two_messenger/cubit/view_stories_cubit.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/main.dart';
import 'package:two_one_two_messenger/utils/loader_overlay.dart';
import 'package:video_player/video_player.dart';

import '../models/stories_response.dart';
import '../screens/upload_stories_screen.dart';
import '../services/api_client.dart';
import '../utils/navigation.dart';
import '../utils/utils.dart';
import 'create_stories_state.dart';

enum ImageSourceOption { none, camera, gallery }

enum CameraSourceOption { none, image, video }

class CreateStoriesCubit extends Cubit<CreateStoriesState> {
  final ApiClient apiClient;
  final ImagePicker _picker = ImagePicker();
  ImageSourceOption source = ImageSourceOption.none;
  VideoPlayerController? videoController;
  File? selectedFile;
  File? videoThumbnail;
  int videoDuration = 5;
  MimeType? mimeType;

  CreateStoriesCubit(this.apiClient) : super(CreateStoriesInitial());

  Future<void> createStories(File? file, String caption, BuildContext context,
      {Function(CreateStoriesResponse)? callback,
      required MimeType? mimeType}) async {
    final viewStoriesCubit = context.read<ViewStoriesCubit>();
    final globalContext = navigatorKey.currentContext;
    final apiContext = globalContext ?? context;

    emit(CreateStoriesLoading());
    try {
      Loader.show();
      CreateStoriesResponse response = await apiClient.createStories(
          file, caption, videoDuration, apiContext, mimeType);
      if (response.status == Utils.APISUCCESS) {
        callback?.call(response);
        if (globalContext != null) {
          await viewStoriesCubit.getLoggedInUserStories(globalContext);
        }
      }
      emit(CreateStoriesSuccess());
      emit(CreateStoriesLoaded(response));
    } catch (e) {
      if (globalContext != null) {
        Utils.showSnackBar(
          globalContext,
          e.toString().replaceAll("Exception: ", ""),
        );
      }
      emit(CreateStoriesError(e.toString()));
    } finally {
      Loader.hide();
    }
  }

  void selectCamera() {
    source = ImageSourceOption.camera;
    emit(CreateStoriesSource(source));
  }

  void selectGallery() {
    source = ImageSourceOption.gallery;
    emit(CreateStoriesSource(source));
  }

  void resetSource() {
    source = ImageSourceOption.none;
  }

  Future<void> pickImageFromCamera(
      CameraSourceOption cameraSource, ImageSource imageSource) async {
    XFile? file;
    if (cameraSource == CameraSourceOption.image) {
      final pickedImage = await _picker.pickImage(source: imageSource);
      if (pickedImage != null) {
        file = pickedImage;
        videoDuration = 5;
        selectedFile = File(file.path);
        mimeType = Utils.getMimeType(file.path);
        NavigationService().goBackTo(1);
        NavigationService().navigateTo(UploadStoriesScreen());
      }
    } else if (cameraSource == CameraSourceOption.video) {
      final pickedVideo = await _picker.pickVideo(source: imageSource);
      if (pickedVideo != null) {
        file = pickedVideo;
        await getVideoThumbnail(File(file.path));
        videoDuration = await getVideoDuration(File(file.path)) ?? 10;
        showMessage("videoDuration12==> $videoDuration");
        if (videoDuration > 30) {
          NavigationService().goBackTo(1);
          Utils.showSnackBar(navigatorKey.currentContext!,
              S.current.videoDurationIsMorethen30Sec);
          return;
        } else {
          selectedFile = File(file.path);
          mimeType = Utils.getMimeType(file.path);

          NavigationService().navigateTo(UploadStoriesScreen());
        }
      } else {
        return;
      }
    }
  }

  Future<int?> getVideoDuration(File file) async {
    final controller = VideoPlayerController.file(file);
    await controller.initialize();
    Duration duration = controller.value.duration;
    controller.dispose(); // Dispose to free resources
    return duration.inSeconds;
  }

  Future<void> pickImageFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'jpeg',
          'png',
          'webp',
          'mp4',
          'mkv',
          'mov',
          'avi',
          'flv',
          'wmv',
        ],
        allowMultiple: false,
        allowCompression: true);

    if (result != null) {
      File file = File(result.files.single.path!);
      selectedFile = file;
      mimeType = Utils.getMimeType(file.path);
      if (mimeType == MimeType.video) {
        await getVideoThumbnail(file);
        videoDuration = await getVideoDuration(selectedFile!) ?? 10;
        showMessage("videoDuration1==> $videoDuration");
        if (videoDuration > 30) {
          showMessage("videoDuration==> $videoDuration");
          NavigationService().goBackTo(1);
          Utils.showSnackBar(navigatorKey.currentContext!,
              S.current.videoDurationIsMorethen30Sec);
          return;
        }
      }
      NavigationService().goBack();
      NavigationService().navigateTo(UploadStoriesScreen());
    } else {
      // User canceled the picker
    }

    // final result = await _picker.pickMedia(
    //     // source: ImageSource.me,

    //     );

    // if (result != null) {
    //   File file = File(result.path);
    //   selectedFile = file;
    //   mimeType = Utils.getMimeType(file.path);
    //   showMessage("videoDuration==>getMimeType $mimeType");
    //   if (mimeType == MimeType.video) {
    //     await getVideoThumbnail(file);
    //     videoDuration = await getVideoDuration(selectedFile!) ?? 10;
    //     if (videoDuration > 30) {
    //       showMessage("videoDuration==> $videoDuration");
    //       NavigationService().goBackTo(1);
    //       Utils.showSnackBar(navigatorKey.currentContext!,
    //           S.current.videoDurationIsMorethen30Sec);
    //       return;
    //     }
    //   } else {
    //     videoDuration = 5;
    //   }

    //   NavigationService().goBack();
    //   NavigationService().navigateTo(UploadStoriesScreen());
    // } else {
    //   // User canceled the picker
    // }
  }

  Future<void> getVideoThumbnail(File file) async {
    final directory = await getApplicationDocumentsDirectory(); // Change here

    XFile thumbnailFile = await VideoThumbnail.thumbnailFile(
      video: file.path,
      thumbnailPath: directory.path,
      imageFormat: ImageFormat.JPEG,
      quality: 100,
    );
    videoThumbnail = File(thumbnailFile.path);
  }

  void initializeVideoPlayer(File videoFile) {
    videoController = VideoPlayerController.file(videoFile)
      ..initialize().then((_) {
        videoController?.addListener(videoPlayerListener);
        emit(VideoPlayerInitialized());
      });
  }

  // Listener to detect when the video completes
  void videoPlayerListener() {
    if (videoController != null) {
      if (videoController!.value.position == videoController!.value.duration) {
        emit(VideoPlayerCompleted());
      }
    }
  }

  void togglePlayPause() {
    if (videoController != null) {
      if (videoController!.value.isPlaying) {
        videoController!.pause();
        emit(VideoPlayerPaused());
      } else {
        videoController!.play();
        emit(VideoPlayerPlaying());
      }
    }
  }

  // Method to dispose video controller
  void disposeVideoPlayer() {
    videoController?.removeListener(videoPlayerListener);
    videoController?.dispose();
  }

  void setImageFile(File file) {
    selectedFile = file;
  }
}
