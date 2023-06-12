import 'package:flutter/material.dart';
import 'package:value_stream/value_stream.dart';

import 'default_fetcher_config.dart';
import 'exceptions/fetch_exception.dart';
import 'fetcher_config.dart';
import 'widgets/faded_animated_switcher.dart';

class EventFetchBuilder<T> extends StatefulWidget {
  const EventFetchBuilder({super.key, required this.stream, this.builder, this.config, this.isDense = false, this.fade = true});

  ///
  final EventStream<T> stream;

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
  State<EventFetchBuilder<T>> createState() => _EventFetchBuilderState<T>();
}

class _EventFetchBuilderState<T> extends State<EventFetchBuilder<T>> {
  late final FetcherConfig config;

  @override
  void initState() {
    super.initState();

    // Build config
    final defaultConfig = DefaultFetcherConfig.of(context);
    config = widget.config?.applyDefaults(defaultConfig) ?? defaultConfig;
  }

  @override
  Widget build(BuildContext context) {
    return EventStreamBuilder<T>(
      stream: widget.stream,
      builder: (context, snapshot) {
        final child = () {
          if (snapshot.hasError) {
            return config.errorBuilder!(context, widget.isDense, (snapshot.error as FetchException).retry);
          } else if (!snapshot.hasData) {
            return config.fetchingBuilder!(context);
          } else {
            return widget.builder?.call(context, snapshot.data as T) ?? const SizedBox();
          }
        } ();

        if (widget.fade) {
          return FadedAnimatedSwitcher(
            duration: config.fadeDuration!,
            child: child,
          );
        }

        return child;
      },
    );
  }
}
