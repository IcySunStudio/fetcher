import 'package:flutter/material.dart';

import 'editing_scope.dart';

/// A [Form] that tracks for changes and may prevent pop.
/// Current implementation just track if form has been modified once (calling [Form.save()] doesn't reset status).
/// Call [markAsSaved] to reset status (automatically done by [SubmitFormBuilder] on success).
/// When changed, registers to the closest [EditingScope], until saved or disposed.
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

  /// Marks the closest [GuardedForm] ancestor as saved: allows pop again, and unregisters it from its [EditingScope].
  /// Does nothing if there is no [GuardedForm] ancestor.
  static void markAsSaved(BuildContext context) => context.findAncestorStateOfType<_GuardedFormState>()?._markAsSaved();

  @override
  State<GuardedForm> createState() => _GuardedFormState();
}

class _GuardedFormState extends State<GuardedForm> {
  bool _canPop = true;
  EditingScopeState? _editingScope;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Stored, as ancestors can't be looked up from dispose
    _editingScope = EditingScope.maybeOf(context);
  }

  void _markAsSaved() {
    _editingScope?.unregister(this);
    if (!_canPop) {
      setState(() => _canPop = true);
    }
  }

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
        // Register on every change, so that form is tracked again after an EditingScope.clear()
        _editingScope?.register(this);
        if (_canPop) {
          setState(() => _canPop = false);
        }
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _editingScope?.unregister(this);
    super.dispose();
  }
}
