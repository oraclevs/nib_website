import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_components/nib_components.dart';
import 'package:nib_ember_living/components/component_settings.dart';
import 'package:nib_ember_living/components/component_catalog.dart';
import 'package:nib_ember_living/components/component_pages.dart';
import 'package:nib_ember_living/components/component_toggle.dart';
import 'package:nib_ember_living/components/component_theme.dart';
import 'package:nib_ember_living/components/examples/selection_family_demos.dart';
import 'package:nib_ember_living/components/guides/selection_family_guides.dart';

Widget _demo(
  String id,
  ComponentSettings settings,
  ValueChanged<ComponentSettings> changed,
  ValueChanged<String> event,
) => switch (id) {
  'button' => ButtonComponentDemo(
    settings: settings,
    onChanged: changed,
    onEvent: event,
  ),
  'checkbox' => CheckboxComponentDemo(
    settings: settings,
    onChanged: changed,
    onEvent: event,
  ),
  'switch' => SwitchComponentDemo(
    settings: settings,
    onChanged: changed,
    onEvent: event,
  ),
  'radio-group' => RadioGroupComponentDemo(
    settings: settings,
    onChanged: changed,
    onEvent: event,
  ),
  'toggle-group' => ToggleGroupComponentDemo(
    settings: settings,
    onChanged: changed,
    onEvent: event,
  ),
  'slider' => SliderComponentDemo(
    settings: settings,
    onChanged: changed,
    onEvent: event,
  ),
  'select' => SelectComponentDemo(
    settings: settings,
    onChanged: changed,
    onEvent: event,
  ),
  'combobox' => ComboboxComponentDemo(
    settings: settings,
    onChanged: changed,
    onEvent: event,
  ),
  'date-picker' => DatePickerComponentDemo(
    settings: settings,
    onChanged: changed,
    onEvent: event,
  ),
  'otp-input' => OtpInputComponentDemo(
    settings: settings,
    onChanged: changed,
    onEvent: event,
  ),
  _ => throw ArgumentError(id),
};

class _Host extends StatefulWidget {
  const _Host(
    this.id, {
    super.key,
    this.initial,
    this.scale = 1,
    this.reduceMotion = false,
  });
  final String id;
  final ComponentSettings? initial;
  final double scale;
  final bool reduceMotion;
  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late ComponentSettings settings =
      widget.initial ??
      selectionComponentGuides.firstWhere((g) => g.id == widget.id).initial;
  final events = <String>[];
  void change(String key, Object value) =>
      setState(() => settings = settings.change(key, value));
  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: componentEmberTheme(
      accent: settings.accent,
      radius: settings.radius,
    ),
    home: Scaffold(
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(widget.scale),
          disableAnimations: widget.reduceMotion,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: _demo(
            widget.id,
            settings,
            (next) => setState(() => settings = next),
            events.add,
          ),
        ),
      ),
    ),
  );
}

