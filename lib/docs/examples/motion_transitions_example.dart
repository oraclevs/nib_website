import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

/// The same target change uses a spring on the left and a timed tween on right.
class MotionTransitionsExample extends StatefulWidget {
  const MotionTransitionsExample({super.key});

  @override
  State<MotionTransitionsExample> createState() =>
      _MotionTransitionsExampleState();
}

class _MotionTransitionsExampleState extends State<MotionTransitionsExample> {
  bool _right = false;

  @override
  Widget build(BuildContext context) {
    final target = _right ? 22.0 : -22.0;
    final color = Theme.of(context).colorScheme.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Tap again before the tiles arrive'),
        const SizedBox(height: 12),
        SizedBox(
          height: 98,
          child: Row(
            children: [
              Expanded(
                child: _lane(
                  label: 'Spring',
                  target: target,
                  transition: NibTransition.springSnappy,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _lane(
                  label: '450 ms',
                  target: target,
                  transition: const NibTransition(
                    duration: Duration(milliseconds: 450),
                    curve: Curves.easeInOutCubic,
                  ),
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => setState(() => _right = !_right),
          child: Text(_right ? 'Move left' : 'Move right'),
        ),
      ],
    );
  }

  Widget _lane({
    required String label,
    required double target,
    required NibTransition transition,
    required Color color,
  }) => Column(
    children: [
      Text(label, style: const TextStyle(fontSize: 12)),
      const SizedBox(height: 8),
      SizedBox(
        height: 60,
        child: Center(
          child: NibMotion(
            animate: NibAnim(x: target),
            transition: transition,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
