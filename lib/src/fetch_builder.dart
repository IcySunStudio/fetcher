import 'package:fetcher/src/default_fetcher_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:value_stream/value_stream.dart';

import 'exceptions/connectivity_exception.dart';
import 'exceptions/fetch_exception.dart';
import 'fetcher_config.dart';
import 'widgets/faded_animated_switcher.dart';
import 'utils.dart';

/// Widget that fetch data asynchronously, and display it when available.
/// Handle all possible states: loading, loaded, errors.
class FetchBuilder<T, R> extends StatefulWidget {
  /// Basic [FetchBuilder] constructor (not parameterized).
  ///
  /// Because constructor or factory must be of type <T, R>, we must use a static method instead.
  static FetchBuilder<Never, R> basic<R>({
    Key? key,
    FetcherConfig? config,
    FetchBuilderControllerBase<Never, R?>? controller,
    required AsyncValueGetter<R> task,
    bool fetchAtInit = true,
    DataWidgetBuilder<R>? builder,
    AsyncValueSetter<R>? onSuccess,
    bool isDense = false,
    bool fade = true,
    ValueGetter<R?>? getFromCache,
    ValueChanged<R>? saveToCache,
  }) => FetchBuilder.parameterized(
    key: key,
    config: config,
    controller: controller,
    task: (_) => task(),
    fetchAtInit: fetchAtInit,
    builder: builder,
    onSuccess: onSuccess,
    isDense: isDense,
    fade: fade,
    getFromCache: getFromCache,
    saveToCache: saveToCache,
  );

  /// A [FetchBuilder] where [FetchBuilderControllerBase.refresh] takes a parameter that will be passed to [task].
  const FetchBuilder.parameterized({
    super.key,
    this.config,
    this.controller,
    required this.task,
    this.fetchAtInit = true,
    this.builder,
    this.onSuccess,
    this.isDense = false,
    this.fade = true,
    this.getFromCache,
    this.saveToCache,
  });

  /// Widget configuration, that will override the one provided by [DefaultFetcherConfig]
  final FetcherConfig? config;

  /// Task that fetch and return the data, with optional parameter
  /// If task throws, it will be properly handled (message displayed + report error)
  final ParameterizedAsyncTask<T, R> task;

  /// Whether to automatically start [task] when widget is initialised
  final bool fetchAtInit;

  /// Child to display when data is available
  final DataWidgetBuilder<R>? builder;

  /// Called when [task] has completed with success
  final AsyncValueSetter<R>? onSuccess;

  /// A controller used to programmatically show the refresh indicator and call the [onRefresh] callback.
  final FetchBuilderControllerBase<T, R?>? controller;

  /// Whether this widget is in a low space environment
  /// Will affect default error widget density
  final bool isDense;

  /// Whether to enable a fading transition
  final bool fade;

  /// Optional function to provide data from cache at creation.
  /// If available, data will be displayed instantly, while fetching newer data from [task].
  /// If a [ConnectivityException] happens while fetching, cached data will stay displayed.
  final ValueGetter<R?>? getFromCache;

  /// Called when [task] is a success, to save new data to cache.
  final ValueChanged<R>? saveToCache;

  @override
  State<FetchBuilder<T, R>> createState() => _FetchBuilderState<T, R>();
}

class _FetchBuilderState<T, R> extends State<FetchBuilder<T, R>> {
  late final FetcherConfig config = DefaultFetcherConfig.of(context).apply(widget.config);
  final data = EventStream<_DataWrapper<R>?>();

  @override
  void initState() {
    super.initState();

    // Get from cache
    try {
      final cachedData = widget.getFromCache?.call();
      if (cachedData != null) data.add(_DataWrapper(cachedData));
    } catch(e, s) {
      config.reportError!(e, s);
    }

    // Init controller
    widget.controller?._mountState(this);

    // Fetch
    if (widget.fetchAtInit) _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return EventStreamBuilder<_DataWrapper<R>?>(
      stream: data,
      builder: (context, snapshot) {
        final child = () {
          if (snapshot.hasError) {
            return config.errorBuilder!(context, widget.isDense, (snapshot.error as FetchException).retry);
          } else if (!snapshot.hasData) {
            return config.fetchingBuilder!(context);
          } else {
            return widget.builder?.call(context, snapshot.data!.data) ?? const SizedBox();
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

  /// Store last started task id
  int _lastFetchTaskId = 0;

  Future<R?> _fetch({T? param, bool? clearDataFirst, bool? showErrors}) async {
    // Save task id
    final taskId = ++_lastFetchTaskId;
    bool isTaskValid() => mounted && taskId == _lastFetchTaskId;

    // Skip if disposed
    if (!mounted) return null;

    // Clear current data
    clearDataFirst ??= data.hasError;
    if (clearDataFirst) data.add(null);

    // Run task
    R result;
    try {
      result = await widget.task(param);
    } catch(e, s) {
      // Report error first
      config.reportError!(e, s);

      // Update UI
      if (isTaskValid()) {
        // Broadcast error, but not if there already is data and it's just a [ConnectivityException]
        if (e is! ConnectivityException || data.valueOrNull == null) {
          data.addError(FetchException(e, () => _fetch(param: param, showErrors: true)));
        }

        // Display error to user, if asked.
        // Default to false, to avoid displaying error when fetch has been started from code: user may be on another screen.
        if (showErrors == true) {
          config.showError!(context, e);
        }
      }

      // Exit
      return null;
    }

    // Run post tasks
    try {
      // Save to cache
      if (isTaskValid()) {
        widget.saveToCache?.call(result);
      }

      // Call onSuccess
      if (isTaskValid()) {
        await widget.onSuccess?.call(result);
      }

      // Update UI
      if (isTaskValid()) {
        data.add(_DataWrapper(result));
        return result;
      }
    } catch(e, s) {
      config.reportError!(e, s);
    }
    return null;
  }

  @override
  void dispose() {
    widget.controller?._unmountState(this);
    data.close();
    super.dispose();
  }
}

/// Small data wrapper, that allow data to be null when himself isn't.
/// Allow to properly handle loading state when data may be null.
class _DataWrapper<T> {
  const _DataWrapper(this.data);

  final T data;
}

/// A controller for an [FetchBuilder].
///
/// Only support one widget per controller.
/// If multiple widget are using the same controller, only the last one will work.
abstract class FetchBuilderControllerBase<T, R> {
  _FetchBuilderState<T, R>? _state;

  void _mountState(_FetchBuilderState<T, R> state) {
    _state = state;
  }

  void _unmountState(_FetchBuilderState<T, R> state) {
    /// When a widget is rebuilt with another key,
    /// the state of the new widget is first initialised,
    /// then the state of the old widget is disposed.
    /// So we need to unmount state only if it hasn't changed since.
    if (_state == state) {
      _state = null;
    }
  }

  Future<R?> refresh();
}

class ParameterizedFetchBuilderController<T, R> extends FetchBuilderControllerBase<T, R> {
  @override
  Future<R?> refresh({T? param, bool? clearDataFirst, bool? userAsked}) =>
      _state!._fetch(param: param, clearDataFirst: clearDataFirst, showErrors: userAsked);
}

class BasicFetchBuilderController<R> extends FetchBuilderControllerBase<Never, R> {
  @override
  Future<R?> refresh({bool? clearDataFirst, bool? userAsked}) =>
      _state!._fetch(clearDataFirst: clearDataFirst, showErrors: userAsked);
}
