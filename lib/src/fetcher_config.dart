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
  final Widget Function(BuildContext context, bool isDense, VoidCallback retry)? errorBuilder;

  ///
  final void Function(Object exception, StackTrace stack, {dynamic reason})? reportError;

  ///
  final void Function(BuildContext context, Object error)? showError;


  static FetcherConfig defaultConfig = FetcherConfig(
    fetchingBuilder: (_) => const Center(
      child: CircularProgressIndicator(),
    ),
    fadeDuration: const Duration(milliseconds: 250),
    errorBuilder: (_, isDense, retry) => FetchBuilderErrorWidget(isDense: isDense, onRetry: retry),
    reportError: (e, s, {reason}) => debugPrint('[Fetcher] report error: $e'),
    showError: (_, error) => debugPrint('[Fetcher] display error: $error'),
  );

  /// Creates a copy of this config where each fields are overridden by each non-null field of [config].
  FetcherConfig apply(FetcherConfig? config) {
    if (config == null) return this;
    return FetcherConfig(
      fetchingBuilder: config.fetchingBuilder ?? fetchingBuilder,
      fadeDuration: config.fadeDuration ?? fadeDuration,
      errorBuilder: config.errorBuilder ?? errorBuilder,
      reportError: config.reportError ?? reportError,
      showError: config.showError ?? showError,
    );
  }
}

