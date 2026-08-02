import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/screens/create_profile.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';
import '../cubit/otp_verify_state.dart';
import '../cubit/otp_verify_cubit.dart';
import '../cubit/send_otp_cubit.dart';
import '../database/local_db.dart';
import '../utils/navigation.dart';
import '../widgets/buttons.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/text_style.dart';
import '../utils/utils.dart';
import '../widgets/keyboard_safe_scaffold.dart';
import '../widgets/svg_images.dart';
import 'home_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String email;
  final String phoneNumber;
  final String countryISOCode;
  final String countryCode;
  final String verificationId;
  final bool isEditProfile;
  final bool isCreateProfile;
  final String? infoMessage;

  const OtpVerifyScreen(
      {super.key,
      this.email = '',
      this.phoneNumber = '',
      this.countryISOCode = '',
      this.countryCode = '',
      this.verificationId = '',
      this.isEditProfile = false,
      this.isCreateProfile = false,
      this.infoMessage});

  @override
  OtpVerifyFormState createState() => OtpVerifyFormState();
}

class OtpVerifyFormState extends State<OtpVerifyScreen> {
  final TextEditingController _pinController = TextEditingController();
  late final FocusNode focusNode = FocusNode();
  final _otpFormKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // late final SmsRetriever smsRetriever;
  final dbHelper = DatabaseHelper();
  // Object? argument;
  // String? email;
  // Map<String, dynamic>? map;

  @override
  void initState() {
    // WidgetsBinding.instance.addPostFrameCallback(
    //   (timeStamp) {
    //     argument = ModalRoute.of(context)?.settings.arguments;
    //     if (argument is String) {
    //       email = argument as String?;
    //     } else {
    //       map = argument as Map<String, dynamic>?;
    //     }
    //   },
    // );
    context.read<OtpVerifyCubit>().startTimer();
    super.initState();
  }

