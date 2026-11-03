/// Test bodies inserted into the isolated copied-app consumer. No website imports.
String? overlayExportContract(String id) => switch (id) {
  'alert-dialog' =>
    r'''
await tester.tap(find.text('Review change'));
await tester.pumpAndSettle();
expect(find.text(expected['text'] as String), findsOneWidget);
await tester.tap(find.text('Apply locally'));
await tester.pumpAndSettle();
expect(find.text('Applied locally'), findsWidgets);
await tester.tap(find.text('Review change'));
await tester.pumpAndSettle();
await tester.tap(find.text('Keep current'));
await tester.pumpAndSettle();
expect(find.text('Kept current label'), findsWidgets);
''',
  'dialog' =>
    r'''
final declared = tester.widget<NibDialog>(find.byType(NibDialog));
expect(declared.title, expected['text']);
expect(declared.animated, expected['animated']);
expect(declared.animation.name, expected['variant']);
expect(declared.size.name, expected['backdrop']);
expect(declared.barrierDismissible, expected['interactive']);
for (final trigger in ['Open dialog', 'Open with handle', 'Open controlled']) {
  await tester.tap(find.text(trigger));
  await tester.pumpAndSettle();
  expect(find.text(expected['text'] as String), findsOneWidget);
  await tester.tap(find.text('Use this title'));
  await tester.pumpAndSettle();
  expect(find.text(trigger == 'Open controlled' ? 'Controlled dialog closed' : 'Draft selected'), findsWidgets);
}
''',
  'bottom-sheet' =>
    r'''
final declared = tester.widget<NibBottomSheet>(find.byType(NibBottomSheet));
expect(declared.title, expected['text']);
expect(declared.snapPoints, [(expected['value'] as num).clamp(30,60)/100, .85]);
expect(declared.animated, expected['animated']);
expect(declared.dismissible, expected['interactive']);
expect(declared.showDragHandle, expected['showBorder']);
for (final trigger in ['Open sheet', 'Open sheet handle', 'Open controlled sheet']) {
  await tester.tap(find.text(trigger));
  await tester.pumpAndSettle();
  final before = tester.getTopLeft(find.text(expected['text'] as String)).dy;
  await tester.tap(find.text('Expand sheet'));
  await tester.pumpAndSettle();
  expect(tester.getTopLeft(find.text(expected['text'] as String)).dy, lessThan(before));
  await tester.tap(find.text('Use reading list'));
  await tester.pumpAndSettle();
  expect(find.text(trigger == 'Open controlled sheet' ? 'Controlled sheet closed' : 'Reading list selected'), findsWidgets);
}
''',
  'popover' =>
    r'''
final popover = tester.widget<NibPopover>(find.byType(NibPopover));
expect(popover.placement.name, expected['variant']);
expect(popover.maxWidth, expected['value']);
expect(popover.showArrow, expected['showBorder']);
expect(popover.dismissOnOutsideTap, expected['interactive']);
expect(popover.animated, expected['animated']);
await tester.tap(find.text('Choose a tag'));
await tester.pumpAndSettle();
expect(find.text(expected['text'] as String), findsOneWidget);
await tester.tap(find.text('Pick Flutter'));
await tester.pumpAndSettle();
expect(find.text('Tag: Flutter'), findsOneWidget);
expect(find.text(expected['text'] as String), findsNothing);
''',
  'hover-card' =>
    r'''
final hover = tester.widget<NibHoverCard>(find.byType(NibHoverCard));
expect(hover.placement.name, expected['variant']);
expect(hover.showDelay.inMilliseconds, (expected['value'] as num).round());
expect(hover.animated, expected['animated']);
await tester.tap(find.text('Inspect contributor'));
await tester.pumpAndSettle();
expect(find.text(expected['text'] as String), findsOneWidget);
await tester.tap(find.text('Close profile'));
await tester.pumpAndSettle();
expect(find.text(expected['text'] as String), findsNothing);
expect(find.text('Profile closed'), findsWidgets);
''',
  'context-menu' =>
    r'''
final menu = tester.widget<NibContextMenu>(find.byType(NibContextMenu));
expect(menu.animated, expected['animated']);
expect((menu.items[1] as NibMenuItem).enabled, !(expected['disabled'] as bool));
await tester.tap(find.text('Open menu'));
await tester.pumpAndSettle();
if (expected['disabled'] == true) {
  await tester.tap(find.text('Pin note'));
  await tester.pumpAndSettle();
  expect(find.text('No menu action'), findsOneWidget);
}
await tester.tap(find.text('Move to'));
await tester.pumpAndSettle();
await tester.tap(find.text('Later'));
await tester.pumpAndSettle();
expect(find.text('Selected: Later'), findsWidgets);
''',
  'command-palette' =>
    r'''
final palette = tester.widget<NibCommandPalette>(find.byType(NibCommandPalette));
expect(palette.placeholder, expected['text']);
expect(palette.animated, expected['animated']);
expect(palette.showRecent, expected['multiple']);
expect(palette.actions.first.disabled, expected['disabled']);
expect(palette.filter == null, expected['searchable']);
await tester.tap(find.text('Open commands'));
await tester.pumpAndSettle();
await tester.enterText(find.byType(TextField), 'Choose');
await tester.pumpAndSettle();
expect(find.text('Create draft'), findsNothing);
await tester.tap(find.text('Choose folder'));
await tester.pumpAndSettle();
await tester.tap(find.text('Later folder'));
await tester.pumpAndSettle();
expect(find.text('Folder: Later'), findsOneWidget);
expect(palette.controller!.recentActionIds, contains('later'));
''',
  'toast' =>
    r'''
await tester.tap(find.text('Save locally'));
await tester.pumpAndSettle();
expect(find.text(expected['text'] as String), findsOneWidget);
expect(find.text('Local save 1'), findsOneWidget);
await tester.tap(find.text('Save locally'));
await tester.pumpAndSettle();
expect(find.text(expected['multiple'] == true ? 'Local save 2' : 'Local save 1'), findsOneWidget);
await tester.tap(find.text('Undo save'));
await tester.pumpAndSettle();
expect(find.text('Save undone'), findsOneWidget);
expect(find.text(expected['text'] as String), findsNothing);
await tester.tap(find.text('Save locally'));
await tester.pumpAndSettle();
await tester.tap(find.text('Dismiss this toast'));
await tester.pumpAndSettle();
expect(find.text(expected['text'] as String), findsNothing);
await tester.tap(find.text('Save locally'));
await tester.pumpAndSettle();
await tester.tap(find.text('Dismiss all toasts'));
await tester.pumpAndSettle();
expect(find.text(expected['text'] as String), findsNothing);
''',
  _ => null,
};
