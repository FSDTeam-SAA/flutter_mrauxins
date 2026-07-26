import 'package:equatable/equatable.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

class CallState extends Equatable {
  final CallType? callType;
  final bool isSpeaker;
  final bool isInCall;

  const CallState({
    this.callType,
    this.isSpeaker = true,
    this.isInCall = false,
  });

  CallState copyWith({
    CallType? callType,
    bool? isSpeaker,
    bool? isInCall,
  }) {
    return CallState(
      callType: callType ?? this.callType,
      isSpeaker: isSpeaker ?? this.isSpeaker,
      isInCall: isInCall ?? this.isInCall,
    );
  }

  @override
  List<Object?> get props => [callType, isSpeaker, isInCall];
}
