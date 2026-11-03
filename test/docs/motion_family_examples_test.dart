import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/docs/examples/motion_family_examples.dart';
import 'package:nib_motion/nib_motion.dart';

Future<void> pumpDemo(
  WidgetTester tester,
  Widget child, {
  double width = 320,
}) async {
  tester.view.physicalSize = const Size(360, 300);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('all family demos fit a 257 by 240 preview', (tester) async {
    for (final demo in <Widget>[
      const MotionPresetExample(),
      const MotionListExample(),
      const MotionGestureToolsExample(),
      const MotionRoutesExample(),
    ]) {
      await pumpDemo(tester, demo, width: 257);
      expect(
        tester.takeException(),
        isNull,
        reason: demo.runtimeType.toString(),
      );
    }
  });

  testWidgets('preset chooser uses each public widget and replays safely', (
    tester,
  ) async {
    await pumpDemo(tester, const MotionPresetExample());
    expect(find.byType(NibBounce), findsOneWidget);
    await tester.tap(find.text('Shake').first);
    await tester.pump();
    expect(find.byType(NibShake), findsOneWidget);
    await tester.tap(find.text('Shake again'));
    await tester.pump();
    await tester.tap(find.text('Flip').first);
    await tester.pump();
    expect(find.byType(NibFlip), findsOneWidget);
    await tester.tap(find.text('Flip card'));
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.widget<NibFlip>(find.byType(NibFlip)).isFlipped, isTrue);
    await tester.tap(find.text('Float').first);
    await tester.pump();
    expect(find.byType(NibFloat), findsOneWidget);
    await tester.tap(find.text('Pulse').first);
    await tester.pump();
    expect(find.byType(NibPulse), findsOneWidget);
    await tester.tap(find.text('Rubber band').first);
    await tester.pump();
    expect(find.byType(NibRubberBand), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('list controls change actual stagger properties and replay', (
    tester,
  ) async {
    await pumpDemo(tester, const MotionListExample());
    var list = tester.widget<NibMotionList>(find.byType(NibMotionList));
    expect(list.staggerDirection, NibStaggerDirection.forward);
    expect(list.staggerDelay, const Duration(milliseconds: 60));
    await tester.tap(find.byTooltip('Change stagger direction'));
    await tester.pump();
    await tester.tap(find.byTooltip('Change stagger delay'));
    await tester.pump();
    list = tester.widget<NibMotionList>(find.byType(NibMotionList));
    expect(list.staggerDirection, NibStaggerDirection.reverse);
    expect(list.staggerDelay, const Duration(milliseconds: 160));
    final key = list.key;
    await tester.tap(find.byTooltip('Replay list entrance'));
    await tester.pump();
    expect(
      tester.widget<NibMotionList>(find.byType(NibMotionList)).key,
      isNot(key),
    );
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('gesture modes, keyboard removal, and reset remain operable', (
    tester,
  ) async {
    await pumpDemo(tester, const MotionGestureToolsExample());
    expect(find.byType(NibPinch), findsOneWidget);
    await tester.tap(find.text('Dismiss'));
    await tester.pump();
    expect(find.byType(NibSwipeDismiss), findsOneWidget);
    await tester.tap(find.text('Remove card'));
    await tester.pump();
    expect(find.text('Card removed'), findsOneWidget);
    await tester.tap(find.text('Reset card'));
    await tester.pump();
    expect(find.byType(NibSwipeDismiss), findsOneWidget);
    await tester.drag(
      find.byKey(const ValueKey('gesture-card')),
      const Offset(105, 0),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Card removed'), findsOneWidget);
    await tester.tap(find.text('Reset card'));
    await tester.pump();
    await tester.tap(find.text('Pinch'));
    await tester.pump();
    expect(find.byType(NibPinch), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('nested navigator pushes a NibPageRoute and pops it', (
    tester,
  ) async {
    await pumpDemo(tester, const MotionRoutesExample());
    expect(find.text('Home page'), findsOneWidget);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator).last);
    expect(navigator.canPop(), isFalse);
    await tester.tap(find.byTooltip('Open page'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(navigator.canPop(), isTrue);
    expect(find.text('Detail page'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(navigator.canPop(), isFalse);
    expect(find.text('Home page'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
