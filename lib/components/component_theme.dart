import 'package:flutter/material.dart';
import 'package:nib_components/nib_components.dart';

import '../ember_material_theme.dart';

/// Ember belongs to the preview's inherited Theme, including captured overlays.
ThemeData componentEmberTheme({int accent = 0xFFFFB51B, double radius = 8}) {
  final nib = NibTheme.dark.copyWith(
    background: const Color(0xFF111210),
    foreground: const Color(0xFFF4E8C8),
    card: const Color(0xFF1B1D19),
    cardForeground: const Color(0xFFF4E8C8),
    primary: Color(accent),
    primaryForeground: const Color(0xFF241A05),
    secondary: const Color(0xFF262922),
    secondaryForeground: const Color(0xFFF4E8C8),
    muted: const Color(0xFF262922),
    mutedForeground: const Color(0xFFB8B5A4),
    accent: Color(accent),
    accentForeground: const Color(0xFF241A05),
    border: const Color(0xFF393D33),
    input: const Color(0xFF393D33),
    ring: Color(accent),
    destructive: const Color(0xFFFFAEA3),
    radiusSm: radius / 2,
    radiusDefault: radius,
    radiusLg: radius * 1.5,
  );
  final base = emberMaterialTheme(accent: Color(accent));
  return base.copyWith(
    extensions: [nib],
    textTheme: base.textTheme.copyWith(
      bodyMedium: base.textTheme.bodyMedium!.copyWith(
        fontSize: 14,
        height: 1.5,
      ),
    ),
  );
}
