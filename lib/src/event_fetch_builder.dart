import 'package:flutter/material.dart';
import 'package:value_stream/value_stream.dart';

import 'default_fetcher_config.dart';
import 'fetcher_config.dart';
import 'widgets/fetch_builder_content.dart';

/// Widget that listen to a Stream and display data.
/// It's like [FetchBuilder] but instead of directly calling a task once, it will listen to a stream and his updates.
/// Handle all possible states: loading, loaded, errors.
class EventFetchBuilder<T> extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      initialData: initialData,
      builder: (context, snapshot) {
        return FetchBuilderContent<T>(
          snapshot: snapshot,
          builder: builder,
          config: config,
          isDense: isDense,
          fade: fade,
        );
      },
    );
  }
}
