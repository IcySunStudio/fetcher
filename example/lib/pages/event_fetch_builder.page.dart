import 'dart:async';

import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';

class EventFetchBuilderPage extends StatefulWidget {
  const EventFetchBuilderPage({super.key});

  @override
  State<EventFetchBuilderPage> createState() => _EventFetchBuilderPageState();
}

class _EventFetchBuilderPageState extends State<EventFetchBuilderPage> {
  late final EventStream<String> stream;
  late final Timer timer;

  Future<String> fetchTask() async {
    await Future.delayed(const Duration(seconds: 2));
    return DateTime.now().toString();
  }

  Future<void> tick() async {
    print('new fetch - starting');
    final value = await fetchTask();
    stream.add(value, skipIfClosed: true);
    print('new fetch - over');
  }

  @override
  void initState() {
    super.initState();
    stream = EventStream();
    timer = Timer.periodic(const Duration(seconds: 5), (timer) => tick());
    tick();
  }

  @override
  Widget build(BuildContext context) {
    return EventFetchBuilder<String>(
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
    );
  }

  @override
  void dispose() {
    timer.cancel();
    stream.close();
    super.dispose();
  }
}
