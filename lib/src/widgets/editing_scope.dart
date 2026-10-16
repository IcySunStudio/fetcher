import 'dart:async';

import 'package:flutter/widgets.dart';

/// Tracks elements being edited in its subtree (e.g. a [GuardedForm] with changes).
/// May be used to delay a data update while user is editing, so that the input isn't lost when the subtree is recreated.
/// [GuardedForm] (and so [SubmitFormBuilder]) automatically registers to the closest [EditingScope] when changed.
/// Nested scopes are supported: an element being edited also marks all ancestor scopes as editing.
/// Must be placed above the subtree that may be recreated.
/// Parent scope is resolved once: moving a scope or a [GuardedForm] to another place in the tree (with a [GlobalKey]) isn't supported.
class EditingScope extends StatefulWidget {
  const EditingScope({
    super.key,
    this.onChanged,
    required this.child,
  });

  /// Called when [EditingScopeState.isEditing] changes.
  /// Called asynchronously (in a microtask), so it's safe to call [State.setState] from it.
  /// Only called if [EditingScopeState.isEditing] actually changed since last call (e.g. an unregister immediately followed by a register is ignored).
  final ValueChanged<bool>? onChanged;

  /// The subtree to track.
  final Widget child;

  /// Returns the closest [EditingScope] ancestor, or null if there is none.
  /// Doesn't register a dependency, so it may be called from [State.initState].
  static EditingScopeState? maybeOf(BuildContext context) => context.getInheritedWidgetOfExactType<_EditingScopeScope>()?.state;

  @override
  EditingScopeState createState() => EditingScopeState();
}

class EditingScopeState extends State<EditingScope> {
  final _owners = <Object>{};
  EditingScopeState? _parent;
  bool _notifiedIsEditing = false;

  /// Whether at least one element is registered.
  bool get isEditing => _owners.isNotEmpty;

  /// Registers [owner] as being edited.
  /// May be called several times.
  void register(Object owner) {
    _owners.add(owner);
    _parent?.register(this);
    _notifyLater();
  }

  /// Unregisters [owner].
  /// May be called several times, and from [State.dispose].
  void unregister(Object owner) {
    _owners.remove(owner);
    if (!isEditing) _parent?.unregister(this);
    _notifyLater();
  }

  /// Unregisters all elements.
  /// Usually used after an action that makes current input useless (e.g. edited item has been deleted).
  /// Registered [GuardedForm]s will register again on their next change.
  void clear() {
    _owners.clear();
    _parent?.unregister(this);
    _notifyLater();
  }

  /// Deferred, as [unregister] is usually called from dispose (locked tree),
  /// and to ignore an unregister immediately followed by a register (e.g. recreated form).
  void _notifyLater() => scheduleMicrotask(() {
    if (!mounted || isEditing == _notifiedIsEditing) return;
    _notifiedIsEditing = isEditing;
    widget.onChanged?.call(isEditing);
  });

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Stored, as ancestors can't be looked up from dispose
    _parent = EditingScope.maybeOf(context);
  }

  @override
  Widget build(BuildContext context) => _EditingScopeScope(state: this, child: widget.child);

  @override
  void dispose() {
    _parent?.unregister(this);
    super.dispose();
  }
}

class _EditingScopeScope extends InheritedWidget {
  const _EditingScopeScope({
    required this.state,
    required super.child,
  });

  final EditingScopeState state;

  @override
  bool updateShouldNotify(_EditingScopeScope oldWidget) => false;
}
