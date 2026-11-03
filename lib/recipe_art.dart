import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'ember_theme.dart';

/// Decorative previews. The surrounding recipe link opens the interactive lab.
class RecipeArt extends StatelessWidget {
  const RecipeArt({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.expand(
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(child: OrbitRings()),
          if (index == 0) ...[
            Transform.rotate(
              angle: -.19,
              child: Container(
                width: 103,
                height: 123,
                decoration: BoxDecoration(
                  color: Ember.raised,
                  border: Border.all(color: Ember.strong),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
            EmberFloat(
              y: 9,
              x: 3,
              turn: .014,
              child: Transform.rotate(
                angle: -.06,
                child: Container(
                  width: 118,
                  height: 123,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Ember.accent,
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x55000000),
                        blurRadius: 22,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'NIB / MOTION',
                        style: TextStyle(
                          fontFamily: Ember.mono,
                          color: Ember.onAccent,
                          fontSize: 7,
                        ),
                      ),
                      Text(
                        'A new\nperspective.',
                        style: TextStyle(
                          color: Ember.onAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.05,
                          letterSpacing: -.7,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.arrow_forward,
                          color: Ember.onAccent,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else if (index == 1) ...[
            Container(
              width: 228,
              height: 66,
              decoration: BoxDecoration(
                border: Border.all(color: Ember.border),
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            const EmberFloat(
              x: 66,
              y: 4,
              turn: .025,
              duration: Duration(milliseconds: 2100),
              child: _ArtPuck(),
            ),
            const Positioned(
              bottom: 14,
              child: Text(
                'A LITTLE GIVE. A LOT OF FEEL.',
                style: TextStyle(
                  fontFamily: Ember.mono,
                  color: Ember.muted,
                  fontSize: 8,
                  letterSpacing: .6,
                ),
              ),
            ),
          ] else
            SizedBox(
              width: 196,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < 3; i++)
                    EmberFloat(
                      y: 3,
                      x: i == 1 ? -10 : 6,
                      reverse: i == 1,
                      duration: Duration(milliseconds: 2600 + i * 400),
                      child: Container(
                        height: 34,
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: i == 1 ? Ember.soft : Ember.panel,
                          border: Border.all(
                            color: i == 1
                                ? Ember.accent.withValues(alpha: .4)
                                : Ember.border,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '0${i + 1}',
                              style: const TextStyle(
                                fontFamily: Ember.mono,
                                fontSize: 8,
                                color: Ember.muted,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                ['Motion', 'Components', 'Generative UI'][i],
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                            const Icon(
                              Icons.drag_indicator,
                              size: 12,
                              color: Ember.accent,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

class _ArtPuck extends StatelessWidget {
  const _ArtPuck();
  @override
  Widget build(BuildContext context) => Container(
    width: 46,
    height: 46,
    decoration: BoxDecoration(
      color: Ember.accent,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Ember.accent.withValues(alpha: .16), blurRadius: 24),
      ],
    ),
    child: const Icon(Icons.drag_indicator, size: 20, color: Ember.onAccent),
  );
}

class OrbitRings extends StatelessWidget {
  const OrbitRings({super.key});
  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Stack(
      fit: StackFit.expand,
      children: [
        EmberFloat(
          y: 3,
          turn: .025,
          duration: const Duration(milliseconds: 5200),
          child: CustomPaint(painter: _RingPainter()),
        ),
        EmberFloat(
          y: 2,
          turn: -.035,
          reverse: true,
          duration: const Duration(milliseconds: 6700),
          child: CustomPaint(painter: _RingPainter(second: true)),
        ),
      ],
    ),
  );
}

class _RingPainter extends CustomPainter {
  _RingPainter({this.second = false});
  final bool second;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate((second ? 35 : -20) * math.pi / 180);
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: math.min(size.width * .92, second ? 245 : 285),
      height: math.min(size.height * .92, second ? 295 : 245),
    );
    final paint = Paint()
      ..color = Ember.accent.withValues(alpha: second ? .16 : .23)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    if (second) {
      for (var angle = 0.0; angle < math.pi * 2; angle += .065) {
        canvas.drawArc(rect, angle, .028, false, paint);
      }
    } else {
      canvas.drawOval(rect, paint);
    }
    final angle = second ? 1.2 : 4.1;
    final dot = Offset(
      rect.width / 2 * math.cos(angle),
      rect.height / 2 * math.sin(angle),
    );
    final color = second ? Ember.positive : Ember.accent;
    canvas.drawCircle(
      dot,
      7,
      Paint()
        ..color = color.withValues(alpha: .4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(dot, 3, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      second != oldDelegate.second;
}
