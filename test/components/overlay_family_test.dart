import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_components/nib_components.dart';
import 'package:nib_ember_living/components/component_preview.dart';
import 'package:nib_ember_living/components/component_catalog.dart';
import 'package:nib_ember_living/components/guides/overlay_family_guides.dart';
import 'package:nib_ember_living/components/component_settings.dart';
import 'package:nib_ember_living/components/examples/overlay_family_demos.dart';

typedef _BuildDemo = Widget Function(
  ComponentSettings settings,
  ValueChanged<ComponentSettings> change,
  ValueChanged<String> event,
);

Future<List<String>> _mount(
  WidgetTester tester,
  _BuildDemo demo, {
  ComponentSettings settings = const ComponentSettings(),
  double width = 660,
  double textScale = 1,
}) async {
  tester.view.physicalSize = const Size(1000, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final events = <String>[];
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: ComponentPreview(
              height: 560,
              settings: settings,
              child: demo(settings, (_) {}, events.add),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return events;
}

Future<void> _tap(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> _dispose(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 3));
  expect(tester.takeException(), isNull);
  expect(tester.binding.transientCallbackCount, 0);
}

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;
  testWidgets(
    'alert returns confirm, cancel, and null dismissal with inherited theme',
    (tester) async {
      final events = await _mount(
        tester,
        (s, c, e) =>
            AlertDialogComponentDemo(settings: s, onChanged: c, onEvent: e),
        settings: const ComponentSettings(
          text: 'Local label',
          variant: 'error',
        ),
        width: 360,
      );
      await _tap(tester, 'Review change');
      expect(find.text('Local label'), findsOneWidget);
      final action = tester.widget<NibButton>(
        find.widgetWithText(NibButton, 'Apply locally'),
      );
      expect(action.variant, NibButtonVariant.destructive);
      expect(
        NibTheme.of(tester.element(find.text('Apply locally'))).background,
        const Color(0xFF111210),
      );
      await _tap(tester, 'Apply locally');
      expect(find.text('Applied locally'), findsOneWidget);
      await _tap(tester, 'Review change');
      await _tap(tester, 'Keep current');
      expect(find.text('Kept current label'), findsOneWidget);
      await _tap(tester, 'Review change');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Dismissed without a decision'), findsOneWidget);
      expect(events, [
        'Applied locally',
        'Kept current label',
        'Dismissed without a decision',
      ]);
      await _dispose(tester);
    },
  );

  testWidgets('dialog Future, handle, controller and scoped result all work', (
    tester,
  ) async {
    await _mount(
      tester,
      (s, c, e) => DialogComponentDemo(settings: s, onChanged: c, onEvent: e),
      settings: const ComponentSettings(
        animated: true,
        variant: 'slideUp',
        backdrop: 'sm',
        text: 'Draft',
      ),
      width: 360,
    );
    for (final trigger in [
      'Open dialog',
      'Open with handle',
      'Open controlled',
    ]) {
      await _tap(tester, trigger);
      expect(find.text('Draft'), findsOneWidget);
      await _tap(tester, 'Use this title');
      expect(
        find.text(
          trigger == 'Open controlled'
              ? 'Controlled dialog closed'
              : 'Draft selected',
        ),
        findsOneWidget,
      );
    }
    await _tap(tester, 'Open with handle');
    await _dispose(tester);
  });

  testWidgets(
    'sheet Future, handle, controller and expansion preserve result',
    (tester) async {
      final events = await _mount(
        tester,
        (s, c, e) =>
            BottomSheetComponentDemo(settings: s, onChanged: c, onEvent: e),
        settings: const ComponentSettings(
          animated: true,
          value: 45,
          text: 'Reading list',
        ),
        width: 360,
      );
      for (final trigger in [
        'Open sheet',
        'Open sheet handle',
        'Open controlled sheet',
      ]) {
        await _tap(tester, trigger);
        final before = tester.getTopLeft(find.text('Reading list')).dy;
        await _tap(tester, 'Expand sheet');
        final after = tester.getTopLeft(find.text('Reading list')).dy;
        expect(after, lessThan(before - 80));
        await _tap(tester, 'Use reading list');
        expect(
          find.text(
            trigger == 'Open controlled sheet'
                ? 'Controlled sheet closed'
                : 'Reading list selected',
          ),
          findsOneWidget,
        );
      }
      expect(events, contains('Requested snap 1'));
      await _tap(tester, 'Open sheet handle');
      await _dispose(tester);
    },
  );

  test(
    'public snap and dialog resolver semantics match their numeric contracts',
    () {
      expect(normalizeSnapExtents([.8, .2, .8, -1, 2]), [.05, .2, .8, 1]);
      expect(normalizeSnapExtents([]), isNull);
      expect(kNibSheetMinExtent, .05);
      expect(kNibSheetFlingVelocity, 2);
      expect(clampInitialSnapIndex(3, null), 2);
      expect(clampInitialSnapIndex(3, -1), 0);
      expect(
        resolveSnapTarget(
          currentExtent: .4,
          extents: [.4, .8],
          velocity: 3,
          dismissible: true,
        ),
        1,
      );
      expect(
        resolveSnapTarget(
          currentExtent: .4,
          extents: [.4, .8],
          velocity: -3,
          dismissible: true,
        ),
        isNull,
      );
      expect(
        resolveSnapTarget(
          currentExtent: .4,
          extents: [.4, .8],
          velocity: -3,
          dismissible: false,
        ),
        0,
      );
      expect(nibDialogMaxWidth(NibDialogSize.sm), 380);
      expect(nibDialogMaxWidth(NibDialogSize.fullscreen), isNull);
      expect(resolveNibDialogEnter(NibDialogAnimation.slideUp).y, 16);
      expect(resolveNibDialogEnter(NibDialogAnimation.fadeScale).scale, .97);
    },
  );

  testWidgets(
    'popover anchored choice closes through scope and removes on disposal',
    (tester) async {
      await _mount(
        tester,
        (s, c, e) =>
            PopoverComponentDemo(settings: s, onChanged: c, onEvent: e),
        settings: const ComponentSettings(
          text: 'Reading tags',
          value: 240,
          variant: 'end',
          animated: true,
        ),
        width: 360,
      );
      await _tap(tester, 'Choose a tag');
      expect(find.text('Reading tags'), findsOneWidget);
      await _tap(tester, 'Pick Flutter');
      expect(find.text('Tag: Flutter'), findsOneWidget);
      expect(find.text('Reading tags'), findsNothing);
      await _tap(tester, 'Choose a tag');
      await _dispose(tester);
    },
  );

  testWidgets('hover delay is real and explicit controls work without hover', (
    tester,
  ) async {
    await _mount(
      tester,
      (s, c, e) =>
          HoverCardComponentDemo(settings: s, onChanged: c, onEvent: e),
      settings: const ComponentSettings(
        text: 'Ada',
        value: 500,
        variant: 'bottom',
      ),
      width: 360,
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.text('Inspect contributor')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Ada'), findsNothing);
    await tester.pump(const Duration(milliseconds: 101));
    await tester.pump();
    expect(find.text('Ada'), findsOneWidget);
    await mouse.moveTo(Offset.zero);
    await tester.pump(const Duration(milliseconds: 301));
    await tester.pumpAndSettle();
    expect(find.text('Ada'), findsNothing);
    await mouse.removePointer();
    await _tap(tester, 'Inspect contributor');
    await _tap(tester, 'Close profile');
    expect(find.text('Ada'), findsNothing);
    await _tap(tester, 'Inspect contributor');
    await _dispose(tester);
  });

  testWidgets(
    'context menu helper and wrapper select real nested and disabled entries',
    (tester) async {
      final events = await _mount(
        tester,
        (s, c, e) =>
            ContextMenuComponentDemo(settings: s, onChanged: c, onEvent: e),
        settings: const ComponentSettings(text: 'A note', disabled: true),
        width: 360,
      );
      await _tap(tester, 'Open menu');
      await _tap(tester, 'Pin note');
      expect(events, isEmpty);
      await _tap(tester, 'Move to');
      await _tap(tester, 'Later');
      expect(find.text('Selected: Later'), findsOneWidget);
      await tester.longPress(find.text('A note'));
      await tester.pumpAndSettle();
      expect(find.text('Pin note'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Pin note'), findsNothing);
      await _dispose(tester);
    },
  );

  testWidgets(
    'command search, leaf callback, drill-down and recent controller state work',
    (tester) async {
      await _mount(
        tester,
        (s, c, e) =>
            CommandPaletteComponentDemo(settings: s, onChanged: c, onEvent: e),
        settings: const ComponentSettings(
          text: 'Search local commands',
          multiple: true,
        ),
        width: 360,
      );
      await _tap(tester, 'Open commands');
      await tester.enterText(find.byType(TextField), 'Create');
      await tester.pumpAndSettle();
      expect(find.text('Choose folder'), findsNothing);
      await _tap(tester, 'Create draft');
      expect(find.text('Drafts: 1'), findsOneWidget);
      await _tap(tester, 'Open commands');
      final palette = tester.widget<NibCommandPalette>(
        find.byType(NibCommandPalette),
      );
      expect(palette.controller!.recentActionIds, ['new-draft']);
      await _tap(tester, 'Choose folder');
      await _tap(tester, 'Later folder');
      expect(find.text('Folder: Later'), findsOneWidget);
      await _tap(tester, 'Open commands');
      await _dispose(tester);
    },
  );

  testWidgets(
    'toast duplicates replace content, undo, targeted and global dismiss work',
    (tester) async {
      await _mount(
        tester,
        (s, c, e) => ToastComponentDemo(settings: s, onChanged: c, onEvent: e),
        settings: const ComponentSettings(
          text: 'Saved',
          value: 0,
          variant: 'success',
          backdrop: 'bottomCenter',
          multiple: true,
        ),
        width: 440,
      );
      await _tap(tester, 'Save locally');
      expect(find.text('Local save 1'), findsOneWidget);
      await _tap(tester, 'Save locally');
      expect(find.text('Local save 2'), findsOneWidget);
      expect(find.text('Local save 1'), findsNothing);
      await _tap(tester, 'Undo save');
      expect(find.text('Save undone'), findsOneWidget);
      expect(find.text('Local save 2'), findsNothing);
      await _tap(tester, 'Save locally');
      await _tap(tester, 'Dismiss this toast');
      expect(find.text('Local save 3'), findsNothing);
      await _tap(tester, 'Save locally');
      await _tap(tester, 'Dismiss all toasts');
      expect(find.text('Local save 4'), findsNothing);
      await _tap(tester, 'Save locally');
      await _dispose(tester);
    },
  );
  testWidgets('hover card end preference stays within its local preview', (
    tester,
  ) async {
    await _mount(
      tester,
      (s, c, e) =>
          HoverCardComponentDemo(settings: s, onChanged: c, onEvent: e),
      settings: const ComponentSettings(text: 'Ada', variant: 'end', value: 0),
      width: 360,
    );
    await _tap(tester, 'Inspect contributor');
    final bounds = tester.getRect(find.byType(ComponentPreview));
    final card = tester.getRect(
      find
          .ancestor(of: find.text('Ada'), matching: find.byType(Material))
          .first,
    );
    expect(card.left, greaterThanOrEqualTo(bounds.left));
    expect(card.right, lessThanOrEqualTo(bounds.right));
    expect(card.top, greaterThanOrEqualTo(bounds.top));
    expect(card.bottom, lessThanOrEqualTo(bounds.bottom));
    await _tap(tester, 'Close profile');
    await _dispose(tester);
  });

  test(
    'public severity and toast extensions retain their documented mappings',
    () {
      expect(
        NibAlertSeverity.error.accent(NibTheme.dark),
        NibTheme.dark.destructive,
      );
      expect(
        NibAlertSeverity.success.defaultIcon(),
        Icons.check_circle_rounded,
      );
      expect(NibToastVariant.normal.defaultIcon(), isNull);
      expect(
        NibToastVariant.error.accent(NibTheme.dark),
        NibTheme.dark.destructive,
      );
      expect(NibToastPosition.topCenter.isTop, isTrue);
      expect(NibToastPosition.bottomCenter.isTop, isFalse);
      expect(NibToastPosition.bottomRight.alignment, Alignment.bottomRight);
      expect(NibToastPosition.topCenter.enterOffset, const Offset(0, -16));
      expect(NibToastPosition.bottomRight.enterOffset, const Offset(40, 0));
      expect(NibToastDuplicateBehavior.values.map((value) => value.name), [
        'shake',
        'ignore',
        'replace',
      ]);
    },
  );
  for (final guide in overlayComponentGuides) {
    testWidgets('${guide.id} stays usable at 320px and 1.5 text scale', (
      tester,
    ) async {
      await _mount(
        tester,
        (s, c, e) => buildComponentDemo(guide, s, c, e),
        settings: guide.initial,
        width: 320,
        textScale: 1.5,
      );
      final (open, close) = switch (guide.id) {
        'alert-dialog' => ('Review change', 'Keep current'),
        'dialog' => ('Open dialog', 'Use this title'),
        'bottom-sheet' => ('Open sheet', 'Use reading list'),
        'popover' => ('Choose a tag', 'Pick Flutter'),
        'hover-card' => ('Inspect contributor', 'Close profile'),
        'context-menu' => ('Open menu', 'Pin note'),
        'command-palette' => ('Open commands', 'Create draft'),
        'toast' => ('Save locally', 'Undo save'),
        _ => throw StateError(guide.id),
      };
      await _tap(tester, open);
      await _tap(tester, close);
      final result = switch (guide.id) {
        'alert-dialog' => 'Kept current label',
        'dialog' => 'Draft selected',
        'bottom-sheet' => 'Reading list selected',
        'popover' => 'Tag: Flutter',
        'hover-card' => 'Profile closed',
        'context-menu' => 'Selected: Pin note',
        'command-palette' => 'Drafts: 1',
        'toast' => 'Save undone',
        _ => throw StateError(guide.id),
      };
      expect(find.text(result), findsOneWidget);
      await _dispose(tester);
    });
  }
}
