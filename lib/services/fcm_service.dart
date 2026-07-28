import 'package:two_one_two_messenger/utils/utils.dart';

class FCMService {
  Future<String?> getFCMToken() async {
    try {
      // Utils.fetchToken() waits for the APNS token before requesting the
      // FCM token on iOS (required, otherwise getToken() returns null/hangs)
      // and times out instead of hanging indefinitely.
      String? token = await Utils.fetchToken();
      showMessage("FCM Token: $token");
      return token;
    } catch (e) {
      showMessage("Error retrieving FCM token: $e");
      return null;
    }
  }
}
