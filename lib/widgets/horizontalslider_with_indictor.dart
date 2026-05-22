import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/colors.dart';

class PageViewWithIndicator extends StatefulWidget {
  final int itemCount; // Total number of pages
  final IndexedWidgetBuilder itemBuilder; // Widget builder for each page
  final double height; // Height of the PageView
  final ValueChanged<int>? onPageChanged; // Callback for page changes
  final Color activeColor;
  final Color inactiveColor;

  const PageViewWithIndicator({
    required this.itemCount,
    required this.itemBuilder,
    this.height = 100, // Default height
    this.onPageChanged,
    this.activeColor =AppColors.primaryColor,
    this.inactiveColor =  AppColors.white,
    super.key,
  });

  @override
  PageViewWithIndicatorState createState() => PageViewWithIndicatorState();
}

class PageViewWithIndicatorState extends State<PageViewWithIndicator> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.itemCount,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              if (widget.onPageChanged != null) {
                widget.onPageChanged!(index);
              }
            },
            itemBuilder: widget.itemBuilder,
          ),
        ),
        SizedBox(height: 8.h),
        CarouselIndicator(
          count:  widget.itemCount,
          index: _currentPage,
          width: 12.w,
          height: 12.w,
          cornerRadius: 12.w / 2,
          activeColor: widget.activeColor,
          color: widget.inactiveColor,
        ),

      ],
    );
  }
}