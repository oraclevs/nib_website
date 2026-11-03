import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

/// Two controllers follow timed entries; the slider seeks the same timeline.
class MotionTimelineExample extends StatefulWidget {
  const MotionTimelineExample({super.key});

  @override
  State<MotionTimelineExample> createState() => _MotionTimelineExampleState();
}

class _MotionTimelineExampleState extends State<MotionTimelineExample> {
  static const _start = NibAnim(x: -36, opacity: 0.5);
  final NibMotionController _first = NibMotionController();
  final NibMotionController _second = NibMotionController();
  late final NibTimeline _timeline = NibTimeline([
    NibTimelineEntry(
      controller: _first,
      from: _start,
      target: const NibAnim(x: 36, opacity: 1),
      at: Duration.zero,
      transition: const NibTransition(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      ),
    ),
    NibTimelineEntry(
      controller: _second,
      from: _start,
      target: const NibAnim(x: 36, opacity: 1),
      at: const Duration(milliseconds: 180),
      transition: const NibTransition(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      ),
    ),
  ]);
  double _seek = 0;
  String _status = 'Ready';

  void _play() {
    _timeline.stop();
    _first.set(_start);
    _second.set(_start);
    setState(() {
      _seek = 0;
      _status = 'Playing two entries';
    });
    unawaited(_timeline.play());
  }

  void _stop() {
    _timeline.stop();
    _first.stop();
    _second.stop();
    setState(() => _status = 'Pending and active motion stopped');
  }

  void _seekTo(double value) {
    _timeline.seek(value);
    setState(() {
      _seek = value;
      _status = 'Seeked to ${(value * 100).round()}%';
    });
  }

  @override
  void dispose() {
    _timeline.dispose();
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_status, textAlign: TextAlign.center),
        const SizedBox(height: 6),
        _track('First', _first, color),
        const SizedBox(height: 4),
        _track('Second · 180 ms later', _second, color),
        const SizedBox(height: 5),
        Slider(
          value: _seek,
          onChanged: _seekTo,
          label: '${(100 * _seek).round()}%',
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          children: [
            TextButton(onPressed: _play, child: const Text('Play')),
            TextButton(onPressed: _stop, child: const Text('Cancel')),
          ],
        ),
      ],
    );
  }

  Widget _track(String label, NibMotionController controller, Color color) =>
      Row(
        children: [
          SizedBox(
            width: 65,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11),
              maxLines: 2,
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 37,
              child: Center(
                child: NibMotion(
                  controller: controller,
                  initial: _start,
                  animate: _start,
                  child: Container(
                    width: 29,
                    height: 29,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}
