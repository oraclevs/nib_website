import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/components/component_catalog.dart';
import 'package:nib_ember_living/components/component_pages.dart';
import 'package:nib_ember_living/components/component_theme.dart';
import 'package:nib_ember_living/site_navigation.dart';

void main() {
  testWidgets('capture actual Flutter component pages for review', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final flutterRoot =
          Platform.environment['FLUTTER_ROOT'] ?? '/home/occ/DevTools/flutter';
      for (final family in ['Ember Sans', 'Roboto']) {
        final loader = FontLoader(family)
          ..addFont(rootBundle.load('assets/fonts/LiberationSans-Regular.ttf'))
          ..addFont(rootBundle.load('assets/fonts/LiberationSans-Bold.ttf'));
        await loader.load();
      }
      await (FontLoader('MaterialIcons')..addFont(
            File(
              '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
            ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
          ))
          .load();
      await (FontLoader(
        'Ember Mono',
      )..addFont(rootBundle.load('assets/fonts/DejaVuSansMono.ttf'))).load();
    });
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final id in [
      'explorer',
      ...componentGuides.map((guide) => guide.id),
    ]) {
      final key = GlobalKey();
      final path = id == 'explorer'
          ? '/components'
          : componentById(id)!.playgroundRoute;
      await tester.pumpWidget(
        MaterialApp(
          theme: componentEmberTheme(),
          home: RepaintBoundary(
            key: key,
            child: Scaffold(
              body: Column(
                children: [
                  SiteNavigation(
                    path: path,
                    onNavigate: (_) {},
                    onSearch: () {},
                    onSupport: () {},
                  ),
                  Expanded(
                    child: id == 'explorer'
                        ? ComponentExplorerPage(onNavigate: (_) {})
                        : ComponentGuidePage(
                            guide: componentById(id)!,
                            onNavigate: (_) {},
                            playground: true,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      // Autoplay, loaders and skeletons intentionally never settle. Capture a
      // fixed visible frame after assets and initial transitions have loaded.
      await tester.pump(const Duration(milliseconds: 400));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        final png = (await image.toByteData(format: ui.ImageByteFormat.png))!;
        final file = File(
          'docs/evidence/2026-10-28-components/visual/$id-widget.png',
        );
        await file.parent.create(recursive: true);
        await file.writeAsBytes(png.buffer.asUint8List());
        image.dispose();
      });
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });
}
