import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:two_one_two_messenger/cubit/home_cubit.dart';
import 'package:two_one_two_messenger/cubit/home_state.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/chat_message_model.dart';
import 'package:two_one_two_messenger/models/conversation_model.dart';
import 'package:two_one_two_messenger/screens/chat_screen.dart';
import 'package:two_one_two_messenger/services/api_config.dart';
import 'package:two_one_two_messenger/services/encryption_service.dart';
import 'package:two_one_two_messenger/services/socket_service.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/widgets/app_check_box.dart';
import 'package:two_one_two_messenger/widgets/buttons.dart';
import 'package:two_one_two_messenger/widgets/keyboard_safe_scaffold.dart';
import 'package:two_one_two_messenger/widgets/forwarded_message_view.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';
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

class ForwardMessageScreen extends StatefulWidget {
  ForwardMessageScreen(
      {super.key,
      required this.user,
      required this.callback,
      required this.message,
      required this.aesKey,
      required this.isFromSavedMessage});
  UserData? user;
  final void Function() callback;
  final MessageModel message;
  final String aesKey;
  final bool isFromSavedMessage;
  @override
  State<ForwardMessageScreen> createState() => _ForwardMessageScreenState();
}

class _ForwardMessageScreenState extends State<ForwardMessageScreen> {
  // final TextEditingController _searchUserController = TextEditingController();
  // final ScrollController _scrollController = ScrollController();
  // int currentPage = 1;
  // final int limit = 10;

  // @override
  // void initState() {
  //   super.initState();
  // }

  Future<void> onInit() async {
    widget.user ??= await homeCubit.dbHelper.getLoginData();
    _scrollController.addListener(_onScroll);
    _fetchInitialData();
  }

  // Future<void> _fetchInitialData() async {
  //   _searchUserController.clear();
  //   homeCubit.getConversation(
  //     context: context,
  //     searchTerm: _searchUserController.text,
  //   );
  //   if (currentPage == 1) {
  //     currentPage++;
  //   }
  // }

  // Timer? timer;
  // void _onSearchTextChange(String name, BuildContext context) {
  //   if (timer != null) {
  //     timer!.cancel();
  //   }
  //   // Fetch data on enter key or when user stops typing
  //   if (_searchUserController.text.isNotEmpty) {
  //     timer = Timer(const Duration(milliseconds: 1000), () {
  //       final searchText = _searchUserController.text.trim();
  //       homeCubit.getConversation(
  //         context: context,
  //         searchTerm: searchText,
  //       );
  //     });
  //   } else {
  //     _fetchInitialData();
  //   }
  // }

