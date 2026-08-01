import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:two_one_two_messenger/database/local_db.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/main.dart';
import 'package:two_one_two_messenger/screens/channel_info.dart';
import 'package:two_one_two_messenger/screens/group_info.dart';
import 'package:two_one_two_messenger/screens/login_screen.dart';
import 'package:two_one_two_messenger/utils/constants.dart';
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
    final chatId = _extractJoinChatId(uri);
    if (chatId == null) return;

    final inviteLink = uri.toString();

    if (AppPreference.getCurrentUserId().isEmpty) {
      // Not logged in — stash the invite and resume it after login
      // instead of letting the join call fail with an auth error.
      await AppPreference.setString(
          LocalDbConstants.pendingInviteChatId, chatId);
      await AppPreference.setString(
          LocalDbConstants.pendingInviteLink, inviteLink);

      final context = navigatorKey.currentContext;
      if (context != null) {
        Utils.showSnackBar(context, "Please log in to join this group.");
        NavigationService().navigateTo(LoginScreen());
      }
      return;
    }

    await _joinGroup(chatId, inviteLink);
  }

  /// Recognizes both the legacy custom-scheme invite link
  /// (`messenger212://join/<chatId>/<name>`, where Dart's Uri parses "join"
  /// as the host) and the HTTPS App Links/Universal Links form
  /// (`https://<inviteLinkDomain>/join/<chatId>/<name>`, where "join" is the
  /// first path segment). Returns the chatId if the URI matches either
  /// shape, or null otherwise.
  String? _extractJoinChatId(Uri uri) {
    if (uri.scheme == 'messenger212') {
      if (uri.host == 'join' && uri.pathSegments.length >= 2) {
        return uri.pathSegments[0];
      }
      return null;
    }

    if (uri.scheme == 'https' && uri.host == AppConstants.inviteLinkDomain) {
      if (uri.pathSegments.length >= 3 && uri.pathSegments[0] == 'join') {
        return uri.pathSegments[1];
      }
      return null;
    }

    return null;
  }

  /// Call after the user lands on the home screen (fresh launch or right
  /// after completing login) to resume a join that was deferred because
  /// the user wasn't authenticated when they tapped the invite link.
  Future<void> resumePendingJoinIfAny() async {
    if (AppPreference.getCurrentUserId().isEmpty) return;

    final chatId = AppPreference.getString(LocalDbConstants.pendingInviteChatId);
    final inviteLink = AppPreference.getString(LocalDbConstants.pendingInviteLink);
    if (chatId.isEmpty || inviteLink.isEmpty) return;

    await AppPreference.setString(LocalDbConstants.pendingInviteChatId, "");
    await AppPreference.setString(LocalDbConstants.pendingInviteLink, "");

    await _joinGroup(chatId, inviteLink);
  }

  Future<void> _joinGroup(String chatId, String inviteLink) async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    try {
      Utils.showLoader();
      final response = await groupCubit.repository.joinGroupByInvite(
        chatId: chatId,
        inviteLink: inviteLink,
      );
      Utils.hideLoader();

      if (response.status == Utils.APISUCCESS) {
        final user = await homeCubit.dbHelper.getLoginData();
        if (user == null) return;
        if (navigatorKey.currentContext == null) return;
        Utils.showSnackBar(
            navigatorKey.currentContext!, response.message ?? "Joined!");

        // The join response itself doesn't say whether chatId is a group or
        // a channel, so fetch the freshly-joined chat's info and branch on
        // its chatType. Older/unpatched backend responses may not send
        // chatType yet — default to GroupInfoScreen in that case, same as
        // this always did before the field existed.
        final groupInfo = await groupCubit.repository.getGroupInfobyId(
          context: navigatorKey.currentContext!,
          groupId: chatId,
        );
        if (navigatorKey.currentContext == null) return;
        if (groupInfo.groupData?.chatType == 'channel') {
          NavigationService().navigateTo(ChannelInfoScreen(
            currentUser: user,
            groupId: chatId,
          ));
        } else {
          NavigationService().navigateTo(GroupInfoScreen(
            currentUser: user,
            groupId: chatId,
          ));
        }
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
