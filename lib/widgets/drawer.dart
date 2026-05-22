import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/screens/calls_screen.dart';
import 'package:two_one_two_messenger/screens/contacts_screen.dart';
import 'package:two_one_two_messenger/screens/invite_friend_screen.dart';
import 'package:two_one_two_messenger/screens/my_profile_screen.dart';
import 'package:two_one_two_messenger/screens/saved_messages.dart';
import 'package:two_one_two_messenger/services/fcm_service.dart';
import 'package:two_one_two_messenger/services/socket_service.dart';
import 'package:two_one_two_messenger/utils/app_dialoge.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';

import '../cubit/send_otp_cubit.dart';
import '../cubit/theme_cubit.dart';
import '../cubit/user_data_cubit.dart';
import '../database/local_db.dart';
import '../models/otp_verify.dart';
import '../screens/login_screen.dart';
import '../screens/new_group.dart';
import '../screens/profile_screen.dart';
import '../services/api_client.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/navigation.dart';
import '../utils/text_style.dart';
import '../utils/utils.dart';
import 'network_image.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  CustomDrawerState createState() => CustomDrawerState();
}

class CustomDrawerState extends State<CustomDrawer> {
  final Map<String, bool> _expandedState = {};
  final dbHelper = DatabaseHelper();
  UserData? user;

  @override
  void initState() {
    super.initState();
    userDataCubit.loadUserData().then(
      (value) {
        user = userDataCubit.state;
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    user = context.watch<UserDataCubit>().state;

    return SafeArea(
      child: Drawer(
        backgroundColor: AppColors.dark,
        width: context.w * 0.85,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(40.w)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // DrawerHeader(
            //   decoration: BoxDecoration(
            //     color: AppColors.darkAppBar,
            //
            //   ),
            //   child:
            // ),
            Container(
              color: AppColors.darkAppBar,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 4,
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: 24.h, left: 16.w, right: 16.w, bottom: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 8.h),
                        user?.profilePicture != null
                            ? Container(
                                width: 100.w,
                                height: 100.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: AppNetworkImage(
                                  imageUrl:
                                      '${Urls.mediaUrl}${user?.profilePicture}' ??
                                          '',
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100.r)),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                width: 100.w,
                                height: 100.h,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.dark, width: 2.w)),
                                child: Center(
                                  child: SvgImage(
                                      source: SvgAssets.icPerson,
                                      width: 20.w,
                                      color: AppColors.white),
                                ),
                              ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.name ?? user?.userName ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.semiBold(
                                      fontSize: 18.sp,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  // if (user?.phone != null)
                                  //   Text(
                                  //     '${user?.countryCode} ${user?.phone}',
                                  //     style: AppTextStyles.regular(
                                  //       color: AppColors.textColorSecondary,
                                  //       fontSize: 14.sp,
                                  //     ),
                                  //   ),
                                ],
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  NavigationService()
                                      .navigateTo(ProfileScreen());
                                  Utils.closeDrawer(context);
                                },
                                icon: Icon(
                                  Icons.settings,
                                  color: AppColors.white,
                                )
                                // SvgImage(
                                //   width: 24.w,
                                //   source: SvgAssets.icSettings,
                                //   color: AppColors.white,
                                // ),
                                ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    top: 10.h,
                    right: 4.w,
                    child: IconButton(
                      onPressed: () {
                        context.read<ThemeCubit>().toggleTheme();
                        Utils.showSnackBar(context, S.of(context).comingSoon);
                      },
                      icon: SvgImage(
                        source: SvgAssets.icBrightness,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 8.h,
            ),
            Expanded(
              child: ListView(
                children: [
                  buildListTile(
                    image: SvgAssets.icPerson,
                    text: S.of(context).sProfile,
                    onTap: () async {
                      NavigationService().navigateTo(MyProfileScreen());
                      Utils.closeDrawer(context);
                    },
                  ),
                  buildListTile(
                    image: SvgAssets.icNewGroup,
                    text: S.of(context).newGroup,
                    onTap: () async {
                      homeCubit.cleanGroupData();
                      NavigationService().navigateTo(NewGroupScreen(
                        isGroup: true,
                      ));
                      Utils.closeDrawer(context);
                    },
                  ),
                  buildListTile(
                    image: SvgAssets.megaphone,
                    text: S.of(context).newChannel,
                    onTap: () async {
                      homeCubit.cleanGroupData();
                      NavigationService().navigateTo(NewGroupScreen(
                        isGroup: false,
                      ));
                      Utils.closeDrawer(context);
                    },
                  ),
                  buildListTile(
                    image: SvgAssets.icContacts,
                    text: S.of(context).sContacts,
                    onTap: () async {
                      NavigationService().navigateTo(ContactsScreen());
                      Utils.closeDrawer(context);
                    },
                  ),
                  buildListTile(
                    image: SvgAssets.icCalls,
                    text: S.of(context).sCalls,
                    onTap: () async {
                      NavigationService().navigateTo(CallsScreen());
                      Utils.closeDrawer(context);
                    },
                  ),
                  buildListTile(
                    image: SvgAssets.icBookmarks,
                    text: S.of(context).sSavedMessages,
                    onTap: () async {
                      NavigationService().navigateTo(SavedMessages());
                      Utils.closeDrawer(context);
                    },
                  ),
                  // buildListTile(
                  //   image: SvgAssets.icSettings,
                  //   text: AppConstants.sSettings,
                  //   onTap: () async {
                  //      NavigationService().navigateTo(SavedMessages());
                  //     Utils.closeDrawer(context);
                  //   },
                  // ),
                  buildListTile(
                    image: SvgAssets.icInviteFriends,
                    text: S.of(context).sInviteFriends,
                    onTap: () async {
                      NavigationService().navigateTo(InviteFriendScreen());
                      Utils.closeDrawer(context);
                    },
                  ),
                  buildListTile(
                    image: SvgAssets.icLogout,
                    text: S.of(context).sLogout,
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
                          await context.read<SendOtpCubit>().deleteToken(
                            userId,
                            token ?? '',
                            context,
                            callback: (response) async {
                              await dbHelper.deleteLoginData();
                              await dbHelper.saveKeepLoggedIn(false, "", "");

                              ///TODO NOTE: SignIn With google and facebook
                              // await GoogleSignIn().signOut();
                              await sendOtpCubit.resetSendOtpState();
                              NavigationService()
                                  .clearAndNavigateTo(LoginScreen());
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            Center(
              child: Image.asset(
                ImgAssets.logo,
                width: (MediaQuery.of(context).size.width / 8),
              ),
            ),
            SizedBox(
              height: 16.h,
            ),
          ],
        ),
      ),
    );
  }

  Padding buildListTile(
      {required String image,
      required String text,
      required Function() onTap}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: ListTile(
        horizontalTitleGap: 16.w,
        leading: SvgImage(
          width: 20.w,
          source: image,
          color: AppColors.white,
        ),
        title: Text(
          text,
          style: AppTextStyles.medium(
            fontSize: 16.sp,
          ),
        ),
        onTap: onTap,
        splashColor: Colors.transparent,
      ),
    );
  }

  // String _getIcon(String iconName) {
  //   switch (iconName) {
  //     case AppConstants.sSettings:
  //       return SvgAssets.icSettings;
  //     case S.of(context).sLogout:
  //       return SvgAssets.icLogout;
  //     default:
  //       return SvgAssets.icSettings;
  //   }
  // }
}
