import 'package:fetcher/src/default_fetcher_config.dart';
import 'package:fetcher/src/exceptions/fetch_exception.dart';
import 'package:fetcher/src/fetcher_config.dart';
import 'package:flutter/material.dart';
import 'package:value_stream/value_stream.dart';

import 'faded_animated_switcher.dart';

class FetchBuilderContent<T> extends StatelessWidget {
  const FetchBuilderContent({
    super.key,
    required this.snapshot,
    this.builder,
    this.config,
    this.isDense = false,
    this.fade = true,
  });

  final AsyncSnapshot<T> snapshot;

  /// Child to display when data is available
  final DataWidgetBuilder<T>? builder;

  /// Widget configuration, that will override the one provided by [DefaultFetcherConfig]
  final FetcherConfig? config;

  /// Whether this widget is in a low space environment
  /// Will affect default error widget density
  final bool isDense;

  /// Whether to enable a fading transition
  final bool fade;

  @override
  Widget build(BuildContext context) {
    final config = DefaultFetcherConfig.of(context).apply(this.config);

    final child = () {
      if (snapshot.hasError) {
        return config.errorBuilder!(context, isDense, (snapshot.error as FetchException).retry);
      } else if (!snapshot.hasData) {
        return config.fetchingBuilder!(context);
      } else {
        return builder?.call(context, snapshot.data as T) ?? const SizedBox();
      }
    } ();

    if (fade) {
      return FadedAnimatedSwitcher(
        duration: config.fadeDuration!,
        child: child,
      );
    }

    return child;
  }
}
