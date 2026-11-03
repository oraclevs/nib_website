import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nib_components/nib_components.dart';

import '../component_settings.dart';

abstract class _OverlayDemo extends StatefulWidget {
  const _OverlayDemo({
    super.key,
    required this.settings,
    required this.onChanged,
    required this.onEvent,
  });
  final ComponentSettings settings;
  final ValueChanged<ComponentSettings> onChanged;
  final ValueChanged<String> onEvent;
}

class _OverlayPanel extends StatelessWidget {
  const _OverlayPanel({
    required this.description,
    required this.children,
    required this.status,
  });
  final String description, status;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(description),
      const SizedBox(height: 20),
      Wrap(spacing: 12, runSpacing: 12, children: children),
      const SizedBox(height: 20),
      Semantics(
        liveRegion: true,
        child: Text(status, key: const ValueKey('overlay-status')),
      ),
    ],
  );
}

class AlertDialogComponentDemo extends _OverlayDemo {
  const AlertDialogComponentDemo({
    super.key,
    required super.settings,
    required super.onChanged,
    required super.onEvent,
  });
  @override
  State<AlertDialogComponentDemo> createState() =>
      _AlertDialogComponentDemoState();
}

class _AlertDialogComponentDemoState extends State<AlertDialogComponentDemo> {
  String _status = 'No decision yet';
  bool _opening = false;
  VoidCallback? _close;
  Future<void> _open() async {
    if (_opening) return;
    setState(() => _opening = true);
    final severity = NibAlertSeverity.values.firstWhere(
      (v) => v.name == widget.settings.variant,
      orElse: () => NibAlertSeverity.info,
    );
    final result = await showNibAlertDialog(
      context,
      severity: severity,
      animated: widget.settings.animated,
      barrierDismissible: widget.settings.interactive,
      adaptive: widget.settings.multiple,
      confirmText: 'Apply locally',
      cancelText: 'Keep current',
      content: Builder(
        builder: (dialogContext) {
          final scope = NibDialogScope.of(dialogContext);
          _close = () => scope.close();
          final theme = NibTheme.of(dialogContext);
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(severity.defaultIcon(), color: severity.accent(theme)),
              const SizedBox(height: 12),
              Text(
                widget.settings.text,
                style: Theme.of(dialogContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Apply this label to the local preview? No request is sent.',
              ),
            ],
          );
        },
      ),
    );
    _close = null;
    if (!mounted) return;
    setState(() {
      _opening = false;
      _status = result == true
          ? 'Applied locally'
          : result == false
          ? 'Kept current label'
          : 'Dismissed without a decision';
    });
    widget.onEvent(_status);
  }

  @override
  void dispose() {
    _close?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _OverlayPanel(
    description:
        'Confirm a local change, cancel it, or dismiss without a decision.',
    status: _status,
    children: [
      NibButton(label: 'Review change', onPressed: _opening ? null : _open),
    ],
  );
}

class DialogComponentDemo extends _OverlayDemo {
  const DialogComponentDemo({
    super.key,
    required super.settings,
    required super.onChanged,
    required super.onEvent,
  });
  @override
  State<DialogComponentDemo> createState() => _DialogComponentDemoState();
}

