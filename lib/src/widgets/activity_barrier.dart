import 'package:flutter/widgets.dart';

/// A widget that add an activity indicator overlay that prevents the user from interacting with widgets behind itself.
class ActivityBarrier extends StatelessWidget {
  /// Creates a widget that add an activity indicator overlay that prevents the user from interacting with widgets behind itself.
  const ActivityBarrier({
    Key? key,
    required this.duration,
    this.barrierColor,
    required this.busyBuilder,
    this.isBusy = false,
    required this.child,
  }) : super(key: key);

  final Duration duration;
  final Color? barrierColor;
  final WidgetBuilder busyBuilder;
  final bool isBusy;
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
                  padding: const EdgeInsets.all(5),
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
