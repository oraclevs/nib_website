import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/recipes/recipe_runtime.dart';
import 'package:nib_motion/nib_motion.dart';

void main() {
  Future<void> mount(
    WidgetTester tester,
    ValueNotifier<bool> visible,
    String id,
    double value,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<bool>(
            valueListenable: visible,
            builder: (context, enabled, child) =>
                TickerMode(enabled: enabled, child: child!),
            child: SizedBox(
              width: 340,
              height: 400,
              child: RecipeRuntime(recipeId: id, value: value),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'local task preserves remaining time while hidden and disposes cleanly',
    (tester) async {
      final visible = ValueNotifier(true);
      addTearDown(visible.dispose);
      await mount(tester, visible, 'loading-result', 1000);
      await tester.tap(find.text('Run local task'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Working locally…'), findsOneWidget);
      visible.value = false;
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));
      expect(find.text('Done'), findsNothing);
      visible.value = true;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        find.text('Done'),
        findsNothing,
        reason: '500 ms is less than the saved600 ms remaining.',
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Done'), findsOneWidget);
      await tester.tap(find.text('Run local task'));
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
      expect(tester.binding.transientCallbackCount, 0);
    },
  );

  testWidgets(
    'onboarding stages resume in order and reset cancels pending stages',
    (tester) async {
      final visible = ValueNotifier(true);
      addTearDown(visible.dispose);
      await mount(tester, visible, 'onboarding-sequence', 300);
      int activeStages() => tester
          .widgetList<NibMotion>(find.byType(NibMotion))
          .where((motion) => (motion.animate as NibAnim).opacity == 1)
          .length;
      await tester.tap(find.text('Try it'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(activeStages(), 0);
      visible.value = false;
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));
      expect(activeStages(), 0);
      visible.value = true;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(activeStages(), 1);
      await tester.pump(const Duration(milliseconds: 300));
      expect(activeStages(), 2);
      await tester.tap(find.text('Reset'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      expect(activeStages(), 0);
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );
}
