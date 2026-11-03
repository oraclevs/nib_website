import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/content/site_content.dart';
import 'package:nib_ember_living/components/component_catalog.dart';
import 'package:nib_ember_living/components/component_pages.dart';
import 'package:nib_ember_living/components/component_support_guides.dart';
import 'package:nib_ember_living/recipes/recipe_catalog.dart';
import 'package:nib_ember_living/docs/doc_example_catalog.dart';
import 'package:nib_ember_living/pages/doc_example_panel.dart';
import 'package:nib_ember_living/pages/docs_page.dart';
import 'package:nib_ember_living/site_shell.dart';
import 'package:nib_ember_living/widgets/dart_code_view.dart';

import '../support/file_asset_bundle.dart';

void main() {
  final bundle = FileAssetBundle();
  testWidgets('live examples fit the real narrow documentation shell', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final seen = <String>{};
    final seenComponents = <String>{};
    final seenSupport = <String>{};
    for (final article in SiteContent.articles) {
      final component = article.packageId == 'components'
          ? componentById(article.id)
          : null;
      final example = docExampleFor(article.packageId, article.id);
      if (component != null) {
        expect(seenComponents.add(component.id), isTrue);
      } else if (example != null) {
        if (!seen.add(example.identity)) continue;
      } else if (article.packageId == 'motion' &&
          {'introduction', 'installation'}.contains(article.id)) {
        expect(docExamplesFor('motion', article.id), isEmpty);
      } else {
        expect(article.packageId, 'components', reason: article.route);
        expect(
          componentSupportArticles.map((support) => support.id),
          contains(article.id),
          reason: article.route,
        );
        expect(seenSupport.add(article.id), isTrue);
      }
      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: bundle,
          child: MaterialApp(
            home: SiteShell(
              key: ValueKey(article.route),
              path: article.route,
              onNavigate: (_) {},
              child: DocsPage(
                packageId: article.packageId,
                sectionId: article.id,
                onNavigate: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));
      final outer = tester.widget<SingleChildScrollView>(
        find.byKey(const ValueKey('docs-article-scroll')),
      );
      expect(outer.controller!.positions.length, 1, reason: article.route);
      final articleBounds = tester.getRect(
        find.byKey(const ValueKey('docs-article-scroll')),
      );
      expect(
        articleBounds.left,
        greaterThanOrEqualTo(0),
        reason: article.route,
      );
      expect(
        articleBounds.right,
        lessThanOrEqualTo(360),
        reason: article.route,
      );
      if (component != null) {
        final embedded = tester.widget<ComponentGuidePage>(
          find.byType(ComponentGuidePage),
        );
        expect(embedded.embedded, isTrue);
        expect(embedded.guide.id, component.id);
      }
      expect(tester.takeException(), isNull, reason: article.route);
    }
    expect(seen, hasLength(31));
    expect(seenComponents, componentGuides.map((guide) => guide.id).toSet());
    expect(seenSupport, {
      'state-and-controllers',
      'motion-opt-in',
      'overlays',
      'validation',
    });
  });

  testWidgets('source and copy share the live example identity', (
    tester,
  ) async {
    final example = docExampleFor('motion', 'keyframes')!;
    String? copied;
    String? destination;
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
        bundle: bundle,
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DocExamplePanel(
                example: example,
                onNavigate: (route) => destination = route,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Source'));
    await tester.pump();
    await tester.tap(find.text('Full example'));
    await tester.pumpAndSettle();
    final source = tester.widget<DartCodeView>(find.byType(DartCodeView)).code;
    expect(source, await loadDocExampleSource(example, bundle: bundle));
    await tester.ensureVisible(find.text('Copy full example'));
    await tester.tap(find.text('Copy full example'));
    await tester.pump();
    expect(copied, source);
    expect(copied, contains('child: MotionKeyframesExample()'));
    expect(find.text('Open playground'), findsOneWidget);
    await tester.ensureVisible(find.text('Open playground'));
    await tester.tap(find.text('Open playground'));
    expect(destination, example.playgroundRoute);
    expect(
      recipeById(example.playgroundId)!.documentationExample!.identity,
      example.identity,
    );
  });

  test('save exact runnable docs exports for analyzer verification', () async {
    final directory = Directory('build/docs_export_verification')
      ..createSync(recursive: true);
    final seen = <String>{};
    for (final article in SiteContent.articles) {
      for (final example in docExamplesFor(article.packageId, article.id)) {
        if (!seen.add(example.identity)) continue;
        final source = await loadDocExampleSource(example, bundle: bundle);
        File('${directory.path}/${example.widgetClass}_${seen.length}.dart')
            .writeAsStringSync(source);
      }
    }
    expect(seen, hasLength(48));
  });
}
