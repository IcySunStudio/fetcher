import 'package:fetcher/src/widgets/fetch_builder_error_widget.dart';
import 'package:flutter/material.dart';

@immutable
class FetcherConfig {
  const FetcherConfig({
    this.isDense,
    this.fade,
    this.fadeDuration,
    this.fetchingBuilder,
    this.errorBuilder,
    this.reportError,
    this.showError,
  });

  /// Whether fetcher is in a low space environment.
  /// Will affect default error widget density.
  final bool? isDense;

  /// Whether to enable a fading transition between states
  final bool? fade;

  /// Duration of the [fade] transition
  final Duration? fadeDuration;

  /// Widget to display while fetching
  final WidgetBuilder? fetchingBuilder;

  /// Widget to display on error
  final Widget Function(BuildContext context, bool isDense, VoidCallback retry)? errorBuilder;

  ///
  final void Function(Object exception, StackTrace stack, {dynamic reason})? reportError;

  ///
  final void Function(BuildContext context, Object error)? showError;

  /// Default [FetcherConfig] values.
  static FetcherConfig defaultConfig = FetcherConfig(
    isDense: false,
    fade: true,
    fadeDuration: const Duration(milliseconds: 250),
    fetchingBuilder: (_) => const Center(
      child: CircularProgressIndicator(),
    ),
    errorBuilder: (_, isDense, retry) => FetchBuilderErrorWidget(isDense: isDense, onRetry: retry),
    reportError: (e, s, {reason}) => debugPrint('[Fetcher] report error: $e'),
    showError: (_, error) => debugPrint('[Fetcher] display error: $error'),
  );

  /// Creates a copy of this config where each fields are overridden by each non-null field of [config].
  FetcherConfig apply(FetcherConfig? config) {
    if (config == null) return this;
    return FetcherConfig(
      isDense: config.isDense ?? isDense,
      fade: config.fade ?? fade,
      fadeDuration: config.fadeDuration ?? fadeDuration,
      fetchingBuilder: config.fetchingBuilder ?? fetchingBuilder,
      errorBuilder: config.errorBuilder ?? errorBuilder,
      reportError: config.reportError ?? reportError,
      showError: config.showError ?? showError,
    );
  }
}

