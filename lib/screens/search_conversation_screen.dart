import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:two_one_two_messenger/GoogleAds/BannerAds/BannerAdManager.dart';
import 'package:two_one_two_messenger/cubit/home_cubit.dart';
import 'package:two_one_two_messenger/cubit/home_state.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/conversation_model.dart';
import 'package:two_one_two_messenger/widgets/buttons.dart';
import 'package:two_one_two_messenger/widgets/conversation_tile.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';
import 'package:two_one_two_messenger/widgets/keyboard_safe_scaffold.dart';
import 'package:two_one_two_messenger/widgets/refresh_indicator%20copy.dart';

import '../models/otp_verify.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/text_style.dart';
import '../utils/utils.dart';
import '../widgets/appbar.dart';
import '../widgets/network_image.dart';
import '../widgets/svg_images.dart';
import '../widgets/text_fields.dart';

class SearchConversationScreen extends StatefulWidget {
  SearchConversationScreen({super.key, required this.user});
  UserData? user;
  @override
  State<SearchConversationScreen> createState() =>
      _SearchConversationScreenState();
}

class _SearchConversationScreenState extends State<SearchConversationScreen> {
  final TextEditingController _searchUserController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int currentPage = 1;
  final int limit = 10;

  @override
  void initState() {
    super.initState();
  }

