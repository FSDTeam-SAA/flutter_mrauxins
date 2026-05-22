import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:two_one_two_messenger/GoogleAds/config_model.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/main.dart';
import 'package:two_one_two_messenger/models/call_history_model.dart';
import 'package:two_one_two_messenger/models/common_res.dart';
import 'package:two_one_two_messenger/models/group_info_model.dart';
import 'package:two_one_two_messenger/models/nick_name/nick_name_response.dart';
import 'package:two_one_two_messenger/models/notification_model.dart';
import 'package:two_one_two_messenger/models/saved_messages.dart';
import 'package:two_one_two_messenger/models/toggle_nickname_response.dart';
import 'package:two_one_two_messenger/models/token_and_channel.dart';
import 'package:two_one_two_messenger/models/user_name_check_res.dart';
import 'package:two_one_two_messenger/screens/login_screen.dart';
import 'package:two_one_two_messenger/utils/constants.dart';

import '../database/local_db.dart';
import '../models/all_user.dart';
import '../models/chat_message_model.dart';
import '../models/conversation_model.dart';
import '../models/create_conversaion_model.dart';
import '../models/delete_device_token.dart';
import '../models/stories_response.dart';
import '../models/otp_verify.dart';
import '../models/send_otp.dart';
import '../models/sent_message_model.dart';
import '../models/update_profile.dart';
import '../utils/logger.dart';
import '../utils/navigation.dart';
import '../utils/utils.dart';
import 'api_config.dart';

class ApiClient {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  final Dio dio;

  ApiClient()
      : dio = Dio(BaseOptions(
          baseUrl: Urls.baseURL,
          connectTimeout: const Duration(seconds: 5000),
          receiveTimeout: const Duration(seconds: 3000),
        )) {
    dio.interceptors.add(LogInterceptor(
      responseBody: true,
      requestBody: true,
    ));
    dio.options.contentType = Headers.jsonContentType;
    const String acceptHeader = 'application/json';
    dio.options.headers['Accept'] = acceptHeader;

    _initializeBaseURL();
  }

  Future<void> _initializeBaseURL() async {
    String? baseURL = await _databaseHelper.getBaseURL();
    AppLogger.logs(baseURL.toString());
    if (baseURL != null) {
      dio.options.baseUrl = baseURL;
      AppLogger.logs(dio.options.baseUrl);
    } else {
      // Handle case where baseURL is not set, e.g., throw an exception or log
      AppLogger.logs("Base URL is not set.");
    }
  }

  // Handling GET request
  Future<Response> get(String endpoint,
      {bool requiresToken = false, Map<String, dynamic>? params}) async {
    return _handleRequest(
        () => dio.get(endpoint, queryParameters: params), requiresToken);
  }

  // Handling POST request
  Future<Response> post(String endpoint, dynamic data,
      {bool requiresToken = false}) async {
    return _handleRequest(
        () => dio.post(
              endpoint,
              data: data.runtimeType == FormData ? data : jsonEncode(data),
              options: Options(headers: {'Content-Type': 'application/json'}),
            ),
        requiresToken);
  }

  Future<Response> postWithFormData(
    String url,
    Future<FormData> Function() dataBuilder, {
    bool requiresToken = true,
    Function(double)? onProgress,
  }) async {
    return _handleRequest(() async {
      return dio.post(
        url,
        data: await dataBuilder(),
        options: Options(headers: {'Content-Type': 'application/json'}),
        onSendProgress: (int sent, int total) {
          double progress = sent / total;
          if (onProgress != null) onProgress(progress);
        },
      );
    }, requiresToken);
  }

  Future<Response> putWithFormData(
    String url,
    Future<FormData> Function() dataBuilder, {
    bool requiresToken = true,
  }) async {
    return _handleRequest(() async {
      return dio.put(
        url,
        data: await dataBuilder(),
        // options: Options(headers: {'Content-Type': 'application/json'}),
      );
    }, requiresToken);
  }

  // Handling PUT request
  Future<Response> put(String endpoint, dynamic data,
      {bool requiresToken = false}) async {
    return _handleRequest(() => dio.put(endpoint, data: data), requiresToken);
  }

  // Handling DELETE request
  Future<Response> delete(String endpoint,
      {Map<String, dynamic>? queryParameters,
      dynamic data,
      bool requiresToken = false}) async {
    return _handleRequest(
        () =>
            dio.delete(endpoint, queryParameters: queryParameters, data: data),
        requiresToken);
  }

