import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:two_one_two_messenger/extension/bloc.dart';
import 'package:two_one_two_messenger/extension/sizebox.dart';
import 'package:two_one_two_messenger/utils/colors.dart';
import 'package:two_one_two_messenger/utils/text_style.dart';
import 'package:two_one_two_messenger/utils/utils.dart';
import 'package:two_one_two_messenger/widgets/buttons.dart';

import 'group_accordion_header.dart';

class GroupInviteSection extends StatefulWidget {
  const GroupInviteSection({
    super.key,
    required this.groupId,
    required this.inviteLink,
    required this.groupName,
    required this.privateGroup,
    required this.expanded,
    required this.onToggleExpanded,
  });

  final String groupId;
  final String? inviteLink;
  final String? groupName;
  final bool privateGroup;
  final bool expanded;
  final VoidCallback onToggleExpanded;

  @override
  State<GroupInviteSection> createState() => _GroupInviteSectionState();
}

class _GroupInviteSectionState extends State<GroupInviteSection> {
  final TextEditingController _customLinkController = TextEditingController();
  String? _customLinkStatus;
  bool _customLinkValid = false;
  bool _customLinkChecking = false;
  Timer? _linkCheckDebounce;
  bool _customLinkInitialized = false;

  @override
  void dispose() {
    _linkCheckDebounce?.cancel();
    _customLinkController.dispose();
    super.dispose();
  }

  // Generates a readable unique default: cleaned group name + enough chatId chars
  // to ensure the total is ≥ 20 characters.
  String _generateDefaultLinkName(String groupName, String chatId) {
    final cleaned = groupName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final namePart = cleaned.isEmpty ? 'group' : cleaned;
    final id = chatId.toLowerCase().replaceAll(RegExp(r'[^a-f0-9]'), '');
    final neededSuffix = (20 - namePart.length - 1).clamp(8, id.length);
    final suffix = id.substring(id.length - neededSuffix);
    return '${namePart}_$suffix';
  }

  // Returns true if the segment looks like a system-generated MongoDB ObjectId
  // (24 lowercase hex chars with no underscores).
  bool _isSystemId(String segment) =>
      RegExp(r'^[0-9a-f]{24}$').hasMatch(segment);

  void _validateCustomLink(String value) {
    _linkCheckDebounce?.cancel();
    final cleaned = value.trim().toLowerCase();
    if (cleaned.isEmpty) {
      setState(() {
        _customLinkStatus = null;
        _customLinkValid = false;
        _customLinkChecking = false;
      });
      return;
    }
    if (!RegExp(r'^[a-z0-9_]{20,}$').hasMatch(cleaned)) {
      setState(() {
        _customLinkValid = false;
        _customLinkStatus = null;
        _customLinkChecking = false;
      });
      return;
    }
    // Regex passes — debounce the backend availability check
    setState(() {
      _customLinkChecking = true;
      _customLinkValid = false;
      _customLinkStatus = null;
    });
    _linkCheckDebounce = Timer(const Duration(milliseconds: 500), () async {
      final available = await homeCubit.apiClient
          .checkGroupInviteName(cleaned, widget.groupId);
      if (!mounted) return;
      setState(() {
        _customLinkChecking = false;
        _customLinkValid = available;
        _customLinkStatus =
            available ? '$cleaned is available.' : '$cleaned is already taken.';
      });
    });
  }

  void _saveCustomLink(BuildContext context, String chatId) {
    if (!_customLinkValid) return;
    final customName = _customLinkController.text.trim().toLowerCase();
    // Store as a proper deep link so the existing join handler can parse chatId + customName
    final newLink = 'messenger212://join/$chatId/$customName';
    homeCubit.apiClient.updateGroup(
      context,
      groupId: chatId,
      inputData: {"inviteLink": newLink, "chatType": "group"},
      files: null,
    ).then((_) {
      if (!mounted) return;
      homeCubit.getGroupInfobyId(context, chatId);
      Utils.showSnackBar(context, 'Share link updated.');
    });
  }

