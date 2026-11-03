import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

/// Horizontal direct manipulation with tap/hover feedback and a keyboard path.
class MotionGesturesExample extends StatefulWidget {
  const MotionGesturesExample({super.key});

  @override
  State<MotionGesturesExample> createState() => _MotionGesturesExampleState();
}

class _MotionGesturesExampleState extends State<MotionGesturesExample> {
  bool _right = false;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('Drag horizontally, or use the button'),
      const SizedBox(height: 14),
      SizedBox(
        height: 105,
        child: Center(
          child: NibMotion(
            animate: NibAnim(x: _right ? 54 : -54),
            whileTap: const NibAnim(scale: 0.9),
            whileHover: const NibAnim(scale: 1.08),
            whileDrag: const NibAnim(scale: 1.08),
            drag: const NibDragConfig(
              axis: Axis.horizontal,
              constraints: Rect.fromLTRB(-70, 0, 70, 0),
              releaseMode: NibDragReleaseMode.springBack,
            ),
            transition: NibTransition.springSnappy,
            child: Container(
              width: 70,
              height: 70,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB51B),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.drag_indicator, color: Color(0xFF241A05)),
            ),
          ),
        ),
      ),
      TextButton(
        onPressed: () => setState(() => _right = !_right),
        child: Text(_right ? 'Move left' : 'Move right'),
      ),
    ],
  );
}
