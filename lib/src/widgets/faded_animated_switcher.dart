import 'package:flutter/widgets.dart';

class FadedAnimatedSwitcher extends StatelessWidget {
  const FadedAnimatedSwitcher({
    super.key,
    required this.duration,
    this.child,
    this.sizeAnimation = false,
  });

  final Duration duration;

  /// The current child widget to display
  final Widget? child;

  /// Will also animate it's size with a [SizeTransition].
  /// Be aware that this will add a ClipRect.
  final bool sizeAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: sizeAnimation == true
          ? (child, animation) => FadeTransition(opacity: animation, child: SizeTransition(sizeFactor: animation, axisAlignment: -1, child: child))
          : AnimatedSwitcher.defaultTransitionBuilder,
      layoutBuilder: _animatedSwitcherLayoutBuilder,
      child: child,
    );
  }

  /// Copied from AnimatedSwitcher.defaultLayoutBuilder
  static Widget _animatedSwitcherLayoutBuilder(Widget? currentChild, List<Widget> previousChildren) {
    // AnimatedSwitcher only hides outgoing children sharing the current child's key, not outgoing children
    // sharing a key with each other, which throws "Duplicate keys found" on rapid changes.
    // Keep only the most recent one: older duplicates were already hidden by AnimatedSwitcher.
    final seenKeys = <Key?>{};
    final uniquePreviousChildren = previousChildren.reversed.where((child) => seenKeys.add(child.key)).toList().reversed;

    return Stack(
      fit: StackFit.passthrough,
      alignment: Alignment.topLeft,
      children: <Widget>[
        ...uniquePreviousChildren,
        if (currentChild != null) currentChild,
      ],
    );
  }
}
