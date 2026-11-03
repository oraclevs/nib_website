import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

import '../docs/doc_example_catalog.dart';
import '../ember_theme.dart';
import 'doc_example_panel.dart';

/// One mounted preview at a time; choosing a recipe also changes its source.
class DocExampleGallery extends StatefulWidget {
  const DocExampleGallery({
    super.key,
    required this.examples,
    required this.onNavigate,
  });
  final List<DocExample> examples;
  final ValueChanged<String> onNavigate;
  @override
  State<DocExampleGallery> createState() => _DocExampleGalleryState();
}

class _DocExampleGalleryState extends State<DocExampleGallery> {
  int _selected = 0;
  @override
  void didUpdateWidget(covariant DocExampleGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.examples.map((e) => e.identity).join() !=
        widget.examples.map((e) => e.identity).join()) {
      _selected = 0;
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (widget.examples.length > 1) ...[
        const Text(
          'CHOOSE AN EXAMPLE',
          style: TextStyle(
            fontFamily: Ember.mono,
            fontSize: 10,
            letterSpacing: 1.2,
            color: Ember.muted,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var index = 0; index < widget.examples.length; index++)
              ChoiceChip(
                label: Text(widget.examples[index].title),
                selected: index == _selected,
                onSelected: (_) => setState(() => _selected = index),
                side: BorderSide(
                  color: index == _selected
                      ? const Color(0xFF876421)
                      : Ember.border,
                ),
                selectedColor: Ember.soft,
                backgroundColor: Ember.panel,
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: index == _selected ? Ember.accent : Ember.text,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
      ],
      DocExamplePanel(
        example: widget.examples[_selected],
        onNavigate: widget.onNavigate,
      ),
    ],
  );
}

/// The lesson stays readable; its demo is mounted only when requested.
class DocExampleButton extends StatelessWidget {
  const DocExampleButton({
    super.key,
    required this.example,
    required this.onNavigate,
    required this.reducedMotion,
  });
  final DocExample example;
  final ValueChanged<String> onNavigate;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    icon: const Icon(Icons.play_arrow, size: 16),
    label: Text('Try ${example.title}'),
    style: OutlinedButton.styleFrom(
      foregroundColor: Ember.accent,
      side: const BorderSide(color: Ember.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    onPressed: () => showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Ember.bg,
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'Close example',
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  primary: false,
                  padding: const EdgeInsets.all(12),
                  child: NibMotionConfig(
                    reducedMotion: reducedMotion,
                    child: DocExamplePanel(
                      example: example,
                      onNavigate: (route) {
                        Navigator.pop(context);
                        onNavigate(route);
                      },
                    ),
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
