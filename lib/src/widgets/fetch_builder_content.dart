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
      if (snapshot.connectionState == ConnectionState.none) {
        return initBuilder?.call(context) ?? const SizedBox();
      } else if (snapshot.hasError) {
        final error = snapshot.error!;
        return config.fetchErrorBuilder!(context, FetchErrorData(error, config.isDense == true, error is FetchException ? error.retry : null));
      } else if (!snapshot.hasData) {
        return config.fetchingBuilder!(context);
      } else {
        return builder?.call(context, snapshot.data as T) ?? const SizedBox();
      }
    } ();

    if (config.fade == true) {
      return FadedAnimatedSwitcher(
        duration: config.fadeDuration!,
        child: child,
      );
    }

    return child;
  }
}
