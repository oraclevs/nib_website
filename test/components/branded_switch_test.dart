import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_components/nib_components.dart';
import 'package:nib_ember_living/components/component_toggle.dart';
import 'package:nib_ember_living/ember_material_theme.dart';
import 'package:nib_motion/nib_motion.dart';

void main() {
  test('every site switch uses the Nib control and branded thumb', () {
    for (final file
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))) {
      final source = file.readAsStringSync();
      if (file.path.contains('minimal') ||
          file.path.contains('/content/') ||
          file.path.contains('/guides/') ||
          file.path.endsWith('component_support_guides.dart')) {
        continue;
      }
      expect(
        RegExp(r'\b(Switch|SwitchListTile|CupertinoSwitch)(\.adaptive)?\(')
            .hasMatch(source),
        isFalse,
        reason: file.path,
      );
      if (source.contains('NibSwitch(')) {
        expect(source, contains('nibSwitchThumb'), reason: file.path);
      }
    }
  });

  testWidgets('off thumb is visible, named, keyboard operated and animated', (
    tester,
  ) async {
    var value = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: emberMaterialTheme(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, update) => ComponentToggle(
              label: 'Reduce motion',
              showLabel: true,
              value: value,
              onChanged: (next) => update(() => value = next),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final control = tester.widget<NibSwitch>(find.byType(NibSwitch));
    expect(control.animated, isTrue);
    expect(control.semanticLabel, 'Reduce motion');
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.excludeFromSemantics, isTrue);
    final offX = tester.getCenter(find.byType(Image)).dx;
    final decoration = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((widget) => widget.decoration)
        .whereType<BoxDecoration>()
        .firstWhere((box) => box.shape == BoxShape.circle);
    final border = decoration.border! as Border;
    final contrast =
        (border.top.color.computeLuminance() + .05) /
        (decoration.color!.computeLuminance() + .05);
    expect(contrast, greaterThan(3));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(value, isTrue);
    await tester.pump(const Duration(milliseconds: 80));
    final middleX = tester.getCenter(find.byType(Image)).dx;
    await tester.pumpAndSettle();
    final onX = tester.getCenter(find.byType(Image)).dx;
    expect(middleX, greaterThan(offX));
    expect(middleX, lessThan(onX));
    for (var i = 0; i < 8; i++) {
      await tester.tap(find.byType(ComponentToggle));
      await tester.pump(const Duration(milliseconds: 30));
    }
    await tester.pumpAndSettle();
    expect(value, isTrue);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion and disabled input remain respected', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NibMotionConfig(
            reducedMotion: true,
            child: ComponentToggle(
              value: false,
              label: 'Disabled',
              onChanged: null,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final control = tester.widget<NibSwitch>(find.byType(NibSwitch));
    expect(control.animated, isFalse);
    expect(control.onChanged, isNull);
    expect(find.byType(Image), findsOneWidget);
    await tester.tap(find.byType(ComponentToggle));
    expect(tester.widget<NibSwitch>(find.byType(NibSwitch)).value, isFalse);
  });
}
