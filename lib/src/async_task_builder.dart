import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'default_fetcher_config.dart';
import 'fetcher_config.dart';
import 'utils.dart';
import 'widgets/activity_barrier.dart';

typedef AsyncTaskChildBuilder<T> = Widget Function(BuildContext context, TaskRunnerCallback<T> runTask);

/// A widget that allow to run an async task and handle all states (loading, errors, onSuccess).
class AsyncTaskBuilder<T> extends StatefulWidget {
  const AsyncTaskBuilder({
    super.key,
    this.config,
    this.task,
    required this.builder,
    this.onSuccess,
  });

  /// Widget configuration, that will override the one provided by [DefaultFetcherConfig]
  final FetcherConfig? config;

  /// Task to be executed.
  /// Will be overridden by task passed when calling [runTask] provided by [builder].
  final AsyncValueGetter<T>? task;

  /// Widget builder, that provides a [runTask] callback.
  /// You may pass a [task] to run, that will override widget's [task].
  final AsyncTaskChildBuilder<T> builder;

  /// Called after task is successfully executed.
  final AsyncValueSetter<T>? onSuccess;

  @override
  State<AsyncTaskBuilder<T>> createState() => _AsyncTaskBuilderState<T>();
}

class _AsyncTaskBuilderState<T> extends State<AsyncTaskBuilder<T>> {
  late final FetcherConfig config;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();

    // Build config
    final defaultConfig = DefaultFetcherConfig.of(context);
    config = widget.config?.applyDefaults(defaultConfig) ?? defaultConfig;
  }

  @override
  Widget build(BuildContext context) {
    return ActivityBarrier(
      duration: config.fadeDuration!,
      busyBuilder: config.fetchingBuilder!,
      isBusy: _isBusy,
      child: widget.builder(context, _runTask),
    );
  }

  void _runTask([AsyncValueGetter<T>? task]) async {
    assert(widget.task != null || task != null);

    // Skip if disposed or already busy
    if (!mounted || _isBusy) return;

    // Update UI
    setIsBusy(true);

    try {
      // Run task
      final result = await (task ?? widget.task!)();

      // Update UI
      if (mounted) await widget.onSuccess?.call(result);
    } catch (e, s) {
      // Report error first
      config.reportError!(e, s);

      // Update UI
      if (mounted) config.showError!(context, e);
    } finally {
      if (mounted) setIsBusy(false);
    }
  }

  void setIsBusy(bool value) {
    if (value != _isBusy) {
      setState(() {
        _isBusy = value;
      });
    }
  }
}
