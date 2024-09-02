<img src="https://github.com/user-attachments/assets/69be0ff9-840c-44e5-bef0-3147e3d78553" width="100%" alt="fetcher" />

[![Pub](https://img.shields.io/pub/v/fetcher.svg?label=fetcher)](https://pub.dartlang.org/packages/fetcher)
[![License](https://img.shields.io/badge/License-BSD_3--Clause-green.svg)](https://opensource.org/licenses/BSD-3-Clause)

**Async task UI made easy 😄**

Minimalist framework to easily handle UI states (loading, error and data) for asynchonous tasks (like network calls), in an unified way.

It provides two main widgets, with automatic handling of all common UI states:

* `FetchBuilder` fetch then display data *(example: a weather info page)*.
* `SubmitBuilder` submit data *(example: a form page)*.

Simplicity in mind: directly provides a `Future` (likely network call, which may throw), the widget handles the rest.

Package developed with the [KISS principle](https://en.wikipedia.org/wiki/KISS_principle): no fuss, no glitter, just an easy-to-use API, using easy-to-read code.

**Fetcher Bloc**

`fetcher` package was designed with BLoC pattern in mind.
We recommend using `fetcher` with the provided `BlocProvider` to split UI and business logic, and with the `value_stream` package to handle synchronous UI changes (based on `StreamBuilder`).
A handy export file is provided in that purpose.

## Features

* Minimalist library: mostly use native Flutter components & logic
* Ready to use: default widgets provided
* Basic usage should be very simple and straighforward, while advanced usage is possible
* Global configuration with local overrides
* Error & retry handling, with common UX behavior in mind
* Can be plugged into an error reporting service
* Fade transition between states to allow smooth UI
* Optional components to use with BLoC pattern (recommended)

### Main Widgets

* `FetchBuilder` fetch then display data
  * Handle loading, error and data states
  * Retry system
* `SubmitBuilder` submit data
  * Handle loading and error states
  * Display barrier to prevent user interaction while loading (avoid double clicks)

### Additional Widgets

* `EventFetchBuilder` listen to an `EventStream` and display data

  * It's like `FetchBuilder` but instead of directly calling a task once, it will listen to a stream and his updates.
* `PagedListViewFetcher` paginated version of `FetchBuilder`

  * with infinite scrolling
* `SubmitFormBuilder` submit data with automatic form validation

  * use default Flutter Form system
* `AsyncEditBuilder` fetch then display data, and submit a change if needed (example: an async switch)

### Fetcher Bloc

* `BlocProvider` mixin to make a Bloc class easily accessible from widget's state.
* Exports `value_stream` package, recommended way to handle synchonous UI changes, based on `StreamBuilder`.

## Usage examples

### Fetch data

This example fetch a data from a server, then display data directly

```dart
FetchBuilder.basic<Weather>(
  task: api.getWeather,
  builder: (context, weather) => Text('Weather: ${weather.temperature}')
)
```

Were `getWeather` is an async function that return a `Future<Weather>`, and may throw (not internet, bad request, etc).

By default it will use global (or default) config. To override locally you can use config parameter:

```dart
FetchBuilder.basic<Weather>(
  task: api.getWeather,
  config: FetcherConfig(
    fetchingBuilder: (context) => const CircularProgressIndicator(),
  ),
  builder: (context, weather) => Text('Weather: ${weather.temperature}')
)
```

### Submit data

This example submit data to server, and then pop the page.

```dart
SubmitBuilder<void>(
  task: () => api.submitData('new data value'),
  onSuccess: (_) => Navigator.pop(context),
  builder: (context, runTask) => ElevatedButton(
    onPressed: runTask,
    child: const Text('Submit'),
  ),
)
```

Were submitData is an async function that send new data to server, and may throw (not internet, bad request, etc).
If task throws, it will call `onDisplayMessage` callback (see config) and stay on the page to allow user to try again: `onSuccess` is only called it task return without errors.
`task` can optionally return an object, that will be passed to the `onSuccess` callback, for advanced usage.

If task depends of the child context (for instance, if you have 2 buttons that starts 2 different tasks), you can pass the desired task in the runTask callback, instead of the task argument of SubmitBuilder:

```dart
SubmitBuilder<void>(
  onSuccess: (_) => Navigator.pop(context),
  builder: (context, runTask) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: runTask(() => api.submitData('data 1')),
          child: const Text('Submit 1'),
        ),
        ElevatedButton(
          onPressed: runTask(() => api.submitData('data 2')),
          child: const Text('Submit 2'),
        ),
      ],
    );
  },
)
```

### Fetcher Bloc

This example use `BlocProvider` mixin to provide a bloc class to the widget state.

The bloc class, that exposes anything you need (business logic), here a simple value:

```dart
class MyBloc with Disposable {
  final String value = 'Hello';
}
```

The widget (generally the page widget), that uses a `BlocProvider` mixin to give access to the bloc from the state:

```dart
class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with BlocProvider<MyPage, MyBloc> {
  @override
  MyBloc initBloc() => MyBloc();

  @override
  Widget build(BuildContext context) {
    // You have access to the bloc instance anywhere from the state
    return Text(bloc.value);
  }
}
```


### More

See the example project for more usage examples.

## Getting started

1. Add package as dependency in pubspec.yaml
2. Import
   1. `fetcher_bloc.dart` to use fetcher with BLoC pattern (recommended)
   2. Or `fetcher.dart` to just use fetcher widgets directly. You then may use `extra.dart` to use additional components.
3. [Optional] Wrap your app widget with DefaultFetcherConfig to set global configuration:

```dart
DefaultFetcherConfig(
  config: FetcherConfig(
    fetchingBuilder: (context) => const Center(child: CircularProgressIndicator(color: Colors.red)),
    onDisplayError: (context, error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error.toString()),
      backgroundColor: Colors.red,
    )),
    onError: (exception, stack, {reason}) {
      // Report error
    },
  ),
  child: MaterialApp(
    title: 'Fetcher Example',
    home: const MyHomePage(),
  ),
)
```

From there you're good to go 🎉️


## Fetcher Bloc complete example

A detailed example to illustrate how to use Fetcher Bloc for a common use-case: a basic news reader app.

* Fetch latest news article from server
* User has the option to either like or dislike the article

Full source code is available in the example project.


// TODO



## FAQ

### Controller
