import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nib_ember_living/components/component_pages.dart';
import 'package:nib_ember_living/widgets/dart_code_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_components/nib_components.dart';
import 'package:nib_motion/nib_motion.dart';
import 'package:nib_ember_living/components/component_settings.dart';
import 'package:nib_ember_living/components/component_theme.dart';
import 'package:nib_ember_living/components/examples/glass_component_demo.dart';
import 'package:nib_ember_living/components/guides/glass_component_guide.dart';

Future<void> mountWater(
  WidgetTester tester, {
  ComponentSettings? settings,
  double width = 900,
  double textScale = 1,
  bool reduced = false,
}) async {
  tester.view.physicalSize = Size(width, 1500);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  var current = settings ?? glassComponentGuide.initial;
  await tester.pumpWidget(
    MaterialApp(
      theme: componentEmberTheme(),
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: reduced,
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: StatefulBuilder(
                  builder: (context, setState) => GlassComponentDemo(
                    settings: current,
                    onChanged: (value) => setState(() => current = value),
                    onEvent: (_) {},
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

NibWaterGlass material(WidgetTester tester) =>
    tester.widget<NibWaterGlass>(find.byType(NibWaterGlass));
void change(WidgetTester tester, String key, Object value) {
  final demo = tester.widget<GlassComponentDemo>(
    find.byType(GlassComponentDemo),
  );
  demo.onChanged(demo.settings.change(key, value));
}

Future<void> frames(WidgetTester tester, int count) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  test('water defaults and visibility preserve the legacy API', () {
    final water = glassComponentGuide.initial;
    final legacy = water.change('waterMaterial', 'legacy');
    expect(water.waterMaterial, 'water');
    expect(water.waterScene, 'droplets');
    expect(water.animated, isTrue);
    expect(const ComponentSettings().waterMaterial, 'legacy');
    final visibleWater = glassComponentGuide.controls
        .where((control) => control.isVisible(water))
        .map((control) => control.key);
    final visibleLegacy = glassComponentGuide.controls
        .where((control) => control.isVisible(legacy))
        .map((control) => control.key);
    expect(
      visibleWater,
      containsAll(['waterWaveSpeed', 'waterDamping', 'waterCaptureScale']),
    );
    expect(visibleWater, isNot(contains('blurSigma')));
    expect(
      visibleLegacy,
      containsAll(['blurSigma', 'refractiveIndex', 'variant']),
    );
    expect(visibleLegacy, isNot(contains('waterWaveSpeed')));
    for (final control in glassComponentGuide.controls) {
      expect(
        water.values.containsKey(control.key),
        isTrue,
        reason: control.key,
      );
    }
  });

  testWidgets('tuned inspector values reach the actual public controller', (
    tester,
  ) async {
    final settings = glassComponentGuide.initial
        .change('waterWaveSpeed', 250)
        .change('waterDamping', 4.5)
        .change('waterImpulse', 9)
        .change('waterWavelength', 74)
        .change('waterRecovery', 22)
        .change('waterRefraction', 32)
        .change('waterHighlight', .9)
        .change('waterCaptureScale', 1.5)
        .change('waterQuality', .75)
        .change('waterOptics', 'depth')
        .change('waterBlur', 2)
        .change('waterSampling', 'throttled');
    await mountWater(tester, settings: settings);
    final widget = material(tester);
    final config = widget.controller!.config;
    expect(config.waveSpeed, 250);
    expect(config.damping, 4.5);
    expect(config.impulseStrength, 9);
    expect(config.wavelength, 74);
    expect(config.recovery, 22);
    expect(config.refraction, 32);
    expect(config.highlight, .9);
    expect(widget.captureScale, 1.5);
    expect(widget.quality.scale, .75);
    expect(widget.sampling, NibWaterSampling.throttled);
    expect(widget.material!.depth, 1);
    expect(widget.material!.blurSigma, 2);
    expect(widget.interaction, NibWaterInteraction.drag);
    expect(widget.surface, isFalse);
    expect(widget.controller!.drops.map((drop) => drop.center.dx), [180, 460]);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('merge and split are real continuous controller actions', (
    tester,
  ) async {
    await mountWater(tester);
    final controller = material(tester).controller!;
    final initialMass = controller.massProxy;
    await tester.tap(find.byKey(const ValueKey('water-merge')));
    await tester.pump();
    expect(controller.phase, NibWaterPhase.merging);
    await frames(tester, 100);
    expect(
      controller.phase,
      NibWaterPhase.merged,
      reason:
          'time=${controller.simulationTime}; drops=${controller.drops.map((drop) => '${drop.center}/${drop.velocity}').join(',')}',
    );
    expect(controller.drops.map((drop) => drop.bodyId).toSet().length, 1);
    final joined = controller.drops.first.center;
    await tester.tap(find.byKey(const ValueKey('water-split')));
    await tester.pump();
    expect(controller.phase, NibWaterPhase.splitting);
    expect((controller.drops.first.center - joined).distance, lessThan(10));
    await frames(tester, 100);
    expect(controller.phase, NibWaterPhase.separated);
    expect(controller.drops.map((drop) => drop.bodyId).toSet().length, 2);
    expect(controller.massProxy, closeTo(initialMass, .0001));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'scene and background changes retain controller and component state',
    (tester) async {
      await mountWater(tester);
      final controller = material(tester).controller!;
      change(tester, 'waterScene', 'component');
      await tester.pump();
      expect(material(tester).surface, isTrue);
      expect(material(tester).interaction, NibWaterInteraction.disturb);
      expect(material(tester).controller, same(controller));
      await tester.tap(find.byKey(const ValueKey('water-save-note')));
      await tester.pump();
      expect(find.text('Saved'), findsOneWidget);
      change(tester, 'waterBackdrop', 'typography');
      await tester.pump();
      expect(find.text('Saved'), findsOneWidget);
      expect(material(tester).controller, same(controller));
      change(tester, 'waterScene', 'droplets');
      await tester.pump();
      expect(material(tester).surface, isFalse);
      change(tester, 'waterInteraction', 'disturb');
      await tester.pump();
      expect(material(tester).interaction, NibWaterInteraction.disturb);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('shared bubbles stop emission and switching disposes the owner', (
    tester,
  ) async {
    await mountWater(
      tester,
      settings: glassComponentGuide.initial.change('waterScene', 'bubbles'),
    );
    final water = material(tester).controller!;
    expect(water.emitter, isNotNull);
    await frames(tester, 80);
    expect(water.drops, isNotEmpty);
    expect(water.drops.length, lessThanOrEqualTo(6));
    await tester.tap(find.text('Stop emission'));
    await tester.pump();
    expect(water.emitter!.emitting, isFalse);
    change(tester, 'waterScene', 'droplets');
    await tester.pump();
    expect(water.isDisposed, isTrue);
    expect(material(tester).controller!.emitter, isNull);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('scrolling background changes real scroll position', (
    tester,
  ) async {
    await mountWater(
      tester,
      settings: glassComponentGuide.initial.change(
        'waterBackdrop',
        'scrolling',
      ),
    );
    final scroll = tester
        .widget<SingleChildScrollView>(
          find.byKey(const ValueKey('water-scrolling-background')),
        )
        .controller!;
    expect(scroll.offset, 0);
    await tester.tap(find.byKey(const ValueKey('water-scroll-background')));
    await tester.pump();
    expect(scroll.offset, 100);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('reset retains pause and less-motion policy', (tester) async {
    await mountWater(tester);
    await tester.tap(find.text('Pause water'));
    await tester.pump();
    await tester.tap(find.text('Less motion'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('water-reset')));
    await tester.pump();
    expect(material(tester).paused, isTrue);
    expect(material(tester).reducedMotion, isTrue);
    expect(material(tester).controller!.phase, NibWaterPhase.separated);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    expect(tester.hasRunningAnimations, isFalse);
  });

  for (final width in [360.0, 768.0, 1440.0]) {
    testWidgets('water controls fit $width with large text', (tester) async {
      await mountWater(tester, width: width, textScale: 1.6, reduced: true);
      expect(find.byType(NibWaterSurface), findsOneWidget);
      final scene = tester.getRect(
        find.byKey(const ValueKey('water-lab-surface')),
      );
      expect(scene.left, greaterThanOrEqualTo(0));
      expect(scene.right, lessThanOrEqualTo(width));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('keyboard action reaches the real merged state', (tester) async {
    await mountWater(tester, reduced: true);
    final controller = material(tester).controller!;
    final action = find.byKey(const ValueKey('water-merge'));
    final ink = tester.widget<InkWell>(
      find.descendant(of: action, matching: find.byType(InkWell)).first,
    );
    ink.focusNode!.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(controller.phase, NibWaterPhase.merged);
    expect(controller.isReducedMotion, isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'mobile Preview Tune Code retain the real controller and settings',
    (tester) async {
      tester.view.physicalSize = const Size(480, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.runAsync(() async {
        for (final path in [
          'lib/ember_material_theme.dart',
          'lib/components/component_theme.dart',
          'lib/components/component_settings.dart',
          glassComponentGuide.demoFile,
        ]) {
          await rootBundle.loadString(path);
        }
      });
      await tester.pumpWidget(
        MaterialApp(
          theme: componentEmberTheme(),
          home: Scaffold(
            body: ComponentGuidePage(
              guide: glassComponentGuide,
              onNavigate: (_) {},
              playground: true,
            ),
          ),
        ),
      );
      await frames(tester, 4);
      final controller = material(tester).controller!;
      controller.merge();
      await frames(tester, 5);
      await tester.ensureVisible(
        find.byKey(const ValueKey('water-mobile-tab-1')),
      );
      await tester.tap(find.byKey(const ValueKey('water-mobile-tab-1')));
      await tester.pump();
      final before = controller.simulationTime;
      await tester.pump(const Duration(seconds: 1));
      expect(controller.simulationTime, before);
      expect(controller.isDisposed, isFalse);
      final slider = tester.widget<Slider>(
        find.byKey(const ValueKey('component-control-waterWaveSpeed')),
      );
      slider.onChanged!(240);
      await tester.pump();
      expect(controller.config.waveSpeed, 240);
      await tester.tap(find.byKey(const ValueKey('water-mobile-tab-2')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('component-code-full')));
      await tester.pump();
      await tester.pump();
      for (
        var i = 0;
        i < 30 && find.byType(DartCodeView).evaluate().isEmpty;
        i++
      ) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump();
      }
      final code = tester.widget<DartCodeView>(find.byType(DartCodeView)).code;
      expect(code, contains('waterWaveSpeed: 240.0'));
      expect(code, contains('class GlassComponentDemo'));
      await tester.tap(find.byKey(const ValueKey('water-mobile-tab-0')));
      await tester.pump();
      expect(material(tester).controller, same(controller));
      expect(material(tester).controller!.config.waveSpeed, 240);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      expect(controller.isDisposed, isTrue);
    },
  );
}
