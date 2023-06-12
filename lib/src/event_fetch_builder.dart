import 'package:flutter/material.dart';
import 'package:value_stream/value_stream.dart';

import 'default_fetcher_config.dart';
import 'exceptions/fetch_exception.dart';
import 'fetcher_config.dart';
import 'widgets/faded_animated_switcher.dart';

/// Widget that listen to a Stream and display data.
/// Handle all possible states: loading, loaded, errors.
class EventFetchBuilder<T> extends StatefulWidget {
  /// Build a new [EventFetchBuilder] from a classic [Stream], with optional [initialData]
  const EventFetchBuilder({super.key, required this.stream, this.initialData, this.builder, this.config, this.isDense = false, this.fade = true});

  /// Build a new [EventFetchBuilder] from an [EventStream]
  /// If stream already has a value, it will be displayed directly.
  EventFetchBuilder.fromEvent({super.key, required EventStream<T> stream, this.builder, this.config, this.isDense = false, this.fade = true}) :
        stream = stream.innerStream, initialData = stream.valueOrNull;

  /// The [Stream] to listen to.
  /// A progress indicator will be displayed while waiting for first emitted value.
  final Stream<T> stream;

  /// Initial value
  final T? initialData;

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
    return StreamBuilder<T>(
      stream: widget.stream,
      initialData: widget.initialData,
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
