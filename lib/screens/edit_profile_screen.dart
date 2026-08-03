import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/screens/edit_phone_or_email.dart';
import 'package:two_one_two_messenger/services/api_config.dart';
import 'package:two_one_two_messenger/utils/image_picker.dart';
import 'package:two_one_two_messenger/widgets/intl_widget.dart';

import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/navigation.dart';
import '../utils/text_style.dart';
import '../utils/utils.dart';
import '../widgets/appbar.dart';
import '../widgets/keyboard_safe_scaffold.dart';
import '../widgets/buttons.dart';
import '../widgets/network_image.dart';
import '../widgets/svg_images.dart';
import '../widgets/text_fields.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
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
      child: KeyboardSafeScaffold(
        appBar: CommonAppBar(
          isBackShow: true,
          title: S.of(context).lblEditProfile,
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
                      String phoneNumber = '';
                      String countryCode = '';
                      String countryISOCode = '';

                      // if (profileState.phoneNumber != null &&
                      //     profileState.phoneNumber!.number.isNotEmpty) {
                      //   phoneNumber = profileState.phoneNumber!.number;
                      //   countryCode = profileState.phoneNumber!.countryCode;
                      //   countryISOCode = profileState.phoneNumber!.countryISOCode;
                      // } else {
                      //   // Utils.showSnackBar(context, message);
                      // }

                      // showMessage('Phone Number --> ${phoneNumber}');
                      // showMessage('countryCode --> ${countryCode}');
                      // showMessage('countryISOCode --> ${countryISOCode}');
                      // return;
                      if (_editProfileFormKey.currentState!.validate()) {
                        await profileCubit.updateProfile(
                          phone: phoneNumber,
                          countryISOCode: countryISOCode,
                          countryCode: countryCode,
                          context: context,
                          callback: (response) async {
                            // user = response.data;

                            // context.read<PhoneInputCubit>().clearState();
                            // await context.read<UserDataCubit>().loadUserData();
                            Utils.showSnackBar(
                                context, S.of(context).lblUpdateProfile,
                                seconds: 2);
                          },
                        );
                      }
                    },
                    child: Text(
                      S.of(context).updateBtnTxt,
                      style: AppTextStyles.medium(
                        fontSize: 16.sp,
                        color: AppColors.white,
                      ),
                    )
                    //  () {
                    //   if (profileState.profileLoadingState ==
                    //       LoadingState.loading) {
                    //     return const CustomLoadingWidget(color: AppColors.white);
                    //   }
                    //   // else if (profileState is ProfileSuccess) {
                    //   //   return const Icon(
                    //   //     Icons.check,
                    //   //     color: AppColors.white,
                    //   //   );
                    //   // }
                    //   else if (profileState.profileLoadingState ==
                    //       LoadingState.error) {
                    //     return Text(
                    //       S.of(context).loginButtonTextRe,
                    //       style: AppTextStyles.medium(
                    //         fontSize: 16.sp,
                    //         color: AppColors.white,
                    //       ),
                    //     );
                    //   } else {
                    //     return Text(
                    //       S.of(context).updateBtnTxt,
                    //       style: AppTextStyles.medium(
                    //         fontSize: 16.sp,
                    //         color: AppColors.white,
                    //       ),
                    //     );
                    //   }
                    // }(),
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
            child: Form(
              key: _editProfileFormKey,
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
                                : profileState.userData?.profilePicture != null
                                    ? Center(
                                        child: SizedBox(
                                          height: 115.h,
                                          width: 115.w,
                                          child: AppNetworkImage(
                                            imageUrl:
                                                '${Urls.mediaUrl}${profileState.userData?.profilePicture}',
                                            fit: BoxFit.cover,
                                            borderRadius:
                                                BorderRadius.circular(100.r),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: SvgImage(
                                            source: SvgAssets.icPerson,
                                            width: 30.w,
                                            color: AppColors.white),
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return S.of(context).nameError;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () async {
                      NavigationService()
                          .navigateTo(EditPhoneOrEmailScreen(
                        isPhoneUpdate: false,
                      ))
                          .then((value) async {
                        // await profileCubit.getUserProfile();
                        profileCubit.initEditProfileFields(null);
                      });
                    },
                    child: IgnorePointer(
                      ignoring: true,
                      child: CustomTextField(
                        readOnly: true,
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
                    ),
                  ),
                  16.h.s,
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      NavigationService()
                          .navigateTo(EditPhoneOrEmailScreen(
                        isPhoneUpdate: true,
                      ))
                          .then(
                        (value) async {
                          profileCubit.initEditProfileFields(null);
                          // await profileCubit.getUserProfile();
                        },
                      );
                    },
                    child: IgnorePointer(
                      ignoring: true,
                      child: AppIntlPhoneField(
                        key: ValueKey(
                            profileState.phoneNumber?.completeNumber ?? ""),
                        readOnly: true,
                        controller: profileState.phoneController,
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
                        initialCountryCode:
                            profileState.userData?.countryISOCode,
                        initialValue: (profileState.userData?.phone ?? "")
                                .isEmpty
                            ? null
                            : "${profileState.userData?.countryCode ?? ""}${profileState.userData?.phone ?? ""}",
                        style:
                            TextStyle(fontSize: 16.sp, color: AppColors.white),
                        dropdownTextStyle:
                            TextStyle(fontSize: 16.sp, color: AppColors.white),
                        decoration: InputDecoration(
                          hintText: S.of(context).phonePlaceholder,
                          hintStyle: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.textPlaceHolder,
                          ),
                        ),
                        dropdownIcon: Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.white, // Custom color
                        ),
                        pickerDialogStyle: PickerDialogStyle(
                          searchFieldInputDecoration: InputDecoration(
                            hintText: S.of(context).searchCountry,
                            hintStyle: TextStyle(
                                color: AppColors.white), // Hint text color
                            fillColor: AppColors
                                .darkInputFill, // Background color if needed
                          ),
                        ),
                        autovalidateMode: AutovalidateMode.disabled,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ),
                  16.h.s,
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
                      } else if (!Utils.isValidUsername(value.trim())) {
                        // Utils.showSnackBar(
                        //     context, S.current.usernameInvalidCharacters);
                        return S.current.enterValidUsername;
                      } else if (profileState.userIdErrorMessage != null) {
                        return profileState.userIdErrorMessage;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
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
                              return null;

                              // if (value == null || value.isEmpty) {
                              //   return AppConstants.aboutYouError;
                              // }
                              // return null;
                            },
                          ),
                        ),
                      ],
                    ),
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
