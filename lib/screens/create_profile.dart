import 'dart:developer';
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
import 'package:two_one_two_messenger/screens/home_screen.dart';
import 'package:two_one_two_messenger/utils/extensions.dart';
import 'package:two_one_two_messenger/utils/image_picker.dart';
import 'package:two_one_two_messenger/widgets/avatar_widgets.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';
import 'package:two_one_two_messenger/widgets/intl_widget.dart';

import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../cubit/send_otp_cubit.dart';
import '../cubit/user_data_cubit.dart';
import '../models/otp_verify.dart';
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

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  // final TextEditingController _nameController = TextEditingController();

  // // final TextEditingController _phoneController = TextEditingController();
  // final TextEditingController _userIdController = TextEditingController();
  // final TextEditingController _bioController = TextEditingController();

  final _profileFormKey = GlobalKey<FormState>();
  String phoneFieldKey = "";
  UserData? user;

  @override
  void initState() {
    user = context.read<UserDataCubit>().state;
    fillData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  fillData() async {
    user = await profileCubit.dbHelper.getLoginData();
    log("create Login user  ==>${user?.toJson()}");
    await profileCubit.initEditProfileFields(user);
    if (mounted) {
      setState(() {
        phoneFieldKey =
            user?.phone ?? "${DateTime.now().millisecondsSinceEpoch}";
      });
    }
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
          title: S.of(context).lblCreateProfile,
          isActionsShow: false,
          onBackPressed: () async {
            context.read<ProfileCubit>().changePhoneBoolValue();
            await NavigationService().goBack();
          },
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
              left: 32.w,
              right: 32.w,
              bottom: Platform.isIOS ? 32.h : 16.h,
              top: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (contextProfile, profileState) {
                return CustomButton(
                  onPressed: () async {
                    // String phoneNumber = '';
                    // String countryCode = '';
                    // String countryISOCode = '';
                    try {
                      // if ((profileState.userData?.profilePicture ?? "")
                      //         .isEmpty &&
                      //     profileState.selectedFile == null) {
                      //   Utils.showSnackBar(
                      //       context, S.of(context).pleaseSelectProfileImage);
                      //   return;
                      // }
                      if (!(await profileCubit.handleNameValidation(
                          profileState.nameController.text.trim()))) {
                        return;
                      }
                      if (!(await profileCubit.handleUserNameValidation(
                          profileState.userIdController.text.trim(),
                          context))) {
                        return;
                      }

                      if (profileState.userIdErrorMessage != null) {
                        return;
                      }

                      // if (profileState.phoneNumber != null &&
                      //     profileState.phoneNumber!.number.isNotEmpty) {
                      //   phoneNumber = profileState.phoneNumber!.number;
                      //   countryCode = profileState.phoneNumber!.countryCode;
                      //   countryISOCode = profileState.phoneNumber!.countryISOCode;
                      // }

                      // showMessage('Phone Number --> ${phoneNumber}');
                      // showMessage('countryCode --> ${countryCode}');
                      // showMessage('countryISOCode --> ${countryISOCode}');

                      if ((!(profileState.userData?.isPhoneVerify ?? false)) &&
                          (profileState.phoneNumber == null ||
                              (profileState.phoneNumber?.number ?? "")
                                  .isEmpty)) {
                        await profileCubit.createProfile(
                          phone: "",
                          countryISOCode: "",
                          countryCode: "",
                          context: context,
                          file: profileState.selectedFile,
                          callback: (response) async {
                            //   AppPreference.setEmailVerify();
                            await homeCubit.resetState();
                            // AppPreference.setPhoneVerify();
                            NavigationService()
                                .clearAndNavigateTo(HomeScreen());
                          },
                        );
                      } else if (!(profileState.userData?.isEmailVerify ??
                              false) &&
                          (profileState.emailController.text.trim().isEmpty)) {
                        await profileCubit.createProfile(
                          phone: "",
                          countryISOCode: "",
                          countryCode: "",
                          context: context,
                          file: profileState.selectedFile,
                          callback: (response) async {
                            //   AppPreference.setEmailVerify();
                            await homeCubit.resetState();
                            // AppPreference.setPhoneVerify();
                            NavigationService()
                                .clearAndNavigateTo(HomeScreen());
                          },
                        );
                      } else if (_profileFormKey.currentState!.validate()) {
                        if (!(profileState.userData?.isPhoneVerify ?? false)) {
                          if (profileState.phoneNumber != null &&
                              (profileState.phoneNumber?.number ?? "")
                                  .isNotEmpty &&
                              profileState.userData?.phone !=
                                  profileState.phoneNumber?.number) {
                            profileCubit.emitProfileLoadingState();
                            var isPhoneSaveHandled = false;
                            await context.read<SendOtpCubit>().sendPhoneOtp(
                              "${profileState.phoneNumber?.countryCode}${profileState.phoneNumber?.number}",
                              context,
                              callback: (verificationId) async {
                                if (verificationId.isNotEmpty) {
                                  auth.PhoneAuthCredential? result =
                                      await NavigationService()
                                          .navigateTo(OtpVerifyScreen(
                                    phoneNumber:
                                        profileState.phoneNumber?.number ?? '',
                                    countryISOCode: profileState
                                            .phoneNumber?.countryISOCode ??
                                        '',
                                    countryCode:
                                        profileState.phoneNumber?.countryCode ??
                                            '',
                                    verificationId: verificationId,
                                    isEditProfile: true,
                                    isCreateProfile: true,
                                  ));

                                  if (result != null) {
                                    if (isPhoneSaveHandled) return;
                                    isPhoneSaveHandled = true;
                                    Utils.showSnackBar(
                                        context, S.current.otpVerifySuccess,
                                        seconds: 2);
                                    profileCubit.setData(result);
                                    await profileCubit.createProfile(
                                      phone: profileState.phoneNumber?.number ??
                                          '',
                                      countryISOCode: profileState
                                              .phoneNumber?.countryISOCode ??
                                          '',
                                      countryCode: profileState
                                              .phoneNumber?.countryCode ??
                                          '',
                                      context: context,
                                      file: profileState.selectedFile,
                                      callback: (response) async {
                                        // AppPreference.setEmailVerify();
                                        await homeCubit.resetState();
                                        // AppPreference.setPhoneVerify();
                                        NavigationService()
                                            .clearAndNavigateTo(HomeScreen());
                                      },
                                    );
                                  } else {
                                    Utils.showSnackBar(context,
                                        S.of(context).pleaseTryAgainTxt,
                                        seconds: 2);
                                  }
                                }
                                profileCubit.emitProfileSucessState();
                              },
                              verificationCompletedCallback:
                                  (credential) async {
                                if (isPhoneSaveHandled) return;
                                isPhoneSaveHandled = true;
                                Utils.showSnackBar(
                                    context, S.current.otpVerifySuccess,
                                    seconds: 2);
                                profileCubit.setData(credential);
                                await profileCubit.createProfile(
                                  phone: profileState.phoneNumber?.number ?? '',
                                  countryISOCode: profileState
                                          .phoneNumber?.countryISOCode ??
                                      '',
                                  countryCode:
                                      profileState.phoneNumber?.countryCode ??
                                          '',
                                  context: context,
                                  file: profileState.selectedFile,
                                  callback: (response) async {
                                    await homeCubit.resetState();
                                    NavigationService()
                                        .clearAndNavigateTo(HomeScreen());
                                  },
                                );
                              },
                            );
                          } else if (profileState.phoneNumber != null &&
                              (profileState.phoneNumber?.number ?? "")
                                  .isNotEmpty) {
                            await profileCubit.createProfile(
                              phone: profileState.phoneNumber?.number ?? '',
                              countryISOCode:
                                  profileState.phoneNumber?.countryISOCode ??
                                      '',
                              countryCode:
                                  profileState.phoneNumber?.countryCode ?? '',
                              context: context,
                              file: profileState.selectedFile,
                              callback: (response) async {
                                await homeCubit.resetState();
                                NavigationService()
                                    .clearAndNavigateTo(HomeScreen());
                              },
                            );
                          }
                        } else if (!(profileState.userData?.isEmailVerify ??
                            false)) {
                          log("sdhkahskfhcjksdhfjkdjkshjk==== 1");
                          final email =
                              profileState.emailController.text.trim();
                          if (email.isValidEmail(
                            (message) => Utils.showSnackBar(context, message),
                          )) {
                            profileCubit.emitProfileLoadingState();
                            log("sdhkahskfhcjksdhfjkdjkshjk==== 2");
                            await profileCubit.sendOtpForEmailChange(
                              email,
                              context,
                              callback: () async {
                                log("sdhkahskfhcjksdhfjkdjkshjk==== 3");
                                await NavigationService()
                                    .navigateTo(OtpVerifyScreen(
                                  email: email,
                                  isEditProfile: true,
                                  isCreateProfile: true,
                                ));
                                log("sdhkahskfhcjksdhfjkdjkshjk==== 4 ${profileState.userData?.isEmailVerify ?? false}");
                                UserData? user =
                                    await profileCubit.dbHelper.getLoginData();
                                user ??= profileState.userData;
                                if (user?.isEmailVerify ?? false) {
                                  await profileCubit.createProfile(
                                    phone: "",
                                    countryISOCode: "",
                                    countryCode: "",
                                    context: context,
                                    file: profileState.selectedFile,
                                    callback: (response) async {
                                      //   AppPreference.setEmailVerify();
                                      await homeCubit.resetState();
                                      // AppPreference.setPhoneVerify();
                                      NavigationService()
                                          .clearAndNavigateTo(HomeScreen());
                                    },
                                  );
                                } else {
                                  // Utils.showSnackBar(
                                  //     context, "Email is not Verified ");
                                }
                              },
                            );
                            profileCubit.emitProfileSucessState();
                          }
                        } else {
                          await profileCubit.createProfile(
                            phone: "",
                            countryISOCode: "",
                            countryCode: "",
                            context: context,
                            file: profileState.selectedFile,
                            callback: (response) async {
                              //   AppPreference.setEmailVerify();
                              await homeCubit.resetState();
                              // AppPreference.setPhoneVerify();
                              NavigationService()
                                  .clearAndNavigateTo(HomeScreen());
                            },
                          );
                        }
                        showMessage(
                            "11 last in create profile ${(profileState.userData?.isEmailVerify)}");
                      } else {
                        showMessage("last in create profile ");
                      }
                    } catch (e, st) {
                      showMessage("Error in create profile $e $st");
                      profileCubit.emitProfileSucessState();
                    } finally {
                      showMessage("finally in create profile ");
                      // profileCubit.emitProfileSucessState();
                    }
                  },
                  child: () {
                    if (profileState.profileLoadingState ==
                        LoadingState.loading) {
                      return const CustomLoadingWidget(
                        color: AppColors.white,
                      );
                    }
                    // else if (profileState is ProfileSuccess) {
                    //   return const Icon(
                    //     Icons.check,
                    //     color: AppColors.white,
                    //   );
                    // }
                    else if (profileState.profileLoadingState ==
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
                        S.of(context).lblCreateProfile,
                        style: AppTextStyles.medium(
                          fontSize: 16.sp,
                          color: AppColors.white,
                        ),
                      );
                    }
                  }(),
                );
              }),
            ],
          ),
        ),
        body: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (contextProfile, profileState) {
          // showMessage(
          //     " profile code ${profileState.phoneNumber?.countryCode} ${profileState.phoneNumber?.number}");
          return SafeArea(
              child: Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w),
            child: Form(
              key: _profileFormKey,
              child: ListView(
                children: [
                  SizedBox(height: 10.h),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 150.h,
                        child: Container(
                            width: 120.w,
                            height: 120.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.darkAppBar, width: 4.w),
                            ),
                            child: profileState.selectedFile != null
                                ? CircleAvatar(
                                    radius: 60.r,
                                    backgroundImage:
                                        FileImage(profileState.selectedFile!),
                                    // Use FileImage for circular display
                                    backgroundColor: Colors
                                        .transparent, // Set background to transparent if needed
                                  )
                                : AvatarWidgets(
                                    userPic:
                                        profileState.userData?.profilePicture ??
                                            "",
                                    height: 115,
                                    width: 115,
                                  )
                            //     BlocBuilder<ProfilePickCubit, ProfilePickState>(
                            //         builder: (contextProfile, profileState) {
                            //   if (profileState is ProfilePickSuccess) {
                            // return CircleAvatar(
                            //   radius: 60.r,
                            //   backgroundImage: FileImage(profileState.file),
                            //   // Use FileImage for circular display
                            //   backgroundColor: Colors
                            //       .transparent, // Set background to transparent if needed
                            // );
                            //     // return ClipOval(
                            //     //   child: Image.file(
                            //     //     profileState.file,
                            //     //     width: 100.w,
                            //     //     height: 100.h,
                            //     //     fit: BoxFit.contain,
                            //     //   ),
                            //     // );
                            //   }
                            //   /*else if (profileState is ProfilePickError) {
                            //       return Icon(
                            //         Icons.error,
                            //         color: AppColors.redColor,
                            //         size: 30.w,
                            //       );
                            //     } */
                            //   else {
                            //     return user?.profilePicture != null
                            //         ? Center(
                            //             child: SizedBox(
                            //               height: 115.h,
                            //               width: 115.w,
                            //               child: AppNetworkImage(
                            //                 imageUrl:
                            //                     '${Urls.mediaUrl}${user?.profilePicture}',
                            //                 fit: BoxFit.cover,
                            //                 borderRadius:
                            //                     BorderRadius.circular(100.r),
                            //               ),
                            //             ),
                            //           )
                            //         : Center(
                            //             child: SvgImage(
                            //                 source: SvgAssets.icPerson,
                            //                 width: 30.w,
                            //                 color: AppColors.white),
                            //           );
                            //   }
                            // }),
                            ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: GestureDetector(
                          onTap: () {
                            showCustomImageOptionPickerDialog(
                                context: context,
                                onImagePicked: profileCubit.pickImage);
                          },
                          child: CircleAvatar(
                            radius: 15.r,
                            backgroundColor: AppColors.primaryColor,
                            child: SvgImage(
                              source: SvgAssets.icCamera,
                              width: 15.w,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  CustomTextField(
                    controller: profileState.nameController,
                    label: S.of(context).namePlaceholder,
                    prefixIcon: SvgImage(
                      source: SvgAssets.icPerson,
                      fit: BoxFit.scaleDown,
                      color: AppColors.white,
                    ),
                    textInputAction: TextInputAction.next,
                    errorText: profileState.nameErrorMessage,
                    onChanged: (value) {
                      profileCubit.handleNameValidation(value.trim());
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return S.of(context).nameError;
                      }
                      return null;
                    },
                  ),
                  16.s,
                  CustomTextField(
                    controller: profileState.emailController,
                    readOnly: profileState.userData?.isEmailVerify ?? false,
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
                  16.s,
                  IgnorePointer(
                    ignoring: profileState.userData?.isPhoneVerify ?? false,
                    child: AppIntlPhoneField(
                      key: ValueKey(phoneFieldKey),
                      readOnly: profileState.userData?.isPhoneVerify ?? false,
                      controller: profileState.phoneController,
                      onChanged: (value) {
                        contextProfile
                            .read<ProfileCubit>()
                            .updatePhoneNumber(value);
                        // setState(() {});
                      },
                      onCountryChanged: (value) {
                        PhoneNumber? phoneNumber;
                        // if (profileState is UpdatePhoneNumber) {
                        phoneNumber = profileState.phoneNumber;
                        context
                            .read<ProfileCubit>()
                            .updateCountry(value, phoneNumber);
                      },
                      initialCountryCode:
                          (profileState.phoneNumber?.countryISOCode ?? "")
                                  .isEmpty
                              ? "GB"
                              : profileState.phoneNumber?.countryISOCode ??
                                  'GB',
                      initialValue:
                          profileState.phoneNumber?.completeNumber ?? "",
                      style: TextStyle(fontSize: 16.sp, color: AppColors.white),
                      dropdownTextStyle:
                          TextStyle(fontSize: 16.sp, color: AppColors.white),
                      decoration: InputDecoration(
                        hintText: S.of(context).phonePlaceholder,
                        hintStyle: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.textPlaceHolder,
                        ),
                        // suffixIcon: profileState.isPhoneChanged
                        //     ? ElevatedButton(
                        //         onPressed: () async {
                        //           context.dismissKeyboard();
                        //           FocusScope.of(context).unfocus();
                        //           if (profileState.phoneNumber != null &&
                        //               (profileState.phoneNumber?.number ?? "")
                        //                   .isNotEmpty &&
                        //               profileState.userData?.phone !=
                        //                   profileState.phoneNumber?.number) {
                        //             profileCubit.emitSendOtpLoadingState();
                        //             await context
                        //                 .read<SendOtpCubit>()
                        //                 .sendPhoneOtp(
                        //               "${profileState.phoneNumber?.countryCode}${profileState.phoneNumber?.number}",
                        //               context,
                        //               callback: (verificationId) async {
                        //                 if (verificationId.isNotEmpty) {
                        //                   auth.PhoneAuthCredential? result =
                        //                       await NavigationService()
                        //                           .navigateTo(OtpVerifyScreen(
                        //                     phoneNumber: profileState
                        //                             .phoneNumber?.number ??
                        //                         '',
                        //                     countryISOCode: profileState
                        //                             .phoneNumber
                        //                             ?.countryISOCode ??
                        //                         '',
                        //                     countryCode: profileState
                        //                             .phoneNumber?.countryCode ??
                        //                         '',
                        //                     verificationId: verificationId,
                        //                     isEditProfile: true,
                        //                   ));

                        //                   context.dismissKeyboard();
                        //                   if (result != null) {
                        //                     Utils.showSnackBar(context,
                        //                         AppConstants.otpVerifySuccess,
                        //                         seconds: 2);
                        //                     context
                        //                         .read<ProfileCubit>()
                        //                         .setData(result);
                        //                     await profileCubit
                        //                         .updatePhoneNumberProfile(
                        //                       phone: profileState
                        //                               .phoneNumber?.number ??
                        //                           "",
                        //                       countryISOCode: profileState
                        //                               .phoneNumber
                        //                               ?.countryISOCode ??
                        //                           "",
                        //                       countryCode: profileState
                        //                               .phoneNumber?.countryCode ??
                        //                           "",
                        //                       context: context,
                        //                       callback: (response) async {
                        //                         // user = response.data;

                        //                         // context.read<PhoneInputCubit>().clearState();
                        //                         // await context.read<UserDataCubit>().loadUserData();
                        //                         Utils.showSnackBar(context,
                        //                             AppConstants.lblUpdateProfile,
                        //                             seconds: 2);
                        //                       },
                        //                     );
                        //                   } else {
                        //                     Utils.showSnackBar(context,
                        //                         AppConstants.pleaseTryAgainTxt,
                        //                         seconds: 2);
                        //                   }
                        //                 }
                        //               },
                        //             );
                        //           }
                        //         },
                        //         style: ElevatedButton.styleFrom(
                        //           padding: EdgeInsets.zero,
                        //           shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(8.r),
                        //           ),
                        //           backgroundColor:
                        //               (profileState.userData?.isPhoneVerify ??
                        //                       false)
                        //                   ? AppColors.greenColor
                        //                   : AppColors.primaryColor,
                        //         ),
                        //         child: (profileState.sendOtpLoadingState ==
                        //                 LoadingState.loading)
                        //             ? const CustomLoadingWidget(
                        //                 color: AppColors.white)
                        //             : Text(
                        //                 AppConstants.btnVerifyTxt,
                        //                 style: TextStyle(color: AppColors.white),
                        //               ),
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
                        // return Future.value(null);
                        if ((profileState.phoneNumber?.number ?? "").isEmpty) {
                          showMessage(
                              "validator  ${profileState.phoneNumber?.number ?? ""}");
                          return Future.value(null);
                        } else {
                          if (value?.number.isNotEmpty ?? false) {
                            return Future.value(null);
                          }
                          return Future.value(S.of(context).phoneError);
                        }
                      },
                    ),
                  ),
                  8.s,
                  CustomTextField(
                    controller: profileState.userIdController,
                    label: S.of(context).usernamePlaceholder,
                    // readOnly: true,
                    prefixIcon: SvgImage(
                      source: SvgAssets.icIdCard,
                      fit: BoxFit.scaleDown,
                      color: AppColors.white,
                    ),
                    textInputAction: TextInputAction.next,
                    errorText: profileState.userIdErrorMessage,
                    onChanged: (value) {
                      profileCubit.validateUserName(value.trim(), context);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return S.of(context).userIDError;
                      }
                      return null;
                    },
                  ),
                  16.s,
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.darkInputFill,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                            left: 12.w,
                            top: 16.h,
                            right: 2.w,
                          ),
                          child: SvgImage(
                            source: SvgAssets.icInfo,
                            fit: BoxFit.scaleDown,
                            color: AppColors.textPlaceHolder,
                          ),
                        ),
                        Expanded(
                          child: CustomTextField(
                            controller: profileState.bioController,
                            label: S.of(context).aboutYouPlaceholder,
                            maxLines: 4,
                            maxLength: 300,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              // if (value == null || value.isEmpty) {
                              //   return AppConstants.aboutYouError;
                              // }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  16.s,
                  buildProfilePrivacyTile(context,
                      text: S.of(context).makeProfilePrivate,
                      subTitle: profileState.profilePrivacy ==
                              ProfilePivacy.private.value
                          ? S.of(context).privateProfileText
                          : S.of(context).publicProfileText,
                      onChanged: (isPrivate) {
                    profileCubit.setProfilePrivacy(isPrivate);
                  },
                      defaultValue: profileState.profilePrivacy ==
                          ProfilePivacy.private.value),
                ],
              ),
            ),
          ));
        }),
      ),
    );
  }

  Widget buildProfilePrivacyTile(
    BuildContext context, {
    required String text,
    required String subTitle,
    required Function(bool)? onChanged,
    required bool defaultValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: AppTextStyles.medium(
                      fontSize: 18.sp,
                    ),
                  ),
                  Text(
                    subTitle,
                    style: AppTextStyles.regular(
                        fontSize: 12.sp, color: AppColors.textColorHint),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 25.h,
              child: Switch(
                padding: EdgeInsets.zero,
                value: defaultValue,
                onChanged: onChanged,
                activeTrackColor: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 17.h),
        Divider(
          height: 0.h,
          color: AppColors.darkInputFill,
        ),
      ],
    );
  }
}
