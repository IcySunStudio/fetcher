import 'package:fetcher/extra.dart';
import 'package:fetcher/src/submit_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:value_stream/value_stream.dart';

import 'config/default_fetcher_config.dart';
import 'config/fetcher_config.dart';
import 'exceptions/fetch_exception.dart';
import 'utils/data_wrapper.dart';
import 'widgets/fetch_builder_content.dart';

typedef TaskRunnerCallback<T> = void Function([AsyncValueGetter<T>? task]);

enum AsyncTaskMode { fetch, fetchWithParameter, submit }

enum FetchErrorDisplayMode { inWidget, onDisplay }

class AsyncTaskBuilder<T, R> extends StatefulWidget {
  final AsyncTaskMode mode;
  final FetcherConfig? config;
  final ParameterizedAsyncTask<T, R> task;
  final bool fetchAtInit;
  final WidgetBuilder? initBuilder;
  final DataWidgetBuilder<R>? builder;
  final ValueSetter<R>? onSuccess;
  final ValueGetter<R?>? getFromCache;
  final ValueChanged<R>? saveToCache;
  final Color? barrierColor;
  final SubmitChildBuilder<R>? submitBuilder;
  final AsyncTaskBuilderController<T, R>? controller;

  const AsyncTaskBuilder._({
    super.key,
    required this.mode,
    required this.task,
    this.config,
    this.fetchAtInit = false,
    this.initBuilder,
    this.builder,
    this.onSuccess,
    this.getFromCache,
    this.saveToCache,
    this.barrierColor,
    this.submitBuilder,
    this.controller,
  });

  static AsyncTaskBuilder<void, R> basic<R>({
    Key? key,
    required AsyncValueGetter<R> task,
    FetcherConfig? config,
    bool fetchAtInit = true,
    WidgetBuilder? initBuilder,
    DataWidgetBuilder<R>? builder,
    ValueSetter<R>? onSuccess,
    ValueGetter<R?>? getFromCache,
    ValueChanged<R>? saveToCache,
    AsyncTaskBuilderController<void, R>? controller,
  }) {
    return AsyncTaskBuilder<void, R>._(
      key: key,
      mode: AsyncTaskMode.fetch,
      task: ([_]) => task(),
      config: config,
      fetchAtInit: fetchAtInit,
      initBuilder: initBuilder,
      builder: builder,
      onSuccess: onSuccess,
      getFromCache: getFromCache,
      saveToCache: saveToCache,
      controller: controller,
    );
  }

  factory AsyncTaskBuilder.fetch({
    Key? key,
    required AsyncValueGetter<R> task,
    FetcherConfig? config,
    bool fetchAtInit = true,
    WidgetBuilder? initBuilder,
    DataWidgetBuilder<R>? builder,
    ValueSetter<R>? onSuccess,
    ValueGetter<R?>? getFromCache,
    ValueChanged<R>? saveToCache,
    AsyncTaskBuilderController<void, R>? controller,
  }) {
    return AsyncTaskBuilder<T, R>._(
      key: key,
      mode: AsyncTaskMode.fetch,
      task: ([_]) => task(),
      config: config,
      fetchAtInit: fetchAtInit,
      initBuilder: initBuilder,
      builder: builder,
      onSuccess: onSuccess,
      getFromCache: getFromCache,
      saveToCache: saveToCache,
      controller: controller as AsyncTaskBuilderController<T, R>?,
    );
  }

  factory AsyncTaskBuilder.fetchWithParameter({
    Key? key,
    required ParameterizedAsyncTask<T, R> task,
    FetcherConfig? config,
    bool fetchAtInit = true,
    WidgetBuilder? initBuilder,
    DataWidgetBuilder<R>? builder,
    ValueSetter<R>? onSuccess,
    ValueGetter<R?>? getFromCache,
    ValueChanged<R>? saveToCache,
    AsyncTaskBuilderController<T, R>? controller,
  }) {
    return AsyncTaskBuilder<T, R>._(
      key: key,
      mode: AsyncTaskMode.fetchWithParameter,
      task: task,
      config: config,
      fetchAtInit: fetchAtInit,
      initBuilder: initBuilder,
      builder: builder,
      onSuccess: onSuccess,
      getFromCache: getFromCache,
      saveToCache: saveToCache,
      controller: controller,
    );
  }

  factory AsyncTaskBuilder.submit({
    Key? key,
    required AsyncValueGetter<R> task,
    required SubmitChildBuilder<R> builder,
    FetcherConfig? config,
    Color? barrierColor,
    ValueSetter<R>? onSuccess,
    AsyncTaskBuilderController<T, R>? controller,
    bool runTaskOnStart = false,
  }) {
    return AsyncTaskBuilder<T, R>._(
      key: key,
      mode: AsyncTaskMode.submit,
      task: ([_]) => task(),
      config: config,
      barrierColor: barrierColor,
      submitBuilder: builder,
      onSuccess: onSuccess,
      controller: controller,
      fetchAtInit: runTaskOnStart,
    );
  }

