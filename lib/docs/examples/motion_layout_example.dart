import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

/// Reordering changes layout; NibMotion animates each keyed tile's position.
class MotionLayoutExample extends StatefulWidget {
  const MotionLayoutExample({super.key});

  @override
  State<MotionLayoutExample> createState() => _MotionLayoutExampleState();
}

class _MotionLayoutExampleState extends State<MotionLayoutExample> {
  List<String> _order = ['A', 'B', 'C'];

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('Reorder three keyed tiles'),
      const SizedBox(height: 18),
      NibLayoutScope(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final item in _order)
              NibMotion(
                key: ValueKey(item),
                layout: NibLayout.position,
                layoutTransition: NibTransition.springGentle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Container(
                    width: 58,
                    height: 58,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB51B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item,
                      style: const TextStyle(color: Color(0xFF241A05)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      TextButton(
        onPressed: () =>
            setState(() => _order = [..._order.skip(1), _order.first]),
        child: const Text('Move first to end'),
      ),
    ],
  );
}
