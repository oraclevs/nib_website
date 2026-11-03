import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/recipes/recipe_runtime.dart';
import 'package:nib_motion/nib_motion.dart';

void main() {
  testWidgets('reference card supports tap, keyboard, transport and disposal', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();
    final controller = RecipeRuntimeController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 700,
            height: 390,
            child: RecipeRuntime(
              recipeId: 'card-flip',
              value: 600,
              controller: controller,
            ),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(NibFlip)), const Size(207, 252));
    expect(tester.widget<NibFlip>(find.byType(NibFlip)).isFlipped, isFalse);
    final tilt = tester.widget<NibMotion>(
      find.ancestor(of: find.byType(NibFlip), matching: find.byType(NibMotion)),
    );
    expect((tilt.animate as NibAnim).rotate, closeTo(-5 / 360, 0.000001));
    expect(
      find.semantics.byLabel(RegExp('Flip the demonstration card')),
      findsOneWidget,
    );
    expect(
      find.semantics.byLabel(RegExp('Return to front of demonstration card')),
      findsNothing,
    );
    await tester.tap(find.text('Tap to flip'));
    await tester.pumpAndSettle();
    expect(tester.widget<NibFlip>(find.byType(NibFlip)).isFlipped, isTrue);
    expect(
      find.semantics.byLabel(RegExp('Return to front of demonstration card')),
      findsOneWidget,
    );
    expect(
      find.semantics.byLabel(RegExp('Flip the demonstration card')),
      findsNothing,
    );
    await tester.tap(find.text('Tap to return'));
    await tester.pumpAndSettle();
    expect(tester.widget<NibFlip>(find.byType(NibFlip)).isFlipped, isFalse);
    controller.play();
    await tester.pumpAndSettle();
    expect(tester.widget<NibFlip>(find.byType(NibFlip)).isFlipped, isTrue);
    controller.reset();
    await tester.pumpAndSettle();
    expect(tester.widget<NibFlip>(find.byType(NibFlip)).isFlipped, isFalse);
    final front = find.ancestor(
      of: find.text('Tap to flip'),
      matching: find.byType(InkWell),
    );
    tester.widget<InkWell>(front).focusNode!.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(tester.widget<NibFlip>(find.byType(NibFlip)).isFlipped, isTrue);
    controller.reset();
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    controller.play();
    controller.reset();
    controller.dispose();
    semantics.dispose();
    expect(tester.takeException(), isNull);
  });

  testWidgets('reference card shrinks to the HTML mobile dimensions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 350,
            height: 340,
            child: RecipeRuntime(recipeId: 'card-flip', value: 600),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(NibFlip)), const Size(180, 226));
    expect(tester.takeException(), isNull);
  });
}
