import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_motion/nib_motion.dart';
import 'package:nib_ember_living/home_hero.dart';

void main() {
  setUpAll(() async {
    final fonts = FontLoader('Ember Sans')
      ..addFont(rootBundle.load('assets/fonts/LiberationSans-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/LiberationSans-Bold.ttf'));
    await fonts.load();
  });
  testWidgets(
    'hero types with NibMotion then sweeps gradient without layout shift',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HomeHero(
                mobile: false,
                ambient: true,
                playground: () {},
                docs: () {},
                copyInstall: () {},
              ),
            ),
          ),
        ),
      );
      final initialSize = tester.getSize(find.byType(HomeHero));
      expect(find.byType(NibTypewriter), findsNWidgets(2));
      await tester.pump(const Duration(milliseconds: 700));
      final typed = tester.widget<Text>(
        find.descendant(
          of: find.byType(NibTypewriter).first,
          matching: find.byType(Text),
        ),
      );
      expect(typed.data, isNotEmpty);
      expect(typed.data!.length, lessThan('Make every interaction '.length));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(find.byType(NibGradientText), findsOneWidget);
      expect(tester.getSize(find.byType(HomeHero)), initialSize);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('reduced motion reveals the complete headline immediately', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NibMotionConfig(
          reducedMotion: true,
          child: Scaffold(
            body: SingleChildScrollView(
              child: HomeHero(
                mobile: true,
                ambient: false,
                playground: () {},
                docs: () {},
                copyInstall: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.byType(NibGradientText), findsOneWidget);
    expect(find.text('Make every'), findsWidgets);
    expect(find.text('interaction'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
