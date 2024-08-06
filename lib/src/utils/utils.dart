import 'package:flutter/widgets.dart';

typedef ParameterizedAsyncTask<T, R> = Future<R> Function(T? param);

extension ExtendedBuildContext on BuildContext {
  /// Clear current context focus.
  /// This is the cleanest, official way.
  void clearFocus() => FocusScope.of(this).unfocus();

  /// Clear current context focus (Second method)
  /// Use this method if [clearFocus] doesn't work.
  void clearFocus2() => FocusScope.of(this).requestFocus(FocusNode());

  /// Validate the enclosing [Form]
  void validateForm({VoidCallback? onSuccess}) {
    // Clear current focus
    clearFocus();

    // Find closest Form ancestor
    // Throw if no Form ancestor is found
    final form = Form.of(this);

    // Validate form
    if (form.validate()) {
      form.save();
      onSuccess?.call();
    }
  }
}
