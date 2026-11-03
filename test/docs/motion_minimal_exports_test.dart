import 'dart:io';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/docs/motion_minimal_examples.dart';
import 'package:nib_ember_living/recipes/recipe_catalog.dart';
import 'package:nib_ember_living/recipes/recipe_export.dart';

void main() {
  test('all minimal motion exports compile as standalone main.dart files', () async {
    final folder = Directory('.dart_tool/minimal_motion_export_check');
    if (folder.existsSync()) folder.deleteSync(recursive: true);
    folder.createSync(recursive: true);
    final exported = <String>{};
    final lineWidths = <String, int>{};
    final evidence = Directory('docs/evidence/2026-10-28-code-logo');
    evidence.createSync(recursive: true);
    final samples = Directory('${evidence.path}/motion-code-samples');
    samples.createSync(recursive: true);
    for (final recipe in allRecipes) {
      final source = recipeMinimalExample(
        recipe,
        recipe.initial,
        defaultRecipeTuning(recipe),
      );
      expect(source, isNotNull, reason: recipe.id);
      if (source == null) continue;
      expect(source, contains('void main()'), reason: recipe.id);
      lineWidths[recipe.id] = source
          .split('\n')
          .where((line) => !line.trimLeft().startsWith('//'))
          .fold<int>(
            0,
            (longest, line) => line.length > longest ? line.length : longest,
          );
      if (recipe.id == 'spring-retarget' ||
          recipe.documentationExample?.widgetClass ==
              'MotionKeyframesExample' ||
          recipe.documentationExample?.constructorArguments ==
              'composed: true') {
        File('${samples.path}/${recipe.id}.dart').writeAsStringSync(source);
      }
      if (recipe.documentationExample == null ||
          recipe.documentationExample!.widgetClass.startsWith('Motion')) {
        final lines = source
            .split('\n')
            .where((line) => !line.trimLeft().startsWith('//'));
        expect(
          lines.every((line) => line.length <= 88),
          isTrue,
          reason:
              '${recipe.id} has a code line longer than 88 columns: ${lines.where((line) => line.length > 88).join('\n')}',
        );
      }
      expect(source, isNot(contains('recipe_runtime.dart')), reason: recipe.id);
      exported.add(source);
    }
    for (final recipe in verifiedRecipes) {
      final source = recipeMinimalExample(
        recipe,
        recipe.maximum,
        defaultRecipeTuning(recipe),
      )!;
      expect(
        source
            .split('\n')
            .where((line) => !line.trimLeft().startsWith('//'))
            .every((line) => line.length <= 88),
        isTrue,
        reason: 'Tuned ${recipe.id}',
      );
      exported.add(source);
    }
    // Also exercise every primitive generator independently of catalog aliases.
    for (final family in [
      'spring',
      'tween',
      'keyframes',
      'values',
      'presence',
      'layout',
      'hover',
      'drag',
      'pinch',
      'swipe',
      'flip',
      'viewport',
      'scroll',
      'parallax',
      'accessibility',
      'variants',
      'controller',
      'timeline',
      'path',
      'draw',
      'navigation',
      'route',
      'glass',
      'physics',
      'preset',
      'stagger',
      'loop',
      'transform',
      'text',
    ]) {
      exported.add(minimalMotionExample(family));
    }
    // Print the actual catalog coverage so release evidence is reproducible.
    final covered = allRecipes
        .where(
          (r) =>
              recipeMinimalExample(r, r.initial, defaultRecipeTuning(r)) !=
              null,
        )
        .length;
    // ignore: avoid_print
    print(
      'Minimal recipe coverage: $covered/${allRecipes.length}; standalone programs compiled: ${exported.length}',
    );
    File(
      '${evidence.path}/motion-minimal-line-widths.json',
    ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(lineWidths));
    var index = 0;
    for (final source in exported) {
      File('${folder.path}/example_${index++}.dart').writeAsStringSync(source);
    }
    final flutterRoot =
        Platform.environment['FLUTTER_ROOT'] ?? '/home/occ/DevTools/flutter';
    final result = await Process.run('$flutterRoot/bin/dart', [
      'analyze',
      folder.path,
    ]);
    File('${evidence.path}/motion-generated-apps-analyze.log')
        .writeAsStringSync('${result.stdout}\n${result.stderr}');
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    final imports = List.generate(
      index,
      (i) => "import 'example_$i.dart' as sample$i;",
    ).join('\n');
    final launchers = List.generate(index, (i) => 'sample$i.main').join(', ');
    File('${folder.path}/consumer_test.dart').writeAsStringSync("""
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
$imports
void main() {
  testWidgets('every exported app compiles and mounts', (tester) async {
    var index = 0;
    for (final launch in [$launchers]) {
      launch();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('Apply next frame').evaluate().isNotEmpty) {
        await tester.tap(find.text('Apply next frame'));
        await tester.pump();
        await tester.tap(find.text('Apply next frame'));
        await tester.pump();
        expect(find.text('Native generated UI'), findsOneWidget);
      }
      expect(tester.takeException(), isNull, reason: 'Export \$index');
      await tester.pumpWidget(const SizedBox());
      index++;
    }
  });
}
""");
    final compiled = await Process.run('$flutterRoot/bin/flutter', [
      'test',
      '--no-pub',
      '${folder.path}/consumer_test.dart',
      '--reporter',
      'expanded',
    ]);
    File('${evidence.path}/motion-generated-apps-compile-mount.log')
        .writeAsStringSync('${compiled.stdout}\n${compiled.stderr}');
    expect(
      compiled.exitCode,
      0,
      reason: '${compiled.stdout}\n${compiled.stderr}',
    );
    folder.deleteSync(recursive: true);
  }, timeout: const Timeout(Duration(minutes: 2)));
}
