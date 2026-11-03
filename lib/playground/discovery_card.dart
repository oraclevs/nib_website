import 'package:flutter/material.dart';

import '../ember_theme.dart';

class DiscoveryCard extends StatefulWidget {
  const DiscoveryCard({
    super.key,
    required this.title,
    required this.summary,
    required this.preview,
    required this.artHeight,
    required this.mobile,
    required this.compact,
    this.saved = false,
    required this.ambient,
    required this.onTap,
    this.onToggleFavorite,
    this.actionLabel,
  });

  final String title, summary;
  final String? actionLabel;
  final Widget preview;
  final double artHeight;
  final bool mobile, compact, saved, ambient;
  final VoidCallback onTap;
  final VoidCallback? onToggleFavorite;

  @override
  State<DiscoveryCard> createState() => _DiscoveryCardState();
}

class _DiscoveryCardState extends State<DiscoveryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final captionPadding = widget.mobile
        ? const EdgeInsets.symmetric(horizontal: 18, vertical: 16)
        : widget.compact
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 15)
        : const EdgeInsets.symmetric(horizontal: 20, vertical: 18);
    final titleSize = widget.mobile
        ? 14.0
        : widget.compact
        ? 13.0
        : 15.0;
    final detailSize = widget.compact && !widget.mobile ? 10.0 : 11.0;
    final art = widget.preview;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Ember.panel,
          border: Border.all(color: _hovered ? Ember.strong : Ember.border),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Semantics(
              button: true,
              label: 'Open ${widget.title} in playground',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: widget.artHeight,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Ember.code,
                          border: Border(
                            bottom: BorderSide(color: Ember.border),
                          ),
                        ),
                        child: widget.ambient
                            ? EmberFloat(
                                y: 2,
                                duration: const Duration(milliseconds: 4000),
                                child: art,
                              )
                            : art,
                      ),
                      Padding(
                        padding: captionPadding,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Ember.text,
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -.2,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    widget.summary,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Ember.muted,
                                      fontSize: detailSize,
                                    ),
                                  ),
                                  if (widget.actionLabel != null) ...[
                                    const SizedBox(height: 9),
                                    Text(
                                      widget.actionLabel!,
                                      style: const TextStyle(
                                        color: Ember.accent,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.north_east,
                              color: Ember.accent,
                              size: 17,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.onToggleFavorite != null)
              Positioned(
                top: 10,
                right: 10,
                child: Semantics(
                  button: true,
                  selected: widget.saved,
                  label: '${widget.saved ? 'Unsave' : 'Save'} ${widget.title}',
                  child: Material(
                    color: widget.saved ? Ember.soft : Ember.panel,
                    borderRadius: BorderRadius.circular(5),
                    child: InkWell(
                      onTap: widget.onToggleFavorite,
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: widget.saved
                                ? const Color(0xFF88621B)
                                : Ember.border,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Icon(
                          widget.saved ? Icons.star : Icons.star_border,
                          size: 17,
                          color: widget.saved ? Ember.accent : Ember.muted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
