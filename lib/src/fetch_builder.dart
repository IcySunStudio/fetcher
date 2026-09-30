import 'dart:async';

import 'package:fetcher/src/config/default_fetcher_config.dart';
import 'package:flutter/material.dart';
import 'package:value_stream_flutter/value_stream_flutter.dart';

import 'exceptions/fetch_exception.dart';
import 'config/fetcher_config.dart';
import 'utils/data_wrapper.dart';
import 'utils/utils.dart';
import 'widgets/fetch_builder_content.dart';

part 'fetch_refresher.dart';

/// Widget that fetch data asynchronously, and display it when available.
/// Handle all possible states: loading, loaded, errors.
///
/// ## Skipping the loader when data is already available
/// If the data may already be known synchronously (e.g. from a cache), return it directly from `task`
/// instead of a [Future]: the loader is then skipped entirely, even on the first frame.
/// Don't mark the task `async`: an `async` function always returns a [Future], even if it never awaits,
/// so the loader would still be displayed for one frame.
///
/// ```dart
/// // BAD: loader is displayed for one frame, even when `cachedValue` is already set.
/// FetchBuilder<Data>(task: () async => cachedValue ?? await fetchData(), ...)
///
/// // GOOD: no loader at all when `cachedValue` is already set.
/// FetchBuilder<Data>(task: () => cachedValue ?? fetchData(), ...)
/// ```
///
/// The GOOD version requires Dart 3.4+ and an explicit type argument (otherwise the data type is inferred as `Object`).
class FetchBuilder<T> extends FetchBuilderWithParameter<Never, T> {
  FetchBuilder({
    super.key,
    super.config,
    FetchBuilderController<T>? controller,
    /// Task that fetch and return the data.
    /// If task throws, it will be properly handled (message displayed + report error)
    /// Return the value directly (not a [Future]) when it's already available, to skip the loader: see [FetchBuilder].
    required FutureOr<T> Function() task,
    super.fetchAtInit = true,
    super.initBuilder,
    super.builder,
    super.onSuccess,
  }) : super._(
    controller: controller,
    task: (_) => task(),
  );
}

/// A [FetchBuilder] where the refresh method of the controller takes a parameter, passed to [task].
/// Useful for advanced use cases.
class FetchBuilderWithParameter<T, R> extends StatefulWidget {
  const FetchBuilderWithParameter._({
    super.key,
    this.config,
    this.controller,
    required this.task,
    this.fetchAtInit = true,
    this.initBuilder,
    this.builder,
    this.onSuccess,
  });

  /// A [FetchBuilder] where the refresh method of the controller takes a parameter, passed to [task].
  /// Useful for advanced use cases.
  const FetchBuilderWithParameter({
    super.key,
    this.config,
    FetchBuilderWithParameterController<T, R>? controller,
    required this.task,
    this.fetchAtInit = true,
    this.initBuilder,
    this.builder,
    this.onSuccess,
  // ignore: prefer_initializing_formals    // We force subtype to be used
  }) : controller = controller;

  /// Widget configuration, that will override the one provided by [DefaultFetcherConfig]
  final FetcherConfig? config;

  /// A controller used to manually refresh data.
  final FetchBuilderControllerBase<T, R>? controller;

  /// Task that fetch and return the data, with optional parameter
  /// If task throws, it will be properly handled (message displayed + report error)
  /// Return the value directly (not a [Future]) when it's already available, to skip the loader: see [FetchBuilder].
  final ParameterizedAsyncTask<T, R> task;

  /// Whether to automatically start [task] when widget is initialised
  /// Default to true.
  final bool fetchAtInit;

  /// When [fetchAtInit] is false, child to display before fetching starts.
  final WidgetBuilder? initBuilder;

  /// Child to display when data is available
  /// May be null if you only want to fetch data without displaying it (in that case you usually want to use [onSuccess] to navigate out of current page).
  final DataWidgetBuilder<R>? builder;

  /// Called when [task] has successfully completed.
  /// Ignored if widget is unmounted.
  /// Usually used to navigate to another page.
  /// If it throws, it will be handled as if [task] has thrown.
  final ValueSetter<R>? onSuccess;

  @override
  State<FetchBuilderWithParameter<T, R>> createState() => _FetchBuilderWithParameterState<T, R>();
}

class _FetchBuilderWithParameterState<T, R> extends State<FetchBuilderWithParameter<T, R>> {
  /// Resolved config.
  /// Kept in the state (rather than resolved on use), so it's still available if an async task ends after the widget is unmounted.
  late FetcherConfig config;

  void _updateConfig() => config = DefaultFetcherConfig.of(context).merge(widget.config);

  bool _isInitialized = false;

  /// Because BuildContext is unmounted when dispose() is called, we need to keep a reference to the _FetchRefresherState we've registered to
  _FetchRefresherState? _refresherState;

  EventStream<DataWrapper<R>?>? _stream;

  /// Lazy stream init.
  /// This allows to properly display [widget.initBuilder] (When stream is null, the StreamBuilder snapshot's state will be ConnectionState.none).
  EventStream<DataWrapper<R>?> get stream {
    if (_stream == null) {
      setState(() {
        _stream = EventStream();
      });
    }
    return _stream!;
  }

