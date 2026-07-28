import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../extension/sizebox.dart';
import '../../utils/colors.dart';
import '../../utils/text_style.dart';
import '../../widgets/custom_loading_widget.dart';

/// Groups [items] alphabetically by the first letter of [nameOf].
/// Items starting with non-letter characters are grouped under '#'.
Map<String, List<T>> groupByName<T>(
    List<T> items, String Function(T) nameOf) {
  final sorted = [...items]
    ..sort(
        (a, b) => nameOf(a).toLowerCase().compareTo(nameOf(b).toLowerCase()));
  final grouped = <String, List<T>>{};
  for (final item in sorted) {
    final name = nameOf(item);
    final first = name.isEmpty ? '#' : name[0].toUpperCase();
    final key = RegExp(r'[A-Z]').hasMatch(first) ? first : '#';
    grouped.putIfAbsent(key, () => []).add(item);
  }
  return grouped;
}

/// A scrollable list grouped alphabetically with an A-Z rail for quick
/// navigation. Manages its own scroll controller, section keys, and
/// active-letter tracking internally.
class GroupedListWithRail<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) nameOf;
  final Widget Function(T) tileBuilder;
  final Widget emptyState;
  final ScrollController? scrollController;
  final VoidCallback? onScrollNearEnd;
  final bool isLoadingMore;

  const GroupedListWithRail({
    super.key,
    required this.items,
    required this.nameOf,
    required this.tileBuilder,
    required this.emptyState,
    this.scrollController,
    this.onScrollNearEnd,
    this.isLoadingMore = false,
  });

  @override
  State<GroupedListWithRail<T>> createState() => _GroupedListWithRailState<T>();
}

class _GroupedListWithRailState<T> extends State<GroupedListWithRail<T>> {
  late final ScrollController _scrollController;
  final _railKey = GlobalKey();
  final _sectionKeys = <String, GlobalKey>{};
  String _activeRailLetter = 'A';

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    _updateActiveLetter();
    if (widget.onScrollNearEnd != null) {
      if (_scrollController.hasClients &&
          _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 80.h) {
        widget.onScrollNearEnd!();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _updateActiveLetter() {
    if (_sectionKeys.isEmpty) return;
    String? active;
    for (final entry in _sectionKeys.entries) {
      final ctx = entry.value.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final topY = box.localToGlobal(Offset.zero).dy;
      if (topY <= 260) active = entry.key;
    }
    if (active != null && active != _activeRailLetter) {
      setState(() => _activeRailLetter = active!);
    }
  }

  String? _nearestSection(String letter) {
    if (_sectionKeys.isEmpty) return null;
    if (_sectionKeys.containsKey(letter)) return letter;
    const all = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ#';
    final pos = all.indexOf(letter);
    final sorted = _sectionKeys.keys.toList()..sort();
    String? lastBefore;
    for (final avail in sorted) {
      if (all.indexOf(avail) < pos) {
        lastBefore = avail;
      } else {
        break;
      }
    }
    return lastBefore ?? sorted.first;
  }

  void _scrollToSection(String letter) {
    final target = _nearestSection(letter);
    if (target == null) return;

    final key = _sectionKeys[target];

    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
      return;
    }

    if (!_scrollController.hasClients) return;
    final sorted = _sectionKeys.keys.toList()..sort();
    final rank = sorted.indexOf(target);
    if (rank < 0) return;

    final maxExtent = _scrollController.position.maxScrollExtent;
    final estimated =
        sorted.length <= 1 ? 0.0 : maxExtent * rank / (sorted.length - 1);
    _scrollController.jumpTo(estimated.clamp(0.0, maxExtent));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final k = _sectionKeys[target];
      if (k?.currentContext != null) {
        Scrollable.ensureVisible(k!.currentContext!,
            duration: const Duration(milliseconds: 100));
      }
    });
  }

  void _onRailInteraction(Offset globalPosition) {
    final railBox = _railKey.currentContext?.findRenderObject() as RenderBox?;
    if (railBox == null) return;
    final localY = railBox.globalToLocal(globalPosition).dy;
    final railHeight = railBox.size.height;
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ#';
    final index = (localY / railHeight * letters.length)
        .clamp(0, letters.length - 1)
        .toInt();
    final letter = letters[index];
    if (letter != _activeRailLetter) {
      setState(() => _activeRailLetter = letter);
    }
    _scrollToSection(letter);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return widget.emptyState;

    final grouped = groupByName(widget.items, widget.nameOf);
    final letters = grouped.keys.toList()..sort();

    for (final letter in letters) {
      _sectionKeys.putIfAbsent(letter, () => GlobalKey());
    }

    // Hide the A-Z rail while the keyboard is open. The keyboard shrinks the
    // available height so much that the 27-letter Column overflows, and the
    // user is actively typing anyway so A-Z browsing isn't needed.
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.only(right: keyboardOpen ? 0 : 24.w, bottom: 20.h),
          itemCount: letters.length + (widget.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= letters.length) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: const Center(child: CustomLoadingWidget()),
              );
            }

            final letter = letters[index];
            final sectionItems = grouped[letter]!;
            _sectionKeys.putIfAbsent(letter, () => GlobalKey());

            return Column(
              key: _sectionKeys[letter],
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 6.h, bottom: 8.h),
                  child:
                      Text(letter, style: AppTextStyles.medium(fontSize: 13.sp)),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.dialogBg.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                        color: const Color(0xFF86334D).withValues(alpha: 0.35)),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sectionItems.length,
                    itemBuilder: (context, i) => widget.tileBuilder(sectionItems[i]),
                    separatorBuilder: (_, __) => Padding(
                      padding: EdgeInsets.only(left: 58.w),
                      child: Divider(
                          height: 1, color: AppColors.white.withValues(alpha: 0.06)),
                    ),
                  ),
                ),
                12.s,
              ],
            );
          },
        ),
        if (!keyboardOpen)
          Positioned(
            right: 2.w,
            top: 4.h,
            bottom: 8.h,
            child: _alphabetRail(letters),
          ),
      ],
    );
  }

  Widget _alphabetRail(List<String> availableLetters) {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ#';
    return GestureDetector(
      key: _railKey,
      onVerticalDragUpdate: (d) => _onRailInteraction(d.globalPosition),
      onTapDown: (d) => _onRailInteraction(d.globalPosition),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: letters
            .split('')
            .map((letter) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        letter,
                        style: AppTextStyles.medium(
                          fontSize: 10.sp,
                          color: letter == _activeRailLetter
                              ? Colors.red
                              : availableLetters.contains(letter)
                                  ? AppColors.white.withValues(alpha: 0.8)
                                  : AppColors.white.withValues(alpha: 0.25),
                        ),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
