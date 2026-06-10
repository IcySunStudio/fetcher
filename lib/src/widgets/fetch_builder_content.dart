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
      // When fadeOnDataChange is true (default), wrap the child in a KeyedSubtree keyed on the
      // full snapshot so that AnimatedSwitcher always detects a change and plays the fade —
      // including data-to-data transitions. The trade-off is that the child subtree is destroyed
      // and recreated on every data update, which causes stateful children to lose their state.
      //
      // When fadeOnDataChange is false, the child is passed directly without a key. Flutter
      // reconciles the widget tree naturally: transitions between fetch states (loading, error,
      // data) still animate because the child widget type changes, while data updates rebuild
      // the child in-place, preserving subtree state.
      //
      // Note: fadeOnDataChange has no effect when fadeDuration is null or Duration.zero,
      // since the FadedAnimatedSwitcher is not used in that case (see guard above).
      final fadeOnDataChange = config.fadeOnDataChange ?? true;
      return FadedAnimatedSwitcher(
        duration: config.fadeDuration!,
        child: fadeOnDataChange
            ? KeyedSubtree(
                key: ValueKey(snapshot),
                child: child,
              )
            : child,
      );
    }

    return child;
  }
}
