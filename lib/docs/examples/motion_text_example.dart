import '../../components/component_toggle.dart';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nib_motion/nib_motion.dart';

enum TextMotionKind {
  units,
  typewriter,
  gradient,
  reveal,
  revealGradient,
  typingEntrance,
}

/// Each recipe exposes the parameters used by its real Nib widget.
class MotionTextExample extends StatefulWidget {
  const MotionTextExample({
    super.key,
    this.kind = TextMotionKind.units,
    this.unit = NibTextUnit.word,
    this.origin = NibTextStaggerFrom.start,
    this.composed = false,
    this.spring = false,
  });
  final TextMotionKind kind;
  final NibTextUnit unit;
  final NibTextStaggerFrom origin;
  final bool composed;
  final bool spring;

  @override
  State<MotionTextExample> createState() => _MotionTextExampleState();
}

class _MotionTextExampleState extends State<MotionTextExample> {
  late NibTextUnit _unit = widget.unit;
  late NibTextStaggerFrom _origin = widget.origin;
  late String _effect = widget.composed ? 'Compose' : 'Slide';
  late bool _spring = widget.spring;
  final _text = TextEditingController(text: 'Make words\nworth watching.');
  int _generation = 0;
  int _completed = 0;
  bool _playing = true;
  bool _repeat = false;
  bool _reverse = false;
  bool _cool = false;
  bool _copied = false;
  String _cursor = '|';
  String _curve = 'Smooth';
  String _gradientKind = 'Linear';
  NibTextRevealDirection _direction = NibTextRevealDirection.left;
  double _duration = 900;
  double _stagger = 70;
  double _speed = 65;
  double _deleteSpeed = 35;
  double _blink = 530;
  double _delay = 0;

  bool get _units => widget.kind == TextMotionKind.units;
  bool get _typing =>
      widget.kind == TextMotionKind.typewriter ||
      widget.kind == TextMotionKind.typingEntrance;
  bool get _gradient =>
      widget.kind == TextMotionKind.gradient ||
      widget.kind == TextMotionKind.revealGradient;
  bool get _reveal =>
      widget.kind == TextMotionKind.reveal ||
      widget.kind == TextMotionKind.revealGradient;
  String get _sentence => _unit == NibTextUnit.line && _units
      ? _text.text
      : _text.text.replaceAll('\n', ' ');

  void _change(VoidCallback action) => setState(() {
    action();
    _generation++;
    _completed = 0;
    _copied = false;
    _playing = true;
  });

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  NibAnim get _initial => switch (_effect) {
    'Fade' => const NibAnim(opacity: 0),
    'Scale' => const NibAnim(opacity: 0, scale: .5),
    'Rotate' => const NibAnim(opacity: 0, rotate: -.45),
    'Blur' => const NibAnim(opacity: 0, blur: 8),
    'Compose' => const NibAnim(
      opacity: 0,
      x: -10,
      y: 18,
      scale: .75,
      rotate: -.15,
      blur: 4,
    ),
    _ => const NibAnim(opacity: 0, y: 22),
  };

  Curve get _easing => switch (_curve) {
    'Linear' => Curves.linear,
    'Ease out' => Curves.easeOutCubic,
    _ => Curves.easeInOutCubic,
  };

  Gradient get _colors {
    final colors = _cool
        ? const [Color(0xFFCFDEA0), Color(0xFFF4E8C8), Color(0xFFCFDEA0)]
        : const [Color(0xFFFFB51B), Color(0xFFFFAEA3), Color(0xFFFFB51B)];
    return switch (_gradientKind) {
      'Radial' => RadialGradient(colors: colors),
      'Sweep' => SweepGradient(colors: colors),
      _ => LinearGradient(colors: colors),
    };
  }

