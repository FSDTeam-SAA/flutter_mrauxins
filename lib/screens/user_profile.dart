import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

import '../models/otp_verify.dart';
import '../services/api_client.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/text_style.dart';
import '../widgets/appbar.dart';
import '../widgets/network_image.dart';
import '../widgets/svg_images.dart';
import 'nick_name/nick_name_screen.dart';

// ignore: must_be_immutable
class UserProfileScreen extends StatefulWidget {
  UserData user;
  final Function(bool newStatus)? onNickNameStatusChangge;
  final Function({required String? newNickName, required bool? newStatus})?
      onNickNameChange;
  UserProfileScreen({
    super.key,
    required this.user,
    this.onNickNameStatusChangge,
    this.onNickNameChange,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool isLoading = true;
  bool isShowPhoneOrEmail = false;

  @override
  void initState() {
    onInit();
    super.initState();
  }

  Future<void> onInit() async {
    // await profileCubit.getUserProfile();
    if ((widget.user.sId ?? "").isNotEmpty) {
      isShowPhoneOrEmail =
          await homeCubit.dbHelper.getContactById(widget.user.sId ?? "");
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        child: Column(
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
                                widget.user.profilePicture != null
                                    ? Container(
                                        width: 48.w,
                                        height: 48.h,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child: AppNetworkImage(
                                          imageUrl:
                                              '${Urls.mediaUrl}${widget.user.profilePicture}',
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
                                        widget.user.name ??
                                            widget.user.userName ??
                                            '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.semiBold(
                                          fontSize: 20.sp,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        (widget.user.isOnline ?? false)
                                            ? S.of(context).online
                                            : widget.user.lastSeen
                                                    ?.toCustomFormat() ??
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
                  // Positioned(
                  //   right: 10,
                  //   bottom: 0,
                  //   child: CircleAvatar(
                  //     radius: 32.r,
                  //     backgroundColor: AppColors.primaryColor,
                  //     child: SvgImage(
                  //       source: SvgAssets.icCamera,
                  //       width: 20.r,
                  //     ),
                  //   ),
                  // ),
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
                      if (widget.user.phone != null && (isShowPhoneOrEmail))
                        buildListTile(
                          text:
                              '${widget.user.countryCode} ${widget.user.phone}',
                          subTitle: S.of(context).phoneNumber,
                          onTap: () {},
                        ),
                      if (widget.user.phone != null && (isShowPhoneOrEmail))
                        20.h.s,
                      if ((widget.user.email ?? "").isNotEmpty &&
                          isShowPhoneOrEmail)
                        buildListTile(
                          text: widget.user.email ?? "",
                          subTitle: S.of(context).emailAdress,
                          onTap: () {},
                        ),
                      if ((widget.user.email ?? "").isNotEmpty &&
                          isShowPhoneOrEmail)
                        SizedBox(
                          height: 20.h,
                        ),
                      buildListTile(
                        text: widget.user.userName ?? '',
                        subTitle: S.of(context).username,
                        // image: SvgAssets.icQrCode,
                        size: 24.w,
                        onIconTap: () {},
                      ),
                      if ((widget.user.bio ?? '').isNotEmpty) 20.s,
                      if ((widget.user.bio ?? '').isNotEmpty)
                        buildListBioTile(
                          text: widget.user.bio ?? '',
                          subTitle: S.of(context).bio,
                          // image: SvgAssets.icQrCode,
                          size: 24.w,
                          onIconTap: () {},
                        ),
                      SizedBox(height: 20.h),
                      Divider(
                        color: AppColors.dividerColor,
                        thickness: 2,
                        // height: 0.h,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        S.of(context).setNickName,
                        style: AppTextStyles.medium(
                          fontSize: 18.sp,
                          color: AppColors.purpleText,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      GestureDetector(
                        child: Row(
                          children: [
                            Expanded(
                              child: buildListTile(
                                text:
                                    (widget.user.nickName?.isNotEmpty ?? false)
                                        ? widget.user.nickName.toString()
                                        : "-",
                                subTitle: "Nick Name",
                                // onTap: () => showNickNameDialo(context,
                                //     nickName: widget.user.name),
                              ),
                            ),
                            IconButton(
                              onPressed: () => showNickNameDialog(
                                context,
                                nickName: widget.user.nickName,
                                onPressed: (name) {
                                  if (name != null) {
                                    chatCubit.setNickname(
                                      context: context,
                                      contactUserId: widget.user.sId ?? "",
                                      nickName: name,
                                      callback: (p0) {
                                        Utils.showSnackBar(
                                          context,
                                          S.of(context).nickNameSuccessfully,
                                        );

                                        widget.onNickNameChange?.call(
                                          newNickName: p0.message?.nickName,
                                          newStatus:
                                              p0.message?.isActiveNickname ??
                                                  false,
                                        );

                                        setState(() {
                                          widget.user.nickName =
                                              p0.message?.nickName;
                                          widget.user.isActiveNickname =
                                              p0.message?.isActiveNickname ??
                                                  false;
                                          // !isActiveNickName;
                                        });
                                      },
                                    );
                                  }
                                  // print("Name>>> $name");
                                },
                              ),
                              icon: Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                      // SizedBox(height: 10.h),
                      ListTile(
                        contentPadding: EdgeInsets.all(0),
                        title: Text(
                          S.of(context).activeNickName,
                          style: AppTextStyles.medium(
                            fontSize: 16.sp,
                          ),
                        ),
                        trailing: Switch(
                          value: widget.user.isActiveNickname ?? false,
                          onChanged: (value) {
                            chatCubit.toggleNickname(
                              context: context,
                              contactUserId: widget.user.sId ?? "",
                              isActiveNickname:
                                  !(widget.user.isActiveNickname ?? false),
                              callback: (p0) {
                                final newStatus =
                                    p0.data?.isActiveNickname ?? false;
                                setState(() {
                                  widget.user.isActiveNickname = newStatus;
                                });

                                widget.onNickNameStatusChangge?.call(newStatus);

                                Utils.showSnackBar(
                                  context,
                                  p0.message ??
                                      S.of(context).nickNameActiveSuccessfully,
                                );
                              },
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.only(left: 16.w, right: 16.w),
                  child: Divider(
                    color: AppColors.dividerColor,
                    thickness: 2,
                    height: 0.h,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
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
}