  @override
  Widget build(BuildContext context) {
    final link = widget.inviteLink ?? '';
    if (link.isEmpty) {
      return const SizedBox.shrink();
    }
    final isPrivate = widget.privateGroup;

    // Pre-populate the custom link field once the group data loads
    if (!_customLinkInitialized) {
      final lastSegment = link.isNotEmpty ? link.split('/').last : '';
      // Use the existing custom name if it was user-set; otherwise generate a
      // readable default from the group name + chatId suffix.
      final defaultName = (lastSegment.isNotEmpty && !_isSystemId(lastSegment))
          ? lastSegment
          : _generateDefaultLinkName(widget.groupName ?? '', widget.groupId);
      _customLinkController.text = defaultName;
      _customLinkInitialized = true;
      // Kick off the availability check for the pre-populated value
      Future.microtask(() => _validateCustomLink(defaultName));
    }

    return Column(
      children: [
        GroupAccordionHeader(
          title: 'Invite Link',
          isExpanded: widget.expanded,
          onTap: widget.onToggleExpanded,
        ),
        if (widget.expanded)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w).copyWith(top: 10.h),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFF2B1F25),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Invite Link',
                      style: AppTextStyles.medium(fontSize: 17.sp)),
                  22.s,
                  Text(
                    isPrivate
                        ? 'This group is set to private, so people can only join using an invite link.'
                        : 'This group is public and has no custom privacy settings, so anyone can view and join it.',
                    style: AppTextStyles.regular(
                      fontSize: 14.sp,
                      color: AppColors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  16.s,
                  Text(
                    isPrivate
                        ? 'Your unique invite link is below, and you can revoke it or create a new one at any time.'
                        : 'Create a share link to give people quick access.',
                    style: AppTextStyles.regular(
                      fontSize: 14.sp,
                      color: AppColors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  14.s,
                  Container(
                    height: 45.h,
                    padding: EdgeInsets.only(left: 14.w),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text('the212.me/',
                            style: AppTextStyles.regular(
                                fontSize: 13.sp,
                                color:
                                    AppColors.white.withValues(alpha: 0.4))),
                        Expanded(
                          child: TextField(
                            controller: _customLinkController,
                            onChanged: _validateCustomLink,
                            style: AppTextStyles.regular(fontSize: 14.sp),
                            decoration: InputDecoration(
                              hintText: 'your-link-name',
                              hintStyle: AppTextStyles.regular(
                                  fontSize: 14.sp,
                                  color: AppColors.white
                                      .withValues(alpha: 0.3)),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 10.h),
                            ),
                          ),
                        ),
                        if (_customLinkChecking)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: SizedBox(
                              width: 16.w,
                              height: 16.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: AppColors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          )
                        else if (_customLinkValid)
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(minWidth: 32.w),
                            onPressed: () =>
                                _saveCustomLink(context, widget.groupId),
                            icon: Icon(Icons.check_circle,
                                color: Colors.green, size: 20.sp),
                          ),
                        IconButton(
                          onPressed: () => _showRevokeDialog(context),
                          icon: Icon(Icons.more_vert,
                              color: AppColors.white, size: 20.sp),
                        ),
                      ],
                    ),
                  ),
                  8.s,
                  if (_customLinkStatus != null) ...[
                    Text(
                      _customLinkStatus!,
                      style: AppTextStyles.regular(
                        fontSize: 13.sp,
                        color:
                            _customLinkValid ? Colors.green : Colors.orange,
                      ),
                    ),
                    6.s,
                  ],
                  Text(
                    'You can use a-z, 0-9 and underscores.',
                    style: AppTextStyles.regular(
                      fontSize: 13.sp,
                      color: AppColors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  4.s,
                  Text(
                    'Minimum length is 20 Characters.',
                    style: AppTextStyles.regular(
                      fontSize: 13.sp,
                      color: AppColors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  14.s,
                  22.s,
                  Row(
                    children: [
                      Expanded(
                        child: _inviteActionButton(
                          text: 'Copy',
                          color: AppColors.white.withValues(alpha: 0.12),
                          onPressed: () =>
                              Utils.copyToClipboard(context, link),
                        ),
                      ),
                      8.s,
                      Expanded(
                        child: _inviteActionButton(
                          text: 'Share',
                          color: AppColors.primaryColor,
                          onPressed: () => Share.share(
                            'Join "${widget.groupName ?? "group"}" on 212 Messenger:\n$link',
                          ),
                        ),
                      ),
                      8.s,
                      Expanded(
                        child: _inviteActionButton(
                          text: 'QR Code',
                          color: const Color(0xFF930C17),
                          borderColor: const Color(0xFFDF3340),
                          onPressed: () => _showQrDialog(context, link),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        20.s,
      ],
    );
  }

  Widget _inviteActionButton({
    required String text,
    required Color color,
    Color? borderColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 46.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
            side: BorderSide(color: borderColor ?? Colors.transparent),
          ),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.medium(fontSize: 15.sp),
        ),
      ),
    );
  }

  void _showQrDialog(BuildContext context, String link) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.dialogBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Invite QR Code',
                    style: AppTextStyles.medium(fontSize: 18.sp)),
                16.s,
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: QrImageView(
                    data: link,
                    version: QrVersions.auto,
                    size: 220.w,
                  ),
                ),
                18.s,
                CustomButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Close',
                    style: AppTextStyles.medium(color: AppColors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRevokeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF1E1D22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
            side: BorderSide(
              color: const Color(0xFF8E1322).withValues(alpha: 0.8),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: AppColors.white,
                    size: 22.sp,
                  ),
                ),
                18.s,
                Text('Revoke Link', style: AppTextStyles.medium(fontSize: 20.sp)),
                14.s,
                Text(
                  'Are you sure you want to revoke this link? Once revoked, it can no longer be used to join.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.regular(
                    fontSize: 15.sp,
                    color: AppColors.white.withValues(alpha: 0.72),
                  ),
                ),
                22.s,
                Row(
                  children: [
                    Expanded(
                      child: _inviteActionButton(
                        text: 'Cancel',
                        color: AppColors.white.withValues(alpha: 0.14),
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ),
                    12.s,
                    Expanded(
                      child: _inviteActionButton(
                        text: 'Revoke',
                        color: const Color(0xFF930C17),
                        borderColor: const Color(0xFFDF3340),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          homeCubit.revokeGroupInviteLink(
                              context, widget.groupId);
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
