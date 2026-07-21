import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl_phone_field/countries.dart';

import 'package:intl_phone_field/phone_number.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/delete_device_token.dart';
import 'package:two_one_two_messenger/services/socket_service.dart';
import '../database/local_db.dart';
import '../models/send_otp.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../utils/navigation.dart';
import '../utils/utils.dart';
import '../services/api_client.dart';
import 'send_otp_state.dart';

class SendOtpCubit extends Cubit<SendOtpState> {
  final ApiClient apiClient;
  final DatabaseHelper dbHelper;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // bool _isPhoneValid = false;
  // bool _isEmailValid = false;

  SendOtpCubit(this.apiClient, this.dbHelper) : super(SendOtpState.initial());

  final SocketService _socketService = SocketService();
  void setPhoneValid(bool isValid) {
    // _isPhoneValid = isValid;
    emit(state.copyWith(
        isPhoneValid: isValid)); // Emit a new state to notify listeners
  }

  Future<void> resetSendOtpState() async {
    emit(state.clear());
    await Future.delayed(Durations.long1);
  }

  void setEmailValid(bool isValid) {
    // _isEmailValid = isValid;
    emit(state.copyWith(
        isEmailValid: isValid)); // Emit a new state to notify listeners
  }

  void setSuceessState() {
    // _isEmailValid = isValid;
    emit(state.copyWith(
        sendOtpLoadingState:
            LoadingState.success)); // Emit a new state to notify listeners
  }

  void onAgreedToTerms(bool value) {
    // _isEmailValid = isValid;
    emit(state.copyWith(
        agreedToTerms: value)); // Emit a new state to notify listeners
  }

