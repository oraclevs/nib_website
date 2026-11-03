import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/playground/playground_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('favorite choice is saved in local preferences', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
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
    // Ambient motion keeps scheduling frames; wait for a bounded interval.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Tune'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.scrollUntilVisible(
      find.text('Save recipe'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Save recipe'));
    await tester.pump(const Duration(milliseconds: 400));
    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getStringList('nib_ember_favorites_v1'),
      contains('spring-retarget'),
    );
    expect(find.text('Saved locally'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
