/// Executed inside each isolated copied-example widget test.
/// The host provides tester, expected settings, and runtime().
String? layoutExportContract(String id) => switch (id) {
  'accordion' =>
    r'''
final accordion = tester.widget<NibAccordion>(find.byType(NibAccordion));
expect(accordion.allowMultipleOpen, expected['multiple']);
expect(accordion.animated, expected['animated']);
expect(accordion.items[1].enabled, !(expected['disabled'] as bool));
expect(find.text(expected['text'] as String), findsOneWidget);
await tester.tap(find.text('Open first'));
await tester.pump(const Duration(milliseconds: 350));
expect(accordion.controller!.openIndices, {0});
expect(find.text('Open sections: 1'), findsOneWidget);
await tester.tap(find.text('Close all'));
await tester.pump(const Duration(milliseconds: 350));
expect(accordion.controller!.openIndices, isEmpty);
''',
  'card' =>
    r'''
if (expected['variant'] == 'flip') {
  var card = tester.widget<NibFlipCard>(find.byType(NibFlipCard));
  expect(card.duration!.inMilliseconds, (expected['value'] as num).round().clamp(0, 1200));
  expect(card.flipAxis, expected['vertical'] == true ? Axis.vertical : Axis.horizontal);
  expect(card.tappable, expected['disabled'] != true && expected['interactive'] == true);
  runtime().onChanged(runtime().settings.change('disabled', false).change('interactive', true));
  await tester.pump();
  await tester.tap(find.text(expected['text'] as String));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1400));
  card = tester.widget<NibFlipCard>(find.byType(NibFlipCard));
  expect(card.isFlipped, isTrue);
  expect(find.text('Requested face: back'), findsOneWidget);
} else {
  var card = tester.widget<NibCard>(find.byType(NibCard));
  expect(card.animated, expected['animated']);
  expect(card.disabled, expected['disabled']);
  expect(card.interactive, expected['interactive']);
  runtime().onChanged(runtime().settings.change('disabled', false).change('interactive', true));
  await tester.pump();
  await tester.tap(find.text(expected['text'] as String));
  await tester.pump(const Duration(milliseconds: 350));
  expect(find.text('Card activations: 1'), findsOneWidget);
}
''',
  'carousel' =>
    r'''
final carousel = tester.widget<NibCarousel>(find.byType(NibCarousel));
expect(carousel.peekExtent, (expected['value'] as num).clamp(0, 40));
expect(carousel.loop, expected['multiple']);
expect(carousel.autoPlay, expected['animated']);
expect(carousel.animated, expected['animated']);
expect(carousel.indicatorStyle.name, ['line', 'none'].contains(expected['variant']) ? expected['variant'] : 'dots');
await tester.tap(find.text('Next slide'));
await tester.pump();
await tester.pump(const Duration(milliseconds: 400));
expect(carousel.controller!.page, 1);
expect(find.descendant(of: find.byType(runtime().runtimeType), matching: find.text('Slide 2 of 3')), findsOneWidget);
await tester.tap(find.text('Previous slide'));
await tester.pump();
await tester.pump(const Duration(milliseconds: 400));
expect(carousel.controller!.page, 0);
expect(carousel.items.length, 3);
if (expected['animated'] == true) {
  await tester.pump(const Duration(seconds: 4));
  await tester.pump(const Duration(milliseconds: 400));
  expect(carousel.controller!.page, 1);
  await tester.tap(find.text('Pause carousel'));
  await tester.pump();
  expect(tester.widget<NibCarousel>(find.byType(NibCarousel)).autoPlay, isFalse);
  await tester.pump(const Duration(seconds: 8));
  expect(carousel.controller!.page, 1);
}
''',
  'tabs' =>
    r'''
final tabs = tester.widget<NibTabs>(find.byType(NibTabs));
expect(tabs.panelGap, (expected['value'] as num).clamp(0, 40));
expect(tabs.scrollable, expected['searchable']);
expect(tabs.swipeable, expected['interactive']);
expect(tabs.animated, expected['animated']);
await tester.tap(find.text('Animate to notes'));
await tester.pumpAndSettle();
expect(tabs.controller!.index, 1);
expect(find.text('Selected tab: Notes'), findsOneWidget);
await tester.tap(find.text('Jump to overview'));
await tester.pumpAndSettle();
expect(tabs.controller!.index, 0);
''',
  'data-table' =>
    r'''
final tableFinder = find.byWidgetPredicate((widget) => widget is NibDataTable);
final configuredTable = tester.widget(tableFinder) as NibDataTable;
expect(configuredTable.rowHeight, (expected['value'] as num).clamp(44, 72));
expect(configuredTable.animated, expected['animated']);
expect(configuredTable.selectionMode.name, ['none', 'multi'].contains(expected['variant']) ? expected['variant'] : 'single');
runtime().onChanged(runtime().settings.change('text', '').change('variant', 'single'));
await tester.pump(const Duration(milliseconds: 350));
await tester.tap(find.text('Tasks'));
await tester.pump(const Duration(milliseconds: 350));
expect(find.text('Selected rows: 0 · Sort: ascending'), findsOneWidget);
expect(tester.getTopLeft(find.text('Dune')).dy, lessThan(tester.getTopLeft(find.text('Atlas')).dy));
await tester.tap(find.text('Birch'));
await tester.pump();
expect(find.text('Selected rows: 1 · Sort: ascending'), findsOneWidget);
await tester.tap(find.text('Clear selection'));
await tester.pump();
expect(find.text('Selected rows: 0 · Sort: ascending'), findsOneWidget);
''',
  'resizable-panels' =>
    r'''
final group = tester.widget<NibResizablePanels>(find.byType(NibResizablePanels));
expect(group.direction, expected['vertical'] == true ? Axis.vertical : Axis.horizontal);
expect(group.animated, expected['animated']);
final controller = group.controller!;
final original = List<double>.of(controller.sizes);
expect(original.first, closeTo((expected['value'] as num).clamp(20, 80) / 100, .000001));
final handle = find.byType(NibResizablePanelsHandle);
expect(handle, findsOneWidget);
final delta = original.first <= .5 ? 40.0 : -40.0;
await tester.drag(handle, group.direction == Axis.horizontal ? Offset(delta, 0) : Offset(0, delta));
await tester.pump(const Duration(milliseconds: 350));
expect((controller.sizes.first - original.first).abs(), greaterThan(.001));
expect(controller.sizes.reduce((a,b) => a+b), closeTo(1, .000001));
await tester.ensureVisible(find.text('Reset split'));
await tester.tap(find.text('Reset split'));
await tester.pump(const Duration(milliseconds: 350));
expect(controller.sizes.first, closeTo(original.first, .000001));
''',
  'loader' =>
    r'''
final loader = tester.widget<NibCircularLoader>(find.byType(NibCircularLoader));
expect(loader.size, (expected['value'] as num).clamp(32, 96));
expect(loader.strokeWidth, (expected['radius'] as num).clamp(2, 12));
expect(TickerMode.valuesOf(tester.element(find.byType(NibCircularLoader))).enabled, expected['animated']);
await tester.tap(find.text(expected['animated'] == true ? 'Pause indicator' : 'Run indicator'));
await tester.pump(const Duration(milliseconds: 100));
expect(TickerMode.valuesOf(tester.element(find.byType(NibCircularLoader))).enabled, expected['animated'] != true);
runtime().onChanged(runtime().settings.change('animated', false));
await tester.pump();
expect(find.descendant(of: find.byType(runtime().runtimeType), matching: find.text('Indicator paused')), findsOneWidget);
''',
  'skeleton' =>
    r'''
final skeleton = tester.widget<NibSkeleton>(find.byType(NibSkeleton));
expect(skeleton.animated, expected['animated']);
expect(skeleton.borderRadius!.topLeft.x, expected['radius']);
expect(skeleton.loading, isTrue);
expect(find.text('FIELD NOTES'), findsOneWidget);
await tester.tap(find.text('Reveal content'));
await tester.pump();
await tester.pump(const Duration(milliseconds: 500));
expect(tester.widget<NibSkeleton>(find.byType(NibSkeleton)).loading, isFalse);
expect(find.text(expected['text'] as String), findsOneWidget);
final bone = tester.widget<NibSkeletonBone>(find.byType(NibSkeletonBone));
expect(bone.shape, expected['variant'] == 'circle' ? NibSkeletonShape.circle : NibSkeletonShape.rectangle);
''',
  'breadcrumb' =>
    r'''
final breadcrumb = tester.widget<NibBreadcrumb>(find.byType(NibBreadcrumb));
expect(breadcrumb.maxVisibleItems, (expected['value'] as num).round().clamp(2, 4));
expect(breadcrumb.disabled, expected['disabled']);
expect(breadcrumb.animated, expected['animated']);
runtime().onChanged(runtime().settings.change('disabled', false));
await tester.pump();
await tester.tap(find.text('Workspace'));
await tester.pumpAndSettle();
expect(tester.widget<NibBreadcrumb>(find.byType(NibBreadcrumb)).items.length, 1);
expect(find.text('Current folder: Workspace'), findsOneWidget);
await tester.tap(find.text('Restore full path'));
await tester.pumpAndSettle();
expect(tester.widget<NibBreadcrumb>(find.byType(NibBreadcrumb)).items.length, 4);
''',
  'pagination' =>
    r'''
final pagination = tester.widget<NibPagination>(find.byType(NibPagination));
expect(pagination.totalPages, (expected['value'] as num).round().clamp(1, 30));
expect(pagination.disabled, expected['disabled']);
expect(pagination.showFirstLast, expected['multiple']);
expect(pagination.variant.name, expected['variant'] == 'compact' ? 'compact' : 'numbered');
runtime().onChanged(runtime().settings.change('disabled', false).change('value', 6.0));
await tester.pump();
final next = find.byWidgetPredicate((widget) => widget is NibButton && widget.semanticLabel == 'Next page');
await tester.tap(next);
await tester.pump(const Duration(milliseconds: 350));
expect(tester.widget<NibPagination>(find.byType(NibPagination)).currentPage, 2);
expect(find.text('Note 4 · Local demo item'), findsOneWidget);
''',
  _ => null,
};
