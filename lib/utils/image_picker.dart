import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/widgets/buttons.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';

import '../widgets/alert_dialog.dart';
import 'constants.dart';
import 'utils.dart';

Future<void> showCustomImageOptionPickerDialog(
    {required BuildContext context,
    required Function(XFile?) onImagePicked}) async {
  await Utils.hideKeyboard();
  ImageSource selectedSource = ImageSource.camera;
  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
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
                    S.of(context).lblUploadPhotos,
                    style: AppTextStyles.medium(fontSize: 16.sp),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedSource = ImageSource.camera;
                              });
                            },
                            child: Container(
                              height: 65.w,
                              width: 65.w,
                              decoration: BoxDecoration(
                                color: selectedSource == ImageSource.camera
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
                            onTap: () {
                              setState(() {
                                selectedSource = ImageSource.gallery;
                              });
                            },
                            child: Container(
                              height: 65.w,
                              width: 65.w,
                              decoration: BoxDecoration(
                                color: selectedSource == ImageSource.gallery
                                    ? AppColors.primaryColor
                                    : AppColors.darkInputFill,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: SvgImage(
                                  source: SvgAssets.icGallery,
                                  width: 24.w,
                                  height: 24.h,
                                  color: selectedSource == ImageSource.gallery
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
                      Navigator.pop(context);
                      customImagePickerwithoutMimeType(
                          context, selectedSource, onImagePicked);
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

Future<void> customImagePickerwithoutMimeType(BuildContext context,
    ImageSource source, Function(XFile?) onImagePicked) async {
  final pickedFile = await ImagePicker().pickImage(
      source: source, imageQuality: 80, maxWidth: 1280, maxHeight: 1280);
  if (pickedFile != null) {
    onImagePicked(XFile(pickedFile.path,
        name: pickedFile.name, mimeType: pickedFile.mimeType));
  }
  // }
}

Future<void> customImagePicker(BuildContext context, ImageSource source,
    Function(XFile?, MimeType) onImagePicked) async {
  PermissionStatus? status;

  if (source == ImageSource.camera) {
    status = await Permission.camera.request();
  }

  if (status != null && !status.isGranted) {
    await CustomAlertDialog(
      context: context,
      icon: SvgImage(
        source: SvgAssets.icSettingsOutline,
        color: AppColors.white,
        height: 28.w,
        width: 28.w,
      ),
      title: 'Permission Required',
      description: 'Please enable the Camera permission from the app settings',
      buttonText: 'Open Settings',
      onPressed: () => openAppSettings(),
    );
  } else {
    final pickedFile =
        await ImagePicker().pickImage(source: source, imageQuality: 100);
    if (pickedFile != null) {
      MimeType mimeType = Utils.getMimeType(pickedFile.path);
      onImagePicked(
          XFile(pickedFile.path,
              name: pickedFile.name, mimeType: pickedFile.mimeType),
          mimeType);
    }
  }
}

Future<void> customVideoWithCameraPicker(BuildContext context,
    ImageSource source, Function(XFile?, MimeType) onImagePicked) async {
  PermissionStatus? status;

  if (source == ImageSource.camera) {
    status = await Permission.camera.request();
  }

  if (status != null && !status.isGranted) {
    await CustomAlertDialog(
      context: context,
      icon: SvgImage(
        source: SvgAssets.icSettingsOutline,
        color: AppColors.white,
        height: 28.w,
        width: 28.w,
      ),
      title: 'Permission Required',
      description: 'Please enable the Camera permission from the app settings',
      buttonText: 'Open Settings',
      onPressed: () => openAppSettings(),
    );
  } else {
    final pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.camera);
    if (pickedFile != null) {
      MimeType mimeType = Utils.getMimeType(pickedFile.path);
      onImagePicked(
          XFile(pickedFile.path,
              name: pickedFile.name, mimeType: pickedFile.mimeType),
          mimeType);
    }
  }
}

Future<void> customVideoPicker(BuildContext context, ImageSource source,
    Function(XFile?, MimeType) onVideoPicked) async {
  PermissionStatus? status;

  if (source == ImageSource.camera) {
    status = await Permission.camera.request();
  }

  if (status != null && !status.isGranted) {
    await CustomAlertDialog(
      context: context,
      icon: SvgImage(
        source: SvgAssets.icSettingsOutline,
        color: AppColors.white,
        height: 28.w,
        width: 28.w,
      ),
      title: 'Permission Required',
      description: 'Please enable the Camera permission from the app settings',
      buttonText: 'Open Settings',
      onPressed: () => openAppSettings(),
    );
  } else {
    final pickedFile = await ImagePicker().pickVideo(source: source);
    if (pickedFile != null) {
      MimeType mimeType = Utils.getMimeType(pickedFile.path);
      onVideoPicked(
          XFile(pickedFile.path,
              name: pickedFile.name, mimeType: pickedFile.mimeType),
          mimeType);
    }
  }
}

Future<void> customFilePicker(
    BuildContext context,
    List<String>? customExtension,
    FileType type,
    Function(XFile?, MimeType) onAudioPicked,
    {bool isMultiple = false}) async {
  try {
    if (type == FileType.custom && customExtension == null) {
      Utils.showSnackBar(context, "Please give extension for type custom");
      return;
    }
    final pickedFile = await FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: customExtension,
      allowMultiple: isMultiple,
    );
    if (pickedFile != null && pickedFile.files.isNotEmpty) {
      MimeType mimeType = Utils.getMimeType(pickedFile.files.first.xFile.path);
      onAudioPicked(pickedFile.files.first.xFile, mimeType);
    }
  } catch (e, st) {
    showMessage("Error in file picking $e, $st");
  }
  // }
}
