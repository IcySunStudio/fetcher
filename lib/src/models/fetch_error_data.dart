import 'package:flutter/foundation.dart';

/// Fetch error data
class FetchErrorData {
  const FetchErrorData(this.error, this.isDense, this.retry);

  /// Error object
  final Object error;

  /// Whether the widget context is in a low space environment
  final bool isDense;

  /// Function to call to retry the fetch
  /// Only available on [FetchBuilder]
  final VoidCallback? retry;
}