class _DialogComponentDemoState extends State<DialogComponentDemo> {
  final _controller = NibDialogController();
  NibDialogHandle<String>? _handle;
  VoidCallback? _close;
  bool _opening = false;
  String _status = 'No result yet';
  NibDialogSize get _size => NibDialogSize.values.firstWhere(
    (v) => v.name == widget.settings.backdrop,
    orElse: () => NibDialogSize.md,
  );
  NibDialogAnimation get _animation => NibDialogAnimation.values.firstWhere(
    (v) => v.name == widget.settings.variant,
    orElse: () => NibDialogAnimation.fadeScale,
  );
  Widget get _body => Builder(
    builder: (dialogContext) {
      final scope = NibDialogScope.of(dialogContext);
      _close = () => scope.close();
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose the draft title. The result stays in this preview.',
          ),
          const SizedBox(height: 16),
          NibButton(
            label: 'Use this title',
            onPressed: () =>
                NibDialogScope.of(dialogContext).close('Draft selected'),
          ),
        ],
      );
    },
  );
  Future<void> _open(bool withHandle) async {
    if (_opening || _controller.isOpen) return;
    setState(() => _opening = true);
    Future<String?> result;
    if (withHandle) {
      _handle = openNibDialog<String>(
        context,
        title: widget.settings.text,
        content: _body,
        size: _size,
        animation: _animation,
        animated: widget.settings.animated,
        barrierDismissible: widget.settings.interactive,
      );
      result = _handle!.closed;
    } else {
      result = showNibDialog<String>(
        context,
        title: widget.settings.text,
        content: _body,
        size: _size,
        animation: _animation,
        animated: widget.settings.animated,
        barrierDismissible: widget.settings.interactive,
      );
    }
    final selected = await result;
    _close = null;
    _handle = null;
    if (!mounted) return;
    setState(() {
      _opening = false;
      _status = selected ?? 'Dialog dismissed';
    });
    widget.onEvent(_status);
  }

  @override
  void dispose() {
    _close?.call();
    _handle?.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      NibDialog(
        controller: _controller,
        title: widget.settings.text,
        content: _body,
        size: _size,
        animation: _animation,
        animated: widget.settings.animated,
        barrierDismissible: widget.settings.interactive,
        onClose: () {
          _close = null;
          if (mounted) {
            setState(() => _status = 'Controlled dialog closed');
            widget.onEvent(_status);
          }
        },
      ),
      _OverlayPanel(
        description: 'Compare a returned Future, an explicit handle, and a widget-owned surface.',
        status: _status,
        children: [
          NibButton(label: 'Open dialog', onPressed: () => _open(false)),
          NibButton(
            label: 'Open with handle',
            variant: NibButtonVariant.outline,
            onPressed: () => _open(true),
          ),
          NibButton(
            label: 'Open controlled',
            variant: NibButtonVariant.ghost,
            onPressed: () {
              if (!_opening) _controller.open();
            },
          ),
        ],
      ),
    ],
  );
}

class BottomSheetComponentDemo extends _OverlayDemo {
  const BottomSheetComponentDemo({
    super.key,
    required super.settings,
    required super.onChanged,
    required super.onEvent,
  });
  @override
  State<BottomSheetComponentDemo> createState() =>
      _BottomSheetComponentDemoState();
}