  @override
  void initState() {
    super.initState();

    // Init controller
    widget.controller?._mountState(this);

    // Register to closest FetchRefresher
    _refresherState = FetchRefresher._maybeOf(context);
    _refresherState?._register(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateConfig();

    // Initial fetch is done here rather than in initState, because it may use the config synchronously,
    // which can't be read from initState (inherited widgets can't be listened to there).
    if (!_isInitialized) {
      _isInitialized = true;
      if (widget.fetchAtInit) _fetch();
    }
  }

  @override
  void didUpdateWidget(covariant FetchBuilderWithParameter<T, R> oldWidget) {
    _updateConfig();
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._unmountState(this);
      widget.controller?._mountState(this);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return EventStreamBuilder(
      stream: _stream,   // Use private nullable stream: when it's null, the snapshot's state will be ConnectionState.none.
      builder: (context, snapshot) {
        return FetchBuilderContent(
          config: config,
          snapshot: snapshot,
          initBuilder: widget.initBuilder,
          builder: widget.builder,
        );
      },
    );
  }

  /// Store last started task id
  int _lastFetchTaskId = 0;

  Future<R?> _fetch({T? param, bool? clearDataFirst, FetchErrorDisplayMode? errorDisplayMode}) async {
    // Save task id
    final taskId = ++_lastFetchTaskId;
    bool isTaskValid() => mounted && taskId == _lastFetchTaskId;

    // Skip if disposed
    if (!mounted) return null;

    // Clear current data
    clearDataFirst ??= stream.hasError;
    if (clearDataFirst) stream.add(null);

    // Start process
    try {
      // Run task.
      // If it resolves synchronously (a plain value, not a Future — see [ParameterizedAsyncTask]), skip the await entirely so the result is available before the first build.
      final taskResult = widget.task(param);
      final result = taskResult is Future<R> ? await taskResult : taskResult;

      // If task is still valid
      if (isTaskValid()) {
        // Call config onFetchSuccess
        config.onFetchSuccess?.call(result);

        // Call onSuccess
        widget.onSuccess?.call(result);

        // Update UI
        stream.add(DataWrapper(result));
      }

      // Return result, even if task is not valid anymore
      return result;
    } catch(e, s) {
      // Report error first
      config.onError!(e, s);

      // Update UI
      if (isTaskValid()) {
        // Set display mode default value
        errorDisplayMode ??= FetchErrorDisplayMode.values.first;

        // Display "in widget" if asked OR if no data is available (because widget will be in loading state)
        final inWidget = errorDisplayMode == FetchErrorDisplayMode.inWidget || stream.valueOrNull == null;

        // Display "on display" if asked
        final onDisplay = errorDisplayMode == FetchErrorDisplayMode.onDisplay;

        // Display error in widget
        if (inWidget) {
          stream.addError(FetchException(e, () => _fetch(param: param, errorDisplayMode: FetchErrorDisplayMode.onDisplay)));
        }

        // Display error in display
        if (onDisplay) {
          // [isTaskValid] already check if widget is mounted
          // ignore: use_build_context_synchronously
          config.onDisplayError!(context, e);
        }
      }
    }

    // Exit with no result
    return null;
  }

  @override
  void dispose() {
    widget.controller?._unmountState(this);
    _refresherState?._unregister(this);
    _stream?.close();
    super.dispose();
  }
}

enum FetchErrorDisplayMode {
  /// Display error inside the widget, replacing content.
  /// Will use [FetcherConfig.fetchErrorBuilder] to build the error widget.
  /// Default mode.
  inWidget,

  /// Display error to user.
  /// Will call [FetcherConfig.onDisplayError] to display the error.
  onDisplay,
}

/// A controller for an [FetchBuilder].
///
/// Only support one widget per controller.
/// If multiple widget are using the same controller, only the last one will work.
abstract class FetchBuilderControllerBase<T, R> {
  _FetchBuilderWithParameterState<T, R>? _state;

  void _mountState(_FetchBuilderWithParameterState<T, R> state) {
    _state = state;
  }

  void _unmountState(_FetchBuilderWithParameterState<T, R> state) {
    /// When a widget is rebuilt with another key,
    /// the state of the new widget is first initialised,
    /// then the state of the old widget is disposed.
    /// So we need to unmount state only if it hasn't changed since.
    if (_state == state) {
      _state = null;
    }
  }

  /// Whether the controller is mounted to a [FetchBuilder].
  bool get isMounted => _state != null;

  /// Refresh data by re-running the [FetchBuilder.task].
  /// Return the result of the task, or null if task throws.
  /// Throws if controller is not mounted. Use [isMounted] to check if controller is mounted before use.
  Future<R?> refresh();
}

class FetchBuilderWithParameterController<T, R> extends FetchBuilderControllerBase<T, R> {
  @override
  Future<R?> refresh({T? param, bool? clearDataFirst, FetchErrorDisplayMode? errorDisplayMode}) =>
      _state!._fetch(param: param, clearDataFirst: clearDataFirst, errorDisplayMode: errorDisplayMode);
}

class FetchBuilderController<R> extends FetchBuilderControllerBase<Never, R> {
  @override
  Future<R?> refresh({bool? clearDataFirst, FetchErrorDisplayMode? errorDisplayMode}) =>
      _state!._fetch(clearDataFirst: clearDataFirst, errorDisplayMode: errorDisplayMode);
}
