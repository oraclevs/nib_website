import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

class MotionWaterExample extends StatefulWidget {
  const MotionWaterExample({super.key});
  @override
  State<MotionWaterExample> createState() => _MotionWaterExampleState();
}

class _MotionWaterExampleState extends State<MotionWaterExample> {
  final _water = NibWaterController(drops: const []);
  NibWaterRenderStatus? _status;
  bool _paused = false;

  @override
  void dispose() {
    _water.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 180,
          child: NibWaterSurface(
            controller: _water,
            surface: true,
            sampling: NibWaterSampling.live,
            paused: _paused,
            onStatus: (value) {
              if (mounted &&
                  (_status?.path != value.path ||
                      _status?.backend != value.backend)) {
                setState(() => _status = value);
              }
            },
            background: const ColoredBox(
              color: Color(0xFF173A40),
              child: Center(
                child: Wrap(
                  spacing: 28,
                  children: [
                    Icon(Icons.circle, size: 68, color: Color(0xFFFFB51B)),
                    Icon(Icons.grid_4x4, size: 90, color: Color(0xFFCFDEA0)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(switch (_status?.path) {
          NibWaterRenderPath.refractive => 'Refractive · ${_status!.backend}',
          NibWaterRenderPath.fallback =>
            'Fallback · direct content, without refraction',
          _ => 'Loading water resources…',
        }, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const Text(
          'Tap the water or use Disturb. Rendering status appears below.',
        ),
        Wrap(
          spacing: 8,
          children: [
            FilledButton(
              onPressed: _paused
                  ? null
                  : () => _water.disturb(Offset(constraints.maxWidth / 2, 90)),
              child: const Text('Disturb'),
            ),
            TextButton(
              onPressed: () => setState(() => _paused = !_paused),
              child: Text(_paused ? 'Resume' : 'Pause'),
            ),
            TextButton(onPressed: _water.reset, child: const Text('Reset')),
          ],
        ),
      ],
    ),
  );
}

class MotionTunerExample extends StatelessWidget {
  const MotionTunerExample({super.key});
  @override
  Widget build(BuildContext context) => const NibSpringTuner();
}

class MotionSharedLayoutExample extends StatefulWidget {
  const MotionSharedLayoutExample({super.key});
  @override
  State<MotionSharedLayoutExample> createState() =>
      _MotionSharedLayoutExampleState();
}

class _MotionSharedLayoutExampleState extends State<MotionSharedLayoutExample> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      NibLayoutScope(
        child: SizedBox(
          height: 190,
          width: double.infinity,
          child: Align(
            alignment: _expanded ? Alignment.bottomRight : Alignment.topLeft,
            child: NibMotion(
              key: ValueKey(_expanded),
              layoutId: 'shared-card',
              layout: NibLayout.both,
              layoutTransition: NibTransition.springGentle,
              child: Container(
                width: _expanded ? 180 : 80,
                height: _expanded ? 120 : 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.layers,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      FilledButton(
        onPressed: () => setState(() => _expanded = !_expanded),
        child: Text(_expanded ? 'Return card' : 'Expand card'),
      ),
      const Text('One layoutId, two keyed placements in the same scope.'),
    ],
  );
}