  // Private method to handle token and exceptions
  Future<Response> _handleRequest(
      Future<Response> Function() request, bool requiresToken) async {
    try {
      if (requiresToken) {
        final token = await _databaseHelper.getToken();
        dio.options.headers['ngrok-skip-browser-warning'] = "1";
        dio.options.headers['User-Agent'] = "custom/non-standard browser";
        dio.options.headers["Authorization"] = "Bearer $token";
        showMessage("new accessToken ==> $token");
      }
      final response = await request();

      // Log successful response
      AppLogger.logs("API Success: ${response.data}");
      return response;
    } on DioException catch (e) {
      // Handle different HTTP status codes
      String errorMessage;

      if (e.response != null) {
        // Get response data for better error messages

        if (e.response!.statusCode == 403) {
          final retryResponse = await refreshToken(request, requiresToken);
          if (retryResponse != null) {
            return retryResponse; // ✅ Success on retry
          } else {
            manageLogout();
            return Response(
              requestOptions: e.requestOptions,
              statusCode: 403,
              data: {'message': 'Unauthorized'},
            );
          }
        }

        errorMessage = _handleErrorResponse(e.response!);
      } else {
        // If no response is available, it might be a connection error
        errorMessage = 'Server Connection Error';
      }

      AppLogger.logs("API Error: $errorMessage");
      throw Exception(errorMessage);
    }
  }

  manageLogout() async {
    await DatabaseHelper().saveKeepLoggedIn(false, "", "");
    await DatabaseHelper().deleteLoginData();
    await AppPreference.clearSharedPreferences();
    //TODO ///NOTE: SignIn With google and facebook
    // await GoogleSignIn().signOut();
    await sendOtpCubit.resetSendOtpState();
    NavigationService().clearAndNavigateTo(LoginScreen());
  }

  String _handleErrorResponse(
    Response response,
  ) {
    if (Utils.isDebug) {
      switch (response.statusCode) {
        case 400:
          return '${response.data['message'] ?? response.statusMessage.toString()}';
        case 401:
          return '${response.data['message'] ?? response.statusMessage.toString()}';
        // case 403:
        //   manageLogout();
        //   return '${response.data['message'] ?? response.statusMessage.toString()}';
        case 404:
          return '${response.data['message'] ?? response.statusMessage.toString()}';
        case 500:
          return '${response.data['message'] ?? response.statusMessage.toString()}';
        default:
          return response.statusMessage.toString();
      }
    } else {
      switch (response.statusCode) {
        case 400:
          return '${response.data['message'] ?? response.statusMessage.toString()}';
        case 401:
          return '${response.data['message'] ?? response.statusMessage.toString()}';
        // case 403:
        //   manageLogout();
        //   return '${response.data['message'] ?? response.statusMessage.toString()}';
        case 404:
          return response.statusMessage.toString();
        case 500:
          return '${response.data['message'] ?? response.statusMessage.toString()}';
        default:
          return response.statusMessage.toString();
      }
    }
  }

