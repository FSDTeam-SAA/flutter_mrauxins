import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_client.dart';
import '../utils/utils.dart';
import 'new_group_state.dart';

class NewGroupCubit extends Cubit<NewGroupState> {
  final ApiClient apiClient;

  NewGroupCubit(this.apiClient) : super(NewGroupInitial());


}

class NewGroupUiCubit extends Cubit<NewGroupUiState> {
  final ImagePicker picker = ImagePicker();
  File? selectedFile;

  NewGroupUiCubit() : super(NewGroupUiState.initial());

  Future<void> pickImage(BuildContext context) async {
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        File file = File(image.path);
        selectedFile = file;
        emit(state.copyWith(file: file));
        // emit(ProfilePickSuccess(file)); // Set state after picking the image
      }
    } catch (e) {
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""));
    }
  }

  void clearSelectedFile() {
    selectedFile = null;
    emit(state.copyWith(file: null)); // Emit the initial or an empty state
  }

}