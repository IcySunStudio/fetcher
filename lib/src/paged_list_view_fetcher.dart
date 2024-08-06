import 'package:fetcher/extra.dart';
import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:value_stream/value_stream.dart';

/// A widget that fetch a paginated list of data, page by page.
/// Handle all states (loading, errors, onSuccess).
/// Initially just fetch first page, then fetch next page when user scrolls.
/// [T] is the type of the data.
/// [P] is the type of the pageId (usually String or int).
class PagedListViewFetcher<T, P> extends StatefulWidget {
  const PagedListViewFetcher({
    super.key,
    this.controller,
    required this.task,
    this.separator,
    required this.itemBuilder,
    this.emptyWidget,
    this.padding,
    this.itemExtent,
    this.reverse = false,
  }) : assert(separator == null || itemExtent == null);

  /// A controller used to manually refresh data.
  final BasicFetchBuilderController<PagedData<T, P>>? controller;

  /// Task that fetch and return the data, with pageId as parameter.
  final ParameterizedAsyncTask<P, PagedData<T, P>> task;

  /// A widget to display between each item.
  final Widget? separator;

  /// A builder that builds the widget for each item.
  final DataWidgetBuilder<T> itemBuilder;

  /// A widget to display when there is no data.
  final Widget? emptyWidget;

  /// The padding around the list.
  final EdgeInsetsGeometry? padding;

  /// The extent the item will have.
  /// Only work if [separator] is null.
  final double? itemExtent;

  /// If true, the list will be reversed.
  final bool reverse;

  @override
  State<PagedListViewFetcher<T, P>> createState() => _PagedListViewFetcherState<T, P>();
}

class _PagedListViewFetcherState<T, P> extends State<PagedListViewFetcher<T, P>> {
  final List<T> items = [];

  P? nextPageId;
  bool get isLastPageLoaded => nextPageId == null;

  late final Widget _loader;

  @override
  void initState() {
    super.initState();

    // Build loader
    _loader = Center(   // Center force CircularProgressIndicator to have a proper size if itemExtent is used
      child: SizedBox(
        height: 45,
        child: FetchBuilder.basic<PagedData<T, P>>(
          task: _fetchNextPage,
          onSuccess: (pagedData) {
            setState(() {
              _updatePagedData(pagedData);
            });
          },
          config: FetcherConfig(
            isDense: true,
            fetchingBuilder: (_) => const Padding(
              padding: EdgeInsets.all(10),
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FetchBuilder.basic<PagedData<T, P>>(
      controller: widget.controller,
      task: _fetchNextPage,
      onSuccess: (pagedData) {
        items.clear();
        _updatePagedData(pagedData);
      },
      builder: (context, _) {
        final itemCount = items.length + (isLastPageLoaded ? 0 : 1);

        if (itemCount == 0) {
          return widget.emptyWidget ?? const SizedBox();
        }

        if (widget.separator != null) {
          return ListView.separated(
            padding: widget.padding,
            reverse: widget.reverse,
            itemCount: itemCount,
            separatorBuilder: (_, __) => widget.separator!,
            itemBuilder: _itemBuilder,
          );
        } else {
          return ListView.builder(
            padding: widget.padding,
            reverse: widget.reverse,
            itemCount: itemCount,
            itemExtent: widget.itemExtent,
            itemBuilder: _itemBuilder,
          );
        }
      },
    );
  }

  Future<PagedData<T, P>> _fetchNextPage() => widget.task(nextPageId);

  Widget _itemBuilder(BuildContext context, int index) {
    if (!isLastPageLoaded && index == items.length) {
      return _loader;
    } else {
      return widget.itemBuilder(context, items[index]);
    }
  }

  void _updatePagedData(PagedData<T, P> pagedData) {
    nextPageId = pagedData.nextPageId;
    items.addAll(pagedData.data);
  }
}


class PagedData<T, P> {
  const PagedData({
    this.nextPageId,
    this.data = const[],
  });

  final P? nextPageId;
  final List<T> data;
}
