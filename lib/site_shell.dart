import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nib_motion/nib_motion.dart';

import 'ember_theme.dart';
import 'content/site_content.dart';
import 'components/component_catalog.dart';
import 'recipes/recipe_catalog.dart';
import 'search/docs_search_dialog.dart';
import 'site_navigation.dart';

class SiteShell extends StatefulWidget {
  const SiteShell({
    super.key,
    required this.path,
    required this.onNavigate,
    required this.child,
  });

  final String path;
  final ValueChanged<String> onNavigate;
  final Widget child;

  @override
  State<SiteShell> createState() => _SiteShellState();
}

class _SiteShellState extends State<SiteShell> {
  final ScrollController _docsScroll = ScrollController();

  @override
  void didUpdateWidget(covariant SiteShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (Uri.parse(oldWidget.path).path != Uri.parse(widget.path).path) {
      if (_docsScroll.positions.length == 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _docsScroll.positions.length == 1) {
            _docsScroll.jumpTo(0);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _docsScroll.dispose();
    super.dispose();
  }

  String get path => widget.path;
  ValueChanged<String> get onNavigate => widget.onNavigate;
  Widget get child => widget.child;

  String get _pageTitle {
    if (path == '/components') return 'Components | Nib';
    if (path == '/packages') return 'Packages | Nib';
    if (path == '/packages/motion') return 'NibMotion | Nib';
    if (path == '/packages/components') return 'NibComponents | Nib';
    if (path == '/packages/genui') return 'NibGenUI | Nib';
    if (path.startsWith('/docs/')) {
      final parts = Uri.parse(path).pathSegments;
      final article = parts.length == 3
          ? SiteContent.articleById(parts[1], parts[2])
          : null;
      return '${article?.title ?? 'Guide not found'} | Nib';
    }
    if (path == '/examples') return 'NibMotion examples | Nib';
    if (path.startsWith('/playground/components/')) {
      return '${componentById(Uri.parse(path).pathSegments.last)?.title ?? 'Component playground'} | Nib';
    }
    if (path.startsWith('/playground/')) {
      return '${recipeById(Uri.parse(path).pathSegments.last)?.title ?? 'Playground'} | Nib';
    }
    if (path == '/search') return 'Search Nib | Packages, guides and recipes';
    return 'Page not found | Nib';
  }

  void _showSupport(BuildContext context) => showDialog<void>(
    context: context,
    builder: (dialog) => AlertDialog(
      backgroundColor: Ember.panel,
      title: const Text('Support Nib'),
      content: const Text(
        'Payments are coming soon. There is no donation checkout on this site yet.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialog),
          child: const Text('Close'),
        ),
      ],
    ),
  );

  Future<void> _openDocsSearch() async {
    final destination = await showDocsSearchDialog(context);
    if (mounted && destination != null) onNavigate(destination);
  }

  Widget _buildDocs(BuildContext context) {
    final document = Column(
      children: [
        SiteNavigation(
          path: path,
          onNavigate: onNavigate,
          onSearch: _openDocsSearch,
          onSupport: () => _showSupport(context),
        ),
        Expanded(child: child),
      ],
    );
    return Title(
      title: _pageTitle,
      color: Ember.bg,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyK, meta: true):
              _openDocsSearch,
          const SingleActivator(LogicalKeyboardKey.keyK, control: true):
              _openDocsSearch,
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: Ember.bg,
            body: Stack(
              children: [
                SafeArea(
                  child: NibMotionConfig(
                    reducedMotion: MediaQuery.of(context).disableAnimations,
                    child: PrimaryScrollController(
                      controller: _docsScroll,
                      child: document,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _docsScroll,
                      builder: (context, _) {
                        var progress = 0.0;
                        if (_docsScroll.positions.length == 1 &&
                            _docsScroll.position.hasContentDimensions) {
                          final max = _docsScroll.position.maxScrollExtent;
                          if (max > 0) {
                            progress = (_docsScroll.offset / max).clamp(0, 1);
                          }
                        }
                        return LayoutBuilder(
                          builder: (context, constraints) => Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              key: const ValueKey('docs-reading-progress'),
                              width: constraints.maxWidth * progress,
                              height: 3,
                              child: const ColoredBox(color: Ember.accent),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDocs = path.startsWith('/docs/');
    if (isDocs) return _buildDocs(context);
    return Title(
      title: _pageTitle,
      color: Ember.bg,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyK, meta: true):
              _openDocsSearch,
          const SingleActivator(LogicalKeyboardKey.keyK, control: true):
              _openDocsSearch,
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: Ember.bg,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: NibMotionConfig(
                  reducedMotion: MediaQuery.of(context).disableAnimations,
                  child: Column(
                    children: [
                      SiteNavigation(
                        path: path,
                        onNavigate: onNavigate,
                        onSearch: _openDocsSearch,
                        onSupport: () => _showSupport(context),
                      ),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SiteNotFoundPage extends StatelessWidget {
  const SiteNotFoundPage({
    super.key,
    required this.path,
    required this.onNavigate,
  });

  final String path;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) => Center(
    child: EmberWrap(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EmberEyebrow('404 / PAGE NOT FOUND'),
            const SizedBox(height: 18),
            const Text(
              'This page has wandered off.',
              style: TextStyle(
                color: Ember.text,
                fontSize: 36,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            SelectableText(
              path,
              style: const TextStyle(
                color: Ember.muted,
                fontFamily: Ember.mono,
              ),
            ),
            const SizedBox(height: 20),
            EmberButton(
              label: 'Back to Nib',
              onPressed: () => onNavigate('/'),
              icon: Icons.arrow_forward,
            ),
          ],
        ),
      ),
    ),
  );
}
