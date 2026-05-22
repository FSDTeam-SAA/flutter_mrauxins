import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:two_one_two_messenger/GoogleAds/BannerAds/BannerAdManager.dart';
import 'package:two_one_two_messenger/cubit/profile_cubit.dart';
import 'package:two_one_two_messenger/cubit/profile_state.dart';
import 'package:two_one_two_messenger/cubit/send_otp_cubit.dart';
import 'package:two_one_two_messenger/database/local_db.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/screens/app_language.dart';
import 'package:two_one_two_messenger/screens/edit_phone_or_email.dart';
import 'package:two_one_two_messenger/screens/login_screen.dart';
import 'package:two_one_two_messenger/screens/notifications_setting.dart';
import 'package:two_one_two_messenger/screens/otp_verify_screen.dart';
import 'package:two_one_two_messenger/screens/primium_purchase_screen.dart';
import 'package:two_one_two_messenger/screens/privacy_security_screen.dart';
import 'package:two_one_two_messenger/services/fcm_service.dart';
import 'package:two_one_two_messenger/services/socket_service.dart';
import 'package:two_one_two_messenger/utils/app_dialoge.dart';
import 'package:two_one_two_messenger/utils/extensions.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/buttons.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';
import '../models/otp_verify.dart';
import '../services/api_client.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/navigation.dart';
import '../utils/text_style.dart';
import '../widgets/network_image.dart';
import '../widgets/svg_images.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isStillYourNumber = true;
  @override
  void initState() {
    onInit();
    super.initState();
  }

  Future<void> onInit() async {
    isStillYourNumber = true;
    await profileCubit.getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    // UserData? user = context.watch<UserDataCubit>().state;
    // showMessage("user --> $user");

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.darkAppBar,
        surfaceTintColor: AppColors.darkAppBar,
        leading: IconButton(
          onPressed: () async {
            await NavigationService().goBack();
          },
          icon: SvgImage(
            source: SvgAssets.icArrowBack,
            width: 20.w,
            color: AppColors.white,
          ),
        ),
        title: const BannerAdManager(),
      ),

      // CommonAppBar(
      //   isBackShow: true,
      //   backgroundColor: AppColors.darkAppBar,
      //   actions: [
      //     IconButton(
      //       icon: SvgImage(
      //           source: SvgAssets.icQrCode,
      //           width: 20.w,
      //           color: AppColors.white),
      //       onPressed: () {
      //         Utils.showSnackBar(context,
      //             "QR Share is currently unavailable as we're finalizing important security updates. Please check back soon");
      //         // NavigationService().navigateTo(EditProfileScreen());
      //       },
      //     ),
      //     // IconButton(
      //     //   icon: SvgImage(
      //     //       source: SvgAssets.icMoreDots,
      //     //       width: 20.w,
      //     //       color: AppColors.white),
      //     //   onPressed: () {},
      //     // ),
      //   ],
      // ),
      bottomNavigationBar: const BannerAdManager(),

      //  Container(
      //   height: 85.h,
      //   constraints: BoxConstraints(maxHeight: 85),
      //   decoration: BoxDecoration(
      //       gradient: LinearGradient(
      //           colors: AppColors.gradientColor,
      //           begin: Alignment.topCenter,
      //           end: Alignment.bottomCenter)),
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Image.asset(
      //         ImgAssets.logo,
      //         height: 36.h,
      //       ),
      //       14.h.s,
      //       Text(
      //         "212 Private Messenger for Android v11.2.2066 Store",
      //         style: AppTextStyles.regular(
      //             fontSize: 12.sp, color: AppColors.white.withAlpha(60)),
      //       )
      //     ],
      //   ),
      // ),

      body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (contextProfile, state) {
        UserData? user = state.userData ?? userDataCubit.state;
        return Column(
          children: [
            SizedBox(
              height: 125.h,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100.h,
                      color: AppColors.darkAppBar,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 16.h, horizontal: 16.w),
                            child: Row(
                              children: [
                                user?.profilePicture != null
                                    ? Container(
                                        width: 48.w,
                                        height: 48.h,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child: AppNetworkImage(
                                          imageUrl:
                                              '${Urls.mediaUrl}${user?.profilePicture}',
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(100.r)),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Container(
                                        width: 48.w,
                                        height: 48.h,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: AppColors.dark,
                                                width: 2.w)),
                                        child: Center(
                                          child: SvgImage(
                                              source: SvgAssets.icPerson,
                                              width: 20.w,
                                              color: AppColors.white),
                                        ),
                                      ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        user?.name ?? user?.userName ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.semiBold(
                                          fontSize: 20.sp,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        user!.isOnline!
                                            ? S.of(context).online
                                            : user.lastSeen?.toCustomFormat() ??
                                                S.of(context).offline,
                                        style: AppTextStyles.regular(
                                          color: AppColors.textColorThird,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                          Divider(
                            color: AppColors.dividerColor,
                            thickness: 2,
                            height: 0.h,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () {
                        NavigationService().navigateTo(EditProfileScreen());
                      },
                      child: CircleAvatar(
                        radius: 32.r,
                        backgroundColor: AppColors.primaryColor,
                        child: SvgImage(
                          source: SvgAssets.icEdit,
                          width: 20.r,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16.w, right: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 4.h,
                        ),
                        Text(
                          S.of(context).account,
                          style: AppTextStyles.medium(
                            fontSize: 18.sp,
                            color: AppColors.purpleText,
                          ),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        buildListTile(
                          text: (user.phone ?? "").isNotEmpty
                              ? '${user.countryCode} ${user.phone}'
                              : S.of(context).noPhoneNumber,
                          subTitle: user.phone != null
                              ? S.of(context).phoneNumber
                              : S
                                  .of(context)
                                  .youCanAddPhoneNumberInProfileSettings,
                          onTap: () {
                            // NavigationService()
                            //     .navigateTo(EditPhoneOrEmailScreen(
                            //   isPhoneUpdate: true,
                            // ));
                          },
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        buildListTile(
                          text: (user.email ?? "").isNotEmpty
                              ? user.email ?? ""
                              : S.of(context).noEmailAddress,
                          subTitle: user.email != null
                              ? S.of(context).emailAdress
                              : S
                                  .of(context)
                                  .youCanAddAnEmailAddressInProfileSettings,
                          onTap: () {
                            // NavigationService()
                            //     .navigateTo(EditPhoneOrEmailScreen(
                            //   isPhoneUpdate: false,
                            // ));
                          },
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        buildListTile(
                          text: user.userName ?? '',
                          subTitle: S.of(context).username,
                          image: SvgAssets.icQrCode,
                          size: 24.w,
                          onIconTap: () {
                            Utils.showSnackBar(context,
                                "QR Share is currently unavailable as we're finalizing important security updates. Please check back soon");
                          },
                        ),
                        20.s,
                        buildListBioTile(
                          text: S.of(context).bio,
                          subTitle: user.bio ??
                              S.of(context).addFewWordsAboutYourself,
                          // image: SvgAssets.icQrCode,
                          // size: 24.w,
                          // onIconTap: () {},
                        ),
                      ],
                    ),
                  ),
                  20.h.s,
                  // if (isStillYourNumber)
                  //   Padding(
                  //     padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Divider(
                  //           color: AppColors.dividerColor,
                  //           thickness: 2,
                  //           height: 0.h,
                  //         ),
                  //         25.h.s,
                  //         Text(
                  //           S.of(context).isStillYourNumber(
                  //               '${user.countryCode}${user.phone}'),
                  //           style: AppTextStyles.medium(
                  //             fontSize: 18.sp,
                  //             color: AppColors.purpleText,
                  //           ),
                  //         ),
                  //         20.s,
                  //         Text(
                  //           S.of(context).lblKeepYourNumberUptoDate,
                  //           style: AppTextStyles.regular(
                  //             fontSize: 16.sp,
                  //           ),
                  //         ),
                  //         30.s,
                  //         Row(
                  //           children: [
                  //             Expanded(
                  //               child: CustomButton(
                  //                   onPressed: () async {
                  //                     // setState(() {
                  //                     //   isStillYourNumber = false;
                  //                     // });
                  //                     String phoneNumber = '';
                  //                     String countryCode = '';
                  //                     String countryISOCode = '';

                  //                     if (state.phoneNumber != null &&
                  //                         state
                  //                             .phoneNumber!.number.isNotEmpty) {
                  //                       phoneNumber = state.phoneNumber!.number;
                  //                       countryCode =
                  //                           state.phoneNumber!.countryCode;
                  //                       countryISOCode =
                  //                           state.phoneNumber!.countryISOCode;
                  //                     } else {
                  //                       // Utils.showSnackBar(context, message);
                  //                     }

                  //                     showMessage(
                  //                         'Phone Number --> $phoneNumber');
                  //                     showMessage(
                  //                         'countryCode --> $countryCode');
                  //                     showMessage(
                  //                         'countryISOCode --> $countryISOCode');
                  //                     // return;

                  //                     context.dismissKeyboard();
                  //                     FocusScope.of(context).unfocus();
                  //                     if (state.phoneNumber != null &&
                  //                         state.userData?.phone !=
                  //                             state.phoneNumber?.number) {
                  //                       // context.showLoader();
                  //                       profileCubit.emitSendOtpLoadingState();
                  //                       await context
                  //                           .read<SendOtpCubit>()
                  //                           .sendPhoneOtp(
                  //                         "$countryCode$phoneNumber",
                  //                         context,
                  //                         callback: (verificationId) async {
                  //                           if (verificationId.isNotEmpty) {
                  //                             auth.PhoneAuthCredential? result =
                  //                                 await NavigationService()
                  //                                     .navigateTo(
                  //                                         OtpVerifyScreen(
                  //                               phoneNumber: phoneNumber ?? '',
                  //                               countryISOCode:
                  //                                   countryISOCode ?? '',
                  //                               countryCode: countryCode ?? '',
                  //                               verificationId: verificationId,
                  //                               isEditProfile: true,
                  //                             ));

                  //                             context.dismissKeyboard();
                  //                             if (result != null) {
                  //                               Utils.showSnackBar(
                  //                                   context,
                  //                                   AppConstants
                  //                                       .otpVerifySuccess,
                  //                                   seconds: 2);
                  //                               context
                  //                                   .read<ProfileCubit>()
                  //                                   .setData(result);

                  //                               AppPreference.setPhoneVerify();
                  //                               // await profileCubit
                  //                               //     .updatePhoneNumberProfile(
                  //                               //   phone: phoneNumber,
                  //                               //   countryISOCode:
                  //                               //       countryISOCode,
                  //                               //   countryCode: countryCode,
                  //                               //   context: context,
                  //                               //   callback: (response) async {
                  //                               //     // user = response.data;

                  //                               //     // context.read<PhoneInputCubit>().clearState();
                  //                               //     // await context.read<UserDataCubit>().loadUserData();
                  //                               //     Utils.showSnackBar(
                  //                               //         context,
                  //                               //         AppConstants
                  //                               //             .lblUpdateProfile,
                  //                               //         seconds: 2);
                  //                               //   },
                  //                               // );
                  //                             } else {
                  //                               // Utils.showSnackBar(context,
                  //                               //     AppConstants.pleaseTryAgainTxt,
                  //                               //     seconds: 2);
                  //                             }
                  //                           }
                  //                         },
                  //                       );
                  //                     }
                  //                   },
                  //                   child: Text(
                  //                     AppConstants.yes,
                  //                     style: AppTextStyles.medium(
                  //                       fontSize: 16.sp,
                  //                       color: AppColors.white,
                  //                     ),
                  //                   )),
                  //             ),
                  //             10.s,
                  //             Expanded(
                  //               child: CustomButton(
                  //                   onPressed: () {
                  //                     NavigationService()
                  //                         .navigateTo(EditPhoneOrEmailScreen(
                  //                       isPhoneUpdate: true,
                  //                     ));
                  //                   },
                  //                   child: Text(
                  //                     AppConstants.no,
                  //                     style: AppTextStyles.medium(
                  //                       fontSize: 16.sp,
                  //                       color: AppColors.white,
                  //                     ),
                  //                   )),
                  //             ),
                  //           ],
                  //         )
                  //       ],
                  //     ),
                  //   ),
                  Divider(
                    color: AppColors.dividerColor,
                    thickness: 2,
                    height: 0.h,
                  ),
                  25.h.s,
                  if (AppPreference.shouldShowVerificationPromptForPhone() &&
                      (user.phone ?? "").isNotEmpty)
                    buildPhoneReverify(
                      title: S.of(context).isStillYourNumber(
                          '${user.countryCode}${user.phone}'),
                      subTitle: S.of(context).lblKeepYourNumberUptoDate,
                      onYes: () async {
                        // setState(() {
                        //   isStillYourNumber = false;
                        // });
                        String phoneNumber = user.countryCode ?? "";
                        String countryCode = user.phone ?? "";
                        String countryISOCode = user.countryISOCode ?? "";

                        if (state.phoneNumber != null &&
                            state.phoneNumber!.number.isNotEmpty) {
                          phoneNumber = state.phoneNumber!.number;
                          countryCode = state.phoneNumber!.countryCode;
                          countryISOCode = state.phoneNumber!.countryISOCode;
                        } else {
                          profileCubit.updatePhoneNumber(PhoneNumber(
                              countryISOCode: countryISOCode,
                              countryCode: countryCode,
                              number: phoneNumber));
                        }

                        // return;

                        context.dismissKeyboard();
                        FocusScope.of(context).unfocus();
                        if (state.phoneNumber != null &&
                            phoneNumber.isNotEmpty) {
                          // context.showLoader();
                          showMessage('Phone Number --> $phoneNumber');
                          showMessage('countryCode --> $countryCode');
                          showMessage('countryISOCode --> $countryISOCode');
                          profileCubit.emitSendOtpLoadingState(
                              isLoadEmail: false, isLoadPhone: true);
                          await context.read<SendOtpCubit>().sendPhoneOtp(
                            "$countryCode$phoneNumber",
                            context,
                            callback: (verificationId) async {
                              showMessage('Phone Number 2222--> $phoneNumber');
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
                                  Utils.showSnackBar(context,
                                      S.current.phoneVerifiedSuccessfully,
                                      seconds: 2);
                                  context.read<ProfileCubit>().setData(result);

                                  AppPreference.setPhoneVerify();
                                  // await profileCubit
                                  //     .updatePhoneNumberProfile(
                                  //   phone: phoneNumber,
                                  //   countryISOCode:
                                  //       countryISOCode,
                                  //   countryCode: countryCode,
                                  //   context: context,
                                  //   callback: (response) async {
                                  //     // user = response.data;

                                  //     // context.read<PhoneInputCubit>().clearState();
                                  //     // await context.read<UserDataCubit>().loadUserData();
                                  //     Utils.showSnackBar(
                                  //         context,
                                  //         AppConstants
                                  //             .lblUpdateProfile,
                                  //         seconds: 2);
                                  //   },
                                  // );
                                } else {
                                  // Utils.showSnackBar(context,
                                  //     AppConstants.pleaseTryAgainTxt,
                                  //     seconds: 2);
                                }
                              }
                            },
                          );
                          // profileCubit.emitSendOtpSucessState();
                        }
                        // profileCubit.emitSendOtpSucessState();
                      },
                      onNo: () {
                        NavigationService().navigateTo(EditPhoneOrEmailScreen(
                          isPhoneUpdate: true,
                        ));
                      },
                    ),
                  if (AppPreference.shouldShowVerificationPromptForEmail() &&
                      (user.email ?? "").isNotEmpty)
                    buildEmailReverify(
                      title: S
                          .of(context)
                          .isStillYourEmailAddress(user.email ?? ""),
                      subTitle: S.of(context).lblKeepYourEmailAddressUptoDate,
                      onYes: () async {
                        final email = (user.email ?? "").trim();
                        if (email.isValidEmail(
                          (message) => Utils.showSnackBar(context, message),
                        )) {
                          // profileCubit.emitSendOtpLoadingState(isLoadPhone: false, isLoadEmail: true);
                          await profileCubit.sendOtpForEmailChange(
                            email,
                            context,
                            callback: () async {
                              await NavigationService()
                                  .navigateTo(OtpVerifyScreen(
                                email: email,
                                isEditProfile: true,
                                infoMessage:
                                    S.current.emailVerifiedSuccessfully,
                              ));
                            },
                          );
                        }
                      },
                      onNo: () {
                        NavigationService().navigateTo(EditPhoneOrEmailScreen(
                          isPhoneUpdate: false,
                        ));
                      },
                    ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).sSettings,
                          style: AppTextStyles.medium(
                            fontSize: 18.sp,
                            color: AppColors.purpleText,
                          ),
                        ),
                        20.s,
                        buildSettingsListTile(
                            text: S.of(context).notificationsSettings,
                            icon: SvgAssets.notificationFill,
                            onTap: () {
                              NavigationService()
                                  .navigateTo(NotificationsSetting());
                            }),
                        28.h.s,
                        buildSettingsListTile(
                          text: S.of(context).languages,
                          icon: SvgAssets.language,
                          onTap: () {
                            NavigationService().navigateTo(AppLanguagePage());
                          },
                        ),
                        28.h.s,
                        buildSettingsListTile(
                          text: S.of(context).privacyAndSecurity,
                          icon: SvgAssets.passwordLock,
                          onTap: () {
                            NavigationService()
                                .navigateTo(PrivacyAndSecuritySetting());
                          },
                        ),
                        28.h.s,
                        buildSettingsListTile(
                            text: S.of(context).upgradeToPremium,
                            icon: SvgAssets.icSettings,
                            onTap: () {
                              NavigationService().navigateTo(PremiumScreen());
                            }),
                        28.h.s,
                        buildSettingsListTile(
                          text: S.of(context).sLogout,
                          icon: SvgAssets.icLogout,
                          onTap: () async {
                            showCommonLogOutDialog(
                              context: context,
                              title: S.of(context).sLogout,
                              subTitle: S.of(context).sLogoutMessage,
                              icon: SvgAssets.icLogout,
                              onSubmit: () async {
                                final token = await FCMService().getFCMToken();
                                String userId = user?.sId ?? '';
                                if (userId.isNotEmpty) {
                                  SocketService().logout({"userId": userId});
                                }
                                if ((token ?? "").isNotEmpty) {
                                  await context
                                      .read<SendOtpCubit>()
                                      .deleteToken(
                                    userId,
                                    token ?? '',
                                    context,
                                    callback: (response) async {
                                      await profileCubit.dbHelper
                                          .deleteLoginData();
                                      await profileCubit.dbHelper
                                          .saveKeepLoggedIn(false, "", "");

                                      ///TODO NOTE: SignIn With google and facebook
                                      // await GoogleSignIn().signOut();
                                      await sendOtpCubit.resetSendOtpState();
                                      NavigationService()
                                          .clearAndNavigateTo(LoginScreen());
                                    },
                                  );
                                } else {
                                  await profileCubit.dbHelper.deleteLoginData();
                                  await profileCubit.dbHelper
                                      .saveKeepLoggedIn(false, "", "");
                                  await sendOtpCubit.resetSendOtpState();

                                  ///TODO NOTE: SignIn With google and facebook
                                  // await GoogleSignIn().signOut();
                                  NavigationService()
                                      .clearAndNavigateTo(LoginScreen());
                                }
                              },
                            );
                          },
                        ),
                        28.h.s,
                        buildSettingsListTile(
                          text: S.of(context).deleteAccount,
                          icon: SvgAssets.icTrash,
                          isForDelete: true,
                          onTap: () async {
                            showCommonLogOutDialog(
                              context: context,
                              color: AppColors.redColor,
                              icon: SvgAssets.icTrash,
                              title: S.of(context).deleteAccount,
                              subTitle: S.of(context).deleteAccountSlogen,
                              onSubmit: () async {
                                await profileCubit.deleteAccount(
                                  context,
                                  callback: () async {},
                                );
                              },
                            );
                          },
                        ),
                        40.h.s
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget buildPhoneReverify(
      {required String title,
      required String subTitle,
      required void Function() onYes,
      required void Function() onNo}) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.medium(
                  fontSize: 18.sp,
                  color: AppColors.purpleText,
                ),
              ),
              20.s,
              Text(
                subTitle,
                style: AppTextStyles.regular(
                  fontSize: 16.sp,
                ),
              ),
              30.s,
              BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (contextProfile, state) {
                return Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                          onPressed: onYes,
                          child: () {
                            if (state.sendOtpLoadingState ==
                                    LoadingState.loading &&
                                state.isPhoneReVerification) {
                              return const CustomLoadingWidget(
                                  color: AppColors.white);
                            } else {
                              return Text(
                                S.of(context).yes,
                                style: AppTextStyles.medium(
                                  fontSize: 16.sp,
                                  color: AppColors.white,
                                ),
                              );
                            }
                          }()),
                    ),
                    10.s,
                    Expanded(
                      child: CustomButton(
                          onPressed: onNo,
                          child: Text(
                            S.of(context).no,
                            style: AppTextStyles.medium(
                              fontSize: 16.sp,
                              color: AppColors.white,
                            ),
                          )),
                    ),
                  ],
                );
              })
            ],
          ),
        ),
        20.h.s,
        Divider(
          color: AppColors.dividerColor,
          thickness: 2,
          height: 0.h,
        ),
        25.h.s
      ],
    );
  }

  Widget buildEmailReverify(
      {required String title,
      required String subTitle,
      required void Function() onYes,
      required void Function() onNo}) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.medium(
                  fontSize: 18.sp,
                  color: AppColors.purpleText,
                ),
              ),
              20.s,
              Text(
                subTitle,
                style: AppTextStyles.regular(
                  fontSize: 16.sp,
                ),
              ),
              30.s,
              BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (contextProfile, state) {
                return Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                          onPressed: onYes,
                          child: () {
                            if (state.sendOtpLoadingState ==
                                    LoadingState.loading &&
                                state.isEmailReVerification) {
                              return const CustomLoadingWidget(
                                  color: AppColors.white);
                            } else {
                              return Text(
                                S.of(context).yes,
                                style: AppTextStyles.medium(
                                  fontSize: 16.sp,
                                  color: AppColors.white,
                                ),
                              );
                            }
                          }()),
                    ),
                    10.s,
                    Expanded(
                      child: CustomButton(
                          onPressed: onNo,
                          child: Text(
                            S.of(context).no,
                            style: AppTextStyles.medium(
                              fontSize: 16.sp,
                              color: AppColors.white,
                            ),
                          )),
                    ),
                  ],
                );
              })
            ],
          ),
        ),
        20.h.s,
        Divider(
          color: AppColors.dividerColor,
          thickness: 2,
          height: 0.h,
        ),
        25.h.s
      ],
    );
  }

  Widget buildListTile({
    required String text,
    String? subTitle,
    Function()? onTap,
    String? image,
    double? size,
    Function()? onIconTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.medium(
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                if (subTitle != null)
                  Text(
                    subTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.medium(
                        fontSize: 12.sp, color: AppColors.textColorHint),
                  ),
              ],
            ),
          ),
          if (image != null)
            IconButton(
              icon:
                  SvgImage(source: image, width: size, color: AppColors.white),
              onPressed: onIconTap,
            ),
        ],
      ),
    );
  }

  Widget buildListBioTile({
    required String text,
    String? subTitle,
    Function()? onTap,
    String? image,
    double? size,
    Function()? onIconTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                //  overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: AppTextStyles.medium(
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 8.h),
              if (subTitle != null)
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    subTitle,
                    softWrap: true,
                    style: AppTextStyles.medium(
                        fontSize: 12.sp, color: AppColors.textColorHint),
                  ),
                ),
            ],
          ),
        ),
        if (image != null)
          IconButton(
            icon: SvgImage(source: image, width: size, color: AppColors.white),
            onPressed: onIconTap,
          ),
      ],
    );
  }

  Widget buildSettingsListTile(
      {required String text,
      Function()? onTap,
      required String icon,
      bool? isForDelete}) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Row(
        children: [
          SvgImage(
              source: icon,
              width: 22,
              color: (isForDelete ?? false)
                  ? AppColors.redColor
                  : AppColors.white),
          18.s,
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: AppTextStyles.medium(
                  fontSize: 20.sp,
                  color: (isForDelete ?? false) ? AppColors.redColor : null),
            ),
          ),
        ],
      ),
    );
  }
}
