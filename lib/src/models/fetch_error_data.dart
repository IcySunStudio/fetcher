import 'package:flutter/foundation.dart';

class FetchErrorData {
  const FetchErrorData(this.exception, this.isDense, this.retry);

  final Object exception;
  final bool isDense;
  final VoidCallback? retry;
}
