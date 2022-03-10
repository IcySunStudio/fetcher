import 'package:flutter/widgets.dart';
import 'package:rxdart/streams.dart';

class ValueStreamBuilder<T> extends StreamBuilder<T> {
  ValueStreamBuilder({ Key? key, required ValueStream<T> stream, required AsyncWidgetBuilder<T> builder }) : super(
    key: key,
    stream: stream,
    initialData: stream.value,
    builder: builder,
  );
}
