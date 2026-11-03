import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_motion/nib_motion.dart' as motion;
import 'package:nib_ember_living/components/component_catalog.dart';
import 'package:nib_ember_living/components/component_theme.dart';

void main() {
  for (final id in ['glass-bottom-navigation', 'liquid-bottom-navigation']) {
    testWidgets(
      '$id updates content, retains draft, and obeys external state',
      (tester) async {
        final guide = componentById(id)!;
        final events = <String>[];
        var settings = guide.initial;
        late StateSetter change;
        await tester.pumpWidget(
          MaterialApp(
            theme: componentEmberTheme(),
            home: StatefulBuilder(
              builder: (context, setState) {
                change = setState;
                return Scaffold(
                  body: SingleChildScrollView(
                    child: buildComponentDemo(
                      guide,
                      settings,
                      (next) => setState(() => settings = next),
                      events.add,
                    ),
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();
        final bar = find.byType(motion.NibNavBar);
        expect(
          tester.widget<motion.NibNavBar>(bar).style.glass,
          id.startsWith('glass'),
        );
        expect(
          tester.widget<motion.NibNavBar>(bar).indicator.type,
          id.startsWith('glass')
              ? motion.NibNavIndicatorType.pill
              : motion.NibNavIndicatorType.liquid,
        );
        await tester.tap(find.bySemanticsLabel('Open inbox'));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('bottom-nav-inbox')), findsOneWidget);
        await tester.enterText(find.byType(TextField), 'Keep this draft');
        await tester.tap(find.bySemanticsLabel('Open settings'));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('bottom-nav-settings')),
          findsOneWidget,
        );
        await tester.tap(find.bySemanticsLabel('Open inbox'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'Keep this draft',
        );
        change(() => settings = settings.change('radius', 4.0));
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'Keep this draft',
        );
        await tester.tap(find.text('Next destination from host'));
        await tester.pumpAndSettle();
        expect(tester.widget<motion.NibNavBar>(bar).currentIndex, 2);
        expect(events.last, 'onIndexChanged: 2');
        final target = find.bySemanticsLabel('Open ${settings.text}');
        final gesture = await tester.startGesture(tester.getCenter(target));
        await tester.pump(const Duration(milliseconds: 150));
        await gesture.cancel();
        await tester.pumpAndSettle();
        expect(tester.widget<motion.NibNavBar>(bar).currentIndex, 0);
        expect(
          find.byKey(const ValueKey('bottom-nav-overview')),
          findsOneWidget,
        );
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(tester.binding.transientCallbackCount, 0);
      },
    );
    for (final width in [360.0, 390.0, 768.0, 1024.0, 1440.0]) {
      testWidgets('$id long label at $width /2x, reduced motion and keyboard', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final guide = componentById(id)!;
        final settings = guide.initial
            .change('text', 'A very long workspace destination')
            .change('animated', false);
        await tester.pumpWidget(
          MaterialApp(
            theme: componentEmberTheme(),
            home: MediaQuery(
              data: MediaQueryData(
                size: Size(width, 900),
                textScaler: const TextScaler.linear(2),
                disableAnimations: true,
              ),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: buildComponentDemo(guide, settings, (_) {}, (_) {}),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final bar = tester.widget<motion.NibNavBar>(
          find.byType(motion.NibNavBar),
        );
        expect(bar.style.labelStyle!.fontSize, 24);
        final target = find.bySemanticsLabel('Open inbox');
        final detector = find.descendant(
          of: target,
          matching: find.byType(FocusableActionDetector),
        );
        final gesture = find
            .descendant(of: detector, matching: find.byType(GestureDetector))
            .first;
        Focus.of(tester.element(gesture)).requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<motion.NibNavBar>(find.byType(motion.NibNavBar))
              .currentIndex,
          1,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
