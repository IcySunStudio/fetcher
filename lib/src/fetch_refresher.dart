part of 'fetch_builder.dart';

/// A widget that supports the Material "swipe to refresh" idiom (a.k.a pull-to-refresh) for [FetchBuilder].
/// When triggered, will automatically call [FetchBuilderControllerBase.refresh] for all [FetchBuilder] children.
///
/// In some case you should set [Scrollable]'s physics to AlwaysScrollableScrollPhysics
class FetchRefresher extends StatefulWidget {
  const FetchRefresher({
    super.key,
    this.controller,
    required this.child,
  });

  /// A controller used to programmatically refresh data.
  final FetchRefresherController? controller;

  /// The widget below this widget in the tree.
  ///
  /// The refresh indicator will be stacked on top of this child. The indicator
  /// will appear when child's Scrollable descendant is over-scrolled.
  ///
  /// Typically a [SingleChildScrollView], [ListView] or [CustomScrollView].
  final Widget child;

  /// Returns the closest [_FetchRefresherState] which encloses the given context.
  static _FetchRefresherState? _maybeOf(BuildContext context) => context.getInheritedWidgetOfExactType<_FetchRefresherScope>()?.refresherState;

  @override
  State<FetchRefresher> createState() => _FetchRefresherState();
}

class _FetchRefresherState extends State<FetchRefresher> {
  final refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  bool refreshing = false;

  final _fetchBuilders = <_FetchBuilderWithParameterState>{};

  void _register(_FetchBuilderWithParameterState refreshable) => _fetchBuilders.add(refreshable);

  void _unregister(_FetchBuilderWithParameterState refreshable) => _fetchBuilders.remove(refreshable);

  @override
  void initState() {
    super.initState();
    widget.controller?._mountState(this);
  }

  @override
  void didUpdateWidget(FetchRefresher oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller?._unmountState(this);
    widget.controller?._mountState(this);
  }

  /// Refresh all [FetchBuilder] children, while displaying a refresh indicator.
  Future<void> refresh() async => await refreshIndicatorKey.currentState?.show();

  Future<void> _onRefresh() async {
    if (refreshing) return;
    try {
      refreshing = true;
      await Future.wait(_fetchBuilders.map((fetchBuilder) => fetchBuilder._fetch()));
    } finally {
      refreshing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _FetchRefresherScope(
      refresherState: this,
      child: RefreshIndicator(
        key: refreshIndicatorKey,
        onRefresh: _onRefresh,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    widget.controller?._unmountState(this);
    super.dispose();
  }
}

class _FetchRefresherScope extends InheritedWidget {
  const _FetchRefresherScope({
    required this.refresherState,
    required super.child,
  });

  final _FetchRefresherState refresherState;

  @override
  bool updateShouldNotify(_FetchRefresherScope old) => refresherState != old.refresherState;
}

/// A controller for an [FetchRefresher].
class FetchRefresherController {
  _FetchRefresherState? _state;

  void _mountState(_FetchRefresherState state) {
    _state = state;
  }

  void _unmountState(_FetchRefresherState state) {
    /// When a widget is rebuilt with another key,
    /// the state of the new widget is first initialised,
    /// then the state of the old widget is disposed.
    /// So we need to unmount state only if it hasn't changed since.
    if (_state == state) {
      _state = null;
    }
  }

  /// Refresh all [FetchBuilder] children, while displaying a refresh indicator.
  Future<void> refresh() => _state!.refresh();
}