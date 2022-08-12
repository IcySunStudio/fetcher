import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:fetcher/src/utils.dart';
import '../async_task_builder.dart';
import 'clear_focus_background.dart';

typedef AsyncFormChildBuilder = Widget Function(BuildContext context, VoidCallback validate);

class AsyncForm extends StatelessWidget {
  const AsyncForm({Key? key, required this.builder, this.onValidated, this.onSuccess}) : super(key: key);

  /// Child widget builder that provide a [validate] callback to be called when needed.
  final AsyncFormChildBuilder builder;

  /// Called when the form has been validated
  final AsyncCallback? onValidated;

  /// Called when the [onValidated] task has successfully completed
  final AsyncCallback? onSuccess;

  @override
  Widget build(BuildContext context) {
    return ClearFocusBackground(
      child: Form(
        child: Builder(
          builder: (context) {
            return AsyncTaskBuilder<void>(
              task: onValidated != null ? onValidated! : () async {},
              onSuccess: onSuccess != null ? (_) => onSuccess!() : null,
              builder: (context, runTask) => builder(context, () => context.validateForm(
                onSuccess: runTask,
              )),
            );
          },
        ),
      ),
    );
  }
}
