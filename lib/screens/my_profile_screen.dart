import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/GoogleAds/BannerAds/BannerAdManager.dart';
import 'package:two_one_two_messenger/cubit/profile_cubit.dart';
import 'package:two_one_two_messenger/cubit/profile_state.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

import '../models/otp_verify.dart';
import '../services/api_client.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/navigation.dart';
import '../utils/text_style.dart';
import '../widgets/appbar.dart';
import '../widgets/network_image.dart';
import '../widgets/svg_images.dart';
import 'edit_profile_screen.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  @override
  void initState() {
    onInit();
    super.initState();
  }

  Future<void> onInit() async {
    await profileCubit.getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    // UserData? user = context.watch<UserDataCubit>().state;
    // showMessage("user --> $user");

    return Scaffold(
      appBar: CommonAppBar(
        isBackShow: true,
        backgroundColor: AppColors.darkAppBar,
        actions: [
          // IconButton(
          //   icon: SvgImage(
          //       source: SvgAssets.icEdit, width: 20.w, color: AppColors.white),
          //   onPressed: () {
          //     NavigationService().navigateTo(EditProfileScreen());
          //   },
          // ),
          // IconButton(
          //   icon: SvgImage(
          //       source: SvgAssets.icMoreDots,
          //       width: 20.w,
          //       color: AppColors.white),
          //   onPressed: () {},
          // ),
        ],
      ),
      bottomNavigationBar: const BannerAdManager(),
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
            ListView(
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
                        S.of(context).info,
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
                        onTap: () {},
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
                        text: user?.userName ?? '',
                        subTitle: S.of(context).username,
                        // image: SvgAssets.icQrCode,
                        size: 24.w,
                        onIconTap: () {},
                      ),
                      20.s,
                      buildListBioTile(
                        text: (user.bio ?? "").isNotEmpty
                            ? user.bio ?? ""
                            : S.of(context).addFewWordsAboutYourself,

                        subTitle: S.of(context).bio,
                        // image: SvgAssets.icQrCode,
                        // size: 24.w,
                        // onIconTap: () {},
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Divider(
                  color: AppColors.dividerColor,
                  thickness: 2,
                  height: 0.h,
                ),
              ],
            ),
          ],
        );
      }),
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
    return Row(
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
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    subTitle,
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
}
