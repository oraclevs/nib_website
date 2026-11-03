import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/components/component_catalog.dart';
import 'package:nib_ember_living/components/component_export.dart';
import 'package:nib_ember_living/components/component_model.dart';
import 'package:nib_ember_living/components/component_settings.dart';

import 'bottom_navigation_export_contracts.dart';
import 'overlay_export_contracts.dart';
import 'layout_export_contracts.dart';
import 'selection_export_contracts.dart';

const _escapingText = r'''$5 \ path "quoted" 'single'
${literal} ✓''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every configured component export runs against isolated candidate sources', () async {
    final project = Directory.current.absolute;
    final root = project.parent;
    final temp = await Directory.systemTemp.createTemp('nib-component-export-');
    final stamp = DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
    final evidence = Directory(
      '${project.path}/docs/evidence/2026-10-28-components/export-$stamp',
    );
    await evidence.create(recursive: true);
    final flutter =
        Platform.environment['FLUTTER_BIN'] ??
        (Platform.environment['FLUTTER_ROOT'] == null
            ? 'flutter'
            : '${Platform.environment['FLUTTER_ROOT']}/bin/flutter');
    final commands = <Map<String, Object?>>[];
    final cases = <_ComponentExportCase>[];
    final inputPaths = <String>{
      'lib/components/component_catalog.dart',
      'lib/components/component_model.dart',
      'lib/components/component_export.dart',
      'lib/components/component_settings.dart',
      'lib/components/component_theme.dart',
      'lib/components/component_toggle.dart',
      'lib/ember_material_theme.dart',
      'test/components/component_export_consumer_test.dart',
      'test/components/bottom_navigation_export_contracts.dart',
      'test/components/overlay_export_contracts.dart',
      'test/components/layout_export_contracts.dart',
      'test/components/selection_export_contracts.dart',
      ...componentGuides.map((guide) => guide.demoFile),
      ...Directory('${project.path}/lib/components/guides')
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .map((file) => file.path.substring(project.path.length + 1)),
    }.toList()..sort();
    final inputs = {
      for (final path in inputPaths)
        path: File('${project.path}/$path').readAsStringSync(),
    };
    final dependencyPaths = <String>[];
    const packages = {
      'nib_motion': 'MotionNib/motion',
      'nib_components': 'ComponetsNib/nib_components',
    };
    for (final path in packages.values) {
      dependencyPaths.add('$path/pubspec.yaml');
      for (final folder in ['lib', 'shaders']) {
        final directory = Directory('${root.path}/$path/$folder');
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
    Future<String> hashes(List<String> paths, String cwd) async {
      final result = await Process.run(
        'sha256sum',
        paths,
        workingDirectory: cwd,
      );
      expect(result.exitCode, 0, reason: result.stderr.toString());
      return result.stdout.toString();
    }

    final websiteStart = await hashes(inputPaths, project.path);
    final dependencyStart = await hashes(dependencyPaths, root.path);
    await File('${evidence.path}/WEBSITE_SOURCE_SHA256SUMS.start')
        .writeAsString(websiteStart);
    await File('${evidence.path}/DEPENDENCY_SOURCE_SHA256SUMS.start')
        .writeAsString(dependencyStart);
    final identities = <String, Object?>{};
    for (final entry in packages.entries) {
      final path = '${root.path}/${entry.value}';
      final head = await Process.run('git', [
        'rev-parse',
        'HEAD',
      ], workingDirectory: path);
      final status = await Process.run('git', [
        'status',
        '--short',
      ], workingDirectory: path);
      identities[entry.key] = {
        'sourcePath': path,
        'head': head.stdout.toString().trim(),
        'workingTreeStatus': status.stdout.toString(),
        'sourceIdentity':
            'HEAD plus files in DEPENDENCY_SOURCE_SHA256SUMS.start',
        'consumerPath': 'candidate_packages/${entry.key}',
      };
    }
    await File('${evidence.path}/source-revisions.json')
        .writeAsString(const JsonEncoder.withIndent('  ').convert(identities));
    for (final entry in inputs.entries) {
      final saved = File('${evidence.path}/source-inputs/${entry.key}');
      await saved.parent.create(recursive: true);
      await saved.writeAsString(entry.value);
    }

    // Generate from exactly the captured source assets, avoiding an old
    // compiled test asset bundle while another agent works on the website.
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final path in inputs.keys) {
      rootBundle.evict(path);
    }
    messenger.setMockMessageHandler('flutter/assets', (message) async {
      if (message == null) return null;
      final key = utf8.decode(
        message.buffer.asUint8List(
          message.offsetInBytes,
          message.lengthInBytes,
        ),
      );
      final source = inputs[key];
      return source == null
          ? null
          : ByteData.sublistView(Uint8List.fromList(utf8.encode(source)));
    });
    Future<ProcessResult> run(String name, List<String> args) async {
      final started = DateTime.now().toUtc();
      final result = await Process.run(
        flutter,
        args,
        workingDirectory: temp.path,
      );
      commands.add({
        'executable': flutter,
        'arguments': args,
        'startedUtc': started.toIso8601String(),
        'exitCode': result.exitCode,
      });
      await File('${evidence.path}/$name.log').writeAsString(
        'Command: $flutter ${args.join(' ')}\nExit: ${result.exitCode}\n'
        '${result.stdout}\n${result.stderr}',
      );
      return result;
    }

    try {
      await Directory('${temp.path}/lib').create(recursive: true);
      await Directory('${temp.path}/test').create(recursive: true);
      for (final entry in packages.entries) {
        for (final path in dependencyPaths.where(
          (p) => p.startsWith('${entry.value}/'),
        )) {
          final relative = path.substring(entry.value.length + 1);
          final target = File(
            '${temp.path}/candidate_packages/${entry.key}/$relative',
          );
          await target.parent.create(recursive: true);
          await File('${root.path}/$path').copy(target.path);
        }
      }
      final snapshotPaths = [
        for (final entry in packages.entries)
          for (final path in dependencyPaths.where(
            (p) => p.startsWith('${entry.value}/'),
          ))
            'candidate_packages/${entry.key}/${path.substring(entry.value.length + 1)}',
      ]..sort();
      final snapshotHashes = await hashes(snapshotPaths, temp.path);
      await File('${evidence.path}/SNAPSHOT_SHA256SUMS')
          .writeAsString(snapshotHashes);
      final sourceDigests =
          dependencyStart
              .trim()
              .split('\n')
              .map((line) => line.split('  ').first)
              .toList()
            ..sort();
      final snapshotDigests =
          snapshotHashes
              .trim()
              .split('\n')
              .map((line) => line.split('  ').first)
              .toList()
            ..sort();
      expect(
        snapshotDigests,
        sourceDigests,
        reason: 'Snapshot must match the source captured before copying.',
      );

      await File('${temp.path}/pubspec.yaml').writeAsString('''
