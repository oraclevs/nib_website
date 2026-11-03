import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/playground/examples_page.dart';
import 'package:nib_ember_living/playground/playground_page.dart';
import 'package:nib_ember_living/recipes/recipe_catalog.dart';

void main() {
  testWidgets('gallery search narrows recipes and opens the selected route', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String? opened;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ExamplesPage(onOpenRecipe: (id) => opened = id)),
      ),
    );
    await tester.enterText(find.byType(TextField), 'spring retarget');
    await tester.pump();
    expect(find.text('Mid-flight spring retarget'), findsOneWidget);
    expect(find.text('Two-sided card flip'), findsNothing);
    await tester.tap(find.text('Mid-flight spring retarget'));
    expect(opened, 'spring-retarget');
    expect(tester.takeException(), isNull);
  });

  testWidgets('playground offers live preview, tuning, and source on mobile', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlaygroundPage(
            recipeId: 'spring-retarget',
            onOpenRecipe: (_) {},
          ),
        ),
      ),
    );
    expect(find.text('Retarget the spring'), findsOneWidget);
    await tester.tap(find.text('Tune'));
    await tester.pump();
    expect(find.text('Travel distance'), findsOneWidget);
    await tester.tap(find.text('Code'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Source files'));
    await tester.pump();
    expect(
      find.textContaining('Copy spring_retarget_recipe.dart'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('every recipe fits the mobile playground viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final recipe in verifiedRecipes) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlaygroundPage(
              key: ValueKey(recipe.id),
              recipeId: recipe.id,
              onOpenRecipe: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: recipe.id);
    }
  });
}
