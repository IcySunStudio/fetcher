import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FetchBuilderPage extends StatefulWidget {
  const FetchBuilderPage({super.key});

  @override
  State<FetchBuilderPage> createState() => _FetchBuilderPageState();
}

class _FetchBuilderPageState extends State<FetchBuilderPage> {
  final _fetchController1 = ParameterizedFetchBuilderController<bool, String>();
  final _fetchController2 = BasicFetchBuilderController<String>();

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
    return Column(
      children: [

        // Header
        const SizedBox(height: 20),
        const _Title(title: 'Fetcher with parameters'),

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

        // Button
        ElevatedButton(
          onPressed: () => _fetchController1.refresh(clearDataFirst: dataClear ? true : null, param: withError),
          child: const Text('Refresh'),
        ),

        // Parameterized Fetcher
        Expanded(
          child: FetchBuilder<bool, String>.parameterized(
            controller: _fetchController1,
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

        // Dense Fetcher
        const Separator(),
        const Padding(
          padding: EdgeInsets.all(10),
          child: _Title(title: 'Dense Fetcher with Error'),
        ),
        FetchBuilder.basic<String>(
          task: () async => throw Exception('Error !!'),
          config: const FetcherConfig(
            isDense: true,
          ),
          builder: (context, data) => throw StateError('Should never reach this code'),
        ),

        // Delayed Fetcher without builder
        const Separator(),
        const Padding(
          padding: EdgeInsets.all(10),
          child: _Title(title: 'Delayed Fetcher without builder'),
        ),
        ElevatedButton(
          onPressed: () => _fetchController2.refresh(),
          child: const Text('Fetch'),
        ),
        const SizedBox(height: 20),
        FetchBuilder.basic<String>(
          controller: _fetchController2,
          fetchAtInit: false,
          task: () => Future.delayed(const Duration(seconds: 2), () => 'success'),
          onSuccess: (result) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => Scaffold(
            body: Center(child: Text(result)),
          ))),
          initBuilder: (_) => const Text('Press Fetch to start'),
        ),
        const SizedBox(height: 20),
      ],
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

class _Title extends StatelessWidget {
  const _Title({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}
