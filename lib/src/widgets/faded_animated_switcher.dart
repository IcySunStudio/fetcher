import 'package:flutter/widgets.dart';

/// Internal [AnimatedSwitcher] with a cross-fade, sized to its largest child, and safe against rapid changes.
class FadedAnimatedSwitcher extends StatelessWidget {
  const FadedAnimatedSwitcher({
    super.key,
    required this.duration,
    this.child,
  });

  final Duration duration;

  /// The current child widget to display
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      layoutBuilder: _animatedSwitcherLayoutBuilder,
      child: child,
    );
  }

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