Future<GlobalKey<_HostState>> _mount(
  WidgetTester tester,
  String id, {
  ComponentSettings? initial,
  double width = 700,
  double scale = 1,
  bool reduceMotion = false,
}) async {
  tester.view.physicalSize = Size(width, 850);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final key = GlobalKey<_HostState>();
  await tester.pumpWidget(
    _Host(
      id,
      key: key,
      initial: initial,
      scale: scale,
      reduceMotion: reduceMotion,
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
  return key;
}

Future<void> _tap(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pump();
  await tester.tap(target);
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('button activation, five variants, busy and disabled are real', (
    tester,
  ) async {
    final key = await _mount(tester, 'button');
    await _tap(tester, find.byKey(const ValueKey('button-action')));
    expect(find.text('Activations: 1'), findsOneWidget);
    expect(key.currentState!.events.last, 'Saved locally: 1');
    for (final variant in NibButtonVariant.values) {
      key.currentState!.change('variant', variant.name);
      await tester.pump();
      expect(
        tester
            .widget<NibButton>(find.byKey(const ValueKey('button-action')))
            .variant,
        variant,
      );
    }
    key.currentState!.change('multiple', true);
    await tester.pump();
    await _tap(tester, find.byKey(const ValueKey('button-action')));
    expect(find.text('Activations: 1'), findsOneWidget);
    key.currentState!.change('multiple', false);
    key.currentState!.change('disabled', true);
    await tester.pump();
    await _tap(tester, find.byKey(const ValueKey('button-action')));
    expect(find.text('Activations: 1'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'checkbox emits true mixed false and preserves state on accent update',
    (tester) async {
      final key = await _mount(
        tester,
        'checkbox',
        initial: const ComponentSettings(
          text: 'Include notes',
          value: 0,
          multiple: true,
        ),
      );
      for (final value in [1.0, -1.0, 0.0]) {
        await _tap(tester, find.text('Include notes'));
        expect(key.currentState!.settings.value, value);
      }
      await _tap(tester, find.text('Include notes'));
      key.currentState!.change('accent', 0xFFD4E2A6);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(tester.widget<NibCheckbox>(find.byType(NibCheckbox)).value, true);
      expect(
        NibTheme.of(tester.element(find.byType(NibCheckbox))).primary,
        const Color(0xFFD4E2A6),
      );
      key.currentState!.change('disabled', true);
      await tester.pump();
      await _tap(tester, find.text('Include notes'));
      expect(key.currentState!.settings.value, 1);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'real playground inspector image toggle glides across page rebuild and rapid reversal',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final guide = componentById('switch')!;
      await tester.runAsync(() async {
        for (final path in [
          'lib/components/component_settings.dart',
          'lib/components/component_theme.dart',
          'lib/ember_material_theme.dart',
          guide.demoFile,
        ]) {
          await rootBundle.loadString(path);
        }
      });
      await tester.pumpWidget(
        MaterialApp(
          theme: componentEmberTheme(),
          home: Scaffold(
            body: ComponentGuidePage(
              guide: guide,
              playground: true,
              onNavigate: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final toggle = find.byKey(const ValueKey('component-control-disabled'));
      await tester.ensureVisible(toggle);
      await tester.pumpAndSettle();
      expect(tester.widget<ComponentToggle>(toggle).value, isFalse);
      final image = find.descendant(of: toggle, matching: find.byType(Image));
      double x() => tester.getTopLeft(image).dx;
      final off = x();
      final beforeElement = tester.element(image);
      await tester.tap(toggle);
      await tester.pump();
      expect(tester.element(image), same(beforeElement));
      expect(x(), closeTo(off, .01));
      await tester.pump(const Duration(milliseconds: 40));
      final outward = x();
      expect(outward, greaterThan(off + .1));
      expect(outward, lessThan(off + 19.9));
      await tester.tap(toggle);
      await tester.pump();
      expect(x(), closeTo(outward, .01));
      await tester.pump(const Duration(milliseconds: 40));
      expect(x(), lessThan(outward));
      expect(x(), greaterThanOrEqualTo(off));
      await tester.pumpAndSettle();
      expect(x(), closeTo(off, .01));
      expect(tester.widget<ComponentToggle>(toggle).value, isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
      expect(tester.binding.transientCallbackCount, 0);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'image switch follows reduced motion and disabled input still blocks change',
    (tester) async {
      final key = await _mount(
        tester,
        'switch',
        initial: const ComponentSettings(
          text: 'Reduced switch',
          value: 0,
          variant: 'image-thumb',
          animated: true,
        ),
        reduceMotion: true,
      );
      final image = find.byType(Image);
      final off = tester.getTopLeft(image).dx;
      await tester.tap(find.text('Reduced switch'));
      await tester.pump();
      expect(key.currentState!.settings.value, 1);
      expect(tester.getTopLeft(image).dx, closeTo(off + 28, .01));
      key.currentState!.change('disabled', true);
      await tester.pump();
      await tester.tap(find.text('Reduced switch'));
      await tester.pump();
      expect(key.currentState!.settings.value, 1);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('switch toggles custom thumb and blocks pending changes', (
    tester,
  ) async {
    final key = await _mount(
      tester,
      'switch',
      initial: const ComponentSettings(
        text: 'Updates',
        value: 0,
        variant: 'custom',
      ),
    );
    await _tap(tester, find.text('Updates'));
    expect(key.currentState!.settings.value, 1);
    expect(find.byType(Image), findsOneWidget);
    key.currentState!.change('multiple', true);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await _tap(tester, find.text('Updates'));
    expect(key.currentState!.settings.value, 1);
    expect(tester.takeException(), isNull);
  });
  for (final variant in ['images', 'image-thumb']) {
    testWidgets(
      'switch $variant uses real embedded images and retains loading behavior',
      (tester) async {
        final key = await _mount(
          tester,
          'switch',
          initial: ComponentSettings(
            text: 'Image switch',
            value: 0,
            animated: true,
            variant: variant,
          ),
        );
        await tester.pump(const Duration(milliseconds: 250));
        final initialImage = tester.widget<Image>(find.byType(Image));
        expect(initialImage.image, isA<MemoryImage>());
        expect(initialImage.excludeFromSemantics, isTrue);
        final offBytes = (initialImage.image as MemoryImage).bytes;
        expect(offBytes.length, greaterThan(100));
        final configured = tester.widget<NibSwitch>(find.byType(NibSwitch));
        expect(configured.animated, isTrue);
        expect(configured.thumbBuilder != null, variant == 'image-thumb');
        if (variant == 'images') {
          expect(configured.onThumbIcon, isA<Image>());
          expect(configured.offThumbIcon, isA<Image>());
        }
        await _tap(tester, find.text('Image switch'));
        final onBytes =
            (tester.widget<Image>(find.byType(Image)).image as MemoryImage)
                .bytes;
        expect(onBytes, orderedEquals(offBytes));
        expect(key.currentState!.settings.value, 1);
        key.currentState!.change('multiple', true);
        await tester.pump();
        expect(
          find.byType(Image),
          variant == 'images' ? findsNothing : findsOneWidget,
        );
        await _tap(tester, find.text('Image switch'));
        expect(key.currentState!.settings.value, 1);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 1));
        expect(tester.binding.transientCallbackCount, 0);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'radio keyboard selects next enabled option and custom rows remain actionable',
    (tester) async {
      final key = await _mount(tester, 'radio-group');
      await _tap(tester, find.text('Daily'));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(key.currentState!.settings.text, 'weekly');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(key.currentState!.settings.text, 'daily');
      key.currentState!.change('variant', 'cards');
      await tester.pump();
      await _tap(tester, find.text('Weekly'));
      expect(key.currentState!.settings.text, 'weekly');
      await _tap(tester, find.text('Instant'));
      expect(key.currentState!.settings.text, 'weekly');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'toggle group single deselects and multiple preserves both styles',
    (tester) async {
      final key = await _mount(tester, 'toggle-group');
      await _tap(tester, find.text('Bold'));
      expect(key.currentState!.settings.text, 'bold');
      await _tap(tester, find.text('Bold'));
      expect(key.currentState!.settings.text, '');
      key.currentState!.change('multiple', true);
      await tester.pump();
      await _tap(tester, find.text('Bold'));
      await _tap(tester, find.text('Italic'));
      expect(key.currentState!.settings.text, 'bold,italic');
      await _tap(tester, find.text('Locked'));
      expect(key.currentState!.settings.text, 'bold,italic');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('slider changes real value and range thumbs stay ordered', (
    tester,
  ) async {
    final key = await _mount(tester, 'slider');
    await tester.drag(find.byType(NibSlider), const Offset(100, 0));
    await tester.pump();
    expect(key.currentState!.settings.value, greaterThan(40));
    expect(key.currentState!.events.last, startsWith('Committed volume:'));
    key.currentState!.change('multiple', true);
    key.currentState!.change('variant', 'custom');
    await tester.pump();
    await tester.drag(find.byType(NibSlider), const Offset(-100, 0));
    await tester.pump();
    expect(
      double.parse(key.currentState!.settings.text),
      greaterThanOrEqualTo(key.currentState!.settings.value),
    );
    expect(
      tester.widget<NibSlider>(find.byType(NibSlider)).thumbBuilder,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'grouped select searches, selects multiple, and controller clears',
    (tester) async {
      final key = await _mount(
        tester,
        'select',
        initial: const ComponentSettings(
          text: '',
          variant: 'grouped',
          multiple: true,
          searchable: true,
        ),
      );
      await _tap(tester, find.text('Choose fruit'));
      expect(find.text('Available'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Ban');
      await tester.pump();
      expect(find.text('Apple'), findsNothing);
      await _tap(tester, find.text('Banana'));
      expect(key.currentState!.settings.text, 'banana');
      final controller = tester
          .widget<NibSelect<String>>(find.byType(NibSelect<String>))
          .controller!;
      controller.close();
      await tester.pump();
      await _tap(tester, find.text('Clear selection'));
      expect(controller.selectedValues, isEmpty);
      expect(key.currentState!.settings.text, '');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'combobox typing filters and selects without losing query to styling',
    (tester) async {
      final key = await _mount(tester, 'combobox');
      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Ban');
      await tester.pump();
      final field = tester.widget<TextField>(find.byType(TextField));
      field.controller!.selection = const TextSelection(
        baseOffset: 1,
        extentOffset: 3,
      );
      key.currentState!.change('radius', 12.0);
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller,
        same(field.controller),
      );
      expect(
        field.controller!.selection,
        const TextSelection(baseOffset: 1, extentOffset: 3),
      );
      await _tap(tester, find.text('Banana'));
      expect(key.currentState!.settings.text, 'banana');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'async combobox fixture completes and free text is a distinct event',
    (tester) async {
      final key = await _mount(
        tester,
        'combobox',
        initial: const ComponentSettings(text: '', variant: 'async'),
      );
      await tester.tap(find.byType(TextField));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Apple'), findsOneWidget);
      await _tap(tester, find.text('Apple'));
      expect(key.currentState!.settings.text, 'apple');
      key.currentState!.change('variant', 'free-text');
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Dragonfruit');
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(key.currentState!.events, contains('Free text: Dragonfruit'));
      expect(tester.takeException(), isNull);
    },
  );
  for (final mode in ['single', 'range', 'multi']) {
    testWidgets('date $mode selection updates configured date data', (
      tester,
    ) async {
      final key = await _mount(
        tester,
        'date-picker',
        initial: ComponentSettings(
          text: '',
          variant: mode,
          backdrop: 'inline',
          searchable: false,
        ),
      );
      await _tap(tester, find.text('15'));
      if (mode == 'single') {
        expect(key.currentState!.settings.text, '2026-10-15');
      } else {
        await _tap(tester, find.text('20'));
        expect(key.currentState!.settings.text, '2026-10-15,2026-10-20');
      }
      final controller = tester
          .widget<NibDatePicker>(find.byType(NibDatePicker))
          .controller!;
      key.currentState!.change('animated', true);
      await tester.pump();
      expect(
        tester.widget<NibDatePicker>(find.byType(NibDatePicker)).controller,
        same(controller),
      );
      await _tap(tester, find.text('Clear selection'));
      expect(key.currentState!.settings.text, '');
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'prefilled OTP demo adopts escaped config without an initialization event',
    (tester) async {
      const initialText = r'$5 \ fixture "quoted"';
      final key = await _mount(
        tester,
        'otp-input',
        initial: const ComponentSettings(text: initialText, variant: 'system'),
      );
      expect(tester.takeException(), isNull);
      expect(key.currentState!.settings.text, initialText);
      expect(key.currentState!.events, isEmpty);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '5',
      );
      await tester.enterText(find.byType(TextField), '123456');
      await tester.pump();
      expect(key.currentState!.settings.text, '123456');
      expect(
        key.currentState!.events.last,
        'Six digits entered. This demo does not verify codes.',
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('OTP typed code sanitizes, completes and clears', (tester) async {
    final key = await _mount(tester, 'otp-input');
    await tester.enterText(find.byType(TextField), '12x345678');
    await tester.pump();
    expect(key.currentState!.settings.text, '123456');
    expect(
      key.currentState!.events,
      contains('Six digits entered. This demo does not verify codes.'),
    );
    await _tap(tester, find.text('Clear code'));
    expect(key.currentState!.settings.text, '');
    key.currentState!.change('disabled', true);
    await tester.pump();
    expect(tester.widget<NibOtpInput>(find.byType(NibOtpInput)).enabled, false);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'OTP keypad and exported support widgets accept digits and delete',
    (tester) async {
      final key = await _mount(
        tester,
        'otp-input',
        initial: const ComponentSettings(text: '', variant: 'keypad'),
      );
      expect(find.byType(NibOtpKeypad), findsOneWidget);
      expect(find.byType(NibOtpCell), findsNWidgets(6));
      await _tap(tester, find.widgetWithText(NibOtpKey, '1'));
      await _tap(tester, find.widgetWithText(NibOtpKey, '2'));
      expect(key.currentState!.settings.text, '12');
      await _tap(tester, find.byIcon(Icons.backspace_outlined));
      expect(key.currentState!.settings.text, '1');
      expect(tester.takeException(), isNull);
    },
  );
  for (final guide in selectionComponentGuides) {
    testWidgets(
      '${guide.id} five widths at large text retain Ember and dispose cleanly',
      (tester) async {
        for (final width in [360.0, 390.0, 768.0, 1024.0, 1440.0]) {
          await _mount(tester, guide.id, width: width, scale: 1.5);
          expect(
            tester.takeException(),
            isNull,
            reason: '${guide.id} at $width',
          );
          final context = tester.element(find.byType(_Host));
          expect(context.mounted, true);
          final material = tester.widget<MaterialApp>(find.byType(MaterialApp));
          expect(
            material.theme!.extension<NibTheme>()!.foreground,
            const Color(0xFFF4E8C8),
          );
          await tester.pumpWidget(const SizedBox());
          await tester.pump(const Duration(seconds: 1));
          expect(tester.takeException(), isNull);
          expect(tester.binding.transientCallbackCount, 0);
        }
      },
    );
  }
}
