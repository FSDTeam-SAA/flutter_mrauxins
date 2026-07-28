import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/cubit/chat_cubit.dart';
import 'package:two_one_two_messenger/cubit/chat_state.dart';
import 'package:two_one_two_messenger/cubit/saved_messages_cubit.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/chat_message_model.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/models/saved_messages.dart';
import 'package:two_one_two_messenger/screens/forward_message_screen.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/buttons.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';
import 'dart:math' as math;

void buildMessageSaveAndDeleteDialog(
    {required BuildContext context,
    required int index,
    required Offset offset,
    required bool isSender,
    required MessageModel message,
    required String? aesKey}) {
  showMenu<ChatMessageOption>(
    context: context,
    color: AppColors.dark,
    position: isSender
        ? RelativeRect.fromLTRB(
            offset.dx, offset.dy, 0, 0) // Sender (right-side)
        : RelativeRect.fromLTRB(
            0, offset.dy, context.w - offset.dx, 0), // Receiver (left-side),
    items: [
      // PopupMenuItem<ChatMessageOption>(
      //   value: ChatMessageOption.reply,
      //   child: Row(
      //     children: [
      //       Icon(
      //         Icons.reply_outlined,
      //         color: AppColors.white,
      //       ),
      //       // SvgImage(
      //       //   source: SvgAssets.copy,
      //       //   color: AppColors.white,
      //       // ),
      //       8.s,
      //       Text(S.current.reply, style: AppTextStyles.regular()),
      //     ],
      //   ),
      //   onTap: () {
      //     showMessage("TempMessage==> ${message.toJson()}");

      //     // Utils.copyToClipboard(context, message.content ?? "");
      //   },
      // ),
      PopupMenuItem<ChatMessageOption>(
        value: ChatMessageOption.react,
        child: Row(
          children: [
            Icon(Icons.emoji_emotions_outlined, color: AppColors.white),
            SizedBox(width: 8),
            Text(S.of(context).react, style: AppTextStyles.regular()),
          ],
        ),
        onTap: () async {
          // showModalBottomSheet(
          //   context: context,
          //   builder: (context) {
          //     return SizedBox(
          //       height: 310,
          //       child: EmojiPicker(
          //         onEmojiSelected: ((category, emoji) {
          //           // pop the bottom sheet
          //           Navigator.pop(context);
          //           // addReactionToMessage(
          //           //   message: message,
          //           //   reaction: emoji.emoji,
          //           // );
          //         }),
          //       ),
          //     );
          //   },
          // );
        },
      ),
      PopupMenuItem<ChatMessageOption>(
        value: ChatMessageOption.saveMessage,
        child: Row(
          children: [
            SvgImage(
              source: SvgAssets.icBookmarks,
              color: AppColors.white,
            ),
            8.s,
            Text(S.current.saveMessage, style: AppTextStyles.regular()),
          ],
        ),
        onTap: () {
          showMessage("TempMessage==> ${message.toJson()}");

          context.read<SavedMessagesCubit>().saveMessages(
            chatId: message.chatId ?? "",
            context: context,
            isTempMessage: message.id == message.messageId,
            messageId: message.id ?? '',
            callback: (response) {
              Utils.showSnackBar(context, response.message ?? '', seconds: 3);
            },
          );
        },
      ),
      if (message.type == 'text' || message.type == 'mixed')
        PopupMenuItem<ChatMessageOption>(
          value: ChatMessageOption.copy,
          child: Row(
            children: [
              Icon(
                Icons.copy,
                color: AppColors.white,
              ),
              // SvgImage(
              //   source: SvgAssets.copy,
              //   color: AppColors.white,
              // ),
              8.s,
              Text(S.current.copy, style: AppTextStyles.regular()),
            ],
          ),
          onTap: () {
            showMessage("TempMessage==> ${message.toJson()}");

            Utils.copyToClipboard(context, message.content ?? "");
          },
        ),
      PopupMenuItem<ChatMessageOption>(
        value: ChatMessageOption.pin,
        child: Row(
          children: [
            Icon(
              (message.pinned ?? false)
                  ? CupertinoIcons.pin_slash_fill
                  : CupertinoIcons.pin_fill,
              color: AppColors.white,
            ),
            // SvgImage(
            //   source: SvgAssets.copy,
            //   color: AppColors.white,
            // ),
            8.s,
            Text((message.pinned ?? false) ? S.current.unPin : S.current.pin,
                style: AppTextStyles.regular()),
          ],
        ),
        onTap: () {
          showMessage("TempMessage==> ${message.toJson()}");
          if (message.pinned ?? false) {
            chatCubit.unPinMessage(
                messageId: message.messageId ?? "",
                chatId: message.chatId ?? "");
          } else {
            chatCubit.pinMessage(
                messageId: message.messageId ?? "",
                chatId: message.chatId ?? "");
          }
        },
      ),
      if (aesKey != null)
        PopupMenuItem<ChatMessageOption>(
          value: ChatMessageOption.forward,
          child: Row(
            children: [
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                child: Icon(
                  Icons.reply_outlined,
                  color: AppColors.white,
                ),
              ),
              // SvgImage(
              //   source: SvgAssets.copy,
              //   color: AppColors.white,
              // ),
              8.s,
              Text(S.current.forward, style: AppTextStyles.regular()),
            ],
          ),
          onTap: () async {
            showMessage("TempMessage==> ${message.toJson()}");
            UserData? user = await homeCubit.dbHelper.getLoginData();
            NavigationService().navigateTo(ForwardMessageScreen(
                isFromSavedMessage: false,
                aesKey: aesKey,
                user: user,
                callback: () {},
                message: message));
          },
        ),

      if (isSender) ...[
        PopupMenuItem<ChatMessageOption>(
          value: ChatMessageOption.deleteMessage,
          child: Row(
            children: [
              SvgImage(
                source: SvgAssets.icTrash,
                color: AppColors.white.withValues(alpha: 0.6),
              ),
              8.s,
              Text(S.current.lblDeleteMessage, style: AppTextStyles.regular()),
            ],
          ),
          onTap: () {
            buildDeleteMessagePopup(
                context: context,
                index: index,
                offset: offset,
                isSender: isSender,
                message: message);
          },
        ),
        if ((message.type == 'text' || message.type == 'mixed') &&
            (aesKey ?? "").isNotEmpty)
          PopupMenuItem<ChatMessageOption>(
            value: ChatMessageOption.edit,
            child: Row(
              children: [
                SvgImage(
                  source: SvgAssets.icEdit,
                  color: AppColors.white.withValues(alpha: 0.6),
                ),
                8.s,
                Text(S.current.edit, style: AppTextStyles.regular()),
              ],
            ),
            onTap: () {
              showEditMessageDialog(context, message, aesKey!);
            },
          ),
      ],
    ],
  ).then((value) {
    if (value != null) {
      // Handle the selected value
      showMessage('Selected: $value');
    }
  });
}

