import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
        showError: (context, error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
  final _fetchController = ParameterizedFetchBuilderController<bool, String>();

  bool withError = false;
  bool dataClear = false;

  Future<String> fetchTask(bool? withError) async {
    final response = await http.get(Uri.parse('http://worldtimeapi.org/api/timezone/Europe/Paris'));
    await Future.delayed(const Duration(seconds: 2));
    if (withError == true) throw Exception('Error !');
    return json.decode(response.body)['datetime'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fetcher Example'),
      ),
      body: Column(
        children: [

          // Header
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text('Fetcher with parameters'),
          ),

          // Settings
          CheckboxListTile(
            title: const Text('Clear data first'),
            value: dataClear,
            onChanged: (value) {
              setState(() {
                dataClear = value!;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('With error'),
            value: withError,
            onChanged: (value) {
              setState(() {
                withError = value!;
              });
            },
          ),

          // Buttons
          ElevatedButton(
            onPressed: () => _fetchController.refresh(clearDataFirst: dataClear, param: withError),
            child: const Text('Refresh'),
          ),

          // Fetcher
          Expanded(
            child: FetchBuilder<bool, String>.parameterized(
              controller: _fetchController,
              task: fetchTask,
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
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text('Dense Fetcher with Error'),
          ),
          FetchBuilder.basic<String>(
            task: () async => throw Exception('Error !!'),
            isDense: true,
            builder: (context, data) => throw StateError('Should never reach this code'),
          ),
        ],
      ),
    );
  }
}

class Separator extends StatelessWidget {
  const Separator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: Colors.grey,
    );
  }
}
