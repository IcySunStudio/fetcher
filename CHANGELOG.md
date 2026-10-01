## 5.0.0
* BREAKING: `FetcherConfig.fadeOnDataChange` now defaults to `false`: data updates rebuild the child in-place, preserving its state (scroll position, text fields, animations, platform views, etc.), instead of fading and recreating it. Transitions between fetch states (loading, error, data) still fade. Set `fadeOnDataChange: true` to restore the previous behavior.
  Beware of state derived from data, which is now kept across data updates (e.g. `refresh()` without `clearDataFirst`, new `EventFetchBuilder` event): fields initialized from the data in `initState` (or `late` fields), `initialValue` of form fields, or unkeyed stateful children in a list (state would be associated to the wrong item when items are inserted/removed). Either handle updates in `didUpdateWidget`, add keys (e.g. `ValueKey(item.id)`), or set `fadeOnDataChange: true`.
* New `fadeAlignment` parameter on `FetcherConfig`, to control how outgoing and incoming children are aligned during the fade transition (e.g. when the loader and the content have different sizes). Defaults to `Alignment.topLeft` (previous behavior).
* BREAKING: new `submittingBuilder` parameter on `FetcherConfig`, to customize the loader displayed on the barrier by `SubmitBuilder` and `SubmitFormBuilder`, independently of the `fetchingBuilder` (which is often a placeholder of the content). `SubmitBuilder` and `SubmitFormBuilder` don't use `fetchingBuilder` anymore: if you customized `fetchingBuilder` in your `DefaultFetcherConfig` (or in a `SubmitBuilder.config`), also set `submittingBuilder`.
* BREAKING: `AsyncEditBuilder.fetchingBuilder` was removed. Use `config: FetcherConfig(fetchingBuilder: ...)` instead (same behavior). Use `FetcherConfig.submittingBuilder` to customize the submitting widget.
* BREAKING: `validateForm`'s `onSuccess` parameter was renamed to `onValidated`, to avoid confusion with the task `onSuccess` of `SubmitBuilder`. `validateForm` now also returns whether the form is valid, like `FormState.validate`.
* Fix config changes being ignored by already built widgets: `FetchBuilder` and `SubmitBuilder` used to freeze their config (both `DefaultFetcherConfig` and `config` parameter) on first build. All widgets now rebuild when the enclosing `DefaultFetcherConfig` changes.
* Fix `SubmitBuilder.runTask` not calling `FetcherConfig.onError` from `DefaultFetcherConfig` when the context is unmounted before the task ends: config is now resolved before running the task.
* BREAKING: `DefaultFetcherConfig.of` now registers a dependency on the enclosing `DefaultFetcherConfig` by default (so that widgets rebuild on change), so it can't be called from `initState` anymore. Use the new `listen: false` parameter to read it outside of the build phase (e.g. in `initState` or in callbacks).
* BREAKING: nested `DefaultFetcherConfig`s are now merged: a `DefaultFetcherConfig` now only overrides the non-null fields of the closest `DefaultFetcherConfig` ancestor, instead of resetting all other fields to the library defaults.
* BREAKING: `FetcherConfig.apply` was renamed to `merge` (same behavior, like `TextStyle.merge`).
* BREAKING: `FetcherConfig.defaultConfig` is now `final`. Use a `DefaultFetcherConfig` at the root of your app to customize the global config.
* BREAKING: `DefaultFetcherConfig.defaultConfig` was removed, use `FetcherConfig.defaultConfig` instead.
* BREAKING: `FadedAnimatedSwitcher` is no longer exported by `extra.dart`, and its `sizeAnimation` parameter was removed.

## 4.6.1
* Fix "Duplicate keys found" crash when fetch states change rapidly during a fade transition (e.g. repeated `refresh(clearDataFirst: true)` calls), on `FetchBuilder`, `EventFetchBuilder`, `SubmitBuilder` and `ActivityBarrier`.

## 4.6.0
* Minimum required Dart SDK is now `3.4.0`.
* `task` (on `FetchBuilder`, `FetchBuilderWithParameter` and `PagedListViewFetcher`) now accepts `FutureOr<T>` instead of `Future<T>`: return the value directly, instead of wrapping it in a `Future`, when it's already known synchronously (e.g. from a cache), to skip the loading indicator entirely. See `FetchBuilder` doc for an example.

## 4.5.0
* New `fadeOnDataChange` parameter on `FetcherConfig`. When set to `false`, data updates rebuild the child widget in-place (preserving subtree state) instead of triggering a fade transition. Transitions between fetch states (loading, error, data) still animate naturally. Useful when the builder returns a stateful widget that must survive data changes. Defaults to `true` for backward compatibility.
* Fix `PagedListViewFetcher.refresh()` reloading the wrong page: now refresh always reloads from the first page.
* New `physics` parameter on `PagedListViewFetcher`, forwarded to the internal `ListView`. Use `AlwaysScrollableScrollPhysics` to enable pull-to-refresh even when the list doesn't fill the screen.

## 4.4.0
* New `scrollToFirstInvalidField` feature on `SubmitFormBuilder`: automatically scrolls to the first invalid field when form validation fails. Disabled by default.

## 4.3.1
* Migrate `value_stream` to `value_stream_flutter`.

## 4.3.0
* New `isMounted` getter on controllers, to safely call `refresh`.
* New `onFetchSuccess` parameter on config, global fetch success interceptor.

## 4.2.2
* Fix popping behavior when using `alwaysAllowFormPopCallback` on `SubmitFormBuilder`.
* Rename `alwaysAllowFormPopCallback` to `ignoreFormPopCallback` and review doc to be more clear.

## 4.2.1
* Expose `onChanged` parameter on `GuardedForm` and `SubmitFormBuilder`.

## 4.2.0
* New feature to prevent a form to pop with unsaved changes when using `SubmitFormBuilder`. Introduce new `GuardedForm` widget, along with new `onUnsavedFormPop` parameter in `FetcherConfig` and `SubmitFormBuilder`.

## 4.1.1
* Fix unnecessary rebuild when using `EventFetchBuilder`.

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
