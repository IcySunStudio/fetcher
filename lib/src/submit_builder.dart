import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'config/default_fetcher_config.dart';
import 'config/fetcher_config.dart';
import 'widgets/activity_barrier.dart';

typedef TaskRunnerCallback<T> = void Function([AsyncValueGetter<T>? task]);
typedef SubmitChildBuilder<T> = Widget Function(BuildContext context, TaskRunnerCallback<T> runTask);

/// A widget that allow to run an async task and handle all states (loading, errors, onSuccess).
/// Design for tasks that is triggered by a user action (like a button press).
class SubmitBuilder<T> extends StatefulWidget {
  const SubmitBuilder({
    super.key,
    this.config,
    this.barrierColor,
    this.runTaskOnStart = false,
    this.task,
    required this.builder,
    this.onSuccess,
  });

  /// Widget configuration, that will override the one provided by [DefaultFetcherConfig]
  final FetcherConfig? config;

  /// Color of the barrier, displayed when running the task.
  /// Default to a translucent white.
  /// Use [Colors.transparent] to hide completely the barrier (still blocks interactions).
  final Color? barrierColor;

  /// Whether to run the task on start.
  /// Default to false.
  final bool runTaskOnStart;

  /// Task to be executed.
  /// Will be overridden by task parameter passed when calling [runTask] provided by [builder].
  final AsyncValueGetter<T>? task;

  /// Widget builder, that provides a [runTask] callback.
  /// Call [runTask] to start the task (usually from a button).
  /// You may pass a [task] to run, that will override widget's [task].
  final SubmitChildBuilder<T> builder;

  /// Called after [task] is successfully executed.
  final AsyncValueSetter<T>? onSuccess;

  @override
  State<SubmitBuilder<T>> createState() => _SubmitBuilderState<T>();

  /// Safely run a async task.
  /// Headless version of [SubmitBuilder].
  static Future<void> runTask<T>({
    required BuildContext context,
    required AsyncValueGetter<T> task,
    FetcherConfig? config,
    AsyncValueSetter<T>? onSuccess,
  }) async {
    try {
      // Run task
      final result = await task();

      // Success callback
      await onSuccess?.call(result);
    } catch(e, s) {
      // Get default config if context is mounted
      if (context.mounted) {
        config = DefaultFetcherConfig.of(context).apply(config);
      }

      // Error callback
      config?.onError?.call(e, s);

      // Display error callback
      if (context.mounted) config?.onDisplayError?.call(context, e);
    }
  }
}

class _SubmitBuilderState<T> extends State<SubmitBuilder<T>> {
  late final config = DefaultFetcherConfig.of(context).apply(widget.config);
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    if (widget.runTaskOnStart) {
      _runTask();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ActivityBarrier(
      duration: config.fadeDuration!,
      barrierColor: widget.barrierColor,
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

    // Run task
    await SubmitBuilder.runTask<T>(
      context: context,
      config: config,
      task: task ?? widget.task!,
      onSuccess: (result) async {
        if (mounted) {
          await widget.onSuccess?.call(result);
        }
      },
    );

    // Update UI
    if (mounted) setIsBusy(false);
  }

  void setIsBusy(bool value) {
    if (value != _isBusy) {
      setState(() {
        _isBusy = value;
      });
    }
  }
}
