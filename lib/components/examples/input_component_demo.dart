import 'package:flutter/material.dart';
import 'package:nib_components/nib_components.dart';

import '../component_settings.dart';

/// A controller-owned field. Inspector changes keep the same editing session.
class InputComponentDemo extends StatefulWidget {
  const InputComponentDemo({
    super.key,
    required this.settings,
    required this.onChanged,
    required this.onEvent,
  });

  final ComponentSettings settings;
  final ValueChanged<ComponentSettings> onChanged;
  final ValueChanged<String> onEvent;

  @override
  State<InputComponentDemo> createState() => _InputComponentDemoState();
}

class _InputComponentDemoState extends State<InputComponentDemo> {
  final _form = GlobalKey<FormState>();
  final _focus = FocusNode(debugLabel: 'Component example text field');
  late final TextEditingController _controller;
  bool _syncingSettings = false;
  String? _validationMessage;

  bool get _multiline => widget.settings.variant == 'multiline';
  int get _limit => widget.settings.value.round().clamp(3, 280);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.settings.text);
  }

  @override
  void didUpdateWidget(covariant InputComponentDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.settings.text == _controller.text) return;
    // An explicit inspector text edit replaces text. Style edits never assign
    // controller.value, so the cursor, selection and IME composition survive.
    final text = widget.settings.text;
    final selection = _controller.selection;
    _syncingSettings = true;
    _controller.value = TextEditingValue(
      text: text,
      selection: selection.isValid
          ? TextSelection(
              baseOffset: selection.baseOffset.clamp(0, text.length),
              extentOffset: selection.extentOffset.clamp(0, text.length),
            )
          : TextSelection.collapsed(offset: text.length),
    );
    _syncingSettings = false;
    _validationMessage = null;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _edited(String text) {
    if (_syncingSettings) return;
    setState(() => _validationMessage = null);
    widget.onChanged(widget.settings.change('text', text));
    widget.onEvent('Text changed: ${text.length} characters');
  }

  void _validate() {
    final valid = _form.currentState!.validate();
    final message = valid
        ? 'Valid. This example keeps your text on this page.'
        : 'Check the field message, then try again.';
    setState(() => _validationMessage = message);
    widget.onEvent(valid ? 'Validation passed' : 'Validation failed');
  }

  void _clear() {
    _controller.clear();
    _focus.requestFocus();
    widget.onEvent('Field cleared');
  }

  @override
  Widget build(BuildContext context) {
    final validator = NibValidators.compose([
      NibValidators.required(_multiline ? 'Enter a message.' : 'Enter a name.'),
      NibValidators.minLength(3, 'Use at least 3 characters.'),
      NibValidators.maxLength(_limit, 'Use no more than $_limit characters.'),
    ]);
    final theme = NibTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_multiline)
                NibTextarea(
                  key: const ValueKey('component-textarea'),
                  controller: _controller,
                  focusNode: _focus,
                  label: 'Message',
                  placeholder: 'What are you making?',
                  helperText: '3–$_limit characters. New lines are welcome.',
                  minLines: 3,
                  maxLines: 5,
                  maxLength: _limit,
                  showCounter: true,
                  validator: validator,
                  disabled: widget.settings.disabled,
                  animated: widget.settings.animated,
                  borderRadius: BorderRadius.circular(widget.settings.radius),
                  onChanged: _edited,
                )
              else
                NibInput(
                  key: const ValueKey('component-input'),
                  controller: _controller,
                  focusNode: _focus,
                  label: 'Display name',
                  placeholder: 'Ada Lovelace',
                  helperText:
                      '3–$_limit characters. Nothing is sent to a server.',
                  prefixIcon: const Icon(Icons.person_outline),
                  clearable: true,
                  maxLength: _limit,
                  validator: validator,
                  disabled: widget.settings.disabled,
                  animated: widget.settings.animated,
                  borderRadius: BorderRadius.circular(widget.settings.radius),
                  textInputAction: TextInputAction.done,
                  onChanged: _edited,
                  onSubmitted: (_) => _validate(),
                ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  NibButton(
                    label: 'Validate',
                    onPressed: widget.settings.disabled ? null : _validate,
                  ),
                  NibButton(
                    label: 'Clear field',
                    variant: NibButtonVariant.outline,
                    onPressed: widget.settings.disabled ? null : _clear,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Semantics(
                liveRegion: true,
                child: Text(
                  _validationMessage ??
                      'Type a value, clear it, or check the validation rule.',
                  style: TextStyle(color: theme.mutedForeground, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
