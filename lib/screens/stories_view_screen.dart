import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:two_one_two_messenger/GoogleAds/BannerAds/BannerAdManager.dart';
import 'package:two_one_two_messenger/extension/date_format.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/models/stories_response.dart';
import 'package:two_one_two_messenger/screens/user_profile.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/extensions.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/widgets/avatar_widgets.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';
import '../cubit/stories_cubit.dart';
import '../cubit/stories_state.dart';
import '../services/api_client.dart';
import '../utils/colors.dart';
import '../utils/navigation.dart';
import '../utils/utils.dart';
import '../widgets/network_image.dart';

class StoriesViewScreen extends StatefulWidget {
  final List<GetAllStoriesData> storiesList;
  final int index;

  const StoriesViewScreen(
      {super.key, this.storiesList = const [], this.index = 0});

  @override
  State<StoriesViewScreen> createState() => _StoriesViewScreenState();
}

class _StoriesViewScreenState extends State<StoriesViewScreen>
    with SingleTickerProviderStateMixin {
  final StoryController controller = StoryController();

  ValueNotifier<int> currentStoryIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    final storiesCubit = context.read<StoriesCubit>();
    storiesCubit.initializeAnimation(this);
    storiesCubit.loadStories(widget.storiesList, widget.index);
    showMessage("fetchMoreStories 1");
    storiesCubit.pageController.removeListener(
      () {},
    );
    storiesCubit.pageController.addListener(() {
      final currentIndex = storiesCubit.pageController.page?.toInt() ?? 0;
      showMessage("fetchMoreStories 1");
      if (currentIndex >= storiesCubit.stories.length - 2) {
        // Fetch more stories when reaching the second last item
        showMessage("fetchMoreStories");
        storiesCubit.fetchMoreStories(context);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    context.read<StoriesCubit>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
        title: BlocBuilder<BannerLoadCubit, BannerLoadState>(
            builder: (contextStories, state) {
          if (state is BannerLoadLoaded) {
            showMessage("banner is loaded");
            return const BannerAdManager();
          }
          return const SizedBox();
        }),
      ),

      //  CommonAppBar(
      //   isBackShow: true,
      //   isActionsShow: false,

      // ),
      body: BlocBuilder<StoriesCubit, StoriesState>(
          builder: (contextStories, state) {
        final storiesCubit = contextStories.read<StoriesCubit>();
        if (state.isCompleted) {
          NavigationService().goBack();
          return SizedBox.shrink();
        } else if (state.stories.isNotEmpty) {
          return PageView.builder(
            controller: storiesCubit.pageController,
            itemCount: state.stories.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              // showMessage("PageView.builder == $index");
              return GestureDetector(
                onHorizontalDragEnd: storiesCubit.onHorizontalDragEnd,
                onHorizontalDragStart: storiesCubit.onHorizontalDragStart,
                onHorizontalDragUpdate: storiesCubit.onHorizontalDragUpdate,
                child: Stack(
                  children: [
                    StoryView(
                      controller: controller,
                      storyItems: state.stories[index].stories!.map((e) {
                        // showMessage(
                        //     "PageView.builder StoryView== ${e.userDetails?.userName}");
                        // Check if the media type is a video or image and create StoryItem accordingly
                        return (Utils.getMediaType(e.mediaType!) ==
                                MimeType.video)
                            ? StoryItem.pageVideo(
                                '${Urls.mediaUrl}${e.mediaUrl}',
                                controller: controller,
                                duration: Duration(seconds: e.duration ?? 10),
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
                                    color: AppColors.purpleText,
                                    // backgroundColor: Colors.black54,
                                    fontSize: 17,
                                  ),
                                ),
                                // createDate: e.createdAt
                              );
                      }).toList(),
                      onStoryShow: (storyItem, sIndex) {
                        showMessage("Showing a story $sIndex");
                        currentStoryIndex.value = sIndex;

                        final currentStory =
                            state.stories[index].stories![sIndex];
                        contextStories
                            .read<StoriesCubit>()
                            .viewerStoriesUpdate(currentStory.sId!, context);
                      },
                      onComplete: () {
                        if (index >= storiesCubit.stories.length - 2) {
                          // Fetch more stories when reaching the second last item
                          showMessage("fetchMoreStories");
                          storiesCubit.fetchMoreStories(context);
                        }
                        storiesCubit.moveForward();
                      },
                      progressPosition: ProgressPosition.top,
                      repeat: false,
                      inline: true,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        top: 48,
                        left: 16,
                        right: 16,
                      ),
                      child: _buildProfileView(
                        state.stories[index],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        } else {
          return Center(
            child: CustomLoadingWidget(
              color: AppColors.white,
            ),
          );
        }
      }),
    );
  }

  Widget _buildProfileView(GetAllStoriesData data) {
    return Container(
      // color: Colors.red,
      height: 70,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () async {
              if (data.userDetails != null) {
                controller.pause();
                await NavigationService().navigateTo(UserProfileScreen(
                  user: data.userDetails!,
                ));
                controller.play();
              }
            },
            child: AvatarWidgets(
              userPic: data.userDetails?.profilePicture ?? "",
              height: 50,
              width: 50,
            ),
            // Container(
            //   width: 50.w,
            //   height: 50.w,
            //   decoration: BoxDecoration(
            //     color: AppColors.darkInputFill,
            //     shape: BoxShape.circle,
            //   ),
            //   child: ClipOval(
            //     child: AvatarWidgets(
            //         imageUrl:
            //             '${Urls.mediaUrl}${data.userDetails?.profilePicture}'),
            //   ),
            // ),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  // data.userDetails?.name ?? '',
                  (data.userDetails?.isActiveNickname ?? false)
                      ? (data.userDetails?.nickName ??
                          data.userDetails?.name ??
                          data.userDetails?.userName ??
                          "")
                      : (data.userDetails?.name ??
                          data.userDetails?.userName ??
                          ""),
                  maxLines: 1,
                  style: AppTextStyles.medium(),
                ),
                // SizedBox(height: 5),
                ValueListenableBuilder<int>(
                  valueListenable: currentStoryIndex,
                  builder: (context, value, child) {
                    final date = data.stories?[value].createdAt;
                    return Text(
                      date?.storyTime ?? "",
                      maxLines: 1,
                    );
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
