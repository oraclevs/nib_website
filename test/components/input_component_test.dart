import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_components/nib_components.dart';
import 'package:nib_motion/nib_motion.dart';
import 'package:nib_ember_living/components/component_settings.dart';
import 'package:nib_ember_living/components/component_theme.dart';
import 'package:nib_ember_living/components/examples/input_component_demo.dart';
import 'package:nib_ember_living/components/guides/input_component_guide.dart';

class _Harness extends StatefulWidget {
  _Harness({super.key, ComponentSettings? initial})
    : initial = initial ?? inputComponentGuide.initial;
  final ComponentSettings initial;
  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late ComponentSettings settings = widget.initial;
  final events = <String>[];
  void change(String name, Object value) {
    setState(() => settings = settings.change(name, value));
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: componentEmberTheme(
      accent: settings.accent,
      radius: settings.radius,
    ),
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: InputComponentDemo(
          settings: settings,
          onChanged: (next) => setState(() => settings = next),
          onEvent: events.add,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'actual NibInput edits typed configuration and validates locally',
    (tester) async {
      final key = GlobalKey<_HarnessState>();
      await tester.pumpWidget(_Harness(key: key));
      expect(find.byType(NibInput), findsOneWidget);
      expect(find.byType(NibTextarea), findsNothing);
      expect(key.currentState!.settings.animated, isTrue);
      expect(tester.widget<NibInput>(find.byType(NibInput)).animated, isTrue);
      expect(find.byType(NibMotion), findsOneWidget);
      key.currentState!.change('animated', false);
      await tester.pump();
      expect(find.byType(NibMotion), findsNothing);
      await tester.enterText(find.byType(TextField), 'Ada');
      await tester.pump();
      expect(key.currentState!.settings.text, 'Ada');
      expect(key.currentState!.events, ['Text changed: 3 characters']);
      await tester.tap(find.text('Validate'));
      await tester.pump();
      expect(
        find.text('Valid. This example keeps your text on this page.'),
        findsOneWidget,
      );
      expect(key.currentState!.events.last, 'Validation passed');
      await tester.tap(find.text('Clear field'));
      await tester.pump();
      expect(key.currentState!.settings.text, '');
      expect(
        tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
        isTrue,
      );
      expect(find.text('Enter a name.'), findsOneWidget);
      expect(key.currentState!.events.last, 'Field cleared');
      await tester.tap(find.text('Validate'));
      await tester.pump();
      expect(key.currentState!.events.last, 'Validation failed');
    },
  );

  testWidgets(
    'style updates preserve controller, selection and composing range',
    (tester) async {
      final key = GlobalKey<_HarnessState>();
      await tester.pumpWidget(
        _Harness(
          key: key,
          initial: inputComponentGuide.initial.change('animated', false),
        ),
      );
      expect(find.byType(NibMotion), findsNothing);
      await tester.showKeyboard(find.byType(TextField));
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'selection',
          selection: TextSelection(baseOffset: 2, extentOffset: 6),
          composing: TextRange(start: 1, end: 7),
        ),
      );
      await tester.pump();
      final controller = tester
          .widget<TextField>(find.byType(TextField))
          .controller!;
      final editing = controller.value;
      key.currentState!.change('radius', 20.0);
      key.currentState!.change('animated', true);
      await tester.pump();
      final after = tester
          .widget<TextField>(find.byType(TextField))
          .controller!;
      expect(identical(after, controller), isTrue);
      expect(after.value, editing);
      expect(
        tester.widget<NibInput>(find.byType(NibInput)).borderRadius,
        BorderRadius.circular(20),
      );
      expect(find.byType(NibMotion), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(tester.binding.transientCallbackCount, 0);
    },
  );

  testWidgets('disabled field prevents editing actions without clearing text', (
    tester,
  ) async {
    final key = GlobalKey<_HarnessState>();
    await tester.pumpWidget(_Harness(key: key));
    final text = key.currentState!.settings.text;
    key.currentState!.change('disabled', true);
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    for (final button in tester.widgetList<NibButton>(find.byType(NibButton))) {
      expect(button.onPressed, isNull);
    }
    expect(find.byIcon(Icons.close), findsNothing);
    expect(key.currentState!.settings.text, text);
    expect(key.currentState!.events, isEmpty);
  });

  testWidgets(
    'multiline switch preserves text; external text updates counter and form state',
    (tester) async {
      final key = GlobalKey<_HarnessState>();
      await tester.pumpWidget(_Harness(key: key));
      await tester.enterText(find.byType(TextField), 'Keep this');
      await tester.pump();
      key.currentState!.change('variant', 'multiline');
      await tester.pump();
      expect(find.byType(NibInput), findsNothing);
      expect(find.byType(NibTextarea), findsOneWidget);
      expect(find.text('9/80'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Keep this',
      );
      key.currentState!.change('text', 'New\ntext');
      await tester.pump();
      expect(find.text('8/80'), findsOneWidget);
      final field = tester.state<FormFieldState<String>>(
        find.byType(NibTextarea),
      );
      expect(field.value, 'New\ntext');
      expect(key.currentState!.events, ['Text changed: 9 characters']);
      await tester.tap(find.text('Clear field'));
      await tester.pump();
      expect(find.text('0/80'), findsOneWidget);
      expect(field.value, '');
      expect(find.text('Enter a message.'), findsOneWidget);
    },
  );

  testWidgets('escaped user text remains literal in configured source', (
    tester,
  ) async {
    final key = GlobalKey<_HarnessState>();
    await tester.pumpWidget(
      _Harness(
        key: key,
        initial: inputComponentGuide.initial.change('variant', 'multiline'),
      ),
    );
    const text = 'Ada "quoted" \'single\' \\ path\n\${notDartCode}';
    await tester.enterText(find.byType(TextField), text);
    await tester.pump();
    expect(key.currentState!.settings.text, text);
    final literal = componentDartLiteral(text);
    expect(literal, contains(r'\${notDartCode}'));
    expect(literal, contains(r'\n'));
    expect(literal, contains(r'\\ path'));
    expect(jsonDecode(literal.replaceAll(r'\$', r'$')), text);
    expect(key.currentState!.settings.dartSource, contains('text: $literal,'));
  });

  testWidgets(
    'typing obeys limit and assigned oversized text fails validation',
    (tester) async {
      final key = GlobalKey<_HarnessState>();
      await tester.pumpWidget(
        _Harness(
          key: key,
          initial: inputComponentGuide.initial.change('value', 12.0),
        ),
      );
      await tester.enterText(find.byType(TextField), '1234567890123456');
      await tester.pump();
      expect(key.currentState!.settings.text, '123456789012');
      key.currentState!.change('text', 'programmatic value exceeds limit');
      await tester.pump();
      await tester.tap(find.text('Validate'));
      await tester.pump();
      expect(find.text('Use no more than 12 characters.'), findsOneWidget);
      expect(key.currentState!.events.last, 'Validation failed');
    },
  );

  for (final width in [360.0, 390.0, 768.0, 1024.0, 1440.0]) {
    testWidgets('input family fits $width with large text', (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final key = GlobalKey<_HarnessState>();
      await tester.pumpWidget(_Harness(key: key));
      expect(tester.takeException(), isNull);
      key.currentState!.change('variant', 'multiline');
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(tester.widget<NibTextarea>(find.byType(NibTextarea)).maxLines, 5);
      expect(
        tester.getSize(find.byType(InputComponentDemo)).width,
        lessThanOrEqualTo(width),
      );
    });
  }
}
