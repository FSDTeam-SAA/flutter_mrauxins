import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:two_one_two_messenger/cubit/saved_messages_cubit.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/main.dart';
import 'package:two_one_two_messenger/models/chat_message_model.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
import 'package:two_one_two_messenger/utils/image_picker.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';

void buildBottomSheet({
  required BuildContext context,
  required bool isFromSavedMessage,
  required String? chatId,
  required String? aesKey,
  required MessageModel? replyMessage,
}) {
  // final languageProvider = Provider.of<LanguageChangeProvider>(context);
  // final selectedLanguage = languageProvider.currentLocal.languageCode;
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    backgroundColor: AppColors.dark,
    builder: (BuildContext contextBottom) {
      return SizedBox(
        width: double.infinity,
        height: 100.h,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            spacing: 12.w,
            children: [
              buildBottomSheetImage(
                image: SvgAssets.icGif,
                onTap: () async {
                  GiphyGif? gif = await GiphyGet.getGif(
                    context: context, //Required
                    tabBottomBuilder: (context) => Container(
                      color: Colors.red,
                    ),
                    apiKey: Platform.isIOS
                        ? AppConstants.iosGiphyApiKey
                        : AppConstants.androidGiphyApiKey, //Required.
                    // lang: selectedLanguage, //Optional - Language for query.
                    showEmojis: false,
                    tabColor:
                        AppColors.white, // Optional- default accent color.
                    debounceTimeInMilliseconds:
                        350, // Optional- time to pause between search keystrokes
                  );
                  if (gif != null) {
                    // log("picked Gif file=== ${gif?.toJson()}");
                    log("picked Gif file=== ${gif.images?.original?.url}");
                    // log("picked Gif file=== ${gif.images?.original?.url}");

                    await NavigationService().goBack();
                    isFromSavedMessage
                        ? context.read<SavedMessagesCubit>().sentSaveMessage(
                            context,
                            // chatId: chatId ?? '',
                            mediaType: 1,
                            content: "GIF",
                            gifUrl: gif.images?.original?.url,
                            sizeForGIF: gif.images?.original?.size,
                            mimeType: MimeType.gif,
                            // files: [xFile!],
                            // callback: (sentMessageModel) {
                            //   context.read<ChatCubit>().updateChatList(
                            //       context, sentMessageModel!.data!.toJson());
                            // },
                          )
                        : chatCubit.sentMessage(context,
                            chatId: chatId ?? '',
                            mediaType: 1,
                            content: "GIF",
                            aesKey: aesKey,
                            gifUrl: gif.images?.original?.url,
                            sizeForGIF: gif.images?.original?.size,
                            mimeType: MimeType.gif,
                            // files: [xFile!],
                            replyMessage: replyMessage
                            // callback: (sentMessageModel) {
                            //   context.read<ChatCubit>().updateChatList(
                            //       context, sentMessageModel!.data!.toJson());
                            // },
                            );
                  }
                  // customFilePicker(context, ['gif'], FileType.custom,
                  //     (xFile, mimeType) async {
                  //   await NavigationService().goBack();
                  //   isFromSavedMessage
                  //       ? context.read<SavedMessagesCubit>().sentSaveMessage(
                  //           context,
                  //           // chatId: chatId ?? '',
                  //           mediaType: 1,
                  //           content: "GIF",

                  //           mimeType: MimeType.gif,
                  //           files: [xFile!],
                  //           // callback: (sentMessageModel) {
                  //           //   context.read<ChatCubit>().updateChatList(
                  //           //       context, sentMessageModel!.data!.toJson());
                  //           // },
                  //         )
                  //       : chatCubit.sentMessage(
                  //           context,
                  //           chatId: chatId ?? '',
                  //           mediaType: 1,
                  //           content: "GIF", aesKey: aesKey,
                  //           mimeType: MimeType.gif,
                  //           files: [xFile!],
                  //           replyMessage: replyMessage
                  //           // callback: (sentMessageModel) {
                  //           //   context.read<ChatCubit>().updateChatList(
                  //           //       context, sentMessageModel!.data!.toJson());
                  //           // },
                  //         );
                  // });
                },
              ),
              buildBottomSheetImage(
                image: SvgAssets.icGiftCard,
                onTap: () {
                  showGiftBottomSheet(context);
                  // try {
                  //   customFilePicker(context, null, FileType.image,
                  //       (xFile, mimeType) async {
                  //     await NavigationService().goBack();
                  //     isFromSavedMessage
                  //         ? context.read<SavedMessagesCubit>().sentSaveMessage(
                  //             context,
                  //             // chatId: chatId ?? '',
                  //             content: "Image",
                  //             mediaType: 2,
                  //             mimeType: mimeType,
                  //             files: [xFile!],
                  //             // callback: (sentMessageModel) {
                  //           )
                  //         : chatCubit.sentMessage(
                  //             context,
                  //             chatId: chatId ?? '',
                  //             content: "Image", aesKey: aesKey,
                  //             mediaType: 2,
                  //             mimeType: mimeType,
                  //             files: [xFile!],
                  //             // callback: (sentMessageModel) {
                  //             //   context.read<ChatCubit>().updateChatList(
                  //             //       context, sentMessageModel!.data!.toJson());
                  //             // },
                  //           );
                  //   });
                  // } catch (e, st) {
                  //   showMessage("Error in file picking $e, $st");
                  // }
                },
              ),
              buildBottomSheetImage(
                image: SvgAssets.icImage,
                onTap: () {
                  try {
                    customFilePicker(context, null, FileType.image,
                        (xFile, mimeType) async {
                      await NavigationService().goBack();
                      isFromSavedMessage
                          ? context.read<SavedMessagesCubit>().sentSaveMessage(
                              context,
                              // chatId: chatId ?? '',
                              content: "Image",
                              mediaType: 2,
                              mimeType: MimeType.image,
                              files: [xFile!],
                              // callback: (sentMessageModel) {
                            )
                          : chatCubit.sentMessage(context,
                              chatId: chatId ?? '',
                              content: "Image",
                              aesKey: aesKey,
                              mediaType: 2,
                              mimeType: MimeType.image,
                              files: [xFile!],
                              replyMessage: replyMessage
                              // callback: (sentMessageModel) {
                              //   context.read<ChatCubit>().updateChatList(
                              //       context, sentMessageModel!.data!.toJson());
                              // },
                              );
                    });
                  } catch (e, st) {
                    showMessage("Error in file picking $e, $st");
                  }
                },
              ),
              buildBottomSheetImage(
                image: SvgAssets.icCamera,
                onTap: () async {
                  await NavigationService().goBack();
                  await buildCameraOptionDialog(
                      context: context,
                      isFromSavedMessage: isFromSavedMessage,
                      chatId: chatId,
                      replyMessage: replyMessage,
                      aesKey: aesKey);

                  // customImagePicker(context, ImageSource.camera,
                  //     (xFile, mimeType) async {
                  //   await NavigationService().goBack();
                  // });
                },
              ),
              buildBottomSheetImage(
                image: SvgAssets.icVideo,
                onTap: () {
                  customVideoPicker(context, ImageSource.gallery,
                      (xFile, mimeType) async {
                    await NavigationService().goBack();
                    isFromSavedMessage
                        ? context.read<SavedMessagesCubit>().sentSaveMessage(
                            context,
                            content: "Video",
                            mediaType: 6,
                            mimeType: MimeType.video,
                            files: [xFile!],
                          )
                        : chatCubit.sentMessage(context,
                            chatId: chatId ?? '',
                            content: "Video",
                            mediaType: 6,
                            mimeType: MimeType.video,
                            aesKey: aesKey,
                            files: [xFile!],
                            replyMessage: replyMessage
                            // callback: (sentMessageModel) {
                            //   context.read<ChatCubit>().updateChatList(
                            //       context, sentMessageModel!.data!.toJson());
                            // },
                            );
                  });
                },
              ),
              buildBottomSheetImage(
                image: SvgAssets.icGalleryTwo,
                onTap: () async {
                  try {
                    await customFilePicker(
                        context,
                        [
                          'pdf',
                          'doc',
                        ],
                        FileType.custom, (xFile, mimeType) async {
                      await NavigationService().goBack();
                      isFromSavedMessage
                          ? context.read<SavedMessagesCubit>().sentSaveMessage(
                              context,
                              content: "Document",
                              mediaType: 4,
                              mimeType: mimeType,
                              files: [xFile!],
                            )
                          : chatCubit.sentMessage(context,
                              chatId: chatId ?? '',
                              content: "Document",
                              mediaType: 4,
                              mimeType: mimeType,
                              aesKey: aesKey,
                              files: [xFile!],
                              replyMessage: replyMessage
                              // callback: (sentMessageModel) {
                              //   context.read<ChatCubit>().updateChatList(
                              //       context, sentMessageModel!.data!.toJson());
                              // },
                              );
                    });
                  } catch (e, st) {
                    showMessage("Error in file picking $e, $st");
                  }
                },
              ),
              buildBottomSheetImage(
                image: SvgAssets.icMicrophone,
                onTap: () {
                  showAudioRecordDialog(
                      context: context,
                      onSend: (xFile, mimeType) async {
                        await NavigationService().goBack();
                        isFromSavedMessage
                            ? context.read<SavedMessagesCubit>().sentSaveMessage(
                                context,
                                content: "Audio",
                                mediaType: 5,
                                mimeType: MimeType.audio,
                                files: [xFile],
                              )
                            : chatCubit.sentMessage(context,
                                chatId: chatId ?? '',
                                content: "Audio",
                                mediaType: 5,
                                mimeType: MimeType.audio,
                                aesKey: aesKey,
                                files: [xFile],
                                replyMessage: replyMessage
                                // callback: (sentMessageModel) {
                                //   context.read<ChatCubit>().updateChatList(
                                //       context, sentMessageModel!.data!.toJson());
                                // },
                                );
                      }).then(
                    (value) async {
                      await NavigationService().goBack();
                    },
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  ).then((result) {
    // This callback will be executed once the dialog is closed.
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

Future<void> buildCameraOptionDialog({
  required BuildContext context,
  required bool isFromSavedMessage,
  required String? chatId,
  required String? aesKey,
  required MessageModel? replyMessage,
}) async {
  await showDialog(
    context: context,
    builder: (context) {
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
                  S.of(context).selectMedia,
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
                            await customImagePicker(context, ImageSource.camera,
                                (xFile, mimeType) async {
                              await NavigationService().goBack();
                              isFromSavedMessage
                                  ? context.read<SavedMessagesCubit>().sentSaveMessage(
                                      navigatorKey.currentContext ?? context,
                                      content: "Image",
                                      mediaType: 2,
                                      mimeType: mimeType,
                                      files: [xFile!],
                                    )
                                  : chatCubit.sentMessage(
                                      navigatorKey.currentContext ?? context,
                                      chatId: chatId ?? '',
                                      content: "Image",
                                      mediaType: 2,
                                      mimeType: mimeType,
                                      aesKey: aesKey,
                                      files: [xFile!],
                                      replyMessage: replyMessage
                                      // callback: (sentMessageModel) {
                                      //   context.read<ChatCubit>().updateChatList(
                                      //       context, sentMessageModel!.data!.toJson());
                                      // },
                                      );
                            });
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
                            customVideoWithCameraPicker(
                                context, ImageSource.camera,
                                (xFile, mimeType) async {
                              await NavigationService().goBack();
                              isFromSavedMessage
                                  ? context.read<SavedMessagesCubit>().sentSaveMessage(
                                      navigatorKey.currentContext ?? context,
                                      content: "Video",
                                      mediaType: 6,
                                      mimeType: mimeType,
                                      files: [xFile!],
                                    )
                                  : chatCubit.sentMessage(
                                      navigatorKey.currentContext ?? context,
                                      chatId: chatId ?? '',
                                      content: "Video",
                                      mediaType: 6,
                                      mimeType: mimeType,
                                      aesKey: aesKey,
                                      files: [xFile!],
                                      replyMessage: replyMessage
                                      // callback: (sentMessageModel) {
                                      //   context.read<ChatCubit>().updateChatList(
                                      //       context, sentMessageModel!.data!.toJson());
                                      // },
                                      );
                            });
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
    },
  );
}

void showGiftBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows full-screen dragging
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
    ),
    backgroundColor: AppColors.dialogBg,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 16.h),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 16.0.w,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 24.h,
            children: [
              Container(
                  height: 3,
                  width: 65,
                  decoration: BoxDecoration(
                      color: AppColors.checkboxColor,
                      borderRadius: BorderRadius.circular(50))),
              Text(
                S.of(context).giftsCommingSoon,
                style: AppTextStyles.medium(fontSize: 24.sp),
              ),
              SvgImage(
                source: SvgAssets.giftFillIcon,
                fit: BoxFit.cover,
                height: 100,
                width: 100,
                color: AppColors.white,
              ),
              Text(
                S.of(context).giftsCommingSoonMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.regular(color: AppColors.textColorHint),
              ),
              25.s
            ],
          ),
        ),
      );
    },
  );
}

