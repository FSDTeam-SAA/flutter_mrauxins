import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/screens/image_editing_screen.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';
import 'package:video_player/video_player.dart';

import '../cubit/create_stories_cubit.dart';
import '../cubit/create_stories_state.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/navigation.dart';
import '../utils/text_style.dart';
import '../widgets/buttons.dart';
import '../widgets/keyboard_safe_scaffold.dart';
import '../widgets/text_fields.dart';

class UploadStoriesScreen extends StatefulWidget {
  const UploadStoriesScreen({super.key});

  @override
  State<UploadStoriesScreen> createState() => _UploadStoriesScreenState();
}

class _UploadStoriesScreenState extends State<UploadStoriesScreen> {
  final TextEditingController _captionController = TextEditingController();
  late CreateStoriesCubit cubit;
  @override
  void initState() {
    cubit = context.read<CreateStoriesCubit>();
    if (cubit.mimeType == MimeType.video && cubit.selectedFile != null) {
      cubit.initializeVideoPlayer(cubit.selectedFile!);
    }
    super.initState();
  }

  @override
  void dispose() {
    // final cubit = context.read<CreateStoriesCubit>();
    cubit.disposeVideoPlayer();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardSafeScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        leading: IconButton(
          onPressed: () async {
            await NavigationService().goBack();
          },
          icon: SvgImage(
              source: SvgAssets.icArrowBack,
              width: 20.w,
              color: AppColors.white),
        ),
        titleSpacing: 0.w,
        title: Text(
          S.of(context).yourStories,
          style: AppTextStyles.medium(fontSize: 20.sp),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          // Adjust height of the divider
          child: Container(
            color: AppColors.darkAppBar, // Set divider color
            height: 1, // Divider thickness
          ),
        ),
        actions: [
          BlocBuilder<CreateStoriesCubit, CreateStoriesState>(
              builder: (contextStories, state) {
            final cubit = contextStories.read<CreateStoriesCubit>();
            if (cubit.mimeType != MimeType.image) {
              return SizedBox();
            } else {
              return GestureDetector(
                onTap: () async {
                  // String filePath = cubit.selectedFile!.path.split("/").last;
                  // debugPrint("filePath===> $filePath");

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => ImageEditorScreen(
                        selectedFile: cubit.selectedFile!,
                        onImageEdited: (File editedFile) {
                          cubit.setImageFile(editedFile);
                          if (mounted) {
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  );
                },
                behavior: HitTestBehavior.translucent,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.0).copyWith(right: 16),
                  child: SvgImage(
                    source: SvgAssets.icEdit,
                    width: 20.w,
                    height: 20.w,
                    color: AppColors.white,
                  ),
                ),
              );
            }
          }),
        ],
      ),
      body: BlocBuilder<CreateStoriesCubit, CreateStoriesState>(
          builder: (contextStories, state) {
        final cubit = contextStories.read<CreateStoriesCubit>();
        return SafeArea(
          child: Stack(
            children: [
              cubit.mimeType == MimeType.image
                  ? Positioned.fill(
                      child: Image.file(
                        cubit.selectedFile!,
                        fit: BoxFit.contain,
                      ),
                    )
                  : Positioned.fill(
                      child: Stack(
                        children: [
                          cubit.videoController != null &&
                                  cubit.videoController!.value.isInitialized
                              ? Center(
                                  child: AspectRatio(
                                    aspectRatio: cubit
                                        .videoController!.value.aspectRatio,
                                    child: VideoPlayer(
                                      cubit.videoController!,
                                    ),
                                  ),
                                )
                              : Image.file(
                                  cubit.videoThumbnail!,
                                  fit: BoxFit.cover,
                                ),
                          Center(
                            child: IconButton(
                              onPressed: () => cubit.togglePlayPause(),
                              icon: Icon(
                                cubit.videoController != null &&
                                        cubit.videoController!.value.isPlaying
                                    ? Icons.pause_circle_filled
                                    : state is VideoPlayerCompleted
                                        ? Icons.play_circle_fill_rounded
                                        : Icons.play_circle_fill_rounded,
                                size: 50.w,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              Positioned(
                bottom: 30.h,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: CustomTextField(
                        readOnly: state is CreateStoriesLoading,
                        controller: _captionController,
                        label: S.of(context).writeCaptionHere,
                        borderRadius: 50,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: CustomButton(
                        onPressed: () {
                          // debugPrint("create Story ==> ${cubit.mimeType?.name}");
                          contextStories
                              .read<CreateStoriesCubit>()
                              .createStories(
                            cubit.selectedFile!,
                            _captionController.text,
                            context,
                            mimeType: cubit.mimeType,
                            callback: (response) async {
                              // NavigationService().navigateTo(ViewStoriesScreen(
                              //    ));
                              await homeCubit.getStoriesData(1, context);

                              NavigationService().goBack();
                            },
                          );
                        },
                        child: () {
                          if (state is CreateStoriesLoading) {
                            return const CustomLoadingWidget(
                              color: AppColors.white,
                            );
                          } else if (state is CreateStoriesSuccess) {
                            return const Icon(
                              Icons.check,
                              color: AppColors.white,
                            );
                          } else if (state is CreateStoriesError) {
                            return Text(
                              S.of(context).loginButtonTextRe,
                              style: AppTextStyles.medium(
                                fontSize: 16.sp,
                                color: AppColors.white,
                              ),
                            );
                          } else {
                            return Center(
                              child: Text(
                                S.of(context).uploadStory,
                                style: AppTextStyles.medium(
                                  fontSize: 16.sp,
                                  color: AppColors.white,
                                ),
                              ),
                            );
                          }
                        }(),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
