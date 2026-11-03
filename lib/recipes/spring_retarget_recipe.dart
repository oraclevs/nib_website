import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

/// The same typed settings are used by the preview and its exported launcher.
@immutable
class SpringRetargetSettings {
  const SpringRetargetSettings({
    this.distance = 144,
    this.stiffness = 180,
    this.damping = 18,
    this.mass = 1,
  }) : assert(distance >= 40 && distance <= 180),
       assert(stiffness >= 80 && stiffness <= 420),
       assert(damping >= 6 && damping <= 45),
       assert(mass >= .4 && mass <= 2.5);

  final double distance;
  final double stiffness;
  final double damping;
  final double mass;

  SpringRetargetSettings copyWith({
    double? distance,
    double? stiffness,
    double? damping,
    double? mass,
  }) => SpringRetargetSettings(
    distance: distance ?? this.distance,
    stiffness: stiffness ?? this.stiffness,
    damping: damping ?? this.damping,
    mass: mass ?? this.mass,
  );
}

/// A spring that accepts a new destination before the previous move settles.
/// Tap repeatedly to see the current position and velocity carry into the
/// next target. NibMotion handles the retargeting; this widget owns only the
/// target selection and disposes it with the route.
class SpringRetargetRecipe extends StatefulWidget {
  const SpringRetargetRecipe({
    super.key,
    this.settings = const SpringRetargetSettings(),
  });

  final SpringRetargetSettings settings;

  @override
  State<SpringRetargetRecipe> createState() => _SpringRetargetRecipeState();
}

class _SpringRetargetRecipeState extends State<SpringRetargetRecipe> {
  bool toRight = false;

  void retarget() => setState(() => toRight = !toRight);

  void reset() => setState(() => toRight = false);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      final width = math.min(bounds.maxWidth, 420.0);
      final travel = widget.settings.distance
          .clamp(0.0, math.max(0.0, width - 84))
          .toDouble();
      return Center(
        child: SizedBox(
          width: width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Retarget the spring',
                style: TextStyle(
                  color: Color(0xFFF4E8C8),
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Tap again before it settles. The motion changes course.',
                style: TextStyle(color: Color(0xFFB8B5A4), fontSize: 12),
              ),
              const SizedBox(height: 22),
              Container(
                height: 90,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF151711),
                  border: Border.all(color: const Color(0xFF393D33)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: NibMotion(
                    initial: const NibAnim(x: 0),
                    animate: NibAnim(x: toRight ? travel : 0),
                    transition: NibTransition(
                      spring: NibSpringDescription(
                        mass: widget.settings.mass,
                        stiffness: widget.settings.stiffness,
                        damping: widget.settings.damping,
                      ),
                    ),
                    child: Semantics(
                      label: 'Spring position marker',
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB51B),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Color(0xFF241A05),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: retarget,
                    icon: const Icon(Icons.swap_horiz),
                    label: Text(toRight ? 'Send left' : 'Send right'),
                  ),
                  OutlinedButton(
                    onPressed: reset,
                    child: const Text('Reset target'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
