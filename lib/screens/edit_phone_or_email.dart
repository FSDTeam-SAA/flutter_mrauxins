import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:intl_phone_field/phone_number.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/utils/extensions.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';
import 'package:two_one_two_messenger/widgets/intl_widget.dart';

import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../cubit/send_otp_cubit.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/navigation.dart';
import '../utils/text_style.dart';
import '../utils/utils.dart';
import '../widgets/appbar.dart';
import '../widgets/buttons.dart';
import '../widgets/svg_images.dart';
import '../widgets/text_fields.dart';
import 'otp_verify_screen.dart';

class EditPhoneOrEmailScreen extends StatefulWidget {
  const EditPhoneOrEmailScreen({super.key, required this.isPhoneUpdate});
  final bool isPhoneUpdate;
  @override
  State<EditPhoneOrEmailScreen> createState() => _EditPhoneOrEmailScreenState();
}

class _EditPhoneOrEmailScreenState extends State<EditPhoneOrEmailScreen> {
  // final TextEditingController _nameController = TextEditingController();

  // // final TextEditingController _phoneController = TextEditingController();
  // final TextEditingController _userIdController = TextEditingController();
  // final TextEditingController _bioController = TextEditingController();

  final _editProfileFormKey = GlobalKey<FormState>();

  // UserData? user;

