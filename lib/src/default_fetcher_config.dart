import 'package:fetcher/src/fetcher_config.dart';
import 'package:flutter/widgets.dart';

class DefaultFetcherConfig extends InheritedWidget {
  DefaultFetcherConfig({
    super.key,
    required FetcherConfig config,
    required super.child,
  }) : config = FetcherConfig.defaultConfig.apply(config);

  final FetcherConfig config;

  /// Returns the closest [FetcherConfig] which encloses the given context.
  /// If not found, return [FetcherConfig.defaultConfig].
  static FetcherConfig of(BuildContext context) =>
      context.findAncestorWidgetOfExactType<DefaultFetcherConfig>()?.config ?? FetcherConfig.defaultConfig;

  @override
  bool updateShouldNotify(covariant DefaultFetcherConfig oldWidget) => config != oldWidget.config;
}
