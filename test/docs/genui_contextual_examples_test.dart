import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/content/ecosystem_api_topics.dart';
import 'package:nib_ember_living/content/site_content.dart';
import 'package:nib_ember_living/docs/examples/genui_fixture_example.dart';

void main() {
  test(
    'ecosystem topic maps cover exact public names and real guide sources',
    () {
      final data = jsonDecode(
        File('assets/reference/public_api.json').readAsStringSync(),
      ) as Map;
      final packages = data['packages'] as Map;
      for (final entry in {
        'components': componentsApiTopics,
        'genui': genuiApiTopics,
      }.entries) {
        final expected = (packages[entry.key] as List)
            .map((symbol) => symbol['name'])
            .toSet();
        final actual = entry.value.values.expand((names) => names).toSet();
        expect(actual, expected, reason: entry.key);
        for (final topic in entry.value.keys) {
          expect(SiteContent.articleById(entry.key, topic), isNotNull);
          final sources = ecosystemGuideSources['${entry.key}/$topic'];
          expect(sources, isNotEmpty);
          for (final source in sources!) {
            expect(File('../$source').existsSync(), isTrue, reason: source);
          }
        }
      }
    },
  );

  Future<void> mount(WidgetTester tester, GenUiLesson lesson) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GenUiFixtureExample(lesson: lesson),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'replay still applies each frame and restarts its bounded runtime',
    (tester) async {
      await mount(tester, GenUiLesson.replay);
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('Next frame'));
        await tester.pumpAndSettle();
      }
      expect(find.text('Native generated UI'), findsOneWidget);
      await tester.tap(find.text('Replay fixture'));
      await tester.pumpAndSettle();
      expect(find.text('Frame 0 / 3'), findsOneWidget);
      expect(find.text('Native generated UI'), findsNothing);
    },
  );

  testWidgets(
    'rollback exercise rejects malformed text and retains committed UI',
    (tester) async {
      await mount(tester, GenUiLesson.rollback);
      await tester.tap(find.text('Send invalid Text update'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Rejected '), findsOneWidget);
      expect(find.text('Native generated UI'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'editing exercise reflects local input and applies a real remote update',
    (tester) async {
      await mount(tester, GenUiLesson.localEditing);
      await tester.enterText(find.byType(TextField), 'Lin');
      await tester.pumpAndSettle();
      expect(find.text('Stored /name: Lin'), findsOneWidget);
      await tester.tap(find.text('Write Ada locally'));
      await tester.pumpAndSettle();
      expect(find.text('Stored /name: Ada'), findsOneWidget);
      await tester.tap(find.text('Apply remote name'));
      await tester.pumpAndSettle();
      expect(find.text('Stored /name: Grace'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Grace',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'action exercise checks inputs, changed permission, and stale IDs',
    (tester) async {
      await mount(tester, GenUiLesson.actions);
      await tester.tap(find.text('Dispatch current button'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a name first'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Ada');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dispatch current button'));
      await tester.pumpAndSettle();
      expect(find.text('Hello, Ada'), findsOneWidget);
      await tester.tap(find.text('Allow local greeting'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dispatch current button'));
      await tester.pumpAndSettle();
      expect(find.text('Host permission denied'), findsOneWidget);
      await tester.tap(find.text('Try stale component'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Action rejected:'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );
}
