import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/recipes/recipe_catalog.dart';
import 'package:nib_ember_living/recipes/recipe_runtime.dart';
import 'package:nib_ember_living/recipes/recipe_export.dart';
import 'package:nib_ember_living/recipes/spring_retarget_recipe.dart';
import 'package:nib_motion/nib_motion.dart';

void main() {
  test('the catalog has unique durable routes and bounded settings', () {
    expect(verifiedRecipes.length, 30);
    expect(verifiedRecipes.map((recipe) => recipe.id).toSet().length, 30);
    for (final recipe in verifiedRecipes) {
      expect(recipe.route, '/playground/${recipe.id}');
      expect(recipe.initial, inInclusiveRange(recipe.minimum, recipe.maximum));
      expect(recipeById(recipe.id), same(recipe));
    }
  });

  test('shared URL restores only a finite in-range value on its own path', () {
    final recipe = recipeById('spring-retarget')!;
    expect(
      recipeValueFromUri(
        recipe,
        Uri.parse(
          'http://127.0.0.1:8123/playground/spring-retarget?value=173.50',
        ),
      ),
      173.5,
    );
    expect(
      recipeValueFromUri(
        recipe,
        Uri.parse(
          'http://127.0.0.1:8123/playground/spring-retarget?value=9999',
        ),
      ),
      recipe.maximum,
    );
    expect(
      recipeValueFromUri(
        recipe,
        Uri.parse('http://127.0.0.1:8123/playground/spring-retarget?value=NaN'),
      ),
      recipe.initial,
    );
    expect(
      recipeValueFromUri(
        recipe,
        Uri.parse('http://127.0.0.1:8123/playground/card-flip?value=140'),
      ),
      recipe.initial,
    );
  });

  testWidgets('every catalog recipe mounts without a framework exception', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final recipe in verifiedRecipes) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 600,
                height: 440,
                child: recipe.id == 'spring-retarget'
                    ? const SpringRetargetRecipe()
                    : RecipeRuntime(
                        key: ValueKey(recipe.id),
                        recipeId: recipe.id,
                        value: recipe.initial,
                      ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull, reason: recipe.id);
    }
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('repeated spring retargeting remains interactive', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(height: 440, child: SpringRetargetRecipe()),
        ),
      ),
    );
    await tester.tap(find.text('Send right'));
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(find.text('Send left'));
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(find.text('Send right'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Send left'), findsOneWidget);
  });

  testWidgets('source assets are the checked implementation files', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    final runtime = await rootBundle.loadString(
      'lib/recipes/recipe_runtime.dart',
    );
    final spring = await rootBundle.loadString(
      'lib/recipes/spring_retarget_recipe.dart',
    );
    final tuning = await rootBundle.loadString(
      'lib/recipes/recipe_tuning.dart',
    );
    expect(
      runtime == File('lib/recipes/recipe_runtime.dart').readAsStringSync(),
      isTrue,
      reason: 'Bundled runtime source must match the checked Dart file.',
    );
    expect(
      spring ==
          File('lib/recipes/spring_retarget_recipe.dart').readAsStringSync(),
      isTrue,
      reason: 'Bundled spring source must match the checked Dart file.',
    );
    expect(
      tuning == File('lib/recipes/recipe_tuning.dart').readAsStringSync(),
      isTrue,
      reason: 'Bundled tuning source must match the checked Dart file.',
    );
    expect(runtime, contains('class RecipeRuntime extends StatefulWidget'));
    expect(runtime, contains("'card-flip' => _cardFlip()"));
    for (final recipe in verifiedRecipes.where(
      (item) => item.id != 'spring-retarget',
    )) {
      expect(
        runtime,
        contains("'${recipe.id}' => _"),
        reason: '${recipe.id} must select its own implementation branch',
      );
    }
    expect(
      spring,
      contains('class SpringRetargetRecipe extends StatefulWidget'),
    );
  });

  for (final recipe in verifiedRecipes.where(
    (item) => item.id != 'spring-retarget',
  )) {
    testWidgets('${recipe.id} responds to interaction', (tester) async {
      tester.view.physicalSize = const Size(1100, 850);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 600,
                height: 440,
                child: RecipeRuntime(
                  recipeId: recipe.id,
                  value: recipe.initial,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      switch (recipe.id) {
        case 'card-flip':
          await tester.tap(find.text('Tap to flip'));
          await tester.pump(const Duration(milliseconds: 120));
          expect(
            tester.widget<NibFlip>(find.byType(NibFlip)).isFlipped,
            isTrue,
          );
        case 'hover-press':
          await tester.tap(find.text('Press me · 0'));
          await tester.pump();
          expect(find.text('Press me · 1'), findsOneWidget);
        case 'viewport-reveal':
        case 'local-parallax':
        case 'scroll-progress':
          await tester.drag(find.byType(ListView).first, const Offset(0, -130));
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull, reason: recipe.id);
        case 'accordion':
          await tester.tap(find.text('What is Nib?'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 650));
          expect(
            find.text('Animation and native Flutter components.'),
            findsOneWidget,
          );
        default:
          await tester.tap(find.byType(FilledButton).first);
          await tester.pump(const Duration(milliseconds: 120));
          switch (recipe.id) {
            case 'animated-counter':
              expect(find.text('10'), findsOneWidget);
            case 'progress-choreography':
              expect(find.text('25%'), findsOneWidget);
            case 'swipe-restore':
              expect(find.textContaining('Row dismissed'), findsOneWidget);
            case 'presence-reflow':
              await tester.pump(const Duration(seconds: 1));
              expect(find.text('Remove me'), findsNothing);
            case 'expanding-card':
              expect(
                find.text('Details stay attached to their card.'),
                findsOneWidget,
              );
            case 'filtered-list':
              await tester.pump(const Duration(seconds: 1));
              expect(find.text('Components'), findsNothing);
            case 'focus-overlay':
              expect(find.text('Close panel'), findsNWidgets(2));
            case 'loading-result':
              expect(find.text('Working locally…'), findsOneWidget);
              await tester.pump(Duration(milliseconds: recipe.initial.round()));
              expect(find.text('Done'), findsOneWidget);
            case 'command-palette':
              expect(find.text('Open docs'), findsOneWidget);
            case 'page-transition':
              expect(find.text('Second view'), findsOneWidget);
            case 'form-validation':
              expect(find.textContaining('Use at least'), findsOneWidget);
            case 'tab-content':
              expect(find.text('Copyable Dart'), findsOneWidget);
            default:
              expect(tester.takeException(), isNull, reason: recipe.id);
          }
      }
      expect(tester.takeException(), isNull, reason: recipe.id);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
