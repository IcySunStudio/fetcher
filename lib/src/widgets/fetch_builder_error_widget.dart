import 'package:flutter/material.dart';

class FetchBuilderErrorWidget extends StatelessWidget {
  const FetchBuilderErrorWidget({Key? key, this.onRetry}) : super(key: key);

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(    // Needed when directly under a Scaffold, for instance.
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[

          // Icon
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 40,
          ),

          // Retry button
          if (onRetry != null)...[
            const SizedBox(height: 5),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: onRetry,
            ),
          ],

        ],
      ),
    );
  }
}