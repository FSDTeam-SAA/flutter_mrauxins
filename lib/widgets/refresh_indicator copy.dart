import 'package:flutter/material.dart';
import 'package:two_one_two_messenger/utils/colors.dart';

class CustomRefreshIndicator extends StatelessWidget {
  const CustomRefreshIndicator(
      {super.key, required this.onRefresh, required this.child});

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: onRefresh,
        backgroundColor: AppColors.dark,
        child: SizedBox(height: double.infinity, child: child));
  }
}
