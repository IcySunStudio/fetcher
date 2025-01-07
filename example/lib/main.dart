import 'package:example/utils/message.dart';
import 'package:flutter/material.dart';
import 'package:fetcher/fetcher.dart';

import 'news_reader/news_reader.page.dart';
import 'widgets/widget_examples.page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Global key for the App's main navigator
  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  /// The [BuildContext] of the main navigator.
  static BuildContext get navigatorContext => _navigatorKey.currentContext!;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DefaultFetcherConfig(
      config: FetcherConfig(
        fetchingBuilder: (context) => const Center(child: CircularProgressIndicator(color: Colors.red)),
        onUnsavedFormPop: _askPopConfirmation,
        onDisplayError: (context, error) => showMessage(context, error.toString(), backgroundColor: Colors.red),
      ),
      child: MaterialApp(
        title: 'Fetcher Example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        navigatorKey: _navigatorKey,
        home: const MyHomePage(),
      ),
    );
  }

  Future<bool?> _askPopConfirmation() => showDialog<bool>(
    context: navigatorContext,    // Need to use a context with Material data
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Any unsaved changes will be lost!'),
        actions: <Widget>[
          TextButton(
            child: const Text('Yes, discard my changes'),
            onPressed: () => Navigator.pop(context, true),
          ),
          TextButton(
            child: const Text('No, continue editing'),
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      );
    },
  );
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fetcher Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // News reader example
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NewsReaderPage(page: 1))),
              child: const Text('News reader example'),
            ),

            // Widget examples
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const WidgetExamplesPage())),
              child: const Text('Widget examples'),
            ),
          ],
        ),
      ),
    );
  }
}
