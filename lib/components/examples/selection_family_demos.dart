import 'package:flutter/material.dart';
import 'package:nib_components/nib_components.dart';
import 'package:nib_motion/nib_motion.dart';

import '../component_settings.dart';
import '../component_toggle.dart';

abstract class _SelectionDemo extends StatelessWidget {
  const _SelectionDemo({
    super.key,
    required this.settings,
    required this.onChanged,
    required this.onEvent,
  });
  final ComponentSettings settings;
  final ValueChanged<ComponentSettings> onChanged;
  final ValueChanged<String> onEvent;
  String get family;
  @override
  Widget build(BuildContext context) => _SelectionRuntime(
    key: ValueKey(family),
    family: family,
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  );
}

class ButtonComponentDemo extends _SelectionDemo {
  const ButtonComponentDemo({
    super.key,
    required super.settings,
    required super.onChanged,
    required super.onEvent,
  });
  @override
  String get family => 'button';
}

class CheckboxComponentDemo extends _SelectionDemo {
  const CheckboxComponentDemo({
    super.key,
    required super.settings,
    required super.onChanged,
    required super.onEvent,
  });
  @override
  String get family => 'checkbox';
}

class SwitchComponentDemo extends _SelectionDemo {
  const SwitchComponentDemo({
    super.key,
    required super.settings,
    required super.onChanged,
    required super.onEvent,
  });
  @override
  String get family => 'switch';
}

class RadioGroupComponentDemo extends _SelectionDemo {
  const RadioGroupComponentDemo({
    super.key,
    required super.settings,
    required super.onChanged,
    required super.onEvent,
  });
  @override
  String get family => 'radio-group';
}

class ToggleGroupComponentDemo extends _SelectionDemo {
  const ToggleGroupComponentDemo({
    super.key,
    required super.settings,
    required super.onChanged,
    required super.onEvent,
  });
  @override
  String get family => 'toggle-group';
}

class SliderComponentDemo extends _SelectionDemo {
  const SliderComponentDemo({
    super.key,
    required super.settings,
    required super.onChanged,
    required super.onEvent,
  });
  @override
  String get family => 'slider';
}

class SelectComponentDemo extends _SelectionDemo {
  const SelectComponentDemo({
    super.key,
    required super.settings,
    required super.onChanged,
    required super.onEvent,
  });
  @override
  String get family => 'select';
}

class ComboboxComponentDemo extends _SelectionDemo {
  const ComboboxComponentDemo({
    super.key,
    required super.settings,
    required super.onChanged,
    required super.onEvent,
  });
  @override
  String get family => 'combobox';
}

class DatePickerComponentDemo extends _SelectionDemo {
  const DatePickerComponentDemo({
    super.key,
    required super.settings,
    required super.onChanged,
    required super.onEvent,
  });
  @override
  String get family => 'date-picker';
}

class OtpInputComponentDemo extends _SelectionDemo {
  const OtpInputComponentDemo({
    super.key,
    required super.settings,
    required super.onChanged,
    required super.onEvent,
  });
  @override
  String get family => 'otp-input';
}

class _SelectionRuntime extends StatefulWidget {
  const _SelectionRuntime({
    super.key,
    required this.family,
    required this.settings,
    required this.onChanged,
    required this.onEvent,
  });
  final String family;
  final ComponentSettings settings;
  final ValueChanged<ComponentSettings> onChanged;
  final ValueChanged<String> onEvent;
  @override
  State<_SelectionRuntime> createState() => _SelectionRuntimeState();
}

class _SelectionRuntimeState extends State<_SelectionRuntime> {
  NibSelectController<String>? _select;
  NibComboboxController<String>? _combo;
  NibDatePickerController? _date;
  NibOtpController? _otp;
  bool _syncing = false;
  int _activations = 0;
  String _result = 'Ready';
  ComponentSettings get s => widget.settings;
  // Original site SVG artwork rasterized locally; embedded so copied examples
  // need no network, asset declaration, or SVG rendering dependency.

