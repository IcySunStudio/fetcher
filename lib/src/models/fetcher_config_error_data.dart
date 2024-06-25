import 'package:flutter/foundation.dart';

class FetcherConfigErrorData {
  const FetcherConfigErrorData(this.exception, this.isDense, this.retry);

  final Object exception;
  final bool isDense;
  final VoidCallback? retry;
}
