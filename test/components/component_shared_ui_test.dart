import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_components/nib_components.dart';
import 'package:nib_ember_living/components/component_catalog.dart';
import 'package:nib_ember_living/components/component_pages.dart';
import 'package:nib_ember_living/components/examples/input_component_demo.dart';
import 'package:nib_ember_living/main.dart';
import 'package:nib_ember_living/pages/docs_spring_reference.dart';
import 'package:nib_ember_living/site_router.dart';
import 'package:nib_ember_living/widgets/dart_code_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

Finder get _gallerySearch => find.byWidgetPredicate(
  (widget) =>
      widget is TextField &&
      widget.decoration?.hintText == 'Find a component or public API',
);

Future<SiteRouterDelegate> _mount(
  WidgetTester tester, {
  required double width,
  double scale = 1,
  String route = '/components',
}) async {
  tester.view.physicalSize = Size(width, 1100);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  tester.platformDispatcher.defaultRouteNameTestValue = route;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  addTearDown(tester.platformDispatcher.clearDefaultRouteNameTestValue);
  SharedPreferences.setMockInitialValues({});
  await tester.runAsync(() async {
    final sans = FontLoader('Ember Sans')
      ..addFont(rootBundle.load('assets/fonts/LiberationSans-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/LiberationSans-Bold.ttf'));
    final mono = FontLoader('Ember Mono')
      ..addFont(rootBundle.load('assets/fonts/DejaVuSansMono.ttf'));
    await Future.wait([sans.load(), mono.load()]);
    for (final path in [
      'lib/components/component_settings.dart',
      'lib/components/component_theme.dart',
      'lib/ember_material_theme.dart',
      componentById('input')!.demoFile,
      'assets/reference/public_api.json',
    ]) {
      await rootBundle.loadString(path);
    }
  });
  await tester.pumpWidget(const NibEmberSite());
  final router =
      tester.widget<MaterialApp>(find.byType(MaterialApp)).routerDelegate!
          as SiteRouterDelegate;
  router.go(route);
  await tester.pumpAndSettle();
  return router;
}

