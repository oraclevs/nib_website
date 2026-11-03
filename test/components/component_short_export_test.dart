import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/components/component_catalog.dart';
import 'package:nib_ember_living/components/component_doc_minimal_examples.dart';
import 'package:nib_ember_living/docs/doc_example_catalog.dart';
import 'package:nib_ember_living/docs/motion_minimal_examples.dart';
import 'package:nib_ember_living/components/component_export.dart';

void main() {
  test(
    'all 33 guides and 3 docs examples analyze as standalone main.dart files',
    () async {
      final project = await Directory.systemTemp.createTemp(
        'nib-short-examples-',
      );
      addTearDown(() => project.delete(recursive: true));
      final root = Directory.current.parent.absolute.path;
      final flutter =
          Platform.environment['FLUTTER_BIN'] ??
          '/home/occ/DevTools/flutter/bin/flutter';
      await Directory('${project.path}/lib').create();
      await File('${project.path}/pubspec.yaml').writeAsString('''
name: nib_short_examples
publish_to: none
environment:
  sdk: ^3.13.3
dependencies:
  flutter:
    sdk: flutter
  nib_motion:
    path: $root/MotionNib/motion
  nib_components:
    path: $root/ComponetsNib/nib_components
dependency_overrides:
  nib_motion:
    path: $root/MotionNib/motion
flutter:
  uses-material-design: true
''');
      for (final guide in componentGuides) {
        final source = componentShortSource(guide);
        expect(source, contains('void main()'), reason: guide.id);
        expect(
          source,
          isNot(contains('package:nib_ember_living/')),
          reason: guide.id,
        );
        await File('${project.path}/lib/${guide.id.replaceAll('-', '_')}.dart')
            .writeAsString(source);
      }
      for (final entry in {
        'getting-started': ['NibButton'],
        'forms': ['NibInput', 'NibValidators', 'Form('],
        'theming': ['NibTheme', 'NibButton'],
      }.entries) {
        final article = entry.key;
        final example = docExampleFor('components', article)!;
        final source = minimalComponentDocExample(example);
        expect(source, isNotNull, reason: article);
        expect(source, contains('void main()'), reason: article);
        expect(
          minimalDocExample(example),
          source,
          reason: '$article docs wiring',
        );
        for (final symbol in entry.value) {
          expect(source, contains(symbol), reason: '$article $symbol');
        }
        await File('${project.path}/lib/docs_$article.dart')
            .writeAsString(source!);
      }
      final pub = await Process.run(flutter, [
        'pub',
        'get',
        '--offline',
      ], workingDirectory: project.path);
      expect(pub.exitCode, 0, reason: '${pub.stdout}\n${pub.stderr}');
      final analysis = await Process.run(flutter, [
        'analyze',
        '--no-pub',
        'lib',
      ], workingDirectory: project.path);
      expect(
        analysis.exitCode,
        0,
        reason: '${analysis.stdout}\n${analysis.stderr}',
      );
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
