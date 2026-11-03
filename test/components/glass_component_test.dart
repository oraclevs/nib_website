import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_components/nib_components.dart';
import 'package:nib_ember_living/components/component_settings.dart';
import 'package:nib_ember_living/components/component_theme.dart';
import 'package:nib_ember_living/components/examples/glass_component_demo.dart';
import 'package:nib_ember_living/components/guides/glass_component_guide.dart';
import 'package:nib_motion/nib_motion.dart';

Future<void> _mount(
  WidgetTester tester, {
  double width = 390,
  double textScale = 1,
  bool reduceMotion = false,
  ComponentSettings settings = const ComponentSettings(
    variant: 'rounded',
    radius: 24,
    text: 'Keep the backdrop visible.',
  ),
  List<String>? events,
}) async {
  tester.view.physicalSize = Size(width, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  var current = settings;
  await tester.pumpWidget(
    MaterialApp(
      theme: componentEmberTheme(
        accent: settings.accent,
        radius: settings.radius,
      ),
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: reduceMotion,
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: StatefulBuilder(
                    builder: (context, setState) => GlassComponentDemo(
                      settings: current,
                      onChanged: (value) => setState(() => current = value),
                      onEvent: (event) => events?.add(event),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 16));
}

RenderNibMotion _renderMotion(WidgetTester tester) {
  RenderNibMotion? result;
  void visit(Element element) {
    if (element.renderObject case final RenderNibMotion motion) {
      result = motion;
      return;
    }
    element.visitChildren(visit);
  }

  visit(tester.element(find.byType(NibMotion)));
  return result!;
}

void main() {
  test(
    'guide controls describe existing settings and public glass symbols',
    () {
      expect(
        glassComponentGuide.symbols,
        containsAll(['NibLiquidGlass', 'NibGlass', 'glassLightFromPointer']),
      );
      for (final control in glassComponentGuide.controls) {
        expect(
          glassComponentGuide.initial.values.containsKey(control.key),
          isTrue,
        );
      }
      expect(
        glassComponentGuide.sections.map((section) => section.id),
        containsAll([
          'setup',
          'interactions',
          'fallback',
          'state-lifecycle',
          'accessibility',
        ]),
      );
      expect(glassComponentGuide.demoClass, 'GlassComponentDemo');
      expect(glassComponentGuide.initial.animated, isTrue);
      expect(const ComponentSettings().animated, isFalse);
      expect(const NibLiquidGlass(child: SizedBox()).animated, isFalse);
    },
  );

  for (final width in [360.0, 390.0, 768.0, 1024.0, 1440.0]) {
    testWidgets('native glass and both backdrops fit $width', (tester) async {
      await _mount(tester, width: width);
      expect(find.byType(NibLiquidGlass), findsOneWidget);
      expect(find.byType(NibGlass), findsOneWidget);
      expect(find.byType(NibMotion), findsNothing);
      final surface = tester.getRect(
        find.byKey(const ValueKey('glass-demo-surface')),
      );
      expect(surface.left, greaterThanOrEqualTo(0));
      expect(surface.right, lessThanOrEqualTo(width));
      expect(find.byKey(const ValueKey('glass-backdrop-grid')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('glass-change-backdrop')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('glass-backdrop-content')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('all optical settings reach the real public engine', (
    tester,
  ) async {
    const settings = ComponentSettings(
      variant: 'capsule',
      blurSigma: 9,
      thickness: 37,
      refractiveIndex: 1.6,
      chromaticAberration: .08,
      saturation: 1.7,
      highlight: .8,
      showBorder: false,
      interactive: false,
      animated: false,
    );
    await _mount(tester, settings: settings);
    final component = tester.widget<NibLiquidGlass>(
      find.byType(NibLiquidGlass),
    );
    final engine = tester.widget<NibGlass>(find.byType(NibGlass));
    expect(component.showBorder, isFalse);
    expect(component.interactive, isFalse);
    expect(component.animated, isFalse);
    expect(engine.borderRadius, BorderRadius.circular(94));
    expect(engine.blurSigma, 9);
    expect(engine.thickness, 37);
    expect(engine.refractiveIndex, 1.6);
    expect(engine.chromaticAberration, .08);
    expect(engine.saturation, 1.7);
    expect(engine.highlight, .8);
    expect(find.byType(BackdropFilter), findsWidgets);
    expect(find.textContaining('Frosted fallback:'), findsOneWidget);
    expect(
      find.textContaining('Refraction settings require the shader path.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('hover, press and cancellation use native glass state', (
    tester,
  ) async {
    final events = <String>[];
    await _mount(
      tester,
      settings: const ComponentSettings(animated: true),
      events: events,
    );
    final surface = tester.getRect(
      find.byKey(const ValueKey('glass-demo-surface')),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(surface.centerRight - const Offset(16, 0));
    await tester.pump();
    var engine = tester.widget<NibGlass>(find.byType(NibGlass));
    expect(engine.lightDirection.dx, closeTo(1, .01));
    expect(engine.lightDirection.dy, closeTo(0, .01));
    await mouse.removePointer();
    await tester.pump();

    for (var i = 0; i < 3; i++) {
      final gesture = await tester.startGesture(
        surface.topCenter + const Offset(0, 30),
      );
      await tester.pump();
      expect(
        (tester.widget<NibMotion>(find.byType(NibMotion)).animate as NibAnim)
            .scale,
        .98,
      );
      await tester.pump(const Duration(milliseconds: 180));
      expect(_renderMotion(tester).scaleX.value, closeTo(.98, .001));
      await gesture.cancel();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 180));
      expect(_renderMotion(tester).scaleX.value, closeTo(1, .001));
      engine = tester.widget<NibGlass>(find.byType(NibGlass));
      expect(engine.lightDirection, const Offset(-.4, -1));
    }
    expect(events.where((event) => event == 'Pointer cancelled').length, 3);
    expect(events.where((event) => event == 'Pointer down on glass').length, 3);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    expect(tester.hasRunningAnimations, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'disabling pointer interaction during a press clears native state',
    (tester) async {
      await _mount(tester, settings: const ComponentSettings(animated: true));
      final surface = tester.getRect(
        find.byKey(const ValueKey('glass-demo-surface')),
      );
      final gesture = await tester.startGesture(
        surface.topCenter + const Offset(0, 28),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 180));
      expect(_renderMotion(tester).scaleX.value, closeTo(.98, .001));
      final demo = tester.widget<GlassComponentDemo>(
        find.byType(GlassComponentDemo),
      );
      demo.onChanged(demo.settings.change('interactive', false));
      await tester.pump();
      await gesture.cancel();
      await tester.pump(const Duration(milliseconds: 180));
      expect(_renderMotion(tester).scaleX.value, closeTo(1, .001));
      expect(
        tester.widget<NibGlass>(find.byType(NibGlass)).lightDirection,
        const Offset(-.4, -1),
      );
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'reduced motion settles press response without a running ticker',
    (tester) async {
      await _mount(
        tester,
        reduceMotion: true,
        settings: const ComponentSettings(animated: true),
      );
      final surface = tester.getRect(
        find.byKey(const ValueKey('glass-demo-surface')),
      );
      final gesture = await tester.startGesture(
        surface.topCenter + const Offset(0, 28),
      );
      await tester.pump();
      await tester.pump();
      expect(_renderMotion(tester).scaleX.value, .98);
      expect(tester.hasRunningAnimations, isFalse);
      await gesture.cancel();
      await tester.pump();
      await tester.pump();
      expect(_renderMotion(tester).scaleX.value, 1);
      expect(tester.hasRunningAnimations, isFalse);
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('theme and pinned state survive a backdrop change', (
    tester,
  ) async {
    final events = <String>[];
    await _mount(
      tester,
      settings: const ComponentSettings(accent: 0xFF91AF72),
      events: events,
    );
    final context = tester.element(find.byType(NibLiquidGlass));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(NibTheme.of(context).primary, const Color(0xFF91AF72));
    expect(
      tester.widget<NibGlass>(find.byType(NibGlass)).tint,
      const Color(0x0AFFFFFF),
    );
    expect(
      tester.widget<Text>(find.text('Hello, Nib')).style!.color,
      const Color(0xFFF4E8C8),
    );
    await tester.tap(find.byKey(const ValueKey('glass-pin-note')));
    await tester.pump();
    expect(find.text('Pinned'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('glass-change-backdrop')));
    await tester.pump();
    expect(find.text('Pinned'), findsOneWidget);
    expect(events, containsAll(['Note pinned', 'Backdrop changed to content']));
    expect(tester.takeException(), isNull);
  });

  testWidgets('child keyboard action works with decorative interaction off', (
    tester,
  ) async {
    final events = <String>[];
    await _mount(
      tester,
      settings: const ComponentSettings(interactive: false),
      events: events,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(find.text('Pinned'), findsOneWidget);
    expect(events, contains('Note pinned'));
    expect(events, isNot(contains('Pointer down on glass')));
    expect(tester.takeException(), isNull);
  });

  testWidgets('capsule and content backdrop fit narrow large-text layout', (
    tester,
  ) async {
    await _mount(
      tester,
      width: 360,
      textScale: 2,
      settings: const ComponentSettings(
        variant: 'capsule',
        backdrop: 'content',
        text: 'A longer note still leaves room for its control.',
      ),
    );
    expect(find.text('Pin note'), findsOneWidget);
    final button = tester.getRect(find.byKey(const ValueKey('glass-pin-note')));
    final surface = tester.getRect(
      find.byKey(const ValueKey('glass-demo-surface')),
    );
    expect(button.left, greaterThanOrEqualTo(surface.left));
    expect(button.right, lessThanOrEqualTo(surface.right));
    expect(tester.takeException(), isNull);
  });
}
