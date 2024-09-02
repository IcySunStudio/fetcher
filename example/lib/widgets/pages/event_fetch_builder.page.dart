import 'dart:async';

import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:value_stream/value_stream.dart';

import 'fetch_builder.page.dart';

class EventFetchBuilderPage extends StatefulWidget {
  const EventFetchBuilderPage({super.key});

  @override
  State<EventFetchBuilderPage> createState() => _EventFetchBuilderPageState();
}

class _EventFetchBuilderPageState extends State<EventFetchBuilderPage> {
  int _refreshKey = 0;
  bool withInitialValue = false;
  bool withInitialError = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Settings
        CheckboxListTile(
          title: const Text('With initial value'),
          value: withInitialValue,
          onChanged: (value) {
            setState(() {
              withInitialValue = value!;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('With initial error'),
          value: withInitialError,
          onChanged: (value) {
            setState(() {
              withInitialError = value!;
            });
          },
        ),

        // Button
        ElevatedButton(
          onPressed: () {
            setState(() {
              _refreshKey++;
            });
          },
          child: const Text('Refresh'),
        ),

        // Content
        Expanded(
          child: _EventFetchBuilderPageContent(
            key: ValueKey(_refreshKey),
            initialValue: withInitialValue ? 'Initial value' : null,
            initialError: withInitialError ? Error() : null,
          ),
        ),
      ],
    );
  }
}

class _EventFetchBuilderPageContent extends StatefulWidget {
  const _EventFetchBuilderPageContent({super.key, this.initialValue, this.initialError});

  final String? initialValue;
  final Object? initialError;

  @override
  State<_EventFetchBuilderPageContent> createState() => _EventFetchBuilderPageContentState();
}

class _EventFetchBuilderPageContentState extends State<_EventFetchBuilderPageContent> {
  late final stream = EventStream<String>(widget.initialValue);

  late final nullableStream = EventStream<int?>();
  static const _nullableStreamValues = [ null, 1, 2, null, 3, null, 5, 6, 7, 8, null, 9];
  int _nullableStreamIndex = 0;

  Timer? _timer;

  Future<String> fetchTask() async {
    await Future.delayed(const Duration(seconds: 2));
    return DateTime.now().toString();
  }

  Future<void> tick() async {
    debugPrint('new fetch - starting');
    final value = await fetchTask();
    stream.add(value, skipIfClosed: true);
    nullableStream.add(_nullableStreamValues[_nullableStreamIndex++ % _nullableStreamValues.length], skipIfClosed: true);
    debugPrint('new fetch - over');
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialError != null) {
      stream.addError(widget.initialError!);
    } else {
      _timer = Timer.periodic(const Duration(seconds: 5), (timer) => tick());
      tick();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: EventFetchBuilder<String>(
            stream: stream,
            builder: (context, data) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Data is fetched :',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    data,
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ),
        const Separator(),
        Padding(
          padding: const EdgeInsets.all(20),
          child: EventFetchBuilder<int?>(
            stream: nullableStream,
            builder: (context, data) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Nullable data is fetched :',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    data?.toString() ?? 'null',
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    stream.close();
    nullableStream.close();
    super.dispose();
  }
}
