import 'package:fetcher/src/utils/data_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:value_stream/value_stream.dart';

import 'config/default_fetcher_config.dart';
import 'config/fetcher_config.dart';
import 'widgets/fetch_builder_content.dart';

/// Widget that listen to an [EventStream] and display data.
/// It's like [FetchBuilder] but instead of directly calling a task once, it will listen to a stream and his updates.
/// Handle all possible states: loading, loaded, errors.
class EventFetchBuilder<T> extends StatelessWidget {
  /// Build a new [EventFetchBuilder] from an [EventStream]
  /// If stream already has a value or an error, it will be displayed directly.
  const EventFetchBuilder({super.key, required this.stream, this.builder, this.config});

  /// The [Stream] to listen to.
  /// A progress indicator will be displayed while waiting for first emitted value.
  final EventStream<T> stream;

  /// Child to display when data is available
  final DataWidgetBuilder<T>? builder;

  /// Widget configuration, that will override the one provided by [DefaultFetcherConfig]
  final FetcherConfig? config;

  @override
  Widget build(BuildContext context) {
    return EventStreamBuilder<DataWrapper<T>>.fromStream(   // OPTI use default EventStreamBuilder constructor instead (cleaner). But need to a implement EventStream.map method, which is no easy task.
      stream: stream.innerStream.map(DataWrapper.new),
      initialData: stream.valueOrNull != null ? DataWrapper(stream.valueOrNull as T) : null,
      initialError: stream.error,
      builder: (context, snapshot) {
        return FetchBuilderContent<DataWrapper<T>>(
          config: config,
          snapshot: snapshot,
          builder: builder != null ? (context, value) => builder!(context, value.data) : null,
        );
      },
    );
  }
}
