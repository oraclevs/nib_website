import '../../components/component_toggle.dart';

import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

/// Direct solver ownership: the State owns both the solver and MotionValue.
class MotionPhysicsExample extends StatefulWidget {
  const MotionPhysicsExample({super.key});
  @override
  State<MotionPhysicsExample> createState() => _MotionPhysicsExampleState();
}

class _MotionPhysicsExampleState extends State<MotionPhysicsExample>
    with SingleTickerProviderStateMixin {
  final _position = MotionValue<double>(-65);
  late final _solver = SpringSolver(
    vsync: this,
    value: _position,
    spring: NibSpringDescription.wobbly,
  );
  bool _right = false;
  bool _firm = false;
  void _move() {
    setState(() => _right = !_right);
    if (NibMotionConfig.shouldReduceMotion(context)) {
      _solver.stop();
      _position.value = _right ? 65 : -65;
    } else {
      _solver.animateTo(target: _right ? 65 : -65);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (NibMotionConfig.watchReducedMotion(context)) {
      _solver.stop();
      _position.value = _right ? 65 : -65;
    }
  }

  @override
  void dispose() {
    _solver.dispose();
    _position.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        height: 105,
        child: Center(
          child: NibMotion(
            motionValues: NibMotionValues(translateX: _position),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB51B),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
      Text(
        _firm
            ? 'stiffness 400 · damping 28 · mass 1'
            : 'stiffness 180 · damping 12 · mass 1',
        textAlign: TextAlign.center,
      ),
      ComponentToggle(
        showLabel: true,
        contentPadding: EdgeInsets.zero,
        label: 'Use a firmer spring',
        value: _firm,
        onChanged: (value) {
          setState(() => _firm = value);
          _solver.spring = value
              ? NibSpringDescription.stiff
              : NibSpringDescription.wobbly;
          _move();
        },
      ),
      Wrap(
        spacing: 8,
        children: [
          FilledButton(onPressed: _move, child: const Text('Retarget solver')),
          TextButton(onPressed: _solver.stop, child: const Text('Stop')),
        ],
      ),
    ],
  );
}
