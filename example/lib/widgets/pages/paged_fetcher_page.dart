import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';

class PagedFetcherPage extends StatefulWidget {
  const PagedFetcherPage({super.key});

  @override
  State<PagedFetcherPage> createState() => _PagedFetcherPageState();
}

class _PagedFetcherPageState extends State<PagedFetcherPage> {
  final _controller = FetchBuilderController<PagedData<_Data, int>>();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _controller.refresh,
      child: PagedListViewFetcher<_Data, int>(
        controller: _controller,
        task: (pageId) async {
          pageId ??= 1;
          await Future.delayed(const Duration(seconds: 1));
          final nextPageId = pageId + 1;
          debugPrint('Fetched page $pageId, next page is $nextPageId');
          return PagedData(
            nextPageId: nextPageId,
            data: List.generate(10, (index) => _Data(pageId! * 100 + index, pageId, nextPageId)),
          );
        },
        padding: const EdgeInsets.only(bottom: 8),
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, item) => ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Page #${item.pageId}', style: TextStyle(color: Colors.primaries[item.pageId % Colors.primaries.length])),
              Text('Item #${item.id}'),
            ],
          ),
        ),
      ),
    );
  }
}

class _Data {
  const _Data(this.id, this.pageId, this.nextPageId);

  final int id;
  final int pageId;
  final int nextPageId;
}
