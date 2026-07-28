import 'package:equatable/equatable.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

import '../models/send_otp.dart';

// abstract class SendOtpState {}

// class SendOtpInitial extends SendOtpState {}

// class SendOtpLoading extends SendOtpState {}

// class SendOtpSuccess extends SendOtpState {
//   SendOtpSuccess();
// }

// class SendOtpError extends SendOtpState {
//   final String message;
//   SendOtpError(this.message);
// }

// class SendOtpLoaded extends SendOtpState {
//   final SendOtpResponse sendOtpResponse;
//   SendOtpLoaded(this.sendOtpResponse);
// }

// class SendOtpEmpty extends SendOtpState {}

// class UpdatePhoneNumber extends SendOtpState {
//   final PhoneNumber phoneNumber;
//   UpdatePhoneNumber(this.phoneNumber);
// }

// class UpdateCountry extends SendOtpState {
//   final PhoneNumber phoneNumber;
//   UpdateCountry(this.phoneNumber);
// }

// class PhoneValid extends SendOtpState {
//   final bool isPhoneValid;
//   PhoneValid(this.isPhoneValid);
// }
// class EmailValid extends SendOtpState {
//   final bool isEmailValid;
//   EmailValid(this.isEmailValid);
// }

class SendOtpState extends Equatable {
  final LoadingState sendOtpLoadingState;
  final String? errorMessage;
  final SendOtpResponse? sendOtpResponse;
  final PhoneNumber? phoneNumber;
  final bool isPhoneValid;
  final bool isEmailValid;
  final bool agreedToTerms;

  const SendOtpState({
    this.sendOtpLoadingState = LoadingState.success,
    this.errorMessage,
    this.sendOtpResponse,
    this.phoneNumber,
    this.isPhoneValid = false,
    this.isEmailValid = false,
    this.agreedToTerms = false,
  });

  SendOtpState copyWith({
    LoadingState? sendOtpLoadingState,
    String? errorMessage,
    SendOtpResponse? sendOtpResponse,
    PhoneNumber? phoneNumber,
    bool? isUpdatePhoneNumber,
    bool? isPhoneValid,
    bool? isEmailValid,
    bool? agreedToTerms,
  }) {
    return SendOtpState(
      sendOtpLoadingState: sendOtpLoadingState ?? this.sendOtpLoadingState,
      errorMessage: errorMessage ?? this.errorMessage,
      sendOtpResponse: sendOtpResponse ?? this.sendOtpResponse,
      phoneNumber: phoneNumber ??
          ((isUpdatePhoneNumber ?? false) ? null : this.phoneNumber),
      isPhoneValid: isPhoneValid ?? this.isPhoneValid,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
    );
  }

  SendOtpState clear() {
    return SendOtpState();
  }

  factory SendOtpState.initial() {
    return const SendOtpState();
  }
  @override
  List<Object?> get props => [
        sendOtpLoadingState,
        errorMessage,
        sendOtpResponse,
        phoneNumber,
        isPhoneValid,
        isEmailValid,
        agreedToTerms,
      ];
}
