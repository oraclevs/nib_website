import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_components/nib_components.dart';
import 'package:nib_motion/nib_motion.dart';
import 'package:nib_ember_living/recipes/recipe_runtime.dart';
import 'package:nib_ember_living/recipes/recipe_tuning.dart';

Future<void> mountRecipe(
  WidgetTester tester,
  String id,
  double value,
  RecipeTuning tuning,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 500,
            height: 440,
            child: RecipeRuntime(recipeId: id, value: value, settings: tuning),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('drag controls reach the public Nib drag configuration', (
    tester,
  ) async {
    await mountRecipe(
      tester,
      'drag-snap',
      100,
      const RecipeTuning(elasticity: .4, release: RecipeDragRelease.inertia),
    );
    final drag = tester
        .widgetList<NibMotion>(find.byType(NibMotion))
        .singleWhere((motion) => motion.drag != null)
        .drag!;
    expect(drag.elastic, isTrue);
    expect(drag.elasticFactor, .4);
    expect(drag.releaseMode, NibDragReleaseMode.inertia);
    expect(drag.snapPoints, isNull);
  });

  testWidgets('flip axis and duration reach NibFlip', (tester) async {
    await mountRecipe(
      tester,
      'card-flip',
      820,
      const RecipeTuning(option: true),
    );
    final flip = tester.widget<NibFlip>(find.byType(NibFlip));
    expect(flip.flipAxis, Axis.vertical);
    expect(flip.duration, const Duration(milliseconds: 820));
  });

  testWidgets('reveal threshold and repeat option reach NibScrollReveal', (
    tester,
  ) async {
    await mountRecipe(
      tester,
      'viewport-reveal',
      44,
      const RecipeTuning(secondary: .65, option: false),
    );
    final reveal = tester.widget<NibScrollReveal>(
      find.byType(NibScrollReveal).first,
    );
    expect(reveal.amount, .65);
    expect(reveal.once, isFalse);
    expect(reveal.initial.y, 44);
  });

  testWidgets('accordion duration and coordination reach NibAccordion', (
    tester,
  ) async {
    await mountRecipe(
      tester,
      'accordion',
      80,
      const RecipeTuning(durationMs: 760, option: true),
    );
    final accordion = tester.widget<NibAccordion>(find.byType(NibAccordion));
    expect(accordion.animated, isTrue);
    expect(accordion.allowMultipleOpen, isTrue);
    expect(accordion.transition!.duration, const Duration(milliseconds: 760));
  });
}
