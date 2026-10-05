import 'package:flutter/widgets.dart';

/// Internal [AnimatedSwitcher] with a cross-fade, sized to its largest child, and safe against rapid changes.
class FadedAnimatedSwitcher extends StatelessWidget {
  const FadedAnimatedSwitcher({
    super.key,
    required this.duration,
    this.alignment = Alignment.topLeft,
    this.sizeAnimation = false,
    this.child,
  });

  final Duration duration;

  /// How to align the outgoing and incoming children relative to each other during the transition.
  final AlignmentGeometry alignment;

  /// Whether to also animate the height with a [SizeTransition], in addition to the fade.
  /// Be aware that this adds a [ClipRect] around the children during the transition.
  final bool sizeAnimation;

  /// The current child widget to display
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: sizeAnimation ? _sizeTransitionBuilder : AnimatedSwitcher.defaultTransitionBuilder,
      layoutBuilder: _layoutBuilder,
      child: child,
    );
  }

  Widget _sizeTransitionBuilder(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        alignment: alignment,
        child: child,
      ),
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
