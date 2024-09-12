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
  final _fetchController1 = FetchBuilderWithParameterController<bool, String>();
  final _fetchController2 = FetchBuilderController<String>();

  bool withError = false;
  bool dataClear = false;
  FetchErrorDisplayMode errorDisplayMode = FetchErrorDisplayMode.values.first;

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

        // Unmounted state test
        // Test error handling when state is unmounted
        ElevatedButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Unmounted state test'),
            ),
            body: FetchBuilder<Object>(
              task: () async {
                await Future.delayed(const Duration(milliseconds: 500)).then((value) {
                  if(context.mounted) Navigator.of(context).pop();
                });
                await Future.delayed(const Duration(seconds: 2));
                throw Exception('test');
              },
            ),
          ))),
          child: const Text('Unmounted state test'),
        ),

        // Header
        const SizedBox(height: 20),
        const _Title(title: 'Fetcher with parameters'),

        // Settings
        CheckboxListTile(
          title: const Text('Clear data first'),
          dense: true,
          value: dataClear,
          onChanged: (value) {
            setState(() {
              dataClear = value!;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('With error'),
          dense: true,
          value: withError,
          onChanged: (value) {
            setState(() {
              withError = value!;
            });
          },
        ),
        SwitchListTile(
          title: Text('Display error : ${errorDisplayMode == FetchErrorDisplayMode.inWidget ? 'in widget' : 'on display'}'),
          subtitle: const Text('Only effective on refresh'),
          dense: true,
          value: errorDisplayMode == FetchErrorDisplayMode.inWidget,
          onChanged: (value) {
            setState(() {
              errorDisplayMode = value ? FetchErrorDisplayMode.inWidget : FetchErrorDisplayMode.onDisplay;
            });
          },
        ),

        // Button
        ElevatedButton(
          onPressed: () => _fetchController1.refresh(clearDataFirst: dataClear ? true : null, param: withError, errorDisplayMode: errorDisplayMode),
          child: const Text('Refresh'),
        ),

        // Parameterized Fetcher
        Expanded(
          child: FetchBuilderWithParameter<bool, String>(
            controller: _fetchController1,
            task: fetchTask,
            config: const FetcherConfig(
              // fadeDuration: Duration.zero,    // Disable fade
              fadeDuration: Duration(seconds: 1),   // Long fade
            ),
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
        FetchBuilder<String>(
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
          onPressed: () => _fetchController2.refresh(clearDataFirst: true),
          child: const Text('Fetch'),
        ),
        const SizedBox(height: 20),
        FetchBuilder<String>(
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
  const _Title({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}
