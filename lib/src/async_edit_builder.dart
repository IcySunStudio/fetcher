import 'package:fetcher/fetcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef DataEditWidgetBuilder<T> = Widget Function(BuildContext context, T value, ValueSetter<T> commit);

/// A widget that allow to fetch a value asynchronously, and then to run another task asynchronously (to commit new value for instance) while updating UI with new value.
/// Handle all states (loading, errors, onSuccess).
/// It's actually a mix of [FetchBuilder] and [AsyncTaskBuilder] combined.
/// Typically used for component that needs to fetch a value and then edit that value.
/// Example : an async switch
class AsyncEditBuilder<T> extends StatefulWidget {
  const AsyncEditBuilder({
    super.key,
    this.config,
    required this.fetchTask,
    required this.commitTask,
    required this.builder,
    this.onEditSuccess,
  });

  /// Widget configuration, that will override the one provided by [DefaultFetcherConfig]
  final FetcherConfig? config;

  /// Task that fetch value
  /// If task throws, it will be properly handled
  final AsyncValueGetter<T> fetchTask;

  /// Task that commit modification
  /// If task throws, it will be properly handled
  final AsyncValueSetter<T> commitTask;

  /// Child widget builder
  final DataEditWidgetBuilder<T> builder;

  /// Called after [commitTask] is successfully executed.
  final AsyncValueSetter<T>? onEditSuccess;

  @override
  State<AsyncEditBuilder<T>> createState() => _AsyncEditBuilderState<T>();
}

class _AsyncEditBuilderState<T> extends State<AsyncEditBuilder<T>> {
  final _fetcherController = ParameterizedFetchBuilderController<T, T>();

  @override
  Widget build(BuildContext context) {
    return FetchBuilder<T, T>.parameterized(
      controller: _fetcherController,
      config: widget.config,
      task: (value) async => value ?? await widget.fetchTask(),
      builder: (context, data) {
        return AsyncTaskBuilder<T>(
          config: widget.config,
          onSuccess: (data) => _fetcherController.refresh(param: data),
          builder: (context, runTask) => widget.builder(
            context,
            data,
            (data) => runTask(() async {
              await widget.commitTask(data);
              return data;
            }),
          ),
        );
      },
    );
  }
}
