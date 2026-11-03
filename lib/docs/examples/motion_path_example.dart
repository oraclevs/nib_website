import '../../components/component_toggle.dart';

import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

/// One slider writes a MotionValue read directly by NibPathMotion.
class MotionPathExample extends StatefulWidget {
  const MotionPathExample({super.key});
  @override
  State<MotionPathExample> createState() => _MotionPathExampleState();
}

class _MotionPathExampleState extends State<MotionPathExample> {
  final _progress = MotionValue<double>(0);
  bool _rotate = true;
  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final path = Path()
      ..moveTo(16, 95)
      ..cubicTo(55, -10, 155, 180, 210, 45);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 235,
          height: 160,
          child: Stack(
            children: [
              Positioned.fill(
                child: NibDrawPath(
                  path: path,
                  color: const Color(0xFF74796B),
                  strokeWidth: 2,
                  duration: Duration.zero,
                ),
              ),
              NibPathMotion(
                path: path,
                progress: _progress,
                rotate: _rotate,
                child: const Icon(
                  Icons.navigation,
                  color: Color(0xFFFFB51B),
                  size: 25,
                ),
              ),
            ],
          ),
        ),
        Slider(
          value: _progress.value,
          label: '${(_progress.value * 100).round()}%',
          onChanged: (value) => setState(() => _progress.value = value),
        ),
        Text('Path progress: ${(_progress.value * 100).round()}%'),
        ComponentToggle(
          showLabel: true,
          contentPadding: EdgeInsets.zero,
          label: 'Follow the tangent',
          value: _rotate,
          onChanged: (value) => setState(() => _rotate = value),
        ),
      ],
    );
  }
}
