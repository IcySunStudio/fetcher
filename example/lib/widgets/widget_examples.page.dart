import 'package:flutter/material.dart';

import 'pages/async_edit_builder.page.dart';
import 'pages/event_fetch_builder.page.dart';
import 'pages/fetch_builder.page.dart';
import 'pages/paged_fetcher_page.dart';
import 'pages/submit_builder.page.dart';
import 'pages/submit_form_builder.page.dart';

class WidgetExamplesPage extends StatefulWidget {
  const WidgetExamplesPage({super.key});

  @override
  State<WidgetExamplesPage> createState() => _WidgetExamplesPageState();
}

class _WidgetExamplesPageState extends State<WidgetExamplesPage> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widgets examples'),
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
            label: 'Fetch',
          ),
          NavigationDestination(
            icon: Icon(Icons.keyboard_double_arrow_down),
            label: 'Event',
          ),
          NavigationDestination(
            icon: Icon(Icons.upload),
            label: 'Submit',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_document),
            label: 'Form',
          ),
          NavigationDestination(
            icon: Icon(Icons.sync),
            label: 'Edit',
          ),
          NavigationDestination(
            icon: Icon(Icons.numbers),
            label: 'Paged',
          ),
        ],
      ),
      body: <Widget>[
        const FetchBuilderPage(),
        const EventFetchBuilderPage(),
        const SubmitBuilderPage(),
        const SubmitFormBuilderPage(),
        const AsyncEditBuilderPage(),
        const PagedFetcherPage(),
      ][currentPageIndex],
    );
  }
}
