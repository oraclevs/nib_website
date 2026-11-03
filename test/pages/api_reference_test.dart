import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/pages/api_reference_panel.dart';
import 'package:nib_ember_living/pages/docs_page.dart';
import 'package:nib_ember_living/widgets/dart_code_view.dart';

import '../support/file_asset_bundle.dart';

void main() {
  Widget shell(String package) => DefaultAssetBundle(
    bundle: FileAssetBundle(),
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ApiReferencePanel(packageId: package),
        ),
      ),
    ),
  );

  testWidgets('reference reads real signatures and searches member names', (
    tester,
  ) async {
    await tester.pumpWidget(shell('motion'));
    await tester.pumpAndSettle();
    String signatures() => tester
        .widgetList<DartCodeView>(find.byType(DartCodeView))
        .map((view) => view.code)
        .join('\n');
    expect(signatures(), contains('this.layout = NibLayout.inherit'));
    expect(find.text('Constructors'), findsOneWidget);
    expect(find.text('Properties'), findsOneWidget);
    expect(find.text('Methods'), findsOneWidget);
    final readableComments = tester
        .widgetList<SelectableText>(find.byType(SelectableText))
        .map((text) => text.data ?? text.textSpan?.toPlainText() ?? '')
        .join('\n');
    expect(readableComments, contains('NibMotion owns a MotionValue'));
    expect(readableComments, isNot(contains('[MotionValue]')));
    await tester.enterText(find.byType(TextField), 'spatialFast');
    await tester.pumpAndSettle();
    expect(find.text('NibSpring'), findsWidgets);
    expect(
      signatures(),
      contains('static final NibSpringDescription spatialFast'),
    );
    await tester.enterText(find.byType(TextField), 'NibSpringDescription');
    await tester.pumpAndSettle();
    expect(find.text('NibSpringDescription'), findsWidgets);
    await tester.pumpAndSettle();
    expect(signatures(), contains('this.stiffness = 100.0'));
    expect(signatures(), contains('this.damping = 10.0'));
    await tester.enterText(find.byType(TextField), 'no-such-public-api');
    await tester.pumpAndSettle();
    expect(find.text('No matching APIs. Try a shorter name.'), findsOneWidget);
    expect(find.byType(DartCodeView), findsNothing);
  });

  testWidgets(
    'package change resets selection and reference fits narrow docs',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(shell('motion'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'spring');
      await tester.pumpWidget(shell('components'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '',
      );
      expect(find.text('NibButton'), findsWidgets);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: FileAssetBundle(),
          child: MaterialApp(
            home: Scaffold(
              body: DocsPage(
                packageId: 'genui',
                sectionId: 'api',
                onNavigate: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ApiReferencePanel), findsOneWidget);
      expect(find.text('An interaction, in three moments.'), findsNothing);
      expect(find.text('NibGeneratedSurface'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  test('reference honors public exports and excludes private members', () {
    final data = jsonDecode(
      File('assets/reference/public_api.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final packages = data['packages'] as Map<String, dynamic>;
    final motion = (packages['motion'] as List).cast<Map<String, dynamic>>();
    final names = motion.map((s) => s['name']).toSet();
    expect(names, containsAll(['NibMotion', 'NibSpring', 'NibKeyframe']));
    expect(names, isNot(contains('DragHandler')));
    expect(names, isNot(contains('NibTextUnitData')));
    for (final symbols in packages.values.cast<List>()) {
      for (final symbol in symbols.cast<Map<String, dynamic>>()) {
        expect((symbol['name'] as String).startsWith('_'), isFalse);
        expect(File('../${symbol['source']}').existsSync(), isTrue);
        for (final member in (symbol['members'] as List).cast<Map>()) {
          expect((member['name'] as String).startsWith('_'), isFalse);
          expect(member['signature'], isNotEmpty);
          expect(member['kind'], isNotEmpty);
        }
      }
    }
  });
}
