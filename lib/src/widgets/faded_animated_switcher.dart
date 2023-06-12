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
    return Stack(
      fit: StackFit.passthrough,
      alignment: Alignment.topLeft,
      children: <Widget>[
        ...previousChildren,
        if (currentChild != null) currentChild,
      ],
    );
  }
}