  @override
  State<AsyncTaskBuilder<T, R>> createState() => _AsyncTaskBuilderState<T, R>();
}

class _AsyncTaskBuilderState<T, R> extends State<AsyncTaskBuilder<T, R>> {
  late final FetcherConfig config = DefaultFetcherConfig.of(context).apply(widget.config);
  EventStream<DataWrapper<R>?>? _stream;
  bool _isBusy = false;
  int _lastTaskId = 0;

  @override
  void initState() {
    super.initState();
    widget.controller?._mountState(this);
    if (widget.mode != AsyncTaskMode.submit && widget.fetchAtInit) {
      _initStream();
      _fetch();
    }
  }

  EventStream<DataWrapper<R>?> _initStream() {
    if (_stream == null) {
      setState(() {
        _stream = EventStream<DataWrapper<R>?>();
      });

      if (widget.getFromCache != null) {
        try {
          final cachedData = widget.getFromCache!();
          if (cachedData != null) {
            _stream!.add(DataWrapper(cachedData));
          }
        } catch (e, s) {
          config.onError!(e, s);
        }
      }
    }
    return _stream!;
  }

  Future<void> _fetch({T? param, bool? clearDataFirst, FetchErrorDisplayMode? errorDisplayMode}) async {
    final taskId = ++_lastTaskId;
    if (!mounted) return;

    final stream = _initStream();
    clearDataFirst ??= stream.hasError;
    if (clearDataFirst) stream.add(null);

    try {
      final result = await widget.task(param);
      if (mounted && taskId == _lastTaskId) {
        widget.onSuccess?.call(result);
        widget.saveToCache?.call(result);
        stream.add(DataWrapper(result));
      }
    } catch (e, s) {
      config.onError!(e, s);
      if (mounted && taskId == _lastTaskId) {
        errorDisplayMode ??= FetchErrorDisplayMode.inWidget;
        final inWidget = errorDisplayMode == FetchErrorDisplayMode.inWidget || stream.valueOrNull == null;
        final onDisplay = errorDisplayMode == FetchErrorDisplayMode.onDisplay;

        if (inWidget) {
          stream.addError(FetchException(e, () => _fetch(param: param, errorDisplayMode: FetchErrorDisplayMode.onDisplay)));
        }
        if (onDisplay) {
          config.onDisplayError!(context, e);
        }
      }
    }
  }

  void _runTask([AsyncValueGetter<R>? task]) async {
    if (!mounted || _isBusy) return;

    setState(() => _isBusy = true);

    try {
      final result = await (task ?? (() => widget.task(null)))();
      if (mounted) widget.onSuccess?.call(result);
    } catch (e, s) {
      config.onError?.call(e, s);
      if (mounted) config.onDisplayError?.call(context, e);
    }

    if (mounted) setState(() => _isBusy = false);
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.mode) {
      case AsyncTaskMode.submit:
        return SubmitBuilder<R>(
          config: widget.config,
          barrierColor: widget.barrierColor,
          runTaskOnStart: widget.fetchAtInit,
          task: () => widget.task(null),
          builder: widget.submitBuilder!,
          onSuccess: widget.onSuccess,
        );

      case AsyncTaskMode.fetch:
      case AsyncTaskMode.fetchWithParameter:
        return EventStreamBuilder<DataWrapper<R>?>(
          stream: _stream,
          builder: (context, snapshot) {
            return FetchBuilderContent<R>(
              config: config,
              snapshot: snapshot.data == null
                  ? AsyncSnapshot<R>.nothing()
                  : AsyncSnapshot<R>.withData(
                      snapshot.connectionState,
                      snapshot.data!.data,
                    ),
              initBuilder: widget.initBuilder,
              builder: widget.builder,
            );
          },
        );
    }
  }

  @override
  void dispose() {
    widget.controller?._unmountState(this);
    _stream?.close();
    super.dispose();
  }
}

class AsyncTaskBuilderController<T, R> {
  _AsyncTaskBuilderState<T, R>? _state;

  void _mountState(_AsyncTaskBuilderState<T, R> state) => _state = state;

  void _unmountState(_AsyncTaskBuilderState<T, R> state) {
    if (_state == state) _state = null;
  }

  Future<void> refresh({T? param, bool? clearDataFirst, FetchErrorDisplayMode? errorDisplayMode}) {
    return _state?._fetch(param: param, clearDataFirst: clearDataFirst, errorDisplayMode: errorDisplayMode) ?? Future.value();
  }

  void runTask([AsyncValueGetter<R>? task]) => _state?._runTask(task);

  static AsyncTaskBuilderController<void, R> basic<R>() {
    return AsyncTaskBuilderController<void, R>();
  }
}
