import 'package:fetcher/src/models/fetch_error_data.dart';
import 'package:fetcher/src/widgets/fetch_builder_error_widget.dart';
import 'package:flutter/widgets.dart';

/// Configuration for fetcher widgets.
@immutable
class FetcherConfig {
  /// Creates a new fetcher configuration.
  const FetcherConfig({
    this.isDense,
    this.fadeDuration,
    this.fetchingBuilder,
    this.fetchErrorBuilder,
    this.onUnsavedFormPop,
    this.onError,
    this.onDisplayError,
    this.onFetchSuccess,
  });

  /// Fetcher configuration for silent mode.
  /// Use this configuration to hide loader & error.
  FetcherConfig.silent({bool? fade, Duration? fadeDuration}) : this(
    isDense: true,
    fadeDuration: fadeDuration,
    fetchingBuilder: (_) => const SizedBox(),
    fetchErrorBuilder: (_, __) => const SizedBox(),
    onDisplayError: (_, __) {},
  );

  /// Whether fetcher is in a low space environment.
  /// Will affect default error widget density.
  final bool? isDense;

  /// Duration of the fade transition.
  /// Use [Duration.zero] to disable fade transition.
  ///
  /// It is recommended to use a value that is roughly the duration of the navigation transition, to ensure proper screen transition animation.
  /// (If it's lower, you may see the non-loading state before next page is displayed).
  /// (If it's higher, you may see the loading state for a short time when page is popped (because animation is paused when a route is displayed above)).
  final Duration? fadeDuration;

  /// Widget to display while fetching.
  final WidgetBuilder? fetchingBuilder;

  /// Widget to display on fetch error.
  /// Replace whole widget content.
  /// [FetchErrorData] contains useful data about the error, like a retry function (only available on [FetchBuilder]).
  /// Default to [FetchBuilderErrorWidget], includes a retry button.
  final Widget Function(BuildContext context, FetchErrorData errorData)? fetchErrorBuilder;

  /// On a page with [SubmitFormBuilder], called when current route tries to pop with unsaved form changes.
  /// Return `true` to allow pop, `false` or `null` to prevent pop.
  /// Usually used to show a dialog to confirm pop.
  /// If null (default), always allow pop (behavior disabled).
  /// Current implementation just track if form has been modified (calling [Form.save()] doesn't reset status).
  final Future<bool?> Function()? onUnsavedFormPop;

  /// Called when an error occurred.
  /// Usually used to report error.
  final void Function(Object exception, StackTrace stack, {dynamic reason})? onError;

  /// Called when an error should be displayed to user.
  /// Usually used with a SnackBar system or equivalent.
  final void Function(BuildContext context, Object error)? onDisplayError;

  /// Called when any [FetchBuilder]'s task ends successfully.
  /// Can be used to add cross-cutting concerns like logging, analytics, or custom behaviors
  final void Function(dynamic result)? onFetchSuccess;

  /// Creates a copy of this config where each fields are overridden by each non-null field of [config].
  FetcherConfig apply(FetcherConfig? config) {
    if (config == null) return this;
    return FetcherConfig(
      isDense: config.isDense ?? isDense,
      fadeDuration: config.fadeDuration ?? fadeDuration,
      fetchingBuilder: config.fetchingBuilder ?? fetchingBuilder,
      fetchErrorBuilder: config.fetchErrorBuilder ?? fetchErrorBuilder,
      onUnsavedFormPop: config.onUnsavedFormPop ?? onUnsavedFormPop,
      onError: config.onError ?? onError,
      onDisplayError: config.onDisplayError ?? onDisplayError,
      onFetchSuccess: config.onFetchSuccess ?? onFetchSuccess,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FetcherConfig
        && other.isDense == isDense
        && other.fadeDuration == fadeDuration
        && other.fetchingBuilder == fetchingBuilder
        && other.fetchErrorBuilder == fetchErrorBuilder
        && other.onUnsavedFormPop == onUnsavedFormPop
        && other.onError == onError
        && other.onDisplayError == onDisplayError
        && other.onFetchSuccess == onFetchSuccess;
  }

  @override
  int get hashCode =>
      isDense.hashCode ^
      fadeDuration.hashCode ^
      fetchingBuilder.hashCode ^
      fetchErrorBuilder.hashCode ^
      onUnsavedFormPop.hashCode ^
      onError.hashCode ^
      onDisplayError.hashCode ^
      onFetchSuccess.hashCode;
}
