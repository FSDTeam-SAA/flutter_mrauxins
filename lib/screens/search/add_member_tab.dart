import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/colors.dart';
import '../../utils/text_style.dart';

enum AddPeopleTab { contacts, recentChats }

class AddMemberTabSwitcher extends StatelessWidget {
  final AddPeopleTab selectedTab;
  final ValueChanged<AddPeopleTab> onTabChanged;

  const AddMemberTabSwitcher({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        height: 40.h,
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppColors.darkInputFill.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            _TabButton(
              label: 'Contacts',
              isSelected: selectedTab == AddPeopleTab.contacts,
              onTap: () => onTabChanged(AddPeopleTab.contacts),
            ),
            _TabButton(
              label: 'Recent Chats',
              isSelected: selectedTab == AddPeopleTab.recentChats,
              onTap: () => onTabChanged(AddPeopleTab.recentChats),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF68283B) : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
            border: isSelected
                ? Border.all(
                    color: const Color(0xFFC13C61).withValues(alpha: 0.8),
                  )
                : null,
          ),
          child: Text(
            label,
            style: AppTextStyles.regular(
              fontSize: 13.sp,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
