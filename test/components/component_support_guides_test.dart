import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_components/nib_components.dart';
import 'package:nib_ember_living/components/component_support_guides.dart';
import 'package:nib_ember_living/content/site_content.dart';

String _text(DocArticle article) => [
  article.title,
  article.summary,
  for (final section in article.sections) ...[
    section.heading,
    ...section.paragraphs,
    section.code ?? '',
    section.note ?? '',
    ...section.blocks.map((block) => block.searchText),
  ],
].join(' ');

void main() {
  final inventory = jsonDecode(
    File('docs/evidence/2026-10-28-components/inventory.json')
        .readAsStringSync(),
  ) as Map<String, dynamic>;
  final families = (inventory['families'] as List)
      .map((dynamic family) => family['id'] as String)
      .toSet();
  final symbols = <String, Set<String>>{
    for (final dynamic symbol in inventory['publicSymbols'] as List)
      symbol['name'] as String: (symbol['members'] as List)
          .map((dynamic member) => member['name'] as String)
          .toSet(),
  };

  test('six support guides have distinct routes and substantive sections', () {
    expect(componentSupportArticles.map((article) => article.id).toSet(), {
      'theming',
      'state-and-controllers',
      'motion-opt-in',
      'overlays',
      'accessibility',
      'validation',
    });
    for (final article in componentSupportArticles) {
      expect(article.packageId, 'components');
      expect(article.sections.length, greaterThanOrEqualTo(4));
      expect(
        article.sections.map((section) => section.id).toSet().length,
        article.sections.length,
      );
      expect(
        _text(article).split(RegExp(r'\s+')).length,
        greaterThan(450),
        reason: article.id,
      );
      for (final path in article.evidence.split('; ')) {
        expect(File('../$path').existsSync(), isTrue, reason: path);
      }
    }
  });

  test('guide links use canonical family or support IDs', () {
    final routes = {
      ...families.map((id) => '/docs/components/$id'),
      ...componentSupportArticles.map((article) => article.route),
    };
    for (final article in componentSupportArticles) {
      final links = article.sections
          .expand((section) => section.blocks)
          .whereType<DocLink>();
      expect(links, isNotEmpty, reason: article.id);
      for (final link in links) {
        expect(
          routes,
          contains(link.route),
          reason: '${article.id}: ${link.label}',
        );
      }
    }
  });

  test('named API entries resolve to actual public symbols and members', () {
    for (final article in componentSupportArticles) {
      for (final entry in article.sections.expand((section) => section.api)) {
        final parts = entry.name.split('.');
        expect(symbols, contains(parts.first), reason: entry.name);
        if (parts.length == 2) {
          expect(symbols[parts.first], contains(parts[1]), reason: entry.name);
        }
      }
    }
  });

  test('theming guide covers every public color and radius token', () {
    final text = _text(componentSupportArticles.first);
    for (final token in [
      'background',
      'foreground',
      'card',
      'cardForeground',
      'primary',
      'primaryForeground',
      'secondary',
      'secondaryForeground',
      'muted',
      'mutedForeground',
      'accent',
      'accentForeground',
      'border',
      'input',
      'ring',
      'destructive',
      'radiusSm',
      'radiusDefault',
      'radiusLg',
      'radiusPill',
    ]) {
      expect(text, contains(token));
    }
    expect(text, contains('There are no NibButtonTheme or NibCardTheme'));
    expect(text, contains('also supports light themes'));
  });

  test('validation examples check the first error and actual length units', () {
    final validate = NibValidators.compose([
      NibValidators.required('Enter your email.'),
      NibValidators.email(),
    ]);
    expect(validate(''), 'Enter your email.');
    expect(validate('wrong'), 'Enter a valid email address.');
    expect(validate('ada@example.com'), isNull);
    expect(NibValidators.email()(''), isNull);
    expect(NibValidators.maxLength(1)('😀'), isNotNull);
    expect(
      NibValidators.pattern(RegExp(r'^[A-Z]{3}-[0-9]{3}$'))('ABC-123'),
      isNull,
    );
    expect(
      NibValidators.pattern(RegExp(r'^[A-Z]{3}-[0-9]{3}$'))('ABC-123extra'),
      isNotNull,
    );
    expect(
      NibValidators.password()('abcdefgh'),
      'Must contain an uppercase letter.',
    );
  });

  testWidgets(
    'theme fallback, local override, and external state stay separate',
    (tester) async {
      final controller = TextEditingController(text: 'Keep this draft');
      addTearDown(controller.dispose);
      NibTheme? observed;
      Future<void> mount(ThemeData theme) => tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                observed = NibTheme.of(context);
                return NibInput(controller: controller, label: 'Draft');
              },
            ),
          ),
        ),
      );
      await mount(ThemeData.light());
      expect(observed, NibTheme.light);
      controller.selection = const TextSelection.collapsed(offset: 4);
      await mount(
        ThemeData.dark().copyWith(
          extensions: [
            NibTheme.dark.copyWith(primary: const Color(0xFFBBAAFF)),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(observed!.primary, const Color(0xFFBBAAFF));
      expect(observed!.card, NibTheme.dark.card);
      expect(controller.text, 'Keep this draft');
      expect(controller.selection.baseOffset, 4);
      await tester.pumpWidget(const SizedBox());
      controller.text = 'Still owned by this test';
      expect(controller.text, 'Still owned by this test');
    },
  );

  for (final multiline in [false, true]) {
    testWidgets(
      'forced error and reset baseline are truthful for ${multiline ? 'textarea' : 'input'}',
      (tester) async {
        final controller = TextEditingController(text: 'Saved draft');
        final form = GlobalKey<FormState>();
        addTearDown(controller.dispose);
        var calls = 0;
        String? forced = 'Server rejected this value';
        late StateSetter rebuild;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  rebuild = setState;
                  String? validator(String? value) {
                    calls++;
                    return null;
                  }

                  return Form(
                    key: form,
                    child: multiline
                        ? NibTextarea(
                            controller: controller,
                            validator: validator,
                            errorText: forced,
                            autovalidateMode: AutovalidateMode.disabled,
                          )
                        : NibInput(
                            controller: controller,
                            validator: validator,
                            errorText: forced,
                            autovalidateMode: AutovalidateMode.disabled,
                          ),
                  );
                },
              ),
            ),
          ),
        );
        expect(form.currentState!.validate(), isFalse);
        expect(calls, 0);
        controller.text = 'Edited draft';
        await tester.pump();
        form.currentState!.reset();
        expect(controller.text, 'Saved draft');
        controller.text = 'Current draft';
        rebuild(() => forced = null);
        await tester.pump();
        expect(form.currentState!.validate(), isTrue);
        expect(calls, 1);
        controller.text = 'Later edit';
        await tester.pump();
        form.currentState!.reset();
        expect(controller.text, 'Current draft');
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets('dialog example returns a typed result through its inner scope', (
    tester,
  ) async {
    BuildContext? opener;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              opener = context;
              return const Text('Underlying page');
            },
          ),
        ),
      ),
    );
    final result = showNibDialog<bool>(
      opener!,
      title: 'Keep these changes?',
      content: Builder(
        builder: (dialogContext) => NibButton(
          label: 'Keep changes',
          onPressed: () => NibDialogScope.of(dialogContext).close(true),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Keep changes'));
    await tester.pump();
    expect(await result, isTrue);
    expect(find.text('Keep these changes?'), findsNothing);
    expect(find.text('Underlying page'), findsOneWidget);
  });
}
