import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

/// A finite entrance: the headline leads, then the two supporting rows follow.
class MotionEntranceExample extends StatefulWidget {
  const MotionEntranceExample({super.key});
  @override
  State<MotionEntranceExample> createState() => _MotionEntranceExampleState();
}

class _MotionEntranceExampleState extends State<MotionEntranceExample> {
  int _replay = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 360),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.outline),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _enter(
                0,
                Text(
                  'MAKE ROOM FOR IDEAS',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 2,
                    color: colors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _enter(
                1,
                const Text(
                  'A little motion.\nA clear beginning.',
                  style: TextStyle(
                    fontSize: 27,
                    height: 1.15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _enter(
                2,
                _row(
                  Icons.draw_outlined,
                  'Sketch the idea',
                  'Start with one widget',
                ),
              ),
              const SizedBox(height: 16),
              _enter(
                3,
                _row(
                  Icons.auto_awesome_outlined,
                  'Let it arrive',
                  'Opacity + vertical travel',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: () => setState(() => _replay++),
          icon: const Icon(Icons.replay),
          label: const Text('Replay entrance'),
        ),
      ],
    );
  }

  Widget _enter(int order, Widget child) => NibMotion(
    key: ValueKey('entrance-$_replay-$order'),
    initial: const NibAnim(opacity: 0, y: 18),
    animate: const NibAnim(opacity: 1, y: 0),
    transition: NibTransition(
      duration: const Duration(milliseconds: 480),
      delay: Duration(milliseconds: order * 90),
      curve: Curves.easeOutCubic,
    ),
    child: child,
  );

  Widget _row(IconData icon, String title, String subtitle) => Row(
    children: [
      Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
