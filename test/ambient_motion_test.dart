import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/ember_motion.dart';
import 'package:nib_motion/nib_motion.dart';

void main() {
  testWidgets('float moves, freezes on pause, resumes and rests when reduced', (
    tester,
  ) async {
    var paused = false;
    var reduced = false;
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return EmberMotionPolicy(
              paused: paused,
              reduced: reduced,
              ambient: true,
              child: const Scaffold(
                body: Center(
                  child: EmberFloat(
                    y: 12,
                    duration: Duration(seconds: 2),
                    child: SizedBox(width: 80, height: 80),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    final render = tester.renderObject<RenderNibMotion>(find.byType(NibMotion));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(render.translateY.value.abs(), greaterThan(1));

    update(() => paused = true);
    await tester.pump();
    final frozen = render.translateY.value;
    await tester.pump(const Duration(seconds: 5));
    expect(render.translateY.value, closeTo(frozen, .001));

    update(() => paused = false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect((render.translateY.value - frozen).abs(), greaterThan(.5));

    update(() => reduced = true);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(render.translateY.value, 0);
    expect(render.scaleX.value, 1);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('float stays idle offscreen and stops after scrolling away', (
    tester,
  ) async {
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            controller: scroll,
            child: const Column(
              children: [
                SizedBox(height: 800),
                EmberFloat(y: 10, child: SizedBox(width: 100, height: 100)),
                SizedBox(height: 800),
              ],
            ),
          ),
        ),
      ),
    );
    final render = tester.renderObject<RenderNibMotion>(find.byType(NibMotion));
    await tester.pump(const Duration(seconds: 2));
    expect(render.translateY.value, 0);
    scroll.jumpTo(650);
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(render.translateY.value.abs(), greaterThan(1));
    scroll.jumpTo(0);
    await tester.pump();
    await tester.pump();
    final frozen = render.translateY.value;
    await tester.pump(const Duration(seconds: 3));
    expect(render.translateY.value, closeTo(frozen, .001));
  });

  testWidgets('system reduced motion and ambient off leave decorations still', (
    tester,
  ) async {
    for (final systemReduced in [true, false]) {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: systemReduced),
            child: EmberMotionPolicy(
              paused: false,
              reduced: false,
              ambient: systemReduced,
              child: const Scaffold(
                body: Center(
                  child: EmberFloat(
                    y: 10,
                    x: 4,
                    turn: .02,
                    scale: 1.1,
                    child: SizedBox(width: 80, height: 80),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));
      final render = tester.renderObject<RenderNibMotion>(
        find.byType(NibMotion),
      );
      expect(render.translateY.value, 0);
      expect(render.translateX.value, 0);
      expect(render.scaleX.value, 1);
    }
  });

  testWidgets(
    'left and right viewport entrances start on opposite axes and settle',
    (tester) async {
      for (final entrance in [EmberEntrance.left, EmberEntrance.right]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: EmberReveal(
                  key: ValueKey(entrance),
                  entrance: entrance,
                  child: const SizedBox(width: 100, height: 100),
                ),
              ),
            ),
          ),
        );
        final render = tester.renderObject<RenderNibMotion>(
          find.byType(NibMotion),
        );
        expect(
          render.translateX.value,
          entrance == EmberEntrance.left ? -42 : 42,
        );
        expect(render.opacity.value, 0);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1000));
        await tester.pumpAndSettle();
        expect(render.translateX.value, closeTo(0, .01));
        expect(render.translateY.value, closeTo(0, .01));
        expect(render.opacity.value, closeTo(1, .01));
      }
    },
  );
}
