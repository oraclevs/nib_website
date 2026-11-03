import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/home.dart';

void main() {
  testWidgets('homepage package cards open their own package paths', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final paths = <String>[];
    await tester.pumpWidget(
      MaterialApp(home: EmberHome(onNavigatePath: paths.add)),
    );
    await tester.pump();
    for (final entry in <(String, String)>[
      ('Explore motion', '/packages/motion'),
      ('Browse components', '/packages/components'),
      ('Discover generative UI', '/packages/genui'),
    ]) {
      await tester.ensureVisible(find.text(entry.$1));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text(entry.$1));
      expect(paths.last, entry.$2);
    }
  });
}