  static const _fruits = ['apple', 'banana', 'cherry'];
  static const _selectOptions = [
    NibSelectOption(
      value: 'apple',
      label: 'Apple',
      subtitle: 'Crisp and sweet',
    ),
    NibSelectOption(value: 'banana', label: 'Banana'),
    NibSelectOption(value: 'cherry', label: 'Cherry'),
    NibSelectOption(value: 'sold-out', label: 'Sold out', disabled: true),
  ];
  static const _comboOptions = [
    NibComboboxOption(
      value: 'apple',
      label: 'Apple',
      subtitle: 'Crisp and sweet',
    ),
    NibComboboxOption(value: 'banana', label: 'Banana'),
    NibComboboxOption(value: 'cherry', label: 'Cherry'),
    NibComboboxOption(value: 'sold-out', label: 'Sold out', disabled: true),
  ];

  @override
  void initState() {
    super.initState();
    switch (widget.family) {
      case 'select':
        _select = NibSelectController<String>();
      case 'combobox':
        _combo = NibComboboxController<String>();
      case 'date-picker':
        _date = NibDatePickerController(displayedMonth: DateTime(2026, 10));
      case 'otp-input':
        _otp = NibOtpController();
    }
    _applyText();
  }

  @override
  void didUpdateWidget(covariant _SelectionRuntime oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.text != s.text ||
        oldWidget.settings.multiple != s.multiple) {
      _applyText();
    }
    if (widget.family == 'date-picker' &&
        (oldWidget.settings.variant != s.variant ||
            oldWidget.settings.backdrop != s.backdrop)) {
      _date!.close();
    }
  }

  void _applyText() {
    _syncing = true;
    final values = s.text.split(',').where(_fruits.contains).toList();
    if (!s.multiple && values.length > 1) values.removeRange(1, values.length);
    _select?.setSelection(values);
    _combo?.clear();
    for (final value in values) {
      _combo?.toggle(value);
    }
    if (_date != null) {
      final dates = s.text
          .split(',')
          .map(DateTime.tryParse)
          .whereType<DateTime>()
          .toList();
      _date!.setSingle(dates.isEmpty ? null : dates.first);
      _date!.setRange(
        dates.isEmpty
            ? null
            : NibDateRange(
                start: dates.first,
                end: dates.length > 1 ? dates.last : null,
              ),
      );
      _date!.setMulti(dates);
    }
    _otp?.setValue(_digits(s.text));
    _syncing = false;
  }

  String _digits(String text) {
    final value = text.replaceAll(RegExp(r'[^0-9]'), '');
    return value.substring(0, value.length.clamp(0, 6));
  }

  String _iso(DateTime date) => date.toIso8601String().split('T').first;
  void _event(String event) {
    if (_syncing) return;
    setState(() => _result = event);
    widget.onEvent(event);
  }

  void _change(String key, Object value, String event) {
    if (_syncing) return;
    widget.onChanged(s.change(key, value));
    _event(event);
  }

  @override
  void dispose() {
    _select?.dispose();
    _combo?.dispose();
    _date?.dispose();
    _otp?.dispose();
    super.dispose();
  }

  Widget _reset(VoidCallback callback) => NibButton(
    key: ValueKey('${widget.family}-clear'),
    label: 'Clear selection',
    variant: NibButtonVariant.outline,
    disabled: s.disabled,
    onPressed: s.disabled ? null : callback,
  );

  Widget _button() {
    final variant =
        NibButtonVariant.values.where((v) => v.name == s.variant).firstOrNull ??
        NibButtonVariant.primary;
    final size =
        NibButtonSize.values.where((v) => v.name == s.backdrop).firstOrNull ??
        NibButtonSize.md;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NibButton(
          key: const ValueKey('button-action'),
          label: s.text,
          variant: variant,
          size: size,
          disabled: s.disabled,
          loading: s.multiple,
          loadingText: 'Saving…',
          animated: s.animated,
          pill: s.vertical,
          expand: s.interactive,
          borderRadius: BorderRadius.circular(s.radius),
          leadingIcon: const Icon(Icons.check),
          onPressed: () {
            _activations++;
            _event('Saved locally: $_activations');
          },
        ),
        const SizedBox(height: 12),
        Text('Activations: $_activations'),
      ],
    );
  }

  Widget _checkbox() => NibCheckbox(
    key: const ValueKey('checkbox-action'),
    label: s.text,
    description: s.multiple
        ? 'False → true → mixed → false.'
        : 'Choose whether to include this item.',
    value: s.multiple && s.value < 0 ? null : s.value > 0,
    tristate: s.multiple,
    disabled: s.disabled,
    animated: s.animated,
    onChanged: (v) => _change(
      'value',
      v == null ? -1.0 : (v ? 1.0 : 0.0),
      'Checked: ${v ?? 'mixed'}',
    ),
  );
  Widget _switch() => NibSwitch(
    key: const ValueKey('switch-action'),
    label: s.text,
    description: 'Enable updates for this local workspace.',
    value: s.value > 0,
    loading: s.multiple,
    disabled: s.disabled,
    animated: s.animated,
    transition: const NibTransition(
      duration: Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    ),
    onThumbIcon: s.variant == 'images'
        ? Image.memory(
            nibSwitchLogo,
            key: const ValueKey('switch-image-on'),
            excludeFromSemantics: true,
            fit: BoxFit.contain,
          )
        : s.variant == 'icons'
        ? const Icon(Icons.check, size: 12)
        : null,
    offThumbIcon: s.variant == 'images'
        ? Image.memory(
            nibSwitchLogo,
            key: const ValueKey('switch-image-off'),
            excludeFromSemantics: true,
            fit: BoxFit.contain,
          )
        : s.variant == 'icons'
        ? const Icon(Icons.close, size: 12)
        : null,
    trackWidth: 64,
    trackHeight: 36,
    thumbBuilder: s.variant == 'images'
        ? null
        : (context, state) => KeyedSubtree(
            key: ValueKey('switch-full-image-${state.value}'),
            child: nibSwitchThumb(
              context,
              state,
              square: s.variant == 'custom',
              badge: s.variant == 'icons'
                  ? Icon(
                      state.value ? Icons.check_circle : Icons.remove_circle,
                      size: 12,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
            ),
          ),
    onChanged: (v) =>
        _change('value', v ? 1.0 : 0.0, 'Updates: ${v ? 'on' : 'off'}'),
  );
  Widget _radio() => NibRadioGroup<String>(
    options: const [
      NibRadioOption(
        value: 'daily',
        label: 'Daily',
        description: 'One digest each day.',
      ),
      NibRadioOption(
        value: 'weekly',
        label: 'Weekly',
        description: 'A calmer weekly summary.',
      ),
      NibRadioOption(
        value: 'instant',
        label: 'Instant',
        description: 'Unavailable in this fixture.',
        disabled: true,
      ),
    ],
    value: ['daily', 'weekly'].contains(s.text) ? s.text : null,
    disabled: s.disabled,
    animated: s.animated,
    direction: s.vertical ? Axis.vertical : Axis.horizontal,
    semanticLabel: 'Digest frequency',
    optionBuilder: s.variant == 'cards'
        ? (context, option, selected, disabled) => Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 20,
                  color: disabled
                      ? NibTheme.of(context).mutedForeground
                      : NibTheme.of(context).primary,
                ),
                const SizedBox(width: 8),
                Flexible(child: Text(option.label)),
              ],
            ),
          )
        : null,
    onChanged: (v) => _change('text', v, 'Digest: $v'),
  );
  Widget _toggle() {
    const options = [
      NibToggleOption(value: 'bold', label: 'Bold'),
      NibToggleOption(value: 'italic', label: 'Italic'),
      NibToggleOption(value: 'locked', label: 'Locked', disabled: true),
    ];
    final values = s.text
        .split(',')
        .where((v) => ['bold', 'italic'].contains(v))
        .toSet();
    final direction = s.vertical ? Axis.vertical : Axis.horizontal;
    if (s.multiple) {
      return NibToggleGroup<String>.multiple(
        options: options,
        values: values,
        direction: direction,
        disabled: s.disabled,
        animated: s.animated,
        semanticLabel: 'Text styles',
        onChanged: (next) => _change(
          'text',
          (next.toList()..sort()).join(','),
          'Styles: ${(next.toList()..sort()).join(', ')}',
        ),
      );
    }
    return NibToggleGroup<String>(
      options: options,
      value: values.firstOrNull,
      direction: direction,
      disabled: s.disabled,
      animated: s.animated,
      semanticLabel: 'Text style',
      onChanged: (next) =>
          _change('text', next ?? '', 'Style: ${next ?? 'none'}'),
    );
  }

  Widget _slider() {
    final axis = s.vertical ? Axis.vertical : Axis.horizontal;
    final value = s.value.clamp(0.0, 100.0);
    final end =
        double.tryParse(s.text)?.clamp(value, 100.0) ??
        85.0.clamp(value, 100.0);
    Widget thumb(BuildContext context, NibSliderThumbState state) => Container(
      decoration: BoxDecoration(
        color: NibTheme.of(context).primary,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Icon(
        state.dragging ? Icons.open_with : Icons.drag_indicator,
        size: state.size * .7,
        color: NibTheme.of(context).primaryForeground,
      ),
    );
    final slider = s.multiple
        ? NibSlider.range(
            values: NibRangeValues(value, end),
            min: 0,
            max: 100,
            divisions: s.searchable ? 10 : null,
            showValueLabel: true,
            axis: axis,
            disabled: s.disabled,
            animated: s.animated,
            label: 'Price range',
            thumbBuilder: s.variant == 'custom' ? thumb : null,
            onChanged: (v) {
              widget.onChanged(
                s.change('value', v.start).change('text', v.end.toString()),
              );
              _event('Range: ${v.start.round()}–${v.end.round()}');
            },
            onChangeEnd: (v) =>
                _event('Committed range: ${v.start.round()}–${v.end.round()}'),
          )
        : NibSlider(
            value: value,
            min: 0,
            max: 100,
            divisions: s.searchable ? 10 : null,
            showValueLabel: true,
            axis: axis,
            disabled: s.disabled,
            animated: s.animated,
            label: 'Volume',
            thumbBuilder: s.variant == 'custom' ? thumb : null,
            onChanged: (v) => _change('value', v, 'Volume: ${v.round()}'),
            onChangeEnd: (v) => _event('Committed volume: ${v.round()}'),
          );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.multiple
              ? 'Range: ${value.round()}–${end.round()}'
              : 'Volume: ${value.round()}',
        ),
        SizedBox(
          height: s.vertical ? 220 : 90,
          width: s.vertical ? 90 : double.infinity,
          child: slider,
        ),
      ],
    );
  }

  Widget _selectDemo() => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      NibSelect<String>(
        controller: _select,
        options: s.variant == 'grouped' ? null : _selectOptions,
        groups: s.variant == 'grouped'
            ? const [
                NibSelectGroup(label: 'Available', options: _selectOptions),
              ]
            : null,
        multiSelect: s.multiple,
        searchable: s.searchable,
        clearable: true,
        disabled: s.disabled,
        loading: !s.interactive,
        animated: s.animated,
        animation:
            NibSelectAnimation.values
                .where((preset) => preset.name == s.backdrop)
                .firstOrNull ??
            NibSelectAnimation.fadeScale,
        placeholder: 'Choose fruit',
        semanticLabel: 'Fruit selection',
        noResultsBuilder: (_) => const Padding(
          padding: EdgeInsets.all(12),
          child: Text('No fruit matches. Try Apple.'),
        ),
        onSelectionChanged: (v) =>
            _change('text', v.join(','), 'Selected: ${v.join(', ')}'),
      ),
      const SizedBox(height: 12),
      _reset(() {
        _select!.clear();
        _change('text', '', 'Selection cleared');
      }),
    ],
  );
  Widget _comboboxDemo() => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      NibCombobox<String>(
        controller: _combo,
        options: _comboOptions,
        multiSelect: s.multiple,
        allowFreeText: s.variant == 'free-text',
        asyncOptionsLoader: s.variant == 'async'
            ? (query) async {
                await Future<void>.delayed(const Duration(milliseconds: 220));
                return _comboOptions
                    .where(
                      (o) =>
                          o.label.toLowerCase().contains(query.toLowerCase()),
                    )
                    .toList();
              }
            : null,
        filter: s.variant == 'prefix'
            ? (option, query) =>
                  option.label.toLowerCase().startsWith(query.toLowerCase())
            : null,
        debounceDuration: const Duration(milliseconds: 150),
        placeholder: 'Find fruit',
        disabled: s.disabled,
        loading: !s.interactive,
        animated: s.animated,
        clearable: true,
        onSelectionChanged: (v) =>
            _change('text', v.join(','), 'Selected: ${v.join(', ')}'),
        onFreeTextSubmitted: (v) => _event('Free text: $v'),
      ),
      const SizedBox(height: 12),
      _reset(() {
        _combo!.clear();
        _change('text', '', 'Selection cleared');
      }),
      if (s.variant == 'async')
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text('Local fixture loader: 220 ms. No network request.'),
        ),
    ],
  );
  Widget _dateDemo() {
    final mode =
        NibDatePickerMode.values
            .where((v) => v.name == s.variant)
            .firstOrNull ??
        NibDatePickerMode.single;
    final display =
        NibDatePickerDisplayMode.values
            .where((v) => v.name == s.backdrop)
            .firstOrNull ??
        NibDatePickerDisplayMode.inline;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NibDatePicker(
          controller: _date,
          mode: mode,
          displayMode: display,
          disabled: s.disabled,
          animated: s.animated,
          minDate: DateTime(2026, 10, 1),
          maxDate: DateTime(2026, 12, 31),
          dayBuilder: s.searchable
              ? (context, day) => Text(
                  '${day.date.day}',
                  style: TextStyle(
                    fontWeight: day.selected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: day.disabled
                        ? NibTheme.of(context).mutedForeground
                        : NibTheme.of(context).foreground,
                  ),
                )
              : null,
          disabledDayPredicate: s.multiple
              ? (day) => day.weekday == DateTime.sunday
              : null,
          cellShape: s.vertical
              ? NibDateCellShape.rounded
              : NibDateCellShape.circle,
          onDateChanged: (v) => _change(
            'text',
            v == null ? '' : _iso(v),
            'Date: ${v == null ? 'none' : _iso(v)}',
          ),
          onRangeChanged: (r) => _change(
            'text',
            r == null
                ? ''
                : [_iso(r.start), if (r.end != null) _iso(r.end!)].join(','),
            'Range ${r?.isComplete == true ? 'complete' : 'started'}',
          ),
          onDatesChanged: (v) =>
              _change('text', v.map(_iso).join(','), 'Dates: ${v.length}'),
        ),
        const SizedBox(height: 12),
        _reset(() {
          _date!.clear();
          _change('text', '', 'Dates cleared');
        }),
        const SizedBox(height: 8),
        const Text('Fixture calendar: October–December 2026.'),
      ],
    );
  }

  Widget _otpDemo() => LayoutBuilder(
    builder: (context, constraints) {
      final cellWidth = ((constraints.maxWidth - 5 * 6) / 6).clamp(20.0, 44.0);
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NibOtpInput(
            length: 6,
            controller: _otp,
            cellWidth: cellWidth,
            spacing: 6,
            keyboard: s.variant == 'keypad'
                ? NibOtpKeyboard.onScreen
                : NibOtpKeyboard.system,
            obscureText: s.multiple,
            enabled: !s.disabled,
            loading: !s.interactive,
            animated: s.animated,
            semanticLabel: 'Six-digit demo code',
            errorText: s.backdrop == 'error'
                ? 'Demo error: try another code.'
                : null,
            keypadStyle: const NibOtpKeypadStyle(
              keyWidth: 56,
              keyHeight: 44,
              horizontalSpacing: 8,
              verticalSpacing: 8,
              maxWidth: 230,
            ),
            onChanged: (v) =>
                _change('text', v, 'Digits entered: ${v.length}/6'),
            onCompleted: (_) =>
                _event('Six digits entered. This demo does not verify codes.'),
            onConfirm: (_) => _event('Confirmation requested locally'),
          ),
          const SizedBox(height: 12),
          NibButton(
            label: 'Clear code',
            variant: NibButtonVariant.outline,
            disabled: s.disabled,
            onPressed: s.disabled
                ? null
                : () {
                    _otp!.clear();
                    _change('text', '', 'Code cleared');
                  },
          ),
        ],
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final content = switch (widget.family) {
      'button' => _button(),
      'checkbox' => _checkbox(),
      'switch' => _switch(),
      'radio-group' => _radio(),
      'toggle-group' => _toggle(),
      'slider' => _slider(),
      'select' => _selectDemo(),
      'combobox' => _comboboxDemo(),
      'date-picker' => _dateDemo(),
      'otp-input' => _otpDemo(),
      _ => const SizedBox.shrink(),
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        content,
        const SizedBox(height: 16),
        Semantics(
          liveRegion: true,
          child: Text(
            _result,
            key: ValueKey('${widget.family}-result'),
            style: TextStyle(color: NibTheme.of(context).mutedForeground),
          ),
        ),
      ],
    );
  }
}