GestureDetector buildBottomSheetImage(
    {required String image, required Function() onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 50.w,
      height: 50.w,
      decoration:
          BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle),
      child: Center(
        child: SvgImage(
          source: image,
          height: 20.w,
          width: 20.w,
        ),
      ),
    ),
  );
}

Future<void> showAudioRecordDialog(
    {required BuildContext context,
    required Function(XFile, MimeType) onSend}) async {
  final recorder = AudioRecorder();
  Recoding isRecording = Recoding.stop;
  String? recordedFilePath;
  Timer? timer;
  int recordingDuration = 0;

  void startTimer() {
    recordingDuration = 0;
    if (timer != null) {
      timer?.cancel();
    }
  }

  void restartTimer() {
    recordingDuration = 0;
    if (timer != null) {
      timer?.cancel();
    }
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      recordingDuration++;
      showMessage('Recording: $recordingDuration');
    });
  }

  void stopTimer() {
    timer?.cancel();
    timer = null;
  }

  void resumeTimer() {
    if (timer != null) {
      timer?.cancel();
    }
  }

// Future<void> resumeRecording() async {
//     if (await recorder.isRecording()) {
//       await recorder. resume();
//       isRecording = Recoding.pause;
//       resumeTimer();
//     }
//   }
  Future<void> restartRecording() async {
    if (await recorder.isPaused()) {
      await recorder.resume();
      isRecording = Recoding.start;
      resumeTimer();
    }
  }

  Future<void> startRecording() async {
    final hasPermission = await recorder.hasPermission();
    if (!hasPermission) {
      throw Exception("Recording permission not granted.");
    }

    final dir = await getTemporaryDirectory();
    recordedFilePath =
        '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

    await recorder.start(
      RecordConfig(
          encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100),
      path: recordedFilePath ?? '',
    );
    isRecording = Recoding.start;
    startTimer();
  }

  Future<void> stopRecording() async {
    if (await recorder.isRecording()) {
      await recorder.stop();
      isRecording = Recoding.stop;
      stopTimer();
    }
  }

  Future<void> pauseRecording() async {
    if (await recorder.isRecording()) {
      await recorder.pause();
      isRecording = Recoding.pause;
      timer?.cancel();
    }
  }

  try {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.dark,
              contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 8.h),
                  Container(
                    height: 60.w,
                    width: 60.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.darkAppBar,
                    ),
                    child: Center(
                      child: Icon(Icons.mic,
                          size: 40.w,
                          color: isRecording == Recoding.start
                              ? Colors.red
                              : const Color.fromRGBO(158, 158, 158, 1)),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    isRecording == Recoding.start
                        ? S.of(context).recording2
                        : isRecording == Recoding.stop
                            ? S.of(context).tapToStartRecord
                            : S.of(context).restartRecording,
                    style: AppTextStyles.medium(fontSize: 16.sp),
                  ),
                  SizedBox(height: 10.h),
                  if (isRecording == Recoding.start)
                    Text(
                      "${S.of(context).recording}: ${Duration(seconds: recordingDuration).toString().split('.').first.padLeft(8, "0")}",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (isRecording == Recoding.pause)
                    Text(
                      "${S.of(context).pause}: ${Duration(seconds: recordingDuration).toString().split('.').first.padLeft(8, "0")}",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  SizedBox(height: 18.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (isRecording == Recoding.stop)
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.mic,
                              color: AppColors.primaryColor,
                            ),
                            label: Text(
                              S.of(context).start,
                              style: AppTextStyles.medium(
                                  color: AppColors.primaryColor),
                            ),
                            onPressed: () async {
                              await startRecording().then((_) {
                                timer = Timer.periodic(Duration(seconds: 1),
                                    (timer) {
                                  recordingDuration++;
                                  setState(() {});
                                  showMessage('Recording: $recordingDuration');
                                });
                              });
                              setState(() {});
                            },
                          ),
                        )
                      else if (isRecording == Recoding.pause)
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.stop,
                              color: AppColors.primaryColor,
                            ),
                            label: Text(
                              S.of(context).restart,
                              style: AppTextStyles.medium(
                                  color: AppColors.primaryColor),
                            ),
                            onPressed: () async {
                              await restartRecording().then(
                                (value) {
                                  timer = Timer.periodic(Duration(seconds: 1),
                                      (timer) {
                                    recordingDuration++;
                                    setState(() {});
                                    showMessage(
                                        'Recording: $recordingDuration');
                                  });
                                },
                              );
                              setState(() {});
                            },
                          ),
                        )
                      else if (isRecording == Recoding.start)
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.stop,
                              color: AppColors.primaryColor,
                            ),
                            label: Text(
                              S.of(context).stop,
                              style: AppTextStyles.medium(
                                  color: AppColors.primaryColor),
                            ),
                            onPressed: () async {
                              await pauseRecording();
                              setState(() {});
                            },
                          ),
                        ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(
                            Icons.send,
                            color: recordedFilePath != null
                                ? AppColors.primaryColor
                                : AppColors.textColorSecondary,
                          ),
                          label: Text(
                            S.of(context).send,
                            style: AppTextStyles.medium(
                              color: recordedFilePath != null
                                  ? AppColors.primaryColor
                                  : AppColors.textColorSecondary,
                            ),
                          ),
                          onPressed: recordedFilePath != null
                              ? () async {
                                  await stopRecording();
                                  setState(() {});
                                  MimeType mimeType =
                                      Utils.getMimeType(recordedFilePath!);
                                  onSend(XFile(recordedFilePath!), mimeType);
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () async {
                      await stopRecording();
                      setState(() {});
                      await NavigationService().goBack();
                    },
                    child: Text(
                      S.of(context).cancel,
                      style: AppTextStyles.medium(color: AppColors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  } catch (e) {
    showMessage('Error during recording: $e');
  } finally {
    if (await recorder.isRecording()) {
      await recorder.stop();
    }
  }
}

void showDisappearingMessageTimerSheet(
    BuildContext context, int selectedDuration, Function(int) onSelected) {
  final List<Map<String, dynamic>> options = [
    {"label": "24 Hours", "value": 86400},
    {"label": "7 Days", "value": 604800},
    {"label": "90 Days", "value": 7776000},
    {"label": "Off", "value": 0},
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
    ),
    backgroundColor: AppColors.dialogBg,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 3,
                width: 65,
                decoration: BoxDecoration(
                  color: AppColors.checkboxColor,
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              S.of(context).disappearingMessageTitle,
              style: AppTextStyles.medium(fontSize: 18.sp),
            ),
            SizedBox(height: 16.h),
            Divider(
              height: 1.h,
              color: AppColors.darkInputFill,
            ),
            ...options.map((option) => RadioListTile<int>(
                  title: Text(
                    option["label"],
                    style: AppTextStyles.medium(),
                  ),
                  value: option["value"],
                  groupValue: selectedDuration,
                  activeColor: AppColors.buttonColor,
                  onChanged: (value) {
                    if (value != null) {
                      onSelected(value);
                      Navigator.pop(context);
                    }
                  },
                )),
            SizedBox(height: 16.h),
            Divider(
              height: 1.h,
              color: AppColors.darkInputFill,
            ),
            16.h.s,
            Text(
              S.of(context).disappearingMessageDescription,
              style: AppTextStyles.regular(color: AppColors.textColorHint),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      );
    },
  );
}
