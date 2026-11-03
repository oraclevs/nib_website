import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_components/nib_components.dart';
import 'package:nib_ember_living/components/component_settings.dart';
import 'package:nib_ember_living/components/component_theme.dart';
import 'package:nib_ember_living/components/examples/layout_family_demos.dart';
import 'package:nib_ember_living/components/guides/layout_family_guides.dart';
import 'package:nib_motion/nib_motion.dart';

Widget demo(
  String id,
  ComponentSettings settings,
  ValueChanged<ComponentSettings> onChanged,
  ValueChanged<String> onEvent,
) => switch (id) {
  'accordion' => AccordionComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'card' => CardComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'carousel' => CarouselComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'tabs' => TabsComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'data-table' => DataTableComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'resizable-panels' => ResizablePanelsComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'loader' => LoaderComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'skeleton' => SkeletonComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'breadcrumb' => BreadcrumbComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'pagination' => PaginationComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  _ => throw ArgumentError.value(id),
};

ComponentSettings initial(String id) =>
    layoutComponentGuides.singleWhere((guide) => guide.id == id).initial;

Future<ValueChanged<ComponentSettings>> mount(
  WidgetTester tester,
  String id, {
  double width = 768,
  bool light = false,
  bool reduce = false,
  ComponentSettings? settings,
  List<String>? events,
}) async {
  tester.view.physicalSize = Size(width, 1100);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  var current = settings ?? initial(id);
  late ValueChanged<ComponentSettings> update;
  await tester.pumpWidget(
    MaterialApp(
      theme: light ? ThemeData.light() : componentEmberTheme(),
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
          child: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: StatefulBuilder(
                builder: (context, setState) {
                  update = (next) => setState(() => current = next);
                  return demo(
                    id,
                    current,
                    update,
                    (event) => events?.add(event),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 20));
  return update;
}

void main() {
  test('ten guides cover public family symbols and supported setting keys', () {
    final inventory = jsonDecode(
      File('docs/evidence/2026-10-28-components/inventory.json')
          .readAsStringSync(),
    ) as Map<String, dynamic>;
    final families = {
      for (final dynamic family in inventory['families'] as List)
        family['id'] as String: family,
    };
    expect(layoutComponentGuides.length, 10);
    for (final guide in layoutComponentGuides) {
      expect(
        guide.symbols.toSet(),
        (families[guide.id]['symbols'] as List).toSet(),
        reason: guide.id,
      );
      expect(guide.sections.length, greaterThanOrEqualTo(4));
      expect(
        File(guide.demoFile).readAsStringSync(),
        contains('class ${guide.demoClass}'),
      );
      for (final control in guide.controls) {
        expect(guide.initial.values, contains(control.key));
      }
      for (final source in guide.source.split('; ')) {
        expect(File('../$source').existsSync(), isTrue, reason: source);
      }
    }
  });

  testWidgets('accordion coordinates sections and respects a disabled header', (
    tester,
  ) async {
    final events = <String>[];
    final update = await mount(tester, 'accordion', events: events);
    await tester.tap(find.text('How does this section open?'));
    await tester.pump();
    expect(find.text('Open sections: 1'), findsOneWidget);
    await tester.tap(find.text('What changes in multiple mode?'));
    await tester.pump();
    expect(find.text('Open sections: 2'), findsOneWidget);
    update(initial('accordion').change('multiple', true));
    await tester.pump();
    await tester.tap(find.text('How does this section open?'));
    await tester.pump();
    expect(find.text('Open sections: 1, 2'), findsOneWidget);
    await tester.tap(find.text('Close all'));
    await tester.pump();
    update(initial('accordion').change('disabled', true));
    await tester.pump();
    await tester.tap(find.text('What changes in multiple mode?'));
    await tester.pump();
    expect(find.text('Open sections: none'), findsOneWidget);
    expect(events, contains('Section 2: open'));
  });

  testWidgets('plain card activation and controlled flip use actual APIs', (
    tester,
  ) async {
    final update = await mount(tester, 'card');
    await tester.tap(find.text('A small project worth finishing'));
    await tester.pump();
    expect(find.text('Card activations: 1'), findsOneWidget);
    update(initial('card').change('variant', 'flip'));
    await tester.pump();
    expect(find.byType(NibFlipCard), findsOneWidget);
    expect(
      tester.widget<NibFlip>(find.byType(NibFlip)).duration,
      const Duration(milliseconds: 600),
    );
    await tester.tap(find.text('A small project worth finishing'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<NibFlipCard>(find.byType(NibFlipCard)).isFlipped,
      isTrue,
    );
    expect(find.text('Requested face: back'), findsOneWidget);
    update(initial('card').change('variant', 'flip').change('disabled', true));
    await tester.pump();
    expect(
      tester.widget<NibFlipCard>(find.byType(NibFlipCard)).tappable,
      isFalse,
    );
  });

  testWidgets('carousel moves the real logical page and stops at an end', (
    tester,
  ) async {
    final events = <String>[];
    await mount(
      tester,
      'carousel',
      events: events,
      settings: initial('carousel')
          .change('animated', false)
          .change('multiple', false),
    );
    await tester.tap(find.text('Next slide'));
    await tester.pumpAndSettle();
    expect(find.text('Slide 2 of 3'), findsOneWidget);
    final carousel = tester.widget<NibCarousel>(find.byType(NibCarousel));
    expect(carousel.controller!.page, 1);
    expect(carousel.autoPlay, isFalse);
    await tester.tap(find.text('Next slide'));
    await tester.pumpAndSettle();
    expect(find.text('Slide 3 of 3'), findsOneWidget);
    final next = tester.widget<NibButton>(
      find.ancestor(
        of: find.text('Next slide'),
        matching: find.byType(NibButton),
      ),
    );
    expect(next.onPressed, isNull);
    expect(events, contains('Slide 2 of 3'));
  });

  testWidgets(
    'carousel uses three real portable images and loops automatically',
    (tester) async {
      final events = <String>[];
      await mount(tester, 'carousel', events: events);
      final carousel = tester.widget<NibCarousel>(find.byType(NibCarousel));
      expect(carousel.autoPlay, isTrue);
      expect(carousel.loop, isTrue);
      expect(carousel.autoPlayInterval, const Duration(seconds: 4));
      final images = carousel.items
          .map(
            (item) =>
                ((item as Padding).child! as ClipRRect).child! as ColoredBox,
          )
          .map((box) => box.child! as Image)
          .toList();
      expect(images.map((image) => image.semanticLabel).toSet().length, 3);
      final bytes = images
          .map((image) => (image.image as MemoryImage).bytes)
          .toList();
      expect(bytes.map(base64Encode).toSet().length, 3);
      await tester.runAsync(() async {
        for (final image in bytes) {
          final codec = await ui.instantiateImageCodec(image);
          final frame = await codec.getNextFrame();
          expect(frame.image.width, 640);
          expect(frame.image.height, 360);
          frame.image.dispose();
          codec.dispose();
        }
      });
      for (final page in [1, 2, 0]) {
        await tester.pump(const Duration(seconds: 4));
        await tester.pump(const Duration(milliseconds: 400));
        expect(carousel.controller!.page, page);
      }
      expect(
        events,
        containsAll(['Slide 2 of 3', 'Slide 3 of 3', 'Slide 1 of 3']),
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 20));
      expect(tester.binding.transientCallbackCount, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'carousel pause stops its timer and resume starts from the current slide',
    (tester) async {
      await mount(tester, 'carousel');
      final controller = tester
          .widget<NibCarousel>(find.byType(NibCarousel))
          .controller!;
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(milliseconds: 400));
      expect(controller.page, 1);
      await tester.tap(find.text('Pause carousel'));
      await tester.pump();
      expect(
        tester.widget<NibCarousel>(find.byType(NibCarousel)).autoPlay,
        isFalse,
      );
      await tester.pump(const Duration(seconds: 12));
      expect(controller.page, 1);
      await tester.tap(find.text('Resume carousel'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(milliseconds: 400));
      expect(controller.page, 2);
    },
  );

  testWidgets(
    'reduced motion stops carousel autoplay and manual navigation jumps',
    (tester) async {
      await mount(tester, 'carousel', reduce: true);
      final carousel = tester.widget<NibCarousel>(find.byType(NibCarousel));
      expect(carousel.autoPlay, isFalse);
      expect(carousel.animated, isFalse);
      await tester.pump(const Duration(seconds: 12));
      expect(carousel.controller!.page, 0);
      await tester.tap(find.text('Next slide'));
      await tester.pump();
      expect(carousel.controller!.page, 1);
      final page = tester.widget<PageView>(find.byType(PageView));
      expect(page.controller!.position.isScrollingNotifier.value, isFalse);
    },
  );

  testWidgets(
    'hidden carousel cancels autoplay then resumes without catching up',
    (tester) async {
      final enabled = ValueNotifier(true);
      addTearDown(enabled.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValueListenableBuilder<bool>(
              valueListenable: enabled,
              builder: (_, visible, _) => TickerMode(
                enabled: visible,
                child: CarouselComponentDemo(
                  settings: initial('carousel'),
                  onChanged: (_) {},
                  onEvent: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final controller = tester
          .widget<NibCarousel>(find.byType(NibCarousel))
          .controller!;
      enabled.value = false;
      await tester.pump();
      expect(
        tester.widget<NibCarousel>(find.byType(NibCarousel)).autoPlay,
        isFalse,
      );
      await tester.pump(const Duration(seconds: 30));
      expect(controller.page, 0);
      enabled.value = true;
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      expect(controller.page, 0);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 400));
      expect(controller.page, 1);
    },
  );

  testWidgets('tabs select panels through animated and immediate operations', (
    tester,
  ) async {
    await mount(tester, 'tabs');
    await tester.tap(find.text('Animate to notes'));
    await tester.pumpAndSettle();
    expect(find.text('Selected tab: Notes'), findsOneWidget);
    expect(tester.widget<NibTabs>(find.byType(NibTabs)).controller!.index, 1);
    await tester.tap(find.text('Jump to overview'));
    await tester.pumpAndSettle();
    expect(find.text('Selected tab: Overview'), findsOneWidget);
  });

  testWidgets(
    'table sorts numbers, selects rows and shows loading and empty states',
    (tester) async {
      final update = await mount(tester, 'data-table');
      await tester.tap(find.text('Tasks'));
      await tester.pump();
      expect(find.text('Selected rows: 0 · Sort: ascending'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Dune')).dy,
        lessThan(tester.getTopLeft(find.text('Atlas')).dy),
      );
      await tester.tap(find.text('Birch'));
      await tester.pump();
      expect(find.text('Selected rows: 1 · Sort: ascending'), findsOneWidget);
      await tester.tap(find.text('Clear selection'));
      await tester.pump();
      expect(find.text('Selected rows: 0 · Sort: ascending'), findsOneWidget);
      await tester.tap(find.text('Show loading'));
      await tester.pump();
      expect(find.text('Birch'), findsNothing);
      await tester.tap(find.text('Show rows'));
      await tester.pump();
      update(initial('data-table').change('text', 'unmatched'));
      await tester.pump();
      expect(find.text('No matching projects'), findsOneWidget);
    },
  );

  testWidgets(
    'splitter drag and keyboard change fractions; reset restores them',
    (tester) async {
      final events = <String>[];
      await mount(tester, 'resizable-panels', width: 900, events: events);
      final handle = find.byType(NibResizablePanelsHandle);
      expect(handle, findsOneWidget);
      final controller = tester
          .widget<NibResizablePanels>(find.byType(NibResizablePanels))
          .controller!;
      final before = controller.sizes.first;
      await tester.drag(handle, const Offset(80, 0));
      await tester.pump();
      expect(controller.sizes.first, greaterThan(before));
      expect(controller.sizes.reduce((a, b) => a + b), closeTo(1, 1e-9));
      expect(events.any((e) => e.startsWith('Layout committed:')), isTrue);
      final afterDrag = controller.sizes.first;
      await tester.tap(handle);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(
        controller.sizes.first,
        closeTo(afterDrag + kNibResizablePanelsKeyboardStep, 1e-6),
      );
      await tester.tap(find.text('Reset split'));
      await tester.pump(const Duration(milliseconds: 350));
      expect(controller.sizes, [.5, .5]);
    },
  );

  testWidgets('narrow splitter intentionally stacks without a handle', (
    tester,
  ) async {
    await mount(tester, 'resizable-panels', width: 340);
    expect(find.byType(NibResizablePanelsHandle), findsNothing);
    expect(
      tester.getTopLeft(find.text('Working notes')).dy,
      greaterThan(tester.getTopLeft(find.text('Outline')).dy),
    );
  });

  testWidgets('loader pause and reduced motion affect the real ticker branch', (
    tester,
  ) async {
    await mount(
      tester,
      'loader',
      settings: initial('loader').change('animated', false),
    );
    expect(
      TickerMode.valuesOf(tester.element(find.byType(NibCircularLoader)))
          .enabled,
      isFalse,
    );
    await tester.tap(find.text('Run indicator'));
    await tester.pump();
    expect(
      TickerMode.valuesOf(tester.element(find.byType(NibCircularLoader)))
          .enabled,
      isTrue,
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Pause indicator'));
    await tester.pump();
    expect(
      TickerMode.valuesOf(tester.element(find.byType(NibCircularLoader)))
          .enabled,
      isFalse,
    );
    await mount(tester, 'loader', reduce: true);
    expect(find.byType(NibCircularLoader), findsNothing);
    expect(find.text('Reduced motion: static status'), findsOneWidget);
  });

  testWidgets(
    'skeleton reveals the authored tree and retains an ignored label',
    (tester) async {
      await mount(tester, 'skeleton');
      expect(
        tester.widget<NibSkeleton>(find.byType(NibSkeleton)).loading,
        isTrue,
      );
      expect(find.text('FIELD NOTES'), findsOneWidget);
      expect(find.text('Notes worth keeping'), findsNothing);
      await tester.tap(find.text('Reveal content'));
      await tester.pump();
      expect(
        tester.widget<NibSkeleton>(find.byType(NibSkeleton)).loading,
        isFalse,
      );
      expect(find.text('Notes worth keeping'), findsOneWidget);
      expect(find.byType(NibSkeletonBone), findsOneWidget);
    },
  );

  testWidgets('reduced motion uses static skeleton bones without shimmer', (
    tester,
  ) async {
    await mount(tester, 'skeleton', reduce: true);
    expect(
      tester.widget<NibSkeleton>(find.byType(NibSkeleton)).animated,
      isFalse,
    );
    expect(find.byType(NibShimmer), findsNothing);
    await tester.tap(find.text('Reveal content'));
    await tester.pump();
    expect(find.text('Notes worth keeping'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(NibShimmer), findsNothing);
    expect(find.byType(NibPresence), findsNothing);
  });

  testWidgets('breadcrumb changes its actual path and restores it', (
    tester,
  ) async {
    await mount(tester, 'breadcrumb');
    await tester.tap(find.text('Workspace'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<NibBreadcrumb>(find.byType(NibBreadcrumb)).items.length,
      1,
    );
    expect(find.text('Current folder: Workspace'), findsOneWidget);
    await tester.tap(find.text('Restore full path'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<NibBreadcrumb>(find.byType(NibBreadcrumb)).items.length,
      4,
    );
  });

  testWidgets('pagination changes content and clamps the host page', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    final update = await mount(tester, 'pagination');
    await tester.tap(find.bySemanticsLabel('Next page'));
    await tester.pump();
    expect(find.text('Field notes · page 2'), findsOneWidget);
    expect(find.text('Note 4 · Local demo item'), findsOneWidget);
    update(initial('pagination').change('value', 1));
    await tester.pump();
    expect(
      tester.widget<NibPagination>(find.byType(NibPagination)).currentPage,
      1,
    );
    semantics.dispose();
  });

  for (final width in [360.0, 390.0, 768.0, 1024.0, 1440.0]) {
    testWidgets('all ten families fit width $width and dispose cleanly', (
      tester,
    ) async {
      for (final guide in layoutComponentGuides) {
        await mount(tester, guide.id, width: width);
        expect(tester.takeException(), isNull, reason: '${guide.id} at $width');
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
        expect(
          tester.takeException(),
          isNull,
          reason: '${guide.id} after disposal',
        );
        expect(tester.binding.transientCallbackCount, 0, reason: guide.id);
      }
    });
  }

  testWidgets('all ten families mount under the light package palette', (
    tester,
  ) async {
    for (final guide in layoutComponentGuides) {
      await mount(tester, guide.id, width: 390, light: true);
      expect(tester.takeException(), isNull, reason: guide.id);
      await tester.pumpWidget(const SizedBox());
    }
  });
}
