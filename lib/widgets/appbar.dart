import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/cubit/home_cubit.dart';
import 'package:two_one_two_messenger/cubit/home_state.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/screens/notification_screen.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';

import '../screens/search_screen.dart';
import '../utils/constants.dart';
import '../utils/navigation.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subTitle;
  final String logoPath;
  final Color? backgroundColor;
  final List<Widget>? actions;
  final bool isActionsShow;
  final bool isBackShow;
  final bool automaticallyImplyLeading;
  final bool isShowBottomLine;
  final Function()? onBackPressed;
  final void Function()? onSearch;
  const CommonAppBar({
    super.key,
    this.title,
    this.subTitle,
    this.backgroundColor,
    this.logoPath = ImgAssets.logo,
    this.actions,
    this.automaticallyImplyLeading = false,
    this.isActionsShow = true,
    this.isBackShow = false,
    this.isShowBottomLine = true,
    this.onBackPressed,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor ?? AppColors.dark,
      titleSpacing: 0,
      surfaceTintColor: backgroundColor ?? AppColors.dark,
      leading: isBackShow
          ? Builder(
              builder: (context) => IconButton(
                onPressed: onBackPressed ??
                    () async {
                      await NavigationService().goBack();
                    },
                icon: SvgImage(
                  source: SvgAssets.icArrowBack,
                  width: 20.w,
                  color: AppColors.white,
                ),
              ),
            )
          : null,
      title: !isBackShow
          ? Row(
              children: [
                16.s,
                Image.asset(
                  logoPath,
                  width: (MediaQuery.of(context).size.width / 10),
                ),
                SizedBox(width: 8.w),
                Text(title!, style: AppTextStyles.bold(fontSize: 20.sp))
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title ?? '', style: AppTextStyles.medium(fontSize: 20.sp)),
                if (subTitle != null)
                  Text(subTitle ?? '',
                      style: AppTextStyles.medium(
                          fontSize: 10.sp,
                          color: AppColors.white.withValues(alpha: 0.5))),
              ],
            ),
      actions: isActionsShow
          ? actions ??
              [
                BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
                  return Badge(
                    label: Text(
                      "${state.unreadNotificationCount}",
                      style: AppTextStyles.regular(fontSize: 8),
                    ),
                    isLabelVisible: state.unreadNotificationCount > 0,
                    offset: Offset(-5, 8),
                    child: IconButton(
                      icon: SvgImage(
                        source: SvgAssets.icNotification,
                        width: 20.w,
                        color: AppColors.white,
                      ),
                      onPressed: () {
                        NavigationService().navigateTo(NotificationsScreen());
                      },
                    ),
                  );
                }),
                IconButton(
                  icon: SvgImage(
                    source: SvgAssets.icSearch,
                    width: 20.w,
                    color: AppColors.white,
                  ),
                  onPressed: onSearch ??
                      () {
                        NavigationService().navigateTo(SearchScreen());
                      },
                ),
                Builder(
                  builder: (context) => IconButton(
                    icon: SvgImage(
                        source: SvgAssets.menu, color: AppColors.white),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                  ),
                ),
              ]
          : null,
      bottom: isShowBottomLine
          ? PreferredSize(
              preferredSize:
                  const Size.fromHeight(1), // Adjust height of the divider
              child: Container(
                color: AppColors.darkAppBar, // Set divider color
                height: 1, // Divider thickness
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
