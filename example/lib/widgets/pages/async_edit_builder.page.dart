import 'package:example/utils/message.dart';
import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';

class AsyncEditBuilderPage extends StatefulWidget {
  const AsyncEditBuilderPage({super.key});

  @override
  State<AsyncEditBuilderPage> createState() => _AsyncEditBuilderPageState();
}

class _AsyncEditBuilderPageState extends State<AsyncEditBuilderPage> {
  int _refreshKey = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        FilledButton(
          onPressed: () => setState(() => _refreshKey++),
          child: const Text('Refresh widgets'),
        ),

        // Content
        Expanded(
          child: _PageContent(
            key: ValueKey(_refreshKey),
          ),
        ),
      ],
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({super.key});

  static const values = [0, 2, 4, 8, 10];

  @override
  Widget build(BuildContext context) {
    const iconButtonSize = 50.0;
    const iconButtonLoadingStrokeWidth = 5.0;
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [

          // Simple toggle
          const Text(
            'Simple Toggle example',
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: iconButtonSize,
            height: iconButtonSize,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(500)), // Circular border to avoid ActivityBarrier overflow
              child: AsyncEditBuilder<bool>(
                fetchTask: () => Future.delayed(const Duration(seconds: 2), () => false),
                submitTask: (data) => Future.delayed(const Duration(seconds: 1)),
                onEditSuccess: (data) => showMessage(context, 'Submit success : $data'),
                fetchingBuilder: (context) => const _FavoriteButton(
                  key: ValueKey('fetching'),    // Avoid fade blinking
                  selected: false,
                ),
                config: FetcherConfig(
                  fetchingBuilder: (context) => const SizedBox(   // Force CircularProgressIndicator to be at the border
                    width: iconButtonSize - iconButtonLoadingStrokeWidth / 2,
                    height: iconButtonSize - iconButtonLoadingStrokeWidth / 2,
                    child: CircularProgressIndicator(
                      color: Colors.green,
                      strokeWidth: iconButtonLoadingStrokeWidth,
                    ),
                  ),
                ),
                builder: (context, selected, submit) {
                  return _FavoriteButton(
                    selected: selected,
                    onPressed: () => submit(!selected),
                  );
                },
              ),
            ),
          ),

          // ToggleButtons
          const SizedBox(height: 80),
          const Text(
            'Tap on a cell to submit value.\nThe last cell throws an error.',
          ),
          const SizedBox(height: 20),
          Container(
            height: 50,     // Avoids loading jumps
            alignment: Alignment.center,
            child: AsyncEditBuilder<int>(
              fetchTask: () async {
                // Task that fetch data
                await Future.delayed(const Duration(seconds: 3));
                return values.first;
              },
              submitTask: (data) async {
                // Task that submit data
                await Future.delayed(const Duration(seconds: 1));

                // Throw error (to test)
                if (data == values.last) {
                  throw Exception('An error occured on submit : value is preserved');
                }
              },
              config: FetcherConfig(
                fetchingBuilder: (context) => const Text('Loading...'),
              ),
              onEditSuccess: (data) => showMessage(context, 'Submit success : $data'),
              builder: (context, selected, submit) {
                return ToggleButtons(
                  isSelected: values.map((value) => value == selected).toList(growable: false),
                  onPressed: (index) => submit(values[index]),
                  children: values.map((value) {
                    return Text(value.toString());
                  }).toList(growable: false),
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({super.key, required this.selected, this.onPressed});

  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    const size = 50.0;
    return SizedBox(
      width: size,
      height: size,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: const CircleBorder(),
        color: onPressed == null ? Colors.grey : Theme.of(context).primaryColor,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: Icon(
              selected ? Icons.favorite : Icons.favorite_border,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
