// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import 'package:intl_phone_field/phone_number.dart';
// import 'package:two_one_two_messenger/extension/bloc.dart';
// import 'package:two_one_two_messenger/extension/sizebox.dart';
// import 'package:two_one_two_messenger/generated/l10n.dart';
// import 'package:two_one_two_messenger/utils/extensions.dart';
// import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';
// import 'package:two_one_two_messenger/widgets/intl_widget.dart';

// import '../cubit/send_otp_cubit.dart';
// import '../cubit/send_otp_state.dart';
// import '../database/local_db.dart';
// import '../utils/navigation.dart';
// import '../widgets/buttons.dart';
// import '../utils/colors.dart';
// import '../utils/constants.dart';
// import '../utils/text_style.dart';
// import '../widgets/svg_images.dart';
// import '../widgets/text_fields.dart';
// import '../utils/utils.dart';
// import 'otp_verify_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   LoginFormState createState() => LoginFormState();
// }

// class LoginFormState extends State<LoginScreen> {
//   final TextEditingController _emailController = TextEditingController();

//   final TextEditingController _phoneController = TextEditingController();

//   // final _formKey = GlobalKey<FormState>();
//   // final _phoneFormKey = GlobalKey<FormState>();
//   final dbHelper = DatabaseHelper();
//   // bool _agreedToTerms = false;
//   @override
//   void initState() {
//     onInit();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     // _phoneController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: Padding(
//         padding: EdgeInsets.only(
//             left: 32.w, right: 32.w, bottom: Platform.isIOS ? 32.h : 16.h),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             BlocBuilder<SendOtpCubit, SendOtpState>(
//                 builder: (contextSendOtp, sendOtpState) {
//               return GestureDetector(
//                 behavior: HitTestBehavior.translucent,
//                 onTap: () {
//                   sendOtpCubit.onAgreedToTerms(!sendOtpState.agreedToTerms);

