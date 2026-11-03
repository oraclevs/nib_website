import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/content/motion_foundations_guides.dart';
import 'package:nib_ember_living/content/site_content.dart';
import 'package:nib_ember_living/recipes/recipe_catalog.dart';
import 'package:nib_ember_living/recipes/recipe_export.dart';
import 'package:nib_ember_living/recipes/recipe_tuning.dart';

void main() {
  test('recipe guide links resolve to real articles', () {
    final routes = SiteContent.articles.map((article) => article.route).toSet();
    for (final recipe in verifiedRecipes) {
      expect(routes, contains(recipe.docsRoute), reason: recipe.id);
      expect(recipe.purpose, isNotEmpty, reason: recipe.id);
    }
  });

  test('copied default and tuned examples execute in an isolated consumer', () async {
    final project = Directory.current.absolute;
    final root = project.parent;
    final temp = await Directory.systemTemp.createTemp('nib-copied-consumer-');
    final stamp = DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
    final evidence = Directory(
      '${project.path}/docs/evidence/2026-10-28-correction/recipe-exports/$stamp',
    );
    await evidence.create(recursive: true);
    final flutter =
        Platform.environment['FLUTTER_BIN'] ??
        (Platform.environment['FLUTTER_ROOT'] == null
            ? 'flutter'
            : '${Platform.environment['FLUTTER_ROOT']}/bin/flutter');
    final commands = <Map<String, Object?>>[];
    final cases = <_ExportCase>[];
    final sources = <String, String>{
      for (final asset
          in verifiedRecipes.map((recipe) => recipe.sourceAsset).toSet())
        asset: File('${project.path}/$asset').readAsStringSync(),
      'lib/recipes/recipe_tuning.dart': File(
        '${project.path}/lib/recipes/recipe_tuning.dart',
      ).readAsStringSync(),
    };

    final inputPaths = [
      ...sources.keys,
      'lib/ember_material_theme.dart',
      'lib/components/component_theme.dart',
      'lib/components/component_toggle.dart',
      'lib/recipes/recipe_export.dart',
      'lib/recipes/recipe_catalog.dart',
      'lib/content/motion_foundations_guides.dart',
      'test/recipes/export_consumer_test.dart',
    ];
    final inputHashes = await Process.run(
      'sha256sum',
      inputPaths,
      workingDirectory: project.path,
    );
    expect(inputHashes.exitCode, 0, reason: '${inputHashes.stderr}');
    await File('${evidence.path}/WEBSITE_SOURCE_SHA256SUMS.start')
        .writeAsString(inputHashes.stdout.toString());
    final inputDirectory = Directory('${evidence.path}/source-inputs');
    await inputDirectory.create(recursive: true);
    for (final entry in sources.entries) {
      final savedInput = File('${inputDirectory.path}/${entry.key}');
      await savedInput.parent.create(recursive: true);
      await savedInput.writeAsString(entry.value);
    }

    final dependencyPaths = <String>[];
    for (final packagePath in [
      'MotionNib/motion',
      'ComponetsNib/nib_components',
    ]) {
      dependencyPaths.add('$packagePath/pubspec.yaml');
      for (final folder in ['lib', 'shaders']) {
        final directory = Directory('${root.path}/$packagePath/$folder');
        if (!directory.existsSync()) continue;
        dependencyPaths.addAll(
          directory
              .listSync(recursive: true)
              .whereType<File>()
              .map((file) => file.path.substring(root.path.length + 1)),
        );
      }
    }
    dependencyPaths.sort();
    final dependencyHashes = await Process.run(
      'sha256sum',
      dependencyPaths,
      workingDirectory: root.path,
    );
    expect(dependencyHashes.exitCode, 0);
    await File('${evidence.path}/DEPENDENCY_SOURCE_SHA256SUMS.start')
        .writeAsString(dependencyHashes.stdout.toString());
    // Preserve the package implementation changed by this pass, alongside the
    // manifest and full library hashes identifying the dependency graph.
    for (final path in [
      'MotionNib/motion/lib/src/presets/nib_flip.dart',
      'MotionNib/motion/pubspec.yaml',
      'ComponetsNib/nib_components/pubspec.yaml',
    ]) {
      final target = File('${evidence.path}/dependency-inputs/$path');
      await target.parent.create(recursive: true);
      await File('${root.path}/$path').copy(target.path);
    }

    Future<ProcessResult> run(String name, List<String> arguments) async {
      final started = DateTime.now().toUtc();
      final result = await Process.run(
        flutter,
        arguments,
        workingDirectory: temp.path,
      );
      commands.add({
        'executable': flutter,
        'arguments': arguments,
        'startedUtc': started.toIso8601String(),
        'exitCode': result.exitCode,
      });
      await File('${evidence.path}/$name.log').writeAsString(
        'Command: $flutter ${arguments.join(' ')}\nExit: ${result.exitCode}\n${result.stdout}\n${result.stderr}',
      );
      return result;
    }

    try {
      await Directory('${temp.path}/lib').create(recursive: true);
      await Directory('${temp.path}/test').create(recursive: true);
      await File('${temp.path}/pubspec.yaml').writeAsString('''
name: nib_copied_consumer
publish_to: none
environment:
  sdk: ^3.13.3
dependencies:
  flutter:
    sdk: flutter
  nib_motion:
    path: ${root.path}/MotionNib/motion
  nib_components:
    path: ${root.path}/ComponetsNib/nib_components
dependency_overrides:
  nib_motion:
    path: ${root.path}/MotionNib/motion
dev_dependencies:
  flutter_test:
    sdk: flutter
flutter:
  uses-material-design: true
''');

      for (final recipe in verifiedRecipes) {
        var tuned = defaultRecipeTuning(recipe);
        for (final control in recipeControls(recipe)) {
          if (control.field != null) {
            tuned = tuned.withField(
              control.field!,
              control.minimum + (control.maximum - control.minimum) * .37,
            );
          }
        }
        if (recipeHasOption(recipe)) {
          tuned = tuned.copyWith(option: !tuned.option);
        }
        if (recipeHasEase(recipe)) {
          tuned = tuned.copyWith(ease: RecipeEase.linear);
        }
        if (recipeHasRelease(recipe)) {
          tuned = tuned.copyWith(release: RecipeDragRelease.inertia);
        }
        for (final (label, value, settings) in [
          ('default', recipe.initial, defaultRecipeTuning(recipe)),
          (
            'tuned',
            recipe.minimum + (recipe.maximum - recipe.minimum) * .37,
            tuned,
          ),
        ]) {
          final filename = '${recipe.id.replaceAll('-', '_')}_$label.dart';
          final copied = recipeRunnableExample(
            recipe,
            value,
            settings,
            sources[recipe.sourceAsset]!,
            File('lib/ember_material_theme.dart').readAsStringSync(),
            sources['lib/recipes/recipe_tuning.dart'],
            File('lib/components/component_theme.dart').readAsStringSync(),
            File('lib/components/component_toggle.dart').readAsStringSync(),
          );
          expect(
            copied,
            isNot(contains("import 'recipe_")),
            reason: '$filename must not depend on website helpers.',
          );
          expect(
            copied,
            isNot(contains("import 'spring_retarget_recipe.dart'")),
          );
          await File('${temp.path}/lib/$filename').writeAsString(copied);
          final normalized = recipeConfigurationFromUri(
            recipe,
            recipeShareUri(recipe, value, settings, Uri(path: recipe.route)),
          );
          cases.add(
            _ExportCase(
              filename,
              recipe,
              label,
              normalized.value,
              normalized.tuning,
            ),
          );
        }
      }
      final springGuide = motionFoundationsGuides.firstWhere(
        (article) => article.id == 'springs',
      );
      final springCode = springGuide.sections
          .firstWhere((section) => section.id == 'initial-target')
          .code!;
      await File('${temp.path}/lib/springs_lesson.dart')
          .writeAsString(springCode);
      await File('${temp.path}/test/copied_examples_test.dart')
          .writeAsString(_consumerTests(cases));
      await File('${temp.path}/README.md').writeAsString('''
# Copied recipe consumer

These files are the complete single-file output of recipeRunnableExample, plus the Springs guide's Initial state and target example. There are ${cases.length} recipe configurations and one guide app. Each file under lib is independently usable as main.dart; no website helper imports are needed.

This consumer uses the local candidate graph recorded in pubspec.yaml and pubspec.lock. It does not establish hosted-package availability.

Verified commands (run from this directory with the recorded Flutter SDK):

    flutter pub get --offline
    flutter analyze --no-pub
    flutter test --no-pub test/copied_examples_test.dart --reporter expanded

Tests launch each app, verify its bound recipe identity and exported settings, perform its primary interaction or local scroll, and dispose it. The Springs lesson additionally checks numeric movement and reversal. This is Flutter widget execution, not a browser or physical-device pass.
''');

      final sdk = await run('sdk', ['--version', '--machine']);
      expect(sdk.exitCode, 0);
      final pubGet = await run('pub-get', ['pub', 'get', '--offline']);
      expect(pubGet.exitCode, 0, reason: '${pubGet.stdout}\n${pubGet.stderr}');
      final config = jsonDecode(
        await File('${temp.path}/.dart_tool/package_config.json')
            .readAsString(),
      ) as Map<String, dynamic>;
      await File('${evidence.path}/resolved-nib-packages.json').writeAsString(
        const JsonEncoder.withIndent('  ').convert(
          (config['packages'] as List)
              .where((entry) => (entry['name'] as String).startsWith('nib_'))
              .toList(),
        ),
      );
      final analyze = await run('analyze', ['analyze', '--no-pub']);
      final execute = await run('execution', [
        'test',
        '--no-pub',
        'test/copied_examples_test.dart',
        '--reporter',
        'expanded',
      ]);
      expect(
        execute.exitCode,
        0,
        reason: '${execute.stdout}\n${execute.stderr}',
      );
      expect(
        analyze.exitCode,
        0,
        reason: '${analyze.stdout}\n${analyze.stderr}',
      );
    } finally {
      await File('${evidence.path}/commands.json')
          .writeAsString(const JsonEncoder.withIndent('  ').convert(commands));
      final dartFiles = Directory('${temp.path}/lib').existsSync()
          ? (Directory('${temp.path}/lib')
                .listSync()
                .whereType<File>()
                .map((file) => 'lib/${file.uri.pathSegments.last}')
                .toList()
              ..sort())
          : <String>[];
      final hashes = await Process.run(
        'sha256sum',
        dartFiles,
        workingDirectory: temp.path,
      );
      await File('${temp.path}/SOURCE_SHA256SUMS')
          .writeAsString(hashes.stdout.toString());
      await File('${evidence.path}/SOURCE_SHA256SUMS')
          .writeAsString(hashes.stdout.toString());
      final sourcePaths = inputPaths;
      final websiteHashes = await Process.run(
        'sha256sum',
        sourcePaths,
        workingDirectory: project.path,
      );
      await File('${evidence.path}/WEBSITE_SOURCE_SHA256SUMS')
          .writeAsString(websiteHashes.stdout.toString());
      final dependencyHashesAfter = await Process.run(
        'sha256sum',
        dependencyPaths,
        workingDirectory: root.path,
      );
      await File('${evidence.path}/DEPENDENCY_SOURCE_SHA256SUMS')
          .writeAsString(dependencyHashesAfter.stdout.toString());
      final archive = '${evidence.path}/copied-consumer.tar.gz';
      final archiveEntries =
          [
                'lib',
                'test',
                'pubspec.yaml',
                'pubspec.lock',
                'README.md',
                'SOURCE_SHA256SUMS',
              ]
              .where(
                (name) =>
                    FileSystemEntity.typeSync('${temp.path}/$name') !=
                    FileSystemEntityType.notFound,
              )
              .toList();
      final saved = await Process.run('tar', [
        '-czf',
        archive,
        '-C',
        temp.path,
        ...archiveEntries,
      ]);
      expect(saved.exitCode, 0, reason: '${saved.stderr}');
      final archiveHash = await Process.run('sha256sum', [
        'copied-consumer.tar.gz',
      ], workingDirectory: evidence.path);
      await File('${evidence.path}/ARCHIVE_SHA256SUMS')
          .writeAsString(archiveHash.stdout.toString());
      await File('${evidence.parent.path}/LATEST.txt').writeAsString(
        '${evidence.uri.pathSegments.where((part) => part.isNotEmpty).last}\n',
      );
      await temp.delete(recursive: true);
    }
  }, timeout: const Timeout(Duration(minutes: 8)));
}

