<img src="https://github.com/user-attachments/assets/69be0ff9-840c-44e5-bef0-3147e3d78553" width="100%" alt="fetcher" />

[![Pub](https://img.shields.io/pub/v/fetcher.svg?label=fetcher)](https://pub.dartlang.org/packages/fetcher)
[![License](https://img.shields.io/badge/License-BSD_3--Clause-green.svg)](https://opensource.org/licenses/BSD-3-Clause)

**Async task UI made easy 😄**

Minimalist framework to easily handle UI states (loading, error and data) for asynchronous tasks (like network calls), with global error handling and configuration.

It provides two main widgets, with automatic handling of all common UI states:

* `FetchBuilder`: fetch then display data *(example: a weather info page)*
* `SubmitBuilder`: submit data *(example: a form page)*

Simplicity in mind: you directly provide a `Future` (likely network call, which may throw), the widget handles everything else.

Package developed following the [KISS principle](https://en.wikipedia.org/wiki/KISS_principle): no fuss, no glitter, just an easy-to-use API, using easy-to-read code.

**Fetcher Bloc**

`fetcher` package was designed with BLoC pattern in mind.
We recommend using `fetcher` with the provided `BlocProvider` to split UI and business logic, and with the `value_stream` package to handle synchronous UI changes (based on `StreamBuilder`).
A handy export file is provided in that purpose: `flutter_bloc.dart`.

## Features

* 🚀 Minimalist library: mostly uses native Flutter components & logic
* 🧩 Ready to use: default widgets provided
* 🪄 Basic usage should be very simple and straightforward, while advanced usage is possible
* 🌍 Global configuration with local overrides, to offer uniform UX across the app
* 🔄 Error & retry handling, with common UX behavior in mind
* 🛠️ Can be plugged into an error reporting service
* 🎨 Fade transition between states to allow smooth UI
* 🧱 Optional components to use with BLoC pattern (recommended)

### Main Widgets

* `FetchBuilder`: fetch then display data
  * Handle loading, error and data states
  * Retry system
* `SubmitBuilder`: submit data
  * Handle loading and error states
  * Display barrier to prevent user interaction while loading (avoid double clicks)

### Additional Widgets

* `EventFetchBuilder`: listen to an `EventStream` and display data

  * It's like `FetchBuilder` but instead of directly calling a task once, it will listen to a stream and his updates.
* `PagedListViewFetcher`: paginated version of `FetchBuilder`

  * with infinite scrolling
* `SubmitFormBuilder`: submit data with automatic form validation

  * use default Flutter Form system
* `AsyncEditBuilder`: fetch then display data, and submit a change if needed (example: an async switch)

### Fetcher Bloc

* `BlocProvider` mixin to make a Bloc class easily accessible from widget's state.
* Exports `value_stream` package, recommended way to handle synchonous UI changes, based on `StreamBuilder`.

## Usage examples

### Fetch data

This example fetches data from a server, then displays data directly

```dart
FetchBuilder<Weather>(
  task: api.getWeather,
  builder: (context, weather) => Text('Weather: ${weather.temperature}')
)
```

Where `getWeather` is an async function that returns a `Future<Weather>`, and may throw (no internet, bad request, etc.).

By default, it will use global (or default) config. To override locally you can use config parameter:

```dart
FetchBuilder<Weather>(
  task: api.getWeather,
  config: FetcherConfig(
    fetchingBuilder: (context) => const CircularProgressIndicator(),
  ),
  builder: (context, weather) => Text('Weather: ${weather.temperature}')
)
```

### Submit data

This example submits data to server, and then pops the page.

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

Where submitData is an async function that sends new data to server, and may throw (no internet, bad request, etc.).
If task throws, it will call `onDisplayMessage` callback (see config) and stay on the page to allow user to try again. `onSuccess` is only called if task returns without errors.
`task` can optionally return an object that will be passed to the `onSuccess` callback, for advanced usage.

If `task` depends of the child context (for instance, if you have two buttons starting two different tasks), you can pass the desired task in the `runTask` callback, instead of the `task` argument of SubmitBuilder:

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

This example uses `BlocProvider` mixin to provide a bloc class to the widget state.

The bloc class exposes anything you need (business logic), here is a simple value:

```dart
class MyBloc with Disposable {
  final String value = 'Hello';
}
```

The widget (generally the page widget) uses a `BlocProvider` mixin to give access to the bloc from the state:

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

See [the example project](https://github.com/IcySunStudio/fetcher/tree/master/example) for more examples.

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

## Fetcher Bloc complete example / tutorial

A detailed example to illustrate how to use Fetcher Bloc for a common use-case: a basic news reader app.

* Fetch latest news article from server
* User has the option to either like or dislike the article

Full source code is available in [the example project](https://github.com/IcySunStudio/fetcher/tree/master/example).

### 1. Fetch data

First, let's build the bloc with the method that will fetch last article from server:

```dart
import 'package:fetcher/fetcher_bloc.dart';

class NewsReaderBloc with Disposable {
  Future<NewsArticle> fetchArticle() async {
    // Simulate network request
    await Future.delayed(const Duration(seconds: 2));

    // Return an article
    return NewsArticle('Title 1', 'Random content generated for page 1, at ${DateTime.now()}');
  }
}
```

We just need a class that extends `Disposable`, with an async method returning the fetched data (here `NewsArticle`).
No need for any error handling here, all is handled by `FetchBuilder`.

With corresponding data object:

```dart
class NewsArticle {
  const NewsArticle(this.title, this.content);

  final String title;
  final String content;
}
```

On the UI side, we need to create a new stateful widget for the page that holds the bloc in its state:

```dart
import 'package:fetcher/fetcher_bloc.dart';
import 'package:flutter/material.dart';

import 'news_reader.bloc.dart';

class NewsReaderPage extends StatefulWidget {
  const NewsReaderPage({super.key});

  @override
  State<NewsReaderPage> createState() => _NewsReaderPageState();
}

class _NewsReaderPageState extends State<NewsReaderPage> with BlocProvider<NewsReaderPage, NewsReaderBloc> {
  @override
  NewsReaderBloc initBloc() => NewsReaderBloc();

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

```

Now `NewsReaderBloc` instance is accessible from widget's state.

Let's build a basic UI to fetch and then display data:

```dart
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('News reader #1'),
    ),
    body: FetchBuilder<NewsArticle>(
      task: bloc.fetchArticle,
      builder: (context, article) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Title
              Text(
                article.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
  
              // Content
              const SizedBox(height: 15),
              Text(
                article.content,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        );
      }
    ),
  );
}
```

Key part here is the `FetchBuilder<NewsArticle>` widget, that does all the job: we just give it the `task` (network request from bloc), it handles the rest.
While it's loading, a default loading widget will be displayed.
If task throws, a default error widget will be displayed, with a retry button.
When data is available, `builder` will be called, with direct access to the data.

We now have a basic page that fetch data, then displays `article.title` and `article.content`.

We can go further and customize the fetching widget (optional).
We have a `config` argument of type `FetcherConfig`, which allows to customize this widget.
Here we use `fetchingBuilder` argument to override the default loading widget:

```dart
...
task: bloc.fetchArticle,
config: FetcherConfig(
  fetchingBuilder: (context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 10),
          Text('Fetching article 1...'),
        ],
      ),
    ),
  ),
),
builder: ...
```

### 2. Dynamic widget

If you need some widget to change dynamically, for instance on user interaction, and the related task is synchronous and safe (does not throw), you can use a basic `DataStream` and its widget `DataStreamBuilder`.
`DataStream` is just a Dart `Stream` that holds the latest value for easy access, and also guarantees that the value is always accessible (no error handling).
In our example, we can use that for the user to select a vote (like or dislike).

First, add an enum on the bloc:

```dart
enum ArticleVote {
  like,
  dislike,
}
```

Then instantiate a new `DataStream`, and close it on the `dispose` method:

```dart
  final selectedVote = DataStream<ArticleVote?>(null);

  @override
  void dispose() {
    selectedVote.close();
    super.dispose();
  }

```

Because vote can be null (nothing selected), `DataStream` type must be nullable: `ArticleVote?`
Initial value is `null` (unselected), we must explicitly pass it to the constructor.

You can add an extra handy bloc method to apply a vote (optional):

```dart
void selectVote(ArticleVote vote) => selectedVote.add(vote, skipSame: true);
```

On the UI side, use corresponding DataStreamBuilder:

```dart
DataStreamBuilder<ArticleVote?>(
  stream: bloc.selectedVote,
  builder: (context, selectedVote) {
    return ToggleButtons(
      isSelected: [
        selectedVote == ArticleVote.like,
        selectedVote == ArticleVote.dislike,
      ],
      onPressed: (index) => bloc.selectVote(index == 0 ? ArticleVote.like : ArticleVote.dislike),
      children: const [
        Icon(Icons.thumb_up),
        Icon(Icons.thumb_down),
      ],
    );
  },
),
```

When `bloc.selectedVote` stream updates (using the strem's `add()` method), `DataStreamBuilder.builder` part will be rebuilt.
So you should always wrap the smallest possible part with a `DataStreamBuilder`, to only rebuild the part that changes.

Now we have a working ToggleButtons 😄


### 3. Submit data

Now we want to submit that vote to the server. And because it's an asynchonous task (and unsafe), we have to handle all states properly.
So we will use the perfectly adapted SubmitBuilder widget.

First, add a new method to submit the vote to the server on the bloc:

```dart
Future<ArticleVote> voteArticle([ArticleVote? vote]) async {
  // If no vote is provided, use the selected vote
  vote ??= selectedVote.value;

  // If still no vote, throw an error
  if (vote == null) throw Exception('Select a vote first');

  // Simulate network request
  await Future.delayed(const Duration(seconds: 1));

  // Return the vote
  return vote;
}
```

Method takes the current stream value of `selectedVote`, then sends it to the network.
If selection is empty, we throw an error with a displayable message (by default it will be displayed to user).

Now on UI side, just wrap your page with `SubmitBuilder`:

```dart
Widget build(BuildContext context) {
  return SubmitBuilder<ArticleVote>(
    task: bloc.voteArticle,
    onSuccess: (vote) {
      // Display a success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Voted successfully: ${vote.name}'),
        backgroundColor: Colors.green,
      ));

      // Navigate to the next page
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => NewsReaderPage()));
    },
    builder: (context, runTask) {
      ...
      ElevatedButton(
        onPressed: runTask,
        child: const Text('Vote'),
      ),
      ...
    }
  );
}
```

`task` is executed when `runTask` (in `builder`) is called (usually from a button).
While `task` is executed, a barrier with a loader is displayed, blocking user interaction (that's why we need the `SubmitBuilder` to be relatively high in the widget tree).
If `task` throws, a message is displayed, and state is reverted, so user can retry.
When `task` is completed with success, `onSuccess` is called. This is where you should put navigation logic (all logic that needs a `BuildContext`).

If you need to pass an argument to `task` from the `builder` (or if you have different buttons calling different tasks), you may pass a task to the `runTask` callback, that will override the widget's `task`.

In our example, let's call a secondary task from a new button.

In the bloc:

```dart
  Future<ArticleVote> voteArticleWithError() => voteArticle(ArticleVote.error);
```

In the page:

```dart
ElevatedButton(
  onPressed: () => runTask(bloc.voteArticleWithError),
  child: const Text('Vote with error'),
),
```


That's all!
This example illustrates the base of `fetcher_bloc` usage.

Test & see full example code in [the example project](https://github.com/IcySunStudio/fetcher/tree/master/example).


## FAQ

### Controller

In a FetchBuilder, if you need to call a task programmatically (for instance to refresh data from a pull-to-refresh), you can use the `controller` argument.

1. Instantiate a new `FetchBuilderController` (or `FetchBuilderWithParameterController`) in the bloc or in a state
2. Pass instance to `controller` parameter of `FetchBuilder`
3. Call `controller.refresh()` from a function

### FetchBuilder with extra argument

For advanced usage, you can use `FetchBuilderWithParameter` widget to pass an object to the task.

For instance, it can be useful for a search feature, passing the search string in the `refresh` method of the `controller`, each time search field changes.

### Fetch vs Submit

Both corresponding widgets handle an asynchonous task states (loading, error, data, etc).
But differences in usage is important as state flow is a bit different.

Fetch should be used when you need to fetch a data before displaying it to the user.
So while data is fetching, you have nothing to display but a loader.
Similarly, when an error occurs, an error widget will be displayed instead of the data widget.

Submit should be used when you need to send/post/submit/commit a data asynchonously OR just call an asynchonous task.
Typical example is a form submission. Task is usually called after a user interaction (i.e. a button), displaying a barrier with a loader ABOVE all content.
If an error occurs, barrier is removed and state reverted, so user can try again using same context (you stay on the form page).
If it's a success, you usually want to navigate elsewhere.

You may look at [the news reader example](https://github.com/IcySunStudio/fetcher/tree/master/example) to go deeper.
