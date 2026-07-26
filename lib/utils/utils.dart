import 'dart:developer' as p;
import 'dart:io';
import 'dart:math';

import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart'
    hide PermissionStatus;
import 'package:two_one_two_messenger/database/local_db.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/main.dart';
import 'package:two_one_two_messenger/models/chat_message_model.dart';
import 'package:two_one_two_messenger/models/conversation_model.dart';
import 'package:two_one_two_messenger/models/otp_verify.dart';
import 'package:two_one_two_messenger/widgets/alert_dialog.dart';
import 'package:two_one_two_messenger/widgets/svg_images.dart';
import 'package:url_launcher/url_launcher.dart';

import 'colors.dart';
import 'constants.dart';
import 'logger.dart';
import 'navigation.dart';
import 'text_style.dart';

extension GeneralExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  double get w => MediaQuery.sizeOf(this).width;
  double get h => MediaQuery.sizeOf(this).height;

  void showLoader() {
    loaderOverlay.show();
  }

  /// Hide the global loader overlay.
  void hideLoader() {
    loaderOverlay.hide();
  }

  /// Check if the loader is currently shown.
  bool get isLoaderVisible {
    return loaderOverlay.visible;
  }
}

extension DateTimeExtensions on DateTime {
  String toFormattedString() {
    return "$day-$month-$year";
  }

  String formatMessageTimestamp() {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final yesterdayMidnight = todayMidnight.subtract(Duration(days: 1));
    if (isAfter(todayMidnight)) {
      // Same day (after midnight)
      return DateFormat().add_jm().format(this);
    } else if (isAfter(yesterdayMidnight)) {
      // Previous day (after midnight)
      return DateFormat('E').format(this);
    } else if (now.difference(this).inDays < 7) {
      // Within the last week
      return DateFormat('E').format(this); // Mon, Tue, etc.
    } else {
      // 1 week old or more
      return DateFormat('dd/MM').format(this);
    }
  }
}

extension DateTimeFormatting on String {
  String toCustomFormat() {
    DateTime dateTime = DateTime.parse(this).toLocal();
    return DateFormat("MMM dd 'at' HH:mm").format(dateTime);
  }
}

extension DarkModeExtension on BuildContext {
  bool get isDarkMode {
    return MediaQuery.of(this).platformBrightness == Brightness.dark;
  }
}

extension KeyboardDismissal on BuildContext {
  void dismissKeyboard() {
    FocusScope.of(this).unfocus();
  }
}

void showMessage(String message) {
  if (kDebugMode) {
    p.log(message);
    // dart:developer's log() only shows up in DevTools' Logging panel, not
    // in `flutter run`'s terminal output — print it too so it's visible
    // wherever the app is being debugged from.
    debugPrint(message);
  }
}

class Utils {
  static void hideKeyboardInApp(BuildContext context) {
    var currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }

