import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

typedef TaskRunnerCallback<T> = void Function([AsyncValueGetter<T>? task]);
typedef DataWidgetBuilder<T> = Widget Function(BuildContext context, T data);
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
    final form = Form.of(this);
    if (form == null) return;

    if (form.validate()) {
      form.save();
      onSuccess?.call();
    }
  }
}

extension ExtendedBehaviorSubject<T> on BehaviorSubject<T> {
  /// Sends a data event, only if subject is not closed.
  void tryAdd(T value) {
    if (!isClosed) {
      add(value);
    }
  }

  /// Sends a data event, only if [value] is not null.
  void addNotNull(T? value) {
    if (value != null) {
      add(value);
    }
  }

  /// Add [value] to subject only if it's different from the current value.
  /// Return true if [value] was added.
  bool addDistinct(T value) {
    if (value != this.value) {
      add(value);
      return true;
    }
    return false;
  }
}