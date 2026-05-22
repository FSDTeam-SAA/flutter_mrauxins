import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<String?> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      showMessage("FCM Token: $token");
      return token;
    } catch (e) {
      showMessage("Error retrieving FCM token: $e");
      return null;
    }
  }
}
