import '../models/stories_response.dart';
import 'create_stories_cubit.dart';

abstract class CreateStoriesState {}

class CreateStoriesInitial extends CreateStoriesState {}

class CreateStoriesLoading extends CreateStoriesState {}

class CreateStoriesSuccess extends CreateStoriesState {
  CreateStoriesSuccess();
}

class CreateStoriesLoaded extends CreateStoriesState {
  final CreateStoriesResponse createStoriesResponse;
  CreateStoriesLoaded(this.createStoriesResponse);
}

class DeleteStoriesLoaded extends CreateStoriesState {
  final DeleteStoriesResponse deleteStoriesResponse;
  DeleteStoriesLoaded(this.deleteStoriesResponse);
}

class CreateStoriesError extends CreateStoriesState {
  final String message;
  CreateStoriesError(this.message);
}

class CreateStoriesEmpty extends CreateStoriesState {}

class CreateStoriesSource extends CreateStoriesState {
  final ImageSourceOption imageSource;
  CreateStoriesSource(this.imageSource);
}

class CameraSource extends CreateStoriesState{
  final CameraSourceOption cameraSource;
  CameraSource(this.cameraSource);
}

class VideoPlayerInitialized extends CreateStoriesState {}
class VideoPlayerPaused extends CreateStoriesState {}
class VideoPlayerPlaying extends CreateStoriesState {}
class VideoPlayerCompleted extends CreateStoriesState {}