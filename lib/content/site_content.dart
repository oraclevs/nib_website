import 'motion_guides.dart';
import 'motion_capabilities.dart';
import '../components/component_catalog.dart';
import '../components/component_support_guides.dart';
import 'ecosystem_guides.dart';

/// Source-grounded content shared by package navigation, docs and site search.
///
/// Guides describe the current local public APIs. Local candidate behavior
/// remains distinct from the published package versions.
class PackageInfo {
  const PackageInfo({
    required this.id,
    required this.name,
    required this.role,
    required this.tagline,
    required this.description,
    required this.status,
    required this.install,
    required this.capabilities,
    required this.caution,
  });

  final String id;
  final String name;
  final String role;
  final String tagline;
  final String description;
  final String status;
  final String? install;
  final List<String> capabilities;
  final String caution;

  String get route => '/packages/$id';
  String get docsRoute => '/docs/$id/getting-started';
}

class DocSection {
  const DocSection({
    required this.id,
    required this.heading,
    required this.paragraphs,
    this.code,
    this.note,
    this.api = const [],
    this.blocks = const [],
  });

  final String id;
  final String heading;
  final List<String> paragraphs;
  final String? code;
  final String? note;
  final List<DocApiEntry> api;
  final List<DocBlock> blocks;
}

/// Structured article content; no Markdown parsing or hidden HTML is involved.
sealed class DocBlock {
  const DocBlock();
  String get searchText;
}

class DocList extends DocBlock {
  const DocList(this.items, {this.ordered = false});
  final List<DocListItem> items;
  final bool ordered;
  @override
  String get searchText => items.map((item) => item.searchText).join(' ');
}

class DocListItem {
  const DocListItem(this.text, {this.children = const []});
  final String text;
  final List<DocListItem> children;
  String get searchText =>
      '$text ${children.map((item) => item.searchText).join(' ')}';
}

class DocTable extends DocBlock {
  const DocTable({required this.headers, required this.rows});
  final List<String> headers;
  final List<List<String>> rows;
  @override
  String get searchText => [...headers, ...rows.expand((row) => row)].join(' ');
}

class DocLink extends DocBlock {
  const DocLink(this.label, this.route);
  final String label;
  final String route;
  @override
  String get searchText => label;
}

/// A source-checked API argument, return value, or lifecycle operation.
class DocApiEntry {
  const DocApiEntry({
    required this.name,
    required this.type,
    required this.defaultValue,
    required this.description,
  });
  final String name;
  final String type;
  final String defaultValue;
  final String description;
}

class DocArticle {
  const DocArticle({
    required this.packageId,
    required this.id,
    required this.title,
    required this.summary,
    required this.sections,
    required this.evidence,
    this.relatedRecipeId,
  });

  final String packageId;
  final String id;
  final String title;
  final String summary;
  final List<DocSection> sections;

  /// Local source path(s) used to check the technical claims.
  final String evidence;
  final String? relatedRecipeId;

  String get route => '/docs/$packageId/$id';
}

abstract final class SiteContent {
  /// Reading order: learn the basics, build interactions, then control lifecycle.
  static final learningPaths = <String, Map<String, List<String>>>{
    'motion': {
      'Start here': [
        'introduction',
        'installation',
        'getting-started',
        'first-animation',
        'accessibility',
        'migration',
      ],
      'States and timing': [
        'transitions',
        'variants-stagger',
        'keyframes',
        'presets',
        'motion-lists',
      ],
      'Physics and input': [
        'springs',
        'physics',
        'motion-values',
        'gestures',
        'drag-and-drop',
      ],
      'Layout and presence': [
        'layout-animations',
        'presence',
        'layout-presence',
      ],
      'Scroll and orchestration': [
        'scroll-motion',
        'viewport-motion',
        'navigation',
        'routes',
        'controllers',
        'animation-sequences',
        'timeline',
      ],
      'Text and effects': ['text-motion', 'path-motion', 'shaders', 'water'],
      'Tools and reference': [
        'debugging',
        'performance',
        'platform-limits',
        'troubleshooting',
        'api',
      ],
    },
    'components': {
      'Start here': [
        'getting-started',
        'catalog',
        'theming',
        'state-and-controllers',
        'motion-opt-in',
      ],
      for (final category in componentGuides.map((g) => g.category).toSet())
        category: [
          for (final guide in componentGuides.where(
            (g) => g.category == category,
          ))
            guide.id,
        ],
      'Build reliable interfaces': [
        'forms',
        'validation',
        'overlays',
        'accessibility',
      ],
      'Reference': ['api', 'platform-limits', 'troubleshooting'],
    },
    'genui': {
      'Beginner': ['getting-started', 'protocol-scope'],
      'Intermediate': ['runtime', 'bindings-and-forms'],
      'Advanced': ['actions-and-policy', 'accessibility'],
      'Reference': ['api', 'platform-limits', 'troubleshooting'],
    },
  };

