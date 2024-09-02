import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';

class PagedFetcherPage extends StatelessWidget {
  const PagedFetcherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PagedListViewFetcher<_Data, int>(
      task: (pageId) async {
        pageId ??= 1;
        await Future.delayed(const Duration(seconds: 1));
        final nextPageId = pageId + 1;
        return PagedData(
          nextPageId: nextPageId,
          data: List.generate(10, (index) => _Data(pageId! * 100 + index, pageId, nextPageId)),
        );
      },
      itemBuilder: (context, item) => ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Page #${item.pageId}', style: TextStyle(color: Colors.primaries[item.pageId % Colors.primaries.length])),
            Text('Item #${item.id}'),
          ],
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
