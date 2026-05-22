import '../models/otp_verify.dart';

abstract class OtpVerifyState {}

class OtpVerifyInitial extends OtpVerifyState {}

class OtpVerifyLoading extends OtpVerifyState {}

class OtpVerifySuccess extends OtpVerifyState {
  OtpVerifySuccess();
}

class OtpVerifyError extends OtpVerifyState {
  final String message;
  OtpVerifyError(this.message);
}

class OtpVerifyLoaded extends OtpVerifyState {
  final OtpVerifyResponse sendOtpResponse;
  OtpVerifyLoaded(this.sendOtpResponse);
}

class OtpVerifyEmpty extends OtpVerifyState {}

class OtpVerifyTimerRetry extends OtpVerifyState{}

class OtpVerifyTimerState extends OtpVerifyState {
  final int seconds;
  OtpVerifyTimerState(this.seconds);
}