  static String levelFor(String packageId, String articleId) =>
      learningPaths[packageId]?.entries
          .where((group) => group.value.contains(articleId))
          .firstOrNull
          ?.key ??
      'Guide';

  /// The accepted reference sidebar labels and their distinct Motion routes.
  /// Keep this ordering in the docs navigation; additional guides follow it.
  static const motionReferenceNav = <String, String>{
    'Introduction': 'introduction',
    'Installation': 'installation',
    'Your first animation': 'first-animation',
    'Springs': 'springs',
    'Keyframes': 'keyframes',
    'Motion values': 'motion-values',
    'Presence': 'presence',
    'Layout animations': 'layout-animations',
    'Gestures': 'gestures',
    'Scroll motion': 'scroll-motion',
    'Accessibility': 'accessibility',
    'Performance': 'performance',
  };

  static const packages = <PackageInfo>[
    PackageInfo(
      id: 'motion',
      name: 'NibMotion',
      role: '01 / INTERACTION LAYER',
      tagline: 'One motion model. From a press to a whole interface.',
      description: 'NibMotion connects state, motion values and interruptible drivers across gestures, layout, scroll, timelines and visual effects. Start with a target on one Flutter widget; use the same model as the interaction grows. It depends only on the Flutter SDK.',
      status: 'Published on pub.dev · $motionPublishedVersion',
      install: 'flutter pub add nib_motion',
      capabilities: [
        'Declarative motion',
        'Physics and interactive gestures',
        'Layout and presence',
        'Scroll and orchestration',
        'Visual effects and expressive interfaces',
        'Developer tooling, performance and accessibility',
      ],
      caution: motionReleaseNote,
    ),
    PackageInfo(
      id: 'components',
      name: 'NibComponents',
      role: '02 / INTERFACE LAYER',
      tagline: 'Good controls, ready for real state.',
      description: 'Buttons, forms, overlays, navigation and data widgets built for Flutter. Motion is an actual package dependency.',
      status: 'Available on pub.dev',
      install: 'flutter pub add nib_components',
      capabilities: [
        '30+ themed widgets',
        'Flutter form and controlled-state patterns',
        'Optional animated state changes',
      ],
      caution: 'Component behavior varies by widget. Use the API notes and test each control in the host app.',
    ),
    PackageInfo(
      id: 'genui',
      name: 'NibGenUI',
      role: '03 / EXPERIMENTAL LAYER',
      tagline: 'A bounded path from data to native UI.',
      description: 'A local A2UI v0.9.1 subset renders registered Flutter components from structured messages. Try its fixture replay while release gates remain open.',
      status: 'Local preview · unpublished',
      install: null,
      capabilities: [
        'Four accepted A2UI message envelopes',
        'Text, Column, Button and TextField built in',
        'Host-registered actions and local bindings',
      ],
      caution: 'This is a tested subset, not full protocol conformance or a public package install. No live AI request runs on this site.',
    ),
  ];

  static final articles = <DocArticle>[
    ...detailedMotionGuides,
    ...detailedEcosystemGuides.where(
      (article) => !componentSupportArticles.any(
        (support) => support.route == article.route,
      ),
    ),
    ...componentSupportArticles,
    ...componentGuides.map((guide) => guide.article),
  ];

  static PackageInfo? packageById(String id) {
    for (final package in packages) {
      if (package.id == id) return package;
    }
    return null;
  }

  static DocArticle? articleById(String packageId, String id) {
    if (packageId == 'components' && id == 'textarea') id = 'input';
    for (final article in articles) {
      if (article.packageId == packageId && article.id == id) return article;
    }
    return null;
  }

  static List<DocArticle> articlesFor(String packageId) {
    final result = [
      for (final article in articles)
        if (article.packageId == packageId) article,
    ];
    if (learningPaths[packageId] case final groups?) {
      final order = groups.values.expand((ids) => ids).toList();
      final originalIndex = {
        for (var i = 0; i < result.length; i++) result[i].id: i,
      };
      int rank(DocArticle article) {
        final index = order.indexOf(article.id);
        return index < 0 ? order.length : index;
      }

      result.sort((a, b) {
        final byReference = rank(a).compareTo(rank(b));
        return byReference != 0
            ? byReference
            : originalIndex[a.id]!.compareTo(originalIndex[b.id]!);
      });
    }
    return result;
  }
}
