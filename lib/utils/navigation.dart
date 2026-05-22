// ignore_for_file: use_build_context_synchronously
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:two_one_two_messenger/main.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

import '../screens/chat_screen.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();

  factory NavigationService() {
    return _instance;
  }

  NavigationService._internal();
  bool _isNavigating = false;
  Completer<void>? _navigationCompleter;
  // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  bool _isNavigatingToChat = false;
  String? _currentNavigatingChatId;

  Future<T?> navigateToChat<T>(Widget to,
      {int durationInMS = 250, String? chatId}) async {
    // Special handling for chat screen navigation
    if (to is ChatScreen && chatId != null) {
      if (_isNavigatingToChat) {
        return null; // Block duplicate navigation to same chat
      }

      _isNavigatingToChat = true;
      _currentNavigatingChatId = chatId;
    }

    try {
      await Utils.hideKeyboard();
      final result = await Navigator.push<T>(
        navigatorKey.currentState!.context,
        PageTransition(
          child: to,
          type: PageTransitionType.fade,
          duration: Duration(milliseconds: durationInMS),
          reverseDuration: Duration(milliseconds: durationInMS),
        ),
      );
      return result;
    } finally {
      if (to is ChatScreen) {
        _isNavigatingToChat = false;
        _currentNavigatingChatId = null;
      }
    }
  }

  Future<T?> navigateTo<T>(Widget to, {int durationInMS = 250}) async {
    await Utils.hideKeyboard();
    return await Navigator.push<T>(
        navigatorKey.currentState!.context,
        PageTransition(
            child: to,
            type: PageTransitionType.fade,
            duration: Duration(milliseconds: durationInMS),
            reverseDuration: Duration(milliseconds: durationInMS)));
  }

  Future<T?> replaceWith<T>(Widget to, {int durationInMS = 250}) async {
    await Utils.hideKeyboard();
    return await Navigator.pushReplacement<T, T>(
        navigatorKey.currentState!.context,
        PageTransition(
            child: to,
            type: PageTransitionType.fade,
            duration: Duration(milliseconds: durationInMS),
            reverseDuration: Duration(milliseconds: durationInMS)));
  }

  Future<void> clearAndNavigateTo(Widget to, {int durationInMS = 250}) async {
    await Utils.hideKeyboard();
    await Navigator.pushAndRemoveUntil(
        navigatorKey.currentState!.context,
        PageTransition(
            child: to,
            type: PageTransitionType.fade,
            duration: Duration(milliseconds: durationInMS),
            reverseDuration: Duration(milliseconds: durationInMS)),
        (route) => false);
  }

  Future<void> popUntil() async {
    await Utils.hideKeyboard();
    Navigator.popUntil(navigatorKey.currentState!.context, (route) {
      print("routes = ${route.isFirst}");
      return route.isFirst;
    });
  }

  Future<void> goBack() async {
    await Utils.hideKeyboard();
    Navigator.pop(navigatorKey.currentState!.context);
  }

  Future<void> goBackReturn([result]) async {
    await Utils.hideKeyboard();
    Navigator.pop(navigatorKey.currentState!.context, result);
  }

  Future<void> goBackTo(int count) async {
    for (int i = 0; i < count; i++) {
      goBack();
    }
  }


  
}
