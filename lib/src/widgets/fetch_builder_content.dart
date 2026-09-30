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
    final config = DefaultFetcherConfig.of(context).merge(this.config);

    final child = () {
      // If source stream is null
      if (snapshot.connectionState == ConnectionState.none) {
        return initBuilder?.call(context) ?? const SizedBox();
      }
      // If an error occurred
      else if (snapshot.hasError) {
        final error = snapshot.error!;
        return config.fetchErrorBuilder!(context, FetchErrorData(error is FetchException ? error.innerException : error, config.isDense!, error is FetchException ? error.retry : null));
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

    if (config.fadeDuration! > Duration.zero) {
      // AnimatedSwitcher requires a key change to detect that the child has changed and animate
      // the outgoing widget. Without a key, only the incoming widget is animated.
      //
      // When fadeOnDataChange is false (default), all data snapshots share the same key: data
      // updates rebuild the child in-place, preserving subtree state, while any other snapshot
      // change (none, loading, error, data) fades.
      //
      // When fadeOnDataChange is true, the key is the full snapshot, so data-to-data transitions
      // fade too, at the cost of destroying and recreating the child subtree on every data update.
      return FadedAnimatedSwitcher(
        duration: config.fadeDuration!,
        alignment: config.fadeAlignment!,
        child: KeyedSubtree(
          key: config.fadeOnDataChange! || !snapshot.hasData
              ? ValueKey(snapshot)
              : const ValueKey('data'),
          child: child,
        ),
      );
    }

    return child;
  }
}
