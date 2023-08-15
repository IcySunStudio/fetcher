import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';

class AsyncTaskBuilderPage extends StatefulWidget {
  const AsyncTaskBuilderPage({super.key});

  @override
  State<AsyncTaskBuilderPage> createState() => _AsyncTaskBuilderPageState();
}

class _AsyncTaskBuilderPageState extends State<AsyncTaskBuilderPage> {
  int _refreshKey = 0;
  bool _runTaskOnStart = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // Settings
        CheckboxListTile(
          title: const Text('Run task on start'),
          subtitle: const Text('Automatically refresh widget on changes'),
          value: _runTaskOnStart,
          onChanged: (value) {
            setState(() {
              _runTaskOnStart = value!;
              _refreshKey++;
            });
          },
        ),

        // Content
        Expanded(
          child: AsyncTaskBuilder<String>(
            key: ValueKey(_refreshKey),
            runTaskOnStart: _runTaskOnStart,
            task: () => Future.delayed(const Duration(seconds: 2), () => 'success'),
            onSuccess: (result) async => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(result),
            )),
            builder: (context, runTask) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [

                  // Basic run
                  Center(
                    child: ElevatedButton(
                      onPressed: runTask,
                      child: const Text('Press to start task'),
                    ),
                  ),

                  // Run with error
                  Center(
                    child: ElevatedButton(
                      onPressed: () => runTask(() async {
                        await Future.delayed(const Duration(seconds: 1));
                        throw Exception('Error !');
                      }),
                      child: const Text('Press to start with error'),
                    ),
                  ),

                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