void buildDeleteMessagePopup(
    {required BuildContext context,
    required int index,
    required Offset offset,
    required bool isSender,
    required MessageModel message}) {
  showMenu<ChatMessageDeleteOption>(
    context: context,
    color: AppColors.dark,
    position: isSender
        ? RelativeRect.fromLTRB(
            offset.dx, offset.dy, 0, 0) // Sender (right-side)
        : RelativeRect.fromLTRB(
            0, offset.dy, context.w - offset.dx, 0), // Receiver (left-side),
    items: [
      PopupMenuItem<ChatMessageDeleteOption>(
        value: ChatMessageDeleteOption.deleteForMe,
        child: Row(
          children: [
            SvgImage(
              source: SvgAssets.icTrash,
              color: AppColors.white.withValues(alpha: 0.6),
            ),
            8.s,
            Text(S.current.deleteForMe, style: AppTextStyles.regular()),
          ],
        ),
        onTap: () {
          showDeleteMessageDialog(
              context: context,
              index: index,
              message: message,
              deleteForEveryOne: false,
              isFromSavedMessage: false);
        },
      ),
      if (Utils.canEditOrDeleteMessage(message.createdAt ?? DateTime.now()))
        PopupMenuItem<ChatMessageDeleteOption>(
          value: ChatMessageDeleteOption.deleteForEveryone,
          child: Row(
            children: [
              SvgImage(
                source: SvgAssets.icTrash,
                color: AppColors.white.withValues(alpha: 0.6),
              ),
              8.s,
              Text(S.current.deleteMessageForEveryone,
                  style: AppTextStyles.regular()),
            ],
          ),
          onTap: () {
            showDeleteMessageDialog(
                context: context,
                index: index,
                message: message,
                deleteForEveryOne: true,
                isFromSavedMessage: false);
          },
        ),
    ],
  ).then((value) {
    if (value != null) {
      // Handle the selected value
      showMessage('Selected: $value');
    }
  });
}

