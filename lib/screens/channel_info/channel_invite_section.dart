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

class ChannelInviteSection extends StatefulWidget {
  const ChannelInviteSection({
    super.key,
    required this.groupId,
    required this.inviteLink,
    required this.groupName,
    required this.privateGroup,
    required this.isAdmin,
  });

  final String groupId;
  final String? inviteLink;
  final String? groupName;
  final bool privateGroup;
  final bool isAdmin;

  @override
  State<ChannelInviteSection> createState() => _ChannelInviteSectionState();
}

class _ChannelInviteSectionState extends State<ChannelInviteSection> {
  final TextEditingController _customLinkController = TextEditingController();
  String? _customLinkStatus;
  bool _customLinkValid = false;
  bool _customLinkChecking = false;
  Timer? _linkCheckDebounce;

  @override
  void dispose() {
    _linkCheckDebounce?.cancel();
    _customLinkController.dispose();
    super.dispose();
  }

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
      final available = await groupCubit.repository
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
    final newLink = 'messenger212://join/$chatId/$customName';
    groupCubit.repository
        .updateGroup(
      context,
      groupId: chatId,
      inputData: {"inviteLink": newLink, "chatType": "channel"},
      files: null,
    )
        .then((_) {
      if (!mounted) return;
      groupCubit.getGroupInfobyId(context, chatId);
      Utils.showSnackBar(context, 'Share link updated.');
    });
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
                      child: SizedBox(
                        height: 46.h,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.white.withValues(alpha: 0.14),
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                          ),
                          child: Text('Cancel',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.medium(fontSize: 15.sp)),
                        ),
                      ),
                    ),
                    12.s,
                    Expanded(
                      child: SizedBox(
                        height: 46.h,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            groupCubit.revokeGroupInviteLink(
                                context, widget.groupId);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF930C17),
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.r),
                              side: const BorderSide(color: Color(0xFFDF3340)),
                            ),
                          ),
                          child: Text('Revoke',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.medium(fontSize: 15.sp)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if ((widget.inviteLink ?? '').isEmpty) {
      return const SizedBox();
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.dialogBg,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.darkInputFill),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invite Link', style: AppTextStyles.medium(fontSize: 16.sp)),
            12.s,
            Text(
              widget.privateGroup
                  ? 'People can only join this channel using an invite link.'
                  : 'This channel is public, so anyone with this link can view and join it.',
              style: AppTextStyles.regular(
                fontSize: 13.sp,
                color: AppColors.white.withValues(alpha: 0.65),
              ),
            ),
            12.s,
            Text(
              widget.privateGroup
                  ? 'Your unique invite link is below, and you can revoke it at any time.'
                  : 'Customise your share link or use the one generated below.',
              style: AppTextStyles.regular(
                fontSize: 13.sp,
                color: AppColors.white.withValues(alpha: 0.65),
              ),
            ),
            12.s,
            ...[
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
                            color: AppColors.white.withValues(alpha: 0.4))),
                    Expanded(
                      child: TextField(
                        controller: _customLinkController,
                        readOnly: !widget.isAdmin,
                        onChanged:
                            widget.isAdmin ? _validateCustomLink : null,
                        style: AppTextStyles.regular(fontSize: 14.sp),
                        decoration: InputDecoration(
                          hintText: 'custom-name',
                          hintStyle: AppTextStyles.regular(
                              fontSize: 14.sp,
                              color: AppColors.white.withValues(alpha: 0.3)),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 10.h),
                        ),
                      ),
                    ),
                    if (widget.isAdmin) ...[
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
                          onPressed: () =>
                              _saveCustomLink(context, widget.groupId),
                          icon: Icon(Icons.check_circle,
                              color: Colors.green, size: 22.sp),
                        ),
                      IconButton(
                        onPressed: () => _showRevokeDialog(context),
                        icon: Icon(Icons.more_vert,
                            color: AppColors.white, size: 20.sp),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.isAdmin && _customLinkStatus != null) ...[
                8.s,
                Text(
                  _customLinkStatus!,
                  style: AppTextStyles.regular(
                    fontSize: 13.sp,
                    color: _customLinkValid ? Colors.green : Colors.orange,
                  ),
                ),
              ],
              if (widget.isAdmin) ...[
                8.s,
                Text(
                  'Use a-z, 0-9 and underscores. Minimum 20 characters.',
                  style: AppTextStyles.regular(
                    fontSize: 13.sp,
                    color: AppColors.white.withValues(alpha: 0.5),
                  ),
                ),
                12.s,
              ],
            ],
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46.h,
                    child: ElevatedButton(
                      onPressed: () => Utils.copyToClipboard(
                          context, widget.inviteLink ?? ''),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white.withValues(alpha: 0.12),
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                      ),
                      child: Text('Copy',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.medium(fontSize: 15.sp)),
                    ),
                  ),
                ),
                8.s,
                Expanded(
                  child: SizedBox(
                    height: 46.h,
                    child: ElevatedButton(
                      onPressed: () => Share.share(
                        'Join "${widget.groupName ?? "channel"}" on 212 Messenger:\n${widget.inviteLink ?? ''}',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                      ),
                      child: Text('Share',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.medium(fontSize: 15.sp)),
                    ),
                  ),
                ),
                8.s,
                Expanded(
                  child: SizedBox(
                    height: 46.h,
                    child: ElevatedButton(
                      onPressed: () =>
                          showChannelQrDialog(context, widget.inviteLink ?? ''),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF930C17),
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                          side: const BorderSide(color: Color(0xFFDF3340)),
                        ),
                      ),
                      child: Text('QR Code',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.medium(fontSize: 15.sp)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showChannelQrDialog(BuildContext context, String link) {
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
              Text('Invite QR Code', style: AppTextStyles.medium(fontSize: 18.sp)),
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
