import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/conversation_tile/conversation_tile_actions.dart';

class ConversationTileRow extends StatelessWidget {
  const ConversationTileRow({
    super.key,
    required this.conversationId,
    required this.isArchive,
    required this.userId,
    required this.avatar,
    required this.title,
    required this.subtitle,
    required this.unreadCount,
    required this.lastMessageTimestamp,
    required this.showTrailingSpacer,
    required this.onTap,
    required this.onLongPress,
  });

  final String conversationId;
  final bool isArchive;
  final String userId;
  final Widget avatar;
  final String title;
  final String subtitle;
  final int unreadCount;
  final DateTime? lastMessageTimestamp;

  /// Preserves the existing minor layout quirk where the 1:1 tile has an
  /// extra spacer before the trailing column and the group tile doesn't.
  final bool showTrailingSpacer;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(conversationId),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: null,
        children: [
          buildDeleteChatAction(context, chatId: conversationId),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          buildArchiveChatAction(
            context,
            isArchive: isArchive,
            userId: userId,
            chatId: conversationId,
          ),
        ],
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPress: onLongPress,
        onTap: onTap,
        child: Row(
          children: [
            avatar,
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: AppTextStyles.medium(fontSize: 16.sp),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.regular(fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            if (showTrailingSpacer) 4.w.s,
            _UnreadBadgeAndTimestamp(
              unreadCount: unreadCount,
              timestamp: lastMessageTimestamp,
            ),
          ],
        ),
      ),
    );
  }
}

class _UnreadBadgeAndTimestamp extends StatelessWidget {
  const _UnreadBadgeAndTimestamp({
    required this.unreadCount,
    required this.timestamp,
  });

  final int unreadCount;
  final DateTime? timestamp;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        unreadCount == 0
            ? SizedBox(
                height: 22.w,
                width: 22.w,
              )
            : Container(
                height: 22.w,
                width: 22.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor,
                ),
                alignment: Alignment.center,
                child: Text(
                  "$unreadCount",
                  style:
                      AppTextStyles.medium(fontSize: 12.sp, color: AppColors.white),
                ),
              ),
        SizedBox(height: 10.h),
        if (timestamp != null)
          Row(
            children: [
              Text(
                timestamp!.formatMessageTimestamp(),
                style: AppTextStyles.regular(
                  fontSize: 12.sp,
                  color: AppColors.white.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
