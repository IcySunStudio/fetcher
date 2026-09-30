import 'package:flutter/widgets.dart';

/// Internal [AnimatedSwitcher] with a cross-fade, sized to its largest child, and safe against rapid changes.
class FadedAnimatedSwitcher extends StatelessWidget {
  const FadedAnimatedSwitcher({
    super.key,
    required this.duration,
    this.alignment = Alignment.topLeft,
    this.child,
  });

  final Duration duration;

  /// How to align the outgoing and incoming children relative to each other during the transition.
  final AlignmentGeometry alignment;

  /// The current child widget to display
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      layoutBuilder: _layoutBuilder,
      child: child,
    );
  }

  Widget _layoutBuilder(Widget? currentChild, List<Widget> previousChildren) {
    // AnimatedSwitcher only hides outgoing children sharing the current child's key, not outgoing children
    // sharing a key with each other, which throws "Duplicate keys found" on rapid changes.
    // Keep only the most recent one: older duplicates were already hidden by AnimatedSwitcher.
    final seenKeys = <Key?>{};
    final uniquePreviousChildren = previousChildren.reversed.where((child) => seenKeys.add(child.key)).toList().reversed;

    return Stack(
      fit: StackFit.passthrough,
      alignment: alignment,
      children: <Widget>[
        ...uniquePreviousChildren,
        if (currentChild != null) currentChild,
      ],
    );
  }
}
