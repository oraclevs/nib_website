import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/components/component_catalog.dart';
import 'package:nib_ember_living/components/component_preview.dart';
import 'package:nib_ember_living/components/component_theme.dart';
import 'package:nib_ember_living/ember_material_theme.dart';
import 'package:nib_ember_living/ember_theme.dart';

void main() {
  test('component typography preserves inherited color and font', () {
    for (final accent in [0xFFFFB51B, 0xFFCFDEA0]) {
      final base = emberMaterialTheme(accent: Color(accent));
      final preview = componentEmberTheme(accent: accent);
      final text = preview.textTheme.bodyMedium!;
      expect(text.color, base.textTheme.bodyMedium!.color);
      expect(text.fontFamily, base.textTheme.bodyMedium!.fontFamily);
      expect(text.fontSize, 14);
      expect(text.height, 1.5);
      for (final style in [
        preview.textTheme.bodySmall,
        preview.textTheme.bodyMedium,
        preview.textTheme.bodyLarge,
        preview.textTheme.titleMedium,
      ]) {
        expect(style!.color, isNotNull);
        final contrast =
            (style.color!.computeLuminance() + .05) /
            (Ember.panel.computeLuminance() + .05);
        expect(contrast, greaterThanOrEqualTo(4.5));
      }
    }
  });

  testWidgets('actual card body, footer and status render readable text', (
    tester,
  ) async {
    final guide = componentById('card')!;
    for (final accent in [0xFFFFB51B, 0xFFCFDEA0]) {
      final settings = guide.initial.change('accent', accent);
      await tester.pumpWidget(
        MaterialApp(
          key: ValueKey(accent),
          theme: emberMaterialTheme(),
          home: Scaffold(
            body: ComponentPreview(
              settings: settings,
              child: buildComponentDemo(guide, settings, (_) {}, (_) {}),
            ),
          ),
        ),
      );
      await tester.pump();
      for (final label in [
        'A useful card keeps related content together. Turn on interaction to make the whole surface actionable.',
        'Header · content · footer',
        'Card activations: 0',
      ]) {
        final paragraph = tester.renderObject<RenderParagraph>(
          find.text(label),
        );
        expect(paragraph.text.style!.color, Ember.text, reason: label);
        expect(paragraph.text.style!.fontFamily, 'Ember Sans', reason: label);
      }
      expect(tester.takeException(), isNull);
    }
  });
}
