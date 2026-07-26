import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:two_one_two_messenger/models/chat_message_model.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

import 'typing_state.dart';

class TypingCubit extends Cubit<TypingState> {
  TypingCubit() : super(const TypingState());

  void updateTypingList(TypingModel newTypingModel) {
    // Create a new list from the current state to avoid modifying the original reference
    List<TypingModel> typingList =
        List<TypingModel>.from(state.currentTypingusers);

    // Remove elements with different chatId or those with isTyping = false
    typingList.removeWhere((element) =>
        element.chatId != newTypingModel.chatId || element.isTyping == false);

    if (newTypingModel.isTyping == true) {
      // Check if the sender already exists in the list
      int index = typingList
          .indexWhere((element) => element.sender == newTypingModel.sender);

      if (index != -1) {
        // Update the existing typing model
        typingList[index] = newTypingModel;
      } else {
        // Add a new typing model
        typingList.add(newTypingModel);
      }
    } else {
      // Remove the typing model if isTyping is false
      typingList.removeWhere(
          (element) => element.sender?.id == newTypingModel.sender?.id);
    }

    showMessage("updateTypingList==1111>${typingList.length}");

    // Emit a new state only if there's an actual change
    if (!listEquals(state.currentTypingusers, typingList)) {
      emit(state.copyWith(
          currentTypingusers: List<TypingModel>.from(typingList)));
    }
  }

  void clearTypingList() {
    emit(state.copyWith(currentTypingusers: []));
  }
}