  static void hideKeyboardGlobally() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static initEasyLoading() {
    EasyLoading.instance
          ..indicatorType = EasyLoadingIndicatorType.fadingCircle
          ..loadingStyle = EasyLoadingStyle.custom
          ..indicatorSize = 45.0
          ..radius = 10.0
          ..progressColor = AppColors.white
          ..backgroundColor = AppColors.primaryColor
          ..indicatorColor = AppColors.white
          ..textColor = AppColors.white
          ..maskColor = AppColors.white
          ..userInteractions = false
          ..dismissOnTap = false
          ..boxShadow = [
            BoxShadow(
              color: AppColors.secondaryColor,
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 4), // changes position of shadow
            ),
          ]
        // ..customAnimation = CustomAnimation()
        ;
  }

  final urlPatternPrefix = r'^(http|https)://';
  String get urlPattern =>
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$';

  String get ipPattern => r'^(https?:\/\/)(\d{1,3}\.){3}\d{1,3}:\d{1,5}$';

  String get urlIpPattern =>
      r'^(https?:\/\/)((\d{1,3}\.){3}\d{1,3}:\d{1,5}|([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,})$';

  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  static void showLoader() {
    EasyLoading.show(
      dismissOnTap: false,
    );
  }

  /// Hide the global loader overlay.
  static void hideLoader() {
    EasyLoading.dismiss();
    // if (navigatorKey.currentContext != null) {
    //   navigatorKey.currentContext!.loaderOverlay.hide();
    // }
  }

  static int APISUCCESS = 1;

  static bool isDebug = kDebugMode;

  static bool isDarkMode() {
    return SchedulerBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
  }

  static void showSnackBar(BuildContext context, String message,
      {int seconds = 3}) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: AppTextStyles.regular(
          fontSize: 14.sp,
          color: AppColors.white,
        ),
      ),
      duration: Duration(seconds: seconds),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      snackBar,
    );
  }

  static Future<void> launchUrlHelper(String url, BuildContext context) async {
    try {
      final Uri url0 = Uri.parse(url);
      if (!await launchUrl(url0)) {
        AppLogger.logs('Could not launch : Exception : $url');
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      AppLogger.logs('Could not launch : catch : $e');
      showSnackBar(context, e.toString());
    }
  }

  static Future<bool?> showBackDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.dialogBg,
          title: Text(
            S.of(context).lblAlert,
            style: AppTextStyles.extraBold(
              fontSize: 24.sp,
              // color: AppColors.textColorPrimary,
            ),
          ),
          content: Text(
            S.of(context).lblAlertSubtitle,
            style: AppTextStyles.medium(
              fontSize: 16.sp,
              // color: AppColors.textColorPrimary,
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(
                S.of(context).lblNo,
                style: AppTextStyles.medium(
                  fontSize: 16.sp,
                  color: AppColors.textColorFourth,
                ),
              ),
              onPressed: () {
                NavigationService().goBackReturn(false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(
                S.of(context).lblExit,
                style: AppTextStyles.medium(
                  fontSize: 16.sp,
                  color: AppColors.redColor,
                ),
              ),
              onPressed: () {
                NavigationService().goBackReturn(true);
              },
            ),
          ],
        );
      },
    );
  }

  static Future<String?> fetchToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    try {
      if (Platform.isIOS) {
        // iOS requires the APNS token before FCM can generate a token.
        // Wait for it (with a bounded retry) instead of calling getToken()
        // immediately, otherwise it silently returns null/empty.
        String? apns = await messaging.getAPNSToken();
        for (int i = 0; i < 5 && apns == null; i++) {
          await Future.delayed(const Duration(seconds: 1));
          apns = await messaging.getAPNSToken();
        }
      }
      // iOS simulator has no APNs — getToken() hangs without a timeout
      String? token = await messaging.getToken().timeout(
            const Duration(seconds: 8),
            onTimeout: () => null,
          );
      return token;
    } catch (e) {
      return null;
    }
  }

  static String getDisappearingMessageLabel(int duration) {
    switch (duration) {
      case 86400:
        return S.current.timer24Hours;
      case 604800:
        return S.current.timer7Days;
      case 7776000:
        return S.current.timer90Days;
      case 0:
        return S.current.timerOff;
      default:
        return S.current.timerOff; // Default case
    }
  }

  static closeDrawer(BuildContext context) {
    Scaffold.of(context).closeEndDrawer();
  }

  static bool isImage(String path) {
    final extension = path.split('.').last.toLowerCase();
    showMessage("is Image $extension");
    return ['jpg', 'jpeg', 'png', 'webp'].contains(extension);
  }

  static MimeType getMimeType(String filePath) {
    String? mimeType = lookupMimeType(filePath);
    String? imageType = mimeType?.split('/').first;

    if (mimeType?.contains('image') ?? false) {
      return MimeType.image;
    } else if (mimeType?.contains('video') ?? false) {
      return MimeType.video;
    } else if (mimeType?.contains('audio') ?? false) {
      return MimeType.audio;
    } else if (mimeType?.contains('gif') ?? false) {
      return MimeType.gif;
    } else if (mimeType?.contains('pdf') ?? false) {
      return MimeType.pdf;
    } else if (mimeType?.contains('doc') ?? false) {
      return MimeType.doc;
    }
    return MimeType.image;
  }

  static MimeType getMediaType(String type) {
    String? mediaType = type.split('/')[0];
    if (mediaType == 'image') {
      return MimeType.image;
    } else if (mediaType == 'video') {
      return MimeType.video;
    } else if (mediaType == 'audio') {
      return MimeType.audio;
    } else if (mediaType == 'gif') {
      return MimeType.gif;
    }
    return MimeType.image;
  }

  Future<XFile> getVideoThumbnail(String url) async {
    XFile thumbnailFile = await VideoThumbnail.thumbnailFile(
      video: url,
      thumbnailPath: (await getDownloadsDirectory())?.path,
      imageFormat: ImageFormat.JPEG,
      quality: 100,
    );
    return thumbnailFile;
  }

  static Future<void> hideKeyboard() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  static String formatFileSize(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB"];
    int i = (bytes > 0) ? (log(bytes) / log(1024)).floor() : 0;
    double size = bytes / pow(1024, i);
    return "${size.toStringAsFixed(decimals)} ${suffixes[i]}";
  }

  static Future<Sender> currentUserToSender() async {
    UserData? user = userDataCubit.state;
    user ??= await DatabaseHelper().getLoginData();
    return Sender(
        id: user?.sId,
        profilePicture: user?.profilePicture,
        userName: user?.userName);
  }

  static String getDateLabel(String dateString) {
    DateFormat format = DateFormat("d MMMM yyyy");
    DateTime passedDate = format.parse(dateString);
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(const Duration(days: 1));
    if (passedDate.year == now.year &&
        passedDate.month == now.month &&
        passedDate.day == now.day) {
      return 'Today';
    } else if (passedDate.year == yesterday.year &&
        passedDate.month == yesterday.month &&
        passedDate.day == yesterday.day) {
      return 'Yesterday';
    } else {
      return dateString;
    }
  }

  static String getFormattedDate(int passedInt) {
    DateTime date = DateTime.fromMicrosecondsSinceEpoch(passedInt * 1000);
    return DateFormat('dd MMMM yyyy').format(date);
  }

  static bool canEditOrDeleteMessage(DateTime createdAt,
      {int timeLimitInMinutes = 1440}) {
    final now = DateTime.now();
    final difference = now.difference(createdAt).inMinutes;
    return difference <= timeLimitInMinutes;
  }

  static Future<List<String>> getLocalContacts() async {
    if (await Utils.hasContactsPermission()) {
      // Step 2: Ask for additional in-app user consent before uploading
      bool? userConsent = AppPreference.isContactPermissionGrant();
      if (!userConsent) {
        userConsent = await showDialog<bool>(
          context: navigatorKey.currentContext!,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.dialogBg,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r)),
            icon: Icon(
              Icons.warning_amber,
              color: AppColors.whiteOpa,
            ),
            title: Text(
              S.current.customContactUploadConsentTitle,
              style: AppTextStyles.bold(
                fontSize: 18.sp,
                // color: AppColors.textColorPrimary,
              ),
            ),
            content: Text(
              S.current.contactUseDescription,
              textAlign: TextAlign.center,
              style: AppTextStyles.medium(
                fontSize: 14.sp,
                // color: AppColors.textColorPrimary,
              ),
            ),
            actions: [
              TextButton(
                child: Text(
                  S.current.notNow,
                  style: AppTextStyles.medium(
                    fontSize: 16.sp,
                    color: AppColors.textColorFourth,
                  ),
                ),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: Text(
                  S.current.lblContinue,
                  style: AppTextStyles.medium(
                    fontSize: 16.sp,
                    color: AppColors.primaryColor,
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        );
        await AppPreference.setBoolean(LocalDbConstants.contactPermission,
            value: userConsent ?? false);
      }
      if (userConsent ?? false) {
        List<Contact> contacts = await FlutterContacts.getAll(
            properties: {ContactProperty.name, ContactProperty.phone});
        showMessage("getLocalContacts==> $userConsent  ${contacts.length}");
        return contacts
            .map((c) => c.phones.isNotEmpty ? c.phones.first.number : "")
            .skipWhile(
              (value) => value.isEmpty,
            )
            .toList();
      }
    } else {
// showSnackBar(navigatorKey.currentContext!, S.current. );
      await AppPreference.setBoolean(LocalDbConstants.contactPermission,
          value: false);
      await CustomAlertDialog(
        context: navigatorKey.currentContext!,
        icon: SvgImage(
          source: SvgAssets.icSettings,
          color: AppColors.white,
          height: 28.w,
          width: 28.w,
        ),
        title: S.current.permissionRequired,
        description: S.current.askContactPermission,
        buttonText: S.current.openSetting,
        onPressed: () => openAppSettings(),
      );
    }
    return [];
  }

  static Future<bool> hasContactsPermission() async {
    final status =
        await FlutterContacts.permissions.request(PermissionType.readWrite);
    return status == PermissionStatus.granted ||
        status == PermissionStatus.limited;
  }

  static Future<bool> askContactPermission() async {
    bool? userConsent = AppPreference.isContactPermissionGrant();
    if (!userConsent) {
      userConsent = await showDialog<bool>(
        context: navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.dialogBg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          icon: Icon(
            Icons.warning_amber,
            color: AppColors.whiteOpa,
          ),
          title: Text(
            S.current.customContactUploadConsentTitle,
            style: AppTextStyles.bold(
              fontSize: 18.sp,
              // color: AppColors.textColorPrimary,
            ),
          ),
          content: Text(
            S.current.contactUseDescription,
            textAlign: TextAlign.center,
            style: AppTextStyles.medium(
              fontSize: 14.sp,
              // color: AppColors.textColorPrimary,
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                S.current.notNow,
                style: AppTextStyles.medium(
                  fontSize: 16.sp,
                  color: AppColors.textColorFourth,
                ),
              ),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: Text(
                S.current.lblContinue,
                style: AppTextStyles.medium(
                  fontSize: 16.sp,
                  color: AppColors.primaryColor,
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );
      await AppPreference.setBoolean(LocalDbConstants.contactPermission,
          value: userConsent ?? false);
    }
    return userConsent ?? false;
  }

  static void copyToClipboard(
    BuildContext context,
    String text,
  ) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      showSnackBar(context, S.current.copiedToClipboard);
    });
  }

  static String removeSpaceAndSpecialCharectorsFromString(String input) {
    return input.replaceAll(RegExp(r'[^0-9a-zA-Z]'), '');
  }

  static Future<Uint8List> fileToUint8List(File file) async {
    return await file.readAsBytes();
  }

  static Future<File> uint8ListToFile(
      Uint8List editedImage, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final String newFilePath =
        "${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    File file = File(newFilePath);
    await file.writeAsBytes(editedImage, flush: true);

    return file;
  }

  static Future<void> onOpenLink(LinkableElement link) async {
    debugPrint("onOpenLink==>${_ensureProperUrl(link.url)}");
    EasyLauncher.url(url: _ensureProperUrl(link.url), mode: Mode.inAppBrowser);
  }

  static String _ensureProperUrl(String url) {
    // Add https if missing scheme
    if (url.startsWith('www.')) {
      return 'https://$url';
    }
    if (!url.contains('://')) {
      url = 'https://$url';
    }

    // Parse and validate the URL

    // Handle special cases

    return url;
  }

  static Future<File> fixEditedImageSize(
      Uint8List editedImage, int width, int height) async {
    final directory = await getApplicationDocumentsDirectory();
    final String newFilePath =
        "${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png";

    // Decode edited image
    img.Image? image = img.decodeImage(editedImage);

    if (image != null) {
      // Resize the image back to its original size
      img.Image resizedImage =
          img.copyResize(image, width: width, height: height);

      // Save as PNG to preserve transparency
      File file = File(newFilePath);
      await file.writeAsBytes(img.encodePng(resizedImage), flush: true);

      return file;
    } else {
      throw Exception("Failed to decode the edited image.");
    }
  }

  static String? validateUsername(
    String username,
  ) {
    if (username.isEmpty) {
      return S.current.userNameError; // Fetch from .arb file
    } else if (!isValidUsername(username)) {
      return S.current.usernameInvalidCharacters;
    }
    return null;
  }

  static Future<void> sendSMS(String phoneNumber, String message) async {
    final Uri smsUri =
        Uri.parse("sms:$phoneNumber?body=${Uri.encodeComponent(message)}");

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      showMessage("Could not launch SMS");
    }
  }

  static bool isValidUsername(String username) {
    // Regular expression to allow letters, numbers, underscores, and hyphens but no spaces
    final RegExp regex = RegExp(r'^[a-zA-Z0-9._-]+$');

    // Check if the username is empty or contains invalid characters
    if (username.isEmpty) {
      return false;
    }

    return regex.hasMatch(username);
  }
}

