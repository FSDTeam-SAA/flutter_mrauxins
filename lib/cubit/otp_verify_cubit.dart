import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/models/update_profile.dart';
import 'package:two_one_two_messenger/screens/create_profile.dart';
import 'package:two_one_two_messenger/screens/home_screen.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';

import '../database/local_db.dart';
import '../models/otp_verify.dart';
import '../services/api_client.dart';
import '../utils/utils.dart';
import 'otp_verify_state.dart';

class OtpVerifyCubit extends Cubit<OtpVerifyState> {
  final ApiClient apiClient;
  final DatabaseHelper dbHelper;
  final int initialSeconds = 60;
  Timer? _timer;

  OtpVerifyCubit(this.apiClient, this.dbHelper) : super(OtpVerifyInitial());

  Future<void> otpVerify(String email, String otp, String fcmToken,
      String countryISOCode, String countryCode, BuildContext context,
      {Function()? callback}) async {
    emit(OtpVerifyLoading());
    try {
      showMessage("otpVerify==> $email $countryISOCode $countryCode");
      OtpVerifyResponse response = await apiClient.otpVerify(
          email, otp, fcmToken, countryISOCode, countryCode, context);

      if (response.status == Utils.APISUCCESS) {
        await dbHelper.saveToken(response.data?.token ?? '');
        await AppPreference.setUserRefreshToken(response.data?.refreshToken ?? '');
        await dbHelper.insertLoginData(response.data!.user!);
        if (countryCode.isEmpty) {
          AppPreference.setEmailVerify();
        } else {
          AppPreference.setPhoneVerify();
        }
        callback?.call();
      }

      emit(OtpVerifySuccess());
      emit(OtpVerifyLoaded(response));
    } catch (e) {
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""));
      emit(OtpVerifyError(e.toString()));
    }
  }

  Future<void> socialSignInVerify(
      {required String email,
      required SignInProvider provider,
      required String providerId,
      required String fcmToken,
      required BuildContext context,
      required String name,
      required String photoUrl,
      required String phone,
      Function()? callback}) async {
    // emit(OtpVerifyLoading());
    try {
      OtpVerifyResponse response = await apiClient.socialLoginVerify(
        text: email,
        provider: provider,
        providerId: providerId,
        fcmToken: fcmToken,
        context: context,
        name: name,
        phone: phone,
        photoUrl: photoUrl,
      );

      if (response.status == Utils.APISUCCESS) {
        await dbHelper.deleteLoginData();
        await dbHelper.saveToken(response.data?.token ?? '');
        await AppPreference.setUserRefreshToken(response.data?.refreshToken ?? '');
        await dbHelper.insertLoginData(response.data!.user!);
        await userDataCubit.loadUserData();

        final loginData = await dbHelper.getLoginData();
        showMessage("socialSignInVerify==> ${loginData?.toJson()}");
        if (loginData != null) {
          if (loginData.isProfileSetUp ?? false) {
            // if (loginData.isEmailVerify ?? false) {
            //   AppPreference.setEmailVerify();
            // }
            // AppPreference.setPhoneVerify();
            await homeCubit.resetState();

            await NavigationService().clearAndNavigateTo(HomeScreen());
          } else {
            NavigationService().navigateTo(CreateProfileScreen());
          }
          // if (loginData.isEmailVerify ?? false) {
          //   AppPreference.setEmailVerify();
          // }
        }
        callback?.call();
      }

      // emit(OtpVerifySuccess());
      // emit(OtpVerifyLoaded(response));
    } catch (e, st) {
      showMessage("Error in google sign in socialSignInVerify==> $e,$st");
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""));
      // emit(OtpVerifyError(e.toString()));
    }
  }

  void startTimer() {
    stopTimer(); // Stop any existing timer

    int remainingSeconds = initialSeconds;
    emit(OtpVerifyTimerState(remainingSeconds)); // Emit the initial timer state

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds <= 0) {
        timer.cancel();
        emit(OtpVerifyTimerRetry());
      } else {
        remainingSeconds--;
        emit(OtpVerifyTimerState(remainingSeconds)); // Update the timer state
      }
    });
  }

  void emitOtpVerifyState() {
    emit(OtpVerifyLoading());
  }

  void emitOtpSuccessState() {
    emit(OtpVerifySuccess());
  }

  Future<void> verifyOtpForEmailChange(
      String email, String otp, BuildContext context,
      {Function()? callback}) async {
    emit(OtpVerifyLoading());
    try {
      UpdateProfileResponse response =
          await apiClient.verifyOtpForEmailChange(email, otp, context);

      if (response.status == Utils.APISUCCESS) {
        await dbHelper.deleteLoginData();
        await dbHelper.insertLoginData(response.data!);
        await profileCubit.handleUpdateEmail(response);
        // callback?.call(response);
        AppPreference.setEmailVerify();
        log("sdhkahskfhcjksdhfjkdjkshjk==== 6 ${response.data?.isEmailVerify ?? false}");
        callback?.call();
      }

      emit(OtpVerifySuccess());
    } catch (e) {
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""));
      emit(OtpVerifyError(e.toString()));
    }
  }

  void stopTimer() {
    _timer?.cancel(); // Stop the timer
    emit(OtpVerifyTimerState(initialSeconds)); // Reset the timer state
  }

  @override
  Future<void> close() {
    _timer?.cancel(); // Cancel the timer when Cubit is disposed
    return super.close();
  }
}
