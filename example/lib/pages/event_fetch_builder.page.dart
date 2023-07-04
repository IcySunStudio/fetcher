import 'dart:async';

import 'package:example/pages/fetch_builder.page.dart';
import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';

class EventFetchBuilderPage extends StatefulWidget {
  const EventFetchBuilderPage({super.key});

  @override
  State<EventFetchBuilderPage> createState() => _EventFetchBuilderPageState();
}

class _EventFetchBuilderPageState extends State<EventFetchBuilderPage> {
  int _refreshKey = 0;
  bool withInitialValue = false;

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
          ),
        ),
      ],
    );
  }
}

class _EventFetchBuilderPageContent extends StatefulWidget {
  const _EventFetchBuilderPageContent({super.key, this.initialValue});

  final String? initialValue;

  @override
  State<_EventFetchBuilderPageContent> createState() => _EventFetchBuilderPageContentState();
}

class _EventFetchBuilderPageContentState extends State<_EventFetchBuilderPageContent> {
  late final stream = EventStream<String>(widget.initialValue);

  late final nullableStream = EventStream<int?>();
  static const _nullableStreamValues = [ null, 1, 2, null, 3, null, 5, 6, 7, 8, null, 9];
  int _nullableStreamIndex = 0;

  late final Timer timer;

  Future<String> fetchTask() async {
    await Future.delayed(const Duration(seconds: 2));
    return DateTime.now().toString();
  }

  Future<void> tick() async {
    print('new fetch - starting');
    final value = await fetchTask();
    stream.add(value, skipIfClosed: true);
    nullableStream.add(_nullableStreamValues[_nullableStreamIndex++ % _nullableStreamValues.length], skipIfClosed: true);
    print('new fetch - over');
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 5), (timer) => tick());
    tick();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: EventFetchBuilder<String>.fromEvent(
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
          child: EventFetchBuilder<int?>.fromEvent(
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
    timer.cancel();
    stream.close();
    nullableStream.close();
    super.dispose();
  }
}