enum SignInProvider { google, facebook }

enum MimeType { image, video, audio, gif, none, pdf, doc }

enum CallType { voice, video, voice_group_call, video_group_call }

enum Recoding { start, stop, pause }

enum LoadingState { loading, error, success }

enum MessageOption { clearChat, disapperingMessages, viewContact }

enum GroupAdminAthority {
  createAdmin("Create Admin", "createAdmin", "assets/svg/adminalt.svg"),

  removeMember("Remove Member", "removeMember", 'assets/svg/deleteUser.svg'),

  removeAdmin("Remove From Admin", "removeAdmin", 'assets/svg/deleteUser.svg');

  final String name;
  final String value;
  final String icon;
  const GroupAdminAthority(
    this.name,
    this.value,
    this.icon,
  );
}

enum ChatMessageOption {
  reply,
  react,
  copy,
  edit,
  pin,
  forward,
  saveMessage,
  deleteMessage,
}

enum ChatMessageDeleteOption {
  deleteForMe,
  deleteForEveryone,
}

enum ChatType { one_to_one, group, channel }
// enum CallStatus {missed, completed, ongoing,accepted}

enum CallStatus {
  missed("missed", "missed", "assets/svg/close_red.svg"),
// ended("ended","ended","assets/svg/arrow-small-down.svg"),
// completed("completed","completed",'assets/svg/arrow-small-up.svg'),
  outgoing("outgoing", "outgoing", 'assets/svg/arrow-small-up.svg'),
  incoming("incoming", "incoming", 'assets/svg/arrow-small-down.svg'),
// accepted("accepted","accepted",'assets/svg/arrow-small-up.svg'),
  ;

