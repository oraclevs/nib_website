import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/playground/playground_page.dart';

void main() {
  testWidgets('source handoff includes the branded control and flat import', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      for (final path in [
        'lib/docs/examples/motion_accessibility_example.dart',
        'lib/components/component_toggle.dart',
        'lib/ember_material_theme.dart',
        'lib/components/component_theme.dart',
      ]) {
        await rootBundle.loadString(path);
      }
    });
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
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlaygroundPage(
            recipeId: 'guide-motion-accessibility-example',
            onOpenRecipe: (_) {},
          ),
        ),
      ),
    );
    await tester.runAsync(() async => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Ambient on'));
    await tester.pump();
    await tester.ensureVisible(find.text('Source files'));
    await tester.tap(find.text('Source files'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Copy branded switch'));
    await tester.tap(find.text('Copy branded switch'));
    await tester.pump();
    expect(copied, contains('class ComponentToggle'));
    expect(copied, contains('nibSwitchLogo'));
    await tester.ensureVisible(
      find.text('Copy motion_accessibility_example.dart'),
    );
    await tester.tap(find.text('Copy motion_accessibility_example.dart'));
    await tester.pump();
    expect(copied, contains("import 'component_toggle.dart';"));
    expect(copied, isNot(contains('../../components/')));
    expect(tester.takeException(), isNull);
  });
}
