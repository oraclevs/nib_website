import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_components/nib_components.dart';
import 'package:nib_ember_living/components/component_preview.dart';
import 'package:nib_ember_living/components/component_settings.dart';

class _PreviewHarness extends StatefulWidget {
  const _PreviewHarness({super.key});
  @override
  State<_PreviewHarness> createState() => _PreviewHarnessState();
}

class _PreviewHarnessState extends State<_PreviewHarness> {
  final dialogFocus = FocusNode(debugLabel: 'demo-dialog-trigger');
  final sheetFocus = FocusNode(debugLabel: 'demo-sheet-trigger');
  final popoverFocus = FocusNode(debugLabel: 'demo-popover-trigger');
  final popover = NibPopoverController();
  final results = <Object?>[];
  NibDialogHandle<String>? dialog;
  NibBottomSheetHandle<String>? sheet;
  OverlayState? nearestOverlay;
  OverlayState? furthestOverlay;
  int outsideClicks = 0;
  bool visible = true;
  bool edgeTrigger = false;
  int accent = 0xFFFFB51B;

  void moveTriggerToEdge() => setState(() => edgeTrigger = true);
  void removePreview() {
    dialog?.close();
    sheet?.close();
    setState(() => visible = false);
  }

  void changeAccent(int color) => setState(() => accent = color);

  @override
  void dispose() {
    dialog?.close();
    sheet?.close();
    dialogFocus.dispose();
    sheetFocus.dispose();
    popoverFocus.dispose();
    popover.dispose();
    super.dispose();
  }

