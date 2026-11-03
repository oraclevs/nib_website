import 'package:flutter/material.dart';

import '../content/site_content.dart';
import '../content/motion_capabilities.dart';
import 'doc_blocks.dart';
import '../ember_theme.dart';

class PackagesPage extends StatelessWidget {
  const PackagesPage({super.key, required this.onOpenPackage});

  final ValueChanged<String> onOpenPackage;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final narrow = constraints.maxWidth < 720;
      return SingleChildScrollView(
        key: const PageStorageKey('packages-scroll'),
        child: EmberWrap(
          child: Padding(
            padding: EdgeInsets.only(top: narrow ? 44 : 82, bottom: 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EmberEyebrow('THREE LAYERS · ONE FLUTTER WORKFLOW'),
                const SizedBox(height: 22),
                Text(
                  'Start with the layer\nyou need.',
                  style: TextStyle(
                    color: Ember.text,
                    fontSize: narrow ? 46 : 76,
                    height: 1.02,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -2.4,
                  ),
                ),
                const SizedBox(height: 22),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 610),
                  child: const Text(
                    'Use NibMotion when a widget needs to move between states. Choose NibComponents for themed controls and forms; it includes NibMotion. Explore NibGenUI through its local fixture to see supported structured messages become Flutter widgets.',
                    style: TextStyle(
                      color: Ember.muted,
                      fontSize: 17,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                for (var i = 0; i < SiteContent.packages.length; i++) ...[
                  _PackageEditorialCard(
                    info: SiteContent.packages[i],
                    index: i + 1,
                    onTap: () => onOpenPackage(SiteContent.packages[i].id),
                  ),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 42),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: Ember.soft,
                    border: Border.all(color: Ember.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 24,
                    runSpacing: 18,
                    children: const [
                      Text(
                        'Try a behavior. Read the source. Bring it into your app.',
                        style: TextStyle(
                          color: Ember.text,
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Published packages and local candidates are labeled separately.',
                        style: TextStyle(color: Ember.muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class PackageDetailPage extends StatelessWidget {
  const PackageDetailPage({
    super.key,
    required this.packageId,
    required this.onOpenDoc,
  });

  final String packageId;

  /// Receives a section ID for the current package.
  final ValueChanged<String> onOpenDoc;

  @override
  Widget build(BuildContext context) {
    final info = SiteContent.packageById(packageId);
    if (info == null) {
      return Center(
        child: Text(
          'No package named $packageId.',
          style: const TextStyle(color: Ember.text),
        ),
      );
    }
    final docs = SiteContent.articlesFor(packageId);
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 720;
        final cardWidth = narrow ? constraints.maxWidth - 38 : 315.0;
        return SingleChildScrollView(
          key: PageStorageKey('package-$packageId-scroll'),
          child: EmberWrap(
            child: Padding(
              padding: EdgeInsets.only(top: narrow ? 34 : 72, bottom: 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Crumb(parts: ['PACKAGES']),
                  const SizedBox(height: 28),
                  EmberEyebrow(info.role),
                  const SizedBox(height: 16),
                  Text(
                    info.name,
                    style: TextStyle(
                      color: Ember.text,
                      fontSize: narrow ? 48 : 78,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -2.7,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    info.tagline,
                    style: TextStyle(
                      color: Ember.accent,
                      fontSize: narrow ? 21 : 29,
                      height: 1.25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Text(
                      info.description,
                      style: const TextStyle(
                        color: Ember.muted,
                        fontSize: 17,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _StatusPill(
                    label: info.status,
                    experimental: info.install == null,
                  ),
                  const SizedBox(height: 52),
                  _InstallPanel(
                    info: info,
                    onRead: () => onOpenDoc('getting-started'),
                  ),
                  const SizedBox(height: 58),
                  const _SectionHeading(
                    eyebrow: 'WHAT YOU CAN BUILD',
                    title: 'Choose your next interaction.',
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      if (packageId == 'motion')
                        for (final group in motionCapabilities)
                          Container(
                            width: cardWidth,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Ember.panel,
                              border: Border.all(color: Ember.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  group.heading,
                                  style: const TextStyle(
                                    color: Ember.text,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  group.paragraphs.single,
                                  style: const TextStyle(
                                    color: Ember.muted,
                                    fontSize: 15,
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                DocBlocks(
                                  blocks: group.blocks,
                                  onNavigate: (route) => onOpenDoc(
                                    Uri.parse(route).pathSegments.last,
                                  ),
                                ),
                              ],
                            ),
                          )
                      else
                        for (var i = 0; i < info.capabilities.length; i++)
                          _CapabilityCard(
                            index: i + 1,
                            title: info.capabilities[i],
                            width: cardWidth,
                          ),
                    ],
                  ),
                  const SizedBox(height: 58),
                  const _SectionHeading(
                    eyebrow: 'READ THE DETAILS',
                    title: 'Learn the package, one task at a time.',
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1060),
                    child: Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        for (final article in docs)
                          _DocTile(
                            article: article,
                            width: narrow ? constraints.maxWidth - 38 : 332,
                            onTap: () => onOpenDoc(article.id),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 44),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Ember.soft,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: Ember.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Ember.accent,
                          size: 19,
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Text(
                            info.caution,
                            style: const TextStyle(
                              color: Ember.text,
                              height: 1.5,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PackageEditorialCard extends StatefulWidget {
  const _PackageEditorialCard({
    required this.info,
    required this.index,
    required this.onTap,
  });
  final PackageInfo info;
  final int index;
  final VoidCallback onTap;

  @override
  State<_PackageEditorialCard> createState() => _PackageEditorialCardState();
}

class _PackageEditorialCardState extends State<_PackageEditorialCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: _hovered ? Ember.raised : Ember.panel,
        border: Border.all(color: _hovered ? Ember.strong : Ember.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 760;
                final intro = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.index.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        color: Ember.accent,
                        fontFamily: Ember.mono,
                        fontSize: 12,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.info.name,
                      style: TextStyle(
                        color: Ember.text,
                        fontSize: compact ? 28 : 35,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.7,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      widget.info.tagline,
                      style: const TextStyle(color: Ember.accent, fontSize: 16),
                    ),
                  ],
                );
                final detail = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.info.description,
                      style: const TextStyle(color: Ember.muted, height: 1.5),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      widget.info.status.toUpperCase(),
                      style: const TextStyle(
                        color: Ember.positive,
                        fontFamily: Ember.mono,
                        fontSize: 10,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                );
                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      intro,
                      const SizedBox(height: 22),
                      detail,
                      const SizedBox(height: 22),
                      const _ExploreLabel(),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(flex: 4, child: intro),
                    const SizedBox(width: 24),
                    Expanded(flex: 5, child: detail),
                    const SizedBox(width: 24),
                    const _ExploreLabel(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}

class _ExploreLabel extends StatelessWidget {
  const _ExploreLabel();
  @override
  Widget build(BuildContext context) => const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'Explore package',
        style: TextStyle(color: Ember.accent, fontSize: 13),
      ),
      SizedBox(width: 8),
      Icon(Icons.arrow_outward, color: Ember.accent, size: 16),
    ],
  );
}

class _Crumb extends StatelessWidget {
  const _Crumb({required this.parts});
  final List<String> parts;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final part in parts) ...[
        Text(
          part,
          style: const TextStyle(
            color: Ember.muted,
            fontFamily: Ember.mono,
            fontSize: 11,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(width: 10),
        const Icon(Icons.chevron_right, size: 15, color: Ember.strong),
        const SizedBox(width: 10),
      ],
    ],
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.experimental});
  final String label;
  final bool experimental;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: experimental ? Ember.soft : Ember.raised,
      border: Border.all(color: Ember.border),
      borderRadius: BorderRadius.circular(3),
    ),
    child: Text(
      label.toUpperCase(),
      style: TextStyle(
        color: experimental ? Ember.accent : Ember.positive,
        fontFamily: Ember.mono,
        fontSize: 10,
        letterSpacing: 1.2,
      ),
    ),
  );
}

class _InstallPanel extends StatelessWidget {
  const _InstallPanel({required this.info, required this.onRead});
  final PackageInfo info;
  final VoidCallback onRead;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: Ember.code,
      border: Border.all(color: Ember.border),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 24,
      runSpacing: 20,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              info.install == null ? 'LOCAL FIXTURE PREVIEW' : 'GET STARTED',
              style: const TextStyle(
                color: Ember.accent,
                fontFamily: Ember.mono,
                fontSize: 10,
                letterSpacing: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            SelectableText(
              info.install == null
                  ? 'Public installation is not available yet.'
                  : '\$ ${info.install}',
              style: TextStyle(
                color: Ember.text,
                fontFamily: Ember.mono,
                fontSize: info.install == null ? 14 : 17,
              ),
            ),
          ],
        ),
        EmberButton(
          label: 'Read the guide',
          onPressed: onRead,
          icon: Icons.arrow_outward,
        ),
      ],
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.eyebrow, required this.title});
  final String eyebrow;
  final String title;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      EmberEyebrow(eyebrow),
      const SizedBox(height: 12),
      Text(
        title,
        style: const TextStyle(
          color: Ember.text,
          fontSize: 30,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _CapabilityCard extends StatelessWidget {
  const _CapabilityCard({
    required this.index,
    required this.title,
    required this.width,
  });
  final int index;
  final String title;
  final double width;
  @override
  Widget build(BuildContext context) => Container(
    width: width,
    constraints: const BoxConstraints(minHeight: 155),
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Ember.panel,
      border: Border.all(color: Ember.border),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          index.toString().padLeft(2, '0'),
          style: const TextStyle(
            color: Ember.accent,
            fontFamily: Ember.mono,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 23),
        Text(
          title,
          style: const TextStyle(
            color: Ember.text,
            fontSize: 19,
            height: 1.25,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _DocTile extends StatefulWidget {
  const _DocTile({
    required this.article,
    required this.width,
    required this.onTap,
  });
  final DocArticle article;
  final double width;
  final VoidCallback onTap;
  @override
  State<_DocTile> createState() => _DocTileState();
}

class _DocTileState extends State<_DocTile> {
  bool hovered = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => hovered = true),
    onExit: (_) => setState(() => hovered = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: widget.width,
      constraints: const BoxConstraints(minHeight: 142),
      decoration: BoxDecoration(
        color: hovered ? Ember.raised : Ember.panel,
        border: Border.all(color: hovered ? Ember.strong : Ember.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.article.title,
                        style: const TextStyle(
                          color: Ember.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_outward,
                      color: Ember.accent,
                      size: 17,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.article.summary,
                  style: const TextStyle(
                    color: Ember.muted,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
