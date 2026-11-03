import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

import 'component_settings.dart';
import 'component_theme.dart';

/// Keeps nearest-overlay controls local; root helpers are deliberately page-modal.
/// Retains access to Flutter View for text editing, focus, and input connections.
class ComponentPreview extends StatelessWidget {
  const ComponentPreview({
    super.key,
    required this.child,
    required this.settings,
    this.height = 360,
    this.paused = false,
  });
  final Widget child;
  final ComponentSettings settings;
  final double height;
  final bool paused;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: ClipRect(
      child: Theme(
        data: componentEmberTheme(
          accent: settings.accent,
          radius: settings.radius,
        ),
        child: TickerMode(
          enabled: !paused,
          child: NibMotionConfig(
            reducedMotion: MediaQuery.disableAnimationsOf(context),
            child: Navigator(
              onDidRemovePage: (_) {},
              pages: [
                MaterialPage<void>(
                  key: const ValueKey('component-preview-route'),
                  child: Material(
                    color: Colors.transparent,
                    child: SingleChildScrollView(
                      primary: false,
                      padding: const EdgeInsets.all(20),
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
