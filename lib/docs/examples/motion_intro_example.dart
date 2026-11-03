import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

/// Application state retargets one persistent motion element.
class MotionIntroExample extends StatefulWidget {
  const MotionIntroExample({super.key});
  @override
  State<MotionIntroExample> createState() => _MotionIntroExampleState();
}

class _MotionIntroExampleState extends State<MotionIntroExample> {
  bool _saved = false;

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
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 100,
                child: Center(
                  child: NibMotion(
                    key: const ValueKey('bookmark-motion'),
                    animate: NibAnim(
                      y: _saved ? -10 : 0,
                      scale: _saved ? 1.15 : 1,
                      rotate: _saved ? -.035 : 0,
                    ),
                    transition: NibTransition.springGentle,
                    child: Icon(
                      _saved ? Icons.bookmark : Icons.bookmark_border,
                      size: 60,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
              const Text(
                'Keep the good ideas.',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                _saved
                    ? 'Saved to your collection'
                    : 'One idea worth coming back to',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () => setState(() => _saved = !_saved),
          icon: Icon(_saved ? Icons.undo : Icons.bookmark_add_outlined),
          label: Text(_saved ? 'Undo save' : 'Save idea'),
        ),
        const SizedBox(height: 8),
        const Text(
          'Change your mind before the spring settles.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