//                   // });
//                 },
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Align(
//                       alignment: Alignment.topCenter,
//                       child: Container(
//                         width: 22.h,
//                         height: 22.h,
//                         padding: const EdgeInsets.all(
//                             4), // Inner padding for the checkmark
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: sendOtpState.agreedToTerms
//                               ? AppColors.primaryColor
//                               : Colors.transparent,
//                           border: Border.all(
//                               color: sendOtpState.agreedToTerms
//                                   ? Colors.transparent
//                                   : AppColors.primaryColor,
//                               width: 1),
//                           // borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: sendOtpState.agreedToTerms
//                             ? const FittedBox(
//                                 child: Icon(Icons.check,
//                                     size: 22, color: AppColors.white),
//                               )
//                             : null,
//                       ),

//                       // Transform.scale(
//                       //   scale: 1.2,
//                       //   child: Checkbox.adaptive(
//                       //     splashRadius: 0,
//                       //     // materialTapTargetSize:
//                       //     //     MaterialTapTargetSize.shrinkWrap,
//                       //     visualDensity: VisualDensity.compact,
//                       //     checkColor: AppColors.white,

//                       //     activeColor: AppColors.buttonColor,
//                       //     value: sendOtpState.agreedToTerms,
//                       //     shape: CircleBorder(),
//                       //     onChanged: (bool? value) {
//                       //       sendOtpCubit
//                       //           .onAgreedToTerms(!sendOtpState.agreedToTerms);
//                       //     },
//                       //   ),
//                       // ),
//                     ),
//                     10.s,
//                     Expanded(
//                       child: Text(
//                         "I understand my email/phone is used only for account setup. It will not be used for ads or shared with third parties.",
//                         style: AppTextStyles.regular(fontSize: 10.sp),
//                         softWrap: true,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }),
//             10.h.s,
//             // CheckboxListTile(
//             //   value: _agreedToTerms,
//             //   activeColor: AppColors.primaryColor,
//             //   onChanged: (bool? value) {
//             //     setState(() {
//             //       _agreedToTerms = value ?? false;
//             //     });
//             //   },

//             //   title: Text(
//             //     "I understand my email/phone is used only for account setup. It will not be used for ads or shared with third parties.",
//             //     style: AppTextStyles.regular(),
//             //     softWrap: true,
//             //   ),
//             // ),
//             BlocBuilder<SendOtpCubit, SendOtpState>(
//                 builder: (contextSendOtp, sendOtpState) {
//               return CustomButton(
//                 onPressed: () async {
//                   if (!sendOtpState.agreedToTerms) {
//                     _showError(
//                         "You must accept that your information will only be used for account setup and not for advertising.");
//                     return;
//                   }

//                   String email = _emailController.text.trim();
//                   PhoneNumber? phoneNumberState =
//                       contextSendOtp.read<SendOtpCubit>().state.phoneNumber;
//                   showMessage("State ==> ${phoneNumberState?.number}");
//                   if (email.isNotEmpty &&
//                       phoneNumberState != null &&
//                       phoneNumberState.number.isNotEmpty) {
//                     _showError(
//                         S.of(context).pleaseFillOnlyOneFieldEmailOrPhone);
//                     return;
//                   }

//                   if (email.isEmpty &&
//                       phoneNumberState == null &&
//                       (phoneNumberState?.number ?? "").isEmpty) {
//                     _showError(S.of(context).pleaseEnterEmailOrPhone);
//                     return;
//                   }

//                   // PhoneNumber? phoneNumberState =
//                   //     context.read<PhoneInputCubit>().state;

//                   if (email.isNotEmpty) {
//                     if (!email.isValidEmail(
//                       (message) {
//                         _showError(message);
//                       },
//                     )) {
//                       return;
//                     } else {
// // showCommonAlertDialog(context: context, title: title, subTitle: subTitle, submitBtnText: submitBtnText, onSubmit: S.of(context).continues)

//                       await contextSendOtp.read<SendOtpCubit>().sendOtp(
//                         _emailController.text,
//                         context,
//                         callback: () async {
//                           // Utils.showSnackBar(
//                           //     context, 'Please use static otp: 123456',
//                           //     seconds: 6);
//                           await NavigationService().navigateTo(OtpVerifyScreen(
//                             email: _emailController.text,
//                           ));
//                         },
//                       );
//                       return;
//                     }

//                     // if (_formKey.currentState?.validate() ?? false) {
//                     //   _formKey.currentState?.save();

//                     //   await contextSendOtp.read<SendOtpCubit>().sendOtp(
//                     //     _emailController.text,
//                     //     context,
//                     //     callback: () async {
//                     //       // Utils.showSnackBar(
//                     //       //     context, 'Please use static otp: 123456',
//                     //       //     seconds: 6);
//                     //       await NavigationService().navigateTo(OtpVerifyScreen(
//                     //         email: _emailController.text,
//                     //       ));
//                     //     },
//                     //   );
//                     //   return;
//                     // }
//                   } else if (phoneNumberState != null &&
//                       phoneNumberState.number.isNotEmpty) {
//                     // if (_formKey.currentState?.validate() ?? false) {
//                     //   _formKey.currentState?.save();
//                     final phoneNumber = phoneNumberState.number;
//                     final countryCode = phoneNumberState.countryCode;
//                     final countryISOCode = phoneNumberState.countryISOCode;
//                     // showMessage("phoneNumberState == ${phoneNumberState.toString()}");
//                     await contextSendOtp.read<SendOtpCubit>().sendPhoneOtp(
//                       "$countryCode$phoneNumber",
//                       context,
//                       callback: (verificationId) async {
//                         if (verificationId.isNotEmpty) {
//                           await NavigationService().navigateTo(OtpVerifyScreen(
//                             phoneNumber: phoneNumber,
//                             countryISOCode: countryISOCode,
//                             countryCode: countryCode,
//                             verificationId: verificationId,
//                           ));
//                           contextSendOtp.read<SendOtpCubit>().setSuceessState();
//                         }
//                       },
//                     );
//                     // }
//                     return;
//                   } else {
//                     // _emailFormKey.currentState?.validate();
//                     // _phoneFormKey.currentState?.validate();
//                   }
//                 },
//                 child: () {
//                   if (sendOtpState.sendOtpLoadingState ==
//                       LoadingState.loading) {
//                     return const CustomLoadingWidget(color: AppColors.white);
//                   }
//                   // else if (sendOtpState is SendOtpSuccess) {
//                   //   return const Icon(
//                   //     Icons.check,
//                   //     color: AppColors.white,
//                   //   );
//                   // }
//                   else if (sendOtpState.sendOtpLoadingState ==
//                       LoadingState.error) {
//                     return Text(
//                       S.of(context).loginButtonTextRe,
//                       style: AppTextStyles.medium(
//                         fontSize: 16.sp,
//                         color: AppColors.white,
//                       ),
//                     );
//                   } else {
//                     return Text(
//                       S.of(context).logIn,
//                       style: AppTextStyles.medium(
//                         fontSize: 16.sp,
//                         color: AppColors.white,
//                       ),
//                     );
//                   }
//                 }(),
//               );
//             }),
//             SizedBox(
//               height: 16.h,
//             ),
//           ],
//         ),
//       ),
//       body: BlocBuilder<SendOtpCubit, SendOtpState>(
//           builder: (contextSendOtp, sendOtpState) {
//         return Padding(
//           padding: EdgeInsets.symmetric(horizontal: 24.w),
//           child: SafeArea(
//             child:
//                 // Form(
//                 //   key: /*(sendOtpState is EmailValid && sendOtpState.isEmailValid) ? null : */
//                 //       _formKey,
//                 // child:
//                 SingleChildScrollView(
//               child: Column(
//                 children: [
//                   Column(
//                     children: [
//                       SizedBox(height: 16.h),
//                       Text(
//                         S.of(context).logIn,
//                         style: AppTextStyles.medium(
//                           fontSize: 22.sp,
//                         ),
//                       ),
//                       SizedBox(height: 28.h),
//                       Text(
//                         S.of(context).lblLoginText,
//                         style: AppTextStyles.bold(
//                           fontSize: 26.sp,
//                         ),
//                       ),
//                       SizedBox(height: 8.h),
//                       Text(
//                         S.of(context).lblLoginSubtitleText,
//                         style: AppTextStyles.regular(
//                           fontSize: 11.sp,
//                         ),
//                       ),
//                       SizedBox(height: 32.h),
//                       CustomTextField(
//                         controller: _emailController,
//                         label: S.of(context).emailPlaceHolder,
//                         textInputAction: TextInputAction.done,
//                         maxLines: 1,
//                         prefixIcon: SvgImage(
//                           source: SvgAssets.icEmail,
//                           fit: BoxFit.scaleDown,
//                           color: AppColors.white,
//                         ),
//                         keyboardType: TextInputType.emailAddress,
//                         onChanged: (value) {
//                           if (value == "") {
//                             contextSendOtp
//                                 .read<SendOtpCubit>()
//                                 .setPhoneValid(false);
//                           } else {
//                             contextSendOtp
//                                 .read<SendOtpCubit>()
//                                 .setPhoneValid(true);
//                           }
//                           contextSendOtp
//                               .read<SendOtpCubit>()
//                               .updatePhoneNumber(null);
//                           _phoneController.clear();
//                         },
//                         validator: (value) {
//                           // showMessage("email validator==>$value");
//                           // if (value == null || value.isEmpty) {
//                           //   return AppConstants.emailError;
//                           //   // if(sendOtpState is EmailValid && !sendOtpState.isEmailValid) {
//                           //   //   return AppConstants.emailError;
//                           //   // } else  {
//                           //   //   return AppConstants.emailError;
//                           //   // }
//                           // }
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: 22.h),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Divider(
//                               indent: 20.w,
//                               endIndent: 20.w,
//                               color: Colors.grey,
//                               thickness: 1,
//                             ),
//                           ),
//                           Padding(
//                             padding:
//                                 const EdgeInsets.symmetric(horizontal: 8.0),
//                             child: Text(
//                               S.of(context).or,
//                               style: AppTextStyles.bold(
//                                 fontSize: 12.sp,
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             child: Divider(
//                               indent: 20.w,
//                               endIndent: 20.w,
//                               color: Colors.grey,
//                               thickness: 1,
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 22.h),
//                       AppIntlPhoneField(
//                         controller: _phoneController,
//                         onChanged: (value) {
//                           contextSendOtp
//                               .read<SendOtpCubit>()
//                               .updatePhoneNumber(value);
//                           _emailController.clear();
//                           // if(value.number.isEmpty) {
//                           //   contextSendOtp
//                           //       .read<SendOtpCubit>()
//                           //       .setEmailValid(false);
//                           // } else {
//                           //   contextSendOtp
//                           //       .read<SendOtpCubit>()
//                           //       .setEmailValid(false);
//                           // }
//                         },
//                         onCountryChanged: (value) {
//                           _emailController.clear();
//                           PhoneNumber? phoneNumber;
//                           showMessage(
//                               "country ${value.code}   ${value.dialCode}  region ${value.regionCode}");
//                           showMessage(
//                               "country phone   ${sendOtpState.phoneNumber?.countryCode}   ");
//                           phoneNumber = PhoneNumber(
//                               countryISOCode: value.code ?? "GB",
//                               countryCode: "+${value.dialCode}" ?? "+44",
//                               number: sendOtpState.phoneNumber?.number ?? "");

//                           contextSendOtp
//                               .read<SendOtpCubit>()
//                               .updateCountry(value, phoneNumber);
//                         },
//                         initialCountryCode: 'GB',
//                         dropdownTextStyle:
//                             TextStyle(fontSize: 16.sp, color: AppColors.white),
//                         style:
//                             TextStyle(fontSize: 16.sp, color: AppColors.white),
//                         decoration: InputDecoration(
//                             hintText: S.of(context).phonePlaceholder,
//                             hintStyle: TextStyle(
//                               fontSize: 16.sp,
//                               color: AppColors.textPlaceHolder,
//                             )),
//                         // showCountryFlag: false,
//                         textInputAction: TextInputAction.done,
//                         dropdownIcon: Icon(
//                           Icons.arrow_drop_down,
//                           color: AppColors.white, // Custom color
//                         ),
//                         pickerDialogStyle: PickerDialogStyle(
//                           backgroundColor: AppColors.dialogBg,
//                           countryNameStyle: AppTextStyles.regular(),
//                           countryCodeStyle: AppTextStyles.regular()
//                               .copyWith(fontWeight: FontWeight.bold),
//                           searchFieldInputDecoration: InputDecoration(
//                             hintText: S.of(context).searchCountry,
//                             hintStyle: TextStyle(color: AppColors.white),
//                             // Hint text color
//                             fillColor: AppColors
//                                 .darkInputFill, // Background color if needed
//                           ),
//                         ),

//                         autovalidateMode: AutovalidateMode.disabled,

//                         // (sendOtpState.isPhoneValid)
//                         //     ? AutovalidateMode.onUserInteraction
//                         //     : AutovalidateMode.always,
//                         inputFormatters: [
//                           FilteringTextInputFormatter.digitsOnly,
//                         ],
//                         // validator: (value) {
//                         //   if (value?.number.isNotEmpty ?? false) {
//                         //     return Future.value(null);
//                         //   }
//                         //   if (!sendOtpState.isPhoneValid) {
//                         //     return Future.value(AppConstants.phoneError);
//                         //   }
//                         //   //  else if (sendOtpState is SendOtpInitial) {
//                         //   //   return Future.value(AppConstants.phoneError);
//                         //   // }
//                         //   else {
//                         //     return Future.value(null);
//                         //   }
//                         // },
//                       ),
//                       // BlocBuilder<PhoneInputCubit, PhoneNumber?>(
//                       //     builder: (contextPhone, phoneNumberState) {
//                       //   return Form(
//                       //     key: _phoneFormKey,
//                       //     child: IntlPhoneField(
//                       //       onChanged: (value) {
//                       //         contextPhone
//                       //             .read<PhoneInputCubit>()
//                       //             .updatePhoneNumber(value);
//                       //       },
//                       //       onCountryChanged: (value) {
//                       //         context.read<PhoneInputCubit>().updateCountry(value);
//                       //       },
//                       //       initialCountryCode: 'IN',
//                       //       style: TextStyle(
//                       //           fontSize: 16.sp,
//                       //           color: AppColors.white
//                       //               ),
//                       //       decoration: InputDecoration(
//                       //           hintText: AppConstants.phonePlaceholder,
//                       //           hintStyle: TextStyle(
//                       //             fontSize: 16.sp,
//                       //             color: AppColors.textPlaceHolder,
//                       //           )),
//                       //       // showCountryFlag: false,
//                       //       textInputAction: TextInputAction.done,
//                       //       dropdownIcon: Icon(
//                       //         Icons.arrow_drop_down,
//                       //         color: AppColors.white, // Custom color
//                       //       ),
//                       //       pickerDialogStyle: PickerDialogStyle(
//                       //         searchFieldInputDecoration: InputDecoration(
//                       //           hintText: AppConstants.searchCountry,
//                       //           hintStyle: TextStyle(
//                       //               color: AppColors.white),
//                       //           // Hint text color
//                       //           fillColor: AppColors.darkInputFill, // Background color if needed
//                       //         ),
//                       //       ),
//                       //       autovalidateMode: (sendOtpState is PhoneValid &&
//                       //               sendOtpState.isPhoneValid)
//                       //           ? AutovalidateMode.disabled
//                       //           : AutovalidateMode.always,
//                       //       inputFormatters: [
//                       //         FilteringTextInputFormatter.digitsOnly,
//                       //       ],
//                       //       validator: (value) {
//                       //         if (value?.number.isNotEmpty ?? false) {
//                       //           return Future.value(null);
//                       //         }
//                       //         return Future.value(AppConstants.phoneError);
//                       //       },
//                       //     ),
//                       //   );
//                       // }),
//                       SizedBox(height: 22.h),

//                       ///TODO NOTE: SignIn With google and facebook
//                       // Row(
//                       //   children: [
//                       //     Expanded(
//                       //       child: Divider(
//                       //         indent: 20.w,
//                       //         endIndent: 20.w,
//                       //         color: Colors.grey,
//                       //         thickness: 1,
//                       //       ),
//                       //     ),
//                       //     Padding(
//                       //       padding:
//                       //           const EdgeInsets.symmetric(horizontal: 8.0),
//                       //       child: Text(
//                       //         S.of(context).or,
//                       //         style: AppTextStyles.bold(
//                       //           fontSize: 12.sp,
//                       //         ),
//                       //       ),
//                       //     ),
//                       //     Expanded(
//                       //       child: Divider(
//                       //         indent: 20.w,
//                       //         endIndent: 20.w,
//                       //         color: Colors.grey,
//                       //         thickness: 1,
//                       //       ),
//                       //     ),
//                       //   ],
//                       // ),
//                       // SizedBox(height: 22.h),

//                       ///TODO NOTE: SignIn With google and facebook

//                       // Padding(
//                       //   padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                       //   child: Row(
//                       //     children: [
//                       //       BlocBuilder<SendOtpCubit, SendOtpState>(
//                       //           builder: (contextSendOtp, sendOtpState) {
//                       //         return Expanded(
//                       //           child: InkWell(
//                       //             onTap: () async {
//                       //               if (!sendOtpState.agreedToTerms) {
//                       //                 _showError(
//                       //                     "You must accept that your information will only be used for account setup and not for advertising.");
//                       //                 return;
//                       //               }
//                       //               await dbHelper.deleteLoginData();
//                       //               OAuthCredential? credential =
//                       //                   await contextSendOtp
//                       //                       .read<SendOtpCubit>()
//                       //                       .signInWithGoogle(context);

//                       //               if (credential != null) {
//                       //                 final userCredential = await FirebaseAuth
//                       //                     .instance
//                       //                     .signInWithCredential(credential);

//                       //                 if (userCredential.user != null) {
//                       //                   String? fcmToken =
//                       //                       await Utils.fetchToken();
//                       //                   showMessage(
//                       //                       "user credential == ${userCredential.user}");
//                       //                   await context
//                       //                       .read<OtpVerifyCubit>()
//                       //                       .socialSignInVerify(
//                       //                         email:
//                       //                             userCredential.user?.email ??
//                       //                                 '',
//                       //                         provider: SignInProvider.google,
//                       //                         providerId:
//                       //                             userCredential.user?.uid ??
//                       //                                 "",
//                       //                         fcmToken: fcmToken ?? '',
//                       //                         context: context,
//                       //                         name: userCredential
//                       //                                 .user?.displayName ??
//                       //                             "",
//                       //                         photoUrl: userCredential
//                       //                                 .user?.photoURL ??
//                       //                             "",
//                       //                         phone: userCredential
//                       //                                 .user?.phoneNumber ??
//                       //                             "",
//                       //                         callback: () async {
//                       //                           // await NavigationService()
//                       //                           //     .clearAndNavigateTo(HomeScreen());
//                       //                         },
//                       //                       );
//                       //                 }
//                       //               }
//                       //             },
//                       //             child: Container(
//                       //               height: 45.h,
//                       //               decoration: BoxDecoration(
//                       //                 color: AppColors.white,
//                       //                 borderRadius: BorderRadius.circular(8),
//                       //               ),
//                       //               child: Row(
//                       //                 mainAxisAlignment:
//                       //                     MainAxisAlignment.center,
//                       //                 crossAxisAlignment:
//                       //                     CrossAxisAlignment.center,
//                       //                 children: [
//                       //                   Image.asset(
//                       //                     ImgAssets.icGoogle,
//                       //                     width: 20.w,
//                       //                     height: 20.h,
//                       //                   ),
//                       //                   SizedBox(width: 10.w),
//                       //                   Text(
//                       //                     S.of(context).googleText,
//                       //                     style: AppTextStyles.medium(
//                       //                       fontSize: 14.sp,
//                       //                       color: AppColors.black,
//                       //                     ),
//                       //                   ),
//                       //                 ],
//                       //               ),
//                       //             ),
//                       //           ),
//                       //         );
//                       //       }),
//                       //       SizedBox(width: 20.w),
//                       //       BlocBuilder<SendOtpCubit, SendOtpState>(
//                       //           builder: (contextSendOtp, sendOtpState) {
//                       //         return Expanded(
//                       //           child: InkWell(
//                       //             onTap: () async {
//                       //               if (!sendOtpState.agreedToTerms) {
//                       //                 _showError(
//                       //                     "You must accept that your information will only be used for account setup and not for advertising.");
//                       //                 return;
//                       //               }
//                       //               await dbHelper.deleteLoginData();
//                       //               OAuthCredential? credential =
//                       //                   await contextSendOtp
//                       //                       .read<SendOtpCubit>()
//                       //                       .signInWithFacebook(context);

//                       //               if (credential != null) {
//                       //                 final userCredential = await FirebaseAuth
//                       //                     .instance
//                       //                     .signInWithCredential(credential);

//                       //                 showMessage(
//                       //                     "credential ==> ${userCredential}");
//                       //                 return;

//                       //                 if (userCredential.user != null) {
//                       //                   String? fcmToken =
//                       //                       await Utils.fetchToken();

//                       //                   await context
//                       //                       .read<OtpVerifyCubit>()
//                       //                       .socialSignInVerify(
//                       //                         email:
//                       //                             userCredential.user?.email ??
//                       //                                 '',
//                       //                         provider: SignInProvider.facebook,
//                       //                         providerId:
//                       //                             userCredential.user?.uid ??
//                       //                                 "",
//                       //                         fcmToken: fcmToken ?? '',
//                       //                         context: context,
//                       //                         name: userCredential
//                       //                                 .user?.displayName ??
//                       //                             "",
//                       //                         photoUrl: userCredential
//                       //                                 .user?.photoURL ??
//                       //                             "",
//                       //                         phone: userCredential
//                       //                                 .user?.phoneNumber ??
//                       //                             "",
//                       //                         callback: () async {
//                       //                           // await NavigationService()
//                       //                           //     .clearAndNavigateTo(HomeScreen());
//                       //                         },
//                       //                       );
//                       //                 }
//                       //               }
//                       //             },
//                       //             child: Container(
//                       //               height: 45.h,
//                       //               decoration: BoxDecoration(
//                       //                 color: AppColors.white,
//                       //                 borderRadius: BorderRadius.circular(8),
//                       //               ),
//                       //               child: Row(
//                       //                 mainAxisAlignment:
//                       //                     MainAxisAlignment.center,
//                       //                 crossAxisAlignment:
//                       //                     CrossAxisAlignment.center,
//                       //                 children: [
//                       //                   Image.asset(
//                       //                     ImgAssets.icFacebook,
//                       //                     width: 20.w,
//                       //                     height: 20.h,
//                       //                   ),
//                       //                   SizedBox(width: 10.w),
//                       //                   Text(
//                       //                     S.of(context).facebookText,
//                       //                     style: AppTextStyles.medium(
//                       //                       fontSize: 14.sp,
//                       //                       color: AppColors.black,
//                       //                     ),
//                       //                   ),
//                       //                 ],
//                       //               ),
//                       //             ),
//                       //           ),
//                       //         );
//                       //       })
//                       //     ],
//                       //   ),
//                       // ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             // ),
//           ),
//         );
//       }),
//     );
//   }

//   void _showError(String message) {
//     Utils.showSnackBar(context, message);
//   }

//   Future<void> onInit() async {
//     await dbHelper.deleteLoginData();
//   }
// }
