import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:two_one_two_messenger/cubit/chat_cubit.dart';
import 'package:two_one_two_messenger/cubit/chat_state.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/chat_bubble.dart';
import 'package:two_one_two_messenger/widgets/sent_media_widgets.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';

class ChatInputBar extends StatelessWidget {
  final ChatType chatType;
  final String userName;
  final String aesKey;
  final bool isSendMessage;
  final String? currentChatId;
  final UserData? userData;
  final TextEditingController messageCon;
  final FocusNode focusNode;

  const ChatInputBar({
    super.key,
    required this.chatType,
    required this.userName,
    required this.aesKey,
    required this.isSendMessage,
    required this.currentChatId,
    required this.userData,
    required this.messageCon,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(builder: (contextChat, state) {
      if (isSendMessage &&
          !(state.chatMessageModel?.youBlocked ?? false) &&
          !((state.chatMessageModel?.removeFromChat ?? false)) &&
          !(state.chatMessageModel?.otherUserRemoveFromChat ?? false) &&
          !(state.chatMessageModel?.isBlocked ?? false)) {
        return Padding(
          // The global SafeArea in main.dart already reserves the
          // home-indicator inset — don't add viewPadding.bottom
          // again here or the input bar floats above a dead gap.
          padding:
              EdgeInsets.symmetric(horizontal: 16.w).copyWith(bottom: 16.h),
          child: Column(
            children: [
              if (state.replyingToMessage != null)
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppColors.darkInputFill,
                      borderRadius: BorderRadius.all(Radius.circular(14.r))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              S.of(context).replyingTo,
                              style: AppTextStyles.medium(),
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              // setState(() {
                              // replyingToMessage = null;

                              chatCubit.handleReplyMessage(null);
                              // });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Icon(
                                Icons.close,
                                color: AppColors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                      ReplyMessageView(
                        onTapScroll: () {},
                        message: state.replyingToMessage!,
                        isSender:
                            state.replyingToMessage?.sender?.id ==
                                userData?.sId,
                      ),
                    ],
                  ),
                ),
              4.s,
              Row(
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxHeight: 150.h), // Set your max height
                      child: SingleChildScrollView(
                        reverse: true,
                        child: TextField(
                          controller: messageCon,
                          focusNode: focusNode,
                          keyboardAppearance: Brightness.dark,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          maxLines: 5,
                          expands: false,
                          onChanged: (value) {},
                          minLines: 1,
                          style: AppTextStyles.medium(
                            fontSize: 16.sp,
                            color: AppColors.white,
                          ).copyWith(
                            decoration: TextDecoration.none,
                          ),
                          decoration: InputDecoration(
                            hintText: S.of(context).typeMessage,
                            hintStyle: AppTextStyles.regular(
                              fontSize: 14.sp,
                            ),
                            filled: true,
                            fillColor: AppColors.darkInputFill,
                            suffixIcon: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15.w, vertical: 10.h),
                              child: BlocBuilder<ChatCubit, ChatState>(
                                builder: (context, state) {
                                  return InkWell(
                                      onTap: () {
                                        buildBottomSheet(
                                            chatId: currentChatId,
                                            context: context,
                                            aesKey: aesKey,
                                            replyMessage:
                                                state.replyingToMessage,
                                            isFromSavedMessage: false);

                                        // context.read<ChatCubit>().getChatMessages(chatId??"", context);
                                      },
                                      child: SvgPicture.asset(
                                          SvgAssets.icAddRounded));
                                },
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50.r),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () async {
                      showMessage("ChatID::::$currentChatId");

                      if (messageCon.text.trim().isNotEmpty) {
                        await chatCubit
                            .sentMessage(context,
                                mediaType: 0,
                                mimeType: MimeType.none,
                                chatId: currentChatId ?? '',
                                aesKey: aesKey,
                                content: messageCon.text.trim(),
                                replyMessage: state.replyingToMessage
                                // callback: (sentMessageModel) {

                                // },
                                )
                            .then(
                          (value) {
                            messageCon.clear();
                            // context
                            //     .read<ChatCubit>()
                            //     .getChatMessages(
                            //         chatId ?? "", context);
                          },
                        );
                      }
                    },
                    child: Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                          color: AppColors.primaryColor, shape: BoxShape.circle),
                      child: Center(
                          child: SvgImage(source: SvgAssets.icSend)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      } else if ((state.chatMessageModel?.youBlocked ?? false)) {
        return Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: EdgeInsets.all(16.w),
            color: AppColors.dialogBg,
            child:
                Text(S.of(context).blockedUserCannotSendMessage(userName)));
      } else if ((state.chatMessageModel?.removeFromChat ?? false)) {
        return Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: EdgeInsets.all(16.w),
            color: AppColors.dialogBg,
            child: Text(S.of(context).removedUserCannotSendMessage(
                chatType == ChatType.group
                    ? S.of(context).group
                    : S.of(context).channel)));
      } else if ((state.chatMessageModel?.otherUserRemoveFromChat ?? false)) {
        return Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: EdgeInsets.all(16.w),
            color: AppColors.dialogBg,
            child: Text(S.of(context).cannotSendMessageToDeletedUser));
      } else if ((state.chatMessageModel?.isBlocked ?? false)) {
        return Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: EdgeInsets.all(16.w),
            color: AppColors.dialogBg,
            child: Text(
                S.of(context).userBlockedYouSoCannotSendMessage(userName)));
      } else if (!isSendMessage) {
        return Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: EdgeInsets.all(16.w),
            color: AppColors.dialogBg,
            child: Text(S.of(context).onlyAdminsCanSendMessages));
      } else {
        return Container(
          color: Colors.red,
        );
      }
    });
  }
}
