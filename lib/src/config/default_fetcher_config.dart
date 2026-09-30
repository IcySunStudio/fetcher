import 'package:fetcher/src/config/fetcher_config.dart';
import 'package:flutter/material.dart';

class DefaultFetcherConfig extends InheritedWidget {
  DefaultFetcherConfig({
    super.key,
    required FetcherConfig config,
    required super.child,
  }) : config = FetcherConfig.defaultConfig.apply(config);

  final FetcherConfig config;

  /// Returns the closest [FetcherConfig] which encloses the given context.
  /// If not found, return [FetcherConfig.defaultConfig].
  /// [context] will be rebuilt when the config changes.
  static FetcherConfig of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<DefaultFetcherConfig>()?.config ?? FetcherConfig.defaultConfig;

  /// Default [FetcherConfig] values.
  static FetcherConfig get defaultConfig => FetcherConfig.defaultConfig;

  @override
  bool updateShouldNotify(covariant DefaultFetcherConfig oldWidget) => config != oldWidget.config;
}
