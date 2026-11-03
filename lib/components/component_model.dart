import 'package:flutter/widgets.dart';

import '../content/site_content.dart';
import 'component_settings.dart';

enum ComponentControlKind { toggle, number, choice, text }

class ComponentControl {
  const ComponentControl(
    this.key,
    this.label,
    this.kind, {
    this.minimum = 0,
    this.maximum = 1,
    this.choices = const [],
    this.help,
    this.advanced = false,
    this.visibleWhenKey,
    this.visibleWhenValue,
    this.visibleWhen = const {},
  });
  final String key, label;
  final ComponentControlKind kind;
  final double minimum, maximum;
  final List<String> choices;
  final String? help;
  final bool advanced;
  final String? visibleWhenKey;
  final Object? visibleWhenValue;
  final Map<String, Object> visibleWhen;
  bool isVisible(ComponentSettings settings) =>
      (visibleWhenKey == null ||
          settings.values[visibleWhenKey] == visibleWhenValue) &&
      visibleWhen.entries.every(
        (entry) => settings.values[entry.key] == entry.value,
      );
}

typedef ComponentDemoBuilder = Widget Function(
  String id,
  ComponentSettings settings,
  ValueChanged<ComponentSettings> onChanged,
  ValueChanged<String> onEvent,
);

class ComponentGuide {
  const ComponentGuide({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.symbols,
    required this.source,
    required this.demoClass,
    required this.demoFile,
    required this.minimalCode,
    required this.sections,
    this.controls = const [],
    ComponentSettings initial = const ComponentSettings(),
    this.composition = false,
    this.apiPackageId = 'components',
    this.previewHeight = 320,
    this.limitations = const [],
    // Keep the public argument named initial; the getter applies site defaults.
    // ignore: prefer_initializing_formals
  }) : _initial = initial;
  final String id, title, category, summary, source;
  final String apiPackageId;
  final String demoClass, demoFile, minimalCode;
  final List<String> symbols, limitations;
  final List<DocSection> sections;
  final List<ComponentControl> controls;
  final ComponentSettings _initial;

  /// Website showcase starts animated; package constructor defaults stay unchanged.
  ComponentSettings get initial => _initial.change('animated', true);
  final bool composition;
  final double previewHeight;
  String get route => '/docs/components/$id';
  String get playgroundRoute => '/playground/components/$id';
  DocArticle get article => DocArticle(
    packageId: 'components',
    id: id,
    title: title,
    summary: summary,
    evidence: source,
    sections: [
      ...sections,
      if (limitations.isNotEmpty)
        DocSection(
          id: 'component-limits',
          heading: 'Limits and platform evidence',
          paragraphs: limitations,
        ),
    ],
  );
}
