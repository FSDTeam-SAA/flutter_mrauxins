import 'dart:io';

import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';

/// Screenshot / screen-recording protection, backed by the screen_protector
/// plugin. Toggled per-chat: ChatScreen enables it while a group/channel with
/// "Restrict Content Sharing" on is open, and disables it on leave.
///
/// Android: FLAG_SECURE — the OS refuses the capture outright.
/// iOS: secure-UITextField layer trick — the capture succeeds but app content
/// renders black (iOS offers no way to block the capture itself), plus a
/// black cover over the App Switcher snapshot.
class ScreenProtectionService {
  ScreenProtectionService._();
  static final instance = ScreenProtectionService._();

  Future<void> enable() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      await ScreenProtector.preventScreenshotOn();
      await ScreenProtector.protectDataLeakageWithColor(Colors.black);
    } catch (_) {
      // Never let protection setup crash the app.
    }
  }

  Future<void> disable() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      await ScreenProtector.preventScreenshotOff();
      await ScreenProtector.protectDataLeakageWithColorOff();
    } catch (_) {
      // Ignore — worst case protection stays on.
    }
  }
}
