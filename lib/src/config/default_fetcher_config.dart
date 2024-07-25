import 'package:fetcher/src/config/fetcher_config.dart';
import 'package:fetcher/src/widgets/fetch_builder_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DefaultFetcherConfig extends InheritedWidget {
  DefaultFetcherConfig({
    super.key,
    required FetcherConfig config,
    required super.child,
  }) : config = defaultConfig.apply(config);

  final FetcherConfig config;

  /// Returns the closest [FetcherConfig] which encloses the given context.
  /// If not found, return [FetcherConfig.defaultConfig].
  static FetcherConfig of(BuildContext context) => context.getInheritedWidgetOfExactType<DefaultFetcherConfig>()?.config ?? defaultConfig;

  /// Default [FetcherConfig] values.
  static FetcherConfig defaultConfig = FetcherConfig(
    isDense: false,
    fade: true,
    fadeDuration: const Duration(milliseconds: 250),
    fetchingBuilder: (_) => const Center(child: CircularProgressIndicator()),
    fetchErrorBuilder: (_, data) => FetchBuilderErrorWidget(isDense: data.isDense, onRetry: data.retry),
    onError: (e, s, {reason}) => debugPrint('[Fetcher] onError: $e'),
    onDisplayError: (_, error) => debugPrint('[Fetcher] onDisplayError: $error'),
  );

  @override
  bool updateShouldNotify(covariant DefaultFetcherConfig oldWidget) => config != oldWidget.config;
}
