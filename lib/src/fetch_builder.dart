import 'package:fetcher/src/config/default_fetcher_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:value_stream/value_stream.dart';

import 'exceptions/connectivity_exception.dart';
import 'exceptions/fetch_exception.dart';
import 'config/fetcher_config.dart';
import 'utils/data_wrapper.dart';
import 'utils/utils.dart';
import 'widgets/fetch_builder_content.dart';

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
    WidgetBuilder? initBuilder,
    DataWidgetBuilder<R>? builder,
    AsyncValueSetter<R>? onSuccess,
    ValueGetter<R?>? getFromCache,
    ValueChanged<R>? saveToCache,
  }) => FetchBuilder.parameterized(
    key: key,
    config: config,
    controller: controller,
    task: (_) => task(),
    fetchAtInit: fetchAtInit,
    initBuilder: initBuilder,
    builder: builder,
    onSuccess: onSuccess,
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
    this.initBuilder,
    this.builder,
    this.onSuccess,
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

  /// When [fetchAtInit] is true, child to display before fetching starts.
  final WidgetBuilder? initBuilder;

  /// Child to display when data is available
  final DataWidgetBuilder<R>? builder;

  /// Called when [task] has completed with success
  final AsyncValueSetter<R>? onSuccess;

  /// A controller used to manually refresh data.
  final FetchBuilderControllerBase<T, R?>? controller;

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

  EventStream<DataWrapper<R>?>? _stream;

  /// Only init stream when needed.
  /// This allows to properly display [widget.initBuilder].
  EventStream<DataWrapper<R>?> _initStream() {
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

    // Get from cache
    if (widget.getFromCache != null) {
      try {
        final cachedData = widget.getFromCache!();
        if (cachedData != null) {
          _initStream().add(DataWrapper(cachedData));
        }
      } catch (e, s) {
        config.onError!(e, s);
      }
    }

    // Init controller
    widget.controller?._mountState(this);

    // Fetch
    if (widget.fetchAtInit) _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return EventStreamBuilder<DataWrapper<R>?>(
      stream: _stream,   // When stream is null, the snapshot's state will be ConnectionState.none.
      builder: (context, snapshot) {
        return FetchBuilderContent<DataWrapper<R>?>(
          config: widget.config,
          snapshot: snapshot,
          initBuilder: widget.initBuilder,
          builder: widget.builder == null ? null : (context, data) => widget.builder!.call(context, data!.data),
        );
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

    // Init stream
    final stream = _initStream();

    // Clear current data
    clearDataFirst ??= stream.hasError;
    if (clearDataFirst) stream.add(null);

    // Run task
    final R result;
    try {
      result = await widget.task(param);
    } catch(e, s) {
      // Report error first
      config.onError!(e, s);

      // Update UI
      if (isTaskValid()) {
        // Broadcast error, but not if there already is data and it's just a [ConnectivityException]
        if (e is! ConnectivityException || stream.valueOrNull == null) {
          stream.addError(FetchException(e, () => _fetch(param: param, showErrors: true)));
        }

        // Display error to user, if asked.
        // Default to false, to avoid displaying error when fetch has been started from code: user may be on another screen.
        if (showErrors == true) {
          config.onDisplayError!(context, e);
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
        stream.add(DataWrapper(result));
        return result;
      }
    } catch(e, s) {
      config.onError!(e, s);
    }
    return null;
  }

  @override
  void dispose() {
    widget.controller?._unmountState(this);
    _stream?.close();
    super.dispose();
  }
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
