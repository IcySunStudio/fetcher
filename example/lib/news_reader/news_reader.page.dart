import 'package:example/utils/message.dart';
import 'package:fetcher/fetcher_bloc.dart';
import 'package:flutter/material.dart';

import 'news_reader.bloc.dart';

class NewsReaderPage extends StatefulWidget {
  const NewsReaderPage({super.key, required this.page});

  final int page;

  @override
  State<NewsReaderPage> createState() => _NewsReaderPageState();
}

class _NewsReaderPageState extends State<NewsReaderPage> with BlocProvider<NewsReaderPage, NewsReaderBloc> {
  @override
  NewsReaderBloc initBloc() => NewsReaderBloc(widget.page);

  @override
  Widget build(BuildContext context) {
    return SubmitBuilder<ArticleVote>(
      task: bloc.voteArticle,
      onSuccess: (vote) {
        // Display a success message
        showMessage(context, 'Voted successfully: ${vote.name}', backgroundColor: Colors.green);

        // Navigate to the next page
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => NewsReaderPage(page: widget.page + 1)));
      },
      builder: (context, runTask) {
        return Scaffold(
          appBar: AppBar(
            title: Text('News reader #${widget.page}'),
          ),
          body: FetchBuilder<NewsArticle>(
            task: bloc.fetchArticle,
            config: FetcherConfig(
              fetchingBuilder: (context) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 10),
                      Text('Fetching article ${widget.page}...'),
                    ],
                  ),
                ),
              ),
            ),
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

                    // Vote buttons
                    const Spacer(),
                    const SizedBox(height: 15),
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

                    // Vote
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: runTask,
                      child: const Text('Vote'),
                    ),

                    // Vote with error
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () => runTask(bloc.voteArticleWithError),
                      child: const Text('Vote with error'),
                    ),
                  ],
                ),
              );
            }
          ),
        );
      }
    );
  }
}
