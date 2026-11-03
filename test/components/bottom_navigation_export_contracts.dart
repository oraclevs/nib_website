String? bottomNavigationExportContract(String id) {
  if (id != 'glass-bottom-navigation' && id != 'liquid-bottom-navigation') {
    return null;
  }
  return '''
final barFinder = find.byKey(const ValueKey('composition-bottom-nav'));
NibNavBar bar() => tester.widget<NibNavBar>(barFinder);
expect(bar().style.glass, ${id == 'glass-bottom-navigation'});
expect(bar().items.first.label, expected['text']);
expect(bar().items[1].badge!.count, (expected['value'] as num).round());
await tester.tap(find.bySemanticsLabel('Open inbox'));
await tester.pumpAndSettle();
expect(bar().currentIndex, 1);
expect(find.byKey(const ValueKey('bottom-nav-inbox')), findsOneWidget);
await tester.enterText(find.byType(TextField), 'A retained local draft');
await tester.tap(find.bySemanticsLabel('Open settings'));
await tester.pumpAndSettle();
expect(bar().currentIndex, 2);
expect(find.byKey(const ValueKey('bottom-nav-settings')), findsOneWidget);
await tester.tap(find.bySemanticsLabel('Open inbox'));
await tester.pumpAndSettle();
expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, 'A retained local draft');
runtime().onChanged(runtime().settings.change('radius', 6.0));
await tester.pumpAndSettle();
expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, 'A retained local draft');
await tester.ensureVisible(find.text('Next destination from host'));
await tester.pumpAndSettle();
await tester.tap(find.text('Next destination from host'));
await tester.pumpAndSettle();
expect(bar().currentIndex, 2);
expect(find.text('onIndexChanged: 2'), findsOneWidget);
''';
}
