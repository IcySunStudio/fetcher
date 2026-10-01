import 'package:fetcher/src/config/fetcher_config.dart';
import 'package:flutter/material.dart';

/// Provides a default [FetcherConfig] to all fetcher widgets below it.
///
/// [config] is merged with the one provided by the closest [DefaultFetcherConfig] ancestor
/// (or [FetcherConfig.defaultConfig] if none): only its non-null fields override the inherited ones.
///
/// Dependent widgets are rebuilt whenever the resulting config changes. As closures are compared by instance,
/// a [FetcherConfig] created in a `build` method with inline closures (like `fetchingBuilder: (context) => ...`)
/// is considered different on each build, which rebuilds all fetcher widgets below.
/// If the widget holding this [DefaultFetcherConfig] rebuilds often, create the config outside of `build`
/// (e.g. `static final`), or move this [DefaultFetcherConfig] higher in the tree.
class DefaultFetcherConfig extends StatelessWidget {
  const DefaultFetcherConfig({
    super.key,
    required this.config,
    required this.child,
  });

  /// Config to merge with the inherited one.
  final FetcherConfig config;

  /// The widget below this widget in the tree.
  final Widget child;

  /// Returns the [FetcherConfig] provided by the closest [DefaultFetcherConfig] which encloses the given context.
  /// If not found, return [FetcherConfig.defaultConfig].
  ///
  /// If [listen] is true (default), [context] will be rebuilt when the config changes.
  /// Use it when the config is used to build the widget (e.g. in `build` or `didChangeDependencies`).
  ///
  /// If [listen] is false, the config is only read once, without registering a dependency.
  /// Use it when the config is used outside of the build phase (e.g. in `initState` or in a callback like `onPressed`).
  static FetcherConfig of(BuildContext context, {bool listen = true}) {
    final inherited = listen
        ? context.dependOnInheritedWidgetOfExactType<_InheritedFetcherConfig>()
        : context.getInheritedWidgetOfExactType<_InheritedFetcherConfig>();
    return inherited?.config ?? FetcherConfig.defaultConfig;
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedFetcherConfig(
      config: DefaultFetcherConfig.of(context).merge(config),
      child: child,
    );
  }
}

class _InheritedFetcherConfig extends InheritedWidget {
  const _InheritedFetcherConfig({
    required this.config,
    required super.child,
  });

  /// Resolved config (merged with all ancestors).
  final FetcherConfig config;

  @override
  bool updateShouldNotify(_InheritedFetcherConfig oldWidget) => config != oldWidget.config;
}