  @override
  void dispose() {
    _pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 65.w,
      height: 50.h,
      textStyle: TextStyle(
        fontSize: 22.sp,
        color: AppColors.white,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkInputFill,
        borderRadius: BorderRadius.circular(14),
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        if (widget.isEditProfile) {
          NavigationService().goBackReturn(null);
        } else {
          await sendOtpCubit.resetSendOtpState();
          await NavigationService().goBack();
        }
        context.dismissKeyboard();
      },
      child: KeyboardSafeScaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.dark,
            leading: IconButton(
              onPressed: () async {
                context.dismissKeyboard();
                if (widget.isEditProfile) {
                  NavigationService().goBackReturn(null);
                } else {
                  await NavigationService().goBack();
                }
              },
              icon: SvgImage(
                  source: SvgAssets.icArrowBack,
                  width: 20.w,
                  height: 20.h,
                  color: AppColors.white),
            ),
            title: Text(S.of(context).verificationOtp,
                style: AppTextStyles.medium(fontSize: 20.sp))),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
              left: 32.w, right: 32.w, bottom: Platform.isIOS ? 32.h : 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocBuilder<OtpVerifyCubit, OtpVerifyState>(
                  builder: (contextOtp, otpVerifyState) {
                return CustomButton(
                  onPressed: () async {
                    try {
                      if (_otpFormKey.currentState?.validate() ?? false) {
                        _otpFormKey.currentState?.save();

                        context.read<OtpVerifyCubit>().stopTimer();

                        String? fcmToken = await Utils.fetchToken();
                        PhoneAuthCredential? credential;
                        if (widget.verificationId.isNotEmpty) {
                          contextOtp
                              .read<OtpVerifyCubit>()
                              .emitOtpVerifyState();
                          credential =
                              await contextOtp.read<SendOtpCubit>().verifyOtp(
                                    widget.verificationId,
                                    _pinController.text,
                                    context,
                                  );
                          contextOtp
                              .read<OtpVerifyCubit>()
                              .emitOtpSuccessState();
                          log("otpverify====> $credential");
                          if (credential != null) {
                            if (widget.isEditProfile) {
                              context.dismissKeyboard();
                              NavigationService().goBackReturn(credential);
                              return;
                            }
                          } else {
                            _pinController.clear();
                            // Utils.showSnackBar(
                            //     context, AppConstants.pleaseTryAgainTxt);
                            return;
                          }
                        }
                        if (widget.isEditProfile && widget.email.isNotEmpty) {
                          await contextOtp
                              .read<OtpVerifyCubit>()
                              .verifyOtpForEmailChange(
                            widget.email,
                            _pinController.text,
                            context,
                            callback: () {
                              log("sdhkahskfhcjksdhfjkdjkshjk==== 7 ");
                              NavigationService().goBackReturn();
                              AppPreference.setEmailVerify();
                              if (!widget.isCreateProfile) {
                                if (widget.infoMessage != null) {
                                  Utils.showSnackBar(
                                      context,
                                      widget.infoMessage ??
                                          S.current.emailVerifiedSuccessfully);
                                } else {
                                  Utils.showSnackBar(context,
                                      S.current.emailChangeSuccessfully);
                                }
                              }
                            },
                          );
                        } else {
                          await contextOtp.read<OtpVerifyCubit>().otpVerify(
                            widget.email.isNotEmpty
                                ? widget.email
                                : widget.phoneNumber,
                            _pinController.text,
                            fcmToken ?? '',
                            widget.countryISOCode,
                            widget.countryCode,
                            context,
                            callback: () async {
                              if (credential != null) {
                                // context.read<PhoneInputCubit>().clearState();
                              }
                              await userDataCubit.loadUserData();
                              AppPreference.setEmailVerify();
                              showMessage(
                                  "create Profile == ${userDataCubit.state?.isProfileSetUp ?? false}");
                              if (userDataCubit.state?.isProfileSetUp ??
                                  false) {   await homeCubit.resetState();
                                NavigationService()
                                    .clearAndNavigateTo(HomeScreen());
                              } else {
                                NavigationService()
                                    .navigateTo(CreateProfileScreen());
                              }
                            },
                          );
                        }
                      }
                    } catch (e, st) {
                      log("error while verify otp ==> $e $st");
                    }
                  },
                  child: () {
                    if (otpVerifyState is OtpVerifyLoading) {
                      return const CustomLoadingWidget(
                        color: AppColors.white,
                      );
                    } else if (otpVerifyState is OtpVerifySuccess) {
                      return Text(
                        S.of(context).submitButtonText,
                        style: AppTextStyles.medium(
                          fontSize: 16.sp,
                          color: AppColors.white,
                        ),
                      );
                    } else if (otpVerifyState is OtpVerifyError) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _pinController.clear();
                      });
                      return Text(
                        S.of(context).loginButtonTextRe,
                        style: AppTextStyles.medium(
                          fontSize: 16.sp,
                          color: AppColors.white,
                        ),
                      );
                    } else {
                      return Text(
                        S.of(context).submitButtonText,
                        style: AppTextStyles.medium(
                          fontSize: 16.sp,
                          color: AppColors.white,
                        ),
                      );
                    }
                  }(),
                );
              }),
              SizedBox(
                height: 16.h,
              ),
            ],
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: SafeArea(
            child: Form(
              key: _otpFormKey,
              child: ListView(
                children: [
                  SizedBox(height: 16.h),

                  // SizedBox(height: 28.h),
                  Text(
                    S.of(context).lblOtpText,
                    style: AppTextStyles.bold(
                      fontSize: 26.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    S.of(context).lblOtpSubtitleText(widget.email.isNotEmpty
                        ? widget.email
                        : "${widget.countryCode}${widget.phoneNumber}"),
                    style: AppTextStyles.regular(
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Pinput(
                    // smsRetriever: smsRetriever,
                    controller: _pinController,
                    focusNode: focusNode,
                    defaultPinTheme: defaultPinTheme,
                    length: 6,
                    separatorBuilder: (index) => SizedBox(width: 8.w),
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 6) {
                        return S.of(context).otpError;
                      }
                      return null;
                    },
                    hapticFeedbackType: HapticFeedbackType.lightImpact,
                    onCompleted: (pin) {
                      debugPrint('onCompleted: $pin');
                    },
                    onChanged: (value) {
                      debugPrint('onChanged: $value');
                    },
                    cursor: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          color: AppColors.checkboxColor,
                          margin: const EdgeInsets.only(bottom: 9),
                          width: 22.w,
                          height: 1.h,
                          // color: focusedBorderColor,
                        ),
                      ],
                    ),
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration,
                    ),
                    submittedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        color: AppColors.darkInputFill,
                        borderRadius: BorderRadius.circular(14),
                        // border: Border.all(color: AppColors.white),
                      ),
                    ),
                    errorPinTheme: defaultPinTheme.copyBorderWith(
                      border: Border.all(color: Colors.redAccent),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  BlocBuilder<OtpVerifyCubit, OtpVerifyState>(
                    builder: (timerContext, state) {
                      if (state is OtpVerifyTimerState) {
                        return Center(
                          child: RichText(
                              text: TextSpan(
                                  text:
                                      '${S.of(context).otpNotReceivedText} : ',
                                  style: AppTextStyles.regular(
                                    fontSize: 14.sp,
                                  ),
                                  children: [
                                TextSpan(
                                  text:
                                      state.seconds.toString().padLeft(2, '0'),
                                  style: AppTextStyles.bold(
                                    fontSize: 14.sp,
                                  ),
                                )
                              ])),
                        );
                      } else if (state is OtpVerifyTimerRetry ||
                          state is OtpVerifyLoading ||
                          state is OtpVerifyLoaded ||
                          state is OtpVerifyError) {
                        return Center(
                          child: RichText(
                              text: TextSpan(
                                  text:
                                      '${S.of(context).otpNotReceivedText} : ',
                                  style: AppTextStyles.regular(
                                    fontSize: 14.sp,
                                  ),
                                  children: [
                                TextSpan(
                                    text: S.of(context).resendOtpText,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        if (widget.email.isNotEmpty) {
                                          context
                                              .read<SendOtpCubit>()
                                              .sendOtp(widget.email, context);
                                        } else {
                                          context.read<SendOtpCubit>().sendPhoneOtp(
                                              "${widget.countryCode}${widget.phoneNumber}",
                                              context);
                                        }
                                        context
                                            .read<OtpVerifyCubit>()
                                            .startTimer();
                                      })
                              ])),
                        );
                      } else {
                        return SizedBox(); // In case no timer state is active
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