  final String name;
  final String value;
  final String icon;
  const CallStatus(
    this.name,
    this.value,
    this.icon,
  );
}

enum NotificationType {
  message,

  group_invite,
  create_new_group,
  assign_admin,
  delete_group,
  removed_group,
  removed_member_group,
  new_group_created,
  leave_group,

  voice,
  video,
  video_group_call,
  voice_group_call,
  other,

  channel_mention,
  create_new_channel,
  channel_invite,
  removed_channel,
  leave_channel,
  delete_channel,
  removed_member_channel,

  chat_message,

  agora_call_invitation,
  agora_end_call,
}

enum Languages {
  // czech("czech", "Čeština", "cs"), // Czech as default
  english("english", "English", "en"),
  german("german", "Deutsch", "de"),
  spanish("spanish", "Español", "es"),
  dutch("dutch", "Nederlands", "nl");

  final String value; // Identifier
  final String name; // Display Name
  final String code; // Locale Code

  const Languages(this.value, this.name, this.code);
}

enum ProfilePivacy {
  // czech("czech", "Čeština", "cs"), // Czech as default
  public(
    "public",
    "Public",
  ),
  private(
    "private",
    "Private",
  );

  final String value; // Identifier
  final String name; // Display Name
// Locale Code

  const ProfilePivacy(
    this.value,
    this.name,
  );
}

