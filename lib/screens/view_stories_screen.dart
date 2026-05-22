import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:two_one_two_messenger/cubit/create_stories_cubit.dart';
import 'package:two_one_two_messenger/cubit/create_stories_state.dart';
import 'package:two_one_two_messenger/extension/date_format.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/models/stories_response.dart';
import 'package:two_one_two_messenger/screens/user_profile.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/avatar_widgets.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';

import '../cubit/view_stories_cubit.dart';
import '../cubit/view_stories_state.dart';
import '../services/api_client.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/navigation.dart';
import '../utils/text_style.dart';
import '../widgets/appbar.dart';
import '../widgets/buttons.dart';
import '../widgets/network_image.dart';
import '../widgets/svg_images.dart';
import 'home_screen.dart';

class ViewStoriesScreen extends StatefulWidget {
  // final CreateStoriesResponse? createStoriesResponse;

  const ViewStoriesScreen({
    super.key,
  });

  @override
  State<ViewStoriesScreen> createState() => _ViewStoriesScreenState();
}

class _ViewStoriesScreenState extends State<ViewStoriesScreen> {
  // CreateStoriesResponse? createStoriesResponse;
  ViewStoriesCubit? cubit;
  final StoryController controller = StoryController();
  ValueNotifier<int> currentStoryIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   final argument = ModalRoute.of(context)!.settings.arguments as String;
    //   createStoriesResponse = CreateStoriesResponse.fromJson(jsonDecode(argument));
    //   setState(() {});
    // },);
    init();
    super.initState();
  }

  @override
  void dispose() {
    // final cubit = context.read<ViewStoriesCubit>();
    // if(cubit.flickManager != null) {
    //   cubit.disposeVideoPlayer();
    // }
    super.dispose();
  }

  init() async {
    await context.read<ViewStoriesCubit>().getLoggedInUserStories(context);
    // cubit = context.read<ViewStoriesCubit>();
    // if (Utils.getMediaType(cubit!.currentUserStoriesList.first.mediaType!) ==
    //         MimeType.video &&
    //     cubit!.currentUserStoriesList.first.mediaUrl != null) {
    //   await cubit!
    //       .initializeVideoPlayer(cubit!.currentUserStoriesList.first.mediaUrl!);
    // }
  }

  @override
  void didUpdateWidget(covariant ViewStoriesScreen oldWidget) {
    log("did update widget call");
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    log("didChangeDependencies  call");
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        NavigationService().popUntil();
      },
      child: Scaffold(
        appBar: CommonAppBar(
          isBackShow: true,
          title: S.of(context).yourStories,
          onBackPressed: () => NavigationService().goBack(),
          actions: [
            BlocBuilder<ViewStoriesCubit, ViewStoriesState>(
                builder: (contextView, state) {
              if (state.loadingState == LoadingState.success &&
                  state.currentUserStoriesList.isNotEmpty) {
                return IconButton(
                  icon: SvgImage(
                    source: SvgAssets.icEye,
                    width: 20.w,
                    color: AppColors.white,
                  ),
                  onPressed: () {
                    controller.pause();
                    buildBottomSheet();
                  },
                );
              } else {
                return SizedBox();
              }
            }),
            BlocBuilder<ViewStoriesCubit, ViewStoriesState>(
                builder: (contextView, state) {
              if (state.loadingState == LoadingState.success &&
                  state.currentUserStoriesList.isNotEmpty) {
                return IconButton(
                  icon: SvgImage(
                    source: SvgAssets.icTrash,
                    width: 20.w,
                    color: AppColors.white,
                  ),
                  onPressed: () {
                    controller.pause();
                    buildDeleteDialog();
                  },
                );
              } else {
                return SizedBox();
              }
            }),
          ],
        ),
        body: BlocBuilder<ViewStoriesCubit, ViewStoriesState>(
          builder: (contextView, state) {
            final cubit = contextView.read<ViewStoriesCubit>();
            if (state.loadingState == LoadingState.loading) {
              return Center(
                child: CustomLoadingWidget(
                  color: AppColors.white,
                ),
              );
            } else if (state.loadingState == LoadingState.success) {
              if (state.currentUserStoriesList.isNotEmpty) {
                // final data = state.currentUserStoriesList;

                return SafeArea(
                  child: Stack(
                    children: [
                      StoryView(
                        controller: controller,
                        storyItems: state.currentUserStoriesList.map(
                          (e) {
                            return (Utils.getMediaType(e.mediaType!) ==
                                    MimeType.video)
                                ? StoryItem.pageVideo(
                                    '${Urls.mediaUrl}${e.mediaUrl}',
                                    controller: controller,
                                    duration:
                                        Duration(seconds: e.duration ?? 10),
                                    imageFit: BoxFit.contain,
                                    caption: Text(
                                      e.caption ?? '',
                                      style: TextStyle(
                                        color: AppColors.purpleText,
                                        // backgroundColor: Colors.black54,
                                        fontSize: 17,
                                      ),
                                    ),
                                  )
                                : StoryItem.inlineImage(
                                    url: '${Urls.mediaUrl}${e.mediaUrl}',
                                    controller: controller,
                                    roundedTop: false,
                                    roundedBottom: false,
                                    imageFit: BoxFit.contain,
                                    caption: Text(
                                      e.caption ?? '',
                                      style: TextStyle(
                                        color: Colors.white,
                                        // backgroundColor: Colors.black54,
                                        fontSize: 17,
                                      ),
                                    ),
                                    // createDate: Date
                                  );
                          },
                        ).toList(),
                        onStoryShow: (storyItem, index) {
                          cubit.updateIndex(index);
                          currentStoryIndex.value = index;
                        },
                        onComplete: () {
                          showMessage("Completed a cycle");
                          Navigator.of(context).pop();
                        },
                        progressPosition: ProgressPosition.top,
                        repeat: false,
                        inline: true,
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          top: 16,
                          left: 16,
                          right: 16,
                        ),
                        child: _buildProfileView(
                          state.currentUserStoriesList,
                        ),
                      )
                    ],
                  ),

                  // Stack(
                  //   children: [
                  //     (Utils.getMediaType(data.mediaType!) == MimeType.image)
                  //         ? Positioned.fill(
                  //       child: AppNetworkImage(
                  //         imageUrl: '${Urls.mediaUrl}${data.mediaUrl!}',
                  //         fit: BoxFit.fill,
                  //       ),
                  //     )
                  //         : Positioned.fill(
                  //       child: Stack(
                  //         children: [
                  //           if(cubit.chewieController != null)
                  //             Chewie(
                  //               controller: cubit.chewieController!,
                  //             )
                  //           // cubit.videoController != null &&
                  //           //         cubit.videoController!.value
                  //           //             .isInitialized
                  //           //     ? Center(
                  //           //         child: AspectRatio(
                  //           //           aspectRatio: cubit.videoController!
                  //           //               .value.aspectRatio,
                  //           //           child: VideoPlayer(
                  //           //               cubit.videoController!),
                  //           //         ),
                  //           //       )
                  //           //     : cubit.videoThumbnail == null ? Container() : Image.file(
                  //           //         cubit.videoThumbnail!,
                  //           //       ),
                  //           /*if(cubit.flickManager != null)
                  //             FlickVideoPlayer(
                  //               flickManager: cubit.flickManager!,
                  //               flickVideoWithControls: FlickVideoWithControls(
                  //                 closedCaptionTextStyle: TextStyle(fontSize: 8),
                  //                 controls: FlickPortraitControls(),
                  //               ),
                  //               flickVideoWithControlsFullscreen: FlickVideoWithControls(
                  //                 controls: FlickLandscapeControls(),
                  //               ),
                  //             ),*/
                  //           // Center(
                  //           //   child: IconButton(
                  //           //     onPressed: () => cubit.togglePlayPause(),
                  //           //     icon: Icon(
                  //           //       cubit.videoController != null &&
                  //           //               cubit.videoController!.value
                  //           //                   .isPlaying
                  //           //           ? Icons.pause_circle_filled
                  //           //           : state is VideoPlayerCompleted
                  //           //               ? Icons.play_circle_fill_rounded
                  //           //               : Icons
                  //           //                   .play_circle_fill_rounded,
                  //           //       size: 50.w,
                  //           //       color: AppColors.white,
                  //           //     ),
                  //           //   ),
                  //           // ),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // )
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          S.of(context).noStories,
                          style: AppTextStyles.medium(
                            fontSize: 22.sp,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      20.s,
                      Text(
                        S.of(context).noStoriesUploadedDescription,
                        style: AppTextStyles.regular(
                            color: AppColors.white.withValues(alpha: 70)),
                      )
                    ],
                  ),
                );
              }
            } else if (state.loadingState == LoadingState.error) {
              return Center(
                  child: Text(S.of(context).somethingWentWrongPleaseTryAgain));
            } else {
              return Container();
            }
          },
        ),
        floatingActionButton: GestureDetector(
          onTap: () async {
            controller.pause();
            await buildSelectionDialog();
            showMessage("Strory Start");
            // controller.play();
          },
          child: Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor,
            ),
            child: Center(
              child: SvgImage(
                source: SvgAssets.icAddRounded,
                height: 30.h,
                width: 30.w,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> buildSelectionDialog() async {
    context.read<CreateStoriesCubit>().resetSource();
    await showDialog(
      context: context,
      builder: (context) {
        return BlocBuilder<CreateStoriesCubit, CreateStoriesState>(
            builder: (contextStories, storiesState) {
          final cubit = context.read<CreateStoriesCubit>();
          return Dialog(
            backgroundColor: AppColors.dark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26.r),
            ), //this right here
            child: Container(
              // height: 255.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.dark,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      S.of(context).lblUploadMedias,
                      style: AppTextStyles.medium(fontSize: 16.sp),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () => cubit.selectCamera(),
                              child: Container(
                                height: 65.w,
                                width: 65.w,
                                decoration: BoxDecoration(
                                  color:
                                      cubit.source == ImageSourceOption.camera
                                          ? AppColors.primaryColor
                                          : AppColors.darkInputFill,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: SvgImage(
                                    source: SvgAssets.icCamera,
                                    width: 24.w,
                                    height: 24.h,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              S.of(context).camera,
                              style: AppTextStyles.regular(fontSize: 14.sp),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () => cubit.selectGallery(),
                              child: Container(
                                height: 65.w,
                                width: 65.w,
                                decoration: BoxDecoration(
                                  color:
                                      cubit.source == ImageSourceOption.gallery
                                          ? AppColors.primaryColor
                                          : AppColors.darkInputFill,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: SvgImage(
                                    source: SvgAssets.icGallery,
                                    width: 24.w,
                                    height: 24.h,
                                    color: cubit.source ==
                                            ImageSourceOption.gallery
                                        ? AppColors.white
                                        : AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              S.of(context).gallery,
                              style: AppTextStyles.regular(fontSize: 14.sp),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 30.h),
                    CustomButton(
                      onPressed: () async {
                        // Navigator.of(context).pop();
                        if (cubit.source == ImageSourceOption.camera) {
                          // await cubit.pickImageFromCamera();
                          Navigator.of(context).pop();
                          await buildCameraOptionDialog(ImageSource.camera);
                        } else if (cubit.source == ImageSourceOption.gallery) {
                          // await cubit.pickImageFromGallery();
                          Navigator.of(context).pop();
                          await buildCameraOptionDialog(ImageSource.gallery);
                        }
                      },
                      child: Text(
                        S.of(context).next,
                        style: AppTextStyles.medium(
                          fontSize: 16.sp,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> buildCameraOptionDialog(ImageSource imageSource) async {
    await showDialog(
      context: context,
      builder: (context) {
        return BlocBuilder<CreateStoriesCubit, CreateStoriesState>(
            builder: (contextStories, storiesState) {
          final cubit = context.read<CreateStoriesCubit>();
          return Dialog(
            backgroundColor: AppColors.dark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26.r),
            ), //this right here
            child: Container(
              // height: 255.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.dark,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      S.of(context).lblUploadMedias,
                      style: AppTextStyles.medium(fontSize: 16.sp),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                // Navigator.of(context).pop();
                                cubit.pickImageFromCamera(
                                    CameraSourceOption.image, imageSource);
                              },
                              child: Container(
                                height: 65.w,
                                width: 65.w,
                                decoration: BoxDecoration(
                                  color: AppColors.darkInputFill,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: SvgImage(
                                    source: SvgAssets.icImage,
                                    width: 24.w,
                                    height: 24.h,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              S.of(context).image,
                              style: AppTextStyles.regular(fontSize: 14.sp),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                Navigator.of(context).pop();
                                cubit.pickImageFromCamera(
                                    CameraSourceOption.video, imageSource);
                              },
                              child: Container(
                                height: 65.w,
                                width: 65.w,
                                decoration: BoxDecoration(
                                  color: AppColors.darkInputFill,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: SvgImage(
                                    source: SvgAssets.icVideo,
                                    width: 24.w,
                                    height: 24.h,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              S.of(context).video,
                              style: AppTextStyles.regular(fontSize: 14.sp),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  void buildBottomSheet() {
    // showMessage(
    //     "buildBottomSheet==> ${context.read<ViewStoriesCubit>().currentUserStoriesList[context.read<ViewStoriesCubit>().currentIndex].viewersDetails!}");
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      backgroundColor: AppColors.dark,
      builder: (BuildContext context) {
        return BlocBuilder<ViewStoriesCubit, ViewStoriesState>(
            builder: (contextStories, state) {
          final cubit = context.read<ViewStoriesCubit>();
          // showMessage(
          //     "buildBottomSheet==> ${context.read<ViewStoriesCubit>().currentUserStoriesList[context.read<ViewStoriesCubit>().currentIndex].viewersDetails!}");

          return Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8),
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: 8.h),
                Container(
                  width: 80.h,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                if (state.currentUserStoriesList[cubit.currentIndex]
                    .viewersDetails!.isNotEmpty) ...[
                  ListView.builder(
                    itemCount: state.currentUserStoriesList[cubit.currentIndex]
                        .viewersDetails?.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final data = state
                          .currentUserStoriesList[cubit.currentIndex]
                          .viewersDetails![index];

                      return buildListTile(
                        image: (data.profilePicture ?? "").isEmpty
                            ? ""
                            : '${Urls.mediaUrl}${data.profilePicture}',
                        name: (data.isActiveNickname ?? false)
                            ? (data.nickName ??
                                data.name ??
                                data.userName ??
                                "")
                            : data.name ?? data.userName ?? "",
                        onTap: () {
                          NavigationService().navigateTo(UserProfileScreen(
                            user: UserData.fromJson(data.toJson()),
                          ));
                        },
                      );
                    },
                  )
                ] else ...[
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Center(
                        child: Text(
                          S.of(context).noViewsYetForStories,
                          style: AppTextStyles.medium(
                              fontSize: 14.sp, color: AppColors.white),
                        ),
                      )),
                ],
                // buildListTile(
                //   image: '',
                //   name: 'Abram Passaquindici Arcand',
                //   onTap: () {},
                // )
              ],
            ),
          );
        });
      },
    ).then((result) {
      // This callback will be executed once the dialog is closed.
      controller.play();
      if (result != null) {
        if (result) {
          // Handle the "Delete" action
          showMessage('Dialog dismissed with result: Delete');
        } else {
          // Handle the "Cancel" action
          showMessage('Dialog dismissed with result: Cancel');
        }
      }
    });
  }

  Widget buildListTile({
    required String image,
    required String name,
    String? subTittle,
    required Function() onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.h,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: AppColors.darkInputFill,
                shape: BoxShape.circle,
              ),
              child: image.isEmpty
                  ? Center(
                      child: SvgImage(
                        source: SvgAssets.icPerson,
                        color: AppColors.white,
                      ),
                    )
                  : AppNetworkImage(
                      imageUrl: image,
                    ),
            ),
            SizedBox(
              width: 16.w,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.medium(
                      fontSize: 16.sp,
                    ),
                  ),
                  if (subTittle != null)
                    SizedBox(
                      height: 8.h,
                    ),
                  if (subTittle != null)
                    Text(
                      subTittle,
                      style: AppTextStyles.regular(
                        fontSize: 12.sp,
                        color: AppColors.textColorThird,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void buildDeleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BlocBuilder<ViewStoriesCubit, ViewStoriesState>(
            builder: (contextStories, state) {
          final cubit = context.read<ViewStoriesCubit>();
          return Dialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26.r),
            ), //this right here
            child: SizedBox(
              height: 250.h,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned(
                    top: 30.h,
                    left: 0.w,
                    right: 0.w,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.dark,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(height: 24.h),
                            Text(
                              S.of(context).lblDeleteStories,
                              style: AppTextStyles.medium(fontSize: 20.sp),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              S.of(context).lblDeleteStoriesSubTitle,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.regular(
                                  fontSize: 14.sp,
                                  color: AppColors.textColorSecondary),
                            ),
                            SizedBox(height: 24.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    onPressed: () async =>
                                        await NavigationService().goBack(),
                                    backgroundColor: AppColors.btnGrey,
                                    child: Text(
                                      S.of(context).cancel,
                                      style: AppTextStyles.medium(
                                        fontSize: 16.sp,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: CustomButton(
                                    onPressed: () async {
                                      showMessage(
                                          "createStoriesResponse ==> ${state.currentUserStoriesList[cubit.currentIndex].sId!}");
                                      contextStories
                                          .read<ViewStoriesCubit>()
                                          .deleteStories(
                                        state
                                            .currentUserStoriesList[
                                                cubit.currentIndex]
                                            .sId!,
                                        context,
                                        callback: () async {
                                          await NavigationService().goBack();
                                          final cubit = contextStories
                                              .read<ViewStoriesCubit>();
                                          for (int i = 0;
                                              i < cubit.currentIndex;
                                              i++) {
                                            controller
                                                .next(); // Skip previous stories
                                          }
                                          // await NavigationService()
                                          //     .replaceWith(HomeScreen());
                                        },
                                      );
                                    },
                                    child: () {
                                      if (state.loadingState ==
                                          LoadingState.loading) {
                                        return const CustomLoadingWidget(
                                          color: AppColors.white,
                                        );
                                      }
                                      // else if (state is ViewStoriesSuccess) {
                                      //   return const Icon(
                                      //     Icons.check,
                                      //     color: AppColors.white,
                                      //   );
                                      // }
                                      else if (state.loadingState ==
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
                                          S.of(context).delete,
                                          style: AppTextStyles.medium(
                                            fontSize: 16.sp,
                                            color: AppColors.white,
                                          ),
                                        );
                                      }
                                    }(),
                                    // child: Text(
                                    //   AppConstants.delete,
                                    //   style: AppTextStyles.medium(
                                    //     fontSize: 16.sp,
                                    //     color: AppColors.white,
                                    //   ),
                                    // ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0.h,
                    left: 0.w,
                    right: 0.w,
                    child: Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        // Blue background for the icon
                        shape: BoxShape
                            .circle, // Circle shape for the icon container
                      ),
                      child: Center(
                        child: SvgImage(
                          source: SvgAssets.icTrash,
                          width: 24.w,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildProfileView(List<CurrentUserStoriesData> data) {
    return SizedBox(
        // color: Colors.red,
        // height: 70,
        child: ValueListenableBuilder<int>(
      valueListenable: currentStoryIndex,
      builder: (context, value, child) {
        final date = data[value].createdAt;
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(date?.storyTime ?? ""),
        );
      },
    )

        //  Row(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: <Widget>[
        //     // GestureDetector(
        //     //   onTap: () async {
        //     //     // if (data != null) {
        //     //     //   controller.pause();
        //     //     //   await NavigationService().navigateTo(UserProfileScreen(
        //     //     //     user: data.userDetails!,
        //     //     //   ));
        //     //     //   controller.play();
        //     //     // }
        //     //   },
        //     //   child: AvatarWidgets(
        //     //     userPic: data.mediaUrl ?? "",
        //     //     height: 50,
        //     //     width: 50,
        //     //   ),
        //     //   // Container(
        //     //   //   width: 50.w,
        //     //   //   height: 50.w,
        //     //   //   decoration: BoxDecoration(
        //     //   //     color: AppColors.darkInputFill,
        //     //   //     shape: BoxShape.circle,
        //     //   //   ),
        //     //   //   child: ClipOval(
        //     //   //     child: AvatarWidgets(
        //     //   //         imageUrl:
        //     //   //             '${Urls.mediaUrl}${data.userDetails?.profilePicture}'),
        //     //   //   ),
        //     //   // ),
        //     // ),
        //     // SizedBox(
        //     //   width: 5,
        //     // ),
        //     Expanded(
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         mainAxisAlignment: MainAxisAlignment.start,
        //         children: <Widget>[
        //           // Text(
        //           //   data. ?? '',
        //           //   maxLines: 1,
        //           //   style: AppTextStyles.medium(),
        //           // ),
        //           // SizedBox(height: 10),
        //           ValueListenableBuilder<int>(
        //             valueListenable: currentStoryIndex,
        //             builder: (context, value, child) {
        //               final date = data[value].createdAt;
        //               return Text(date?.storyTime ?? "");
        //             },
        //           )
        //         ],
        //       ),
        //     )
        //   ],
        // ),
        );
  }
}
