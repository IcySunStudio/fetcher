## 4.1.0
* New `FetchRefresher` widget, that allows to refresh all `FetchBuilder` children using Material "swipe to refresh" idiom.
* Fix `FetchBuilder.controller` update when widget parameter changes.

## 4.0.0
* BREAKING: replace `FetchBuilder.basic` constructor to simply `FetchBuilder`.
* BREAKING: replace `FetchBuilder.parameterized` constructor to `FetchBuilderWithParameter`.
* BREAKING: rename `BasicFetchBuilderController` to simply `FetchBuilderController`.
* BREAKING: rename `ParameterizedFetchBuilderController` to simply `FetchBuilderWithParameterController`.
* BREAKING: remove obsolete `clearFocus2` method.
* BREAKING: For `FetchBuilder`, `FetcherConfig.fetchErrorBuilder.errorData.error` is now directly the thrown error object, instead of a useless `FetchException` (which is now hidden).
* BREAKING: remove `FetchBuilder.getFromCache` and `FetchBuilder.saveToCache`: cache handling should be done at the BLoC level.
* Fix when `FetchBuilder.onSuccess` throws an error: it's now handled like if `FetchBuilder.task` throws (before that fix, it would be stuck in loading state).
* Export `ActivityBarrier` widget

## 3.1.0
* Add NewsReaderPage example
* Add BLoC pattern components, so fetcher can be use with BLoC pattern without any additional dependency.

## 3.0.0
* BREAKING: rename `AsyncTaskBuilder` to `SubmitBuilder`.
* BREAKING: rename `AsyncForm` to `SubmitFormBuilder`.
* BREAKING: rename `AsyncEditBuilder.commitTask` to `AsyncEditBuilder.submitTask`.
* BREAKING: all `onSuccess` callbacks are now synchronous.
* BREAKING: remove `FetcherConfig.fade` parameter. Use `FetcherConfig.fadeDuration` instead.
* BREAKING: a bit of other renaming & export cleaning.
* New `FetcherConfig.silent` config for cases where loader & error should not be displayed.
* Fix fade animation not working properly.

## 2.0.1
* BREAKING: rename `FetcherConfigErrorData` to `FetchErrorData`.
* Fix `FetchErrorData` export.

## 2.0.0
* BREAKING: `fetchErrorBuilder` now passes error object to the builder, so error can be used in widget.

## 1.0.0
* BREAKING: `AsyncForm` is now generic and handles a parameter of type `T` to be passed on.
* Add new `AsyncFormPage` in the example app.

## 0.6.2
* Replace `findAncestorWidgetOfExactType` by `getInheritedWidgetOfExactType` for better performance
* Fix `AsyncTaskBuilder.runTask` catch bloc throwing because of unmounted context

## 0.6.1
* Fix ActivityBarrier reverse animation

## 0.6.0
* BREAKING: New `FetchBuilder` error display handling using `FetchErrorDisplayMode`
* BREAKING: Remove `ConnectivityException` & `UnreportedException`
* BREAKING: Rename `FetchBuilder.errorBuilder` to `FetchBuilder.fetchErrorBuilder`

## 0.5.1
* Properly handle when `FetchBuilder.saveToCache` throws  

## 0.5.0
* Add `barrierColor` parameter to `AsyncTaskBuilder`

## 0.4.1
* Fix `FetchBuilder` error that may occur when task throws when state is unmounted

## 0.4.0
* BREAKING: `EventFetchBuilder.fromEvent` constructor is replaced by default constructor
* `EventFetchBuilder` now internally use `EventStreamBuilder`, which allow to properly handle initial error

## 0.3.0
* New `PagedListViewFetcher` widget, that fetches a paginated list of data, page by page

## 0.2.0
* Add `AsyncEditBuilder.fetchingBuilder` parameter, to customize the fetching widget independently from the committing widget

## 0.1.0
* Add `AsyncTaskBuilder.runTaskOnStart` parameter

## 0.0.11
* Fix `AsyncEditBuilder.onEditSuccess` not called

## 0.0.10
* Update to `value_stream` 0.0.4

## 0.0.9
* Fix `AsyncEditBuilder` to correctly pass config

## 0.0.8
* Parameter retry of `FetcherConfig.errorBuilder` is now optional, to correctly handle `EventFetchBuilder` stream errors

## 0.0.7
* Fix `EventFetchBuilder` when using stream with null values

## 0.0.6
* Add `FetchBuilder.initBuilder` param (to be used with `fetchAtInit` false)
* New static `AsyncTaskBuilder.runTask` method that allows to run headless task safely
* New `AsyncEditBuilder`

## 0.0.5
* Default `FetchBuilderErrorWidget` now handles `isDense` parameter
* New `EventFetchBuilder` widget
* Move `isDense` and fade inside `FetcherConfig`
* Expose `ClearFocusBackground`
* Rename `reportError` to `onError` AND `showError` to `onDisplayError`

## 0.0.4
* Replace `rxdart` dependency by `value_stream`
* Remove `ValueStreamBuilder` (use `EventStreamBuilder` from `value_stream`)

## 0.0.3
* New `AsyncForm` widget
* Code clean-up

## 0.0.1-dev1
* Initial dev version
