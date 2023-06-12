import 'package:flutter/foundation.dart';

class FetchException {
  const FetchException(this.innerException, this.retry);

  final Object innerException;
  final VoidCallback retry;
}