  String get _configuration {
    final text = jsonEncode(_sentence).replaceAll(r'$', r'\$');
    const style =
        'TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: Color(0xFFFFB51B), height: 1.4)';
    final curve = switch (_curve) {
      'Linear' => 'Curves.linear',
      'Ease out' => 'Curves.easeOutCubic',
      _ => 'Curves.easeInOutCubic',
    };
    String child;
    if (_units) {
      final initial = switch (_effect) {
        'Fade' => 'NibAnim(opacity: 0)',
        'Scale' => 'NibAnim(opacity: 0, scale: .5)',
        'Rotate' => 'NibAnim(opacity: 0, rotate: -.45)',
        'Blur' => 'NibAnim(opacity: 0, blur: 8)',
        'Compose' => 'NibAnim(opacity: 0, x: -10, y: 18, scale: .75, rotate: -.15, blur: 4)',
        _ => 'NibAnim(opacity: 0, y: 22)',
      };
      final transition = _spring
          ? 'NibTransition.springGentle'
          : 'NibTransition(duration: Duration(milliseconds: ${_duration.round()}), curve: $curve)';
      child =
          '''NibText($text,
  style: const $style,
  textAlign: TextAlign.center,
  config: NibTextConfig(
    unit: NibTextUnit.${_unit.name},
    staggerFrom: NibTextStaggerFrom.${_origin.name},
    staggerDelay: const Duration(milliseconds: ${_stagger.round()}),
    initial: const $initial,
    animate: NibAnim.identity,
    transition: $transition,
  ),
)''';
    } else if (_typing) {
      child =
          '''NibTypewriter($text,
  style: const $style,
  speed: const Duration(milliseconds: ${_speed.round()}),
  deleteSpeed: const Duration(milliseconds: ${_deleteSpeed.round()}),
  cursor: ${_cursor == 'None' ? 'null' : jsonEncode(_cursor)},
  cursorBlinkInterval: const Duration(milliseconds: ${_blink.round()}),
  delay: const Duration(milliseconds: ${_delay.round()}),
  repeat: $_repeat,
  onComplete: () => debugPrint('Typing complete'),
)''';
      if (widget.kind == TextMotionKind.typingEntrance) {
        child =
            '''NibMotion(
  initial: const NibAnim(y: 20, opacity: 0, scale: .9),
  animate: NibAnim.identity,
  transition: NibTransition.springGentle,
  child: $child,
)''';
      }
    } else if (_gradient) {
      final colors = _cool
          ? 'Color(0xFFCFDEA0), Color(0xFFF4E8C8), Color(0xFFCFDEA0)'
          : 'Color(0xFFFFB51B), Color(0xFFFFAEA3), Color(0xFFFFB51B)';
      child =
          '''NibGradientText($text,
  gradient: const ${_gradientKind}Gradient(colors: [$colors]),
  style: const $style,
  duration: const Duration(milliseconds: ${_duration.round()}),
  repeat: $_repeat,
  direction: TextDirection.${_reverse ? 'rtl' : 'ltr'},
)''';
    } else {
      child = 'Text($text, style: const $style, textAlign: TextAlign.center)';
    }
    if (_reveal) {
      child =
          '''NibTextReveal(
  direction: NibTextRevealDirection.${_direction.name},
  duration: const Duration(milliseconds: ${_duration.round()}),
  delay: const Duration(milliseconds: ${_delay.round()}),
  curve: $curve,
  child: $child,
)''';
    }
    return '''import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

void main() => runApp(MaterialApp(
  theme: ThemeData.dark(),
  home: Scaffold(body: Center(child: Padding(
    padding: const EdgeInsets.all(24),
    child: Semantics(label: $text, excludeSemantics: true, child: $child),
  ))),
));
''';
  }

