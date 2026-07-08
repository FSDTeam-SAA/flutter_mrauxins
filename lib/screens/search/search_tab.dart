import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/colors.dart';
import '../../utils/text_style.dart';

enum SearchTab { database, contacts }

class SearchTabSwitcher extends StatelessWidget {
  final SearchTab selectedTab;
  final ValueChanged<SearchTab> onTabChanged;

  const SearchTabSwitcher({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42.h,
      decoration: BoxDecoration(
        color: AppColors.dialogBg,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: const Color(0xFF86334D).withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Database',
            isSelected: selectedTab == SearchTab.database,
            onTap: () => onTabChanged(SearchTab.database),
          ),
          _TabButton(
            label: 'Contacts',
            isSelected: selectedTab == SearchTab.contacts,
            onTap: () => onTabChanged(SearchTab.contacts),
          ),
        ],
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
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF86334D) : Colors.transparent,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Text(
            label,
            style: AppTextStyles.medium(
              fontSize: 14.sp,
              color: isSelected
                  ? AppColors.white
                  : AppColors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