  Future<void> sendOtp(String email, BuildContext context,
      {Function()? callback}) async {
    emit(state.copyWith(sendOtpLoadingState: LoadingState.loading));
    try {
      SendOtpResponse response = await apiClient.sendOtp(email, context);
      if (response.status == Utils.APISUCCESS) {
        callback?.call();
      }

      emit(state.copyWith(
          sendOtpLoadingState: LoadingState.success,
          sendOtpResponse: response));
    } catch (e, st) {
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""));
      showMessage("Error ==>$e $st");
      emit(state.copyWith(
          sendOtpLoadingState: LoadingState.error, errorMessage: e.toString()));
    }
  }

  Future<void> sendPhoneOtp(
    String phoneNumber,
    BuildContext context, {
    Function(String verificationId)? callback,
    Future<void> Function(PhoneAuthCredential credential)?
        verificationCompletedCallback,
  }) async {
    emit(state.copyWith(sendOtpLoadingState: LoadingState.loading));
    profileCubit.emitSendOtpLoadingState(isLoadEmail: false, isLoadPhone: true);
    try {
      // context.showLoader();
      // await apiClient.checkForMobile(mobile, countryCode, context)
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // await _auth.signInWithCredential(credential);
          showMessage("verificationCompleted=== ${credential.smsCode}");
          Utils.hideLoader();
          profileCubit.emitProfileSucessState();
          profileCubit.emitSendOtpSucessState();
          emit(state.copyWith(sendOtpLoadingState: LoadingState.success));
          await verificationCompletedCallback?.call(credential);
          // callback?.call('');
          // emit(SendOtpEmpty());
        },
        verificationFailed: (FirebaseAuthException e) {
          showMessage("Error FirebaseAuthException==>$e");
          Utils.hideLoader();
          Utils.showSnackBar(context, _getFirebaseErrorMessage(e.code),
              seconds: 3);
          profileCubit.emitSendOtpSucessState();
          emit(state.copyWith(
              sendOtpLoadingState: LoadingState.error,
              errorMessage: e.toString()));
        },
        codeSent: (String verificationId, int? resendToken) {
          Utils.hideLoader();
          showMessage("FirebaseAuthException>>> codeSent=== $verificationId");
          callback?.call(verificationId);
          profileCubit.emitProfileSucessState();
          profileCubit.emitSendOtpSucessState();
          // emit(SendOtpEmpty());
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          Utils.hideLoader();
          profileCubit.emitProfileSucessState();
          profileCubit.emitSendOtpSucessState();
        },
      );
    } on FirebaseAuthException catch (ex) {
      showMessage("Error FirebaseAuthException==>$ex");
      Utils.hideLoader();
      profileCubit.emitProfileSucessState();
      profileCubit.emitSendOtpSucessState();
      emit(state.copyWith(
        sendOtpLoadingState: LoadingState.error,
      ));
    } catch (e, st) {
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""));
      showMessage("Error ==>$e $st");
      Utils.hideLoader();
      profileCubit.emitSendOtpSucessState();
      profileCubit.emitProfileSucessState();
      emit(state.copyWith(
          sendOtpLoadingState: LoadingState.error, errorMessage: e.toString()));
    } finally {
      // context.hideLoader();
    }
  }

  // Future<void> verifyPhoneOtp(String phoneNumber, String verificationId,
  //     String otp, BuildContext context,
  //     {Function(String verificationId)? callback}) async {
  //   emit(state.copyWith(sendOtpLoadingState: LoadingState.loading));
  //   try {
  //     PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //       verificationId: verificationId,
  //       smsCode: otp,
  //     );

  //     UserCredential userCredential =
  //         await FirebaseAuth.instance.signInWithCredential(credential);

  //     if (userCredential.user != null) {
  //       // Navigate to Home or Dashboard
  //       NavigationService().navigateTo(HomeScreen());
  //     }

  //     // await _auth.verifyPhoneNumber(
  //     //   phoneNumber: phoneNumber,
  //     //   verificationCompleted: (PhoneAuthCredential credential) async {
  //     //     await _auth.signInWithCredential(credential);

  //     //     emit(state.copyWith(sendOtpLoadingState: LoadingState.success));
  //     //     callback?.call('');
  //     //     // emit(SendOtpEmpty());
  //     //   },
  //     //   verificationFailed: (FirebaseAuthException e) {
  //     //     showMessage("Error FirebaseAuthException==>$e");

  //     //     Utils.showSnackBar(context, _getFirebaseErrorMessage(e.code),
  //     //         seconds: 3);
  //     //     emit(state.copyWith(
  //     //         sendOtpLoadingState: LoadingState.error,
  //     //         errorMessage: e.toString()));
  //     //   },
  //     //   codeSent: (String verificationId, int? resendToken) {
  //     //     callback?.call(verificationId);
  //     //     emit(state.copyWith(sendOtpLoadingState: LoadingState.success));
  //     //     // emit(SendOtpEmpty());
  //     //   },
  //     //   codeAutoRetrievalTimeout: (String verificationId) {},
  //     // );
  //   } on FirebaseAuthException catch (ex) {
  //     showMessage("Error FirebaseAuthException==>$ex");
  //   } catch (e) {
  //     Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""));
  //     showMessage("Error ==>$e");
  //     emit(state.copyWith(
  //         sendOtpLoadingState: LoadingState.error, errorMessage: e.toString()));
  //   }
  // }

  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-verification-code': // Older versions
      case 'invalid-verification-id': // Newer versions
      case 'session-expired':
        return S.current.wrongOtp;
      case "invalid-phone-number":
        return S.current.invalid_phone_number;
      case "too-many-requests":
        return S.current.too_many_requests;
      case "quota-exceeded":
        return S.current.quota_exceeded;
      case "network-request-failed":
        return S.current.network_request_failed;
      default:
        return S.current.somethingWentWrongPleaseTryAgain;
    }
  }

  Future<PhoneAuthCredential?> verifyOtp(
      String verificationId, String smsCode, BuildContext context) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (credential.verificationId != null) {
        return credential;
      } else {
        return null;
      }
      // await _auth.signInWithCredential(credential);
    } on FirebaseException catch (e) {
      Utils.showSnackBar(context, _getFirebaseErrorMessage(e.code), seconds: 3);
      return null;
    } catch (e) {
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""));
      return null;
    }
  }

  ///TODO NOTE: SignIn With google and facebook
  // Future<OAuthCredential?> signInWithGoogle(BuildContext context,
  //     {Function(OAuthCredential credential)? callback}) async {
  //   emit(state.copyWith(sendOtpLoadingState: LoadingState.loading));
  //   try {
  //     await signOut();
  //     final credential = await googleSignIn(context);
  //     if (credential != null) {
  //       emit(state.copyWith(sendOtpLoadingState: LoadingState.success));
  //       // emit(SendOtpEmpty());
  //       return credential;
  //     } else {
  //       emit(state.copyWith(
  //         sendOtpLoadingState: LoadingState.error,
  //       ));
  //       return null;
  //     }
  //   } catch (e, st) {
  //     Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""));
  //     showMessage("Error in google sign in ==> $e,$st");
  //     emit(state.copyWith(
  //         sendOtpLoadingState: LoadingState.error, errorMessage: e.toString()));
  //     return null;
  //   }
  // }

  Future<void> signOut() async {
    ///TODO NOTE: SignIn With google and facebook
    // await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  ///TODO NOTE: SignIn With google and facebook
  // Future<OAuthCredential?> googleSignIn(BuildContext context) async {
  //   try {
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     if (googleUser == null) {
  //       emit(state.copyWith(
  //           sendOtpLoadingState: LoadingState.error,
  //           errorMessage: 'Google Sign In Failed'));

  //       return null; // Sign-in aborted
  //     }
  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //     if (credential.accessToken != null) {
  //       return credential;
  //     } else {
  //       Utils.showSnackBar(context, S.current.pleaseTryAgainTxt);
  //       return null;
  //     }
  //   } catch (e, st) {
  //     Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""));
  //     showMessage("Error in google sign in 0==> $e,$st");
  //     emit(state.copyWith(
  //         sendOtpLoadingState: LoadingState.error, errorMessage: e.toString()));
  //     return null;
  //   }
  // }
  ///TODO NOTE: SignIn With google and facebook
  // Future<OAuthCredential?> signInWithFacebook(BuildContext context,
  //     {Function(OAuthCredential credential)? callback}) async {
  //   emit(state.copyWith(sendOtpLoadingState: LoadingState.loading));
  //   try {
  //     final LoginResult result = await FacebookAuth.instance.login();

  //     if (result.status == LoginStatus.success) {
  //       final OAuthCredential credential =
  //           FacebookAuthProvider.credential(result.accessToken!.tokenString);
  //       emit(state.copyWith(sendOtpLoadingState: LoadingState.success));
  //       // emit(SendOtpEmpty());
  //       return credential;
  //     } else {
  //       emit(state.copyWith(
  //           sendOtpLoadingState: LoadingState.error,
  //           errorMessage: "Facebook login failed: ${result.message}"));
  //       return null;
  //     }
  //   } catch (e) {
  //     showMessage("e.toString() --> ${e.toString()}");
  //     Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""));
  //     emit(state.copyWith(
  //         sendOtpLoadingState: LoadingState.error, errorMessage: e.toString()));
  //     return null;
  //   }
  // }

  Future<void> getLoginDataAndNavigation() async {
    try {
      if (AppPreference.getBoolean('first_run') ?? true) {
        FlutterSecureStorage storage = FlutterSecureStorage();

        await storage.deleteAll();

        AppPreference.setBoolean('first_run', value: false);
      }

      final loginData = await dbHelper.getLoginData();
      showMessage("login data == $loginData");
      if (loginData != null) {
        if (loginData.isProfileSetUp ?? false) {
          await homeCubit.resetState();
          await NavigationService().clearAndNavigateTo(HomeScreen());
        } else {
          await sendOtpCubit.resetSendOtpState();
          NavigationService().clearAndNavigateTo(LoginScreen());

          // NavigationService().navigateTo(CreateProfileScreen());
        }
      } else {
        await sendOtpCubit.resetSendOtpState();
        await NavigationService().clearAndNavigateTo(LoginScreen());
      }
    } catch (e) {
      showMessage("Error :: ${e.toString()}");
    }
  }

  void updatePhoneNumber(PhoneNumber? phoneNumber) {
    emit(state.copyWith(phoneNumber: phoneNumber, isUpdatePhoneNumber: true));
  }

  void clearState() {
    emit(state.clear());
  }

  void updateCountry(Country country, PhoneNumber? phoneNumber) {
    if (phoneNumber != null) {
      emit(state.copyWith(phoneNumber: phoneNumber));
      // emit(UpdateCountry(PhoneNumber(
      //     countryISOCode: country.code,
      //     number: phoneNumber.number,
      //     countryCode: country.dialCode)));
    }
  }

  Future<void> deleteToken(String userId, String token, BuildContext context,
      {Function(DeleteTokenResponse)? callback}) async {
    try {
      if (userId.isEmpty || token.isEmpty) {
        // Nothing meaningful to delete server-side, but the local logout
        // (callback) must still proceed — the user tapping Logout should
        // never get stuck just because there's no token to clean up.
        callback?.call(DeleteTokenResponse(
            status: Utils.APISUCCESS, message: "No device token to delete"));
        return;
      }

      Utils.showLoader();
      DeleteTokenResponse response =
          await apiClient.deleteToken(userId, token, context);
      if (response.status == Utils.APISUCCESS) {
        callback?.call(response);
      }
    } catch (e) {
      // Local logout must not be held hostage by this network call — if the
      // device is offline, the user still needs to be able to log out.
      // The stale token is left registered server-side, but it's a
      // self-healing gap: sentPushNotificationToUser prunes it the next
      // time a send to it fails (FCM will report it invalid/unregistered).
      Utils.showSnackBar(context, e.toString().replaceAll("Exception: ", ""),
          seconds: 3);
      callback?.call(DeleteTokenResponse(
          status: Utils.APISUCCESS,
          message: "Logged out locally; device token deletion will be retried server-side"));
    } finally {
      Utils.hideLoader();
    }
  }
}

class PhoneInputCubit extends Cubit<PhoneNumber?> {
  PhoneInputCubit() : super(null);

  void updatePhoneNumber(PhoneNumber phoneNumber) {
    emit(phoneNumber);
  }

  void clearState() {
    emit(null);
  }

  void updateCountry(Country country) {
    if (state != null) {
      emit(PhoneNumber(
          countryISOCode: country.code,
          number: state!.number,
          countryCode: country.dialCode));
    }
  }
}