  final TextEditingController _searchUserController = TextEditingController();
  final TextEditingController messageCon = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ConversationData> conversations = [];
  final Set<String> selectedConversations = {};
  bool isSelectionMode = false;
  int currentPage = 1;
  final int limit = 10;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    onInit();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchConversations();
      currentPage++;
    }
  }

  Future<void> _fetchInitialData() async {
    _searchUserController.clear();
    _fetchConversations();
    if (currentPage == 1) {
      currentPage++;
    }
  }

  void _fetchConversations() {
    homeCubit.getConversationForForwadMessage(
      context: context,
      searchTerm: _searchUserController.text,
    );
  }

  void _onSearchTextChange(String text) {
    timer?.cancel();
    if (text.isNotEmpty) {
      timer = Timer(const Duration(milliseconds: 1000), _fetchConversations);
    } else {
      _fetchInitialData();
    }
  }

  void _onChatTap(ConversationData conversation) {
    if (isSelectionMode) {
      _toggleSelection(conversation);
    } else {
      _forwardMessage();
    }
  }

  void _onChatLongPress(ConversationData conversation) {
    setState(() {
      isSelectionMode = true;
      _toggleSelection(conversation);
    });
  }

  void _toggleSelection(ConversationData conversation) {
    setState(() {
      if (selectedConversations.length >= 5) {
        Utils.showSnackBar(context, S.current.forwardMessageLimitText);
        return;
      }
      if (selectedConversations.contains(conversation.id)) {
        selectedConversations.remove(conversation.id);
      } else {
        selectedConversations.add(conversation.id!);
      }
      if (selectedConversations.isEmpty) {
        isSelectionMode = false;
      }
    });
  }

  Future<void> _forwardMessage() async {
    String encryptedContent = "";
    final encryptionHelper = EncryptionHelper();
    // if (messageCon.text.trim().isNotEmpty) {
    //   encryptedContent = encryptionHelper.encryptMessage(
    //       messageCon.text.trim() ?? "", widget.aesKey ?? "");
    // }
    showMessage("_forwardMessage==> $encryptedContent");
    List<ConversationData> forwardedToList = conversations
        .where(
          (element) => selectedConversations.contains(element.id),
        )
        .toList();

    if (forwardedToList.length > 5) {
      Utils.showSnackBar(context, S.of(context).forwardMessageLimitText);
      return;
    }
    for (var conversation in forwardedToList) {
      String mainEncryptedContent = encryptionHelper.encryptMessage(
          widget.message.content ?? "", conversation.encryptedAESKey ?? "");
      String mediaContent = encryptionHelper.encryptMessage(
          messageCon.text.trim() ?? "", conversation.encryptedAESKey ?? "");
      if (widget.isFromSavedMessage) {
        SocketService().forwardSavedMessage({
          "mediaContent": mediaContent,
          "content": mainEncryptedContent,
          "sender": widget.user?.sId,
          "messageId": widget.message.messageId,
          "targetChatId": conversation.id
        });
      } else {
        if (conversation.id == widget.message.chatId) {}
        SocketService().forwardMessage({
          "mediaContent": mediaContent,
          "content": mainEncryptedContent,
          "sender": widget.user?.sId,
          "messageId": widget.message.messageId,
          "targetChatId": conversation.id
        });
      }
      showMessage("_forwardMessage==> ${{
        "mediaContent": mediaContent,
        "content": mainEncryptedContent,
        "sender": widget.user?.sId,
        "messageId": widget.message.messageId,
        "targetChatId": conversation.id
      }}");
    }

    if (selectedConversations.length == 1) {
      ConversationData chat = conversations.firstWhere(
        (element) => element.id == selectedConversations.first,
      );

      if (chat.type != ChatType.one_to_one) {
        NavigationService().popUntil();
        await chatCubit.resetChatScreenState();
        await Future.delayed(Durations.long1);

        NavigationService().navigateTo(
            // chatId: chat.id ?? '',
            ChatScreen(
          createdBy: chat.createdBy,
          chatType: chat.type ?? ChatType.group,
          unreadMessageCount: chat.unreadMessageCount ?? 0,
          aesKey: chat.encryptedAESKey ?? "",
          userName: chat.groupName ?? "",
          userId: "",
          userPic: chat.groupImage ?? "",
          chatId: chat.id ?? '',
          lastMessage: chat.lastMessage,
          isSendMessage: chat.isSendMessage ?? true,
          isShowProfileImage: chat.isProfilePhoto ?? true,
        ));
        return;
      } else {
        List<ParticipantDetail> participantList = [];
        participantList = chat.participantDetails
                ?.where((element) => element.id != widget.user?.sId)
                .toList() ??
            [];
        if (participantList.isNotEmpty) {
          // CommonLoader.showLoader();
          debugPrint("Forward message to ${participantList[0].name}");
          NavigationService().popUntil();
          // await Future.delayed(Durations.long1);
          await chatCubit.resetChatScreenState();
          // CommonLoader.hideLoader();
          // await Future.delayed(Durations.long1);
          NavigationService().navigateTo(
              // chatId: chat.id ?? '',
              ChatScreen(
            chatType: chat.type ?? ChatType.one_to_one,
            unreadMessageCount: chat.unreadMessageCount ?? 0,
            aesKey: chat.encryptedAESKey ?? "",
            sender: participantList[0],
            userName: participantList[0].name ?? "",
            userId: participantList[0].id ?? "",
            userPic: participantList[0].profilePicture ?? "",
            chatId: chat.id ?? '',
            lastMessage: chat.lastMessage,
            isSendMessage: chat.isSendMessage ?? true,
            isShowProfileImage: chat.isProfilePhoto ?? true,
          ));
          return;
        }
      }
    }
    // setState(() {
    selectedConversations.clear();
    isSelectionMode = false;
    // });
    NavigationService().goBack();
    // Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    showMessage("forwarded Message==> ${widget.message.type}");
    return KeyboardSafeScaffold(
      appBar: CommonAppBar(
        isBackShow: true,
        title: S.of(context).forwardTo,
        isActionsShow: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: CustomTextField(
                controller: _searchUserController,
                label: S.of(context).searchUsers,
                prefixIcon: SvgImage(
                  source: SvgAssets.icSearch,
                  fit: BoxFit.scaleDown,
                  color: AppColors.white,
                ),
                onChanged: (value) => _onSearchTextChange(
                  value,
                ),
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
                      if ((state.conversationModelForForwardMessages?.data ??
                              [])
                          .isEmpty) {
                        return Center(
                            child: Text(S.of(context).noConversationsFound));
                      }

                      return ListView.separated(
                        controller: _scrollController,
                        separatorBuilder: (context, index) => Divider(
                          color: AppColors.dividerColor,
                          height: 1.h,
                        ),
                        itemCount: state
                            .conversationModelForForwardMessages!.data!.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          List<ParticipantDetail> participantList = [];
                          bool isGroup = state
                                  .conversationModelForForwardMessages
                                  ?.data?[index]
                                  .type !=
                              ChatType.one_to_one;
                          if (!isGroup) {
                            participantList = state
                                    .conversationModelForForwardMessages!
                                    .data![index]
                                    .participantDetails
                                    ?.where((element) =>
                                        element.id != widget.user?.sId)
                                    .toList() ??
                                [];
                          }

                          conversations = List.from(
                              state.conversationModelForForwardMessages!.data!);
                          final conversation = conversations[index];
                          final isSelected =
                              selectedConversations.contains(conversation.id);
                          // if (conversation.id == widget.message.chatId) {
                          //   return SizedBox();
                          // }
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 16.h),
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () => _onChatLongPress(conversation),
                              child: Row(
                                children: [
                                  if (isSelectionMode)
                                    AppCheckBox(
                                      value: isSelected,
                                      onChanged: (value) {
                                        // homeCubit.addToGroup(user,isSelected);
                                      },
                                    ),
                                  if (isSelectionMode) 16.s,
                                  isGroup
                                      ? Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    height: 50.w,
                                                    width: 50.w,
                                                    decoration: BoxDecoration(
                                                      color: AppColors
                                                          .darkInputFill,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: ((conversation
                                                                    .groupImage ??
                                                                "")
                                                            .isNotEmpty)
                                                        ? AppNetworkImage(
                                                            imageUrl:
                                                                '${Urls.mediaUrl}${conversation.groupImage ?? ""}' ??
                                                                    '',
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(
                                                              Radius.circular(
                                                                  50.r),
                                                            ),
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Center(
                                                            child: SvgImage(
                                                              source: isGroup
                                                                  ? (conversation
                                                                              .type ==
                                                                          ChatType
                                                                              .channel)
                                                                      ? SvgAssets
                                                                          .megaphone
                                                                      : SvgAssets
                                                                          .person2
                                                                  : SvgAssets
                                                                      .icPerson,
                                                              color: AppColors
                                                                  .white,
                                                            ),
                                                          ),
                                                  ),
                                                  SizedBox(width: 15.w),
                                                  Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          conversation
                                                                  .groupName ??
                                                              "",
                                                          style: AppTextStyles
                                                              .medium(
                                                                  fontSize:
                                                                      16.sp),
                                                        ),
                                                        SizedBox(height: 5.h),
                                                        Text(
                                                          conversation
                                                                  .lastMessage
                                                                  ?.content ??
                                                              '',
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: AppTextStyles
                                                              .regular(
                                                                  fontSize:
                                                                      12.sp),
                                                        ),
                                                      ]),
                                                ],
                                              ),
                                              // Column(
                                              //   children: [
                                              //     (conversation.unreadMessageCount ??
                                              //                 0) ==
                                              //             0
                                              //         ? SizedBox(
                                              //             height: 22.w,
                                              //             width: 22.w,
                                              //           )
                                              //         : Container(
                                              //             height: 22.w,
                                              //             width: 22.w,
                                              //             decoration: BoxDecoration(
                                              //                 shape: BoxShape
                                              //                     .circle,
                                              //                 color: AppColors
                                              //                     .primaryColor),
                                              //             alignment:
                                              //                 Alignment.center,
                                              //             child: Text(
                                              //               "${conversation.unreadMessageCount ?? 0}",
                                              //               style: AppTextStyles
                                              //                   .medium(
                                              //                       fontSize:
                                              //                           12.sp,
                                              //                       color: AppColors
                                              //                           .white),
                                              //             ),
                                              //           ),
                                              //     SizedBox(height: 10.h),
                                              //     if (conversation.lastMessage
                                              //             ?.createdAt !=
                                              //         null)
                                              //       Text(
                                              //         (conversation.lastMessage
                                              //                     ?.createdAt ??
                                              //                 DateTime.now())
                                              //             .formatMessageTimestamp(),
                                              //         style:
                                              //             AppTextStyles.regular(
                                              //                 fontSize: 12.sp,
                                              //                 color: AppColors
                                              //                     .white
                                              //                     .withValues(alpha:
                                              //                         0.65)),
                                              //       ),
                                              //   ],
                                              // )
                                            ],
                                          ),
                                        )
                                      : Expanded(
                                          child: Column(
                                            children: List.generate(
                                              participantList.length,
                                              (ind) => Row(
                                                children: [
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          height: 50.w,
                                                          width: 50.w,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: AppColors
                                                                .darkInputFill,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: (participantList[
                                                                          ind]
                                                                      .profilePicture !=
                                                                  null)
                                                              ? AppNetworkImage(
                                                                  imageUrl:
                                                                      '${Urls.mediaUrl}${participantList[ind].profilePicture}' ??
                                                                          '',
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                                    Radius.circular(
                                                                        50.r),
                                                                  ),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                              : Center(
                                                                  child:
                                                                      SvgImage(
                                                                    source: SvgAssets
                                                                        .icPerson,
                                                                    color: AppColors
                                                                        .white,
                                                                  ),
                                                                ),
                                                        ),
                                                        SizedBox(width: 15.w),
                                                        Expanded(
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  AppMethods.getNickNameForParticipateDetails(
                                                                      participantList[
                                                                          ind]),
                                                                  // participantList[ind].name ??'',
                                                                  softWrap:
                                                                      true,
                                                                  style: AppTextStyles
                                                                      .medium(
                                                                          fontSize:
                                                                              16.sp),
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        5.h),
                                                                Text(
                                                                  conversation
                                                                          .lastMessage
                                                                          ?.content ??
                                                                      '',
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: AppTextStyles
                                                                      .regular(
                                                                          fontSize:
                                                                              12.sp),
                                                                ),
                                                              ]),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Column(
                                                  //   children: [
                                                  //     (conversation.unreadMessageCount ??
                                                  //                 0) ==
                                                  //             0
                                                  //         ? SizedBox(
                                                  //             height: 22.w,
                                                  //             width: 22.w,
                                                  //           )
                                                  //         : Container(
                                                  //             height: 22.w,
                                                  //             width: 22.w,
                                                  //             decoration: BoxDecoration(
                                                  //                 shape: BoxShape
                                                  //                     .circle,
                                                  //                 color: AppColors
                                                  //                     .primaryColor),
                                                  //             alignment:
                                                  //                 Alignment
                                                  //                     .center,
                                                  //             child: Text(
                                                  //               "${conversation.unreadMessageCount ?? 0}",
                                                  //               style: AppTextStyles.medium(
                                                  //                   fontSize:
                                                  //                       12.sp,
                                                  //                   color: AppColors
                                                  //                       .white),
                                                  //             ),
                                                  //           ),
                                                  //     SizedBox(height: 10.h),
                                                  //     if (conversation
                                                  //             .lastMessage
                                                  //             ?.createdAt !=
                                                  //         null)
                                                  //       Text(
                                                  //         (conversation
                                                  //                     .lastMessage
                                                  //                     ?.createdAt ??
                                                  //                 DateTime
                                                  //                     .now())
                                                  //             .formatMessageTimestamp(),
                                                  //         style: AppTextStyles
                                                  //             .regular(
                                                  //                 fontSize:
                                                  //                     12.sp,
                                                  //                 color: AppColors
                                                  //                     .white
                                                  //                     .withValues(alpha:
                                                  //                         0.65)),
                                                  //       ),
                                                  //   ],
                                                  // )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else if (state.homeLoadingState == LoadingState.error) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                              child: Text(S
                                  .of(context)
                                  .somethingWentWrongPleaseTryAgain)),
                          20.s,
                          CustomButton(
                              onPressed: () {
                                _fetchInitialData();
                              },
                              child: Text(
                                S.of(context).refresh,
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: ForwadedMessageView(message: widget.message)),
                      if ((widget.message.type == 'text' ||
                              widget.message.type == 'mixed') &&
                          selectedConversations.isNotEmpty)
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            // showMessage("ChatID::::$chatId");
                            _forwardMessage();
                            // context.read<ChatCubit>().getChatMessages(chatId??"", context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: AppColors.buttonColor,
                                shape: BoxShape.circle),
                            margin: EdgeInsets.only(left: 4.w),
                            padding: EdgeInsets.all(10.h),
                            child: SvgPicture.asset(SvgAssets.icSend),
                          ),
                        ),
                    ],
                  ),
                  4.s,
                  if (widget.message.type == 'text' ||
                      widget.message.type == 'mixed')
                    SizedBox()
                  else
                    Row(
                      children: [
                        // if (widget.message.type == 'text' ||
                        //     widget.message.type == 'mixed')
                        //   Expanded(
                        //     child: Text(
                        //       S
                        //           .of(context)
                        //           .countSelected(selectedConversations.length),
                        //       overflow: TextOverflow.ellipsis,
                        //       style: AppTextStyles.regular(),
                        //     ),
                        //   )
                        // else
                        Expanded(
                          child: TextField(
                            controller: messageCon,
                            style: AppTextStyles.medium(
                              fontSize: 16.sp,
                              color: AppColors.white,
                            ).copyWith(
                              decoration: TextDecoration.none,
                            ),
                            decoration: InputDecoration(
                              hintText: S.of(context).addMessage,
                              hintStyle: AppTextStyles.regular(
                                fontSize: 14.sp,
                              ),
                              filled: true,
                              fillColor: AppColors.darkInputFill,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.r),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        if (selectedConversations.isNotEmpty)
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              // showMessage("ChatID::::$chatId");
                              _forwardMessage();
                              // context.read<ChatCubit>().getChatMessages(chatId??"", context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: AppColors.buttonColor,
                                  shape: BoxShape.circle),
                              margin: EdgeInsets.only(left: 4.w),
                              padding: EdgeInsets.all(10.h),
                              child: SvgPicture.asset(SvgAssets.icSend),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
