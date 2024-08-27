<img src="https://github.com/user-attachments/assets/69be0ff9-840c-44e5-bef0-3147e3d78553" width="100%" alt="fetcher" />

[![Pub](https://img.shields.io/pub/v/fetcher.svg?label=fetcher)](https://pub.dartlang.org/packages/fetcher)
[![License](https://img.shields.io/badge/License-BSD_3--Clause-green.svg)](https://opensource.org/licenses/BSD-3-Clause)

**Async task UI made easy 😄**

Minimalist framework to easily handle UI states (loading, error and data) for asynchonous tasks (like network calls), in an unified way.

It provides two main widgets, with automatic handling of all common UI states:

* `FetchBuilder` fetch then display data *(example: a weather info page)*.
* `SubmitBuilder` submit data *(example: a form page)*.

Simplicity in mind: directly provides a `Future` (likely network call, which may throw), the widget handles the rest.

## Features

* Minimalist library: mostly use native Flutter components & logic
* Ready to use: default widgets provided
* Basic usage should be very simple and straighforward, while advanced usage is possible
* Global configuration with local overrides
* Error & retry handling, with common UX behavior in mind
* Can be plugged into an error reporting service
* Fade transition between states to allow smooth UI

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

### More

See the example project for more usage examples.

## Getting started

1. Add package as dependency in pubspec.yaml
2. [Optional] Wrap your app widget with DefaultFetcherConfig to set global configuration:

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
