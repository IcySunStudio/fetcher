import 'package:flutter/material.dart';
import 'package:fetcher/fetcher.dart';

import 'news_reader/news_reader.page.dart';
import 'widgets/widget_examples.page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DefaultFetcherConfig(
      config: FetcherConfig(
        fetchingBuilder: (context) => const Center(child: CircularProgressIndicator(color: Colors.red)),
        onDisplayError: (context, error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
        )),
        onFetchSuccess: (result) => debugPrint('[FetchSuccess] Fetch success with result: $result'),
      ),
      child: MaterialApp(
        title: 'Fetcher Example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
      ),
    );
  }
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
