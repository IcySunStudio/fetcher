import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

typedef AsyncTask<T> = Future<T> Function();
typedef AsyncValueChanged<T> = Future<void> Function(T value);
typedef DataWidgetBuilder<T> = Widget Function(BuildContext context, T data);
typedef ParameterizedAsyncTask<T, R> = Future<R> Function(T? param);

extension ExtendedBehaviorSubject<T> on BehaviorSubject<T> {
  void tryAdd(T value) {
    if (!isClosed) {
      add(value);
    }
  }

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