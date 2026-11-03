import 'package:flutter/material.dart';
import 'package:nib_components/nib_components.dart';
import 'package:nib_motion/nib_motion.dart';

import '../component_settings.dart';

/// A bounded glass surface over local fixture content, using the public widget.
class _LegacyGlassDemo extends StatefulWidget {
  const _LegacyGlassDemo({
    required this.settings,
    required this.onChanged,
    required this.onEvent,
  });

  final ComponentSettings settings;
  final ValueChanged<ComponentSettings> onChanged;
  final ValueChanged<String> onEvent;

  @override
  State<_LegacyGlassDemo> createState() => _LegacyGlassDemoState();
}

class _LegacyGlassDemoState extends State<_LegacyGlassDemo> {
  late final Future<bool> _shaderAvailable =
      NibGlass.debugShaderPathAvailable();
  bool _pinned = false;

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    final tokens = NibTheme.of(context);
    final capsule = settings.variant == 'capsule';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          child: SizedBox(
            height: 264,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = (constraints.maxWidth - 32).clamp(120.0, 340.0);
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: ExcludeSemantics(
                        child: settings.backdrop == 'content'
                            ? const _ContentBackdrop(
                                key: ValueKey('glass-backdrop-content'),
                              )
                            : CustomPaint(
                                key: const ValueKey('glass-backdrop-grid'),
                                painter: _GridBackdrop(
                                  background: tokens.background,
                                  line: tokens.border,
                                  accent: tokens.primary,
                                ),
                              ),
                      ),
                    ),
                    MouseRegion(
                      onEnter: settings.interactive
                          ? (_) => widget.onEvent('Pointer entered the glass')
                          : null,
                      onExit: settings.interactive
                          ? (_) => widget.onEvent('Pointer left the glass')
                          : null,
                      child: Listener(
                        onPointerDown: settings.interactive
                            ? (_) => widget.onEvent('Pointer down on glass')
                            : null,
                        onPointerUp: settings.interactive
                            ? (_) => widget.onEvent('Pointer released')
                            : null,
                        onPointerCancel: settings.interactive
                            ? (_) => widget.onEvent('Pointer cancelled')
                            : null,
                        child: NibLiquidGlass(
                          key: const ValueKey('glass-demo-surface'),
                          width: width,
                          height: 188,
                          padding: EdgeInsets.symmetric(
                            horizontal: capsule ? 48 : 20,
                            vertical: 16,
                          ),
                          borderRadius: BorderRadius.circular(
                            capsule ? 94 : settings.radius,
                          ),
                          blurSigma: settings.blurSigma,
                          thickness: settings.thickness,
                          refractiveIndex: settings.refractiveIndex,
                          chromaticAberration: settings.chromaticAberration,
                          saturation: settings.saturation,
                          highlight: settings.highlight,
                          showBorder: settings.showBorder,
                          interactive: settings.interactive,
                          animated: settings.animated,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.layers_outlined,
                                    size: 17,
                                    color: tokens.primary,
                                  ),
                                  const SizedBox(width: 7),
                                  Expanded(
                                    child: Text(
                                      'LOCAL NOTE',
                                      style: TextStyle(
                                        color: tokens.foreground,
                                        fontSize: 10,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: Text(
                                  settings.text,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: tokens.foreground,
                                    fontSize: 17,
                                    height: 1.3,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              NibButton(
                                key: const ValueKey('glass-pin-note'),
                                label: _pinned ? 'Pinned' : 'Pin note',
                                leadingIcon: Icon(
                                  _pinned
                                      ? Icons.push_pin
                                      : Icons.push_pin_outlined,
                                  size: 15,
                                ),
                                size: NibButtonSize.sm,
                                variant: NibButtonVariant.outline,
                                toggled: _pinned,
                                onPressed: () {
                                  setState(() => _pinned = !_pinned);
                                  widget.onEvent(
                                    _pinned ? 'Note pinned' : 'Note unpinned',
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        NibButton(
          key: const ValueKey('glass-change-backdrop'),
          expand: true,
          label: settings.backdrop == 'grid'
              ? 'Use content backdrop'
              : 'Use grid backdrop',
          variant: NibButtonVariant.outline,
          size: NibButtonSize.sm,
          onPressed: () {
            final next = settings.backdrop == 'grid' ? 'content' : 'grid';
            widget.onChanged(settings.change('backdrop', next));
            widget.onEvent('Backdrop changed to $next');
          },
        ),
        const SizedBox(height: 8),
        Text(
          settings.interactive
              ? settings.animated
                    ? 'Move the pointer to aim the rim; hold and release to feel the native press response.'
                    : 'Move the pointer to aim the rim. Enable Animated press to add the native press response.'
              : 'Decorative pointer response is off. The note button remains usable.',
          style: TextStyle(
            color: tokens.mutedForeground,
            fontSize: 12,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        FutureBuilder<bool>(
          future: _shaderAvailable,
          builder: (context, snapshot) => Text(
            snapshot.data == true
                ? 'Shader path available. Its appearance still depends on the renderer and backdrop.'
                : snapshot.hasData || snapshot.hasError
                ? 'Frosted fallback: blur, tint and painted rim. Refraction settings require the shader path.'
                : 'Checking shader capability. The surface uses its fallback while the shader loads.',
            key: const ValueKey('glass-renderer-status'),
            style: TextStyle(
              color: tokens.mutedForeground,
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _ContentBackdrop extends StatelessWidget {
  const _ContentBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = NibTheme.of(context);
    return ColoredBox(
      color: tokens.card,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'STUDIO / NOTES',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: tokens.primary,
                fontSize: 11,
                height: 1.1,
                letterSpacing: 1.4,
              ),
            ),
            const Spacer(),
            for (final label in [
              'Shape the interaction',
              'Keep the context',
              'Test the result',
            ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: tokens.secondary,
                    border: Border.all(color: tokens.border),
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.notes, color: tokens.primary, size: 14),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: tokens.foreground,
                            fontSize: 12,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GridBackdrop extends CustomPainter {
  const _GridBackdrop({
    required this.background,
    required this.line,
    required this.accent,
  });
  final Color background, line, accent;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRect(bounds, Paint()..color = background);
    final grid = Paint()
      ..color = line
      ..strokeWidth = 1;
    for (var x = 0.0; x <= size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y <= size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    canvas.drawCircle(
      Offset(size.width * .3, size.height * .46),
      68,
      Paint()..color = accent.withValues(alpha: .35),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * .6, size.height * .28, 58, 114),
        const Radius.circular(12),
      ),
      Paint()..color = accent.withValues(alpha: .2),
    );
  }

  @override
  bool shouldRepaint(_GridBackdrop oldDelegate) =>
      background != oldDelegate.background ||
      line != oldDelegate.line ||
      accent != oldDelegate.accent;
}

/// The playground and complete exported program use this same public example.
class GlassComponentDemo extends StatelessWidget {
  const GlassComponentDemo({
    super.key,
    required this.settings,
    required this.onChanged,
    required this.onEvent,
  });
  final ComponentSettings settings;
  final ValueChanged<ComponentSettings> onChanged;
  final ValueChanged<String> onEvent;

  @override
  Widget build(BuildContext context) => settings.waterMaterial == 'water'
      ? _WaterLabDemo(
          settings: settings,
          onChanged: onChanged,
          onEvent: onEvent,
        )
      : _LegacyGlassDemo(
          settings: settings,
          onChanged: onChanged,
          onEvent: onEvent,
        );
}

NibWaterConfig _waterConfig(ComponentSettings settings) => NibWaterConfig(
  waveSpeed: settings.waterWaveSpeed,
  damping: settings.waterDamping,
  impulseStrength: settings.waterImpulse,
  wavelength: settings.waterWavelength,
  recovery: settings.waterRecovery,
  refraction: settings.waterRefraction,
  highlight: settings.waterHighlight,
);

class _WaterLabDemo extends StatefulWidget {
  const _WaterLabDemo({
    required this.settings,
    required this.onChanged,
    required this.onEvent,
  });
  final ComponentSettings settings;
  final ValueChanged<ComponentSettings> onChanged;
  final ValueChanged<String> onEvent;
  @override
  State<_WaterLabDemo> createState() => _WaterLabDemoState();
}

class _WaterLabDemoState extends State<_WaterLabDemo> {
  late NibWaterController _water = _makeWater();
  NibWaterController _makeWater() => NibWaterController(
    config: _waterConfig(widget.settings),
    emitter: widget.settings.waterScene == 'bubbles'
        ? NibBubbleEmitter(seed: 17)
        : null,
    drops: widget.settings.waterScene == 'bubbles'
        ? const []
        : const [
            NibWaterDrop(id: 1, center: Offset(180, 190), radius: 78),
            NibWaterDrop(id: 2, center: Offset(460, 190), radius: 78),
          ],
  );
  final ScrollController _backgroundScroll = ScrollController();
  final ValueNotifier<NibWaterRenderStatus?> _renderStatus = ValueNotifier(
    null,
  );
  final ValueNotifier<NibWaterPhase> _phase = ValueNotifier(
    NibWaterPhase.separated,
  );
  bool _paused = false;
  bool _reduceMotion = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _water.addListener(_observePhase);
  }

  void _observePhase() {
    // The renderer listens to every simulation frame. The article only rebuilds
    // when the discrete body state changes, not on each wave step.
    if (_phase.value != _water.phase) _phase.value = _water.phase;
  }

  @override
  void didUpdateWidget(covariant _WaterLabDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.settings.waterScene == 'bubbles') !=
        (widget.settings.waterScene == 'bubbles')) {
      _water.removeListener(_observePhase);
      _water.dispose();
      _water = _makeWater()..addListener(_observePhase);
      _phase.value = _water.phase;
    } else {
      _water.configure(_waterConfig(widget.settings));
    }
    if (oldWidget.settings.waterInteraction !=
        widget.settings.waterInteraction) {
      _water.cancelInputs();
    }
  }

  @override
  void dispose() {
    _water.removeListener(_observePhase);
    _water.dispose();
    _backgroundScroll.dispose();
    _renderStatus.dispose();
    _phase.dispose();
    super.dispose();
  }

  void _action(String message, VoidCallback action) {
    action();
    widget.onEvent(message);
  }

  Widget _background() {
    switch (widget.settings.waterBackdrop) {
      case 'typography':
        return const _WaterTypography();
      case 'image':
        return const CustomPaint(painter: _WaterOriginalArtwork());
      case 'scrolling':
        return ColoredBox(
          color: const Color(0xFFE9E6DD),
          child: SingleChildScrollView(
            key: const ValueKey('water-scrolling-background'),
            controller: _backgroundScroll,
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < 12; i++)
                  Container(
                    height: 92,
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFF8D918D)),
                      ),
                    ),
                    child: Text(
                      '${(i + 1).toString().padLeft(2, '0')}   Moving underneath',
                      style: const TextStyle(
                        color: Color(0xFF202724),
                        fontSize: 23,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      default:
        return const CustomPaint(painter: _WaterNeutralGrid());
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = NibTheme.of(context);
    final settings = widget.settings;
    final component = settings.waterScene == 'component';
    final surface = settings.waterScene != 'droplets';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final scene in const {
              'droplets': 'Droplets',
              'surface': 'Surface',
              'bubbles': 'Bubbles',
              'component': 'Component',
            }.entries)
              ChoiceChip(
                label: Text(scene.value),
                selected: settings.waterScene == scene.key,
                onSelected: (_) =>
                    widget.onChanged(settings.change('waterScene', scene.key)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          settings.waterInteraction == 'drag' && !surface
              ? 'Drag the drops together. Once joined, the body stays joined. Split separates it again.'
              : 'Tap or stroke the water to make a wave. Try several points, then let the surface settle.',
          style: TextStyle(
            color: tokens.mutedForeground,
            height: 1.5,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 640 / 380,
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 640,
                height: 380,
                child: NibWaterGlass(
                  key: const ValueKey('water-lab-surface'),
                  controller: _water,
                  background: ExcludeSemantics(child: _background()),
                  captureScale: settings.waterCaptureScale,
                  sampling: NibWaterSampling.values.byName(
                    settings.waterSampling,
                  ),
                  quality: NibWaterQuality(scale: settings.waterQuality),
                  material: NibWaterMaterial(
                    refraction: settings.waterRefraction,
                    highlight: settings.waterHighlight,
                    blurSigma: settings.waterBlur,
                    depth: settings.waterOptics == 'depth' ? 1 : 0,
                    absorption: settings.waterOptics == 'depth' ? .12 : 0,
                  ),
                  surface: surface,
                  interaction: surface || settings.waterInteraction == 'disturb'
                      ? NibWaterInteraction.disturb
                      : NibWaterInteraction.drag,
                  paused: _paused,
                  reducedMotion: _reduceMotion,
                  animated: settings.animated,
                  onStatus: (status) {
                    if (mounted) _renderStatus.value = status;
                  },
                  child: component
                      ? Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 310),
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: tokens.card.withValues(alpha: .93),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: tokens.border),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'A little clarity.',
                                  style: TextStyle(
                                    color: tokens.foreground,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Water moves underneath. Your action stays sharp.',
                                  style: TextStyle(
                                    color: tokens.mutedForeground,
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                NibButton(
                                  key: const ValueKey('water-save-note'),
                                  label: _saved ? 'Saved' : 'Save this note',
                                  animated: settings.animated,
                                  leadingIcon: Icon(
                                    _saved
                                        ? Icons.check
                                        : Icons.bookmark_outline,
                                    size: 16,
                                  ),
                                  onPressed: () {
                                    setState(() => _saved = !_saved);
                                    widget.onEvent(
                                      _saved
                                          ? 'Water note saved'
                                          : 'Water note unsaved',
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (settings.waterScene == 'bubbles')
              NibButton(
                label: _water.emitter!.emitting
                    ? 'Stop emission'
                    : 'Start emission',
                onPressed: () => setState(
                  () => _water.setEmitting(!_water.emitter!.emitting),
                ),
              ),
            if (!surface) ...[
              NibButton(
                key: const ValueKey('water-merge'),
                label: 'Merge drops',
                animated: settings.animated,
                onPressed: () => _action('Drops merging', _water.merge),
              ),
              NibButton(
                key: const ValueKey('water-split'),
                label: 'Split',
                animated: settings.animated,
                variant: NibButtonVariant.outline,
                onPressed: () =>
                    _action('Controlled split requested', _water.split),
              ),
            ],
            NibButton(
              key: const ValueKey('water-disturb'),
              label: 'Make a wave',
              animated: settings.animated,
              variant: NibButtonVariant.outline,
              onPressed: () => _action(
                'Wave at the center',
                () => _water.disturb(const Offset(320, 190)),
              ),
            ),
            NibButton(
              key: const ValueKey('water-reset'),
              label: 'Reset water',
              animated: settings.animated,
              variant: NibButtonVariant.outline,
              onPressed: () => _action(
                'Water reset; motion preferences retained',
                _water.reset,
              ),
            ),
            if (settings.waterBackdrop == 'scrolling')
              NibButton(
                key: const ValueKey('water-scroll-background'),
                label: 'Move background',
                animated: settings.animated,
                variant: NibButtonVariant.outline,
                onPressed: () {
                  if (_backgroundScroll.hasClients) {
                    final next = _backgroundScroll.offset + 100;
                    _backgroundScroll.jumpTo(
                      next > _backgroundScroll.position.maxScrollExtent
                          ? 0
                          : next,
                    );
                    widget.onEvent('Background moved by 100 logical pixels');
                  }
                },
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () => setState(() => _paused = !_paused),
              icon: Icon(_paused ? Icons.play_arrow : Icons.pause, size: 16),
              label: Text(_paused ? 'Resume water' : 'Pause water'),
            ),
            FilterChip(
              label: const Text('Less motion'),
              selected:
                  _reduceMotion || MediaQuery.disableAnimationsOf(context),
              onSelected: (value) => setState(() => _reduceMotion = value),
            ),
            ValueListenableBuilder<NibWaterPhase>(
              valueListenable: _phase,
              builder: (context, phase, child) => Text(
                'Body: ${phase.name}',
                key: const ValueKey('water-body-phase'),
                style: TextStyle(color: tokens.mutedForeground, fontSize: 12),
              ),
            ),
          ],
        ),
        ValueListenableBuilder<NibWaterRenderStatus?>(
          valueListenable: _renderStatus,
          builder: (context, status, child) => ExpansionTile(
            key: const ValueKey('water-diagnostics'),
            tilePadding: EdgeInsets.zero,
            onExpansionChanged: (expanded) {
              if (expanded) setState(() {});
            },
            title: Text(
              'Development details · ${status?.path.name ?? 'loading'}',
              style: TextStyle(color: tokens.mutedForeground, fontSize: 12),
            ),
            childrenPadding: const EdgeInsets.only(bottom: 14),
            children: [
              TextButton(
                onPressed: () => setState(() {}),
                child: const Text('Refresh diagnostics'),
              ),
              Text(
                '${status?.message ?? 'Waiting for the material renderer.'}\n'
                'Background captures: ${status?.captureCount ?? 0}. Last capture: ${status?.lastCaptureMicros ?? 0} µs.\n'
                'Source regions: ${_water.drops.length}; body ids: ${_water.drops.map((drop) => drop.bodyId).toSet().join(', ')}; phase: ${_water.phase.name}.\n'
                'Active inputs at last diagnostic refresh: ${_water.activeInputs}.\n'
                '2D mass proxy: ${_water.massProxy.toStringAsFixed(1)} px². Last solver step: ${_water.lastStepMicros} µs.\n'
                'Solver: speed ${settings.waterWaveSpeed.toStringAsFixed(0)} px/s; damping ${settings.waterDamping.toStringAsFixed(2)} /s; wavelength ${settings.waterWavelength.toStringAsFixed(0)} px; recovery ${settings.waterRecovery.toStringAsFixed(0)} /s.\n'
                'Backend: ${status?.backend ?? 'loading'}; policy: ${settings.waterSampling}.\n'
                'Requested quality: ${settings.waterQuality} × DPR; legacy absolute: ${settings.waterCaptureScale} px/logical px.\n'
                'Effective: ${status?.resolution?.width ?? '?'} × ${status?.resolution?.height ?? '?'} pixels, ${status?.resolution?.effectiveScale.toStringAsFixed(2) ?? '?'} px/logical px; input ${status?.resolution?.estimatedBytes ?? 0} bytes.\n'
                'Source: ${const String.fromEnvironment('NIB_WATER_REVISION', defaultValue: 'nib_motion 0.3.5 / nib_components 0.2.3; see Water Lab report')}.\n'
                'Local candidate API: NibWaterGlass → NibWaterSurface. Capture and solver timings are separate; these are not frame-rate measurements.',
                style: TextStyle(
                  color: tokens.mutedForeground,
                  fontSize: 11,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Original local vector artwork, painted without a network or image dependency.
class _WaterOriginalArtwork extends CustomPainter {
  const _WaterOriginalArtwork();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE8E4DA),
    );
    canvas.drawCircle(
      const Offset(170, 140),
      115,
      Paint()..color = const Color(0xFFCFDEA0),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(320, 75, 210, 230),
        const Radius.circular(28),
      ),
      Paint()..color = const Color(0xFF44584B),
    );
    for (var i = 0; i < 6; i++) {
      canvas.drawLine(
        Offset(40, 260 + i * 12),
        Offset(600, 160 + i * 12),
        Paint()
          ..color = const Color(0xFF8B927F)
          ..strokeWidth = 2,
      );
    }
    final label = TextPainter(
      text: const TextSpan(
        text: 'NIB / WATER STUDY',
        style: TextStyle(
          color: Color(0xFF202724),
          fontSize: 16,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(canvas, const Offset(28, 28));
  }

  @override
  bool shouldRepaint(_WaterOriginalArtwork oldDelegate) => false;
}

class _WaterNeutralGrid extends CustomPainter {
  const _WaterNeutralGrid();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFECEBE5),
    );
    final line = Paint()
      ..color = const Color(0xFF969B96)
      ..strokeWidth = 1;
    for (var x = 0.0; x <= size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    for (var y = 0.0; y <= size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
    final text = TextPainter(
      text: const TextSpan(
        text: 'LOOK THROUGH\nTHE WATER',
        style: TextStyle(
          color: Color(0xFF323B36),
          fontSize: 34,
          height: 1.3,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 400);
    text.paint(
      canvas,
      Offset((size.width - text.width) / 2, (size.height - text.height) / 2),
    );
  }

  @override
  bool shouldRepaint(_WaterNeutralGrid oldDelegate) => false;
}

class _WaterTypography extends StatelessWidget {
  const _WaterTypography();
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFFECEBE5),
    child: Padding(
      padding: const EdgeInsets.all(35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MATERIAL / 001',
            style: TextStyle(
              color: Color(0xFF454F47),
              fontSize: 13,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          const Text(
            'Still readable.\nUntil the water moves.',
            style: TextStyle(
              color: Color(0xFF202724),
              fontSize: 45,
              height: 1.14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 26),
          const Text(
            'The letters belong to the backdrop. The lens samples them.',
            style: TextStyle(color: Color(0xFF454F47), fontSize: 15),
          ),
          const Spacer(),
        ],
      ),
    ),
  );
}
