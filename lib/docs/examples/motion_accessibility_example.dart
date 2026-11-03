import '../../components/component_toggle.dart';

import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

/// Reduced motion applies the target immediately while preserving the result.
class MotionAccessibilityExample extends StatefulWidget {
  const MotionAccessibilityExample({super.key});

  @override
  State<MotionAccessibilityExample> createState() =>
      _MotionAccessibilityExampleState();
}

class _MotionAccessibilityExampleState
    extends State<MotionAccessibilityExample> {
  bool _localReduce = false;
  bool _complete = false;

  @override
  Widget build(BuildContext context) {
    final systemReduce = MediaQuery.disableAnimationsOf(context);
    final reduced = systemReduce || _localReduce;
    return NibMotionConfig(
      reducedMotion: reduced,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ComponentToggle(
            showLabel: true,
            label: 'Reduce motion for this example',
            description: systemReduce
                ? 'System preference is active'
                : 'Keep the final state',
            value: reduced,
            onChanged: systemReduce
                ? null
                : (value) => setState(() => _localReduce = value),
          ),
          const SizedBox(height: 12),
          NibMotion(
            animate: NibAnim(x: _complete ? 46 : -46),
            transition: NibTransition.springGentle,
            child: Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB51B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _complete ? Icons.check : Icons.arrow_forward,
                color: const Color(0xFF241A05),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => setState(() => _complete = !_complete),
            child: Text(_complete ? 'Reset' : 'Complete'),
          ),
        ],
      ),
    );
  }
}
