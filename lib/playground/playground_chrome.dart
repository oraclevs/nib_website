import 'package:flutter/material.dart';

import '../ember_theme.dart';

// Shared by Motion and Components: one set of panels, dimensions and controls.
ThemeData playgroundTheme(BuildContext context) {
  final base = Theme.of(context);
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(5));
  final common = ButtonStyle(
    shape: WidgetStatePropertyAll(shape),
    minimumSize: const WidgetStatePropertyAll(Size(0, 38)),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 13, vertical: 10),
    ),
    textStyle: const WidgetStatePropertyAll(
      TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        fontFamily: 'Ember Sans',
      ),
    ),
    overlayColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.focused)
          ? Ember.accent.withValues(alpha: .18)
          : states.contains(WidgetState.hovered)
          ? Ember.accent.withValues(alpha: .08)
          : null,
    ),
  );
  return base.copyWith(
    filledButtonTheme: FilledButtonThemeData(
      style: common.copyWith(
        foregroundColor: const WidgetStatePropertyAll(Ember.onAccent),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? Ember.raised
              : Ember.accent,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: common.copyWith(
        foregroundColor: const WidgetStatePropertyAll(Ember.text),
        side: WidgetStateProperty.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.focused)
                ? Ember.accent
                : Ember.border,
          ),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: common.copyWith(
        foregroundColor: const WidgetStatePropertyAll(Ember.text),
      ),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: Ember.bg,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Ember.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Ember.accent),
      ),
    ),
    sliderTheme: base.sliderTheme.copyWith(
      trackHeight: 3,
      activeTrackColor: Ember.accent,
      inactiveTrackColor: Ember.border,
      thumbColor: Ember.accent,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
      showValueIndicator: ShowValueIndicator.never,
    ),
  );
}

class PlaygroundPanel extends StatelessWidget {
  const PlaygroundPanel({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Material(
    color: Ember.panel,
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: Ember.border),
      borderRadius: BorderRadius.circular(7),
    ),
    clipBehavior: Clip.antiAlias,
    child: child,
  );
}

class PlaygroundWorkspace extends StatelessWidget {
  const PlaygroundWorkspace({
    super.key,
    required this.width,
    required this.titlebar,
    required this.dock,
    required this.browser,
    required this.preview,
    required this.inspector,
    this.footer = const SizedBox.shrink(),
  });
  final double width;
  final Widget titlebar, dock, browser, preview, inspector, footer;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            titlebar,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width < 1200 ? 32 : 56),
              child: dock,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                width < 1200 ? 28 : 40,
                0,
                width < 1200 ? 28 : 40,
                34,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: width < 850
                        ? 150
                        : width < 1200
                        ? 170
                        : 190,
                    height: 660,
                    child: PlaygroundPanel(child: browser),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        preview,
                        if (width < 1200) ...[
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 590,
                            child: PlaygroundPanel(child: inspector),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (width >= 1200) ...[
                    const SizedBox(width: 18),
                    SizedBox(
                      width: 290,
                      height: 660,
                      child: PlaygroundPanel(child: inspector),
                    ),
                  ],
                ],
              ),
            ),
            footer,
          ],
        ),
      ),
    ),
  );
}

class PlaygroundDots extends CustomPainter {
  const PlaygroundDots();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF454A39);
    for (var x = 11.0; x < size.width; x += 22) {
      for (var y = 11.0; y < size.height; y += 22) {
        canvas.drawCircle(Offset(x, y), .8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PlaygroundDots oldDelegate) => false;
}
