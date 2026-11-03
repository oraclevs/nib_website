import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_motion/nib_motion.dart';
import 'package:nib_ember_living/pages/docs_spring_demo.dart';
import 'package:nib_ember_living/pages/docs_spring_reference.dart';

import '../support/file_asset_bundle.dart';

void main() {
  testWidgets(
    'spring retargets, freezes, resumes and respects reduced motion',
    (tester) async {
      double target = 0;
      bool paused = false;
      bool reduced = false;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return Scaffold(
                body: Center(
                  child: DocumentationSpring(
                    target: target,
                    paused: paused,
                    reduceMotion: reduced,
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();
      final controller = tester
          .widget<NibMotion>(find.byType(NibMotion))
          .controller!;
      double position() => controller.motionValueOf(NibProperty.x)!.value;
      expect(position(), closeTo(0, .01));
      update(() => target = -60);
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 90));
      expect(position(), lessThan(-1));
      expect(position(), greaterThan(-65));
      update(() => paused = true);
      await tester.pump();
      final frozen = position();
      await tester.pump(const Duration(seconds: 2));
      expect(position(), closeTo(frozen, .001));
      update(() {
        paused = false;
        target = 0;
      });
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      expect(position(), closeTo(0, .02));
      update(() {
        target = -60;
        reduced = true;
      });
      await tester.pump();
      expect(position(), closeTo(-60, .001));
      expect(controller.velocityOf(NibProperty.x), 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'spring guide explains its API and copies the exact preview source',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
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
      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: FileAssetBundle(),
          child: MaterialApp(
            home: Scaffold(body: DocsSpringReference(onNavigate: (_) {})),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Snappy'));
      await tester.tap(find.text('Snappy'));
      await tester.pump();
      await tester.ensureVisible(find.text('Copy code').first);
      await tester.tap(find.text('Copy code').first);
      await tester.pump();
      expect(copied, contains("import 'package:nib_motion/nib_motion.dart';"));
      expect(copied, contains('class DocumentationSpring'));
      expect(copied, contains('stiffness: 300'));
      expect(copied, contains('void main()'));
      // Analyze this exact clipboard artifact with the release verification command.
      final artifact = File('build/docs_copy_verification/main.dart');
      artifact.parent.createSync(recursive: true);
      artifact.writeAsStringSync(copied!);

      expect(find.text('An interaction, in three moments.'), findsNothing);
      expect(find.text('mass'), findsOneWidget);
      expect(find.text('Retargeting'), findsWidgets);
      expect(find.text('Package source for this guide'), findsNothing);
      await tester.pump(const Duration(seconds: 3));
      expect(tester.takeException(), isNull);
    },
  );
}