class _ExportCase {
  const _ExportCase(
    this.filename,
    this.recipe,
    this.label,
    this.value,
    this.tuning,
  );
  final String filename;
  final RecipeDefinition recipe;
  final String label;
  final double value;
  final RecipeTuning tuning;
}

String _consumerTests(List<_ExportCase> cases) {
  final output = StringBuffer(
    "import 'package:flutter/material.dart';\nimport 'package:flutter_test/flutter_test.dart';\nimport 'package:nib_motion/nib_motion.dart';\n",
  );
  for (var index = 0; index < cases.length; index++) {
    output.writeln(
      "import '../lib/${cases[index].filename}' as example$index;",
    );
  }
  output.writeln(
    "import '../lib/springs_lesson.dart' as lesson;\nvoid main() {",
  );
  for (var index = 0; index < cases.length; index++) {
    final item = cases[index];
    final recipe = item.recipe;
    final alias = 'example$index';
    output.writeln(
      "testWidgets('${recipe.id} ${item.label}: copied app and controls', (tester) async {",
    );
    output.writeln(
      'tester.view.physicalSize = const Size(1100, 850); tester.view.devicePixelRatio = 1; addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);',
    );
    output.writeln(
      'await tester.pumpWidget(const SizedBox()); $alias.main(); await tester.pump(); await tester.pump(const Duration(milliseconds: 100));',
    );
    if (recipe.id == 'spring-retarget') {
      output.writeln(
        'final runtime = tester.widget<$alias.SpringRetargetRecipe>(find.byType($alias.SpringRetargetRecipe));',
      );
      output.writeln('expect(runtime.settings.distance, ${item.value});');
      for (final field in ['stiffness', 'damping', 'mass']) {
        final value = switch (field) {
          'stiffness' => item.tuning.stiffness,
          'damping' => item.tuning.damping,
          _ => item.tuning.mass,
        };
        output.writeln('expect(runtime.settings.$field, $value);');
      }
      output.writeln(
        "expect(find.text('Retarget the spring'), findsOneWidget); await tester.tap(find.text('Send right')); await tester.pump(const Duration(milliseconds: 100)); expect(find.text('Send left'), findsOneWidget); await tester.tap(find.text('Send left')); await tester.pump(const Duration(milliseconds: 100)); expect(find.text('Send right'), findsOneWidget);",
      );
    } else {
      output.writeln(
        'final runtime = tester.widget<$alias.RecipeRuntime>(find.byType($alias.RecipeRuntime));',
      );
      output.writeln(
        "expect(runtime.recipeId, '${recipe.id}'); expect(runtime.value, ${item.value});",
      );
      for (final field in RecipeField.values) {
        if (field == RecipeField.secondary && item.tuning.secondary == null) {
          output.writeln('expect(runtime.settings.secondary, isNull);');
        } else {
          output.writeln(
            'expect(runtime.settings.${field.name}, ${item.tuning.getField(field)});',
          );
        }
      }
      output.writeln(
        "expect(runtime.settings.option, ${item.tuning.option}); expect(runtime.settings.ease.name, '${item.tuning.ease.name}'); expect(runtime.settings.release.name, '${item.tuning.release.name}');",
      );
      output.writeln("expect(find.text('Recipe unavailable.'), findsNothing);");
      if (recipe.id != 'card-flip') {
        output.writeln("expect(find.text('Reset'), findsOneWidget);");
      }
      switch (recipe.id) {
        case 'card-flip':
          output.writeln(
            "expect(tester.widget<NibFlip>(find.byType(NibFlip)).isFlipped, isFalse); await tester.tap(find.byType(InkWell).first); await tester.pump(); await tester.pump(const Duration(milliseconds: 700)); expect(tester.widget<NibFlip>(find.byType(NibFlip)).isFlipped, isTrue);",
          );
        case 'hover-press':
          output.writeln(
            "await tester.tap(find.text('Press me · 0')); await tester.pump(); expect(find.text('Press me · 1'), findsOneWidget);",
          );
        case 'viewport-reveal':
        case 'local-parallax':
        case 'scroll-progress':
          output.writeln(
            'final scroll = tester.state<ScrollableState>(find.byType(Scrollable).first).position; final before = scroll.pixels; await tester.drag(find.byType(ListView).first, const Offset(0, -130)); await tester.pump(const Duration(milliseconds: 120)); expect(scroll.pixels, greaterThan(before));',
          );
        case 'accordion':
          output.writeln(
            "await tester.tap(find.text('What is Nib?')); await tester.pump(); await tester.pump(const Duration(milliseconds: 1600)); expect(find.text('Animation and native Flutter components.'), findsOneWidget);",
          );
        default:
          output.writeln(
            'await tester.tap(find.byType(FilledButton).first); await tester.pump(); await tester.pump(const Duration(milliseconds: 120));',
          );
          if (recipe.id == 'animated-counter') {
            output.writeln(
              "expect(find.text('${item.value.round()}'), findsOneWidget);",
            );
          }
          if (recipe.id == 'form-validation') {
            output.writeln(
              "expect(find.text('Use at least ${item.value.round()} characters'), findsOneWidget);",
            );
          }
      }
    }
    output.writeln(
      'expect(tester.takeException(), isNull); await tester.pumpWidget(const SizedBox()); await tester.pump(const Duration(seconds: 2)); expect(tester.takeException(), isNull); expect(tester.binding.transientCallbackCount, 0); });',
    );
  }
  output.writeln('''
  testWidgets('Springs guide complete example changes target and reverses', (tester) async {
    await tester.pumpWidget(const SizedBox()); lesson.main(); await tester.pump(); await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(lesson.SpringLesson), findsOneWidget);
    final square = find.descendant(of: find.byType(NibMotion), matching: find.byType(ColoredBox));
    final initial = tester.getCenter(square).dx;
    await tester.tap(find.text('Change target')); await tester.pump(); await tester.pump(const Duration(milliseconds: 100));
    final moving = tester.getCenter(square).dx;
    expect(moving, greaterThan(initial + 1));
    expect(tester.widget<NibMotion>(find.byType(NibMotion)).animate, isA<NibAnim>().having((value) => value.x, 'target x', 160));
    await tester.tap(find.text('Change target')); await tester.pump();
    expect(tester.widget<NibMotion>(find.byType(NibMotion)).animate, isA<NibAnim>().having((value) => value.x, 'reversed target x', 0));
    await tester.pump(const Duration(seconds: 3));
    expect(tester.getCenter(square).dx, closeTo(initial, 1));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox()); await tester.pump(const Duration(seconds: 1));
    expect(tester.binding.transientCallbackCount, 0);
  });
}
''');
  return output.toString();
}
