import 'package:fetcher/fetcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef DataEditWidgetBuilder<T> = Widget Function(BuildContext context, T value, ValueSetter<T> submit);

/// A widget that allow to fetch a value asynchronously, and then to run another task asynchronously (to submit new value for instance) while updating UI with new value.
/// Handle all states (loading, errors, onSuccess).
/// It's actually a mix of [FetchBuilder] and [SubmitBuilder] combined.
/// Typically used for component that needs to fetch a value and then edit that value.
/// DON'T use this if fetch and submit tasks are not related (prefer using separate [FetchBuilder] and [SubmitBuilder]).
/// Example : an async switch, that fetch the current value, and then can submit the new value.
class AsyncEditBuilder<T> extends StatefulWidget {
  const AsyncEditBuilder({
    super.key,
    this.config,
    this.fetchingBuilder,
    required this.fetchTask,
    required this.submitTask,
    required this.builder,
    this.onEditSuccess,
  });

  /// Widget configuration, that will override the one provided by [DefaultFetcherConfig]
  /// Config is applied to both [FetchBuilder] and [SubmitBuilder]
  final FetcherConfig? config;

  /// Widget to display while fetching
  /// Default to [config.fetchingBuilder]
  /// If you want to change the submit widget, you should use [config.fetchingBuilder] instead.
  final WidgetBuilder? fetchingBuilder;

  /// Task that fetch value
  /// If task throws, it will be properly handled
  final AsyncValueGetter<T> fetchTask;

  /// Task that submit modification
  /// If task throws, it will be properly handled
  final AsyncValueSetter<T> submitTask;

  /// Child widget builder
  final DataEditWidgetBuilder<T> builder;

  /// Called after [submitTask] is successfully executed.
  /// Ignored if widget is unmounted.
  final ValueSetter<T>? onEditSuccess;

  @override
  State<AsyncEditBuilder<T>> createState() => _AsyncEditBuilderState<T>();
}

class _AsyncEditBuilderState<T> extends State<AsyncEditBuilder<T>> {
  final _fetcherController = FetchBuilderWithParameterController<T, T>();
  late final _fetchBuilderConfig = () {
    if (widget.fetchingBuilder == null) return widget.config;
    final fetchingBuilderConfig = FetcherConfig(fetchingBuilder: widget.fetchingBuilder);
    return widget.config == null ? fetchingBuilderConfig : widget.config!.apply(fetchingBuilderConfig);
  } ();

  @override
  Widget build(BuildContext context) {
    return FetchBuilderWithParameter<T, T>(
      controller: _fetcherController,
      config: _fetchBuilderConfig,
      task: (value) async => value ?? await widget.fetchTask(),
      builder: (context, data) {
        return SubmitBuilder<T>(
          config: widget.config,
          onSuccess: (data) {
            widget.onEditSuccess?.call(data);
            _fetcherController.refresh(param: data);
          },
          builder: (context, runTask) => widget.builder(
            context,
            data,
            (data) => runTask(() async {
              await widget.submitTask(data);
              return data;
            }),
          ),
        );
      },
    );
  }
}
