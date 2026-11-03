import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/playground/playground_page.dart';
import 'package:nib_ember_living/recipes/recipe_catalog.dart';
import 'package:nib_ember_living/recipes/recipe_export.dart';
import 'package:nib_ember_living/recipes/spring_retarget_recipe.dart';

void main() {
  testWidgets(
    'tuning a spring updates preview settings and exported launcher',
    (tester) async {
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
      await tester.tap(find.text('Tune'));
      await tester.pump();
      final slider = find.byKey(const ValueKey('recipe-control-stiffness'));
      await tester.ensureVisible(slider);
      await tester.pumpAndSettle();
      await tester.drag(slider, const Offset(65, 0));
      await tester.pump();
      final live = tester.widget<SpringRetargetRecipe>(
        find.byType(SpringRetargetRecipe, skipOffstage: false),
      );
      expect(live.settings.stiffness, greaterThan(180));
      final recipe = recipeById('spring-retarget')!;
      final launcher = recipeLauncher(
        recipe,
        live.settings.distance,
        defaultRecipeTuning(recipe).copyWith(
          stiffness: live.settings.stiffness,
          damping: live.settings.damping,
          mass: live.settings.mass,
        ),
      );
      expect(launcher, contains('stiffness: ${live.settings.stiffness}'));
      expect(launcher, contains('mass: ${live.settings.mass}'));
    },
  );
}
