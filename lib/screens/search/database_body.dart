import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/date_format.dart';
import 'package:two_one_two_messenger/generated/l10n.dart';
import 'package:two_one_two_messenger/models/conversation_model.dart';
import 'package:two_one_two_messenger/screens/channel_info.dart';
import 'package:two_one_two_messenger/screens/chat_screen.dart';
import 'package:two_one_two_messenger/screens/group_info.dart';
import 'package:two_one_two_messenger/utils/navigation.dart';
import 'package:two_one_two_messenger/widgets/avatar_widgets.dart';
import 'package:two_one_two_messenger/widgets/custom_loading_widget.dart';

import '../../extension/sizebox.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../utils/text_style.dart';
import '../../utils/utils.dart';
import 'search_widgets.dart';

class DatabaseBody extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final bool isLoading;
  final String searchQuery;

  const DatabaseBody({
    super.key,
    required this.results,
    required this.isLoading,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && results.isEmpty) {
      return const Center(child: CustomLoadingWidget());
    }
    return GroupedListWithRail<Map<String, dynamic>>(
      items: results,
      nameOf: (item) => (item['name'] ?? '') as String,
      tileBuilder: (item) => _DatabaseResultTile(item: item),
      emptyState: Center(
        child: Text(
          searchQuery.isEmpty
              ? 'Search for public users, groups & channels'
              : S.of(context).noContactsFound,
          style: AppTextStyles.regular(
              fontSize: 14.sp, color: AppColors.white.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}

class _DatabaseResultTile extends StatelessWidget {
  final Map<String, dynamic> item;

  const _DatabaseResultTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final resultType = item['resultType'] ?? 'user';
    final name = item['name'] ?? '';
    final image = item['profilePicture'] ?? item['groupImage'] ?? '';

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _onDatabaseItemTap(context, item),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
        child: Row(
          children: [
            AvatarWidgets(
              userPic: image,
              svgAvatar: resultType == 'channel'
                  ? SvgAssets.megaphone
                  : resultType == 'group'
                      ? SvgAssets.person2
                      : SvgAssets.icPerson,
              height: 42,
              width: 42,
            ),
            12.s,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.medium(fontSize: 15.sp)),
                  4.s,
                  Text(
                    _databaseSubtitle(context, item),
                    style: AppTextStyles.regular(
                        fontSize: 12.sp,
                        color: AppColors.white.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ),
            if (resultType != 'user' && (item['isMember'] ?? false))
              Text('Joined',
                  style:
                      AppTextStyles.regular(fontSize: 12.sp, color: Colors.green)),
          ],
        ),
      ),
    );
  }

  String _databaseSubtitle(BuildContext context, Map<String, dynamic> item) {
    final type = item['resultType'] ?? 'user';
    if (type == 'user') {
      final isOnline = item['isOnline'] ?? false;
      if (isOnline) return S.of(context).online;
      final lastSeen = item['lastSeen'];
      if (lastSeen != null) {
        return "${S.of(context).sLastSeen}${DateTime.parse(lastSeen).toLocal().formattedDateWithDayMonthAtTime}";
      }
      return '';
    }
    final memberCount = item['memberCount'] ?? 0;
    return '${type == 'channel' ? 'Channel' : 'Group'} · $memberCount members';
  }

  Future<void> _onDatabaseItemTap(
      BuildContext context, Map<String, dynamic> item) async {
    final type = item['resultType'] ?? 'user';
    final id = item['_id'] ?? '';
    if (id.isEmpty) return;

    if (type == 'user') {
      final sender = ParticipantDetail(
        id: id,
        name: item['name'],
        userName: item['userName'],
        profilePicture: item['profilePicture'],
        lastSeen: item['lastSeen'],
        isOnline: item['isOnline'],
      );
      await chatCubit.resetChatScreenState();
      NavigationService().replaceWith(ChatScreen(
        chatType: ChatType.one_to_one,
        sender: sender,
        unreadMessageCount: 0,
        userName: item['name'] ?? '',
        userId: id,
        userPic: item['profilePicture'] ?? '',
        chatId: '',
        aesKey: '',
        isSendMessage: true,
        isShowProfileImage: true,
      ));
    } else {
      final user = await homeCubit.dbHelper.getLoginData();
      if (user == null) return;
      if (type == 'channel') {
        NavigationService()
            .navigateTo(ChannelInfoScreen(currentUser: user, groupId: id));
      } else {
        NavigationService()
            .navigateTo(GroupInfoScreen(currentUser: user, groupId: id));
      }
    }
  }
}
