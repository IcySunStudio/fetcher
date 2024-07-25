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
  Future<void> validateForm({VoidCallback? onSuccess}) async {
    clearFocus();
    final form = Form.maybeOf(this);
    if (form == null) return;

    if (form.validate()) {
      form.save();
      onSuccess?.call();
    }
  }
}