  Widget _body(String kind) => Builder(
    builder: (context) {
      final theme = NibTheme.of(context);
      return Column(
        key: ValueKey('$kind-body'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$kind content', style: TextStyle(color: theme.primary)),
          const SizedBox(height: 10),
          NibButton(
            label: 'Finish $kind',
            onPressed: () {
              if (kind == 'dialog') {
                NibDialogScope.of(context).close('dialog result');
              } else if (kind == 'sheet') {
                NibBottomSheetScope.of(context).close('sheet result');
              } else {
                NibPopoverScope.of(context).close();
              }
            },
          ),
        ],
      );
    },
  );

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData.light().copyWith(extensions: const [NibTheme.light]),
    home: Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 20,
            top: 20,
            child: FilledButton(
              onPressed: () => setState(() => outsideClicks++),
              child: Text('Outside site button: $outsideClicks'),
            ),
          ),
          if (visible)
            Positioned(
              left: 400,
              top: 120,
              width: 360,
              child: ComponentPreview(
                key: const ValueKey('preview'),
                height: 340,
                settings: ComponentSettings(accent: accent),
                child: Builder(
                  builder: (context) {
                    nearestOverlay = Overlay.of(context);
                    furthestOverlay = Overlay.of(context, rootOverlay: true);
                    return Column(
                      crossAxisAlignment: edgeTrigger
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        NibButton(
                          label: 'Open dialog',
                          focusNode: dialogFocus,
                          onPressed: () {
                            dialogFocus.requestFocus();
                            dialog = openNibDialog<String>(
                              context,
                              title: 'Local dialog',
                              content: _body('dialog'),
                            );
                            dialog!.closed.then(results.add);
                          },
                        ),
                        const SizedBox(height: 12),
                        NibButton(
                          label: 'Open sheet',
                          focusNode: sheetFocus,
                          onPressed: () {
                            sheetFocus.requestFocus();
                            sheet = openNibBottomSheet<String>(
                              context,
                              title: 'Local sheet',
                              content: _body('sheet'),
                            );
                            sheet!.closed.then(results.add);
                          },
                        ),
                        const SizedBox(height: 12),
                        Focus(
                          focusNode: popoverFocus,
                          child: NibPopover(
                            controller: popover,
                            trigger: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Text('Open popover'),
                            ),
                            content: _body('popover'),
                            maxWidth: 250,
                            semanticLabel: 'Open popover',
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

Future<GlobalKey<_PreviewHarnessState>> _mount(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1000, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final key = GlobalKey<_PreviewHarnessState>();
  await tester.pumpWidget(_PreviewHarness(key: key));
  await tester.pumpAndSettle();
  return key;
}

Finder _card(String kind) => find
    .ancestor(
      of: find.byKey(ValueKey('$kind-body')),
      matching: find.byType(Material),
    )
    .first;

void _inside(WidgetTester tester, Finder child, Rect bounds) {
  final rect = tester.getRect(child);
  expect(rect.left, greaterThanOrEqualTo(bounds.left - .1));
  expect(rect.right, lessThanOrEqualTo(bounds.right + .1));
  expect(rect.top, greaterThanOrEqualTo(bounds.top - .1));
  expect(rect.bottom, lessThanOrEqualTo(bounds.bottom + .1));
}

void main() {
  testWidgets(
    'root helper lookup reaches page while anchored lookup stays local',
    (tester) async {
      final key = await _mount(tester);
      expect(
        identical(
          key.currentState!.nearestOverlay,
          key.currentState!.furthestOverlay,
        ),
        isFalse,
      );
      final outer = tester
          .state<NavigatorState>(find.byType(Navigator).first)
          .overlay;
      expect(identical(outer, key.currentState!.furthestOverlay), isTrue);
    },
  );

  testWidgets('popover fits a trigger near the local preview edge', (
    tester,
  ) async {
    final key = await _mount(tester);
    key.currentState!.moveTriggerToEdge();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open popover'));
    await tester.pumpAndSettle();
    _inside(
      tester,
      _card('popover'),
      tester.getRect(find.byKey(const ValueKey('preview'))),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('preview preserves the Flutter View required for actual typing', (
    tester,
  ) async {
    String? value;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ComponentPreview(
            settings: const ComponentSettings(),
            child: NibInput(
              label: 'Preview text',
              onChanged: (text) => value = text,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.enterText(find.byType(TextField), 'Editing works');
    await tester.pump();
    expect(value, 'Editing works');
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Editing works',
    );
    expect(tester.takeException(), isNull);
  });

  for (final kind in ['dialog', 'sheet', 'popover']) {
    testWidgets(
      '$kind follows its local or page-modal bounds with captured theme',
      (tester) async {
        final key = await _mount(tester);
        final bounds = tester.getRect(find.byKey(const ValueKey('preview')));
        if (kind == 'popover') {
          key.currentState!.popoverFocus.requestFocus();
          await tester.pump();
        }
        await tester.tap(find.text('Open $kind'));
        await tester.pumpAndSettle();
        expect(find.byKey(ValueKey('$kind-body')), findsOneWidget);
        _inside(
          tester,
          _card(kind),
          kind == 'popover' ? bounds : const Rect.fromLTWH(0, 0, 1000, 800),
        );
        final text = tester.widget<Text>(find.text('$kind content'));
        expect(text.style!.color, const Color(0xFFFFB51B));
        expect(
          tester.widget<Material>(_card(kind)).color,
          const Color(0xFF1B1D19),
        );
        await tester.tapAt(
          tester.getCenter(find.text('Outside site button: 0')),
        );
        await tester.pumpAndSettle();
        if (kind == 'popover') {
          expect(key.currentState!.outsideClicks, 1);
          expect(find.byKey(ValueKey('$kind-body')), findsOneWidget);
        } else {
          expect(key.currentState!.outsideClicks, 0);
          expect(find.byKey(ValueKey('$kind-body')), findsNothing);
          expect(key.currentState!.results, [null]);
          await tester.tap(find.text('Open $kind'));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.text('Finish $kind'));
        await tester.pumpAndSettle();
        expect(find.byKey(ValueKey('$kind-body')), findsNothing);
        if (kind != 'popover') {
          expect(key.currentState!.results, [null, '$kind result']);
        }
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('$kind Escape closes and returns focus to the local opener', (
      tester,
    ) async {
      final key = await _mount(tester);
      final focus = switch (kind) {
        'dialog' => key.currentState!.dialogFocus,
        'sheet' => key.currentState!.sheetFocus,
        _ => key.currentState!.popoverFocus,
      };
      focus.requestFocus();
      await tester.pump();
      await tester.tap(find.text('Open $kind'));
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey('$kind-body')), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey('$kind-body')), findsNothing);
      expect(focus.hasFocus, isTrue);
      if (kind != 'popover') expect(key.currentState!.results, [null]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('$kind preview owner closes its surface before disposal', (
      tester,
    ) async {
      final key = await _mount(tester);
      await tester.tap(find.text('Open $kind'));
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey('$kind-body')), findsOneWidget);
      key.currentState!.removePreview();
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey('$kind-body')), findsNothing);
      expect(find.byType(ComponentPreview), findsNothing);
      await tester.tap(find.text('Outside site button: 0'));
      await tester.pump();
      expect(key.currentState!.outsideClicks, 1);
      await tester.pumpAndSettle();
      expect(tester.binding.transientCallbackCount, 0);
      expect(tester.takeException(), isNull);
    });
  }
}