  Future<GetAgoraAppId> getAppIdForAgora() async {
    try {
      final response = await get(
        APIS.getAppIdForAgora,
        requiresToken: true,
      );

      final getAgoraAppIdResponse = GetAgoraAppId.fromJson(response.data);
      // showMessage("REsponse::::fghhgfhghgh::::::${chatResponse}");
      return getAgoraAppIdResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';

      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<Response?> refreshToken(
      Future<Response> Function() request, bool requiresToken) async {
    try {
      final refreshToken = AppPreference.getUserRefreshToken();
      final response = await dio.get(APIS.refreshToken,
          options: Options(headers: {
            "ngrok-skip-browser-warning": "1",
            "User-Agent": "custom/non-standard browser",
            "Authorization": "Bearer $refreshToken",
          }));

      final otpResponse = OtpVerifyResponse.fromJson(response.data);
      if (otpResponse.status == 1) {
        showMessage("Refresh Token ==> ${otpResponse.toJson()}");
        await _databaseHelper.saveToken(otpResponse.data?.token ?? '');
        await AppPreference.setUserRefreshToken(
            otpResponse.data?.refreshToken ?? '');
        return await _handleRequest(request, requiresToken);
      }
      // Return the parsed response
      return null;
    } on DioException catch (e, st) {
      String errorMessage = e.response?.data['message'] ?? 'Send Otp failed';
      AppLogger.logs('Send Otp Error: $errorMessage');
      showMessage("Error sendOtp $e $st");
      manageLogout();
      throw Exception(errorMessage);
    }
  }

  Future<SendOtpResponse> sendOtp(String email, BuildContext context) async {
    try {
      final response = await post(
        APIS.sendOtp,
        {
          'email': email,
        },
        requiresToken: false,
      );

      final otpResponse = SendOtpResponse.fromJson(response.data);

      return otpResponse; // Return the parsed response
    } on DioException catch (e, st) {
      String errorMessage = e.response?.data['message'] ?? 'Send Otp failed';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Send Otp Error: $errorMessage');
      showMessage("Error sendOtp $e $st");
      throw Exception(errorMessage);
    }
  }

  Future<CommonResponseModel> syncContact(BuildContext context) async {
    try {
      final response = await post(
        APIS.syncContact,
        {
          'contacts': await Utils.getLocalContacts(),
        },
        requiresToken: false,
      );

      final otpResponse = CommonResponseModel.fromJson(response.data);

      return otpResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Sync contact failed';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Sync Contact  Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<OtpVerifyResponse> otpVerify(String text, String otp, String fcmToken,
      String countryISOCode, String countryCode, BuildContext context) async {
    try {
      Map<String, dynamic> data = Utils.isValidEmail(text)
          ? {
              'email': text,
              'otp': otp,
              'fcmToken': fcmToken,
              'deviceType': Platform.isAndroid ? 'Android' : 'ios'
            }
          : {
              'phone': text,
              'countryISOCode': countryISOCode,
              'countryCode': countryCode,
              'fcmToken': fcmToken,
              'deviceType': Platform.isAndroid ? 'Android' : 'ios'
            };

      showMessage("otpVerify=======>$data");
      final response = await post(
        APIS.verifyOtp,
        data,
        requiresToken: false,
      );

      final otpResponse = OtpVerifyResponse.fromJson(response.data);

      if (otpResponse.status == Utils.APISUCCESS) {
        await _databaseHelper.saveToken(otpResponse.data?.token ?? '');
        await AppPreference.setUserRefreshToken(
            otpResponse.data?.refreshToken ?? '');
        await _databaseHelper.insertLoginData(otpResponse.data!.user!);
      }

      return otpResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Otp verification failed';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Otp Verification Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<SendOtpResponse> sendOtpForEmailChange(
      String email, BuildContext context) async {
    try {
      final response = await post(
        APIS.requestEmailChange,
        {
          'email': email,
        },
        requiresToken: true,
      );

      final otpResponse = SendOtpResponse.fromJson(response.data);

      return otpResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage = e.response?.data['message'] ?? 'Send Otp failed';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Send Otp Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CommonResponseModel?> updateFcmToken(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await post(
        APIS.updateFcmToken,
        data,
        requiresToken: false,
      );

      final res = CommonResponseModel.fromJson(response.data);

      return res; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage = e.response?.data['message'] ?? 'Send Otp failed';
      // Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Send Otp Error: $errorMessage');
      // throw Exception(errorMessage);
      return null;
    }
  }

  Future<UpdateProfileResponse> verifyOtpForEmailChange(
      String text, String otp, BuildContext context) async {
    try {
      Map<String, dynamic> data = {
        'newEmail': text,
        'otp': otp,
      };

      showMessage("otpVerifyForEmailChange=======>$data");
      final response = await post(
        APIS.verifyEmailChange,
        data,
        requiresToken: true,
      );

      final otpResponse = UpdateProfileResponse.fromJson(response.data);

      return otpResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Otp verification failed';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Otp Verification Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<UserNameCheckRes> checkForUserName(
      String userName, BuildContext context) async {
    try {
      Map<String, dynamic> data = {
        'userName': userName,
      };

      showMessage("checkForUserName=======>$data");
      final response = await post(
        APIS.checkUserName,
        data,
        requiresToken: true,
      );

      final checkUserName = UserNameCheckRes.fromJson(response.data);

      return checkUserName; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage = e.response?.data['message'] ??
          S.current.somethingWentWrongPleaseTryAgain;
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Otp Verification Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<UserNameCheckRes> checkForMobile(
      String mobile, String countryCode, BuildContext context) async {
    try {
      Map<String, dynamic> data = {'phone': mobile, 'countryCode': countryCode};

      showMessage("checkForUserName=======>$data");
      final response = await post(
        APIS.checkUserName,
        data,
        requiresToken: true,
      );

      final checkUserName = UserNameCheckRes.fromJson(response.data);

      return checkUserName; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage = e.response?.data['message'] ??
          S.current.somethingWentWrongPleaseTryAgain;
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Otp Verification Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<GetProfileResponse> getUserProfile() async {
    try {
      final response = await get(
        APIS.getProfile,
        requiresToken: false,
      );

      final profileResponse = GetProfileResponse.fromJson(response.data);

      if (profileResponse.status == Utils.APISUCCESS) {
        // await _databaseHelper.saveToken(otpResponse.data?.token ?? '');
        await _databaseHelper.insertLoginData(profileResponse.data!);
      }

      return profileResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Otp verification failed';
      // Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Otp Verification Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<OtpVerifyResponse> socialLoginVerify({
    required String text,
    required SignInProvider provider,
    required String providerId,
    required String fcmToken,
    required BuildContext context,
    required String name,
    required String photoUrl,
    required String phone,
  }) async {
    try {
      // showMessage("Input data for social Login ${{
      //           'email': text,
      //           'provider': 'google',
      //           'providerId': providerId,
      //           'fcmToken': fcmToken,
      //           'deviceType': Platform.isAndroid ? 'Android' : 'ios'
      //         }}");
      Map<String, dynamic> inputData = {
        'email': text,
        'provider': provider == SignInProvider.google ? 'google' : 'facebook',
        'providerId': providerId,
        'fcmToken': fcmToken,
        'deviceType': Platform.isAndroid ? 'Android' : 'ios',
        "name": name,
        "photoURL": photoUrl,
      };
      if (phone.isNotEmpty) {
        CustomPhoneNumber phoneNumber =
            CustomPhoneNumber.fromCompleteNumber(completeNumber: phone);
        inputData["phone"] = phoneNumber.number;
        inputData["countryCode"] = phoneNumber.countryCode;
        inputData["countryISOCode"] = phoneNumber.countryISOCode;
      }

      final response = await post(
        APIS.verifyOtp,
        inputData,
        requiresToken: false,
      );

      final otpResponse = OtpVerifyResponse.fromJson(response.data);

      return otpResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Sign in verification failed';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Sign in Verification Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<DeleteTokenResponse> deleteToken(
      String userId, String token, BuildContext context) async {
    try {
      final response = await delete(
        APIS.deleteToken,
        data: {
          'userId': userId,
          'deviceToken': token,
        },
        requiresToken: true,
      );

      DeleteTokenResponse deleteTokenResponse =
          DeleteTokenResponse.fromJson(response.data);

      return deleteTokenResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage = e.response?.data['message'] ?? 'Send Otp failed';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Send Otp Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CommonResponseModel> deleteAccount(BuildContext context) async {
    try {
      final response = await delete(
        APIS.deleteAccount,
        // data: {
        //   'userId': userId,
        //   'deviceToken': token,
        // },
        requiresToken: true,
      );

      CommonResponseModel deleteAccountResponse =
          CommonResponseModel.fromJson(response.data);

      return deleteAccountResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage = e.response?.data['message'] ?? 'Send Otp failed';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Send Otp Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<ConfigModelRes> getAdsConfig() async {
    try {
      final response = await get(
        APIS.getAdsConfig,
        // data: {
        //   'userId': userId,
        //   'deviceToken': token,
        // },
        requiresToken: false,
      );

      ConfigModelRes adsConfigRes = ConfigModelRes.fromJson(response.data);

      return adsConfigRes; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'get Ads Config failed';

      AppLogger.logs('get Ads Config Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<UpdateProfileResponse> updateUserProfile(
      {required Map<String, dynamic> data,
      required BuildContext context,
      File? file}) async {
    try {
      String fileName = '';

      if (file != null) {
        fileName = file.path.split('/').last;
        data['files'] = [
          await MultipartFile.fromFile(file.path,
              filename: fileName, contentType: MediaType('image', '*'))
        ];
      }

      showMessage("Map ==? $data");

      final response = await putWithFormData(
        APIS.user,
        () async => FormData.fromMap(data),
        requiresToken: true,
      );

      final updateProfileResponse =
          UpdateProfileResponse.fromJson(response.data);

      return updateProfileResponse; // Return the parsed response
    } on DioException catch (e, st) {
      // String errorMessage =
      //     e.response?.data['message'] ?? 'Update profile failed';
      AppLogger.logs('Update profile Error: $e $st');
      Utils.showSnackBar(context, S.current.somethingWentWrongPleaseTryAgain);
      throw Exception(e);
    }
  }

  Future<AllUserResponse> getAllUser(String name, int page, int limit,
      BuildContext context, List<String> contactNumbers) async {
    try {
      final response = await get(APIS.user, requiresToken: true, params: {
        "search": name,
        "page": page,
        "limit": limit,
        "contactNumbers": jsonEncode(contactNumbers)
      });

      final allUserResponse = AllUserResponse.fromJson(response.data);

      print("All Users Length${allUserResponse.data?.users?.length}");

      return allUserResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Update profile failed';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Update profile Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<ConversationModel> getConversationForForwadMessage(
      {required BuildContext context, Map<String, dynamic>? params}) async {
    try {
      final response = await get(APIS.getConversationForForwadMessage,
          requiresToken: true, params: params);

      final conversationResponse = ConversationModel.fromJson(response.data);
      log("REsponse::::::::::===> ${response.data}");
      return conversationResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<ConversationModel> getConversation(
      {required BuildContext context, Map<String, dynamic>? params}) async {
    try {
      final response =
          await get(APIS.getConversation, requiresToken: true, params: params);

      final conversationResponse = ConversationModel.fromJson(response.data);
      // log("REsponse::::::::::===> ${response.data["data"]["chats"][0]}");
      return conversationResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CreateConversionModel> createConversion(
      String userId, BuildContext context) async {
    try {
      final response = await post(
        APIS.createConversation,
        {"userId2": userId},
        requiresToken: true,
      );

      final conversationResponse =
          CreateConversionModel.fromJson(response.data);
      showMessage("REsponse::::::::::${conversationResponse}");
      return conversationResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<TokenAndChannelResponse> requestCall(
      {required String chatId,
      required Map<String, dynamic> data,
      required BuildContext context}) async {
    try {
      final response = await post(
        APIS.requestCall + chatId,
        data,
        requiresToken: true,
      );

      final callRes = TokenAndChannelResponse.fromJson(response.data);
      showMessage("REsponse::::::::::requestCall==>${callRes.toJson()}");
      return callRes; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<ChatMessageModelResponse> getChatMessages(String chatId,
      BuildContext context, String aesKey, Map<String, dynamic>? params) async {
    try {
      final response = await get(
        "${APIS.chat}$chatId",
        params: params,
        requiresToken: true,
      );

      final chatResponse =
          ChatMessageModelResponse.fromJson(response.data, aesKey);
      // showMessage("REsponse::::fghhgfhghgh::::::${chatResponse}");
      return chatResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<SentMessageModel> sentMessage(
    BuildContext context, {
    required int mediaType,
    required String type,
    required String messageId,
    required String messageTime,
    String? chatId,
    String? aesKey,
    String? content,
    String? replyToMessageId,
    List<XFile>? files,
    String? gifUrl,
    String? sizeForGIF,
    Function(double)? onProgress,
  }) async {
    try {
      // showMessage("Form data ==> ${data.fields}");

      final response = await postWithFormData(
        APIS.sentMessage,
        () async {
          FormData data = FormData.fromMap({
            "chatId": chatId,
            if (content != null && content.isNotEmpty) "content": content,
            "type": type,
            "messageId": messageId,
            if (replyToMessageId != null) "replyToMessageId": replyToMessageId,
            if ((gifUrl ?? "").isNotEmpty && (sizeForGIF != null))
              "url": gifUrl,
            if ((gifUrl ?? "").isNotEmpty && (sizeForGIF != null))
              "size": sizeForGIF,
            "createdAt": messageTime,
          });
          print("sent Message = data ${{
            "chatId": chatId,
            // if (content != null && content.isNotEmpty) "content": content,
            // "type": type,
            // "messageId": messageId,
            // if ((gifUrl ?? "").isNotEmpty && (sizeForGIF != null))
            //   "url": gifUrl,
            // if ((gifUrl ?? "").isNotEmpty && (sizeForGIF != null))
            //   "size": sizeForGIF,
            "aesKey": aesKey
          }}");
          // Add multiple files to FormData
          if (files != null && files.isNotEmpty) {
            for (int i = 0; i < files.length; i++) {
              final mimeType =
                  lookupMimeType(files[i].path) ?? 'application/octet-stream';
              final mimeTypeSplit = mimeType.split('/');
              data.files.add(MapEntry(
                'files',
                // The key on the server side (you may need to adjust this depending on your API)
                await MultipartFile.fromFile(files[i].path,
                    filename: files[i].path.split('/').last,
                    contentType: MediaType(mimeTypeSplit[0], mimeTypeSplit[1])),
              ));
            }
          }
          return data;
        },
        onProgress: onProgress,
        requiresToken: true,
      );

      final sentMessageResponse =
          SentMessageModel.fromJson(response.data, aesKey ?? "");
      return sentMessageResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(e);
    }
  }

  Future<SentMessageModel> sentSaveMessage(BuildContext context,
      {required int mediaType,
      required String type,
      required String messageId,
      String? replyToMessageId,
      String? aesKey,
      required String content,
      List<XFile>? files,
      String? gifUrl,
      String? sizeForGIF}) async {
    try {
      final response = await postWithFormData(
        APIS.sentSaveMessage,
        () async {
          FormData data = FormData.fromMap({
            // "chatId": chatId,
            "content": content,
            "type": type,
            "messageId": messageId,
            if (replyToMessageId != null) "replyToMessageId": replyToMessageId,
            if ((gifUrl ?? "").isNotEmpty && (sizeForGIF != null))
              "url": gifUrl,
            if ((gifUrl ?? "").isNotEmpty && (sizeForGIF != null))
              "size": sizeForGIF,
          });
          showMessage("sent Message = data ${{
            // "chatId": chatId,
            if (content != null && content.isNotEmpty) "content": content,
            "type": type,
            "messageId": messageId,
            if ((gifUrl ?? "").isNotEmpty && (sizeForGIF != null))
              "url": gifUrl,
            if ((gifUrl ?? "").isNotEmpty && (sizeForGIF != null))
              "size": sizeForGIF,
          }}");
          // Add multiple files to FormData
          if (files != null && files.isNotEmpty) {
            for (int i = 0; i < files.length; i++) {
              final mimeType =
                  lookupMimeType(files[i].path) ?? 'application/octet-stream';
              final mimeTypeSplit = mimeType.split('/');
              data.files.add(MapEntry(
                'files',
                // The key on the server side (you may need to adjust this depending on your API)
                await MultipartFile.fromFile(files[i].path,
                    filename: files[i].path.split('/').last,
                    contentType: MediaType(mimeTypeSplit[0], mimeTypeSplit[1])),
              ));
            }
          }

          showMessage("Form data ==> ${data.fields}");
          return data;
        },
        requiresToken: true,
      );

      final sentMessageResponse =
          SentMessageModel.fromJson(response.data, aesKey ?? "");
      return sentMessageResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(e);
    }
  }

  Future<CreateConversionModel> createGroup(
    BuildContext context, {
    required Map<String, dynamic> inputData,
    required List<XFile>? files,
  }) async {
    try {
      final response = await postWithFormData(
        APIS.createGroup,
        () async {
          FormData data = FormData.fromMap(inputData);

          // Add multiple files to FormData
          if (files != null && files.isNotEmpty) {
            for (int i = 0; i < files.length; i++) {
              final mimeType =
                  lookupMimeType(files[i].path) ?? 'application/octet-stream';
              final mimeTypeSplit = mimeType.split('/');
              data.files.add(MapEntry(
                'files',
                // The key on the server side (you may need to adjust this depending on your API)
                await MultipartFile.fromFile(files[i].path,
                    filename: files[i].path.split('/').last,
                    contentType: MediaType(mimeTypeSplit[0], mimeTypeSplit[1])),
              ));
            }
          }

          showMessage("Form data ==> ${data.fields}");
          return data;
        },
        requiresToken: true,
      );

      final createGroupResponse = CreateConversionModel.fromJson(response.data);
      return createGroupResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(e);
    }
  }

  Future<CreateConversionModel> updateGroup(
    BuildContext context, {
    required String groupId,
    required Map<String, dynamic> inputData,
    required List<XFile>? files,
  }) async {
    try {
      final response = await putWithFormData(
        "${APIS.updateGroup}$groupId",
        () async {
          FormData data = FormData.fromMap(inputData);

          // Add multiple files to FormData
          if (files != null && files.isNotEmpty) {
            for (int i = 0; i < files.length; i++) {
              final mimeType =
                  lookupMimeType(files[i].path) ?? 'application/octet-stream';
              final mimeTypeSplit = mimeType.split('/');
              data.files.add(MapEntry(
                'files',
                // The key on the server side (you may need to adjust this depending on your API)
                await MultipartFile.fromFile(files[i].path,
                    filename: files[i].path.split('/').last,
                    contentType: MediaType(mimeTypeSplit[0], mimeTypeSplit[1])),
              ));
            }
          }

          showMessage("Form data ==> ${data.fields}");
          return data;
        },
        requiresToken: true,
      );

      final createGroupResponse = CreateConversionModel.fromJson(response.data);
      return createGroupResponse; // Return the parsed response
    } on DioException catch (e, st) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage, $st');

      throw Exception(e);
    }
  }

  Future<GroupResponseModel> getGroupInfobyId(
      {required String groupId, required BuildContext context}) async {
    try {
      final response = await get(
        "${APIS.getGroupInfobyId}$groupId",
        requiresToken: true,
      );
// showMessage("getGroupInfobyId==> ${jsonEncode(response.data)}");
      GroupResponseModel groupDetails =
          GroupResponseModel.fromJson(response.data);
      return groupDetails; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CommonResponseModel> assignAdminToGroup({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await post(
        APIS.assignAdminToGroup,
        data,
        requiresToken: true,
      );
      CommonResponseModel res = CommonResponseModel.fromJson(response.data);
      return res; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      // Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CommonResponseModel> removeMemberToGroup({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await post(
        APIS.removeMemberToGroup,
        data,
        requiresToken: true,
      );
      CommonResponseModel res = CommonResponseModel.fromJson(response.data);
      return res; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      // Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CommonResponseModel> addMemberToGroup({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await post(
        APIS.addMemberToGroup,
        data,
        requiresToken: true,
      );
      CommonResponseModel res = CommonResponseModel.fromJson(response.data);
      return res; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      // Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CommonResponseModel> deleteChat({
    required String chatId,
  }) async {
    try {
      final response = await delete(
        APIS.deleteChat,
        data: {"chatId": chatId},
        requiresToken: true,
      );
      CommonResponseModel res = CommonResponseModel.fromJson(response.data);
      return res; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(navigatorKey.currentContext!, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CommonResponseModel> deleteGroup({
    required String groupId,
  }) async {
    try {
      final response = await delete(
        "${APIS.deleteGroup}$groupId",
        requiresToken: true,
      );
      CommonResponseModel res = CommonResponseModel.fromJson(response.data);
      return res; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(navigatorKey.currentContext!, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CommonResponseModel> leaveGroup({
    required String groupId,
  }) async {
    try {
      final response = await delete(
        "${APIS.leaveGroup}$groupId",
        requiresToken: true,
      );
      CommonResponseModel res = CommonResponseModel.fromJson(response.data);
      return res; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      // Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CommonMessageResponse> deleteChatMessages(
      {required String messageId,
      required String chatId,
      required bool deleteForEveryOne,
      required BuildContext context}) async {
    try {
      final response = await delete(
        APIS.deleteChatMessage,
        data: {
          "messageId": messageId,
          "chatId": chatId,
          "deleteForEveryOne": deleteForEveryOne
        },
        requiresToken: true,
      );

      CommonMessageResponse deleteChatMessages =
          CommonMessageResponse.fromJson(response.data);
      return deleteChatMessages; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CommonMessageResponse> deleteSavedMessages(
      {required String messageId, required BuildContext context}) async {
    try {
      final response = await delete(
        APIS.deleteSavedMessage,
        queryParameters: {
          "messageId": messageId,
        },
        requiresToken: true,
      );

      CommonMessageResponse deleteChatMessages =
          CommonMessageResponse.fromJson(response.data);
      return deleteChatMessages; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CommonMessageResponse> clearChat(String chatId) async {
    try {
      final response = await delete(
        '${APIS.clearChat}/$chatId',
        requiresToken: true,
      );

      CommonMessageResponse clearChatMessages =
          CommonMessageResponse.fromJson(response.data);
      return clearChatMessages; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      // Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CommonResponseModel> clearAllNotification() async {
    try {
      final response = await delete(
        APIS.clearNotification,
        requiresToken: true,
      );

      CommonResponseModel clearAllNotification =
          CommonResponseModel.fromJson(response.data);
      return clearAllNotification; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      // Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CommonMessageResponse> clearAllSavedMessages(
      BuildContext context) async {
    try {
      final response = await delete(
        APIS.clearAllSavedMessage,
        requiresToken: true,
      );

      CommonMessageResponse deleteChatMessages =
          CommonMessageResponse.fromJson(response.data);
      return deleteChatMessages; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CommonMessageResponse> saveMessage(
      {required Map<String, dynamic> data,
      required BuildContext context}) async {
    try {
      final response = await post(
        APIS.savedMessages,
        data,
        requiresToken: true,
      );

      CommonMessageResponse savedMessages =
          CommonMessageResponse.fromJson(response.data);
      return savedMessages; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<GetSavedMessagesResponse> getSaveMessages(
      BuildContext context, Map<String, dynamic>? params) async {
    try {
      final response = await get(
        APIS.savedMessages,
        params: params,
        requiresToken: true,
      );
      showMessage("get Saved message == ${jsonEncode(response.data)}");
      GetSavedMessagesResponse savedMessages =
          GetSavedMessagesResponse.fromJson(response.data, "");
      return savedMessages; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CreateStoriesResponse> createStories(File? file, String caption,
      int? duration, BuildContext context, MimeType? mimeType) async {
    try {
      String fileName = '';
      bool result = false;
      if (file != null) {
        fileName = file.path.split('/').last;
        if (mimeType != null) {
          result = mimeType == MimeType.image;
        } else {
          result = Utils.isImage(file.path);
        }
      }

      Map<String, dynamic> map = {
        if (file != null)
          'files': [
            await MultipartFile.fromFile(
              file.path,
              filename: fileName,
              contentType:
                  result ? MediaType('image', '*') : MediaType('video', '*'),
            ),
          ],
        'mediaType': result ? 'image' : 'video',
        if (caption.isNotEmpty) 'caption': caption,
        'duration': duration ?? 5
      };

      final response = await postWithFormData(
        APIS.createStories,
        () async {
          return FormData.fromMap(map);
        },
        requiresToken: true,
      );

      final createStoriesResponse =
          CreateStoriesResponse.fromJson(response.data);

      return createStoriesResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Update profile failed';
      AppLogger.logs('Update profile Error: $errorMessage');
      Utils.showSnackBar(context, errorMessage);
      throw Exception(errorMessage);
    }
  }

  Future<DeleteStoriesResponse> deleteStories(
      String storiesId, BuildContext context) async {
    try {
      final response = await delete(
        "${APIS.stories}$storiesId",
        requiresToken: true,
      );

      DeleteStoriesResponse deleteStoriesResponse =
          DeleteStoriesResponse.fromJson(response.data);

      return deleteStoriesResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CurrentUserStoriesResponse> getLoggedInUserStories(
      BuildContext context) async {
    try {
      final response = await get(
        APIS.getCurrentUserStories,
        requiresToken: true,
      );

      CurrentUserStoriesResponse currentUserStoriesResponse =
          CurrentUserStoriesResponse.fromJson(response.data);

      return currentUserStoriesResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<GetAllStoriesResponse> getStoriesData(
      int page, int limit, BuildContext context) async {
    try {
      final response = await get(
        '${APIS.stories}?page=$page', //&limit=$limit
        requiresToken: true,
      );
      showMessage("Get Story Data ${jsonEncode(response.data)}");
      GetAllStoriesResponse getAllStoriesResponse =
          GetAllStoriesResponse.fromJson(response.data);

      return getAllStoriesResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<ViewStoriesUpdateResponse> viewerStoriesUpdate(
      String storiesId, BuildContext context) async {
    try {
      final response = await post(
        '${APIS.stories}/$storiesId/view',
        {},
        requiresToken: true,
      );

      final viewStoriesUpdateResponse =
          ViewStoriesUpdateResponse.fromJson(response.data);
      return viewStoriesUpdateResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CommonResponseModel> blockedUser(
      {required String chatId,
      required String userId,
      required BuildContext context}) async {
    try {
      final response = await post(
        APIS.blockedUser,
        {
          "blockedUserId": userId,
          "chatId": chatId,
        },
        requiresToken: true,
      );

      print("DTA. >> uID $userId chatId $chatId");

      final blockedUserResponse = CommonResponseModel.fromJson(response.data);
      return blockedUserResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CommonResponseModel> unBlockedUser(
      {required String userId, required BuildContext context}) async {
    try {
      final response = await post(
        APIS.unBlockedUser,
        {
          "blockedUserId": userId,
        },
        requiresToken: true,
      );

      final unBlockedUserResponse = CommonResponseModel.fromJson(response.data);
      return unBlockedUserResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CommonResponseModel> reportUser(
      {required Map<String, dynamic> data,
      required BuildContext context}) async {
    try {
      final response = await post(
        APIS.reportUser,
        data,
        requiresToken: true,
      );

      final reportUserResponse = CommonResponseModel.fromJson(response.data);
      return reportUserResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CommonResponseModel> getAllBlockedUser(
      {required BuildContext context}) async {
    try {
      final response = await get(
        APIS.getBlockedUsers,
        requiresToken: true,
      );

      final blockedUserResponse = CommonResponseModel.fromJson(response.data);
      return blockedUserResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CallHistoryResponse> getAllCallsHistory(
      int page, int limit, BuildContext context) async {
    try {
      final response = await get(
        '${APIS.getCallsHistory}?page=$page&limit=$limit',
        requiresToken: true,
      );

      final callHistoryResponse = CallHistoryResponse.fromJson(response.data);

      return callHistoryResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? S.current.somethingWentWrong;
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Update profile Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<NotificationsResponse> getAllNotifications(
      {required BuildContext context,
      required Map<String, dynamic> queryparams}) async {
    try {
      final response = await get(
        APIS.getAllNotifications,
        params: queryparams,
        requiresToken: true,
      );

      final notificationsResponse =
          NotificationsResponse.fromJson(response.data);

      return notificationsResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? S.current.somethingWentWrong;
      Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Update profile Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<CommonMessageResponse> clearCallLogs(List<String> callIdList) async {
    try {
      final response = await delete(
        APIS.clearCallLogs,
        data: {
          if (callIdList.isNotEmpty) "callIds": callIdList,
        },
        requiresToken: true,
      );

      CommonMessageResponse clearCallRes =
          CommonMessageResponse.fromJson(response.data);
      return clearCallRes; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      // Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<SetNicknameResponse> nickNameSet(
      {required String contactUserId, required String nickName}) async {
    try {
      final response = await put(
        APIS.setNickname,
        {"contactUserId": contactUserId, "nickName": nickName},
        requiresToken: true,
      );

      SetNicknameResponse setNicknameResponse =
          SetNicknameResponse.fromJson(response.data);
      return setNicknameResponse; // Return the parsed response
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      // Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<ToggleNickNameResponse> toggleNickName(
      {required String contactUserId, required bool isActiveNickname}) async {
    try {
      final response = await put(
        APIS.toggleNickname,
        {"contactUserId": contactUserId, "isActiveNickname": isActiveNickname},
        requiresToken: true,
      );

      ToggleNickNameResponse toggleNickNameResponse =
          ToggleNickNameResponse.fromJson(response.data);
      return toggleNickNameResponse; // Return the parsed response
    } on DioException catch (e) {
      print("Error Message >> ${e}");
      String errorMessage =
          e.response?.data?['message']['message'] ?? 'Something went wrong';
      // Utils.showSnackBar(context, errorMessage);
      AppLogger.logs('Error: toggleNickName $errorMessage');
      throw Exception(errorMessage);
    }
  }
}
