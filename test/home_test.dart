import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/ember_theme.dart';
import 'package:nib_ember_living/hero_lab.dart';
import 'package:nib_ember_living/main.dart';
import 'package:nib_motion/nib_motion.dart';

void main() {
  for (final width in [360.0, 390.0, 768.0, 1024.0, 1440.0]) {
    testWidgets('reference homepage renders at ${width.toInt()} px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const NibEmberSite());
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('Make every'), findsWidgets);
      expect(
        find.text('INTERACTION LAB / FEEL THE DIFFERENCE'),
        findsOneWidget,
      );
    });
  }

  testWidgets('card flip reaches both faces while motion is paused', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HeroLab(paused: true, reduced: false, ambient: true),
        ),
      ),
    );
    await tester.pump();

    final front = find.bySemanticsLabel('Flip card. Front: Make it move you.');
    final back = find.bySemanticsLabel(
      'Flip card. Back: A different point of view.',
    );
    expect(front, findsOneWidget);
    await tester.tap(front);
    await tester.pump();
    expect(back, findsOneWidget);
    await tester.tap(back);
    await tester.pump();
    expect(front, findsOneWidget);
    semantics.dispose();
  });

  testWidgets('scroll reveal stays hidden until the section enters view', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 740),
                EmberReveal(
                  child: SizedBox(
                    height: 160,
                    child: Text('Scrolled into view'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    final reveal = find.byType(EmberReveal);
    final motion = find.descendant(
      of: reveal,
      matching: find.byType(NibMotion),
    );
    final render = tester.renderObject<RenderNibMotion>(motion);
    expect(render.opacity.value, 0);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -420),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
    expect(render.opacity.value, closeTo(1, .01));
  });

  testWidgets('call to action responds to hover and still clicks', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var clicks = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: EmberButton(label: 'Explore', onPressed: () => clicks++),
          ),
        ),
      ),
    );
    final motion = find.descendant(
      of: find.byType(EmberHover),
      matching: find.byType(NibMotion),
    );
    final render = tester.renderObject<RenderNibMotion>(motion);
    expect(render.scaleX.value, 1);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(OutlinedButton)));
    await tester.pumpAndSettle();
    expect(render.scaleX.value, greaterThan(1.02));
    await tester.tap(find.byType(OutlinedButton));
    expect(clicks, 1);
  });

  testWidgets('visible idle call to action nudges once', (tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: EmberButton(
              label: 'Explore',
              attention: true,
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    final shake = find.descendant(
      of: find.byType(NibShake),
      matching: find.byType(NibMotion),
    );
    final render = tester.renderObject<RenderNibMotion>(shake.first);
    expect(render.translateX.value, 0);
    await tester.pump(const Duration(milliseconds: 2800));
    await tester.pump(const Duration(milliseconds: 90));
    expect(render.translateX.value.abs(), greaterThan(0));
  });

  testWidgets('presence study lays out distinct layers and bounds additions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const NibEmberSite());
    await tester.pump();
    await tester.ensureVisible(find.text('Pause motion'));
    await tester.tap(find.text('Pause motion'));
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(
      tester.element(find.text('Add element')),
      alignment: .8,
    );
    await tester.pumpAndSettle();
    final first = tester.getRect(find.text('Layer 01  ×'));
    final second = tester.getRect(find.text('Layer 02  ×'));
    expect(first.overlaps(second), isFalse);
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('Add element'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Layer 06  ×'), findsOneWidget);
    final capacity = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'At capacity'),
    );
    expect(capacity.onPressed, isNull);
    await tester.tap(find.text('Layer 02  ×'));
    await tester.pumpAndSettle();
    expect(find.text('Layer 02  ×'), findsNothing);
    expect(find.text('Add element'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
