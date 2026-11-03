import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

/// One input value drives paint properties through derived MotionValues.
class MotionValuesExample extends StatefulWidget {
  const MotionValuesExample({super.key});

  @override
  State<MotionValuesExample> createState() => _MotionValuesExampleState();
}

class _MotionValuesExampleState extends State<MotionValuesExample> {
  final MotionValue<double> _progress = MotionValue<double>(0.5);
  late final MotionValue<double> _x = _progress.mapRange([0, 1], [-62, 62]);
  late final MotionValue<double> _opacity = _progress.mapRange([0, 1], [.3, 1]);

  @override
  void dispose() {
    _x.dispose();
    _opacity.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('One value, two paint properties'),
      const SizedBox(height: 18),
      SizedBox(
        height: 100,
        child: Center(
          child: NibMotion(
            motionValues: NibMotionValues(translateX: _x, opacity: _opacity),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB51B),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
      ValueListenableBuilder<double>(
        valueListenable: _progress,
        builder: (context, value, _) => Slider(
          value: value,
          label: '${(value * 100).round()}%',
          onChanged: (next) => _progress.value = next,
        ),
      ),
    ],
  );
}
