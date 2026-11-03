import 'package:nib_ember_living/components/component_toggle.dart';

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/docs/examples/motion_text_example.dart';
import 'package:nib_motion/nib_motion.dart';

Future<List<String>> _mount(
  WidgetTester tester,
  MotionTextExample example, {
  bool reducedMotion = false,
}) async {
  tester.view.physicalSize = const Size(240, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final copied = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'Clipboard.setData') {
        copied.add((call.arguments as Map)['text'] as String);
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData.dark(),
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reducedMotion),
        child: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(width: 240, child: example),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  expect(tester.takeException(), isNull);
  return copied;
}

Future<void> _select(WidgetTester tester, String label) async {
  final choice = find.widgetWithText(ChoiceChip, label);
  expect(choice, findsOneWidget);
  await tester.ensureVisible(choice);
  await tester.tap(choice);
  await tester.pump();
  expect(tester.widget<ChoiceChip>(choice).selected, isTrue);
  expect(tester.takeException(), isNull);
}

Future<void> _toggle(WidgetTester tester, String label, bool expected) async {
  final tile = find.byWidgetPredicate(
    (widget) => widget is ComponentToggle && widget.label == label,
  );
  expect(tile, findsOneWidget);
  await tester.ensureVisible(tile);
  await tester.tap(tile);
  await tester.pump();
  expect(tester.widget<ComponentToggle>(tile).value, expected);
  expect(tester.takeException(), isNull);
}

Future<void> _setSlider(WidgetTester tester, String label, double value) async {
  final labelFinder = find.textContaining('$label:');
  expect(labelFinder, findsOneWidget);
  final column = find
      .ancestor(of: labelFinder, matching: find.byType(Column))
      .first;
  final sliderFinder = find.descendant(
    of: column,
    matching: find.byType(Slider),
  );
  expect(sliderFinder, findsOneWidget);
  await tester.ensureVisible(sliderFinder);
  tester.widget<Slider>(sliderFinder).onChanged!(value);
  await tester.pump();
  expect(tester.widget<Slider>(sliderFinder).value, value);
  expect(tester.takeException(), isNull);
}

Future<String> _copy(
  WidgetTester tester,
  List<String> clipboard,
  String filename,
) async {
  final button = find.widgetWithIcon(OutlinedButton, Icons.copy_outlined);
  expect(button, findsOneWidget);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pump();
  expect(clipboard, isNotEmpty);
  expect(find.text('Copied configuration'), findsOneWidget);
  final source = clipboard.last;
  expect(source, contains('void main()'));
  expect(source, contains("import 'package:nib_motion/nib_motion.dart';"));
  final artifact = File('build/text_configuration_verification/$filename.dart');
  artifact.parent.createSync(recursive: true);
  artifact.writeAsStringSync(source);
  expect(tester.takeException(), isNull);
  return source;
}

String _visibleTypewriterText(WidgetTester tester) {
  final textFinder = find.descendant(
    of: find.byType(NibTypewriter),
    matching: find.byType(Text),
  );
  expect(textFinder, findsOneWidget);
  final text = tester.widget<Text>(textFinder);
  return text.data ?? text.textSpan!.toPlainText();
}

