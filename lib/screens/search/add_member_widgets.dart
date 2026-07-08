import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_one_two_messenger/models/conversation_model.dart';
import 'package:two_one_two_messenger/models/all_user.dart';
import 'package:two_one_two_messenger/extension/date_format.dart';

import '../../extension/sizebox.dart';
import '../../utils/colors.dart';
import '../../utils/text_style.dart';
import '../../widgets/avatar_widgets.dart';
import '../../generated/l10n.dart';

class AddMemberTopActionRow extends StatelessWidget {
  final int selectedCount;
  final int memberLimit;
  final VoidCallback onClose;
  final VoidCallback onSubmit;

  const AddMemberTopActionRow({
    super.key,
    required this.selectedCount,
    required this.memberLimit,
    required this.onClose,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          _circleIconButton(
            icon: Icons.close,
            onTap: onClose,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Add people',
                  style: AppTextStyles.medium(fontSize: 15.sp),
                ),
                2.s,
                Text(
                  '$selectedCount/$memberLimit',
                  style: AppTextStyles.regular(
                    fontSize: 11.sp,
                    color: AppColors.white.withValues(alpha: 0.58),
                  ),
                ),
              ],
            ),
          ),
          _circleIconButton(
            icon: Icons.chevron_right,
            onTap: onSubmit,
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 34.w,
        height: 34.w,
        decoration: BoxDecoration(
          color: AppColors.darkInputFill.withValues(alpha: 0.65),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white.withValues(alpha: 0.24)),
        ),
        child: Icon(icon, color: AppColors.white, size: 22.sp),
      ),
    );
  }
}

class AddMemberSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;
  final VoidCallback onClear;

  const AddMemberSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.hintText,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
      child: SizedBox(
        height: 42.h,
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: AppTextStyles.regular(fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.regular(
              fontSize: 14.sp,
              color: AppColors.white.withValues(alpha: 0.45),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.white,
              size: 20.sp,
            ),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      controller.clear();
                      onClear();
                    },
                    icon: Icon(Icons.close,
                        color: AppColors.white.withValues(alpha: 0.65),
                        size: 18.sp),
                  ),
            filled: true,
            fillColor: const Color(0xFF2B1F25),
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: BorderSide(
                color: const Color(0xFF86334D).withValues(alpha: 0.45),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: BorderSide(
                color: const Color(0xFF86334D).withValues(alpha: 0.45),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: BorderSide(
                color: const Color(0xFFB94768).withValues(alpha: 0.75),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SelectedPeopleStrip extends StatelessWidget {
  final List<Participant> selected;
  final Function(String) onRemove;

  const SelectedPeopleStrip({
    super.key,
    required this.selected,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.dialogBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF86334D).withValues(alpha: 0.45),
        ),
      ),
      height: 90.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: selected.length,
        separatorBuilder: (_, __) => 10.s,
        itemBuilder: (context, index) {
          final person = selected[index];
          final name = person.name ?? person.userName ?? '';

          return SizedBox(
            width: 58.w,
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AvatarWidgets(
                      userPic: person.profilePicture ?? '',
                      height: 42,
                      width: 42,
                    ),
                    Positioned(
                      right: -4.w,
                      top: -4.h,
                      child: GestureDetector(
                        onTap: () => onRemove(person.id ?? ''),
                        child: Container(
                          width: 17.w,
                          height: 17.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFA51B2A),
                          ),
                          child: Icon(Icons.close,
                              size: 12.sp, color: AppColors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                6.s,
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.regular(fontSize: 11.sp),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class AddMemberContactTile extends StatelessWidget {
  final UserData user;
  final bool isSelected;
  final VoidCallback onTap;

  const AddMemberContactTile({
    super.key,
    required this.user,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = _displayName(user);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
        child: Row(
          children: [
            AvatarWidgets(
              userPic: user.profilePicture ?? "",
              height: 42,
              width: 42,
            ),
            12.s,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.medium(fontSize: 14.sp),
                  ),
                  if (user.lastSeen != null) ...[
                    5.s,
                    Text(
                      "${S.of(context).sLastSeen} ${_lastSeenLabel(user.lastSeen)}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.regular(
                        fontSize: 11.sp,
                        color: AppColors.white.withValues(alpha: 0.48),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SelectionCircle(isSelected: isSelected),
          ],
        ),
      ),
    );
  }

  String _displayName(UserData user) {
    if (user.isActiveNickname ?? false) {
      return user.nickName ?? user.name ?? user.userName ?? '';
    }
    return user.name ?? user.userName ?? '';
  }

  String _lastSeenLabel(String? value) {
    if (value == null || value.isEmpty) return '';
    final parsed = DateTime.tryParse(value);
    return parsed == null
        ? value
        : parsed.toLocal().formattedDateWithDayMonthAtTime;
  }
}

class SelectionCircle extends StatelessWidget {
  final bool isSelected;

  const SelectionCircle({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 21.w,
      height: 21.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? const Color(0xFF8E1830) : Colors.transparent,
        border: Border.all(
          color: isSelected
              ? AppColors.white.withValues(alpha: 0.45)
              : AppColors.primaryColor,
        ),
      ),
      child: isSelected
          ? Icon(Icons.check, size: 14.sp, color: AppColors.white)
          : null,
    );
  }
}
