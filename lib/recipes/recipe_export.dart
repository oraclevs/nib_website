import '../docs/motion_minimal_examples.dart';
import 'recipe_catalog.dart';
import 'recipe_tuning.dart';
import 'spring_retarget_export.dart';
import 'spring_retarget_recipe.dart';

typedef RecipeConfiguration = ({double value, RecipeTuning tuning});

/// Parses only settings exposed by this recipe. Unknown query keys are ignored.
/// Non-finite and invalid values fall back to the documented defaults.
RecipeConfiguration recipeConfigurationFromUri(
  RecipeDefinition recipe,
  Uri location,
) {
  var tuning = defaultRecipeTuning(recipe);
  if (location.path != recipe.route) {
    return (value: recipe.initial, tuning: tuning);
  }
  var primary = recipe.initial;
  for (final control in recipeControls(recipe)) {
    final key = control.field?.name ?? 'value';
    final parsed = double.tryParse(location.queryParameters[key] ?? '');
    final value = parsed == null || !parsed.isFinite
        ? control.initial
        : parsed.clamp(control.minimum, control.maximum).toDouble();
    if (control.field == null) {
      primary = value;
    } else {
      tuning = tuning.withField(control.field!, value);
    }
  }
  if (recipeHasOption(recipe)) {
    tuning = tuning.copyWith(
      option: switch (location.queryParameters['option']) {
        '1' => true,
        '0' => false,
        _ => recipeDefaultOption(recipe),
      },
    );
  }
  if (recipeHasEase(recipe)) {
    tuning = tuning.copyWith(
      ease: RecipeEase.values.firstWhere(
        (value) => value.name == location.queryParameters['ease'],
        orElse: () => RecipeEase.easeInOut,
      ),
    );
  }
  if (recipeHasRelease(recipe)) {
    tuning = tuning.copyWith(
      release: RecipeDragRelease.values.firstWhere(
        (value) => value.name == location.queryParameters['release'],
        orElse: () => RecipeDragRelease.springBack,
      ),
    );
  }
  return (value: primary, tuning: tuning);
}

double recipeValueFromUri(RecipeDefinition recipe, Uri location) =>
    recipeConfigurationFromUri(recipe, location).value;

Uri recipeShareUri(
  RecipeDefinition recipe,
  double selectedValue,
  RecipeTuning tuning,
  Uri base,
) {
  final query = <String, String>{};
  for (final control in recipeControls(recipe)) {
    final key = control.field?.name ?? 'value';
    final raw = control.field == null
        ? selectedValue
        : tuning.getField(control.field!);
    final value = raw.isFinite
        ? raw.clamp(control.minimum, control.maximum).toDouble()
        : control.initial;
    query[key] = value.toString();
  }
  if (recipeHasOption(recipe)) query['option'] = tuning.option ? '1' : '0';
  if (recipeHasEase(recipe)) query['ease'] = tuning.ease.name;
  if (recipeHasRelease(recipe)) query['release'] = tuning.release.name;
  return base.replace(path: recipe.route, queryParameters: query, fragment: '');
}

/// The launcher uses the same bounded config as the live preview. Place its
/// companion source files beside main.dart in a Flutter app's lib/ directory.
String recipeLauncher(
  RecipeDefinition recipe,
  double selectedValue, [
  RecipeTuning? settings,
]) {
  final launcher = _recipeLauncher(recipe, selectedValue, settings);
  final theme = _recipeUsesComponents(recipe)
      ? 'componentEmberTheme'
      : 'emberMaterialTheme';
  final themeImport = _recipeUsesComponents(recipe)
      ? "import 'component_theme.dart';"
      : "import 'ember_material_theme.dart';";
  return '$themeImport\n$launcher'
      .replaceAll('theme: ThemeData.dark(),', 'theme: $theme(),')
      .replaceAll('const MaterialApp(', 'MaterialApp(\n    theme: $theme(),');
}

bool _recipeUsesComponents(RecipeDefinition recipe) {
  final example = recipe.documentationExample;
  return example == null
      ? recipe.id != 'spring-retarget'
      : example.sourceAsset.contains('/components_') ||
            example.sourceAsset.contains('/genui_');
}

