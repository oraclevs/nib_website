import 'spring_retarget_recipe.dart';

const springRetargetSourceAsset = 'lib/recipes/spring_retarget_recipe.dart';

/// The launcher is generated from the same settings object used by the live
/// preview. Copy it beside spring_retarget_recipe.dart in a Flutter app's lib/.
String springRetargetLauncher(SpringRetargetSettings settings) =>
    '''
import 'package:flutter/material.dart';

import 'spring_retarget_recipe.dart';

void main() => runApp(
  const MaterialApp(
    home: Scaffold(
      backgroundColor: Color(0xFF111210),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: SpringRetargetRecipe(
            settings: SpringRetargetSettings(
              distance: ${settings.distance.toString()},
              stiffness: ${settings.stiffness.toString()},
              damping: ${settings.damping.toString()},
              mass: ${settings.mass.toString()},
            ),
          ),
        ),
      ),
    ),
  ),
);
''';

SpringRetargetSettings springRetargetSettingsFromQuery(
  Map<String, String> query,
) {
  double value(String key, double fallback, double min, double max) {
    final parsed = double.tryParse(query[key] ?? '');
    if (parsed == null || !parsed.isFinite) return fallback;
    return parsed.clamp(min, max).toDouble();
  }

  return SpringRetargetSettings(
    distance: value('distance', 144, 40, 180),
    stiffness: value('stiffness', 180, 80, 420),
    damping: value('damping', 18, 6, 45),
    mass: value('mass', 1, .4, 2.5),
  );
}

Uri springRetargetUri(SpringRetargetSettings settings) => Uri(
  path: '/playground/spring-retarget',
  queryParameters: {
    'distance': settings.distance.toStringAsFixed(0),
    'stiffness': settings.stiffness.toStringAsFixed(0),
    'damping': settings.damping.toStringAsFixed(0),
    'mass': settings.mass.toStringAsFixed(2),
  },
);