class _BottomSheetComponentDemoState extends State<BottomSheetComponentDemo> {
  final _controller = NibBottomSheetController();
  NibBottomSheetHandle<String>? _handle;
  VoidCallback? _close;
  bool _opening = false;
  String _status = 'No sheet result yet';
  List<double> get _snaps => [widget.settings.value.clamp(30, 60) / 100, .85];
  Widget get _body => Builder(
    builder: (sheetContext) {
      final scope = NibBottomSheetScope.of(sheetContext);
      _close = () => scope.close();
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A small reading list. Drag the handle or choose a snap.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                NibButton(
                  label: 'Expand sheet',
                  onPressed: () {
                    scope.snapTo(1);
                    widget.onEvent('Requested snap 1');
                  },
                ),
                NibButton(
                  label: 'Use reading list',
                  variant: NibButtonVariant.outline,
                  onPressed: () => scope.close('Reading list selected'),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
  void _snapChanged(int index) {
    if (mounted) widget.onEvent('Snap $index');
  }

  Future<void> _open(bool withHandle) async {
    if (_opening || _controller.isOpen) return;
    setState(() => _opening = true);
    Future<String?> result;
    if (withHandle) {
      _handle = openNibBottomSheet<String>(
        context,
        title: widget.settings.text,
        content: _body,
        snapPoints: _snaps,
        initialSnap: 0,
        onSnapChanged: _snapChanged,
        animated: widget.settings.animated,
        dismissible: widget.settings.interactive,
        showDragHandle: widget.settings.showBorder,
      );
      result = _handle!.closed;
    } else {
      result = showNibBottomSheet<String>(
        context,
        title: widget.settings.text,
        content: _body,
        snapPoints: _snaps,
        initialSnap: 0,
        onSnapChanged: _snapChanged,
        animated: widget.settings.animated,
        dismissible: widget.settings.interactive,
        showDragHandle: widget.settings.showBorder,
      );
    }
    final selected = await result;
    _close = null;
    _handle = null;
    if (!mounted) return;
    setState(() {
      _opening = false;
      _status = selected ?? 'Sheet dismissed';
    });
    widget.onEvent(_status);
  }

  @override
  void dispose() {
    _close?.call();
    _handle?.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      NibBottomSheet(
        controller: _controller,
        title: widget.settings.text,
        content: _body,
        snapPoints: _snaps,
        initialSnap: 0,
        onSnapChanged: _snapChanged,
        animated: widget.settings.animated,
        dismissible: widget.settings.interactive,
        showDragHandle: widget.settings.showBorder,
        onClose: () {
          _close = null;
          if (mounted) {
            setState(() => _status = 'Controlled sheet closed');
            widget.onEvent(_status);
          }
        },
      ),
      _OverlayPanel(
        description: 'Two snap heights, a close result, and three ways to own the sheet.',
        status: _status,
        children: [
          NibButton(label: 'Open sheet', onPressed: () => _open(false)),
          NibButton(
            label: 'Open sheet handle',
            variant: NibButtonVariant.outline,
            onPressed: () => _open(true),
          ),
          NibButton(
            label: 'Open controlled sheet',
            variant: NibButtonVariant.ghost,
            onPressed: () {
              if (!_opening) _controller.open();
            },
          ),
        ],
      ),
    ],
  );
}

class PopoverComponentDemo extends _OverlayDemo {
  const PopoverComponentDemo({
    super.key,
    required super.settings,
    required super.onChanged,
    required super.onEvent,
  });
  @override
  State<PopoverComponentDemo> createState() => _PopoverComponentDemoState();
}

class _PopoverComponentDemoState extends State<PopoverComponentDemo> {
  final _controller = NibPopoverController();
  String _status = 'No tag selected';
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _OverlayPanel(
    description: 'Open a small anchored task, then return to the page.',
    status: _status,
    children: [
      NibPopover(
        controller: _controller,
        placement: NibPopoverPlacement.values.firstWhere(
          (v) => v.name == widget.settings.variant,
          orElse: () => NibPopoverPlacement.bottom,
        ),
        maxWidth: widget.settings.value.clamp(180, 360),
        showArrow: widget.settings.showBorder,
        dismissOnOutsideTap: widget.settings.interactive,
        animated: widget.settings.animated,
        semanticLabel: 'Reading tags',
        trigger: NibButton(
          label: 'Choose a tag',
          onPressed: _controller.toggle,
        ),
        onOpen: () => widget.onEvent('Popover opened'),
        onClose: () {
          if (mounted) widget.onEvent('Popover closed');
        },
        content: Builder(
          builder: (popoverContext) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.settings.text),
              const SizedBox(height: 12),
              NibButton(
                label: 'Pick Flutter',
                onPressed: () {
                  setState(() => _status = 'Tag: Flutter');
                  widget.onEvent(_status);
                  NibPopoverScope.of(popoverContext).close();
                },
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class HoverCardComponentDemo extends _OverlayDemo {
  const HoverCardComponentDemo({
    super.key,
    required super.settings,
    required super.onChanged,
    required super.onEvent,
  });
  @override
  State<HoverCardComponentDemo> createState() => _HoverCardComponentDemoState();
}

class _HoverCardComponentDemoState extends State<HoverCardComponentDemo> {
  final _controller = NibHoverCardController();
  String _status = 'Profile closed';
  void _record(String value) {
    if (mounted) {
      setState(() => _status = value);
      widget.onEvent(value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _OverlayPanel(
    description:
        'Hover to inspect. The button also works with a keyboard or touch.',
    status: _status,
    children: [
      NibHoverCard(
        controller: _controller,
        placement: NibHoverCardPlacement.values.firstWhere(
          (v) => v.name == widget.settings.variant,
          orElse: () => NibHoverCardPlacement.bottom,
        ),
        showDelay: Duration(milliseconds: widget.settings.value.round()),
        hideDelay: const Duration(milliseconds: 300),
        animated: widget.settings.animated,
        openOnTap: widget.settings.interactive,
        semanticLabel: 'Contributor profile',
        onOpen: () => _record('Profile opened'),
        onClose: () => _record('Profile closed'),
        trigger: NibButton(
          label: 'Inspect contributor',
          onPressed: _controller.toggle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.settings.text,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Writes examples, reviews patches, and leaves useful notes.',
            ),
            const SizedBox(height: 12),
            NibButton(
              label: 'Close profile',
              variant: NibButtonVariant.outline,
              onPressed: _controller.close,
            ),
          ],
        ),
      ),
    ],
  );
}

class ContextMenuComponentDemo extends _OverlayDemo {
  const ContextMenuComponentDemo({
    super.key,
    required super.settings,
    required super.onChanged,
    required super.onEvent,
  });
  @override
  State<ContextMenuComponentDemo> createState() =>
      _ContextMenuComponentDemoState();
}

class _ContextMenuComponentDemoState extends State<ContextMenuComponentDemo> {
  final _anchor = GlobalKey();
  String _status = 'No menu action';
  bool _opening = false;
  List<NibMenuEntry> get _items => [
    const NibMenuSection('Reading list'),
    NibMenuItem(
      label: 'Pin note',
      icon: const Icon(Icons.push_pin_outlined),
      enabled: !widget.settings.disabled,
    ),
    const NibMenuDivider(),
    const NibMenuItem(
      label: 'Move to',
      submenu: [
        NibMenuItem(label: 'Later'),
        NibMenuItem(label: 'Today'),
      ],
    ),
  ];
  void _selected(NibMenuItem item) {
    if (mounted) {
      setState(() => _status = 'Selected: ${item.label}');
      widget.onEvent(_status);
    }
  }

  Future<void> _show() async {
    if (_opening) return;
    final box = _anchor.currentContext!.findRenderObject()! as RenderBox;
    _opening = true;
    final result = await showNibContextMenu(
      context,
      globalPosition: box.localToGlobal(Offset(0, box.size.height)),
      items: _items,
      animated: widget.settings.animated,
    );
    _opening = false;
    if (result != null) _selected(result);
  }

  @override
  Widget build(BuildContext context) => _OverlayPanel(
    description: 'Right-click or long-press the note. Open menu provides a keyboard-accessible alternative.',
    status: _status,
    children: [
      NibContextMenu(
        items: _items,
        animated: widget.settings.animated,
        onItemSelected: _selected,
        child: Container(
          key: _anchor,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: NibTheme.of(context).border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(widget.settings.text),
        ),
      ),
      NibButton(label: 'Open menu', onPressed: _show),
    ],
  );
}

class CommandPaletteComponentDemo extends _OverlayDemo {
  const CommandPaletteComponentDemo({
    super.key,
    required super.settings,
    required super.onChanged,
    required super.onEvent,
  });
  @override
  State<CommandPaletteComponentDemo> createState() =>
      _CommandPaletteComponentDemoState();
}

class _CommandPaletteComponentDemoState
    extends State<CommandPaletteComponentDemo> {
  final _controller = NibCommandPaletteController();
  int _drafts = 0;
  String _status = 'Drafts: 0';
  void _record(String value) {
    if (mounted) {
      setState(() => _status = value);
      widget.onEvent(value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => NibCommandPalette(
    controller: _controller,
    openShortcut: const SingleActivator(
      LogicalKeyboardKey.keyP,
      alt: true,
      shift: true,
    ),
    animated: widget.settings.animated,
    placeholder: widget.settings.text,
    showRecent: widget.settings.multiple,
    maxRecent: 3,
    filter: widget.settings.searchable
        ? null
        : (action, query) =>
              action.label.toLowerCase().startsWith(query.toLowerCase()),
    onActionSelected: (action) => widget.onEvent('Action: ${action.id}'),
    actions: [
      NibCommandAction(
        id: 'new-draft',
        label: 'Create draft',
        subtitle: 'Add one local draft',
        group: 'Notes',
        disabled: widget.settings.disabled,
        onSelected: () => _record('Drafts: ${++_drafts}'),
      ),
      NibCommandAction(
        id: 'folders',
        label: 'Choose folder',
        group: 'Notes',
        children: [
          NibCommandAction(
            id: 'later',
            label: 'Later folder',
            onSelected: () => _record('Folder: Later'),
          ),
          NibCommandAction(
            id: 'today',
            label: 'Today folder',
            onSelected: () => _record('Folder: Today'),
          ),
        ],
      ),
    ],
    child: _OverlayPanel(
      description: 'Search commands, enter a folder, or use Alt+Shift+P while this example is mounted.',
      status: _status,
      children: [
        NibButton(label: 'Open commands', onPressed: _controller.open),
      ],
    ),
  );
}

class ToastComponentDemo extends _OverlayDemo {
  const ToastComponentDemo({
    super.key,
    required super.settings,
    required super.onChanged,
    required super.onEvent,
  });
  @override
  State<ToastComponentDemo> createState() => _ToastComponentDemoState();
}

class _ToastComponentDemoState extends State<ToastComponentDemo> {
  late final String _id = 'nib-guide-toast-${identityHashCode(this)}';
  String _status = 'No notification';
  int _saves = 0;
  void _record(String value) {
    if (mounted) {
      setState(() => _status = value);
      widget.onEvent(value);
    }
  }

  void _show(BuildContext toastContext) {
    _saves++;
    showNibToast(
      context: toastContext,
      id: _id,
      title: widget.settings.text,
      message: 'Local save $_saves',
      variant: NibToastVariant.values.firstWhere(
        (v) => v.name == widget.settings.variant,
        orElse: () => NibToastVariant.success,
      ),
      position: NibToastPosition.values.firstWhere(
        (v) => v.name == widget.settings.backdrop,
        orElse: () => NibToastPosition.bottomCenter,
      ),
      onDuplicateTrigger: widget.settings.multiple
          ? NibToastDuplicateBehavior.replace
          : NibToastDuplicateBehavior.ignore,
      duration: Duration(milliseconds: widget.settings.value.round()),
      animated: widget.settings.animated,
      actionLabel: 'Undo save',
      onAction: () {
        _record('Save undone');
        dismissNibToast(_id);
      },
      onDismiss: () {
        if (mounted) widget.onEvent('Toast dismissed');
      },
    );
    _record('Save requested: $_saves');
  }

  @override
  void dispose() {
    dismissNibToast(_id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 380,
    child: NibToaster(
      child: Builder(
        builder: (toastContext) => SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: _OverlayPanel(
            description: 'Save twice to inspect duplicate handling. Undo only changes this local preview.',
            status: _status,
            children: [
              NibButton(
                label: 'Save locally',
                onPressed: () => _show(toastContext),
              ),
              NibButton(
                label: 'Dismiss this toast',
                variant: NibButtonVariant.outline,
                onPressed: () => dismissNibToast(_id),
              ),
              NibButton(
                label: 'Dismiss all toasts',
                variant: NibButtonVariant.ghost,
                onPressed: dismissAllNibToasts,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
