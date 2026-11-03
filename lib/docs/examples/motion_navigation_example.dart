import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

/// Screens keep their local counter while the active screen changes.
class MotionNavigationExample extends StatefulWidget {
  const MotionNavigationExample({super.key});
  @override
  State<MotionNavigationExample> createState() =>
      _MotionNavigationExampleState();
}

class _MotionNavigationExampleState extends State<MotionNavigationExample> {
  int _index = 0;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        height: 175,
        child: NibScreenStack(
          currentIndex: _index,
          screenTransition: NibMotionConfig.shouldReduceMotion(context)
              ? NibNavScreenTransition.none
              : NibNavScreenTransition.slide,
          screens: const [
            NibNavScreen(
              child: _CounterScreen(label: 'Inbox', icon: Icons.inbox_outlined),
            ),
            NibNavScreen(
              child: _CounterScreen(
                label: 'Saved',
                icon: Icons.bookmark_outline,
              ),
            ),
          ],
        ),
      ),
      NibNavBar(
        currentIndex: _index,
        onIndexChanged: (index) => setState(() => _index = index),
        items: const [
          NibNavItem(icon: Icon(Icons.inbox_outlined), label: 'Inbox'),
          NibNavItem(icon: Icon(Icons.bookmark_outline), label: 'Saved'),
        ],
      ),
      const SizedBox(height: 12),
      const Text(
        'Add a count, switch tabs, then return. Each screen keeps its own state.',
        textAlign: TextAlign.center,
      ),
    ],
  );
}

class _CounterScreen extends StatefulWidget {
  const _CounterScreen({required this.label, required this.icon});
  final String label;
  final IconData icon;
  @override
  State<_CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<_CounterScreen> {
  int _count = 0;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(widget.icon, size: 30, color: const Color(0xFFFFB51B)),
        Text('${widget.label}: $_count', style: const TextStyle(fontSize: 22)),
        TextButton(
          onPressed: () => setState(() => _count++),
          child: const Text('Add a count'),
        ),
      ],
    ),
  );
}
