import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/ember_theme.dart';
import 'package:nib_ember_living/playground/playground_page.dart';
import 'package:nib_ember_living/recipes/recipe_runtime.dart';
import 'package:nib_ember_living/recipes/recipe_catalog.dart';
import 'package:nib_motion/nib_motion.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> mount(
    WidgetTester tester,
    double width, {
    String recipe = 'card-flip',
  }) async {
    await tester.runAsync(() async {
      await rootBundle.loadString('lib/ember_material_theme.dart');
      await rootBundle.loadString('lib/components/component_theme.dart');
      await rootBundle.loadString('lib/components/component_toggle.dart');
      for (final file in [
        'recipe_runtime.dart',
        'recipe_tuning.dart',
        'spring_retarget_recipe.dart',
      ]) {
        await rootBundle.loadString('lib/recipes/$file');
      }
    });
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: PlaygroundPage(recipeId: recipe, onOpenRecipe: (_) {}),
        ),
      ),
    );
    await tester.runAsync(() async => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> copyFull(WidgetTester tester) async {
    if (find.text('Code').evaluate().isNotEmpty) {
      await tester.tap(find.text('Code'));
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(find.text('Full example'));
    await tester.tap(find.text('Full example'));
    await tester.pump();
    await tester.ensureVisible(find.text('Copy full example').first);
    await tester.tap(find.text('Copy full example').first);
  }

  for (final width in [360.0, 390.0, 768.0, 1024.0, 1440.0]) {
    testWidgets('shared card-flip shell stays usable at $width', (
      tester,
    ) async {
      await mount(tester, width);
      expect(find.text('REAL FLUTTER'), findsOneWidget);
      expect(find.text('Copy minimal example'), findsWidgets);
      final previewHeader = tester.getRect(find.text('REAL FLUTTER'));
      expect(previewHeader.left, greaterThanOrEqualTo(0));
      expect(previewHeader.right, lessThanOrEqualTo(width));
      await tester.ensureVisible(find.text('Play'));
      await tester.tap(find.text('Play'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.widget<NibFlip>(find.byType(NibFlip)).isFlipped, isTrue);
      if (width < 640) {
        await tester.tap(find.text('Tune'));
        await tester.pump();
      }
      final slider = find.byKey(const ValueKey('recipe-control-value'));
      final sliderWidth = tester.getSize(slider).width;
      // Desktop inspector interior is 246px; narrow mobile is 276px.
      expect(sliderWidth, greaterThanOrEqualTo(240));
      final widget = tester.widget<Slider>(slider);
      widget.onChanged!(widget.max);
      await tester.pump();
      expect(tester.widget<Slider>(slider).value, widget.max);
      if (width < 640) {
        await tester.tap(find.text('Code'));
        await tester.pumpAndSettle();
        expect(find.text('Launcher'), findsOneWidget);
        await tester.tap(find.text('Source files'));
        await tester.pump();
        expect(find.text('Copy launcher'), findsOneWidget);
        await tester.tap(find.text('Preview'));
        await tester.pump();
        expect(
          tester.widget<NibFlip>(find.byType(NibFlip)).isFlipped,
          isTrue,
          reason: 'Changing mobile panes must preserve the live interaction.',
        );
        await tester.tap(find.text('Tune'));
        await tester.pump();
        expect(tester.widget<Slider>(slider).value, widget.max);
      }
      final themeContext = tester.element(slider);
      final style = Theme.of(themeContext).outlinedButtonTheme.style!;
      final shape = style.shape!.resolve({})! as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(5));
      expect(Theme.of(themeContext).sliderTheme.activeTrackColor, Ember.accent);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('card speed controls real duration and the copied example', (
    tester,
  ) async {
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
    await mount(tester, 390);
    final speed = find.byKey(const ValueKey('card-playback-speed'));
    expect(tester.widget<DropdownButton<double>>(speed).value, 1);
    tester.widget<DropdownButton<double>>(speed).onChanged!(2);
    await tester.pump();
    expect(
      tester.widget<NibFlip>(find.byType(NibFlip)).duration,
      const Duration(milliseconds: 300),
    );
    await copyFull(tester);
    await tester.runAsync(() async => Future<void>.delayed(Duration.zero));
    await tester.pump();
    expect(copied, contains('value: 300.0'));
    await tester.tap(find.text('Preview'));
    await tester.pump();
    tester.widget<DropdownButton<double>>(speed).onChanged!(.5);
    await tester.pump();
    expect(
      tester.widget<NibFlip>(find.byType(NibFlip)).duration,
      const Duration(milliseconds: 1200),
    );
    await tester.tap(find.text('Tune'));
    await tester.pump();
    tester
        .widget<Slider>(find.byKey(const ValueKey('recipe-control-value')))
        .onChanged!(700);
    await tester.pump();
    await tester.tap(find.text('Preview'));
    await tester.pump();
    expect(tester.widget<DropdownButton<double>>(speed).value, isNull);
    expect(find.text('Custom'), findsOneWidget);
    expect(
      tester.widget<NibFlip>(find.byType(NibFlip)).duration,
      const Duration(milliseconds: 700),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('card presets map gentle to slow and snappy to quick', (
    tester,
  ) async {
    await mount(tester, 1440);
    expect(find.text('Default'), findsNothing);
    for (final preset in {
      'Gentle': 900,
      'Balanced': 600,
      'Snappy': 300,
    }.entries) {
      await tester.tap(find.text(preset.key));
      await tester.pump();
      expect(
        tester.widget<NibFlip>(find.byType(NibFlip)).duration,
        Duration(milliseconds: preset.value),
      );
      final button = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, preset.key),
      );
      expect(button.style!.side!.resolve({})!.color, Ember.accent);
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('progress is bounded, labelled and resettable', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 360,
            child: RecipeRuntime(recipeId: 'progress-choreography', value: 40),
          ),
        ),
      ),
    );
    expect(find.text('SIMULATED TASK'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(
      find.text('Advance manually. No files are uploaded.'),
      findsOneWidget,
    );
    for (final expected in ['40%', '80%', '100%']) {
      await tester.tap(find.text('Advance step'));
      await tester.pump(const Duration(milliseconds: 80));
      expect(find.text(expected), findsOneWidget);
    }
    expect(find.text('Task complete'), findsOneWidget);
    expect(find.text('Done'), findsNWidgets(3));
    final complete = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Complete'),
    );
    expect(complete.onPressed, isNull);
    final motion = tester.widget<NibMotion>(
      find.byKey(const ValueKey('progress-fill-motion')),
    );
    expect((motion.animate as NibAnim).x, 0);
    await tester.tap(find.text('Reset'));
    await tester.pump();
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('Advance step'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('copy example contains live settings and actual implementation', (
    tester,
  ) async {
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
    await mount(tester, 390);
    await tester.tap(find.text('Tune'));
    await tester.pump();
    final slider = tester.widget<Slider>(
      find.byKey(const ValueKey('recipe-control-value')),
    );
    slider.onChanged!(slider.max);
    await tester.pump();
    await copyFull(tester);
    await tester.runAsync(() async => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(copied, contains('void main()'));
    expect(copied, contains('class RecipeRuntime'));
    expect(copied, contains("recipeId: 'card-flip'"));
    expect(copied, contains('value: ${slider.max}'));
    expect(copied, isNot(contains("import 'recipe_runtime.dart'")));
  });

  testWidgets(
    'denied clipboard opens selectable complete source without success claim',
    (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            throw PlatformException(code: 'denied');
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
      await mount(tester, 390);
      await copyFull(tester);
      await tester.runAsync(() async => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(find.textContaining('Clipboard unavailable.'), findsWidgets);
      expect(find.text('Complete main.dart copied.'), findsNothing);
      expect(find.text('Complete main.dart'), findsOneWidget);
      expect(find.byType(SelectableText), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'guided text route opens the exact exercise and copies its constructor',
    (tester) async {
      final recipe = allRecipes.firstWhere(
        (recipe) =>
            recipe.documentationExample?.constructorArguments ==
            'kind: TextMotionKind.typewriter',
      );
      await tester.runAsync(() => rootBundle.loadString(recipe.sourceAsset));
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
      await mount(tester, 390, recipe: recipe.id);
      expect(find.text('REAL FLUTTER'), findsOneWidget);
      expect(find.text('Pause'), findsNothing);
      await tester.tap(find.text('Tune'));
      await tester.pump();
      expect(
        find.textContaining('controls beside the animation'),
        findsOneWidget,
      );
      expect(
        find.byType(Slider),
        findsNothing,
        reason:
            'The inspector must not fabricate controls for guided exercises.',
      );
      await copyFull(tester);
      await tester.runAsync(() async => Future<void>.delayed(Duration.zero));
      await tester.pump();
      expect(copied, contains('class MotionTextExample'));
      expect(
        copied,
        contains('MotionTextExample(kind: TextMotionKind.typewriter)'),
      );
      expect(copied, isNot(contains("import 'recipe_runtime.dart'")));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'motion toolbar controls remain independent of reset and inspector',
    (tester) async {
      await mount(tester, 1440);
      expect(find.text('Ambient on'), findsOneWidget);
      await tester.tap(find.text('Pause motion'));
      await tester.pump();
      expect(
        TickerMode.valuesOf(tester.element(find.byType(NibFlip))).enabled,
        isFalse,
      );
      await tester.tap(find.text('Ambient on'));
      await tester.pump();
      expect(find.text('Ambient off'), findsOneWidget);
      await tester.tap(find.text('Reset').first);
      await tester.pump();
      expect(find.text('Resume motion'), findsOneWidget);
      expect(find.text('Ambient off'), findsOneWidget);
      await tester.tap(find.text('Reduce motion'));
      await tester.pump();
      expect(find.text('Reduced motion on'), findsOneWidget);
      await tester.tap(find.text('Resume motion'));
      await tester.pump();
      expect(find.text('Reduced motion on'), findsOneWidget);
      expect(
        MediaQuery.disableAnimationsOf(tester.element(find.byType(NibFlip))),
        isTrue,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
