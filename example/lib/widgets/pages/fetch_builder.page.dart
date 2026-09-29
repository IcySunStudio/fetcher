import 'dart:math';

import 'package:example/utils/message.dart';
import 'package:fetcher/fetcher_bloc.dart';
import 'package:flutter/material.dart';

class FetchBuilderPage extends StatefulWidget {
  const FetchBuilderPage({super.key});

  @override
  State<FetchBuilderPage> createState() => _FetchBuilderPageState();
}

class _FetchBuilderPageState extends State<FetchBuilderPage> {
  final _refreshController = FetchRefresherController();
  final _fetchController1 = FetchBuilderWithParameterController<bool, String>();
  final _fetchController2 = FetchBuilderController<String>();
  final _random = Random();

  bool withError = false;
  bool dataClear = true;
  bool withCachedValue = true;
  FetchErrorDisplayMode errorDisplayMode = FetchErrorDisplayMode.values.first;

  Future<String> fetchTask(String taskName, bool? withError, {bool instant = false}) async {
    // Simulate a network request
    debugPrint('[$taskName] Fetching data...');
    if (!instant) {
      await Future.delayed(Duration(milliseconds: 1000 + (_random.nextDouble() * 2000).round()));
    }

    // Simulate an error
    if (withError == true) throw Exception('Error !');

    // Return simulated data
    return 'taskName: ${DateTime.now().toIso8601String()}';
  }

  void _printControllerMountedState() {
    debugPrint('Controller are mounted: ${_refreshController.isMounted}, ${_fetchController1.isMounted}, ${_fetchController2.isMounted}');
  }

  @override
  void initState() {
    super.initState();

    // Test controller isMounted
    _printControllerMountedState();
    Future.delayed(const Duration(seconds: 1), _printControllerMountedState);
  }

  @override
  Widget build(BuildContext context) {
    const contentPadding = EdgeInsets.symmetric(horizontal: 20);
    return FetchRefresher(
      controller: _refreshController,
      child: FillRemainsScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pull to refresh
            Padding(
              padding: contentPadding,
              child: ElevatedButton(
                onPressed: _refreshController.refresh,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 10),
                    Text('Pull or tap to refresh all fetchers'),
                  ],
                ),
              ),
            ),

            // Unmounted state test
            // Test error handling when state is unmounted
            Padding(
              padding: contentPadding,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => Scaffold(
                  appBar: AppBar(
                    title: const Text('Unmounted state test'),
                  ),
                  body: FetchBuilder<String>(
                    task: () async {
                      await Future.delayed(const Duration(milliseconds: 500)).then((value) {
                        if(context.mounted) Navigator.of(context).pop();
                      });
                      return await fetchTask('Unmounted', false);
                    },
                    onSuccess: (_) => showMessage(context, 'This message should not be displayed because the state is unmounted'),
                  ),
                ))),
                child: const Text('Unmounted state test'),
              ),
            ),

            // Header
            const SizedBox(height: 20),
            const Separator(),
            const _Title(title: 'Fetcher with parameters'),

            // Settings
            CheckboxListTile(
              title: const Text('Clear data on refresh'),
              dense: true,
              value: dataClear,
              onChanged: (value) {
                setState(() {
                  dataClear = value!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Fetch error'),
              dense: true,
              value: withError,
              onChanged: (value) {
                setState(() {
                  withError = value!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('With cached (instant) value'),
              subtitle: const Text('Simulates a cache hit: task resolves synchronously.'),
              dense: true,
              value: withCachedValue,
              onChanged: (value) {
                setState(() {
                  withCachedValue = value!;
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
            Padding(
              padding: contentPadding,
              child: ElevatedButton(
                onPressed: () => _fetchController1.refresh(clearDataFirst: dataClear ? true : null, param: withError, errorDisplayMode: errorDisplayMode),
                child: const Text('Refresh'),
              ),
            ),

            // Parameterized Fetcher
            SizedBox(
              height: 200,
              child: FetchBuilderWithParameter<bool, String>(
                controller: _fetchController1,
                task: (withError) => fetchTask('Parameterized', withError, instant: withCachedValue),
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
            const _Title(title: 'Dense Fetcher with Error'),
            FetchBuilder<String>(
              task: () => fetchTask('Dense', true),
              config: const FetcherConfig(
                isDense: true,
              ),
              builder: (context, data) => throw StateError('Should never reach this code'),
            ),

            // Delayed Fetcher without builder
            const Separator(),
            const _Title(title: 'Delayed Fetcher without builder'),
            Padding(
              padding: contentPadding,
              child: ElevatedButton(
                onPressed: () => _fetchController2.refresh(clearDataFirst: true),
                child: const Text('Fetch'),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: contentPadding,
              child: FetchBuilder<String>(
                controller: _fetchController2,
                fetchAtInit: false,
                task: () => fetchTask('Delayed', false),
                onSuccess: (result) {
                  // Uncomment to test error handling in onSuccess
                  // throw 'An error occurred in onSuccess';

                  // Display a success message
                  showMessage(context, 'Load without builder success', backgroundColor: Colors.green);

                  // Navigate to the next page
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => Scaffold(
                    appBar: AppBar(
                      title: const Text('FetchBuilder without builder'),
                    ),
                    body: Center(child: Text(result)),
                  )));
                },
                initBuilder: (_) => const Text('Press Fetch to start'),
              ),
            ),

            // Search field (rapid clearDataFirst during fade)
            const Separator(),
            const _Title(title: 'Search field with quick fetch & clear repeat cycles'),
            const Text('Type quickly to trigger rapid fetches with clearDataFirst: true'),
            const Padding(
              padding: contentPadding,
              child: _SearchFieldExample(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Reproduces the "Duplicate keys found" crash:
/// every keystroke triggers a quick fetch with `clearDataFirst: true`, which emits
/// repeated identical `null` snapshots while a fade transition is still in progress.
class _SearchFieldExample extends StatefulWidget {
  const _SearchFieldExample();

  @override
  State<_SearchFieldExample> createState() => _SearchFieldExampleState();
}

class _SearchFieldExampleState extends State<_SearchFieldExample> {
  final _textController = TextEditingController();
  final _fetchController = FetchBuilderController<String>();
  final _random = Random();

  Future<String> _search(String query) async {
    // Quick mocked fetch (<50ms)
    await Future.delayed(const Duration(milliseconds: 30));
    return 'Result #${_random.nextInt(1000000)} for "$query"';
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _textController,
          decoration: const InputDecoration(
            labelText: 'Type to search',
            hintText: 'Type quickly to trigger rapid fetches',
          ),
          // No debounce: fire a fetch on every keystroke.
          onChanged: (_) => _fetchController.refresh(clearDataFirst: true),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 80,
          child: FetchBuilder<String>(
            controller: _fetchController,
            config: const FetcherConfig(
              fadeDuration: Duration(seconds: 1),   // Long fade to increase the chance of overlapping fetches during the transition.
            ),
            fetchAtInit: false,
            task: () => _search(_textController.text),
            initBuilder: (_) => const Center(child: Text('Type something to search')),
            builder: (context, data) => Center(child: Text(data)),
          ),
        ),
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
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
