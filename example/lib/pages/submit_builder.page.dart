import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';

import 'fetch_builder.page.dart';

class SubmitBuilderPage extends StatefulWidget {
  const SubmitBuilderPage({super.key});

  @override
  State<SubmitBuilderPage> createState() => _SubmitBuilderPageState();
}

class _SubmitBuilderPageState extends State<SubmitBuilderPage> {
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

        // Classic SubmitBuilder
        Expanded(
          child: SubmitBuilder<String>(
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

        // Very small context, override barrierColor to transparent for proper clipping
        const Separator(),
        Padding(
          padding: const EdgeInsets.all(20),
          child: SubmitBuilder<void>(
            task: () => Future.delayed(const Duration(seconds: 3)),
            onSuccess: (_) async => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Success !'),
            )),
            barrierColor: Colors.transparent,
            builder: (context, runTask) {
              return FloatingActionButton(
                mini: true,
                onPressed: runTask,
                backgroundColor: Colors.green,
                child: const Icon(Icons.run_circle_outlined),
              );
            },
          ),
        ),
      ],
    );
  }
}
