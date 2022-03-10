import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fetcher/fetcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  Future<String> fetchTask() async {
    final response = await http.get(Uri.parse('http://worldtimeapi.org/api/timezone/Europe/Paris'));
    await Future.delayed(const Duration(seconds: 2));
    return json.decode(response.body)['datetime'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fetcher Example'),
      ),
      body: FetchBuilder.basic<String>(
        task: fetchTask,
        builder: (context, data) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Data is fetched :',
                style: Theme.of(context).textTheme.subtitle1,
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
    );
  }
}
