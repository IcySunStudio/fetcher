import 'package:fetcher/src/widgets/fetch_builder_error_widget.dart';
import 'package:flutter/material.dart';

@immutable
class FetcherConfig {
  const FetcherConfig({
    this.fetchingBuilder,
    this.fadeDuration,
    this.errorBuilder,
    this.reportError,
    this.showError,
  });

  /// Widget to display while fetching
  final WidgetBuilder? fetchingBuilder;

  ///
  final Duration? fadeDuration;

  /// [FetchBuilder] only
  final Widget Function(BuildContext context, VoidCallback retry)? errorBuilder;

  ///
  final void Function(Object exception, StackTrace stack, {dynamic reason})? reportError;

  ///
  final void Function(BuildContext context, Object error)? showError;


  static FetcherConfig defaultConfig = FetcherConfig(
    fetchingBuilder: (_) => const AspectRatio(
      aspectRatio: 1,   // Needed when inside a tiny space
      child: Center(
        child: CircularProgressIndicator(),
      ),
    ),
    fadeDuration: const Duration(milliseconds: 250),
    errorBuilder: (_, retry) => FetchBuilderErrorWidget(onRetry: retry),
    reportError: (e, s, {reason}) => debugPrint('[Fetcher] report error: $e'),
    showError: (_, error) => debugPrint('[Fetcher] display error: $error'),
  );

  FetcherConfig applyDefaults(FetcherConfig defaultConfig) {
    return FetcherConfig(
      fetchingBuilder: fetchingBuilder ?? defaultConfig.fetchingBuilder,
      fadeDuration: fadeDuration ?? defaultConfig.fadeDuration,
      errorBuilder: errorBuilder ?? defaultConfig.errorBuilder,
      reportError: reportError ?? defaultConfig.reportError,
      showError: showError ?? defaultConfig.showError,
    );
  }
}

