import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

/// Keyed children stay visible for their NibMotion exit animation.
class MotionPresenceExample extends StatefulWidget {
  const MotionPresenceExample({super.key});

  @override
  State<MotionPresenceExample> createState() => _MotionPresenceExampleState();
}

class _MotionPresenceExampleState extends State<MotionPresenceExample> {
  final List<int> _items = [1, 2, 3];
  int _next = 4;

  void _add() {
    if (_items.length >= 4) return;
    setState(() => _items.add(_next++));
  }

  void _remove() {
    if (_items.isEmpty) return;
    setState(() => _items.removeLast());
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('Add or remove a keyed child'),
      const SizedBox(height: 16),
      SizedBox(
        height: 85,
        child: Center(
          child: NibPresence(
            layoutBuilder: (context, children) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
            children: [
              for (final item in _items)
                NibMotion(
                  key: ValueKey(item),
                  initial: const NibAnim(opacity: 0, y: 20),
                  animate: NibAnim.identity,
                  exit: const NibAnim(opacity: 0, y: -20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB51B),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        '$item',
                        style: const TextStyle(color: Color(0xFF241A05)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        children: [
          TextButton(
            onPressed: _items.isEmpty ? null : _remove,
            child: const Text('Remove'),
          ),
          TextButton(
            onPressed: _items.length >= 4 ? null : _add,
            child: const Text('Add'),
          ),
        ],
      ),
    ],
  );
}
