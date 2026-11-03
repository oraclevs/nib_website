import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/ember_motion.dart';
import 'package:nib_ember_living/fixture_demo.dart';
import 'package:nib_ember_living/hero_lab.dart';
import 'package:nib_motion/nib_motion.dart';

void main() {
  testWidgets('reveal ramps gradually through visible intermediate frames', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NibMotionConfig(
          entranceWarmup: Duration.zero,
          child: Scaffold(
            body: Center(
              child: EmberReveal(child: SizedBox(width: 100, height: 100)),
            ),
          ),
        ),
      ),
    );
    final render = tester.renderObject<RenderNibMotion>(find.byType(NibMotion));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    final samples = <double>[];
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      samples.add(render.opacity.value);
    }
    expect(samples[1], lessThan(.08));
    expect(
      samples.where((value) => value > .05 && value < .95).length,
      greaterThan(7),
    );
    for (var i = 1; i < samples.length; i++) {
      expect(samples[i] - samples[i - 1], inInclusiveRange(0, .2));
    }
    expect(samples.last, closeTo(1, .001));
  });

  testWidgets('fixture fades in, stages content, and cancels older replays', (
    tester,
  ) async {
    var replay = 0;
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        home: NibMotionConfig(
          entranceWarmup: Duration.zero,
          child: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return Center(
                  child: SizedBox(
                    width: 310,
                    child: EmberFixtureDemo(replay: replay),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    update(() => replay++);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    final heading = find.byKey(ValueKey('heading-$replay'));
    final render = tester.renderObject<RenderNibMotion>(heading);
    await tester.pump(const Duration(milliseconds: 200));
    expect(render.opacity.value, greaterThan(0));
    expect(render.opacity.value, lessThan(.9));
    expect(find.text('Continue →'), findsNothing);
    await tester.pump(const Duration(milliseconds: 520));
    expect(
      find.text('A generated local surface, shown from a fixture.'),
      findsOneWidget,
    );
    update(() => replay++);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text('A generated local surface, shown from a fixture.'),
      findsNothing,
    );
    await tester.pump(const Duration(milliseconds: 1140));
    await tester.pumpAndSettle();
    expect(find.text('Continue →'), findsOneWidget);
    update(() => replay++);
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('ambient off returns gradually without a position jump', (
    tester,
  ) async {
    var ambient = true;
    var paused = false;
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return EmberMotionPolicy(
              paused: paused,
              reduced: false,
              ambient: ambient,
              child: const Scaffold(
                body: Center(
                  child: EmberFloat(
                    y: 12,
                    child: SizedBox(width: 100, height: 100),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    final render = tester.renderObject<RenderNibMotion>(find.byType(NibMotion));
    final before = render.translateY.value;
    expect(before.abs(), greaterThan(1));
    update(() => ambient = false);
    await tester.pump();
    expect(render.translateY.value, closeTo(before, .01));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 220));
    expect(render.translateY.value.abs(), lessThan(before.abs()));
    expect(render.translateY.value.abs(), greaterThan(.1));
    update(() => paused = true);
    await tester.pump();
    final frozen = render.translateY.value;
    await tester.pump(const Duration(seconds: 1));
    expect(render.translateY.value, closeTo(frozen, .001));
    update(() => paused = false);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(render.translateY.value, closeTo(0, .001));
  });

  testWidgets('card flip has intermediate angles and preserves a reversal', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(
        home: EmberMotionPolicy(
          paused: false,
          reduced: false,
          ambient: false,
          child: Scaffold(
            body: HeroLab(paused: false, reduced: false, ambient: false),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final motion = tester
        .widgetList<NibMotion>(find.byType(NibMotion))
        .firstWhere(
          (widget) =>
              widget.controller != null &&
              widget.animate is NibAnim &&
              (widget.animate as NibAnim).rotateY == 0,
        );
    final angle = motion.controller!.motionValueOf(NibProperty.rotateY)!;
    await tester.tap(find.text('Tap to flip'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 160));
    expect(angle.value, greaterThan(.01));
    expect(angle.value, lessThan(.49));
    final before = angle.value;
    await tester.tap(find.text('Tap to flip'));
    await tester.pump();
    expect((angle.value - before).abs(), lessThan(.03));
    await tester.pumpAndSettle();
    expect(angle.value, closeTo(0, .001));
    await tester.tap(find.text('Tap to flip'));
    await tester.pumpAndSettle();
    expect(angle.value, closeTo(.5, .001));
  });

  testWidgets('shuffle travels through intermediate positions', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(
        home: EmberMotionPolicy(
          paused: false,
          reduced: false,
          ambient: false,
          child: Scaffold(
            body: HeroLab(paused: false, reduced: false, ambient: false),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final before = tester.getCenter(find.text('Motion')).dy;
    await tester.tap(find.text('Shuffle'));
    await tester.pump();
    final start = tester.getCenter(find.text('Motion')).dy;
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 100));
    final middle = tester.getCenter(find.text('Motion')).dy;
    await tester.pumpAndSettle();
    final end = tester.getCenter(find.text('Motion')).dy;
    expect((start - before).abs(), lessThan(2));
    expect(middle, greaterThan(before + 2));
    expect(middle, lessThan(end - 2));
    expect(end - before, greaterThan(80));
  });
}
