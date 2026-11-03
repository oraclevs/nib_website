import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/docs/examples/motion_composition_examples.dart';
import 'package:nib_motion/nib_motion.dart';

Future<void> _mount(
  WidgetTester tester,
  Widget child, {
  bool reduced = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData.dark(),
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(800, 600),
          disableAnimations: reduced,
        ),
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: 240,
              child: NibMotionConfig(
                entranceWarmup: Duration.zero,
                child: SingleChildScrollView(child: child),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

Finder _motionTarget(String key) =>
    key == 'drag-motion' && find.byType(Dialog).evaluate().isNotEmpty
    ? find.descendant(
        of: find.byType(Dialog),
        matching: find.byKey(ValueKey(key)),
      )
    : find.byKey(ValueKey(key));
Finder _dragTile() => find.byType(Dialog).evaluate().isNotEmpty
    ? find.descendant(of: find.byType(Dialog), matching: find.text('DRAG'))
    : find.text('DRAG');
NibMotionController _controller(WidgetTester tester, String key) =>
    tester.widget<NibMotion>(_motionTarget(key)).controller!;
double _value(NibMotionController controller, NibProperty property) =>
    controller.motionValueOf(property)!.value;
Future<void> _tap(WidgetTester tester, String label) async {
  final target = find.byType(Dialog).evaluate().isNotEmpty
      ? find.descendant(of: find.byType(Dialog), matching: find.text(label))
      : find.text(label);
  await tester.ensureVisible(target);
  await tester.pump();
  await tester.tap(target);
  await tester.pump();
}

void main() {
  testWidgets('finite loop completes three passes; unlimited loop can stop', (
    tester,
  ) async {
    await _mount(tester, const MotionLoopExample());
    final controller = _controller(tester, 'loop-motion');
    await _tap(tester, 'Replay');
    expect(_value(controller, NibProperty.x), -56);
    await tester.pump(const Duration(milliseconds: 350));
    expect(_value(controller, NibProperty.x), closeTo(0, .1));
    await tester.pumpAndSettle();
    expect(find.text('Three passes complete.'), findsOneWidget);
    expect(_value(controller, NibProperty.x), 56);

    await _tap(tester, 'Unlimited');
    await _tap(tester, 'Replay');
    await tester.pump(const Duration(milliseconds: 350));
    expect(_value(controller, NibProperty.x), inExclusiveRange(-56, 56));
    await _tap(tester, 'Stop');
    final frozen = _value(controller, NibProperty.x);
    await tester.pump(const Duration(seconds: 2));
    expect(_value(controller, NibProperty.x), frozen);
    expect(tester.takeException(), isNull);
  });

  testWidgets('path stroke and child share progress, pause, and restart', (
    tester,
  ) async {
    await _mount(tester, const MotionDrawPathExample());
    final draw = tester.allRenderObjects
        .whereType<RenderNibDrawPath>()
        .toSet()
        .single;
    final follow = tester.allRenderObjects
        .whereType<RenderNibPathMotion>()
        .toSet()
        .single;
    await tester.pump(const Duration(milliseconds: 1500));
    expect(draw.progress.value, closeTo(.5, .001));
    expect(follow.progress.value, closeTo(.5, .001));
    await _tap(tester, 'Pause');
    await tester.pump(const Duration(seconds: 1));
    expect(draw.progress.value, closeTo(.5, .001));
    expect(follow.progress.value, closeTo(.5, .001));
    await _tap(tester, 'Restart');
    expect(draw.progress.value, 0);
    expect(follow.progress.value, 0);
    await tester.pump(const Duration(seconds: 3));
    expect(draw.progress.value, 1);
    expect(follow.progress.value, 1);
  });

  testWidgets(
    'scroll bridge maps start, middle and end to actual child channels',
    (tester) async {
      await _mount(tester, const MotionScrollProgressExample());
      NibMotionValues channels() =>
          tester.widget<NibMotion>(find.byType(NibMotion)).motionValues!;
      expect(channels().translateX!.value, -56);
      await _tap(tester, 'Halfway');
      expect(find.text('50% read'), findsOneWidget);
      expect(channels().translateX!.value, closeTo(0, .001));
      expect(channels().rotate!.value, closeTo(0, .001));
      await _tap(tester, 'End');
      expect(find.text('100% read'), findsOneWidget);
      expect(channels().translateX!.value, 56);
      expect(channels().rotate!.value, .4);
      await _tap(tester, 'Start');
      expect(channels().translateX!.value, -56);
    },
  );

  testWidgets('drag locks axes, bounds offsets, and resets', (tester) async {
    await _mount(tester, const MotionDragAxesExample());
    await _tap(tester, 'Open drag canvas');
    await tester.pumpAndSettle();
    final controller = _controller(tester, 'drag-motion');
    await tester.drag(_dragTile(), const Offset(240, 80));
    await tester.pump();
    expect(_value(controller, NibProperty.x), closeTo(56, .001));
    expect(_value(controller, NibProperty.y), 0);
    await _tap(tester, 'Y');
    await tester.ensureVisible(_dragTile());
    await tester.pump();
    expect(
      tester.widget<NibMotion>(_motionTarget('drag-motion')).drag!.axis,
      Axis.vertical,
    );
    await tester.drag(_dragTile(), const Offset(80, 180));
    await tester.pump();
    expect(_value(controller, NibProperty.x), 0);
    expect(_value(controller, NibProperty.y), closeTo(34, .001));
    await _tap(tester, 'Center');
    await _tap(tester, 'Both');
    await tester.ensureVisible(_dragTile());
    await tester.pump();
    await tester.drag(_dragTile(), const Offset(45, 30));
    await tester.pump();
    expect(_value(controller, NibProperty.x), greaterThan(0));
    expect(_value(controller, NibProperty.y), greaterThan(0));
    await _tap(tester, 'Center');
    expect(_value(controller, NibProperty.x), 0);
    expect(_value(controller, NibProperty.y), 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'inline drag leaves page scrolling available and isolated canvas keeps page offset',
    (tester) async {
      final scroll = ScrollController(initialScrollOffset: 120);
      addTearDown(scroll.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              controller: scroll,
              children: const [
                SizedBox(height: 240),
                Center(
                  child: SizedBox(width: 240, child: MotionDragAxesExample()),
                ),
                SizedBox(height: 700),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final inline = _controller(tester, 'drag-motion');
      final before = scroll.offset;
      await tester.drag(_dragTile(), const Offset(0, -100));
      await tester.pumpAndSettle();
      expect(scroll.offset, greaterThan(before));
      expect(_value(inline, NibProperty.x), 0);
      expect(_value(inline, NibProperty.y), 0);
      expect(
        find.textContaining('A scrolling page can claim vertical'),
        findsOneWidget,
      );
      await _tap(tester, 'Open drag canvas');
      await tester.pumpAndSettle();
      final pageOffset = scroll.offset;
      final isolated = _controller(tester, 'drag-motion');
      await _tap(tester, 'Y');
      await tester.drag(_dragTile(), const Offset(80, 180));
      await tester.pump();
      expect(_value(isolated, NibProperty.x), 0);
      expect(_value(isolated, NibProperty.y), closeTo(34, .001));
      expect(scroll.offset, pageOffset);
      await tester.tap(find.byTooltip('Close drag canvas'));
      await tester.pumpAndSettle();
      expect(find.text('Drag canvas'), findsNothing);
      expect(scroll.offset, pageOffset);
      await tester.drag(find.byType(ListView), const Offset(0, -100));
      await tester.pumpAndSettle();
      expect(scroll.offset, greaterThan(pageOffset));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'drag canvas fits a narrow page with independently scrolling controls',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await _mount(tester, const MotionDragAxesExample());
      await _tap(tester, 'Open drag canvas');
      await tester.pumpAndSettle();
      await _tap(tester, 'Y');
      await tester.drag(_dragTile(), const Offset(0, 120));
      await tester.pump();
      expect(
        _value(_controller(tester, 'drag-motion'), NibProperty.y),
        closeTo(34, .001),
      );
      await _tap(tester, 'Center');
      expect(_value(_controller(tester, 'drag-motion'), NibProperty.y), 0);
      await tester.tap(find.byTooltip('Close drag canvas'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('stagger order changes which numeric opacity advances first', (
    tester,
  ) async {
    await _mount(tester, const MotionStaggerOrderExample());
    List<double> opacities() => [
      for (var i = 0; i < 5; i++)
        tester
            .renderObject<RenderNibMotion>(find.byKey(ValueKey('stagger-$i')))
            .opacity
            .value,
    ];
    await tester.pump(const Duration(milliseconds: 80));
    expect(opacities().first, greaterThan(0));
    expect(opacities().last, 0);
    await _tap(tester, 'End');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(opacities().first, 0);
    expect(opacities().last, greaterThan(0));
    await _tap(tester, 'Center');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(opacities()[2], greaterThan(0));
    expect(opacities()[1], 0);
    expect(opacities()[3], 0);
    await tester.pumpAndSettle();
    expect(opacities(), everyElement(1));
  });

  testWidgets(
    'presence retains exiting key until complete in both native modes',
    (tester) async {
      await _mount(tester, const MotionPresenceModesExample());
      await tester.pumpAndSettle();
      for (final label in ['Sync', 'Pop']) {
        await _tap(tester, label);
        await tester.pumpAndSettle();
        await _tap(tester, 'Remove B');
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byKey(const ValueKey('presence-B')), findsOneWidget);
        final exiting = tester.allRenderObjects
            .whereType<RenderNibMotion>()
            .where((render) => render.opacity.value < 1)
            .toList();
        expect(exiting, isNotEmpty);
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('presence-B')), findsNothing);
        await _tap(tester, 'Restore B');
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('presence-B')), findsOneWidget);
      }
    },
  );

  testWidgets('five transform channels reach intermediate and final targets', (
    tester,
  ) async {
    await _mount(tester, const MotionTransformExample());
    final controller = _controller(tester, 'transform-motion');
    await _tap(tester, 'Compose');
    await tester.pump(const Duration(milliseconds: 300));
    expect(_value(controller, NibProperty.x), closeTo(24, .001));
    expect(_value(controller, NibProperty.y), closeTo(-11, .001));
    expect(_value(controller, NibProperty.scaleX), closeTo(1.1, .001));
    expect(_value(controller, NibProperty.rotate), closeTo(math.pi / 6, .001));
    expect(_value(controller, NibProperty.opacity), closeTo(.775, .001));
    await tester.pumpAndSettle();
    expect(_value(controller, NibProperty.x), 48);
    expect(_value(controller, NibProperty.scaleX), 1.2);
    await _tap(tester, 'Reset');
    await tester.pumpAndSettle();
    expect(_value(controller, NibProperty.x), 0);
    expect(_value(controller, NibProperty.opacity), 1);
  });

  testWidgets(
    'viewport re-entry resets while once survives hide and scope replay',
    (tester) async {
      await _mount(tester, const MotionViewportReplayExample());
      NibMotionController card() =>
          tester.widgetList<NibMotion>(find.byType(NibMotion)).last.controller!;
      await tester.pumpAndSettle();
      expect(_value(card(), NibProperty.opacity), 0);
      await _tap(tester, 'Reveal');
      await tester.pumpAndSettle();
      expect(_value(card(), NibProperty.opacity), 1);
      await _tap(tester, 'Hide');
      await tester.pumpAndSettle();
      expect(_value(card(), NibProperty.opacity), 0);
      await _tap(tester, 'Once');
      await _tap(tester, 'Reveal');
      await tester.pumpAndSettle();
      expect(_value(card(), NibProperty.opacity), 1);
      await _tap(tester, 'Hide');
      await tester.pumpAndSettle();
      expect(_value(card(), NibProperty.opacity), 1);
      await _tap(tester, 'Replay scope');
      expect(_value(card(), NibProperty.opacity), 1);
      expect(
        _value(_controller(tester, 'viewport-badge'), NibProperty.opacity),
        lessThan(1),
      );
      await tester.pumpAndSettle();
    },
  );

  testWidgets('all examples fit 240px and dispose with reduced motion', (
    tester,
  ) async {
    for (final example in const <Widget>[
      MotionLoopExample(),
      MotionDrawPathExample(),
      MotionScrollProgressExample(),
      MotionDragAxesExample(),
      MotionStaggerOrderExample(),
      MotionPresenceModesExample(),
      MotionTransformExample(),
      MotionViewportReplayExample(),
    ]) {
      await _mount(tester, example, reduced: true);
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull, reason: '${example.runtimeType}');
      if (example is MotionDrawPathExample) {
        expect(
          tester.allRenderObjects
              .whereType<RenderNibDrawPath>()
              .toSet()
              .single
              .progress
              .value,
          1,
        );
        expect(
          tester.allRenderObjects
              .whereType<RenderNibPathMotion>()
              .toSet()
              .single
              .progress
              .value,
          1,
        );
      }
      if (example is MotionLoopExample) {
        await _tap(tester, 'Replay');
        expect(_value(_controller(tester, 'loop-motion'), NibProperty.x), 56);
      }
      if (example is MotionTransformExample) {
        await _tap(tester, 'Compose');
        expect(
          _value(_controller(tester, 'transform-motion'), NibProperty.x),
          48,
        );
      }
      await tester.pumpWidget(const SizedBox.shrink());
      expect(
        tester.takeException(),
        isNull,
        reason: '${example.runtimeType} disposal',
      );
    }
  });
}
