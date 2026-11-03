import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

/// A named parent target propagates to children without per-child callbacks.
class MotionVariantsExample extends StatefulWidget {
  const MotionVariantsExample({super.key});

  @override
  State<MotionVariantsExample> createState() => _MotionVariantsExampleState();
}

class _MotionVariantsExampleState extends State<MotionVariantsExample> {
  static const _parentStates = <String, NibAnim>{
    'closed': NibAnim(opacity: 0.6),
    'open': NibAnim(opacity: 1),
  };
  static const _childStates = <String, NibAnim>{
    'closed': NibAnim(opacity: 0, x: -18),
    'open': NibAnim(opacity: 1, x: 0),
  };
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('One named state, three staggered children'),
        const SizedBox(height: 10),
        SizedBox(
          height: 102,
          child: NibMotion(
            variants: _parentStates,
            initial: 'closed',
            animate: _open ? 'open' : 'closed',
            transition: const NibTransition(
              duration: Duration(milliseconds: 300),
              delayChildren: Duration(milliseconds: 30),
              staggerChildren: Duration(milliseconds: 75),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final index in [1, 2, 3])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: NibMotion(
                      key: ValueKey(index),
                      variants: _childStates,
                      child: Container(
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('Step $index'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => setState(() => _open = !_open),
          child: Text(_open ? 'Close list' : 'Open list'),
        ),
      ],
    );
  }
}
