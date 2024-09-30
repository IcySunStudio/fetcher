import 'package:fetcher/src/config/default_fetcher_config.dart';
import 'package:fetcher/src/exceptions/fetch_exception.dart';
import 'package:fetcher/src/config/fetcher_config.dart';
import 'package:fetcher/src/models/fetch_error_data.dart';
import 'package:flutter/material.dart';
import 'package:value_stream/value_stream.dart';

import 'faded_animated_switcher.dart';

class FetchBuilderContent<T> extends StatelessWidget {
  const FetchBuilderContent({
    super.key,
    this.config,
    required this.snapshot,
    this.initBuilder,
    this.builder,
  });

  /// Widget configuration, that will override the one provided by [DefaultFetcherConfig]
  final FetcherConfig? config;

  /// Data snapshot
  final AsyncSnapshot<T> snapshot;

  /// Widget to display when snapshot is in [ConnectionState.none] state (before fetching has started).
  final WidgetBuilder? initBuilder;

  /// Child to display when data is available
  final DataWidgetBuilder<T>? builder;

  @override
  Widget build(BuildContext context) {
    final config = DefaultFetcherConfig.of(context).apply(this.config);

    final child = () {
      // If source stream is null
      if (snapshot.connectionState == ConnectionState.none) {
        return initBuilder?.call(context) ?? const SizedBox();
      }
      // If an error occurred
      else if (snapshot.hasError) {
        final error = snapshot.error!;
        return config.fetchErrorBuilder!(context, FetchErrorData(error is FetchException ? error.innerException : error, config.isDense == true, error is FetchException ? error.retry : null));
      }
      // If data is loading
      else if (!snapshot.hasData) {
        return config.fetchingBuilder!(context);
      }
      // If data is available
      else {
        return builder?.call(context, snapshot.data as T) ?? const SizedBox();
      }
    } ();

    if (config.fadeDuration != null && config.fadeDuration! > Duration.zero) {
      return FadedAnimatedSwitcher(
        duration: config.fadeDuration!,
        child: KeyedSubtree(
          // Ensure proper AnimatedSwitcher transition between states.
          // Without this, transition doesn't work when data isn't cleared first (same widget type), and in any case the outgoing widget isn't animated.
          key: ObjectKey(snapshot),
          child: child,
        ),
      );
    }

    return child;
  }
}
