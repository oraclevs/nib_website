import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

/// The final card reveals when it enters this nested scroll viewport.
class MotionScrollExample extends StatelessWidget {
  const MotionScrollExample({super.key});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('Scroll the window to reveal the last card'),
      const SizedBox(height: 12),
      Container(
        height: 160,
        width: 260,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(7),
        ),
        child: ListView(
          children: [
            for (final label in ['First', 'Second', 'Third'])
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  height: 58,
                  alignment: Alignment.center,
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  child: Text(label),
                ),
              ),
            NibScrollReveal(
              once: false,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  height: 70,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB51B),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Text(
                    'Revealed',
                    style: TextStyle(color: Color(0xFF241A05)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
