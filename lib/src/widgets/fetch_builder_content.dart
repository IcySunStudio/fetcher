import 'package:fetcher/src/config/default_fetcher_config.dart';
import 'package:fetcher/src/exceptions/fetch_exception.dart';
import 'package:fetcher/src/config/fetcher_config.dart';
import 'package:fetcher/src/models/fetch_error_data.dart';
import 'package:fetcher/src/utils/data_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:value_stream_flutter/value_stream_flutter.dart';

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
  final AsyncSnapshot<DataWrapper<T>?> snapshot;

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
        return builder?.call(context, snapshot.data!.data) ?? const SizedBox();
      }
    } ();

    if (config.fadeDuration != null && config.fadeDuration! > Duration.zero) {
      // AnimatedSwitcher requires a key change to detect that the child has changed and animate
      // the outgoing widget. Without a key, only the incoming widget is animated.
      //
      // When fadeOnDataChange is true (default), wrap the child in a KeyedSubtree keyed on the
      // full snapshot so that AnimatedSwitcher always detects a change and plays the fade —
      // including data-to-data transitions. The trade-off is that the child subtree is destroyed
      // and recreated on every data update, which causes stateful children to lose their state.
      //
      // When fadeOnDataChange is false, use a key that changes only on fetch state category
      // transitions (none → loading → data ↔ error). This ensures AnimatedSwitcher properly
      // animates outgoing widgets (e.g. the loader fades out) on state changes, while data
      // updates rebuild the child in-place, preserving subtree state.
      final fadeOnDataChange = config.fadeOnDataChange ?? true;
      return FadedAnimatedSwitcher(
        duration: config.fadeDuration!,
        child: KeyedSubtree(
          key: fadeOnDataChange || !snapshot.hasData
              ? ValueKey(snapshot)
              : const ValueKey('data'),
          child: child,
        ),
      );
    }

    return child;
  }
}
