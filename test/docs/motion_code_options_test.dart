import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/docs/doc_example_catalog.dart';
import 'package:nib_ember_living/pages/doc_example_panel.dart';

import '../support/file_asset_bundle.dart';

void main() {
  testWidgets(
    'motion docs copy a minimal app by default and offer the full exercise',
    (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: FileAssetBundle(),
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: DocExamplePanel(
                  example: docExampleFor('motion', 'springs')!,
                  onNavigate: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.text('Copy minimal example'));
      await tester.pump();
      expect(copied, contains('void main()'));
      expect(copied, contains('NibSpringDescription'));
      expect(copied, isNot(contains('class MotionSpringExample')));
      final minimalLength = copied!.length;
      await tester.tap(find.text('Source'));
      await tester.pump();
      await tester.tap(find.text('Full example'));
      await tester.pump();
      await tester.ensureVisible(find.text('Copy full example'));
      await tester.tap(find.text('Copy full example'));
      await tester.pump();
      expect(copied, contains('class MotionSpringExample'));
      expect(copied!.length, greaterThan(minimalLength));
      expect(tester.takeException(), isNull);
    },
  );
}
