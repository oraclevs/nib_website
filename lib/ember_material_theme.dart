import 'package:flutter/material.dart';

/// Complete Material palette for Ember previews and their copied examples.
/// Explicit container roles prevent SDK fallback blue/teal from leaking in.
ColorScheme emberColorScheme({Color accent = const Color(0xFFFFB51B)}) =>
    ColorScheme.dark(
      primary: accent,
      onPrimary: const Color(0xFF241A05),
      primaryContainer: const Color(0xFF332A15),
      onPrimaryContainer: const Color(0xFFF4E8C8),
      secondary: accent,
      onSecondary: const Color(0xFF241A05),
      secondaryContainer: const Color(0xFF262922),
      onSecondaryContainer: const Color(0xFFF4E8C8),
      tertiary: const Color(0xFFCFDEA0),
      onTertiary: const Color(0xFF241A05),
      tertiaryContainer: const Color(0xFF332A15),
      onTertiaryContainer: const Color(0xFFF4E8C8),
      error: const Color(0xFFFFAEA3),
      onError: const Color(0xFF241A05),
      errorContainer: const Color(0xFF59322A),
      onErrorContainer: const Color(0xFFF4E8C8),
      surface: const Color(0xFF1B1D19),
      onSurface: const Color(0xFFF4E8C8),
      onSurfaceVariant: const Color(0xFFB8B5A4),
      surfaceDim: const Color(0xFF111210),
      surfaceBright: const Color(0xFF262922),
      surfaceContainerLowest: const Color(0xFF111210),
      surfaceContainerLow: const Color(0xFF151711),
      surfaceContainer: const Color(0xFF1B1D19),
      surfaceContainerHigh: const Color(0xFF262922),
      surfaceContainerHighest: const Color(0xFF393D33),
      outline: const Color(0xFF393D33),
      outlineVariant: const Color(0xFF393D33),
      surfaceTint: Colors.transparent,
      inverseSurface: const Color(0xFFF4E8C8),
      onInverseSurface: const Color(0xFF111210),
      inversePrimary: const Color(0xFF735923),
      primaryFixed: accent,
      primaryFixedDim: const Color(0xFFCFDEA0),
      onPrimaryFixed: const Color(0xFF241A05),
      onPrimaryFixedVariant: const Color(0xFF241A05),
      secondaryFixed: const Color(0xFFCFDEA0),
      secondaryFixedDim: const Color(0xFFB8B5A4),
      onSecondaryFixed: const Color(0xFF241A05),
      onSecondaryFixedVariant: const Color(0xFF241A05),
      tertiaryFixed: const Color(0xFFF4E8C8),
      tertiaryFixedDim: const Color(0xFFCFDEA0),
      onTertiaryFixed: const Color(0xFF241A05),
      onTertiaryFixedVariant: const Color(0xFF241A05),
    );

ThemeData emberMaterialTheme({Color accent = const Color(0xFFFFB51B)}) {
  final colors = emberColorScheme(accent: accent);
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(5));
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF111210),
    fontFamily: 'Ember Sans',
    colorScheme: colors,
    dividerColor: colors.outline,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: Color(0xFFF4E8C8),
        fontSize: 15,
        height: 1.55,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: colors.surface,
      selectedColor: colors.primaryContainer,
      secondarySelectedColor: colors.primaryContainer,
      checkmarkColor: colors.primary,
      labelStyle: TextStyle(color: colors.onSurfaceVariant),
      secondaryLabelStyle: TextStyle(color: colors.primary),
      side: WidgetStateBorderSide.resolveWith(
        (states) => BorderSide(
          color: states.contains(WidgetState.selected)
              ? colors.primary.withValues(alpha: .55)
              : colors.outline,
        ),
      ),
      shape: shape,
      elevation: 0,
      pressElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.onSurface,
        side: BorderSide(color: colors.outline),
        shape: shape,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(shape: shape),
    ),
  );
}
