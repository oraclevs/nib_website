import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

// Each tile reaches its own position at the same point in the timeline.
// `at` is normalized progress: 0 = start, 0.5 = halfway, 1 = finish.
const _tracks = <List<NibKeyframe>>[
  [
    NibKeyframe(at: 0, value: NibAnim(x: -72, y: -52, rotate: -0.16)),
    NibKeyframe(at: 0.5, value: NibAnim(x: 72, y: -48, rotate: 0.12)),
    NibKeyframe(at: 1, value: NibAnim(x: 62, y: 12, rotate: 0)),
  ],
  [
    NibKeyframe(at: 0, value: NibAnim(x: -14, y: 52, rotate: 0.12, scale: 0.9)),
    NibKeyframe(
      at: 0.5,
      value: NibAnim(x: 14, y: 64, rotate: -0.12, scale: 1.08),
    ),
    NibKeyframe(at: 1, value: NibAnim(x: 0, y: 12, rotate: 0, scale: 1)),
  ],
  [
    NibKeyframe(at: 0, value: NibAnim(x: 72, y: 4, rotate: 0.16)),
    NibKeyframe(at: 0.5, value: NibAnim(x: -72, y: 8, rotate: -0.16)),
    NibKeyframe(at: 1, value: NibAnim(x: -62, y: 12, rotate: 0)),
  ],
];

const _tileColors = [
  Color(0xFFFFB51B), // Amber
  Color(0xFFCFDEA0), // Sage
  Color(0xFFFFAEA3), // Peach
];
const _tileNames = ['Amber', 'Sage', 'Peach'];
const _stageNames = ['Scatter', 'Cross', 'Align'];

/// Three keyframe tracks share one duration, with an optional stage preview.
class MotionKeyframesExample extends StatefulWidget {
  const MotionKeyframesExample({super.key});

  @override
  State<MotionKeyframesExample> createState() => _MotionKeyframesExampleState();
}

class _MotionKeyframesExampleState extends State<MotionKeyframesExample> {
  final _controllers = List.generate(3, (_) => NibMotionController());
  double _durationMs = 2400;
  int? _previewStage;
  bool _reduced = false;

  NibTransition get _transition => NibTransition(
    duration: Duration(milliseconds: _durationMs.round()),
    curve: Curves.easeInOut,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = NibMotionConfig.watchReducedMotion(context);
    if (reduced != _reduced) _previewStage = null;
    _reduced = reduced;
  }

  void _play() {
    setState(() => _previewStage = null);
    for (var i = 0; i < _controllers.length; i++) {
      unawaited(
        _controllers[i].start(keyframes: _tracks[i], transition: _transition),
      );
    }
  }

  void _preview(int stage) {
    setState(() => _previewStage = stage);
    for (var i = 0; i < _controllers.length; i++) {
      _controllers[i].stop();
      _controllers[i].set(_tracks[i][stage].value);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final reduced = _reduced;
    final selectedStage = reduced ? 2 : _previewStage;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Three tiles, one timeline',
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Swap places, then settle into a row.',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            height: 220,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border.all(color: colors.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: NibMotionConfig(
              reducedMotion: reduced,
              entranceWarmup: Duration.zero,
              child: CustomPaint(
                painter: _PositionGuide(colors.outline),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    for (var i = 0; i < _tracks.length; i++)
                      NibMotion(
                        key: ValueKey('keyframe-tile-$i-$reduced'),
                        controller: _controllers[i],
                        keyframes: _tracks[i],
                        transition: _transition,
                        child: Semantics(
                          label: '${_tileNames[i]} tile ${i + 1}',
                          child: Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _tileColors[i],
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: _tileColors[i].withValues(alpha: 0.16),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              String.fromCharCode(65 + i),
                              style: const TextStyle(
                                color: Color(0xFF182319),
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var stage = 0; stage < _stageNames.length; stage++) ...[
                if (stage > 0) const SizedBox(width: 6),
                Expanded(
                  child: Semantics(
                    selected: selectedStage == stage,
                    child: OutlinedButton(
                      onPressed: reduced ? null : () => _preview(stage),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: selectedStage == stage
                            ? colors.primary.withValues(alpha: 0.12)
                            : null,
                        side: BorderSide(
                          color: selectedStage == stage
                              ? const Color(0xFF876421)
                              : colors.outline,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _stageNames[stage],
                            style: const TextStyle(fontSize: 11),
                          ),
                          Text(
                            'at ${(stage / 2).toStringAsFixed(1)}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Text(
            reduced
                ? 'Reduced motion: showing the aligned result.'
                : selectedStage == null
                ? 'Select a stage to inspect its positions.'
                : '${_stageNames[selectedStage]} paused. Replay to see every stage.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Text(
            'Duration · ${(_durationMs / 1000).toStringAsFixed(1)} s',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
          Slider(
            value: _durationMs,
            min: 1200,
            max: 4800,
            divisions: 6,
            label: '${(_durationMs / 1000).toStringAsFixed(1)} seconds',
            semanticFormatterCallback: (value) =>
                'Duration ${(value / 1000).toStringAsFixed(1)} seconds',
            onChanged: reduced
                ? null
                : (value) => setState(() => _durationMs = value),
            onChangeEnd: reduced ? null : (_) => _play(),
          ),
          Center(
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 38),
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: reduced ? null : _play,
              icon: const Icon(Icons.replay, size: 16),
              label: const Text('Replay keyframes'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PositionGuide extends CustomPainter {
  const _PositionGuide(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final dots = Paint()..color = color.withValues(alpha: 0.5);
    for (var x = 12.0; x < size.width; x += 20) {
      for (var y = 10.0; y < size.height; y += 20) {
        canvas.drawCircle(Offset(x, y), 0.7, dots);
      }
    }
    final outline = Paint()
      ..color = color
      ..style = PaintingStyle.stroke;
    for (final x in [-62.0, 0.0, 62.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.width / 2 + x, size.height / 2 + 12),
            width: 44,
            height: 44,
          ),
          const Radius.circular(12),
        ),
        outline,
      );
    }
  }

  @override
  bool shouldRepaint(_PositionGuide oldDelegate) => oldDelegate.color != color;
}
