import 'package:flutter/material.dart';
import 'package:nib_components/nib_components.dart';
import 'package:nib_motion/nib_motion.dart' as motion;

import '../component_settings.dart';

class GlassBottomNavigationDemo extends StatelessWidget {
  const GlassBottomNavigationDemo({
    super.key,
    required this.settings,
    required this.onChanged,
    required this.onEvent,
  });
  final ComponentSettings settings;
  final ValueChanged<ComponentSettings> onChanged;
  final ValueChanged<String> onEvent;
  @override
  Widget build(BuildContext context) =>
      _BottomNavigationFrame(settings: settings, onEvent: onEvent, glass: true);
}

class LiquidBottomNavigationDemo extends StatelessWidget {
  const LiquidBottomNavigationDemo({
    super.key,
    required this.settings,
    required this.onChanged,
    required this.onEvent,
  });
  final ComponentSettings settings;
  final ValueChanged<ComponentSettings> onChanged;
  final ValueChanged<String> onEvent;
  @override
  Widget build(BuildContext context) => _BottomNavigationFrame(
    settings: settings,
    onEvent: onEvent,
    glass: false,
  );
}

class _BottomNavigationFrame extends StatefulWidget {
  const _BottomNavigationFrame({
    required this.settings,
    required this.onEvent,
    required this.glass,
  });
  final ComponentSettings settings;
  final ValueChanged<String> onEvent;
  final bool glass;
  @override
  State<_BottomNavigationFrame> createState() => _BottomNavigationFrameState();
}

class _BottomNavigationFrameState extends State<_BottomNavigationFrame> {
  int _index = 0;
  final _draft = TextEditingController();
  final _draftFocus = FocusNode();
  @override
  void dispose() {
    _draft.dispose();
    _draftFocus.dispose();
    super.dispose();
  }

  void _select(int index) {
    _draftFocus.unfocus();
    setState(() => _index = index);
    widget.onEvent('onIndexChanged: $index');
  }

  @override
  Widget build(BuildContext context) {
    final theme = NibTheme.of(context);
    final settings = widget.settings;
    final scaledLabel = MediaQuery.textScalerOf(context).scale(12);
    final barHeight = (scaledLabel * 2 + 48).clamp(72.0, 120.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.glass
              ? 'A glass bar over a scrolling workspace'
              : 'A liquid indicator follows the selected destination',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 330,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(settings.radius),
            child: ColoredBox(
              color: theme.secondary,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IndexedStack(
                      index: _index,
                      children: [
                        ListView(
                          padding: EdgeInsets.fromLTRB(
                            18,
                            18,
                            18,
                            barHeight + 30,
                          ),
                          children: [
                            const Text(
                              'Workspace overview',
                              key: ValueKey('bottom-nav-overview'),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 12),
                            for (final item in [
                              'Design review · 10:00',
                              'Package notes · 12:30',
                              'Community hour · 16:00',
                              'Next week · Build a small app',
                            ])
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.primary.withValues(alpha: .15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: theme.border),
                                ),
                                child: Text(item),
                              ),
                          ],
                        ),
                        ListView(
                          padding: EdgeInsets.fromLTRB(
                            18,
                            18,
                            18,
                            barHeight + 30,
                          ),
                          children: [
                            const Text(
                              'Inbox draft',
                              key: ValueKey('bottom-nav-inbox'),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 12),
                            NibInput(
                              controller: _draft,
                              focusNode: _draftFocus,
                              label: 'Local draft',
                              placeholder: 'Write a note, then change tabs',
                              onChanged: (value) =>
                                  widget.onEvent('Draft: $value'),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Your draft stays in this example when you switch destinations. Nothing is sent.',
                            ),
                          ],
                        ),
                        ListView(
                          padding: EdgeInsets.fromLTRB(
                            18,
                            18,
                            18,
                            barHeight + 30,
                          ),
                          children: const [
                            Text(
                              'Workspace settings',
                              key: ValueKey('bottom-nav-settings'),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Local preview only. Theme controls live in the guide inspector; browser history remains on this guide.',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 10,
                    child: SafeArea(
                      top: false,
                      left: false,
                      right: false,
                      child: motion.NibMotionConfig(
                        reducedMotion:
                            !settings.animated ||
                            MediaQuery.disableAnimationsOf(context),
                        child: motion.NibNavBar(
                          key: const ValueKey('composition-bottom-nav'),
                          currentIndex: _index,
                          onIndexChanged: _select,
                          style: motion.NibNavBarStyle(
                            glass: widget.glass,
                            glassBlur: settings.blurSigma,
                            glassHighlight: settings.highlight,
                            glassTint: theme.card.withValues(alpha: .32),
                            backgroundColor: theme.card,
                            activeColor: theme.primary,
                            inactiveColor: theme.mutedForeground,
                            height: barHeight,
                            borderRadius: BorderRadius.circular(
                              settings.radius,
                            ),
                            border: settings.showBorder
                                ? Border.all(color: theme.border)
                                : null,
                            labelStyle: TextStyle(fontSize: scaledLabel),
                          ),
                          indicator: motion.NibNavIndicatorStyle(
                            type: widget.glass
                                ? motion.NibNavIndicatorType.pill
                                : motion.NibNavIndicatorType.liquid,
                            color: theme.primary.withValues(alpha: .28),
                          ),
                          items: [
                            motion.NibNavItem(
                              icon: const Icon(Icons.dashboard_outlined),
                              activeIcon: const Icon(Icons.dashboard),
                              label: settings.text,
                              tooltip: 'Open ${settings.text}',
                            ),
                            motion.NibNavItem(
                              icon: const Icon(Icons.inbox_outlined),
                              activeIcon: const Icon(Icons.inbox),
                              label: 'Inbox',
                              tooltip: 'Open inbox',
                              badge: motion.NibNavBadge(
                                count: settings.value.round(),
                                color: theme.primary,
                                textColor: theme.primaryForeground,
                              ),
                            ),
                            const motion.NibNavItem(
                              icon: Icon(Icons.settings_outlined),
                              activeIcon: Icon(Icons.settings),
                              label: 'Settings',
                              tooltip: 'Open settings',
                            ),
                          ],
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
        Text(
          'Selected destination: $_index',
          key: const ValueKey('bottom-nav-selection'),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: NibButton(
            onPressed: () => _select((_index + 1) % 3),
            label: 'Next destination from host',
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.glass
              ? 'NibMotion glass background: shader refraction where supported, frosted blur fallback otherwise.'
              : 'NibMotion liquid indicator: nav_water.frag when loaded, painted lens fallback otherwise. This preview does not certify which renderer your device uses.',
          style: TextStyle(
            color: theme.mutedForeground,
            fontSize: 12,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
