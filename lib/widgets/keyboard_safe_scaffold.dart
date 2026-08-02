import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Screens that manage their own full bottom inset (keyboard + home
/// indicator) via [KeyboardSafeScaffold] register here while mounted, so the
/// app-root [SafeArea] in main.dart can stop separately reserving the same
/// space. Two independently-timed bottom reservations racing each other
/// during the iOS keyboard-close animation is what produced the hairline
/// white seam this widget fixes — see main.dart's builder for the other half
/// of this mechanism.
final ValueNotifier<int> activeSelfManagedInsetScreens = ValueNotifier<int>(0);

/// A [Scaffold] that avoids the iOS-only hairline seam that appears when the
/// keyboard closes.
///
/// Two things cause that seam if left to Flutter's defaults: (1) this
/// Scaffold resizing independently of the non-resizing app-root Scaffold in
/// main.dart, racing against iOS's own per-frame keyboard-close animation;
/// and (2) the keyboard inset and the home-indicator inset being reserved by
/// two differently-timed layers (an animated padding here vs. an unanimated
/// SafeArea above it). This widget fixes both: it matches the app-root
/// Scaffold's `resizeToAvoidBottomInset: false`, drives the *combined*
/// keyboard + home-indicator inset through a single [AnimatedPadding], and
/// registers with [activeSelfManagedInsetScreens] so the app-root SafeArea
/// backs off instead of double-reserving.
class KeyboardSafeScaffold extends StatefulWidget {
  const KeyboardSafeScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.backgroundColor,
    this.bottomNavigationBar,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Color? backgroundColor;

  /// Animated up together with [body] as a single unit, so a bottom-pinned
  /// CTA button or ad banner never lags a frame behind the body content.
  final Widget? bottomNavigationBar;

  @override
  State<KeyboardSafeScaffold> createState() => _KeyboardSafeScaffoldState();
}

class _KeyboardSafeScaffoldState extends State<KeyboardSafeScaffold> {
  @override
  void initState() {
    super.initState();
    // Deferred: mutating the ValueNotifier synchronously here would notify
    // main.dart's ValueListenableBuilder — an ancestor — while this widget's
    // own first build is still in progress, which throws "setState() or
    // markNeedsBuild() called during build". Registering a frame late is
    // harmless (worst case: one extra frame of the app-root SafeArea still
    // reserving space, i.e. the safe/conservative direction).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      activeSelfManagedInsetScreens.value++;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      activeSelfManagedInsetScreens.value--;
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset =
        math.max(mediaQuery.viewInsets.bottom, mediaQuery.viewPadding.bottom);

    return Scaffold(
      appBar: widget.appBar,
      backgroundColor: widget.backgroundColor,
      resizeToAvoidBottomInset: false,
      body: AnimatedPadding(
        padding: EdgeInsets.only(bottom: bottomInset),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: widget.bottomNavigationBar == null
            ? widget.body
            : Column(
                children: [
                  Expanded(child: widget.body),
                  widget.bottomNavigationBar!,
                ],
              ),
      ),
    );
  }
}
