import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/export_complete_guide_examples.dart' as exporter;

void main() {
  test(
    'complete guide listings resolve against the actual public APIs',
    () async {
      final directory = Directory('.dart_tool/guide_snippet_check');
      if (directory.existsSync()) directory.deleteSync(recursive: true);
      addTearDown(() => directory.deleteSync(recursive: true));
      exporter.main([directory.path]);
      expect(directory.listSync().whereType<File>(), isNotEmpty);
      final result = await Process.run('dart', ['analyze', directory.path]);
      expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    },
  );
}
