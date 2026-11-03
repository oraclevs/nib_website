import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/playground/playground_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('ambient grid cannot paint over the preview header', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: RepaintBoundary(
            key: boundaryKey,
            child: PlaygroundPage(recipeId: 'card-flip', onOpenRecipe: (_) {}),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    final header = tester.getRect(find.text('FLIP CARD / MOTION'));
    final boundary =
        boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    for (final elapsed in [
      const Duration(milliseconds: 250),
      const Duration(milliseconds: 1800),
    ]) {
      await tester.pump(elapsed);
      final brightPixels = await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = (await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        ))!;
        var count = 0;
        for (var y = header.top.ceil(); y < header.bottom.floor(); y++) {
          for (var x = header.left.ceil(); x < header.right.floor(); x++) {
            final i = (y * image.width + x) * 4;
            if (bytes.getUint8(i) > 170 &&
                bytes.getUint8(i + 1) > 160 &&
                bytes.getUint8(i + 2) > 140) {
              count++;
            }
          }
        }
        image.dispose();
        return count;
      });
      expect(
        brightPixels,
        greaterThan(25),
        reason: 'The header text must remain painted above the ambient grid.',
      );
    }
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
}
