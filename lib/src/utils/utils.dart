import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef ParameterizedAsyncTask<T, R> = Future<R> Function(T? param);

/// Scrolls to the first invalid [FormField] in the subtree rooted at [formContext].
/// Must be called after [Form.validate] so that [FormFieldState.hasError] is up to date.
void scrollToFirstInvalidField(BuildContext formContext) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    bool found = false;
    void visitor(Element element) {
      if (found) return;
      if (element is StatefulElement && element.state is FormFieldState) {
        if ((element.state as FormFieldState).hasError) {
          found = true;
          Scrollable.ensureVisible(
            element,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: 0.1,
          );
          return;
        }
      }
      element.visitChildren(visitor);
    }
    (formContext as Element).visitChildren(visitor);
  });
}

extension ExtendedBuildContext on BuildContext {
  /// Clear current context focus.
  /// This is the cleanest, official way.
  void clearFocus() => FocusScope.of(this).unfocus();

  /// Validate the enclosing [Form].
  /// If [scrollToFirstInvalid] is true and validation fails, scrolls to the first invalid field.
  void validateForm({VoidCallback? onSuccess, bool scrollToFirstInvalid = false}) {
    // Clear current focus
    clearFocus();

    // Find closest Form ancestor
    // Throw if no Form ancestor is found
    final form = Form.of(this);

    // Validate form
    if (form.validate()) {
      form.save();
      onSuccess?.call();
    } else if (scrollToFirstInvalid) {
      scrollToFirstInvalidField(this);
    }
  }
}
