import 'package:nib_ember_living/components/component_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/content/site_content.dart';
import 'package:nib_ember_living/components/component_catalog.dart';
import 'package:nib_ember_living/components/component_support_guides.dart';
import 'package:nib_ember_living/docs/doc_example_catalog.dart';
import 'package:nib_motion/nib_motion.dart';

Future<void> pumpExample(WidgetTester tester, DocExample example) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 360,
            child: SingleChildScrollView(child: example.buildPreview()),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 250));
}

void main() {
  test('articles resolve to exact preview source or an explicit cross-family support guide', () async {
    final supportById = {
      for (final article in componentSupportArticles) article.id: article,
    };
    for (final article in SiteContent.articles) {
      final component = article.packageId == 'components'
          ? componentById(article.id)
          : null;
      if (component != null) {
        final source = await rootBundle.loadString(component.demoFile);
        expect(source, contains('class ${component.demoClass} extends'));
        expect(component.route, article.route);
        expect(
          buildComponentDemo(
            component,
            component.initial,
            (_) {},
            (_) {},
          ).runtimeType.toString(),
          component.demoClass,
        );
        continue;
      }
      if (article.packageId == 'components' &&
          supportById.containsKey(article.id)) {
        // Cross-family policy/reference guides use concrete code and links;
        // they do not masquerade as a single repeated generic live demo.
        expect(article, same(supportById[article.id]));
        expect(componentSupportSymbols[article.id], isNotEmpty);
        expect(
          article.sections.any((section) => section.code != null),
          isTrue,
          reason: article.route,
        );
        expect(article.evidence, isNotEmpty);
        continue;
      }
      if (article.packageId == 'motion' &&
          {'introduction', 'installation'}.contains(article.id)) {
        expect(docExamplesFor('motion', article.id), isEmpty);
        expect(docExampleFor('motion', article.id), isNull);
        continue;
      }
      final example = docExampleFor(article.packageId, article.id);
      expect(example, isNotNull, reason: article.route);
      final source = await rootBundle.loadString(example!.sourceAsset);
      expect(source, contains('class ${example.widgetClass} extends'));
      expect(
        example.buildPreview().runtimeType.toString(),
        example.widgetClass,
      );
    }
  });

  test('reference concepts lead to distinct real package examples', () {
    const topics = [
      'first-animation',
      'springs',
      'keyframes',
      'motion-values',
      'presence',
      'layout-animations',
      'gestures',
      'scroll-motion',
      'accessibility',
    ];
    final paths = topics
        .map((id) => docExampleFor('motion', id)!.sourceAsset)
        .toSet();
    expect(paths, hasLength(topics.length));
    expect(docExampleFor('motion', 'missing'), isNull);
  });

  testWidgets('motion examples respond to their documented controls', (
    tester,
  ) async {
    await pumpExample(tester, docExampleFor('motion', 'first-animation')!);
    expect(
      (tester.widget<NibMotion>(find.byType(NibMotion)).animate as NibAnim).y,
      0,
    );
    await tester.tap(find.text('Save idea'));
    await tester.pump();
    expect(find.text('Undo save'), findsOneWidget);
    expect(
      (tester.widget<NibMotion>(find.byType(NibMotion)).animate as NibAnim).y,
      -10,
    );

    await pumpExample(tester, docExampleFor('motion', 'springs')!);
    expect(
      (tester.widget<NibMotion>(find.byType(NibMotion)).animate as NibAnim).x,
      -60,
    );
    await tester.tap(find.text('Retarget'));
    await tester.pump();
    expect(
      (tester.widget<NibMotion>(find.byType(NibMotion)).animate as NibAnim).x,
      60,
    );

    await pumpExample(tester, docExampleFor('motion', 'keyframes')!);
    await tester.tap(find.text('Replay keyframes'));
    await tester.pump();
    expect(tester.takeException(), isNull);

    await pumpExample(tester, docExampleFor('motion', 'presence')!);
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('4'), findsOneWidget);
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(find.text('4'), findsNothing);

    await pumpExample(tester, docExampleFor('motion', 'layout-animations')!);
    final firstCenter = tester.getCenter(find.text('A'));
    await tester.tap(find.text('Move first to end'));
    await tester.pumpAndSettle();
    expect(find.text('A'), findsOneWidget);
    expect(tester.getCenter(find.text('A')).dx, greaterThan(firstCenter.dx));
    expect(tester.takeException(), isNull);
  });

  testWidgets('motion value, gesture, and accessibility controls work', (
    tester,
  ) async {
    await pumpExample(tester, docExampleFor('motion', 'motion-values')!);
    final slider = tester.widget<Slider>(find.byType(Slider));
    slider.onChanged!(0.9);
    await tester.pump();
    expect(tester.widget<Slider>(find.byType(Slider)).value, closeTo(.9, .001));
    expect(
      tester
          .widget<NibMotion>(find.byType(NibMotion))
          .motionValues!
          .translateX!
          .value,
      closeTo(49.6, .001),
    );

    await pumpExample(tester, docExampleFor('motion', 'gestures')!);
    await tester.tap(find.text('Move right'));
    await tester.pump();
    expect(find.text('Move left'), findsOneWidget);

    await pumpExample(tester, docExampleFor('motion', 'accessibility')!);
    await tester.tap(find.byType(ComponentToggle));
    await tester.pump();
    expect(
      tester
          .widget<NibMotionConfig>(find.byType(NibMotionConfig))
          .reducedMotion,
      isTrue,
    );
    await tester.tap(find.text('Complete'));
    await tester.pump();
    expect(find.text('Reset'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('scroll example enters its inner viewport', (tester) async {
    await pumpExample(tester, docExampleFor('motion', 'scroll-motion')!);
    final viewport = tester.getRect(find.byType(ListView));
    expect(find.text('Revealed'), findsNothing);
    await tester.drag(find.byType(ListView), const Offset(0, -230));
    await tester.pumpAndSettle();
    final after = tester.getRect(find.text('Revealed'));
    expect(after.center.dy, inInclusiveRange(viewport.top, viewport.bottom));
    expect(tester.takeException(), isNull);
  });

  testWidgets('component examples update native widget state', (tester) async {
    await pumpExample(tester, docExampleFor('components', 'catalog')!);
    await tester.tap(find.text('Add one'));
    await tester.pump();
    expect(find.text('Pressed 1 time'), findsOneWidget);
    await tester.tap(find.text('Reset'));
    await tester.pump();
    expect(find.text('Pressed 0 times'), findsOneWidget);

    await pumpExample(tester, docExampleFor('components', 'forms')!);
    await tester.tap(find.text('Check form'));
    await tester.pump();
    expect(find.text('Enter a name'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Ada');
    await tester.tap(find.text('Check form'));
    await tester.pump();
    expect(find.text('Ready for Ada'), findsOneWidget);

    await pumpExample(tester, docExampleFor('components', 'theming')!);
    expect(find.text('Dark palette · amber'), findsOneWidget);
    await tester.tap(find.text('Change accent token'));
    await tester.pump();
    expect(find.text('Dark palette · sage'), findsOneWidget);
  });

  testWidgets('GenUI fixture replays bounded frames and validates action', (
    tester,
  ) async {
    await pumpExample(tester, docExampleFor('genui', 'runtime')!);
    for (var frame = 1; frame <= 3; frame++) {
      await tester.tap(find.text('Next frame'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Frame $frame / 3'), findsOneWidget);
    }
    expect(find.text('Native generated UI'), findsOneWidget);
    await tester.tap(find.text('Say hello'));
    await tester.pump();
    expect(find.text('Enter a name first'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Ada');
    await tester.tap(find.text('Say hello'));
    await tester.pump();
    expect(find.text('Hello, Ada'), findsOneWidget);
    await tester.tap(find.text('Replay fixture'));
    await tester.pump();
    expect(find.text('Frame 0 / 3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
