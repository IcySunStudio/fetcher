import 'package:fetcher/fetcher_bloc.dart';

class NewsReaderBloc with Disposable {
  NewsReaderBloc(this.page);

  final int page;
  final selectedVote = DataStream<ArticleVote?>(null);

  Future<NewsArticle> fetchArticle() async {
    // Simulate network request
    await Future.delayed(const Duration(seconds: 2));

    // Return an article
    return NewsArticle('Title #$page', 'Random content generated for page #$page, at ${DateTime.now()}');
  }

  void selectVote(ArticleVote vote) => selectedVote.add(vote, skipSame: true);

  Future<ArticleVote> voteArticle([ArticleVote? vote]) async {
    // If no vote is provided, use the selected vote
    vote ??= selectedVote.value;

    // If still no vote, throw an error
    if (vote == null) throw Exception('Select a vote first');

    // Simulate network request
    await Future.delayed(const Duration(seconds: 1));

    // Simulate error
    if (vote == ArticleVote.error) throw Exception('Error while submitting vote');

    // Return the vote
    return vote;
  }

  Future<ArticleVote> voteArticleWithError() => voteArticle(ArticleVote.error);

  @override
  void dispose() {
    selectedVote.close();
    super.dispose();
  }
}

class NewsArticle {
  const NewsArticle(this.title, this.content);

  final String title;
  final String content;
}

enum ArticleVote {
  like,
  dislike,
  error,
}