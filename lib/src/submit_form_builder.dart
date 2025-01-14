import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:fetcher/src/utils/utils.dart';
import 'package:fetcher/src/submit_builder.dart';
import 'package:fetcher/src/widgets/clear_focus_background.dart';
import 'package:fetcher/src/widgets/guarded_form.dart';

import 'config/default_fetcher_config.dart';

/// Wrapper around [SubmitBuilder] with automatic form validation.
class SubmitFormBuilder<T> extends StatelessWidget {
  const SubmitFormBuilder({
    super.key,
    this.onChanged,
    this.onUnsavedFormPop,
    this.onValidated,
    this.onSuccess,
    required this.builder,
  });

  /// Use this callback on [onUnsavedFormPop] to ignore form pop (will not prevent popping, i.e. disable default behavior).
  static Future<bool> ignoreFormPopCallback() async => true;

  /// Called when one of the form fields changes.
  final VoidCallback? onChanged;

  /// Called when current route tries to pop with unsaved changes.
  /// Return `true` to allow pop, `false` or `null` to prevent pop.
  /// Usually used to show a dialog to confirm pop.
  /// If null, will use closest [DefaultFetcherConfig]'s value.
  /// Use [ignoreFormPopCallback] to disable behavior.
  final Future<bool?> Function()? onUnsavedFormPop;

  /// Called when the form has been validated
  final AsyncValueGetter<T>? onValidated;

  /// Called when the [onValidated] task has successfully completed.
  /// Ignored if widget is unmounted.
  /// Usually used to navigate to another page.
  final ValueSetter<T>? onSuccess;

  /// Child widget builder that provide a [validate] callback to be called when needed (usually on a 'validate' button).
  final SubmitChildBuilder<T> builder;

  @override
  Widget build(BuildContext context) {
    return ClearFocusBackground(
      child: GuardedForm(
        onChanged: onChanged,
        // It's NOT the same to pass null VS ignoreFormPopCallback directly: using ignoreFormPopCallback might trigger pop several times on pages that uses several SubmitFormBuilder.
        // So we explicitly check if the callback is ignoreFormPopCallback, and pass null instead, to properly disable behavior.
        onUnsavedFormPop: onUnsavedFormPop == ignoreFormPopCallback ? null : (onUnsavedFormPop ?? DefaultFetcherConfig.of(context).onUnsavedFormPop),
        child: Builder(
          builder: (context) {
            return SubmitBuilder<T>(
              task: onValidated,
              onSuccess: onSuccess,
              builder: (context, runTask) => builder(context, ([task]) => context.validateForm(
                onSuccess: () => runTask(task),
              )),
            );
          },
        ),
      ),
    );
  }
}
