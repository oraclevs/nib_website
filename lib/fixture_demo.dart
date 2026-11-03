import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

import 'ember_theme.dart';

/// A bounded local fixture. Replay changes start a new three-frame sequence.
class EmberFixtureDemo extends StatefulWidget {
  const EmberFixtureDemo({super.key, required this.replay});
  final int replay;

  @override
  State<EmberFixtureDemo> createState() => _EmberFixtureDemoState();
}

class _EmberFixtureDemoState extends State<EmberFixtureDemo> {
  Timer? timer;
  int frame = 0;
  bool immediate = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final policy = EmberMotionPolicy.maybeOf(context);
    immediate =
        (policy?.paused ?? false) ||
        (policy?.reduced ?? false) ||
        MediaQuery.of(context).disableAnimations;
    if (immediate && frame > 0) {
      timer?.cancel();
      frame = 3;
    }
  }

  @override
  void didUpdateWidget(EmberFixtureDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.replay == widget.replay) return;
    timer?.cancel();
    frame = immediate ? 3 : 1;
    if (!immediate) {
      timer = Timer.periodic(const Duration(milliseconds: 720), (timer) {
        if (!mounted) return;
        setState(() => frame++);
        if (frame == 3) timer.cancel();
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget entry(String id, Widget child) => NibMotion(
    key: ValueKey('$id-${widget.replay}'),
    initial: const NibAnim(opacity: 0, y: 12),
    animate: const NibAnim(opacity: 1, y: 0),
    exit: const NibAnim(opacity: 0, y: -6),
    transition: const NibTransition(
      duration: Duration(milliseconds: 620),
      curve: Curves.easeInOutCubic,
    ),
    exitTransition: const NibTransition(
      duration: Duration(milliseconds: 260),
      curve: Curves.easeInOut,
    ),
    child: Padding(padding: const EdgeInsets.only(bottom: 8), child: child),
  );

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 156,
    width: double.infinity,
    child: Align(
      alignment: Alignment.topLeft,
      child: NibPresence.layout(
        children: [
          if (frame == 0)
            entry(
              'ready',
              const Text(
                'A local fixture is ready to replay.',
                style: TextStyle(
                  fontFamily: Ember.mono,
                  fontSize: 11,
                  color: Ember.muted,
                ),
              ),
            ),
          if (frame > 0)
            entry(
              'heading',
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Ember.raised,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Your next step',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          if (frame > 1)
            entry(
              'body',
              const Text(
                'A generated local surface, shown from a fixture.',
                style: TextStyle(color: Ember.muted, fontSize: 13),
              ),
            ),
          if (frame > 2)
            entry(
              'action',
              const Text('Continue →', style: TextStyle(color: Ember.accent)),
            ),
        ],
      ),
    ),
  );
}