class CustomPhoneNumber {
  String countryISOCode;
  String countryCode;
  String number;

  CustomPhoneNumber({
    required this.countryISOCode,
    required this.countryCode,
    required this.number,
  });

  factory CustomPhoneNumber.fromCompleteNumber(
      {required String completeNumber}) {
    if (completeNumber == "") {
      return CustomPhoneNumber(countryISOCode: "", countryCode: "", number: "");
    }

    try {
      Country country = getCountry(completeNumber);
      String number;
      if (completeNumber.startsWith('+')) {
        number = completeNumber
            .substring(1 + country.dialCode.length + country.regionCode.length);
      } else {
        number = completeNumber
            .substring(country.dialCode.length + country.regionCode.length);
      }
      return CustomPhoneNumber(
          countryISOCode: country.code,
          countryCode: country.dialCode + country.regionCode,
          number: number);
    } on InvalidCharactersException {
      rethrow;
      // ignore: unused_catch_clause
    } on Exception catch (e) {
      return CustomPhoneNumber(countryISOCode: "", countryCode: "", number: "");
    }
  }

  bool isValidNumber() {
    Country country = getCountry(completeNumber);
    if (number.length < country.minLength) {
      throw NumberTooShortException();
    }

    if (number.length > country.maxLength) {
      throw NumberTooLongException();
    }
    return true;
  }

  String get completeNumber {
    return countryCode + number;
  }

  static Country getCountry(String phoneNumber) {
    if (phoneNumber == "") {
      throw NumberTooShortException();
    }

    final validPhoneNumber = RegExp(r'^[+0-9]*[0-9]*$');

    if (!validPhoneNumber.hasMatch(phoneNumber)) {
      throw InvalidCharactersException();
    }

    if (phoneNumber.startsWith('+')) {
      return countries.firstWhere((country) => phoneNumber
          .substring(1)
          .startsWith(country.dialCode + country.regionCode));
    }
    return countries.firstWhere((country) =>
        phoneNumber.startsWith(country.dialCode + country.regionCode));
  }

  @override
  String toString() =>
      'PhoneNumber(countryISOCode: $countryISOCode, countryCode: $countryCode, number: $number)';
}

class ChatOption {
  final String value;
  final String name;
  final Widget icon;
  final VoidCallback? onTap;

  ChatOption({
    required this.value,
    required this.name,
    required this.icon,
    this.onTap,
  });
}

class AppMethods {
  static String getNickName(Sender? sender) {
    if (sender?.isActiveNickname ?? false) {
      return sender?.nickName ?? sender?.name ?? sender?.userName ?? "";
    } else {
      return sender?.name ?? sender?.userName ?? "";
    }
  }

  static String getNickNameForParticipateDetails(ParticipantDetail? sender) {
    if (sender?.isActiveNickname ?? false) {
      return sender?.nickName ?? sender?.name ?? sender?.userName ?? "";
    } else {
      return sender?.name ?? sender?.userName ?? "";
    }
  }
}