void main() {
  testWidgets('all units and stagger origins change the real widget and copy', (
    tester,
  ) async {
    final clipboard = await _mount(tester, const MotionTextExample());
    var exports = 0;
    for (final unit in NibTextUnit.values) {
      await _select(tester, unit.name);
      for (final origin in NibTextStaggerFrom.values) {
        await _select(tester, origin.name);
        final widget = tester.widget<NibText>(find.byType(NibText));
        expect(widget.config.unit, unit);
        expect(widget.config.staggerFrom, origin);
        expect(widget.config.staggerDelay, const Duration(milliseconds: 70));
        final source = await _copy(
          tester,
          clipboard,
          'units_${unit.name}_${origin.name}',
        );
        expect(source, contains('unit: NibTextUnit.${unit.name}'));
        expect(
          source,
          contains('staggerFrom: NibTextStaggerFrom.${origin.name}'),
        );
        exports++;
      }
    }
    expect(exports, 12);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('composed spring and edited text match the copied Dart', (
    tester,
  ) async {
    final clipboard = await _mount(tester, const MotionTextExample());
    await _select(tester, 'line');
    await _select(tester, 'Compose');
    await _toggle(tester, 'Spring transition', true);
    final input = 'Cost \$5, "yes"\nnext line';
    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), input);
    final replay = find.text('Replay text');
    await tester.ensureVisible(replay);
    await tester.tap(replay);
    await tester.pump();
    final text = tester.widget<NibText>(find.byType(NibText));
    expect(text.text, input);
    expect(text.config.initial, isA<NibAnim>());
    final initial = text.config.initial!;
    expect(initial.x, -10);
    expect(initial.y, 18);
    expect(initial.scale, .75);
    expect(initial.rotate, -.15);
    expect(initial.blur, 4);
    expect(text.config.transition!.spring, isNotNull);
    final source = await _copy(
      tester,
      clipboard,
      'units_composed_spring_escaped',
    );
    expect(source, contains('NibTransition.springGentle'));
    expect(source, contains('scale: .75, rotate: -.15, blur: 4'));
    expect(source, contains(jsonEncode(input).replaceAll(r'$', r'\$')));
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('all reveal directions alter the wrapper and exported source', (
    tester,
  ) async {
    final clipboard = await _mount(
      tester,
      const MotionTextExample(kind: TextMotionKind.reveal),
    );
    for (final direction in NibTextRevealDirection.values) {
      await _select(tester, direction.name);
      final reveal = tester.widget<NibTextReveal>(find.byType(NibTextReveal));
      expect(reveal.direction, direction);
      expect(reveal.duration, const Duration(milliseconds: 900));
      final source = await _copy(tester, clipboard, 'reveal_${direction.name}');
      expect(source, contains('NibTextRevealDirection.${direction.name}'));
      expect(source, contains('child: Text('));
    }
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'typewriter delay, repeat, deletion and cursor are real controls',
    (tester) async {
      final clipboard = await _mount(
        tester,
        const MotionTextExample(kind: TextMotionKind.typewriter),
      );
      await tester.ensureVisible(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'Hi');
      await _select(tester, 'None');
      await _setSlider(tester, 'Typing interval', 20);
      await _setSlider(tester, 'Initial delay', 1000);
      await _toggle(tester, 'Repeat typing and deletion', true);
      await _setSlider(tester, 'Deletion interval', 20);
      final typewriter = tester.widget<NibTypewriter>(
        find.byType(NibTypewriter),
      );
      expect(typewriter.text, 'Hi');
      expect(typewriter.speed, const Duration(milliseconds: 20));
      expect(typewriter.deleteSpeed, const Duration(milliseconds: 20));
      expect(typewriter.delay, const Duration(milliseconds: 1000));
      expect(typewriter.cursor, isNull);
      expect(typewriter.repeat, isTrue);
      expect(_visibleTypewriterText(tester), '');
      await tester.pump(const Duration(milliseconds: 900));
      expect(_visibleTypewriterText(tester), '');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 20));
      expect(_visibleTypewriterText(tester), 'H');
      await tester.pump(const Duration(milliseconds: 20));
      expect(_visibleTypewriterText(tester), 'Hi');
      await tester.pump(const Duration(milliseconds: 20));
      expect(find.text('onComplete calls this run: 1'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 40));
      expect(_visibleTypewriterText(tester), isNot('Hi'));
      var source = await _copy(
        tester,
        clipboard,
        'typewriter_repeat_delete_delay',
      );
      expect(source, contains('repeat: true'));
      expect(source, contains('deleteSpeed: const Duration(milliseconds: 20)'));
      expect(source, contains('delay: const Duration(milliseconds: 1000)'));
      expect(source, contains('cursor: null'));
      await _select(tester, '_');
      await _setSlider(tester, 'Cursor blink interval', 200);
      expect(
        tester.widget<NibTypewriter>(find.byType(NibTypewriter)).cursor,
        '_',
      );
      expect(
        tester
            .widget<NibTypewriter>(find.byType(NibTypewriter))
            .cursorBlinkInterval,
        const Duration(milliseconds: 200),
      );
      source = await _copy(tester, clipboard, 'typewriter_cursor_blink');
      expect(source, contains('cursor: "_"'));
      expect(
        source,
        contains('cursorBlinkInterval: const Duration(milliseconds: 200)'),
      );
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'gradient kinds, direction, palette and repeat reach preview and copy',
    (tester) async {
      final clipboard = await _mount(
        tester,
        const MotionTextExample(kind: TextMotionKind.gradient),
      );
      await _toggle(tester, 'Repeat gradient sweep', true);
      await _toggle(tester, 'Reverse sweep direction', true);
      await _toggle(tester, 'Sage palette', true);
      for (final kind in ['Linear', 'Radial', 'Sweep']) {
        await _select(tester, kind);
        final gradient = tester.widget<NibGradientText>(
          find.byType(NibGradientText),
        );
        expect(gradient.repeat, isTrue);
        expect(gradient.direction, TextDirection.rtl);
        expect(gradient.gradient.runtimeType.toString(), '${kind}Gradient');
        final source = await _copy(
          tester,
          clipboard,
          'gradient_${kind.toLowerCase()}_rtl',
        );
        expect(source, contains('const ${kind}Gradient('));
        expect(source, contains('direction: TextDirection.rtl'));
        expect(source, contains('repeat: true'));
        expect(source, contains('Color(0xFFCFDEA0)'));
      }
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'composed reveal-gradient and typing entrance copy their wrappers',
    (tester) async {
      final clipboard = await _mount(
        tester,
        const MotionTextExample(kind: TextMotionKind.revealGradient),
      );
      await _select(tester, 'up');
      await _select(tester, 'Radial');
      expect(find.byType(NibTextReveal), findsOneWidget);
      expect(find.byType(NibGradientText), findsOneWidget);
      var source = await _copy(tester, clipboard, 'reveal_gradient_radial_up');
      expect(source, contains('NibTextRevealDirection.up'));
      expect(source, contains('child: NibGradientText('));

      await tester.pumpWidget(const SizedBox.shrink());
      final entranceClipboard = await _mount(
        tester,
        const MotionTextExample(kind: TextMotionKind.typingEntrance),
      );
      expect(
        find.ancestor(
          of: find.byType(NibTypewriter),
          matching: find.byType(NibMotion),
        ),
        findsOneWidget,
      );
      expect(find.byType(NibTypewriter), findsOneWidget);
      source = await _copy(tester, entranceClipboard, 'typing_entrance');
      expect(source, contains('NibMotion('));
      expect(source, contains('child: NibTypewriter('));
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('reduced motion presents complete static typewriter text', (
    tester,
  ) async {
    final clipboard = await _mount(
      tester,
      const MotionTextExample(kind: TextMotionKind.typewriter),
      reducedMotion: true,
    );
    expect(
      _visibleTypewriterText(tester),
      contains('Make words worth watching.'),
    );
    expect(find.text('onComplete calls this run: 1'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(
      _visibleTypewriterText(tester),
      contains('Make words worth watching.'),
    );
    expect(find.text('onComplete calls this run: 1'), findsOneWidget);
    final source = await _copy(tester, clipboard, 'typewriter_reduced_motion');
    expect(source, contains('NibTypewriter('));
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}
