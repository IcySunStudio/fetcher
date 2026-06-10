import 'dart:async';

import 'package:fetcher/fetcher_bloc.dart';
import 'package:flutter/material.dart';

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
        // Caption
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'EventFetchBuilder listen to an EventStream and display data. '
                'It\'s like FetchBuilder but instead of directly calling a task once, it will listen to a stream and his updates. '
                'Handle all possible states: loading, loaded, errors.\n'
                'This example fetches the current time every 5 seconds, and display it. It also display a nullable stream that emit null and int values.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),

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

  late final animalStream = EventStream<String>();
  static const _animalValues = ['Cat', 'Dog', 'Elephant', 'Lion', 'Tiger', 'Giraffe', 'Zebra', 'Penguin'];
  int _animalIndex = 0;

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
    animalStream.add(_animalValues[_animalIndex++ % _animalValues.length], skipIfClosed: true);
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
                    'Fetched data:',
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
                    'Fetched nullable data:',
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
        const Separator(),
        Padding(
          padding: const EdgeInsets.all(20),
          child: EventFetchBuilder<String>(
            stream: animalStream,
            config: const FetcherConfig(
              fadeOnDataChange: false,
            ),
            builder: (context, data) => _HeavyInitWidget(data: data),
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
    animalStream.close();
    super.dispose();
  }
}

/// A stateful widget that simulates a heavy one-time initialisation (2 seconds),
/// then updates its display via [didUpdateWidget] when [data] changes —
/// without re-running the expensive init.
///
/// Used to demonstrate that the fade animation must NOT destroy the subtree
/// on data updates: [_initCount] must stay at 1 and [_computedValue] must
/// persist across animal changes.
class _HeavyInitWidget extends StatefulWidget {
  const _HeavyInitWidget({required this.data});

  final String data;

  @override
  State<_HeavyInitWidget> createState() => _HeavyInitWidgetState();
}

class _HeavyInitWidgetState extends State<_HeavyInitWidget> {
  /// Simulates a value computed once during heavy init
  String? _computedValue;

  @override
  void initState() {
    super.initState();
    // Simulate heavy one-time computation
    final initialData = widget.data;
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _computedValue = '$initialData + 42';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Stateful widget',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          'keep state while fading between data updates',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Input value: ${widget.data}',
          textAlign: TextAlign.center,
        ),
        Text(
          'State value: ${_computedValue ?? 'computing…'}',
          textAlign: TextAlign.center,
          style: TextStyle(color: _computedValue != null ? Colors.green : Colors.orange),
        ),
      ],
    );
  }
}
