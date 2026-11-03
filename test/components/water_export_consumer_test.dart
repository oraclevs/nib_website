import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/components/component_export.dart';
import 'package:nib_ember_living/components/guides/glass_component_guide.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('water exports compile and mount in a clean local consumer', () async {
    final website = Directory.current;
    final root = website.parent.path;
    final consumer = await Directory.systemTemp.createTemp('nib-water-export-');
    final evidence = Directory('$root/docs/water/evidence/consumer')
      ..createSync(recursive: true);
    Directory('${consumer.path}/lib').createSync();
    Directory('${consumer.path}/test').createSync();
    final commands = <Map<String, Object>>[];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMessageHandler('flutter/assets', (message) async {
      final key = utf8.decode(
        message!.buffer.asUint8List(
          message.offsetInBytes,
          message.lengthInBytes,
        ),
      );
      final file = File('${website.path}/$key');
      return file.existsSync()
          ? ByteData.sublistView(file.readAsBytesSync())
          : null;
    });
    addTearDown(() => messenger.setMockMessageHandler('flutter/assets', null));
    final imports = <String>[];
    final tests = <String>[];
    var index = 0;
    for (final scene in ['droplets', 'surface', 'component', 'bubbles']) {
      for (final depth in [false, true]) {
        final settings = glassComponentGuide.initial
            .change('waterScene', scene)
            .change('waterOptics', depth ? 'depth' : 'clear')
            .change('waterQuality', depth ? .75 : 1)
            .change('waterSampling', depth ? 'throttled' : 'live');
        final source = await componentRunnableSource(
          glassComponentGuide,
          settings,
        );
        expect(source, isNot(contains('package:nib_ember_living/')));
        File('${consumer.path}/lib/case_$index.dart').writeAsStringSync(source);
        File('${evidence.path}/case_$index.dart').writeAsStringSync(source);
        imports.add(
          "import 'package:water_export_check/case_$index.dart' as case$index;",
        );
        tests.add(
          '''testWidgets('$scene ${depth ? 'depth' : 'clear'}', (tester) async {
          await tester.pumpWidget(const case$index.ComponentExampleApp());
          await tester.pump();
          final glass = tester.widget<NibWaterGlass>(find.byType(NibWaterGlass));
          expect(glass.sampling.name, '${settings.waterSampling}');
          expect(glass.quality.scale, ${settings.waterQuality});
          expect(glass.material!.depth, ${depth ? 1 : 0});
          expect(glass.controller!.emitter != null, ${scene == 'bubbles'});
          for (var i=0; i<8; i++) { await tester.pump(const Duration(milliseconds:16)); }
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        });''',
        );
        index++;
      }
    }
    final short = componentShortSource(glassComponentGuide);
    File('${consumer.path}/lib/short.dart').writeAsStringSync(short);
    File('${evidence.path}/short.dart').writeAsStringSync(short);
    File('${consumer.path}/test/exports_test.dart').writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_components/nib_components.dart';
${imports.join('\n')}
void main() { ${tests.join('\n')} }
''');
    File('${consumer.path}/pubspec.yaml').writeAsStringSync('''
name: water_export_check
publish_to: none
environment:
  sdk: ^3.13.3
dependencies:
  flutter:
    sdk: flutter
  nib_components:
    path: $root/ComponetsNib/nib_components
  nib_motion:
    path: $root/MotionNib/motion
dependency_overrides:
  nib_motion:
    path: $root/MotionNib/motion
dev_dependencies:
  flutter_test:
    sdk: flutter
flutter:
  uses-material-design: true
''');
    for (final args in [
      ['pub', 'get', '--offline'],
      ['analyze'],
      ['test', '--reporter', 'expanded'],
    ]) {
      final result = await Process.run(
        'flutter',
        args,
        workingDirectory: consumer.path,
      );
      final name = args.first;
      File('${evidence.path}/$name.log')
          .writeAsStringSync('${result.stdout}\n${result.stderr}');
      commands.add({'args': args, 'exitCode': result.exitCode});
      File('${evidence.path}/result.json').writeAsStringSync(
        jsonEncode({'consumer': consumer.path, 'commands': commands}),
      );
      expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    }
  }, timeout: const Timeout(Duration(minutes: 5)));
}
