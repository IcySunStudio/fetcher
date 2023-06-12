import 'package:flutter/material.dart';

class FetchBuilderErrorWidget extends StatelessWidget {
  const FetchBuilderErrorWidget({super.key, this.isDense = false, this.onRetry});

  final bool isDense;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(    // Needed when directly under a Scaffold, for instance.
      child: Flex(
        direction: isDense ? Axis.horizontal : Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[

          // Icon
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: isDense ? 30 : 40,
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