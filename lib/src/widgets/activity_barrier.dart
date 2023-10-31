import 'package:flutter/widgets.dart';

/// A widget that add an activity indicator overlay that prevents the user from interacting with widgets behind itself.
class ActivityBarrier extends StatelessWidget {
  /// Creates a widget that add an activity indicator overlay that prevents the user from interacting with widgets behind itself.
  const ActivityBarrier({
    super.key,
    required this.duration,
    this.barrierColor,
    required this.busyBuilder,
    this.isBusy = false,
    required this.child,
  });

  /// Duration of the fade animation.
  final Duration duration;

  /// Color of the barrier, displayed when running the task.
  /// Default to a translucent white.
  /// Use [Colors.transparent] to hide completely the barrier (still blocks interactions).
  final Color? barrierColor;

  /// Builder for the busy indicator.
  final WidgetBuilder busyBuilder;

  /// Whether to display the barrier.
  final bool isBusy;

  /// Child to display (behind the barrier).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Content
        child,

        // Modal barrier
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: duration,
            child: isBusy
              ? Container(
                  color: barrierColor ?? const Color(0x99FFFFFF),
                  alignment: Alignment.center,
                  child: busyBuilder(context),
                )
              : const SizedBox(),
          ),
        ),
      ],
    );
  }
}
