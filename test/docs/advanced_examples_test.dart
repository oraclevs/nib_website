import 'package:nib_ember_living/components/component_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/docs/examples/motion_controller_example.dart';
import 'package:nib_ember_living/docs/examples/motion_navigation_example.dart';
import 'package:nib_ember_living/docs/examples/motion_physics_example.dart';
import 'package:nib_ember_living/docs/examples/motion_timeline_example.dart';
import 'package:nib_motion/nib_motion.dart';

Future<void> _pumpExample(
  WidgetTester tester,
  Widget example, {
  bool reducedMotion = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData.dark(),
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reducedMotion),
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: 257,
              child: NibMotionConfig(
                entranceWarmup: Duration.zero,
                child: SingleChildScrollView(child: example),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

List<NibMotionController> _controllers(WidgetTester tester) => tester
    .widgetList<NibMotion>(find.byType(NibMotion))
    .map((motion) => motion.controller!)
    .toList();

double _x(NibMotionController controller) =>
    controller.motionValueOf(NibProperty.x)!.value;

double _opacity(NibMotionController controller) =>
    controller.motionValueOf(NibProperty.opacity)!.value;

MotionValue<double> _physicsPosition(WidgetTester tester) => tester
    .widget<NibMotion>(
      find.byWidgetPredicate(
        (widget) =>
            widget is NibMotion && widget.motionValues?.translateX != null,
      ),
    )
    .motionValues!
    .translateX!;

void main() {
  testWidgets(
    'controller starts, freezes, resumes, and sets its real position',
    (tester) async {
      await _pumpExample(tester, const MotionControllerExample());
      final controller = _controllers(tester).single;
      expect(_x(controller), -48);

      await tester.tap(find.text('Start'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      final moving = _x(controller);
      expect(moving, inExclusiveRange(-48, 48));

      await tester.tap(find.text('Stop'));
      await tester.pump();
      expect(find.text('Stopped at current position'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      expect(_x(controller), closeTo(moving, 0.001));

      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();
      expect(_x(controller), closeTo(48, 0.01));

      await tester.tap(find.text('Set'));
      expect(_x(controller), -48);
      await tester.pump(const Duration(seconds: 1));
      expect(_x(controller), -48);
      expect(find.text('Set instantly to the left'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('timeline starts its second track after the documented delay', (
    tester,
  ) async {
    await _pumpExample(tester, const MotionTimelineExample());
    final controllers = _controllers(tester);
    expect(controllers, hasLength(2));

    await tester.tap(find.text('Play'));
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 80));
    expect(_x(controllers[0]), greaterThan(-36));
    expect(_x(controllers[1]), -36);
    expect(_opacity(controllers[1]), 0.5);

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    expect(_x(controllers[1]), greaterThan(-36));
    expect(_x(controllers[0]), greaterThan(_x(controllers[1])));
    await tester.pump(const Duration(milliseconds: 500));
    for (final controller in controllers) {
      expect(_x(controller), 36);
      expect(_opacity(controller), 1);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancel freezes active motion and prevents the pending track', (
    tester,
  ) async {
    await _pumpExample(tester, const MotionTimelineExample());
    final controllers = _controllers(tester);
    await tester.tap(find.text('Play'));
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 80));
    final firstPosition = _x(controllers[0]);
    final firstOpacity = _opacity(controllers[0]);
    expect(firstPosition, greaterThan(-36));

    await tester.tap(find.text('Cancel'));
    await tester.pump(const Duration(seconds: 2));
    expect(_x(controllers[0]), closeTo(firstPosition, 0.001));
    expect(_opacity(controllers[0]), closeTo(firstOpacity, 0.001));
    expect(_x(controllers[1]), -36);
    expect(_opacity(controllers[1]), 0.5);
    expect(find.text('Pending and active motion stopped'), findsOneWidget);

    await tester.tap(find.text('Play'));
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 180));
    await tester.pump(const Duration(milliseconds: 100));
    final positions = controllers.map(_x).toList();
    expect(positions[1], greaterThan(-36));
    await tester.tap(find.text('Cancel'));
    await tester.pump(const Duration(seconds: 2));
    for (var i = 0; i < controllers.length; i++) {
      expect(_x(controllers[i]), closeTo(positions[i], 0.001));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'seek applies both track times and holds after interrupted play',
    (tester) async {
      await _pumpExample(tester, const MotionTimelineExample());
      final controllers = _controllers(tester);

      tester.widget<Slider>(find.byType(Slider)).onChanged!(0.5);
      await tester.pump();
      // Halfway through 680 ms is 340 ms: 68% of the first entry,
      // and 32% of the second entry after its 180 ms delay.
      final fractions = [0.68, 0.32];
      for (var i = 0; i < controllers.length; i++) {
        final eased = Curves.easeInOutCubic.transform(fractions[i]);
        expect(_x(controllers[i]), closeTo(-36 + 72 * eased, 0.001));
        expect(_opacity(controllers[i]), closeTo(0.5 + 0.5 * eased, 0.001));
      }
      expect(find.text('Seeked to 50%'), findsOneWidget);

      tester.widget<Slider>(find.byType(Slider)).onChanged!(1);
      await tester.pump();
      for (final controller in controllers) {
        expect(_x(controller), 36);
        expect(_opacity(controller), 1);
      }
      tester.widget<Slider>(find.byType(Slider)).onChanged!(0);
      await tester.pump();
      for (final controller in controllers) {
        expect(_x(controller), -36);
        expect(_opacity(controller), 0.5);
      }

      await tester.tap(find.text('Play'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      tester.widget<Slider>(find.byType(Slider)).onChanged!(0.25);
      await tester.pump();
      final position = _x(controllers[0]);
      expect(position, inExclusiveRange(-36, 36));
      expect(_x(controllers[1]), -36);
      await tester.pump(const Duration(seconds: 2));
      expect(_x(controllers[0]), closeTo(position, 0.001));
      expect(_x(controllers[1]), -36);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('navigation preserves each screen counter across tab changes', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await _pumpExample(tester, const MotionNavigationExample());
      expect(find.text('Inbox: 0'), findsOneWidget);
      await tester.tap(find.text('Add a count'));
      await tester.pump();
      await tester.tap(find.text('Add a count'));
      await tester.pump();
      expect(find.text('Inbox: 2'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Saved'));
      await tester.pumpAndSettle();
      expect(find.text('Saved: 0'), findsOneWidget);
      expect(find.text('Inbox: 2'), findsNothing);
      await tester.tap(find.text('Add a count'));
      await tester.pump();
      expect(find.text('Saved: 1'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Inbox'));
      await tester.pumpAndSettle();
      expect(find.text('Inbox: 2'), findsOneWidget);
      expect(find.text('Saved: 1'), findsNothing);
      await tester.tap(find.bySemanticsLabel('Saved'));
      await tester.pumpAndSettle();
      expect(find.text('Saved: 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('physics jumps to each target with reduced motion enabled', (
    tester,
  ) async {
    await _pumpExample(
      tester,
      const MotionPhysicsExample(),
      reducedMotion: true,
    );
    final position = _physicsPosition(tester);
    expect(position.value, -65);

    await tester.tap(find.text('Retarget solver'));
    expect(position.value, 65);
    await tester.pump(const Duration(milliseconds: 80));
    expect(position.value, 65);

    await tester.tap(find.byType(ComponentToggle));
    expect(position.value, -65);
    await tester.pump(const Duration(seconds: 1));
    expect(position.value, -65);
    expect(find.text('stiffness 400 · damping 28 · mass 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('enabling reduced motion settles an active physics solver', (
    tester,
  ) async {
    await _pumpExample(tester, const MotionPhysicsExample());
    final position = _physicsPosition(tester);
    await tester.tap(find.text('Retarget solver'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(position.value, inExclusiveRange(-65, 65));

    await _pumpExample(
      tester,
      const MotionPhysicsExample(),
      reducedMotion: true,
    );
    expect(_physicsPosition(tester), same(position));
    expect(position.value, 65);
    await tester.pump(const Duration(seconds: 1));
    expect(position.value, 65);
    expect(tester.takeException(), isNull);
  });
}