void buildMessageDeleteForSavedMessageDialog(
    {required BuildContext context,
    required int index,
    required Offset offset,
    required bool isSender,
    required SavedMessage message}) {
  showMenu<ChatMessageOption>(
    context: context,
    color: AppColors.dark,
    position: isSender
        ? RelativeRect.fromLTRB(
            offset.dx, offset.dy, 0, 0) // Sender (right-side)
        : RelativeRect.fromLTRB(
            0, offset.dy, context.w - offset.dx, 0), // Receiver (left-side),
    items: [
      PopupMenuItem<ChatMessageOption>(
        value: ChatMessageOption.deleteMessage,
        child: Row(
          children: [
            SvgImage(
              source: SvgAssets.icTrash,
              color: AppColors.white.withValues(alpha: 0.6),
            ),
            8.s,
            Text(S.current.lblDeleteMessage, style: AppTextStyles.regular()),
          ],
        ),
        onTap: () {
          showDeleteMessageDialog(
              context: context,
              index: index,
              savedMessage: message,
              message: message.messageDetails,
              deleteForEveryOne: false,
              isFromSavedMessage: true);
        },
      ),
      if (message.messageDetails?.type == 'text' ||
          message.messageDetails?.type == 'mixed')
        PopupMenuItem<ChatMessageOption>(
          value: ChatMessageOption.copy,
          child: Row(
            children: [
              Icon(
                Icons.copy,
                color: AppColors.white,
              ),
              // SvgImage(
              //   source: SvgAssets.copy,
              //   color: AppColors.white,
              // ),
              8.s,
              Text(S.current.copy, style: AppTextStyles.regular()),
            ],
          ),
          onTap: () {
            showMessage("TempMessage==> ${message.toJson()}");

            Utils.copyToClipboard(
                context, message.messageDetails?.content ?? "");
          },
        ),
    ],
  ).then((value) {
    if (value != null) {
      // Handle the selected value
      showMessage('Selected: $value');
    }
  });
}

