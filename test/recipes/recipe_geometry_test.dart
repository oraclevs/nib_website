import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/recipes/recipe_runtime.dart';
import 'package:nib_motion/nib_motion.dart';

Widget _host(String id, double value) => MaterialApp(
  home: Scaffold(
    body: Center(
      child: SizedBox(
        width: 600,
        height: 440,
        child: RecipeRuntime(recipeId: id, value: value),
      ),
    ),
  ),
);

void main() {
  testWidgets('spring and timed markers move to the same destination', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_host('spring-tween', 130));
    await tester.tap(find.byType(FilledButton).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    final motions = find.byType(NibMotion);
    final spring = tester.renderObject<RenderNibMotion>(motions.at(0));
    final timed = tester.renderObject<RenderNibMotion>(motions.at(1));
    expect(spring.translateX.value, greaterThan(115));
    expect(timed.translateX.value, closeTo(130, 3));
  });

  testWidgets('keyed reordering changes row positions', (tester) async {
    tester.view.physicalSize = const Size(1100, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_host('keyed-reorder', 10));
    final before = tester.widget<NibLayoutGroup>(find.byType(NibLayoutGroup));
    expect(before.children.map((child) => child.key), [
      const ValueKey(0),
      const ValueKey(1),
      const ValueKey(2),
    ]);
    await tester.tap(find.byType(FilledButton).first);
    await tester.pump(const Duration(seconds: 2));
    final after = tester.widget<NibLayoutGroup>(find.byType(NibLayoutGroup));
    expect(after.children.map((child) => child.key), [
      const ValueKey(1),
      const ValueKey(2),
      const ValueKey(0),
    ]);
  });

  testWidgets('scroll-linked marker follows the local scroll position', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_host('scroll-progress', 180));
    final marker = find.byKey(const ValueKey('scroll-progress-marker'));
    final before = tester.getTopLeft(marker).dx;
    await tester.drag(find.byType(ListView), const Offset(0, -180));
    await tester.pump(const Duration(milliseconds: 100));
    final after = tester.getTopLeft(marker).dx;
    expect(after - before, greaterThan(40));
  });

  testWidgets('keyboard alternative moves snap target', (tester) async {
    tester.view.physicalSize = const Size(1100, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_host('drag-snap', 95));
    await tester.tap(find.byType(FilledButton).first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    final render = tester.renderObject<RenderNibMotion>(find.byType(NibMotion));
    expect(render.translateX.value, greaterThan(70));
  });

  testWidgets('overlay returns focus to its trigger', (tester) async {
    tester.view.physicalSize = const Size(1100, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_host('focus-overlay', 36));
    await tester.tap(find.byType(FilledButton).first);
    await tester.pump();
    final close = find.widgetWithText(TextButton, 'Close panel');
    expect(close, findsOneWidget);
    await tester.tap(close);
    await tester.pump();
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(find.byType(FilledButton))
          .focusNode
          ?.hasFocus,
      isTrue,
    );
  });

  testWidgets('reduced motion keeps the endpoint and removes parallax', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: SizedBox(
              width: 600,
              height: 440,
              child: RecipeRuntime(recipeId: 'spring-tween', value: 130),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(FilledButton).first);
    await tester.pump();
    final spring = tester.renderObject<RenderNibMotion>(
      find.byType(NibMotion).at(0),
    );
    expect(spring.translateX.value, closeTo(130, 1));

    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: SizedBox(
              width: 600,
              height: 440,
              child: RecipeRuntime(recipeId: 'local-parallax', value: .45),
            ),
          ),
        ),
      ),
    );
    expect(tester.widget<NibParallax>(find.byType(NibParallax)).factor, 1);
  });
}
