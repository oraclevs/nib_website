import 'package:flutter/services.dart';

import 'component_model.dart';
import 'component_settings.dart';

/// A small runnable `main.dart` built from the guide's focused usage sample.
/// Stateful controls keep the value they report in the host widget.
String componentShortSource(ComponentGuide guide) {
  if (guide.id == 'liquid-glass') return guide.minimalCode;

  var usage = guide.minimalCode
      .replaceAll(
        RegExp(r'''^import\s+['"][^'"]+['"][^;]*;\s*''', multiLine: true),
        '',
      )
      .trim();
  var state = '';
  switch (guide.id) {
    case 'navigation-menu':
      usage = usage.replaceFirst("String selected = 'home';", '').trim();
      state = "String selected = 'home';";
    case 'glass-bottom-navigation':
    case 'liquid-bottom-navigation':
      state = 'int selectedIndex = 0;';
    case 'pagination':
      state = 'int page = 1;';
    case 'checkbox':
      state = 'bool included = false;';
    case 'switch':
      state = 'bool enabled = true;';
    case 'radio-group':
      state = "String? frequency = 'daily';";
    case 'toggle-group':
      state = "String? style = 'bold';";
    case 'slider':
      state = 'double volume = 40;';
    case 'date-picker':
      state = 'DateTime? selected;';
  }

  final isAction = const {
    'alert-dialog',
    'dialog',
    'bottom-sheet',
    'toast',
  }.contains(guide.id);
  if (guide.id == 'bottom-sheet' || guide.id == 'dialog') {
    usage = usage.replaceFirst('final result = await ', 'await ');
  }
  if (guide.id == 'toast') {
    usage = usage.replaceFirst('final id = showNibToast(', 'showNibToast(');
    usage = usage.replaceFirst(
      RegExp(r'\n// If the operation is cancelled elsewhere:[\s\S]*$'),
      '',
    );
  }
  final child = isAction
      ? '''NibButton(
            label: 'Open ${guide.title}',
            onPressed: () async {
              $usage
            },
          )'''
      : usage;
  final componentsImport = guide.composition
      ? ''
      : "import 'package:nib_components/nib_components.dart';";
  final motionImport = switch (guide.id) {
    'glass-bottom-navigation' || 'liquid-bottom-navigation' =>
      "import 'package:nib_motion/nib_motion.dart' as motion;",
    'switch' =>
      "import 'package:nib_motion/nib_motion.dart' show NibTransition;",
    _ => '',
  };
  return '''import 'package:flutter/material.dart';
$componentsImport
$motionImport

void main() => runApp(const MaterialApp(home: ShortExample()));

class ShortExample extends StatefulWidget {
  const ShortExample({super.key});

  @override
  State<ShortExample> createState() => _ShortExampleState();
}

class _ShortExampleState extends State<ShortExample> {
  $state

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: $child,
        ),
      ),
    ),
  );
}
''';
}

/// The website's demo file, including its original imports and comments.
Future<String> componentDemoSource(ComponentGuide guide) =>
    rootBundle.loadString(guide.demoFile);

/// The full example uses the same demo implementation as the preview.
Future<String> componentRunnableSource(
  ComponentGuide guide,
  ComponentSettings settings,
) async {
  final paths = [
    'lib/ember_material_theme.dart',
    'lib/components/component_settings.dart',
    'lib/components/component_theme.dart',
    if (guide.id == 'switch' ||
        guide.demoFile.endsWith('selection_family_demos.dart'))
      'lib/components/component_toggle.dart',
    guide.demoFile,
  ];
  final imports = <String>{};
  final bodies = <String>[];
  final directive = RegExp(
    r"""^import\s+['"]([^'"]+)['"][^;]*;\s*""",
    multiLine: true,
  );
  for (final path in paths) {
    final source = await rootBundle.loadString(path);
    for (final match in directive.allMatches(source)) {
      if (match[1]!.startsWith('package:') || match[1]!.startsWith('dart:')) {
        imports.add(match[0]!.trim());
      }
    }
    bodies.add(source.replaceAll(directive, '').trim());
  }
  return '''// Complete configured example. Dependencies: flutter, nib_components, nib_motion.
// The website verifies local candidate packages; see the guide's version note.
${imports.join('\n')}

${bodies.join('\n\n')}

void main() => runApp(const ComponentExampleApp());

class ComponentExampleApp extends StatefulWidget {
  const ComponentExampleApp({super.key});
  @override
  State<ComponentExampleApp> createState() => _ComponentExampleAppState();
}
class _ComponentExampleAppState extends State<ComponentExampleApp> {
  ComponentSettings settings = ${settings.dartSource};
  String lastEvent = 'Ready';
  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: componentEmberTheme(accent: settings.accent, radius: settings.radius),
    home: Scaffold(body: SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ${guide.demoClass}(
          settings: settings,
          onChanged: (next) => setState(() => settings = next),
          onEvent: (event) => setState(() => lastEvent = event),
        ),
        const SizedBox(height: 20),
        Text(lastEvent, semanticsLabel: 'Last component event: \$lastEvent'),
      ]),
    ))),
  );
}
''';
}