void showDeleteMessageDialog(
    {required BuildContext context,
    required bool isFromSavedMessage,
    required bool deleteForEveryOne,
    SavedMessage? savedMessage,
    MessageModel? message,
    required int index}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return BlocBuilder<ChatCubit, ChatState>(
          builder: (contextMessage, state) {
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
                            S.current.lblDeleteMessage,
                            style: AppTextStyles.medium(fontSize: 20.sp),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            S.of(context).lblDeleteMessageSubTitle,
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
                                    await NavigationService().goBack();

                                    if (isFromSavedMessage) {
                                      context
                                          .read<SavedMessagesCubit>()
                                          .deleteSavedMessages(
                                              savedMessage?.id ?? '',
                                              index,
                                              context);
                                    } else {
                                      chatCubit.deleteChatMessages(
                                        messageId: message?.messageId ?? '',
                                        chatId: message?.chatId ?? "",
                                        index: index,
                                        context: context,
                                        deleteForEveryOne: deleteForEveryOne,
                                        callback: (response) {
                                          // Utils.showSnackBar(
                                          //     context, response.message ?? '',
                                          //     seconds: 3);
                                        },
                                      );
                                    }
                                  },
                                  child: Text(
                                    S.of(context).delete,
                                    style: AppTextStyles.medium(
                                      fontSize: 16.sp,
                                      color: AppColors.white,
                                    ),
                                  ),
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

void showCommonAlertDialog(
    {required BuildContext context,
    required String title,
    required String subTitle,
    required String submitBtnText,
    required void Function() onSubmit}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26.r),
        ), //this right here
        child: SizedBox(
          width: double.infinity,
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
                  Text(
                    title,
                    style: AppTextStyles.medium(fontSize: 20.sp),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    subTitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.regular(
                        fontSize: 14.sp, color: AppColors.textColorSecondary),
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
                            await NavigationService().goBack();
                            onSubmit();
                          },
                          child: Text(
                            submitBtnText,
                            style: AppTextStyles.medium(
                              fontSize: 16.sp,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

void showCommonLogOutDialog(
    {required BuildContext context,
    required String title,
    required String subTitle,
    required String icon,
    Color? color,
    required void Function() onSubmit}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26.r),
        ), //this right here
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 32,
                      ),
                      Container(
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
                              32.s,
                              Text(
                                title,
                                style: AppTextStyles.medium(
                                    fontSize: 20.sp, color: color),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                subTitle,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.regular(
                                    fontSize: 14.sp,
                                    color: AppColors.textColorSecondary),
                              ),
                              SizedBox(height: 24.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                      backgroundColor: color,
                                      onPressed: () async {
                                        await NavigationService().goBack();
                                        onSubmit();
                                      },
                                      child: Text(
                                        S.of(context).yes,
                                        style: AppTextStyles.medium(
                                          fontSize: 16.sp,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    child: CircleAvatar(
                        radius: 32,
                        backgroundColor: color ?? AppColors.buttonColor,
                        child: Center(
                          child: SvgImage(
                            height: 28,
                            width: 28,
                            source: icon,
                            color: AppColors.white,
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

void showEditMessageDialog(
  BuildContext context,
  MessageModel message,
  String aesKey,
) {
  final TextEditingController controller =
      TextEditingController(text: message.content);
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return BlocBuilder<ChatCubit, ChatState>(
          builder: (contextMessage, state) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26.r),
          ), //this right here
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.dark,
              borderRadius: BorderRadius.circular(26.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(height: 24.h),
                  Text(
                    S.current.editMessage,
                    style: AppTextStyles.medium(fontSize: 20.sp),
                  ),
                  16.h.s,
                  TextField(
                    controller: controller,
                    style: AppTextStyles.medium(
                      fontSize: 16.sp,
                      color: AppColors.white,
                    ).copyWith(
                      decoration: TextDecoration.none,
                    ),
                    maxLines: 5,
                    expands: false,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: S.of(context).typeMessage,
                      hintStyle: AppTextStyles.regular(
                        fontSize: 14.sp,
                      ),
                      filled: true,
                      fillColor: AppColors.darkInputFill,
                      // suffixIcon: Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                      //   child: BlocBuilder<ChatCubit, ChatState>(
                      //     builder: (context, state) {
                      //       return InkWell(
                      //           onTap: () {
                      //             showMessage("ChatID::::${message.chatId}");

                      //             if (_controller.text.trim().isNotEmpty) {
                      //               chatCubit
                      //                   .editMessage(
                      //                 context,
                      //                 message: message,
                      //                 content: _controller.text.trim(),
                      //                 // callback: (sentMessageModel) {

                      //                 // },
                      //               )
                      //                   .then(
                      //                 (value) {
                      //                   _controller.clear();
                      //                   // context
                      //                   //     .read<ChatCubit>()
                      //                   //     .getChatMessages(
                      //                   //         chatId ?? "", context);
                      //                 },
                      //               );
                      //             }
                      //             // context.read<ChatCubit>().getChatMessages(chatId??"", context);
                      //           },
                      //           child: SvgPicture.asset(SvgAssets.icSend));
                      //     },
                      //   ),
                      // ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
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
                            showMessage("editMessage onTap");
                            if (controller.text.trim().isNotEmpty) {
                              chatCubit.editMessage(
                                message: message,
                                aesKey: aesKey,
                                newText: controller.text.trim(),
                                callback: () async {
                                  await NavigationService().goBack();
                                  // Utils.showSnackBar(
                                  //     context, response.message ?? '',
                                  //     seconds: 3);
                                },
                              );
                            }
                          },
                          child: Text(
                            S.current.save,
                            style: AppTextStyles.medium(
                              fontSize: 16.sp,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      });
    },
  );

  // showDialog(
  //   context: context,
  //   builder: (context) => AlertDialog(
  //     title: Text(S.current.editMessage),
  //     content:
  //     actions: [
  //       TextButton(
  //         onPressed: () => Navigator.pop(context),
  //         child: Text(S.current.cancel),
  //       ),
  //       TextButton(
  //         onPressed: () {
  //           if (_controller.text.trim().isNotEmpty) {
  //             chatCubit.editMessage(
  //               chatId: message.chatId ?? "",
  //               messageId: message.id ?? "",
  //               newText: _controller.text.trim(),
  //               callback: (response) {
  //                 Navigator.pop(context);
  //                 Utils.showSnackBar(context, response.message ?? '',
  //                     seconds: 3);
  //               },
  //             );
  //           }
  //         },
  //         child: Text(S.current.save),
  //       ),
  //     ],
  //   ),
  // );
}

void showEditSavedMessageDialog(
  BuildContext context,
  SavedMessage savedMessage,
) {
  MessageModel message = savedMessage.messageDetails!;
  final TextEditingController controller =
      TextEditingController(text: message.content);
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return BlocBuilder<ChatCubit, ChatState>(
          builder: (contextMessage, state) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26.r),
          ), //this right here
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.dark,
              borderRadius: BorderRadius.circular(26.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(height: 24.h),
                  Text(
                    S.current.editMessage,
                    style: AppTextStyles.medium(fontSize: 20.sp),
                  ),
                  16.h.s,
                  TextField(
                    controller: controller,
                    style: AppTextStyles.medium(
                      fontSize: 16.sp,
                      color: AppColors.white,
                    ).copyWith(
                      decoration: TextDecoration.none,
                    ),
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    maxLines: 5,
                    minLines: 1,
                    expands: false,
                    decoration: InputDecoration(
                      hintText: S.of(context).typeMessage,
                      hintStyle: AppTextStyles.regular(
                        fontSize: 14.sp,
                      ),
                      filled: true,
                      fillColor: AppColors.darkInputFill,
                      // suffixIcon: Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                      //   child: BlocBuilder<ChatCubit, ChatState>(
                      //     builder: (context, state) {
                      //       return InkWell(
                      //           onTap: () {
                      //             showMessage("ChatID::::${message.chatId}");

                      //             if (_controller.text.trim().isNotEmpty) {
                      //               chatCubit
                      //                   .editMessage(
                      //                 context,
                      //                 message: message,
                      //                 content: _controller.text.trim(),
                      //                 // callback: (sentMessageModel) {

                      //                 // },
                      //               )
                      //                   .then(
                      //                 (value) {
                      //                   _controller.clear();
                      //                   // context
                      //                   //     .read<ChatCubit>()
                      //                   //     .getChatMessages(
                      //                   //         chatId ?? "", context);
                      //                 },
                      //               );
                      //             }
                      //             // context.read<ChatCubit>().getChatMessages(chatId??"", context);
                      //           },
                      //           child: SvgPicture.asset(SvgAssets.icSend));
                      //     },
                      //   ),
                      // ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
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
                            showMessage("editMessage onTap");
                            if (controller.text.trim().isNotEmpty) {
                              context.read<SavedMessagesCubit>().editSavedMessage(
                                message: savedMessage,
                                newText: controller.text.trim(),
                                callback: () async {
                                  await NavigationService().goBack();
                                  // Utils.showSnackBar(
                                  //     context, response.message ?? '',
                                  //     seconds: 3);
                                },
                              );
                            }
                          },
                          child: Text(
                            S.current.save,
                            style: AppTextStyles.medium(
                              fontSize: 16.sp,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      });
    },
  );

  // showDialog(
  //   context: context,
  //   builder: (context) => AlertDialog(
  //     title: Text(S.current.editMessage),
  //     content:
  //     actions: [
  //       TextButton(
  //         onPressed: () => Navigator.pop(context),
  //         child: Text(S.current.cancel),
  //       ),
  //       TextButton(
  //         onPressed: () {
  //           if (_controller.text.trim().isNotEmpty) {
  //             chatCubit.editMessage(
  //               chatId: message.chatId ?? "",
  //               messageId: message.id ?? "",
  //               newText: _controller.text.trim(),
  //               callback: (response) {
  //                 Navigator.pop(context);
  //                 Utils.showSnackBar(context, response.message ?? '',
  //                     seconds: 3);
  //               },
  //             );
  //           }
  //         },
  //         child: Text(S.current.save),
  //       ),
  //     ],
  //   ),
  // );
}

void showCommonDeleteDialog({
  required BuildContext context,
  required void Function() onSubmit,
  required String title,
  required String subTitle,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26.r),
        ), //this right here
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 32,
                      ),
                      Container(
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
                              32.s,
                              Text(
                                title,
                                style: AppTextStyles.medium(fontSize: 20.sp),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                subTitle,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.regular(
                                    fontSize: 14.sp,
                                    color: AppColors.textColorSecondary),
                              ),
                              SizedBox(height: 24.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                        await NavigationService().goBack();
                                        onSubmit();
                                      },
                                      child: Text(
                                        S.of(context).delete,
                                        style: AppTextStyles.medium(
                                          fontSize: 16.sp,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    child: CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.redColor,
                        child: Center(
                          child: SvgImage(
                            height: 28,
                            width: 28,
                            source: SvgAssets.icTrash,
                            color: AppColors.white,
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

void showCommonBlockUserDialog({
  required BuildContext context,
  required void Function() onSubmit,
  required String title,
  required String subTitle,
  IconData? icon,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26.r),
        ), //this right here
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 32,
                      ),
                      Container(
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
                              32.s,
                              Text(
                                title,
                                style: AppTextStyles.medium(fontSize: 20.sp),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                subTitle,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.regular(
                                    fontSize: 14.sp,
                                    color: AppColors.textColorSecondary),
                              ),
                              SizedBox(height: 24.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                        await NavigationService().goBack();
                                        onSubmit();
                                      },
                                      child: Text(
                                        S.of(context).yes,
                                        style: AppTextStyles.medium(
                                          fontSize: 16.sp,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    child: CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.whiteOpa,
                        child: Center(
                            child: Icon(
                          icon ?? Icons.block,
                          size: 28,
                          color: AppColors.dark,
                        )

                            // SvgImage(
                            //   height: 28,
                            //   width: 28,
                            //   source: SvgAssets.blo,
                            //   color: AppColors.white,
                            // ),
                            )),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