String _recipeLauncher(
  RecipeDefinition recipe,
  double selectedValue,
  RecipeTuning? settings,
) {
  final example = recipe.documentationExample;
  if (example != null) {
    final motionImport = example.constructorArguments.contains('Nib')
        ? "import 'package:nib_motion/nib_motion.dart';"
        : '';
    return '''
import 'package:flutter/material.dart';
$motionImport
import '${recipe.sourceAsset.split('/').last}';

void main() => runApp(MaterialApp(
  theme: ThemeData.dark(),
  home: Scaffold(body: SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Center(child: SizedBox(width: 720,
      child: ${example.widgetClass}(${example.constructorArguments}),
    )),
  )),
));
''';
  }
  final tuning = settings ?? defaultRecipeTuning(recipe);
  final normalized = recipeConfigurationFromUri(
    recipe,
    recipeShareUri(recipe, selectedValue, tuning, Uri(path: recipe.route)),
  );
  final value = normalized.value;
  final safe = normalized.tuning;
  if (recipe.id == 'spring-retarget') {
    return springRetargetLauncher(
      SpringRetargetSettings(
        distance: value,
        stiffness: safe.stiffness,
        damping: safe.damping,
        mass: safe.mass,
      ),
    );
  }
  final secondary = safe.secondary == null
      ? 'null'
      : safe.secondary!.toString();
  return '''
import 'package:flutter/material.dart';
import 'recipe_runtime.dart';
import 'recipe_tuning.dart';

void main() => runApp(
  const MaterialApp(
    home: Scaffold(
      backgroundColor: Color(0xFF111210),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: RecipeRuntime(
            recipeId: '${recipe.id}',
            value: ${value.toString()},
            settings: RecipeTuning(
              durationMs: ${safe.durationMs.toString()},
              stiffness: ${safe.stiffness.toString()},
              damping: ${safe.damping.toString()},
              mass: ${safe.mass.toString()},
              secondary: $secondary,
              elasticity: ${safe.elasticity.toString()},
              opacity: ${safe.opacity.toString()},
              scale: ${safe.scale.toString()},
              option: ${safe.option},
              ease: RecipeEase.${safe.ease.name},
              release: RecipeDragRelease.${safe.release.name},
            ),
          ),
        ),
      ),
    ),
  ),
);
''';
}

/// Combines the exact bundled source and current launcher into one main.dart.
/// Only local companion imports are removed; public package imports remain.
String recipeRunnableExample(
  RecipeDefinition recipe,
  double selectedValue,
  RecipeTuning settings,
  String source,
  String themeSource, [
  String? tuningSource,
  String? componentThemeSource,
  String? toggleSource,
]) {
  if (recipe.documentationExample == null &&
      recipe.id != 'spring-retarget' &&
      tuningSource == null) {
    throw ArgumentError('recipe_tuning.dart source is required');
  }
  if (_recipeUsesComponents(recipe) && componentThemeSource == null) {
    throw ArgumentError('component_theme.dart source is required');
  }
  if (source.contains('component_toggle.dart') && toggleSource == null) {
    throw ArgumentError('component_toggle.dart source is required');
  }
  final imports = <String>{};
  final bodies = <String>[];
  final directive = RegExp(r'''^import ['"]([^'"]+)['"][^;]*;\s*$''');
  for (final file in [
    themeSource,
    if (source.contains('component_toggle.dart')) toggleSource!,
    if (_recipeUsesComponents(recipe)) componentThemeSource!,
    source,
    if (recipe.documentationExample == null && recipe.id != 'spring-retarget')
      tuningSource!,
    recipeLauncher(recipe, selectedValue, settings),
  ]) {
    final body = <String>[];
    for (final line in file.split('\n')) {
      final match = directive.firstMatch(line);
      if (match == null) {
        body.add(line);
        continue;
      }
      final uri = match.group(1)!;
      if (uri.startsWith('dart:') || uri.startsWith('package:')) {
        imports.add(line);
      }
    }
    bodies.add(body.join('\n').trim());
  }
  // material.dart exports these two libraries; avoid redundant imports.
  if (imports.contains("import 'package:flutter/material.dart';")) {
    imports.remove("import 'package:flutter/animation.dart';");
    imports.remove("import 'package:flutter/foundation.dart';");
  }
  return '// Add nib_motion and nib_components to your Flutter app.\n'
      '// Uses the local candidate APIs documented by this website.\n'
      '${imports.join('\n')}\n\n${bodies.join('\n\n')}\n';
}

/// A standalone primitive example, without the website's exercise framework.
String? recipeMinimalExample(
  RecipeDefinition recipe,
  double value,
  RecipeTuning settings,
) {
  if (recipe.documentationExample case final example?) {
    return minimalDocExample(example);
  }
  final family = switch (recipe.id) {
    'spring-retarget' => 'spring',
    'progress-choreography' => 'progress',
    'spring-tween' => 'compare',
    'animated-counter' => 'counter',
    'pivot-turn' => 'pivot',
    'keyframe-hop' || 'onboarding-sequence' => 'keyframes',
    'linked-objects' => 'linked',
    'card-flip' => 'flip',
    'bounded-drag' => 'drag',
    'drag-snap' => 'snap',
    'swipe-restore' => 'swipe',
    'hover-press' => 'hover',
    'keyed-reorder' => 'layout',
    'selection-indicator' => 'selection',
    'presence-reflow' ||
    'filtered-list' ||
    'focus-overlay' ||
    'loading-result' ||
    'command-palette' => 'presence',
    'stagger-list' => 'stagger',
    'variant-orchestration' => 'variants',
    'viewport-reveal' => 'viewport',
    'local-parallax' => 'parallax',
    'scroll-progress' => 'scroll',
    'page-transition' => 'navigation',
    'tab-content' => 'tab',
    'expanding-card' => 'expand',
    'form-validation' => 'validation',
    'accordion' => 'accordion',
    _ => null,
  };
  if (family == null) return null;
  final config = recipeConfigurationFromUri(
    recipe,
    recipeShareUri(recipe, value, settings, Uri(path: recipe.route)),
  );
  return minimalMotionExample(
    family,
    distance: config.value,
    durationMs: config.tuning.durationMs,
    stiffness: config.tuning.stiffness,
    damping: config.tuning.damping,
    mass: config.tuning.mass,
  );
}
