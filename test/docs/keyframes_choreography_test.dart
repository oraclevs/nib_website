import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/docs/examples/motion_keyframes_example.dart';
import 'package:nib_motion/nib_motion.dart';

Future<void> _pumpExample(
  WidgetTester tester, {
  bool reducedMotion = false,
  Brightness brightness = Brightness.dark,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reducedMotion),
        child: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 257,
              child: SingleChildScrollView(child: MotionKeyframesExample()),
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

void _expectPositions(WidgetTester tester, List<Offset> expected) {
  final controllers = _controllers(tester);
  expect(controllers, hasLength(expected.length));
  for (var i = 0; i < controllers.length; i++) {
    expect(
      controllers[i].motionValueOf(NibProperty.x)!.value,
      closeTo(expected[i].dx, 0.02),
      reason: 'Tile $i horizontal position',
    );
    expect(
      controllers[i].motionValueOf(NibProperty.y)!.value,
      closeTo(expected[i].dy, 0.02),
      reason: 'Tile $i vertical position',
    );
  }
}

const _scatter = [Offset(-72, -52), Offset(-14, 52), Offset(72, 4)];
const _cross = [Offset(72, -48), Offset(14, 64), Offset(-72, 8)];
const _aligned = [Offset(62, 12), Offset(0, 12), Offset(-62, 12)];

void main() {
  testWidgets('three tracks reach intermediate and final positions together', (
    tester,
  ) async {
    await _pumpExample(tester);
    _expectPositions(tester, _scatter);

    await tester.pump(const Duration(milliseconds: 600));
    _expectPositions(tester, [
      const Offset(0, -50),
      const Offset(0, 58),
      const Offset(0, 6),
    ]);

    await tester.pump(const Duration(milliseconds: 600));
    _expectPositions(tester, _cross);
    await tester.pump(const Duration(milliseconds: 1200));
    _expectPositions(tester, _aligned);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'stage previews freeze positions and replay restarts the tracks',
    (tester) async {
      await _pumpExample(tester);
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('Cross'));
      await tester.pump();
      _expectPositions(tester, _cross);
      await tester.pump(const Duration(seconds: 3));
      _expectPositions(tester, _cross);

      await tester.tap(find.text('Align'));
      await tester.pump();
      _expectPositions(tester, _aligned);
      await tester.tap(find.text('Scatter'));
      await tester.pump();
      _expectPositions(tester, _scatter);

      await tester.tap(find.text('Replay keyframes'));
      await tester.pump();
      _expectPositions(tester, _scatter);
      await tester.pump(const Duration(milliseconds: 1200));
      _expectPositions(tester, _cross);
      await tester.pump(const Duration(milliseconds: 1200));
      _expectPositions(tester, _aligned);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('duration changes the timing of every track', (tester) async {
    await _pumpExample(tester);
    final slider = tester.widget<Slider>(find.byType(Slider));
    slider.onChanged!(4800);
    await tester.pump();
    tester.widget<Slider>(find.byType(Slider)).onChangeEnd!(4800);
    await tester.pump();
    expect(find.text('Duration · 4.8 s'), findsOneWidget);
    _expectPositions(tester, _scatter);
    await tester.pump(const Duration(milliseconds: 2400));
    _expectPositions(tester, _cross);
    await tester.pump(const Duration(milliseconds: 2400));
    _expectPositions(tester, _aligned);
  });

  testWidgets('reduced motion shows the result immediately at narrow widths', (
    tester,
  ) async {
    await _pumpExample(tester, reducedMotion: true);
    _expectPositions(tester, _aligned);
    expect(
      find.text('Reduced motion: showing the aligned result.'),
      findsOneWidget,
    );
    expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNull);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    for (final button in tester.widgetList<OutlinedButton>(
      find.byType(OutlinedButton),
    )) {
      expect(button.onPressed, isNull);
    }
    await tester.pump(const Duration(seconds: 5));
    _expectPositions(tester, _aligned);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a changed reduced motion preference settles a paused stage', (
    tester,
  ) async {
    await _pumpExample(tester);
    await tester.tap(find.text('Scatter'));
    await tester.pump();
    _expectPositions(tester, _scatter);

    await _pumpExample(tester, reducedMotion: true);
    _expectPositions(tester, _aligned);
    await _pumpExample(tester, brightness: Brightness.light);
    await tester.pumpAndSettle();
    _expectPositions(tester, _aligned);
    expect(
      find.text('Select a stage to inspect its positions.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
