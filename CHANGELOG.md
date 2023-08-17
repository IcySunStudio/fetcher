## 0.2.0
* Add AsyncEditBuilder.fetchingBuilder parameter, to customize the fetching widget independently from the committing widget

## 0.1.0
* Add AsyncTaskBuilder.runTaskOnStart parameter

## 0.0.11
* fix AsyncEditBuilder.onEditSuccess not called

## 0.0.10
* update to value_stream 0.0.4

## 0.0.9
* fix [AsyncEditBuilder] to correctly pass config

## 0.0.8
* Parameter retry of FetcherConfig.errorBuilder is now optional, to correctly handle EventFetchBuilder stream errors

## 0.0.7
* fix EventFetchBuilder when using stream with null values

## 0.0.6
* Add FetchBuilder.initBuilder param (to be used with fetchAtInit false)
* New static AsyncTaskBuilder.runTask method that allows to run headless task safely
* New AsyncEditBuilder

## 0.0.5
* Default FetchBuilderErrorWidget now handles isDense parameter
* New EventFetchBuilder widget
* Move isDense and fade inside FetcherConfig
* Expose ClearFocusBackground
* Rename reportError to onError AND showError to onDisplayError

## 0.0.4
* Replace rxdart dependency by value_stream
* Remove ValueStreamBuilder (use EventStreamBuilder from value_stream)

## 0.0.3
* New AsyncForm widget
* Code clean-up

## 0.0.1-dev1
* Initial dev version
