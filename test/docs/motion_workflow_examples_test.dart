import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/content/motion_capabilities.dart';
import 'package:nib_ember_living/content/site_content.dart';
import 'package:nib_ember_living/docs/examples/motion_workflow_examples.dart';
import 'package:nib_motion/nib_motion.dart';

void main() {
  test(
    'six capabilities lead to real guides and retain all 32 existing routes',
    () {
      expect(motionCapabilities, hasLength(6));
      for (final section in motionCapabilities) {
        for (final link in section.blocks.cast<DocLink>()) {
          expect(
            SiteContent.articleById('motion', link.route.split('/').last),
            isNotNull,
          );
        }
      }
      expect(SiteContent.articlesFor('motion'), hasLength(35));
      expect(motionPublishedVersion, '0.3.5');
      expect(motionPendingVersion, '0.3.6');
    },
  );

  testWidgets(
    'water controls, reduced motion and unmount keep ownership sound',
    (tester) async {
      for (final reduced in [false, true]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: NibMotionConfig(
                  reducedMotion: reduced,
                  child: const SizedBox(
                    width: 300,
                    child: MotionWaterExample(),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        final surface = tester.widget<NibWaterSurface>(
          find.byType(NibWaterSurface),
        );
        expect(surface.sampling, NibWaterSampling.live);
        for (var i = 0; i < 5; i++) {
          await tester.tap(find.text('Disturb'));
          await tester.pump(const Duration(milliseconds: 16));
        }
        await tester.tap(find.text('Pause'));
        await tester.pump();
        expect(
          tester.widget<NibWaterSurface>(find.byType(NibWaterSurface)).paused,
          isTrue,
        );
        await tester.tap(find.text('Reset'));
        await tester.pump();
        expect(surface.controller.impulses, isEmpty);
        await tester.pumpWidget(const SizedBox());
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('shared layout changes keyed placement repeatedly and disposes', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(width: 300, child: MotionSharedLayoutExample()),
          ),
        ),
      ),
    );
    for (var i = 0; i < 6; i++) {
      await tester.tap(find.text(i.isEven ? 'Expand card' : 'Return card'));
      await tester.pump(const Duration(milliseconds: 48));
      final motion = tester.widget<NibMotion>(find.byType(NibMotion));
      expect(motion.layoutId, 'shared-card');
      expect(motion.key, ValueKey(i.isEven));
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });
}