Future<void> _tap(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _openInputFromPreview(WidgetTester tester) async {
  await tester.ensureVisible(_gallerySearch);
  await tester.enterText(_gallerySearch, 'NibInput');
  await tester.pumpAndSettle();
  final card = find.byKey(const ValueKey('component-card-input'));
  final galleryScroll = find
      .descendant(
        of: find.byType(ComponentExplorerPage),
        matching: find.byType(Scrollable),
      )
      .first;
  await tester.scrollUntilVisible(card, 200, scrollable: galleryScroll);
  await tester.pumpAndSettle();
  final input = find.descendant(of: card, matching: find.byType(NibInput));
  expect(input, findsOneWidget);
  expect(
    find.ancestor(
      of: input,
      matching: find.byWidgetPredicate(
        (widget) => widget is IgnorePointer && widget.ignoring,
      ),
    ),
    findsWidgets,
  );
  expect(
    find.ancestor(of: input, matching: find.byType(ExcludeFocus)),
    findsWidgets,
  );
  final field = find.descendant(of: input, matching: find.byType(TextField));
  expect(tester.widget<TextField>(field).controller!.text, 'Hello, Nib');
  await tester.ensureVisible(field);
  await tester.pumpAndSettle();
  // The view-only field cannot receive this pointer. The surrounding card
  // handles it and opens the actual interactive playground.
  await tester.tapAt(tester.getCenter(field));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final width in [360.0, 390.0, 768.0, 1024.0, 1440.0]) {
    for (final scale in [1.0, 1.5]) {
      testWidgets('real site gallery → playground → guide at $width / $scale', (
        tester,
      ) async {
        final router = await _mount(tester, width: width, scale: scale);
        expect(router.currentConfiguration.path, '/components');
        await _openInputFromPreview(tester);
        expect(
          router.currentConfiguration.path,
          '/playground/components/input',
        );
        expect(find.byType(InputComponentDemo), findsOneWidget);
        expect(
          tester
              .widget<InputComponentDemo>(find.byType(InputComponentDemo))
              .settings
              .text,
          'Hello, Nib',
        );
        await _tap(tester, find.text('Read the guide'));
        expect(router.currentConfiguration.path, '/docs/components/input');
        expect(find.byType(DocsSpringReference), findsOneWidget);
        expect(
          find.byKey(const ValueKey('docs-article-scroll')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 1));
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final width in [390.0, 1440.0]) {
    testWidgets('real controls, keyboard focus, copy and reset at $width', (
      tester,
    ) async {
      await _mount(tester, width: width, route: '/playground/components/input');
      final field = find.descendant(
        of: find.byType(NibInput),
        matching: find.byType(TextField),
      );
      await _tap(tester, field);
      expect(tester.widget<TextField>(field).focusNode!.hasFocus, isTrue);
      await tester.enterText(field, 'A note from the keyboard');
      await tester.pumpAndSettle();
      InputComponentDemo runtime() =>
          tester.widget<InputComponentDemo>(find.byType(InputComponentDemo));
      expect(runtime().settings.text, 'A note from the keyboard');

      final variant = find.byKey(const ValueKey('input-variant-single-line'));
      await _tap(tester, variant);
      await _tap(tester, find.text('multiline').last);
      expect(runtime().settings.variant, 'multiline');
      expect(find.byType(NibTextarea), findsOneWidget);
      final multiline = find.descendant(
        of: find.byType(NibTextarea),
        matching: find.byType(TextField),
      );
      expect(
        tester.widget<TextField>(multiline).controller!.text,
        'A note from the keyboard',
      );
      await _tap(tester, multiline);
      expect(tester.widget<TextField>(multiline).focusNode!.hasFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(multiline).focusNode!.hasFocus, isFalse);

      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      if (width < 640) {
        final outer = find
            .descendant(
              of: find.byType(ComponentGuidePage),
              matching: find.byType(Scrollable),
            )
            .first;
        tester.state<ScrollableState>(outer).position.jumpTo(0);
        await tester.pumpAndSettle();
      }
      await _tap(tester, find.byKey(const ValueKey('component-code-full')));
      await _tap(tester, find.byKey(const ValueKey('component-copy-code')));
      for (var attempt = 0; copied == null && attempt < 100; attempt++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump();
      }
      expect(copied, contains('void main()'));
      expect(copied, contains('class InputComponentDemo'));
      expect(copied, contains('variant: "multiline"'));
      expect(copied, contains('text: "A note from the keyboard"'));
      expect(copied, isNot(contains("import '../")));
      await _tap(tester, find.text('Reset example'));
      expect(runtime().settings.values, componentById('input')!.initial.values);
      expect(find.byType(NibTextarea), findsNothing);
      expect(tester.widget<TextField>(field).controller!.text, 'Hello, Nib');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('clipboard denial keeps complete source available', (
    tester,
  ) async {
    await _mount(tester, width: 1440, route: '/playground/components/input');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          throw PlatformException(code: 'denied');
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await _tap(tester, find.text('Copy code'));
    final message = find.text(
      'Clipboard unavailable. Select the code below and copy it manually.',
    );
    for (
      var attempt = 0;
      message.evaluate().isEmpty && attempt < 100;
      attempt++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
    expect(message, findsOneWidget);
    bool completeSourceReady() => tester
        .widgetList<DartCodeView>(find.byType(DartCodeView))
        .any((source) => source.code.contains('class ShortExample'));
    for (var attempt = 0; !completeSourceReady() && attempt < 100; attempt++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
    expect(completeSourceReady(), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'component documentation topics and article scroll independently',
    (tester) async {
      await _mount(tester, width: 1440, route: '/docs/components/input');
      final topics = find.byKey(const ValueKey('docs-topics-scroll'));
      final article = find.byKey(const ValueKey('docs-article-scroll'));
      final topicController = tester
          .widget<SingleChildScrollView>(topics)
          .controller!;
      final articleController = tester
          .widget<SingleChildScrollView>(article)
          .controller!;
      expect(topicController, isNot(same(articleController)));
      final initialArticle = articleController.offset;
      await tester.drag(topics, const Offset(0, -350));
      await tester.pumpAndSettle();
      expect(topicController.offset, greaterThan(100));
      expect(articleController.offset, initialArticle);
      final afterTopics = topicController.offset;
      await tester.drag(article, const Offset(0, -420));
      await tester.pumpAndSettle();
      expect(articleController.offset, greaterThan(200));
      expect(topicController.offset, afterTopics);
      expect(tester.takeException(), isNull);
    },
  );
}
