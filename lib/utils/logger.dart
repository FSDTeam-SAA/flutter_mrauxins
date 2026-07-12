
import 'package:flutter/foundation.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

class AppLogger {
  static void logs(String message, {isLog = false}) {
    final time = DateTime.now().toIso8601String();

    if (isLog) {
      showMessage("212 Messenger: [$time] - $message");
    } else {
      debugPrint("212 Messenger: [$time] - $message");
    }
  }
}