  Future<void> onInit() async {
    widget.user ??= await homeCubit.dbHelper.getLoginData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        homeCubit.getConversation(
          context: context,
          searchTerm: _searchUserController.text,
        );
        // (
        //     _searchUserController.text, currentPage, limit, context);
        currentPage++;
      }
    });

    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    _searchUserController.clear();
    homeCubit.getConversation(
      context: context,
      searchTerm: _searchUserController.text,
    );
    if (currentPage == 1) {
      currentPage++;
    }
  }

  Timer? timer;
  void _onSearchTextChange(String name, BuildContext context) {
    if (timer != null) {
      timer!.cancel();
    }
    // Fetch data on enter key or when user stops typing
    if (_searchUserController.text.isNotEmpty) {
      timer = Timer(const Duration(milliseconds: 1000), () {
        final searchText = _searchUserController.text.trim();
        homeCubit.getConversation(
          context: context,
          searchTerm: searchText,
        );
      });
    } else {
      _fetchInitialData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardSafeScaffold(
      appBar: CommonAppBar(
        isBackShow: true,
        title: S.of(context).lblSearchChat,
        isActionsShow: false,
      ),
      bottomNavigationBar: const BannerAdManager(),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: CustomTextField(
                controller: _searchUserController,
                label: S.of(context).searchConversations,
                textInputAction: TextInputAction.go,
                prefixIcon: SvgImage(
                  source: SvgAssets.icSearch,
                  fit: BoxFit.scaleDown,
                  color: AppColors.white,
                ),
                onChanged: (value) => _onSearchTextChange(value, context),
                validator: (value) {
                  return null;
                },
              ),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: CustomRefreshIndicator(
                onRefresh: () async {
                  _fetchInitialData();
                },
                child: BlocBuilder<HomeCubit, HomeState>(
                  // buildWhen: (previous, current) =>
                  //     current is HomeLoading ||
                  //     current is HomeLoaded ||
                  //     current is HomeError,
                  builder: (context, state) {
                    if (state.homeLoadingState == LoadingState.loading) {
                      return Center(child: CustomLoadingWidget());
                    } else if (state.homeLoadingState == LoadingState.success) {
                      if ((state.conversationModel?.data ?? []).isEmpty) {
                        return Center(child: Text("No Conversations Found"));
                      }

                      return SlidableAutoCloseBehavior(
                        child: ListView.separated(
                          controller: _scrollController,
                          separatorBuilder: (context, index) => Divider(
                            color: AppColors.dividerColor,
                            height: 1.h,
                          ),
                          itemCount: state.conversationModel!.data!.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            // List<ParticipantDetail> participantList = [];
                            // bool isGroup =
                            //     state.conversationModel?.data?[index].type !=
                            //         ChatType.one_to_one;
                            // if (!isGroup) {
                            //   participantList = state.conversationModel!
                            //           .data![index].participantDetails
                            //           ?.where((element) =>
                            //               element.id != widget.user?.sId)
                            //           .toList() ??
                            //       [];
                            // }
                            ParticipantDetail? participant;
                            bool isGroup =
                                state.conversationModel!.data![index].type !=
                                    ChatType.one_to_one;
                            if (!isGroup) {
                              try {
                                participant = state.conversationModel
                                    ?.data?[index].participantDetails
                                    ?.firstWhere((element) =>
                                        element.id != widget.user?.sId);
                              } catch (e) {
                                participant = null;
                              }
                            }
                            if (widget.user == null) return SizedBox();
                            return ConversationTile(
                                user: widget.user!,
                                isGroup: isGroup,
                                isArchive: false,
                                conversationData:
                                    state.conversationModel!.data![index],
                                participantDetails: participant);

                            // Padding(
                            //   padding: EdgeInsets.symmetric(
                            //       horizontal: 16.w, vertical: 16.h),
                            //   child: isGroup
                            //       ? GestureDetector(
                            //           behavior: HitTestBehavior.translucent,
                            //           onTap: () {
                            //             NavigationService().navigateTo(ChatScreen(
                            //               createdBy: state.conversationModel
                            //                   ?.data?[index].createdBy,
                            //               chatType: state.conversationModel
                            //                       ?.data?[index].type ??
                            //                   ChatType.group,
                            //               unreadMessageCount: state
                            //                       .conversationModel
                            //                       ?.data?[index]
                            //                       .unreadMessageCount ??
                            //                   0,
                            //               aesKey: state
                            //                       .conversationModel
                            //                       ?.data?[index]
                            //                       .encryptedAESKey ??
                            //                   "",
                            //               userName: state.conversationModel!
                            //                       .data![index].groupName ??
                            //                   "",
                            //               userId: "",
                            //               userPic: state.conversationModel!
                            //                       .data![index].groupImage ??
                            //                   "",
                            //               chatId: state.conversationModel!
                            //                       .data![index].id ??
                            //                   '',
                            //               lastMessage: state.conversationModel
                            //                   ?.data?[index].lastMessage,
                            //               isSendMessage: state.conversationModel
                            //                       ?.data?[index].isSendMessage ??
                            //                   true,
                            //               isShowProfileImage: state
                            //                       .conversationModel
                            //                       ?.data?[index]
                            //                       .isProfilePhoto ??
                            //                   true,
                            //             ));
                            //           },
                            //           child: Row(
                            //             children: [
                            //               Container(
                            //                 height: 50.w,
                            //                 width: 50.w,
                            //                 decoration: BoxDecoration(
                            //                   color: AppColors.darkInputFill,
                            //                   shape: BoxShape.circle,
                            //                 ),
                            //                 child: ((state
                            //                                 .conversationModel
                            //                                 ?.data?[index]
                            //                                 .groupImage ??
                            //                             "")
                            //                         .isNotEmpty)
                            //                     ? AppNetworkImage(
                            //                         imageUrl:
                            //                             '${Urls.mediaUrl}${state.conversationModel?.data?[index].groupImage ?? ""}' ??
                            //                                 '',
                            //                         borderRadius:
                            //                             BorderRadius.all(
                            //                           Radius.circular(50.r),
                            //                         ),
                            //                         fit: BoxFit.cover,
                            //                       )
                            //                     : Center(
                            //                         child: SvgImage(
                            //                           source: SvgAssets.icPerson,
                            //                           color: AppColors.white,
                            //                         ),
                            //                       ),
                            //               ),
                            //               SizedBox(width: 15.w),
                            //               Expanded(
                            //                 child: Column(
                            //                     crossAxisAlignment:
                            //                         CrossAxisAlignment.start,
                            //                     children: [
                            //                       Text(
                            //                         state
                            //                                 .conversationModel
                            //                                 ?.data?[index]
                            //                                 .groupName ??
                            //                             "",
                            //                         style: AppTextStyles.medium(
                            //                             fontSize: 16.sp),
                            //                       ),
                            //                       SizedBox(height: 5.h),
                            //                       Text(
                            //                         state
                            //                                 .conversationModel!
                            //                                 .data![index]
                            //                                 .lastMessage
                            //                                 ?.content ??
                            //                             '',
                            //                         maxLines: 2,
                            //                         overflow:
                            //                             TextOverflow.ellipsis,
                            //                         style: AppTextStyles.regular(
                            //                             fontSize: 12.sp),
                            //                       ),
                            //                     ]),
                            //               ),
                            //               Column(
                            //                 children: [
                            //                   (state
                            //                                   .conversationModel
                            //                                   ?.data?[index]
                            //                                   .unreadMessageCount ??
                            //                               0) ==
                            //                           0
                            //                       ? SizedBox(
                            //                           height: 22.w,
                            //                           width: 22.w,
                            //                         )
                            //                       : Container(
                            //                           height: 22.w,
                            //                           width: 22.w,
                            //                           decoration: BoxDecoration(
                            //                               shape: BoxShape.circle,
                            //                               color: AppColors
                            //                                   .primaryColor),
                            //                           alignment: Alignment.center,
                            //                           child: Text(
                            //                             "${state.conversationModel?.data?[index].unreadMessageCount ?? 0}",
                            //                             style:
                            //                                 AppTextStyles.medium(
                            //                                     fontSize: 12.sp,
                            //                                     color: AppColors
                            //                                         .white),
                            //                           ),
                            //                         ),
                            //                   SizedBox(height: 10.h),
                            //                   if (state
                            //                           .conversationModel!
                            //                           .data![index]
                            //                           .lastMessage
                            //                           ?.createdAt !=
                            //                       null)
                            //                     Text(
                            //                       (state
                            //                                   .conversationModel!
                            //                                   .data![index]
                            //                                   .lastMessage
                            //                                   ?.createdAt ??
                            //                               DateTime.now())
                            //                           .formatMessageTimestamp(),
                            //                       style: AppTextStyles.regular(
                            //                           fontSize: 12.sp,
                            //                           color: AppColors.white
                            //                               .withValues(alpha:0.65)),
                            //                     ),
                            //                 ],
                            //               )
                            //             ],
                            //           ),
                            //         )
                            //       : Column(
                            //           children: List.generate(
                            //             participantList.length,
                            //             (ind) => GestureDetector(
                            //               behavior: HitTestBehavior.translucent,
                            //               onTap: () {
                            //                 NavigationService()
                            //                     .navigateTo(ChatScreen(
                            //                   chatType: state.conversationModel
                            //                           ?.data?[index].type ??
                            //                       ChatType.one_to_one,
                            //                   unreadMessageCount: state
                            //                           .conversationModel
                            //                           ?.data?[index]
                            //                           .unreadMessageCount ??
                            //                       0,
                            //                   aesKey: state
                            //                           .conversationModel
                            //                           ?.data?[index]
                            //                           .encryptedAESKey ??
                            //                       "",
                            //                   sender: participantList[ind],
                            //                   userName:
                            //                       participantList[ind].name ?? "",
                            //                   userId:
                            //                       participantList[ind].id ?? "",
                            //                   userPic: participantList[ind]
                            //                           .profilePicture ??
                            //                       "",
                            //                   chatId: state.conversationModel!
                            //                           .data![index].id ??
                            //                       '',
                            //                   lastMessage: state.conversationModel
                            //                       ?.data?[index].lastMessage,
                            //                   isSendMessage: state
                            //                           .conversationModel
                            //                           ?.data?[index]
                            //                           .isSendMessage ??
                            //                       true,
                            //                   isShowProfileImage: state
                            //                           .conversationModel
                            //                           ?.data?[index]
                            //                           .isProfilePhoto ??
                            //                       true,
                            //                 ));
                            //               },
                            //               child: Row(
                            //                 children: [
                            //                   Container(
                            //                     height: 50.w,
                            //                     width: 50.w,
                            //                     decoration: BoxDecoration(
                            //                       color: AppColors.darkInputFill,
                            //                       shape: BoxShape.circle,
                            //                     ),
                            //                     child: (participantList[ind]
                            //                                 .profilePicture !=
                            //                             null)
                            //                         ? AppNetworkImage(
                            //                             imageUrl:
                            //                                 '${Urls.mediaUrl}${participantList[ind].profilePicture}' ??
                            //                                     '',
                            //                             borderRadius:
                            //                                 BorderRadius.all(
                            //                               Radius.circular(50.r),
                            //                             ),
                            //                             fit: BoxFit.cover,
                            //                           )
                            //                         : Center(
                            //                             child: SvgImage(
                            //                               source:
                            //                                   SvgAssets.icPerson,
                            //                               color: AppColors.white,
                            //                             ),
                            //                           ),
                            //                   ),
                            //                   SizedBox(width: 15.w),
                            //                   Expanded(
                            //                     child: Column(
                            //                         crossAxisAlignment:
                            //                             CrossAxisAlignment.start,
                            //                         children: [
                            //                           Text(
                            //                             participantList[ind]
                            //                                     .name ??
                            //                                 '',
                            //                             style:
                            //                                 AppTextStyles.medium(
                            //                                     fontSize: 16.sp),
                            //                           ),
                            //                           SizedBox(height: 5.h),
                            //                           Text(
                            //                             state
                            //                                     .conversationModel!
                            //                                     .data![index]
                            //                                     .lastMessage
                            //                                     ?.content ??
                            //                                 '',
                            //                             maxLines: 2,
                            //                             overflow:
                            //                                 TextOverflow.ellipsis,
                            //                             style:
                            //                                 AppTextStyles.regular(
                            //                                     fontSize: 12.sp),
                            //                           ),
                            //                         ]),
                            //                   ),
                            //                   Column(
                            //                     children: [
                            //                       (state
                            //                                       .conversationModel
                            //                                       ?.data?[index]
                            //                                       .unreadMessageCount ??
                            //                                   0) ==
                            //                               0
                            //                           ? SizedBox(
                            //                               height: 22.w,
                            //                               width: 22.w,
                            //                             )
                            //                           : Container(
                            //                               height: 22.w,
                            //                               width: 22.w,
                            //                               decoration: BoxDecoration(
                            //                                   shape:
                            //                                       BoxShape.circle,
                            //                                   color: AppColors
                            //                                       .primaryColor),
                            //                               alignment:
                            //                                   Alignment.center,
                            //                               child: Text(
                            //                                 "${state.conversationModel?.data?[index].unreadMessageCount ?? 0}",
                            //                                 style: AppTextStyles
                            //                                     .medium(
                            //                                         fontSize:
                            //                                             12.sp,
                            //                                         color: AppColors
                            //                                             .white),
                            //                               ),
                            //                             ),
                            //                       SizedBox(height: 10.h),
                            //                       if (state
                            //                               .conversationModel!
                            //                               .data![index]
                            //                               .lastMessage
                            //                               ?.createdAt !=
                            //                           null)
                            //                         Text(
                            //                           (state
                            //                                       .conversationModel!
                            //                                       .data![index]
                            //                                       .lastMessage
                            //                                       ?.createdAt ??
                            //                                   DateTime.now())
                            //                               .formatMessageTimestamp(),
                            //                           style:
                            //                               AppTextStyles.regular(
                            //                                   fontSize: 12.sp,
                            //                                   color: AppColors
                            //                                       .white
                            //                                       .withValues(alpha:
                            //                                           0.65)),
                            //                         ),
                            //                     ],
                            //                   )
                            //                 ],
                            //               ),
                            //             ),
                            //           ),
                            //         ),
                            // );
                          },
                        ),
                      );
                    } else if (state.homeLoadingState == LoadingState.error) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                              child: Text(
                                  "Something went wrong!, please try again")),
                          20.s,
                          CustomButton(
                              onPressed: () {
                                _fetchInitialData();
                              },
                              child: Text(
                                "Refresh",
                                style: AppTextStyles.baseStyle(),
                              ))
                        ],
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildListTile({
    required String image,
    required String name,
    required String subTittle,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        child: Row(
          children: [
            Container(
              width: 60.w,
              height: 60.h,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.medium(
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(
                  height: 8.h,
                ),
                Text(
                  subTittle,
                  style: AppTextStyles.regular(
                      fontSize: 12.sp, color: AppColors.textColorThird),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
