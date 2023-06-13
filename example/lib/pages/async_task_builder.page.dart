import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';

class AsyncTaskBuilderPage extends StatelessWidget {
  const AsyncTaskBuilderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AsyncTaskBuilder<String>(
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
    );
  }
}