name: nib_component_export_consumer
publish_to: none
environment:
  sdk: ^3.13.3
dependencies:
  flutter:
    sdk: flutter
  nib_motion:
    path: candidate_packages/nib_motion
  nib_components:
    path: candidate_packages/nib_components
dependency_overrides:
  nib_motion:
    path: candidate_packages/nib_motion
dev_dependencies:
  flutter_test:
    sdk: flutter
flutter:
  uses-material-design: true
''');
      // Analyze only consumer code. Package snapshots keep their original
      // manifests; their own development tests/lints are separate gates.
      await File('${temp.path}/analysis_options.yaml').writeAsString('''
analyzer:
  exclude:
    - candidate_packages/**
''');
      for (final guide in componentGuides) {
        var tuned = guide.initial;
        for (final control in guide.controls) {
          final value = switch (control.kind) {
            ComponentControlKind.toggle =>
              !(tuned.values[control.key]! as bool),
            ComponentControlKind.number =>
              control.minimum + (control.maximum - control.minimum) * .37,
            ComponentControlKind.choice => control.choices.last,
            ComponentControlKind.text => _escapingText,
          };
          tuned = tuned.change(control.key, value);
        }
        for (final entry in [('default', guide.initial), ('tuned', tuned)]) {
          final filename = '${guide.id.replaceAll('-', '_')}_${entry.$1}.dart';
          final source = await componentRunnableSource(guide, entry.$2);
          expect(source, isNot(contains('package:nib_ember_living/')));
          final imports = RegExp(
            r'''^import\s+['"]([^'"]+)['"]''',
            multiLine: true,
          );
          for (final import in imports.allMatches(source)) {
            expect(
              import[1],
              anyOf(startsWith('dart:'), startsWith('package:')),
              reason:
                  '$filename must not import website-only relative helpers.',
            );
            expect(
              import[1],
              isNot(contains('/src/')),
              reason: '$filename must use public package APIs.',
            );
          }
          await File('${temp.path}/lib/$filename').writeAsString(source);
          cases.add(_ComponentExportCase(filename, guide, entry.$1, entry.$2));
        }
      }
      await File('${temp.path}/test/copied_components_test.dart')
          .writeAsString(_consumerTests(cases));
      await File('${temp.path}/README.md').writeAsString('''
# Copied component consumer

Each lib file is a complete app produced by componentRunnableSource. There are ${cases.length} configurations across ${componentGuides.length} guides. Candidate packages are immutable source snapshots captured for this run, with original manifests and a local Motion override. No website dependency or private package import is required.

Run with the recorded SDK:

    flutter pub get --offline
    flutter analyze --no-pub
    flutter test --no-pub test/copied_components_test.dart --reporter expanded

The widget tests check default and tuned values, escaped text, inherited Ember tokens, actual component interaction and disposal. These tests do not validate hosted availability, browser rendering, physical touch, GPU optics or screen readers. Source-hash files identify the exact candidate, including uncommitted repairs.
''');
      await File('${evidence.path}/cases.json').writeAsString(
        const JsonEncoder.withIndent('  ').convert([
          for (final item in cases)
            {
              'guide': item.guide.id,
              'configuration': item.label,
              'filename': item.filename,
              'settings': item.settings.values,
              'interactionContract': item.guide.id,
            },
        ]),
      );
      final sdk = await run('sdk', ['--version', '--machine']);
      expect(sdk.exitCode, 0);
      final pubGet = await run('pub-get', ['pub', 'get', '--offline']);
      expect(pubGet.exitCode, 0, reason: '${pubGet.stdout}\n${pubGet.stderr}');
      final configFile = File('${temp.path}/.dart_tool/package_config.json');
      final config =
          jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
      final nib = (config['packages'] as List)
          .cast<Map<String, dynamic>>()
          .where(
            (entry) =>
                (entry['name'] as String).startsWith('nib_') &&
                entry['name'] != 'nib_component_export_consumer',
          )
          .toList();
      expect(nib.map((entry) => entry['name']).toSet(), packages.keys.toSet());
      for (final entry in nib) {
        final actual = Directory.fromUri(
          configFile.uri.resolve(entry['rootUri'] as String),
        ).resolveSymbolicLinksSync();
        final expected = Directory(
          '${temp.path}/candidate_packages/${entry['name']}',
        ).resolveSymbolicLinksSync();
        expect(
          actual,
          expected,
          reason: 'The consumer must resolve the saved candidate, not an old hosted version.',
        );
        entry['verifiedResolvedPath'] = actual;
      }
      await File('${evidence.path}/resolved-nib-packages.json')
          .writeAsString(const JsonEncoder.withIndent('  ').convert(nib));
      final analyze = await run('analyze', ['analyze', '--no-pub']);
      final execute = await run('execution', [
        'test',
        '--no-pub',
        'test/copied_components_test.dart',
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
      messenger.setMockMessageHandler('flutter/assets', null);
      for (final path in inputs.keys) {
        rootBundle.evict(path);
      }
      await File('${evidence.path}/commands.json')
          .writeAsString(const JsonEncoder.withIndent('  ').convert(commands));
      final websiteEnd = await hashes(inputPaths, project.path);
      final dependencyEnd = await hashes(dependencyPaths, root.path);
      await File('${evidence.path}/WEBSITE_SOURCE_SHA256SUMS.end')
          .writeAsString(websiteEnd);
      await File('${evidence.path}/DEPENDENCY_SOURCE_SHA256SUMS.end')
          .writeAsString(dependencyEnd);
      await File('${evidence.path}/source-drift.json').writeAsString(
        jsonEncode({
          'websiteChangedDuringRun': websiteStart != websiteEnd,
          'dependenciesChangedDuringRun': dependencyStart != dependencyEnd,
          'meaning': 'Results certify saved source snapshots only. Rerun after later edits before certifying the current workspace.',
        }),
      );
      final entries =
          [
                'lib',
                'test',
                'candidate_packages',
                'pubspec.yaml',
                'pubspec.lock',
                'analysis_options.yaml',
                'README.md',
              ]
              .where(
                (path) =>
                    FileSystemEntity.typeSync('${temp.path}/$path') !=
                    FileSystemEntityType.notFound,
              )
              .toList();
      final exported =
          Directory('${temp.path}/lib')
              .listSync()
              .whereType<File>()
              .map((file) => 'lib/${file.uri.pathSegments.last}')
              .toList()
            ..sort();
      if (exported.isNotEmpty) {
        final sourceHashes = await hashes(exported, temp.path);
        await File('${temp.path}/SOURCE_SHA256SUMS')
            .writeAsString(sourceHashes);
        await File('${evidence.path}/SOURCE_SHA256SUMS')
            .writeAsString(sourceHashes);
        entries.add('SOURCE_SHA256SUMS');
      }
      final archive = await Process.run('tar', [
        '-czf',
        '${evidence.path}/copied-consumer.tar.gz',
        '-C',
        temp.path,
        ...entries,
      ]);
      expect(archive.exitCode, 0, reason: archive.stderr.toString());
      await File(
        '${evidence.path}/ARCHIVE_SHA256SUMS',
      ).writeAsString(await hashes(['copied-consumer.tar.gz'], evidence.path));
      await File('${evidence.parent.path}/export-LATEST.txt').writeAsString(
        '${evidence.uri.pathSegments.where((part) => part.isNotEmpty).last}\n',
      );
      await temp.delete(recursive: true);
    }
  }, timeout: const Timeout(Duration(minutes: 8)));
}

class _ComponentExportCase {
  const _ComponentExportCase(
    this.filename,
    this.guide,
    this.label,
    this.settings,
  );
  final String filename, label;
  final ComponentGuide guide;
  final ComponentSettings settings;
}

String _consumerTests(List<_ComponentExportCase> cases) {
  final out = StringBuffer('''
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_components/nib_components.dart';
import 'package:nib_motion/nib_motion.dart' show NibGlass, NibNavBar;
''');
  for (var i = 0; i < cases.length; i++) {
    out.writeln("import '../lib/${cases[i].filename}' as example$i;");
  }
  out.writeln(
    'void main() { WidgetController.hitTestWarningShouldBeFatal = true;',
  );
  for (var i = 0; i < cases.length; i++) {
    final item = cases[i];
    final alias = 'example$i';
    final type = '$alias.${item.guide.demoClass}';
    final expected = base64Encode(
      utf8.encode(jsonEncode(item.settings.values)),
    );
    out.writeln(
      "testWidgets('${item.guide.id} ${item.label}: copied configuration and interaction', (tester) async {",
    );
    out.writeln('''
tester.view.physicalSize = const Size(1100, 850);
tester.view.devicePixelRatio = 1;
addTearDown(tester.view.resetPhysicalSize);
addTearDown(tester.view.resetDevicePixelRatio);
await tester.pumpWidget(const SizedBox());
$alias.main();
await tester.pump();
await tester.pump(const Duration(milliseconds: 150));
final expected = jsonDecode(utf8.decode(base64Decode('$expected'))) as Map<String, dynamic>;
$type runtime() => tester.widget<$type>(find.byType($type));
expect(runtime().settings.values, expected);
final tokens = NibTheme.of(tester.element(find.byType($type)));
expect(tokens.background, const Color(0xFF111210));
expect(tokens.foreground, const Color(0xFFF4E8C8));
expect(tokens.primary.toARGB32(), expected['accent']);
''');
    switch (item.guide.id) {
      case 'input':
        out.writeln('''
final multiline = expected['variant'] == 'multiline';
expect(find.byType(multiline ? NibTextarea : NibInput), findsOneWidget);
var field = tester.widget<TextField>(find.byType(TextField));
expect(field.controller!.text, expected['text']);
expect(field.enabled, !(expected['disabled'] as bool));
if (expected['disabled'] == true) {
  expect(tester.widget<NibButton>(find.widgetWithText(NibButton, 'Validate')).onPressed, isNull);
  runtime().onChanged(runtime().settings.change('disabled', false));
  await tester.pump();
}
await tester.tap(find.text('Clear field'));
await tester.pump(const Duration(milliseconds: 250));
expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);
expect(runtime().settings.text, isEmpty);
await tester.tap(find.text('Validate'));
await tester.pump(const Duration(milliseconds: 250));
expect(find.text(multiline ? 'Enter a message.' : 'Enter a name.'), findsOneWidget);
expect(find.text('Validation failed'), findsOneWidget);
await tester.enterText(find.byType(TextField), 'Ada writes');
await tester.pump(const Duration(milliseconds: 250));
await tester.tap(find.text('Validate'));
await tester.pump(const Duration(milliseconds: 250));
expect(find.text('Validation passed'), findsOneWidget);
expect(runtime().settings.text, 'Ada writes');
final controller = tester.widget<TextField>(find.byType(TextField)).controller!;
controller.selection = const TextSelection(baseOffset: 1, extentOffset: 3);
runtime().onChanged(runtime().settings.change('radius', 11.0));
await tester.pump();
field = tester.widget<TextField>(find.byType(TextField));
expect(identical(field.controller, controller), isTrue);
expect(field.controller!.selection, const TextSelection(baseOffset: 1, extentOffset: 3));
''');
      case 'navigation-menu':
        out.writeln('''
NibNavigationMenu menu() => tester.widget<NibNavigationMenu>(find.byType(NibNavigationMenu));
expect(menu().orientation, expected['vertical'] == true ? NibNavMenuOrientation.vertical : NibNavMenuOrientation.horizontal);
expect(menu().allowMultipleOpen, expected['multiple']);
expect(menu().animated, expected['animated']);
expect(menu().items.first.label, expected['text']);
expect(menu().items[1].children.last.disabled, expected['disabled']);
await tester.tap(find.text('Settings'));
await tester.pump(const Duration(milliseconds: 250));
expect(menu().activeItemId, 'settings');
expect(find.text('Workspace settings'), findsOneWidget);
expect(find.text('Selected destination: settings'), findsOneWidget);
expect(find.text('onItemSelected: settings'), findsOneWidget);
await tester.tap(find.text('Reports').first);
await tester.pump(const Duration(milliseconds: 400));
expect(find.text('Weekly'), findsOneWidget);
await tester.tap(find.text('Weekly'));
await tester.pump(const Duration(milliseconds: 400));
expect(menu().activeItemId, 'weekly');
expect(find.text('This week'), findsOneWidget);
expect(find.text('Selected destination: weekly'), findsOneWidget);
if (expected['vertical'] == true) {
  final before = menu().controller!.openIds.contains('reports');
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Toggle Reports from controller'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Toggle Reports from controller'));
  await tester.pump(const Duration(milliseconds: 400));
  expect(menu().controller!.openIds.contains('reports'), !before);
}
''');
      case 'liquid-glass':
        out.writeln('''
if (expected['waterMaterial'] == 'water') {
  final water = tester.widget<NibWaterGlass>(find.byType(NibWaterGlass));
  expect(water.sampling.name, expected['waterSampling']);
  expect(water.quality.scale, expected['waterQuality']);
  await tester.ensureVisible(find.byKey(const ValueKey('water-disturb')));
  await tester.pump();
  await tester.tap(find.byKey(const ValueKey('water-disturb')));
  await tester.pump(const Duration(milliseconds: 16));
  expect(water.controller!.impulses, isNotEmpty);
  await tester.ensureVisible(find.byKey(const ValueKey('water-reset')));
  await tester.pump();
  await tester.tap(find.byKey(const ValueKey('water-reset')));
  await tester.pump();
  expect(water.controller!.impulses, isEmpty);
} else {
NibLiquidGlass glass() => tester.widget<NibLiquidGlass>(find.byKey(const ValueKey('glass-demo-surface')));
expect(glass().blurSigma, expected['blurSigma']);
expect(glass().thickness, expected['thickness']);
expect(glass().refractiveIndex, expected['refractiveIndex']);
expect(glass().chromaticAberration, expected['chromaticAberration']);
expect(glass().saturation, expected['saturation']);
expect(glass().highlight, expected['highlight']);
expect(glass().animated, expected['animated']);
expect(glass().interactive, expected['interactive']);
expect(glass().showBorder, expected['showBorder']);
expect(glass().borderRadius!.topLeft.x, expected['variant'] == 'capsule' ? 94 : expected['radius']);
expect(find.text(expected['text'] as String), findsOneWidget);
if (expected['interactive'] == true) {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  final rect = tester.getRect(find.byKey(const ValueKey('glass-demo-surface')));
  await mouse.moveTo(rect.center + const Offset(60, 0));
  await tester.pump();
  final engine = tester.widget<NibGlass>(find.byType(NibGlass));
  expect(engine.lightDirection.dx, greaterThan(.9));
  await mouse.removePointer();
  await tester.pump();
}
await tester.tap(find.byKey(const ValueKey('glass-pin-note')));
await tester.pump(const Duration(milliseconds: 200));
expect(find.text('Pinned'), findsOneWidget);
expect(find.text('Note pinned'), findsOneWidget);
final oldBackdrop = runtime().settings.backdrop;
await tester.tap(find.byKey(const ValueKey('glass-change-backdrop')));
await tester.pump();
expect(runtime().settings.backdrop, oldBackdrop == 'grid' ? 'content' : 'grid');
expect(find.byKey(ValueKey('glass-backdrop-\${runtime().settings.backdrop}')), findsOneWidget);
if (!ui.ImageFilter.isShaderFilterSupported) {
  expect(find.textContaining('Frosted fallback:'), findsOneWidget);
}
}
''');
      default:
        out.writeln(
          overlayExportContract(item.guide.id) ??
              layoutExportContract(item.guide.id) ??
              selectionExportContract(item.guide.id) ??
              bottomNavigationExportContract(item.guide.id) ??
              "fail('Add a meaningful copied-source interaction contract for ${item.guide.id}; mount-only coverage is insufficient.');",
        );
    }
    out.writeln('''
expect(tester.takeException(), isNull);
await tester.pumpWidget(const SizedBox());
await tester.pump(const Duration(seconds: 2));
expect(tester.takeException(), isNull);
expect(tester.binding.transientCallbackCount, 0);
});
''');
  }
  out.writeln('}');
  return out.toString();
}
