import 'package:equatable/equatable.dart';
import 'package:two_one_two_messenger/models/chat_message_model.dart';

class TypingState extends Equatable {
  final List<TypingModel> currentTypingusers;

  const TypingState({this.currentTypingusers = const []});

  TypingState copyWith({List<TypingModel>? currentTypingusers}) {
    return TypingState(
      currentTypingusers: currentTypingusers ?? this.currentTypingusers,
    );
  }

  @override
  List<Object?> get props => [currentTypingusers];
}
