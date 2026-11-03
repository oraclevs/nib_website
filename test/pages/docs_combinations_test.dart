import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/content/motion_api_topics.dart';
import 'package:nib_ember_living/content/site_content.dart';
import 'package:nib_ember_living/docs/doc_example_catalog.dart';
import 'package:nib_ember_living/docs/examples/motion_text_example.dart';
import 'package:nib_ember_living/pages/doc_example_gallery.dart';
import 'package:nib_ember_living/pages/doc_example_panel.dart';

import '../support/file_asset_bundle.dart';

void main() {
  test('every exported Motion declaration has a reachable topic', () {
    final data = jsonDecode(
      File('assets/reference/public_api.json').readAsStringSync(),
    );
    final actual = (data['packages']['motion'] as List)
        .map((s) => s['name'])
        .toSet();
    expect(motionApiTopics.values.expand((names) => names).toSet(), actual);
    for (final topic in motionApiTopics.keys) {
      expect(
        SiteContent.articleById('motion', topic),
        isNotNull,
        reason: topic,
      );
      expect(
        SiteContent.learningPaths['motion']!.values.expand((ids) => ids),
        contains(topic),
      );
    }
    final text = SiteContent.articleById('motion', 'text-motion')!;
    for (final id in textMotionExamples.keys.where(
      (id) => id != 'typing-entrance',
    )) {
      expect(text.sections.map((s) => s.id), contains(id));
      expect(docSectionExamples('motion', 'text-motion', id), isNotEmpty);
    }
  });

  testWidgets(
    'switching same-file recipes updates live widget and copied launcher',
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
                child: DocExampleGallery(
                  examples: docExamplesFor('motion', 'text-motion'),
                  onNavigate: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final gradientChoice = find.widgetWithText(ChoiceChip, 'Gradient text');
      await tester.ensureVisible(gradientChoice);
      await tester.tap(gradientChoice);
      await tester.pumpAndSettle();
      expect(
        tester.widget<MotionTextExample>(find.byType(MotionTextExample)).kind,
        TextMotionKind.gradient,
      );
      await tester.ensureVisible(find.text('Source'));
      await tester.tap(find.text('Source'));
      await tester.pump();
      await tester.tap(find.text('Full example'));
      await tester.pump();
      final copy = find.text('Copy full example');
      await tester.ensureVisible(copy);
      await tester.tap(copy);
      await tester.pump();
      expect(
        copied,
        contains('child: MotionTextExample(kind: TextMotionKind.gradient)'),
      );
      expect(
        copied,
        isNot(
          contains('child: MotionTextExample(unit: NibTextUnit.character)'),
        ),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('section experiment opens matching example and closes cleanly', (
    tester,
  ) async {
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: FileAssetBundle(),
        child: MaterialApp(
          home: Scaffold(
            body: DocExampleButton(
              example: textMotionExamples['reveal']!,
              onNavigate: (_) {},
              reducedMotion: true,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Try Reveal from any edge'));
    await tester.pumpAndSettle();
    expect(find.byType(DocExamplePanel), findsOneWidget);
    expect(
      tester.widget<MotionTextExample>(find.byType(MotionTextExample)).kind,
      TextMotionKind.reveal,
    );
    await tester.tap(find.byTooltip('Close example'));
    await tester.pumpAndSettle();
    expect(find.byType(DocExamplePanel), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
