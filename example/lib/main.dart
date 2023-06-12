
import 'package:example/pages/event_fetch_builder.page.dart';
import 'package:example/pages/fetch_builder.page.dart';
import 'package:flutter/material.dart';
import 'package:fetcher/fetcher.dart';

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
        onDisplayError: (context, error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.toString()),
        )),
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fetcher Example'),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.download),
            label: 'FetchBuilder',
          ),
          NavigationDestination(
            icon: Icon(Icons.sync),
            label: 'EventFetchBuilder',
          ),
        ],
      ),
      body: <Widget>[
        const FetchBuilderPage(),
        const EventFetchBuilderPage(),
      ][currentPageIndex],
    );
  }
}
