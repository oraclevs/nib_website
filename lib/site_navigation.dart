import 'package:flutter/material.dart';

import 'ember_theme.dart';

/// The shared header used by the home page and every inner page.
class SiteNavigation extends StatefulWidget {
  const SiteNavigation({
    super.key,
    required this.path,
    required this.onNavigate,
    required this.onSearch,
    required this.onSupport,
  });

  final String path;
  final ValueChanged<String> onNavigate;
  final VoidCallback onSearch;
  final VoidCallback onSupport;

  @override
  State<SiteNavigation> createState() => _SiteNavigationState();
}

class _SiteNavigationState extends State<SiteNavigation> {
  bool _menuOpen = false;

  @override
  void didUpdateWidget(covariant SiteNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) _menuOpen = false;
  }

  bool _selected(String label) => switch (label) {
    'Ecosystem' => widget.path == '/' || widget.path.startsWith('/packages'),
    'Docs' =>
      widget.path.startsWith('/docs') &&
          !widget.path.startsWith('/docs/components/'),
    'Components' =>
      widget.path == '/components' ||
          widget.path.startsWith('/docs/components/'),
    'Motion' => widget.path == '/examples',
    'Playground' => widget.path.startsWith('/playground'),
    _ => false,
  };

  void _navigate(String path) {
    if (_menuOpen) setState(() => _menuOpen = false);
    widget.onNavigate(path);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final narrow =
        width <= 1024 || MediaQuery.textScalerOf(context).scale(13) > 17;
    final compactSearch = width <= 850;
    final horizontalPadding = narrow
        ? 20.0
        : width <= 1199
        ? 32.0
        : 56.0;
    final navGap = width <= 850
        ? 20.0
        : width <= 1199
        ? 22.0
        : 28.0;
    final height = narrow ? 68.0 : 84.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          key: const ValueKey('site-navigation'),
          height: height,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          decoration: const BoxDecoration(
            color: Ember.bg,
            border: Border(bottom: BorderSide(color: Ember.border)),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () => _navigate('/'),
                child: Semantics(
                  button: true,
                  label: 'Nib home',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _NibBrandMark(width: narrow ? 88 : 100),
                      if (width >= 1200) ...[
                        const SizedBox(width: 20),
                        const Text(
                          'ECOSYSTEM',
                          style: TextStyle(
                            color: Ember.muted,
                            fontFamily: Ember.mono,
                            fontSize: 9,
                            letterSpacing: 1.7,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (!narrow) ...[
                _SiteNavLink(
                  label: 'Ecosystem',
                  selected: _selected('Ecosystem'),
                  onTap: () => _navigate('/'),
                  height: height,
                ),
                SizedBox(width: navGap),
                _SiteNavLink(
                  label: 'Motion',
                  selected: _selected('Motion'),
                  onTap: () => _navigate('/examples'),
                  height: height,
                ),
                SizedBox(width: navGap),
                _SiteNavLink(
                  label: 'Docs',
                  selected: _selected('Docs'),
                  onTap: () => _navigate('/docs/motion/springs'),
                  height: height,
                ),
                SizedBox(width: navGap),
                _SiteNavLink(
                  label: 'Components',
                  selected: _selected('Components'),
                  onTap: () => _navigate('/components'),
                  height: height,
                ),
                SizedBox(width: navGap),
                _SiteNavLink(
                  label: 'Playground',
                  selected: _selected('Playground'),
                  onTap: () => _navigate('/playground/spring-retarget'),
                  height: height,
                ),
                SizedBox(width: width <= 1199 ? 24 : 34),
              ],
              _SiteSearchButton(
                compact: compactSearch,
                width: width <= 1199 ? 170 : 190,
                onTap: widget.onSearch,
              ),
              if (narrow) ...[
                const SizedBox(width: 10),
                Tooltip(
                  message: _menuOpen ? 'Close navigation' : 'Open navigation',
                  excludeFromSemantics: true,
                  child: Semantics(
                    button: true,
                    label: _menuOpen ? 'Close navigation' : 'Open navigation',
                    child: SizedBox(
                      width: 42,
                      height: 42,
                      child: OutlinedButton(
                        onPressed: () => setState(() => _menuOpen = !_menuOpen),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          foregroundColor: Ember.text,
                          side: const BorderSide(color: Ember.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Icon(
                          _menuOpen ? Icons.close : Icons.menu,
                          size: 19,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (narrow && _menuOpen)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
            decoration: const BoxDecoration(
              color: Ember.panel,
              border: Border(bottom: BorderSide(color: Ember.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (label, route) in [
                  ('Ecosystem', '/'),
                  ('Motion', '/examples'),
                  ('Docs', '/docs/motion/springs'),
                  ('Components', '/components'),
                  ('Playground', '/playground/spring-retarget'),
                ])
                  TextButton(
                    onPressed: () => _navigate(route),
                    style: TextButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      foregroundColor: Ember.text,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                    child: Text(label),
                  ),
                TextButton(
                  onPressed: () {
                    setState(() => _menuOpen = false);
                    widget.onSupport();
                  },
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    foregroundColor: Ember.accent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                  ),
                  child: const Text('Support Nib'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Approved NIB wordmark: the fountain nib forms the I.
class _NibBrandMark extends StatelessWidget {
  const _NibBrandMark({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/brand/nib-mark.png',
    width: width,
    height: width * 210 / 355,
    fit: BoxFit.contain,
    filterQuality: FilterQuality.high,
    excludeFromSemantics: true,
  );
}

class _SiteNavLink extends StatelessWidget {
  const _SiteNavLink({
    required this.label,
    required this.onTap,
    required this.height,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final double height;
  final bool selected;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    child: InkWell(
      onTap: onTap,
      child: SizedBox(
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Ember.text : Ember.muted,
                fontSize: 13,
                letterSpacing: 0,
                height: 1.55,
              ),
            ),
            if (selected)
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SizedBox(
                  key: ValueKey('site-active-underline'),
                  height: 2,
                  child: ColoredBox(color: Ember.accent),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _SiteSearchButton extends StatelessWidget {
  const _SiteSearchButton({
    required this.compact,
    required this.width,
    required this.onTap,
  });

  final bool compact;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Search documentation',
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        key: const ValueKey('site-search-button'),
        width: compact ? 40 : width,
        height: 40,
        padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 12),
        decoration: BoxDecoration(
          color: Ember.panel,
          border: Border.all(color: Ember.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: compact
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            const Icon(Icons.search, color: Ember.muted, size: 15),
            if (!compact) ...[
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Search the docs',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Ember.muted,
                    fontSize: 12,
                    letterSpacing: 0,
                    height: 1.55,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Ember.raised,
                  border: Border.all(color: Ember.border),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  '⌘ K',
                  style: TextStyle(
                    color: Ember.muted,
                    fontFamily: Ember.mono,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
