/// Behavioral contracts executed against the exported, standalone Flutter app.
/// The consumer supplies tester, expected settings, and runtime().
String? selectionExportContract(String id) => switch (id) {
  'button' =>
    r'''
var button = tester.widget<NibButton>(find.byKey(const ValueKey('button-action')));
expect(button.label, expected['text']);
expect(button.disabled, expected['disabled']);
expect(button.loading, expected['multiple']);
expect(button.animated, expected['animated']);
expect(button.expand, expected['interactive']);
expect(button.pill, expected['vertical']);
expect(button.variant.name, expected['variant']);
expect(button.size.name, expected['backdrop']);
runtime().onChanged(runtime().settings.change('disabled', false).change('multiple', false));
await tester.pump();
await tester.tap(find.byKey(const ValueKey('button-action')));
await tester.pump(const Duration(milliseconds: 300));
expect(find.text('Activations: 1'), findsOneWidget);
''',
  'checkbox' =>
    r'''
final box = tester.widget<NibCheckbox>(find.byType(NibCheckbox));
expect(box.label, expected['text']);
expect(box.disabled, expected['disabled']);
expect(box.tristate, expected['multiple']);
expect(box.animated, expected['animated']);
runtime().onChanged(runtime().settings.change('disabled', false).change('multiple', true).change('value', 0.0));
await tester.pump();
await tester.tap(find.byKey(const ValueKey('checkbox-action')));
await tester.pump(const Duration(milliseconds: 300));
expect(runtime().settings.value, 1);
await tester.tap(find.byKey(const ValueKey('checkbox-action')));
await tester.pump(const Duration(milliseconds: 300));
expect(runtime().settings.value, -1);
expect(tester.widget<NibCheckbox>(find.byType(NibCheckbox)).value, isNull);
''',
  'switch' =>
    r'''
final toggle = tester.widget<NibSwitch>(find.byType(NibSwitch));
expect(toggle.label, expected['text']);
expect(toggle.loading, expected['multiple']);
expect(toggle.disabled, expected['disabled']);
expect(toggle.animated, expected['animated']);
expect(toggle.transition!.duration.inMilliseconds, 320);
expect(toggle.value, (expected['value'] as num) > 0);
runtime().onChanged(runtime().settings.change('disabled', false).change('multiple', false).change('value', 0.0));
await tester.pump();
await tester.tap(find.byKey(const ValueKey('switch-action')));
await tester.pump(const Duration(milliseconds: 300));
expect(runtime().settings.value, 1);
expect(find.descendant(of: find.byType(runtime().runtimeType), matching: find.text('Updates: on')), findsOneWidget);
for (final variant in ['images', 'image-thumb']) {
  runtime().onChanged(runtime().settings.change('variant', variant).change('value', 0.0));
  await tester.pump();
  final offImage = tester.widget<Image>(find.byType(Image));
  expect(offImage.image, isA<MemoryImage>());
  final offBytes = (offImage.image as MemoryImage).bytes;
  await tester.tap(find.byKey(const ValueKey('switch-action')));
  await tester.pump(const Duration(milliseconds: 300));
  expect(runtime().settings.value, 1);
  final onImage = tester.widget<Image>(find.byType(Image));
  expect((onImage.image as MemoryImage).bytes, orderedEquals(offBytes));
}
''',
  'radio-group' =>
    r'''
final group = tester.widget<NibRadioGroup<String>>(find.byType(NibRadioGroup<String>));
expect(group.disabled, expected['disabled']);
expect(group.animated, expected['animated']);
expect(group.direction, expected['vertical'] == true ? Axis.vertical : Axis.horizontal);
expect(group.optionBuilder != null, expected['variant'] == 'cards');
runtime().onChanged(runtime().settings.change('disabled', false).change('text', 'daily'));
await tester.pump();
await tester.tap(find.text('Weekly'));
await tester.pump(const Duration(milliseconds: 300));
expect(runtime().settings.text, 'weekly');
await tester.tap(find.text('Instant'));
await tester.pump();
expect(runtime().settings.text, 'weekly');
''',
  'toggle-group' =>
    r'''
final group = tester.widget<NibToggleGroup<String>>(find.byType(NibToggleGroup<String>));
expect(group.disabled, expected['disabled']);
expect(group.animated, expected['animated']);
expect(group.direction, expected['vertical'] == true ? Axis.vertical : Axis.horizontal);
runtime().onChanged(runtime().settings.change('disabled', false).change('multiple', true).change('text', ''));
await tester.pump();
await tester.tap(find.text('Bold'));
await tester.pump(const Duration(milliseconds: 300));
await tester.tap(find.text('Italic'));
await tester.pump(const Duration(milliseconds: 300));
expect(runtime().settings.text, 'bold,italic');
await tester.tap(find.text('Locked'));
await tester.pump();
expect(runtime().settings.text, 'bold,italic');
''',
  'slider' =>
    r'''
final slider = tester.widget<NibSlider>(find.byType(NibSlider));
expect(slider.disabled, expected['disabled']);
expect(slider.animated, expected['animated']);
expect(slider.axis, expected['vertical'] == true ? Axis.vertical : Axis.horizontal);
expect(slider.divisions, expected['searchable'] == true ? 10 : null);
runtime().onChanged(runtime().settings.change('disabled', false).change('multiple', false).change('vertical', false).change('value', 20.0));
await tester.pump();
final rect = tester.getRect(find.byType(NibSlider));
await tester.tapAt(Offset(rect.left + rect.width * .75, rect.center.dy));
await tester.pump(const Duration(milliseconds: 300));
expect(runtime().settings.value, greaterThan(50));
''',
  'select' =>
    r'''
final select = tester.widget<NibSelect<String>>(find.byType(NibSelect<String>));
expect(select.multiSelect, expected['multiple']);
expect(select.searchable, expected['searchable']);
expect(select.disabled, expected['disabled']);
expect(select.loading, expected['interactive'] != true);
expect(select.animated, expected['animated']);
expect(select.animation.name, expected['backdrop']);
runtime().onChanged(runtime().settings.change('disabled', false).change('interactive', true).change('multiple', false).change('searchable', true).change('text', ''));
await tester.pump();
await tester.tap(find.text('Choose fruit'));
await tester.pump(const Duration(milliseconds: 600));
await tester.enterText(find.byType(TextField), 'Ban');
await tester.pump();
expect(find.text('Apple'), findsNothing);
await tester.tap(find.text('Banana'));
await tester.pump(const Duration(milliseconds: 600));
expect(runtime().settings.text, 'banana');
await tester.tap(find.text('Clear selection'));
await tester.pump();
expect(runtime().settings.text, '');
''',
  'combobox' =>
    r'''
final combo = tester.widget<NibCombobox<String>>(find.byType(NibCombobox<String>));
expect(combo.multiSelect, expected['multiple']);
expect(combo.disabled, expected['disabled']);
expect(combo.loading, expected['interactive'] != true);
expect(combo.allowFreeText, expected['variant'] == 'free-text');
expect(combo.asyncOptionsLoader != null, expected['variant'] == 'async');
runtime().onChanged(runtime().settings.change('disabled', false).change('interactive', true).change('multiple', false).change('variant', 'free-text').change('text', ''));
await tester.pump();
await tester.tap(find.byType(TextField));
await tester.pump();
await tester.enterText(find.byType(TextField), 'Ban');
await tester.pump();
await tester.tap(find.text('Banana'));
await tester.pump(const Duration(milliseconds: 600));
expect(runtime().settings.text, 'banana');
await tester.enterText(find.byType(TextField), 'Dragonfruit');
await tester.pump();
await tester.sendKeyEvent(LogicalKeyboardKey.enter);
await tester.pump();
expect(find.descendant(of: find.byType(runtime().runtimeType), matching: find.text('Free text: Dragonfruit')), findsOneWidget);
''',
  'date-picker' =>
    r'''
final date = tester.widget<NibDatePicker>(find.byType(NibDatePicker));
expect(date.mode.name, expected['variant']);
expect(date.displayMode.name, expected['backdrop']);
expect(date.disabled, expected['disabled']);
expect(date.animated, expected['animated']);
expect(date.dayBuilder != null, expected['searchable']);
runtime().onChanged(runtime().settings.change('disabled', false).change('variant', 'single').change('backdrop', 'inline').change('text', ''));
await tester.pump();
await tester.tap(find.text('15'));
await tester.pump(const Duration(milliseconds: 350));
expect(runtime().settings.text, '2026-10-15');
await tester.ensureVisible(find.text('Clear selection'));
await tester.tap(find.text('Clear selection'));
await tester.pump();
expect(runtime().settings.text, '');
''',
  'otp-input' =>
    r'''
final otp = tester.widget<NibOtpInput>(find.byType(NibOtpInput));
expect(otp.enabled, expected['disabled'] != true);
expect(otp.loading, expected['interactive'] != true);
expect(otp.obscureText, expected['multiple']);
expect(otp.keyboard, expected['variant'] == 'keypad' ? NibOtpKeyboard.onScreen : NibOtpKeyboard.system);
runtime().onChanged(runtime().settings.change('disabled', false).change('interactive', true).change('variant', 'system').change('text', ''));
await tester.pump();
await tester.enterText(find.byType(TextField), '123456');
await tester.pump();
expect(runtime().settings.text, '123456');
expect(find.descendant(of: find.byType(runtime().runtimeType), matching: find.text('Six digits entered. This demo does not verify codes.')), findsOneWidget);
await tester.ensureVisible(find.text('Clear code'));
await tester.tap(find.text('Clear code'));
await tester.pump();
expect(runtime().settings.text, '');
''',
  _ => null,
};
