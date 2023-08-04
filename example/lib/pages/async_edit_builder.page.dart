import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';

class AsyncEditBuilderPage extends StatelessWidget {
  const AsyncEditBuilderPage({super.key});

  static const values = [0, 2, 4, 8, 10];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [

          // Text
          const Text(
            'Tap on a cell to commit value.\nThe last cell throws an error.'
          ),
          const SizedBox(height: 20),

          // Content
          AsyncEditBuilder<int>(
            fetchTask: () async {
              // Task that fetch data
              await Future.delayed(const Duration(seconds: 2));
              return values.first;
            },
            commitTask: (data) async {
              // Task that commit data
              await Future.delayed(const Duration(seconds: 1));

              // Throw error (to test)
              if (data == values.last) {
                throw Exception('An error occured on commit : value is preserved');
              }
            },
            config: FetcherConfig(
              fetchingBuilder: (context) => Text('Loading...'),
            ),
            onEditSuccess: (data) async {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Commit success : $data'),
              ));
              await Future.delayed(const Duration(seconds: 1));
            },
            builder: (context, selected, commit) {
              return ToggleButtons(
                isSelected: values.map((value) => value == selected).toList(growable: false),
                onPressed: (index) => commit(values[index]),
                children: values.map((value) {
                  return Text(value.toString());
                }).toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }
}
