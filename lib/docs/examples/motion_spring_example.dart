import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

/// Retarget the same spring before it settles to see interruption.
class MotionSpringExample extends StatefulWidget {
  const MotionSpringExample({super.key});

  @override
  State<MotionSpringExample> createState() => _MotionSpringExampleState();
}

class _MotionSpringExampleState extends State<MotionSpringExample> {
  double _target = -60;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('Retarget before the spring settles'),
      const SizedBox(height: 20),
      SizedBox(
        height: 100,
        child: Center(
          child: NibMotion(
            initial: const NibAnim(x: -60),
            animate: NibAnim(x: _target),
            transition: const NibTransition(
              spring: NibSpringDescription(stiffness: 180, damping: 18),
            ),
            child: Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB51B),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.swap_horiz, color: Color(0xFF241A05)),
            ),
          ),
        ),
      ),
      TextButton(
        onPressed: () => setState(() => _target = _target < 0 ? 60 : -60),
        child: const Text('Retarget'),
      ),
    ],
  );
}
