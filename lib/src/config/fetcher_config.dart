import 'package:fetcher/src/widgets/fetch_builder_error_widget.dart';
import 'package:flutter/material.dart';

@immutable
class FetcherConfig {
  const FetcherConfig({
    this.isDense,
    this.fade,
    this.fadeDuration,
    this.fetchingBuilder,
    this.fetchErrorBuilder,
    this.onError,
    this.onDisplayError,
  });

  /// Whether fetcher is in a low space environment.
  /// Will affect default error widget density.
  final bool? isDense;

  /// Whether to enable a fading transition between states.
  final bool? fade;

  /// Duration of the [fade] transition.
  final Duration? fadeDuration;

  /// Widget to display while fetching.
  final WidgetBuilder? fetchingBuilder;

  /// Widget to display on fetch error.
  /// Replace whole widget content.
  /// Default to [FetchBuilderErrorWidget], includes a retry button.
  final Widget Function(BuildContext context, bool isDense, VoidCallback? retry)? fetchErrorBuilder;

  /// Called when an error occurred.
  /// Usually used to report error.
  final void Function(Object exception, StackTrace stack, {dynamic reason})? onError;

  /// Called when an error should be displayed to user.
  /// Usually used with a SnackBar system or equivalent.
  final void Function(BuildContext context, Object error)? onDisplayError;

  /// Default [FetcherConfig] values.
  static FetcherConfig defaultConfig = FetcherConfig(
    isDense: false,
    fade: true,
    fadeDuration: const Duration(milliseconds: 250),
    fetchingBuilder: (_) => const Center(
      child: CircularProgressIndicator(),
    ),
    fetchErrorBuilder: (_, isDense, retry) => FetchBuilderErrorWidget(isDense: isDense, onRetry: retry),
    onError: (e, s, {reason}) => debugPrint('[Fetcher] onError: $e'),
    onDisplayError: (_, error) => debugPrint('[Fetcher] onDisplayError: $error'),
  );

  /// Creates a copy of this config where each fields are overridden by each non-null field of [config].
  FetcherConfig apply(FetcherConfig? config) {
    if (config == null) return this;
    return FetcherConfig(
      isDense: config.isDense ?? isDense,
      fade: config.fade ?? fade,
      fadeDuration: config.fadeDuration ?? fadeDuration,
      fetchingBuilder: config.fetchingBuilder ?? fetchingBuilder,
      fetchErrorBuilder: config.fetchErrorBuilder ?? fetchErrorBuilder,
      onError: config.onError ?? onError,
      onDisplayError: config.onDisplayError ?? onDisplayError,
    );
  }
}

