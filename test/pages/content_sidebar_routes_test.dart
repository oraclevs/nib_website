import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/content/site_content.dart';
import 'package:nib_ember_living/components/component_catalog.dart';
import 'package:nib_ember_living/components/component_support_guides.dart';
import 'package:nib_motion/nib_motion.dart';

void main() {
  test(
    'each reference sidebar label resolves to its own real Motion article',
    () {
      const expectedLabels = [
        'Introduction',
        'Installation',
        'Your first animation',
        'Springs',
        'Keyframes',
        'Motion values',
        'Presence',
        'Layout animations',
        'Gestures',
        'Scroll motion',
        'Accessibility',
        'Performance',
      ];
      expect(SiteContent.motionReferenceNav.keys.toList(), expectedLabels);
      expect(SiteContent.motionReferenceNav.values.toSet().length, 12);

      for (final entry in SiteContent.motionReferenceNav.entries) {
        final article = SiteContent.articleById('motion', entry.value);
        expect(article, isNotNull, reason: entry.key);
        expect(article!.route, '/docs/motion/${entry.value}');
        expect(article.summary, isNotEmpty);
        expect(article.sections, isNotEmpty);
        expect(article.evidence, contains('MotionNib/motion/'));
        expect(
          article.sections.every((section) => section.paragraphs.isNotEmpty),
          isTrue,
        );
      }
      final readingOrder = SiteContent.articlesFor('motion')
          .map((a) => a.id)
          .toList();
      expect(readingOrder.take(4), [
        'introduction',
        'installation',
        'getting-started',
        'first-animation',
      ]);
      expect(
        readingOrder.indexOf('transitions'),
        lessThan(readingOrder.indexOf('controllers')),
      );
      expect(
        readingOrder.indexOf('accessibility'),
        lessThan(readingOrder.indexOf('presence')),
      );
      for (final package in SiteContent.packages) {
        final ids = SiteContent.learningPaths[package.id]!.values
            .expand((ids) => ids)
            .toList();
        expect(ids.toSet().length, ids.length, reason: package.id);
        final articleIds = SiteContent.articlesFor(package.id)
            .map((article) => article.id)
            .toSet();
        expect(ids.toSet().difference(articleIds), isEmpty, reason: package.id);
        expect(articleIds.difference(ids.toSet()), isEmpty, reason: package.id);
        if (package.id == 'components') {
          expect(ids, containsAll(componentGuides.map((guide) => guide.id)));
          expect(
            ids,
            containsAll(componentSupportArticles.map((guide) => guide.id)),
          );
          expect(SiteContent.articleById('components', 'catalog'), isNotNull);
        }
        for (final article in SiteContent.articlesFor(package.id)) {
          expect(
            article.sections.map((s) => s.id).toSet().length,
            article.sections.length,
            reason: article.route,
          );
        }
      }
    },
  );

  test(
    'technical articles include source-checked examples and scoped limits',
    () {
      for (final id in [
        'installation',
        'first-animation',
        'keyframes',
        'presence',
        'layout-animations',
        'scroll-motion',
      ]) {
        final article = SiteContent.articleById('motion', id)!;
        expect(
          article.sections.any((section) => section.code != null),
          isTrue,
          reason: id,
        );
      }
      final keyframes = SiteContent.articleById('motion', 'keyframes')!;
      expect(
        keyframes.sections.any(
          (section) => section.paragraphs.join(' ').contains('spring'),
        ),
        isTrue,
      );
      final layout = SiteContent.articleById('motion', 'layout-animations')!;
      expect(
        layout.sections.any(
          (section) => section.paragraphs
              .join(' ')
              .toLowerCase()
              .contains('perspective'),
        ),
        isTrue,
      );
      final performance = SiteContent.articleById('motion', 'performance')!;
      expect(
        performance.sections.any(
          (section) => section.paragraphs.join(' ').contains('raster'),
        ),
        isTrue,
      );
    },
  );

  test(
    'documented example constructors are available from the public barrel',
    () {
      final examples = <Widget>[
        const NibMotion(
          initial: NibAnim(opacity: 0, y: 20),
          animate: NibAnim(opacity: 1, y: 0),
          child: Text('Hello NibMotion'),
        ),
        const NibMotion(
          keyframes: [
            NibKeyframe(at: 0, value: NibAnim(opacity: 0)),
            NibKeyframe(at: 1, value: NibAnim(opacity: 1)),
          ],
          child: Text('Sequence'),
        ),
        NibPresence(
          children: [
            const NibMotion(
              key: ValueKey('item'),
              exit: NibAnim(opacity: 0),
              child: Text('Item'),
            ),
          ],
        ),
        const NibLayoutScope(
          child: NibMotion(
            key: ValueKey('layout'),
            layout: NibLayout.both,
            layoutTransition: NibTransition.springGentle,
            child: Text('Layout'),
          ),
        ),
        const NibScrollReveal(
          initial: NibAnim(opacity: 0, y: 32),
          child: Text('Now in view'),
        ),
      ];
      expect(examples, hasLength(5));
    },
  );
}
