import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/playground/playground_page.dart';

void main() {
  Future<void> mount(WidgetTester tester, Size size) async {
    await tester.runAsync(() async {
      await rootBundle.loadString('lib/ember_material_theme.dart');
      await rootBundle.loadString('lib/components/component_theme.dart');
      await rootBundle.loadString('lib/components/component_toggle.dart');
      await rootBundle.loadString('lib/recipes/spring_retarget_recipe.dart');
      await rootBundle.loadString('lib/recipes/recipe_tuning.dart');
    });
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlaygroundPage(
            recipeId: 'spring-retarget',
            onOpenRecipe: (_) {},
          ),
        ),
      ),
    );
    await tester.runAsync(() async => Future<void>.delayed(Duration.zero));
    await tester.pump();
    expect(tester.takeException(), isNull);
  }

  testWidgets('desktop keeps the reference workspace columns and real source', (
    tester,
  ) async {
    await mount(tester, const Size(1440, 900));
    expect(find.text('The playground'), findsOneWidget);
    expect(find.text('MOTION RECIPES'), findsOneWidget);
    expect(find.text('REAL FLUTTER'), findsOneWidget);
    expect(find.text('Make it yours'), findsOneWidget);
    expect(find.text('Launcher'), findsOneWidget);
    expect(find.text('Full example'), findsOneWidget);
    expect(find.text('Source files'), findsOneWidget);
    expect(find.text('Restart'), findsOneWidget);
    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('SEEK'), findsNothing);
    expect(find.text('Compare'), findsNothing);
    await tester.tap(find.text('Pause'));
    await tester.pump();
    expect(find.text('Resume'), findsOneWidget);
    await tester.tap(find.text('Restart'));
    await tester.pump();
    expect(find.text('Pause'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'tablet keeps recipe navigation and puts inspector below preview',
    (tester) async {
      await mount(tester, const Size(850, 900));
      expect(find.text('MOTION RECIPES'), findsOneWidget);
      expect(find.text('REAL FLUTTER'), findsOneWidget);
      expect(find.text('Make it yours'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('mobile has three working panes without losing copy and tuning', (
    tester,
  ) async {
    await mount(tester, const Size(390, 844));
    expect(find.text('The playground'), findsOneWidget);
    expect(find.text('Preview'), findsOneWidget);
    expect(find.text('Tune'), findsOneWidget);
    expect(find.text('Code'), findsOneWidget);
    expect(find.text('REAL FLUTTER'), findsOneWidget);
    await tester.tap(find.text('Tune'));
    await tester.pump();
    expect(find.text('Make it yours'), findsOneWidget);
    expect(find.text('Travel distance'), findsOneWidget);
    await tester.tap(find.text('Code'));
    await tester.pumpAndSettle();
    expect(find.text('Full example'), findsOneWidget);
    await tester.tap(find.text('Source files'));
    await tester.pump();
    expect(
      find.textContaining('Copy spring_retarget_recipe.dart'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