  @override
  void initState() {
    // user = context.read<UserDataCubit>().state;
    fillData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  fillData() {
    // showMessage("User ==> ${user?.toDbJson()}");
    profileCubit.initEditProfileFields(null);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        context.read<ProfileCubit>().changePhoneBoolValue();
        await NavigationService().goBack();
      },
      child: Scaffold(
        appBar: CommonAppBar(
          isBackShow: true,
          title: S.of(context).editPhoneOrEmail(
              widget.isPhoneUpdate ? S.current.phone : S.current.email),
          isActionsShow: false,
          onBackPressed: () async {
            context.read<ProfileCubit>().changePhoneBoolValue();
            await NavigationService().goBack();
          },
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
              left: 32.w, right: 32.w, bottom: Platform.isIOS ? 32.h : 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (contextProfile, profileState) {
                return CustomButton(
                  onPressed: () async {
                    if (widget.isPhoneUpdate) {
                      if (profileState.phoneNumber != null &&
                          profileState.phoneNumber!.number.isEmpty) {
                        if ((profileState.userData!.email ?? "").isNotEmpty) {
                          showMessage("Remove PhoneNumber");
                          await profileCubit.updateProfileForRemovePhone(
                              context: context);
                        } else {
                          Utils.showSnackBar(
                              context, S.current.errorCannotRemovePhone);
                          profileCubit
                              .initEditProfileFields(profileState.userData);
                          return;
                        }
                      } else if (_editProfileFormKey.currentState!.validate()) {
                        if (profileState.isPhoneChanged) {
                          String phoneNumber = '';
                          String countryCode = '';
                          String countryISOCode = '';

                          if (profileState.phoneNumber != null &&
                              profileState.phoneNumber!.number.isNotEmpty) {
                            phoneNumber = profileState.phoneNumber!.number;
                            countryCode = profileState.phoneNumber!.countryCode;
                            countryISOCode =
                                profileState.phoneNumber!.countryISOCode;
                          } else {
                            // Utils.showSnackBar(context, message);
                          }

                          showMessage('Phone Number --> $phoneNumber');
                          showMessage('countryCode --> $countryCode');
                          showMessage('countryISOCode --> $countryISOCode');
                          // return;

                          context.dismissKeyboard();
                          FocusScope.of(context).unfocus();
                          if (profileState.phoneNumber != null &&
                              profileState.userData?.phone !=
                                  profileState.phoneNumber?.number) {
                            // context.showLoader();
                            profileCubit.emitSendOtpLoadingState(
                                isLoadEmail: false, isLoadPhone: true);
                            await context.read<SendOtpCubit>().sendPhoneOtp(
                              "$countryCode$phoneNumber",
                              context,
                              callback: (verificationId) async {
                                if (verificationId.isNotEmpty) {
                                  auth.PhoneAuthCredential? result =
                                      await NavigationService()
                                          .navigateTo(OtpVerifyScreen(
                                    phoneNumber: phoneNumber ?? '',
                                    countryISOCode: countryISOCode ?? '',
                                    countryCode: countryCode ?? '',
                                    verificationId: verificationId,
                                    isEditProfile: true,
                                  ));

                                  context.dismissKeyboard();
                                  if (result != null) {
                                    Utils.showSnackBar(
                                        context, S.current.otpVerifySuccess,
                                        seconds: 2);
                                    context
                                        .read<ProfileCubit>()
                                        .setData(result);
                                    await profileCubit.updatePhoneNumberProfile(
                                      phone: phoneNumber,
                                      countryISOCode: countryISOCode,
                                      countryCode: countryCode,
                                      context: context,
                                      callback: (response) async {
                                        // user = response.data;
                                        NavigationService().goBack();
                                        // context.read<PhoneInputCubit>().clearState();
                                        // await context.read<UserDataCubit>().loadUserData();
                                        // Utils.showSnackBar(context,
                                        //     AppConstants.lblUpdateProfile,
                                        //     seconds: 2);
                                      },
                                    );
                                  } else {
                                    // Utils.showSnackBar(context,
                                    //     AppConstants.pleaseTryAgainTxt,
                                    //     seconds: 2);
                                  }
                                }
                              },
                            );
                          }
                        } else {
                          Utils.showSnackBar(context,
                              S.current.pleaseChangePhoneNumberBeforeUpdate);
                        }
                      }
                    } else {
                      if (_editProfileFormKey.currentState!.validate()) {
                        final email = profileState.emailController.text.trim();
                        if (email == profileState.userData?.email) {
                          Utils.showSnackBar(context,
                              S.of(context).emailAddressIsAlreadyUpdated);
                          return;
                        }
                        if (email.isEmpty) {
                          if (profileState.phoneNumber != null &&
                              profileState.phoneNumber!.number.isNotEmpty) {
                            showMessage("Remove Email ");
                            await profileCubit.updateProfileForRemoveEmail(
                                context: context);
                          } else {
                            Utils.showSnackBar(
                                context, S.current.errorCannotRemoveEmail);
                            profileCubit
                                .initEditProfileFields(profileState.userData);
                            return;
                          }
                        } else if (email.isValidEmail(
                          (message) => Utils.showSnackBar(context, message),
                        )) {
                          await profileCubit.sendOtpForEmailChange(
                            email,
                            context,
                            callback: () async {
                              await NavigationService()
                                  .navigateTo(OtpVerifyScreen(
                                email: email,
                                isEditProfile: true,
                              ));
                              NavigationService().goBack();
                            },
                          );
                        }
                      }
                    }

                    // if (profileState.phoneNumber != null &&
                    //     profileState.phoneNumber!.number.isEmpty) {
                    //   if ((profileState.userData!.email ?? "").isNotEmpty) {
                    //     showMessage("Remove PhoneNumber");
                    //     await profileCubit.updateProfileForRemovePhone(
                    //         context: context);
                    //   } else {
                    //     Utils.showSnackBar(
                    //         context, S.current.errorCannotRemovePhone);
                    //     return;
                    //   }
                    // } else if (_editProfileFormKey.currentState!.validate()) {
                    //   if (widget.isPhoneUpdate) {
                    //   } else {
                    //     final email = profileState.emailController.text.trim();
                    //     if (email.isEmpty) {
                    //       if (profileState.phoneNumber != null &&
                    //           profileState.phoneNumber!.number.isNotEmpty) {
                    //         showMessage("Remove Email ");
                    //         await profileCubit.updateProfileForRemoveEmail(
                    //             context: context);
                    //       } else {
                    //         Utils.showSnackBar(
                    //             context, S.current.errorCannotRemoveEmail);
                    //         return;
                    //       }
                    //     } else if (email.isValidEmail(
                    //       (message) => Utils.showSnackBar(context, message),
                    //     )) {
                    //       await profileCubit.sendOtpForEmailChange(
                    //         email,
                    //         context,
                    //         callback: () async {
                    //           await NavigationService()
                    //               .navigateTo(OtpVerifyScreen(
                    //             email: email,
                    //             isEditProfile: true,
                    //           ));
                    //         },
                    //       );
                    //     }
                    //   }
                    // }
                    // if (_editProfileFormKey.currentState!.validate()) {
                    //   await profileCubit.updateProfile(
                    //     phone: phoneNumber,
                    //     countryISOCode: countryISOCode,
                    //     countryCode: countryCode,
                    //     context: context,
                    //     callback: (response) async {
                    //       // user = response.data;

                    //       // context.read<PhoneInputCubit>().clearState();
                    //       // await context.read<UserDataCubit>().loadUserData();
                    //       Utils.showSnackBar(
                    //           context, AppConstants.lblUpdateProfile,
                    //           seconds: 2);
                    //     },
                    //   );
                    // }
                  },
                  child: () {
                    if (profileState.sendOtpLoadingState ==
                        LoadingState.loading) {
                      return const CustomLoadingWidget(color: AppColors.white);
                    }
                    // else if (profileState is ProfileSuccess) {
                    //   return const Icon(
                    //     Icons.check,
                    //     color: AppColors.white,
                    //   );
                    // }
                    else if (profileState.sendOtpLoadingState ==
                        LoadingState.error) {
                      return Text(
                        S.of(context).loginButtonTextRe,
                        style: AppTextStyles.medium(
                          fontSize: 16.sp,
                          color: AppColors.white,
                        ),
                      );
                    } else {
                      return Text(
                        S.of(context).updateBtnTxt,
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
        body: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (contextProfile, profileState) {
          return SafeArea(
              child: Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w),
            child: widget.isPhoneUpdate
                ? Form(
                    key: _editProfileFormKey,
                    child: ListView(
                      children: [
                        10.s,
                        Text(
                          S.of(context).phoneNumber,
                          style: AppTextStyles.medium(),
                        ),
                        10.s,
                        AppIntlPhoneField( dropdownTextStyle: TextStyle(fontSize: 16.sp, color: AppColors.white),
                          onChanged: (value) {
                            contextProfile
                                .read<ProfileCubit>()
                                .updatePhoneNumber(value);
                          },
                          onCountryChanged: (value) {
                            PhoneNumber? phoneNumber;
                            // if (profileState is UpdatePhoneNumber) {
                            phoneNumber = profileState.phoneNumber;
                            context
                                .read<ProfileCubit>()
                                .updateCountry(value, phoneNumber);
                          },
                          controller: profileState.phoneController,
                          initialCountryCode:
                              profileState.userData?.countryISOCode,
                          initialValue: profileState.userData?.phone,
                          style: TextStyle(
                              fontSize: 16.sp, color: AppColors.white),
                          decoration: InputDecoration(
                            hintText: S.of(context).phonePlaceholder,
                            hintStyle: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.textPlaceHolder,
                            ),
                            // suffixIcon: profileState.isPhoneChanged &&
                            //         !profileState.isPhoneVerified
                            //     ? ElevatedButton(
                            //         onPressed: () async {
                            //           context.dismissKeyboard();
                            //           FocusScope.of(context).unfocus();
                            //           if (profileState.phoneNumber != null &&
                            //               profileState.userData?.phone !=
                            //                   profileState
                            //                       .phoneNumber?.number) {
                            //             await context
                            //                 .read<SendOtpCubit>()
                            //                 .sendPhoneOtp(
                            //               "${profileState.phoneNumber?.countryCode}${profileState.phoneNumber?.number}",
                            //               context,
                            //               callback: (verificationId) async {
                            //                 if (verificationId.isNotEmpty) {
                            //                   auth.PhoneAuthCredential? result =
                            //                       await NavigationService()
                            //                           .navigateTo(
                            //                               OtpVerifyScreen(
                            //                     phoneNumber: profileState
                            //                             .phoneNumber?.number ??
                            //                         '',
                            //                     countryISOCode: profileState
                            //                             .phoneNumber
                            //                             ?.countryISOCode ??
                            //                         '',
                            //                     countryCode: profileState
                            //                             .phoneNumber
                            //                             ?.countryCode ??
                            //                         '',
                            //                     verificationId: verificationId,
                            //                     isEditProfile: true,
                            //                   ));

                            //                   context.dismissKeyboard();
                            //                   if (result != null) {
                            //                     Utils.showSnackBar(
                            //                         context,
                            //                         AppConstants
                            //                             .otpVerifySuccess,
                            //                         seconds: 2);
                            //                     context
                            //                         .read<ProfileCubit>()
                            //                         .setData(result);
                            //                   } else {
                            //                     // Utils.showSnackBar(context,
                            //                     //     AppConstants.pleaseTryAgainTxt,
                            //                     //     seconds: 2);
                            //                   }
                            //                 }
                            //               },
                            //             );
                            //           }
                            //         },
                            //         style: ElevatedButton.styleFrom(
                            //           padding: EdgeInsets.zero,
                            //           shape: RoundedRectangleBorder(
                            //             borderRadius:
                            //                 BorderRadius.circular(8.r),
                            //           ),
                            //           backgroundColor: AppColors.primaryColor,
                            //         ),
                            //         child: Text(
                            //           AppConstants.btnVerifyTxt,
                            //           style: TextStyle(color: AppColors.white),
                            //         ),
                            //       )
                            //     : null,
                          ),
                          // showCountryFlag: false,
                          dropdownIcon: Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.white, // Custom color
                          ),
                          pickerDialogStyle: PickerDialogStyle(
                            backgroundColor: AppColors.dialogBg,
                            countryNameStyle: AppTextStyles.regular(),
                            countryCodeStyle: AppTextStyles.regular()
                                .copyWith(fontWeight: FontWeight.bold),
                            searchFieldInputDecoration: InputDecoration(
                              hintText: S.of(context).searchCountry,
                              hintStyle: TextStyle(color: AppColors.white),
                              // Hint text color
                              fillColor: AppColors
                                  .darkInputFill, // Background color if needed
                            ),
                          ),
                          autovalidateMode: AutovalidateMode.disabled,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value?.number.isEmpty ?? false) {
                              return Future.value(null);
                            } else if (value?.number.isNotEmpty ?? false) {
                              return Future.value(null);
                            }
                            return Future.value(S.of(context).phoneError);
                          },
                        ),
                      ],
                    ),
                  )
                : Form(
                    key: _editProfileFormKey,
                    child: ListView(
                      children: [
                        10.s,
                        Text(
                          S.of(context).emailAdress,
                          style: AppTextStyles.medium(),
                        ),
                        10.s,
                        CustomTextField(
                          controller: profileState.emailController,
                          label: S.of(context).emailPlaceHolder,
                          textInputAction: TextInputAction.done,
                          maxLines: 1,
                          prefixIcon: SvgImage(
                            source: SvgAssets.icEmail,
                            fit: BoxFit.scaleDown,
                            color: AppColors.white,
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),
                  ),
          ));
        }),
      ),
    );
  }
}
