import 'package:flutter/material.dart';

/// A [Form] that tracks for changes and may prevent pop.
/// Current implementation just track if form has been modified once (calling [Form.save()] doesn't reset status).
class GuardedForm extends StatefulWidget {
  const GuardedForm({
    super.key,
    this.onChanged,
    this.onUnsavedFormPop,
    required this.child,
  });

  /// Called when one of the form fields changes.
  final VoidCallback? onChanged;

  /// Called when current route tries to pop with unsaved changes.
  /// Return `true` to allow pop, `false` or `null` to prevent pop.
  /// Usually used to show a dialog to confirm pop.
  /// If null, will not prevent pop (behavior disabled, acts like a normal [Form]).
  final Future<bool?> Function()? onUnsavedFormPop;

  /// The form content.
  final Widget child;

  @override
  State<GuardedForm> createState() => _GuardedFormState();
}

class _GuardedFormState extends State<GuardedForm> {
  bool _canPop = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      canPop: _canPop || widget.onUnsavedFormPop == null,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = widget.onUnsavedFormPop == null ? true : (await widget.onUnsavedFormPop!() ?? false);
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop(result);
        }
      },
      onChanged: () {
        widget.onChanged?.call();
        if (_canPop) {
          setState(() => _canPop = false);
        }
      },
      child: widget.child,
    );
  }
}
