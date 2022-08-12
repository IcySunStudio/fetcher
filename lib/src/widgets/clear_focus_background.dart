import 'package:fetcher/src/utils.dart';
import 'package:flutter/material.dart';

class ClearFocusBackground extends StatelessWidget {
  const ClearFocusBackground({Key? key, this.child}) : super(key: key);

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.clearFocus(),
      child: child,
    );
  }
}
