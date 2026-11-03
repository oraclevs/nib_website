import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

/// Start, stop, and set control one real NibMotion through its controller.
class MotionControllerExample extends StatefulWidget {
  const MotionControllerExample({super.key});

  @override
  State<MotionControllerExample> createState() =>
      _MotionControllerExampleState();
}

class _MotionControllerExampleState extends State<MotionControllerExample> {
  final NibMotionController _controller = NibMotionController();
  String _status = 'Ready at the left';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_status, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        SizedBox(
          height: 82,
          child: Center(
            child: NibMotion(
              controller: _controller,
              initial: const NibAnim(x: -48, opacity: 1),
              animate: const NibAnim(x: -48, opacity: 1),
              child: Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 2,
          children: [
            TextButton(
              onPressed: () {
                setState(() => _status = 'Moving to the right');
                unawaited(
                  _controller.start(
                    target: const NibAnim(x: 48, opacity: 1),
                    transition: NibTransition.springGentle,
                  ),
                );
              },
              child: const Text('Start'),
            ),
            TextButton(
              onPressed: () {
                _controller.stop();
                setState(() => _status = 'Stopped at current position');
              },
              child: const Text('Stop'),
            ),
            TextButton(
              onPressed: () {
                _controller.set(const NibAnim(x: -48, opacity: 1));
                setState(() => _status = 'Set instantly to the left');
              },
              child: const Text('Set'),
            ),
          ],
        ),
      ],
    );
  }
}
