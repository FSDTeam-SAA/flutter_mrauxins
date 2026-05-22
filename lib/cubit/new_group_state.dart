import 'dart:io';

import '../models/update_profile.dart';

abstract class NewGroupState {}

class NewGroupInitial extends NewGroupState {}

class NewGroupLoading extends NewGroupState {}

class NewGroupSuccess extends NewGroupState {
  NewGroupSuccess();
}

class NewGroupError extends NewGroupState {
  final String message;
  NewGroupError(this.message);
}

class NewGroupLoaded extends NewGroupState {
  final UpdateProfileResponse updateProfileResponse;
  NewGroupLoaded(this.updateProfileResponse);
}

class NewGroupEmpty extends NewGroupState {}

class NewGroupUiState {
  final File? file;

  NewGroupUiState({required this.file});

  factory NewGroupUiState.initial() {
    return NewGroupUiState(
      file: null,
    );
  }

  NewGroupUiState copyWith({
    File? file,
  }) {
    return NewGroupUiState(file: file ?? this.file);
  }
}