  Future<void> _copyConfiguration() async {
    try {
      await Clipboard.setData(ClipboardData(text: _configuration));
      if (mounted) setState(() => _copied = true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Copy unavailable. Select the current configuration below.',
            ),
          ),
        );
      }
    }
  }

  Widget _animatedText(TextStyle style) {
    final generation = _generation;
    Widget child;
    if (_units) {
      child = NibText(
        _sentence,
        style: style,
        textAlign: TextAlign.center,
        overflow: TextOverflow.visible,
        config: NibTextConfig(
          unit: _unit,
          staggerFrom: _origin,
          staggerDelay: Duration(milliseconds: _stagger.round()),
          initial: _initial,
          animate: NibAnim.identity,
          transition: _spring
              ? NibTransition.springGentle
              : NibTransition(
                  duration: Duration(milliseconds: _duration.round()),
                  curve: _easing,
                ),
        ),
      );
    } else if (_typing) {
      child = NibTypewriter(
        _sentence,
        speed: Duration(milliseconds: _speed.round()),
        deleteSpeed: Duration(milliseconds: _deleteSpeed.round()),
        cursor: _cursor == 'None' ? null : _cursor,
        cursorBlinkInterval: Duration(milliseconds: _blink.round()),
        delay: Duration(milliseconds: _delay.round()),
        repeat: _repeat,
        style: style,
        onComplete: () {
          if (mounted && generation == _generation) {
            setState(() => _completed++);
          }
        },
      );
      if (widget.kind == TextMotionKind.typingEntrance) {
        child = NibMotion(
          initial: const NibAnim(y: 20, opacity: 0, scale: .9),
          animate: NibAnim.identity,
          transition: NibTransition.springGentle,
          child: child,
        );
      }
    } else if (_gradient) {
      child = NibGradientText(
        _sentence,
        gradient: _colors,
        style: style,
        duration: Duration(milliseconds: _duration.round()),
        repeat: _repeat,
        direction: _reverse ? TextDirection.rtl : TextDirection.ltr,
      );
    } else {
      child = Text(_sentence, style: style, textAlign: TextAlign.center);
    }
    if (_reveal) {
      child = NibTextReveal(
        direction: _direction,
        duration: Duration(milliseconds: _duration.round()),
        delay: Duration(milliseconds: _delay.round()),
        curve: _easing,
        child: child,
      );
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w600,
      color: colors.primary,
      height: 1.4,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 155),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            border: Border.all(color: colors.outline),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Semantics(
            label: _sentence,
            excludeSemantics: true,
            child: KeyedSubtree(
              key: ValueKey(_generation),
              child: _playing
                  ? _animatedText(style)
                  : Text(_sentence, style: style, textAlign: TextAlign.center),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () => _change(() {}),
              icon: const Icon(Icons.replay, size: 16),
              label: const Text('Replay text'),
            ),
            OutlinedButton(
              onPressed: () => setState(() => _playing = false),
              child: const Text('Stop'),
            ),
            OutlinedButton.icon(
              onPressed: _copyConfiguration,
              icon: const Icon(Icons.copy_outlined, size: 16),
              label: Text(
                _copied ? 'Copied configuration' : 'Copy current configuration',
              ),
            ),
          ],
        ),
        if (_typing)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              'onComplete calls this run: $_completed',
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 16),
        TextField(
          controller: _text,
          minLines: 1,
          maxLines: 2,
          maxLength: 80,
          decoration: const InputDecoration(
            labelText: 'Your text',
            helperText: 'Edit, then choose Replay text.',
            border: OutlineInputBorder(),
          ),
        ),
        if (_units) ...[
          _choices(
            'Unit',
            NibTextUnit.values,
            _unit,
            (v) => _change(() => _unit = v),
            (v) => v.name,
          ),
          _choices(
            'Stagger origin',
            NibTextStaggerFrom.values,
            _origin,
            (v) => _change(() => _origin = v),
            (v) => v.name,
          ),
          _choices(
            'Effect',
            const ['Fade', 'Slide', 'Scale', 'Rotate', 'Blur', 'Compose'],
            _effect,
            (v) => _change(() => _effect = v),
            (v) => v,
          ),
          _slider(
            'Stagger',
            _stagger,
            0,
            200,
            (v) => _change(() => _stagger = v),
          ),
          ComponentToggle(
            showLabel: true,
            contentPadding: EdgeInsets.zero,
            label: 'Spring transition',
            value: _spring,
            onChanged: (v) => _change(() => _spring = v),
          ),
        ],
        if (!_typing && !(_units && _spring))
          _slider(
            'Duration',
            _duration,
            200,
            3000,
            (v) => _change(() => _duration = v),
          ),
        if ((_units && !_spring) || _reveal)
          _choices(
            'Curve',
            const ['Linear', 'Smooth', 'Ease out'],
            _curve,
            (v) => _change(() => _curve = v),
            (v) => v,
          ),
        if (_typing) ...[
          _slider(
            'Typing interval',
            _speed,
            20,
            180,
            (v) => _change(() => _speed = v),
          ),
          _choices(
            'Cursor',
            const ['None', '|', '_', '▌'],
            _cursor,
            (v) => _change(() => _cursor = v),
            (v) => v,
          ),
          if (_cursor != 'None')
            _slider(
              'Cursor blink interval',
              _blink,
              200,
              1000,
              (v) => _change(() => _blink = v),
            ),
        ],
        if (_typing || _reveal)
          _slider(
            'Initial delay',
            _delay,
            0,
            1500,
            (v) => _change(() => _delay = v),
          ),
        if (_gradient || _typing)
          ComponentToggle(
            showLabel: true,
            contentPadding: EdgeInsets.zero,
            label: _typing
                ? 'Repeat typing and deletion'
                : 'Repeat gradient sweep',
            value: _repeat,
            onChanged: (v) => _change(() => _repeat = v),
          ),
        if (_typing && _repeat)
          _slider(
            'Deletion interval',
            _deleteSpeed,
            20,
            180,
            (v) => _change(() => _deleteSpeed = v),
          ),
        if (_gradient) ...[
          _choices(
            'Gradient',
            const ['Linear', 'Radial', 'Sweep'],
            _gradientKind,
            (v) => _change(() => _gradientKind = v),
            (v) => v,
          ),
          ComponentToggle(
            showLabel: true,
            contentPadding: EdgeInsets.zero,
            label: 'Reverse sweep direction',
            value: _reverse,
            onChanged: (v) => _change(() => _reverse = v),
          ),
          ComponentToggle(
            showLabel: true,
            contentPadding: EdgeInsets.zero,
            label: 'Sage palette',
            value: _cool,
            onChanged: (v) => _change(() => _cool = v),
          ),
        ],
        if (_reveal)
          _choices(
            'Reveal direction',
            NibTextRevealDirection.values,
            _direction,
            (v) => _change(() => _direction = v),
            (v) => v.name,
          ),
        ExpansionTile(
          title: const Text('Current configuration'),
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(
                _configuration,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> change,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('$label: ${value.round()} ms'),
      Slider(
        value: value,
        min: min,
        max: max,
        divisions: 30,
        semanticFormatterCallback: (v) => '${v.round()} milliseconds',
        onChanged: change,
      ),
    ],
  );

  Widget _choices<T>(
    String label,
    List<T> values,
    T selected,
    ValueChanged<T> change,
    String Function(T) name,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final value in values)
              ChoiceChip(
                label: Text(name(value)),
                selected: value == selected,
                onSelected: (_) => change(value),
              ),
          ],
        ),
      ],
    ),
  );
}
