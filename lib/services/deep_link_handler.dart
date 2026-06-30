import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/main.dart';
import 'package:two_one_two_messenger/screens/group_info.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

class DeepLinkHandler {
  static final DeepLinkHandler _instance = DeepLinkHandler._internal();
  factory DeepLinkHandler() => _instance;
  DeepLinkHandler._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  void initialize() {
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleLink(uri);
    });

    _sub = _appLinks.uriLinkStream.listen((uri) {
      _handleLink(uri);
    });
  }

  void dispose() {
    _sub?.cancel();
  }

  Future<void> _handleLink(Uri uri) async {
    if (uri.scheme != 'messenger212') return;

    if (uri.host == 'join' && uri.pathSegments.length >= 2) {
      final chatId = uri.pathSegments[0];
      final inviteLink = uri.toString();
      await _joinGroup(chatId, inviteLink);
    }
  }

  Future<void> _joinGroup(String chatId, String inviteLink) async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    try {
      Utils.showLoader();
      final response = await homeCubit.apiClient.joinGroupByInvite(
        chatId: chatId,
        inviteLink: inviteLink,
      );
      Utils.hideLoader();

      if (response.status == Utils.APISUCCESS) {
        final user = await homeCubit.dbHelper.getLoginData();
        if (user == null) return;
        Utils.showSnackBar(
            navigatorKey.currentContext!, response.message ?? "Joined!");
        NavigationService().navigateTo(GroupInfoScreen(
          currentUser: user,
          groupId: chatId,
        ));
      } else {
        Utils.showSnackBar(
            navigatorKey.currentContext!, response.message ?? "Failed to join");
      }
    } catch (e) {
      Utils.hideLoader();
      if (navigatorKey.currentContext != null) {
        Utils.showSnackBar(navigatorKey.currentContext!, e.toString());
      }
    }
  }
}
