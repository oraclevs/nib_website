import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/ember_theme.dart';
import 'package:nib_ember_living/playground/example_card_art.dart';
import 'package:nib_ember_living/playground/examples_page.dart';
import 'package:nib_ember_living/recipes/recipe_catalog.dart';
import 'package:nib_motion/nib_motion.dart';

void main() {
  test('every canonical recipe has an explicit distinct illustration', () {
    expect(
      recipeIllustrations.keys.toSet(),
      verifiedRecipes.map((r) => r.id).toSet(),
    );
    expect(recipeIllustrations.values.toSet().length, verifiedRecipes.length);
    expect(recipeIllustrations['spring-retarget'], RecipeIllustration.retarget);
    expect(recipeIllustrations['keyframe-hop'], RecipeIllustration.keyframes);
    expect(recipeIllustrations['spring-tween'], RecipeIllustration.responses);
    expect(recipeIllustrations['keyed-reorder'], RecipeIllustration.reorder);
    expect(recipeIllustrations['bounded-drag'], RecipeIllustration.bounds);
  });

  testWidgets(
    'illustrations explain recipe behavior and render within bounds',
    (tester) async {
      final semantics = tester.ensureSemantics();
      for (final recipe in verifiedRecipes.reversed) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 245,
                  height: 160,
                  child: ExampleCardArt(recipe: recipe),
                ),
              ),
            ),
          ),
        );
        expect(
          find.bySemanticsLabel(
            'Illustration: ${recipeIllustrations[recipe.id]!.description}',
          ),
          findsOneWidget,
          reason: recipe.id,
        );
        expect(
          tester.getSize(find.byKey(ValueKey('recipe-art-${recipe.id}'))),
          const Size(245, 160),
        );
        expect(tester.takeException(), isNull, reason: recipe.id);
        expect(
          tester.binding.transientCallbackCount,
          0,
          reason: 'Illustrations do not run persistent simulations.',
        );
      }
      semantics.dispose();
    },
  );

  testWidgets(
    'search, category, saved filters retain canonical recipe identity',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final favorites = ValueNotifier<Set<String>>({
        'spring-tween',
        'keyframe-hop',
      });
      addTearDown(favorites.dispose);
      final opened = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(1440, 1000),
              disableAnimations: true,
            ),
            child: Scaffold(
              body: NibMotionConfig(
                reducedMotion: true,
                child: ExamplesPage(
                  onOpenRecipe: opened.add,
                  favorites: favorites,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('30 RUNNABLE EXAMPLES'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'spring-tween');
      await tester.pumpAndSettle();
      expect(find.text('01 RUNNABLE EXAMPLES'), findsOneWidget);
      final art = tester.widget<ExampleCardArt>(find.byType(ExampleCardArt));
      expect(art.recipe.id, 'spring-tween');
      await tester.tap(find.text('Spring or timed response'));
      expect(opened, ['spring-tween']);
      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.text('☆ Saved'));
      await tester.pumpAndSettle();
      expect(find.text('02 SAVED EXAMPLES'), findsOneWidget);
      expect(
        tester
            .widgetList<ExampleCardArt>(find.byType(ExampleCardArt))
            .map((a) => a.recipe.id)
            .toList(),
        ['keyframe-hop', 'spring-tween'],
      );
      await tester.tap(find.text('Multi-stage keyframe hop'));
      expect(opened.last, 'keyframe-hop');
      await tester.tap(find.text('Components'));
      await tester.pumpAndSettle();
      expect(find.text('03 RUNNABLE EXAMPLES'), findsOneWidget);
      expect(
        tester
            .widgetList<ExampleCardArt>(find.byType(ExampleCardArt))
            .map((a) => a.recipe.id)
            .toList(),
        ['form-validation', 'tab-content', 'accordion'],
      );
      await tester.tap(find.text('Accordion disclosure'));
      expect(opened.last, 'accordion');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'save action keeps the card identity and does not open a recipe',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final saved = <String>[];
      final opened = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NibMotionConfig(
              reducedMotion: true,
              child: ExamplesPage(
                onOpenRecipe: opened.add,
                onToggleFavorite: saved.add,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'spring-retarget');
      await tester.pumpAndSettle();
      await tester.tap(
        find.bySemanticsLabel('Save Mid-flight spring retarget'),
      );
      expect(saved, ['spring-retarget']);
      expect(opened, isEmpty);
    },
  );

  for (final width in [360.0, 390.0, 768.0, 1024.0, 1440.0]) {
    testWidgets('gallery fits a $width logical-pixel viewport', (tester) async {
      tester.view.physicalSize = Size(width, 950);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(width, 950),
              disableAnimations: true,
            ),
            child: Scaffold(
              body: NibMotionConfig(
                reducedMotion: true,
                child: ExamplesPage(onOpenRecipe: (_) {}),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.enterText(find.byType(TextField), 'keyframe-hop');
      await tester.pumpAndSettle();
      final art = find.byKey(const ValueKey('recipe-art-keyframe-hop'));
      final bounds = tester.getRect(art);
      expect(bounds.left, greaterThanOrEqualTo(0));
      expect(bounds.right, lessThanOrEqualTo(width));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('artwork contact sheet is available for complete visual review', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1250, 1170);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final loader = FontLoader('Ember Sans')
      ..addFont(rootBundle.load('assets/fonts/LiberationSans-Regular.ttf'));
    await tester.runAsync(loader.load);
    final boundary = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: RepaintBoundary(
          key: boundary,
          child: ColoredBox(
            color: Ember.code,
            child: Wrap(
              children: [
                for (final recipe in verifiedRecipes)
                  SizedBox(
                    width: 250,
                    height: 195,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 245,
                          height: 160,
                          child: ExampleCardArt(recipe: recipe),
                        ),
                        Text(
                          recipe.id,
                          style: const TextStyle(
                            fontFamily: 'Ember Sans',
                            color: Ember.text,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.runAsync(() async {
      final image =
          await (boundary.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary)
              .toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final output = File('build/gallery_artwork_review.png');
      await output.parent.create(recursive: true);
      await output.writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
    expect(tester.takeException(), isNull);
  });
}
