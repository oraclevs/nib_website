import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/components/component_theme.dart';
import 'package:nib_ember_living/components/component_catalog.dart';
import 'package:nib_ember_living/components/component_export.dart';
import 'package:nib_ember_living/docs/doc_example_catalog.dart';
import 'package:nib_ember_living/docs/examples/motion_family_examples.dart';
import 'package:nib_ember_living/ember_material_theme.dart';
import 'package:nib_ember_living/ember_theme.dart';
import 'package:nib_ember_living/pages/doc_example_panel.dart';
import 'package:nib_ember_living/recipes/recipe_catalog.dart';
import 'package:nib_ember_living/recipes/recipe_export.dart';

import 'support/file_asset_bundle.dart';

void main() {
  testWidgets('gesture card and chips use Ember in both preview themes', (
    tester,
  ) async {
    for (final theme in [emberMaterialTheme(), componentEmberTheme()]) {
      await tester.pumpWidget(
        MaterialApp(
          key: UniqueKey(),
          theme: theme,
          home: const Scaffold(
            body: Center(
              child: SizedBox(width: 360, child: MotionGestureToolsExample()),
            ),
          ),
        ),
      );
      await tester.pump();
      final card = tester.widget<Container>(
        find.byKey(const ValueKey('gesture-card')),
      );
      final decoration = card.decoration! as BoxDecoration;
      expect(decoration.color, Ember.soft);
      expect((decoration.border! as Border).bottom.color, Ember.border);
      final label = tester.widget<Text>(find.text('Pinch with two fingers'));
      expect(label.style!.color, Ember.text);
      expect(label.textAlign, TextAlign.center);
      final chip = tester.widget<RawChip>(find.byType(RawChip).first);
      expect(chip.selected, isTrue);
      expect(theme.chipTheme.selectedColor, Ember.soft);
      expect(
        DefaultTextStyle.of(tester.element(find.text('Pinch'))).style.color,
        Ember.accent,
      );
      expect(theme.colorScheme.secondaryContainer, Ember.raised);
      expect(theme.colorScheme.outlineVariant, Ember.border);
      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();
      expect(find.text('Swipe sideways'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  test(
    'standalone guide and playground exports include the exact theme',
    () async {
      final example = docExampleFor('motion', 'drag-and-drop')!;
      final theme = File('lib/ember_material_theme.dart').readAsStringSync();
      final guide = await loadDocExampleSource(
        example,
        bundle: FileAssetBundle(),
      );
      final recipe = recipeById(example.playgroundId)!;
      final playground = recipeRunnableExample(
        recipe,
        recipe.initial,
        defaultRecipeTuning(recipe),
        File(recipe.sourceAsset).readAsStringSync(),
        theme,
      );
      final output = Directory('build/ember_theme_export_verification')
        ..createSync(recursive: true);
      File('${output.path}/gesture_guide.dart').writeAsStringSync(guide);
      File('${output.path}/gesture_playground.dart')
          .writeAsStringSync(playground);
      for (final exported in [guide, playground]) {
        expect(exported, contains('theme: emberMaterialTheme()'));
        expect(
          exported,
          contains(
            theme
                .replaceFirst("import 'package:flutter/material.dart';", '')
                .trim(),
          ),
        );
        expect(
          exported,
          isNot(contains("import 'ember_material_theme.dart';")),
        );
        expect(RegExp(r'void main\(').allMatches(exported), hasLength(1));
      }
    },
  );
  test(
    'save representative complete exports with shared Ember theme',
    () async {
      final output = Directory('build/ember_theme_export_verification')
        ..createSync(recursive: true);
      final theme = File('lib/ember_material_theme.dart').readAsStringSync();
      final componentTheme = File('lib/components/component_theme.dart')
          .readAsStringSync();
      for (final id in ['radio-group', 'input', 'card']) {
        final guide = componentById(id)!;
        final source = await componentRunnableSource(guide, guide.initial);
        expect(source, contains('ColorScheme emberColorScheme'));
        File('${output.path}/component_$id.dart').writeAsStringSync(source);
      }
      for (final id in ['spring-retarget', 'card-flip', 'form-validation']) {
        final recipe = recipeById(id)!;
        final source = recipeRunnableExample(
          recipe,
          recipe.initial,
          defaultRecipeTuning(recipe),
          File(recipe.sourceAsset).readAsStringSync(),
          theme,
          File('lib/recipes/recipe_tuning.dart').readAsStringSync(),
          componentTheme,
        );
        File('${output.path}/recipe_$id.dart').writeAsStringSync(source);
      }
    },
  );
}
