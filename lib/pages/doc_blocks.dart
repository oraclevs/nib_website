import 'package:flutter/material.dart';

import '../content/site_content.dart';
import '../ember_theme.dart';
import '../external_link.dart';

/// Body blocks retain their content and links at every reading width.
class DocBlocks extends StatelessWidget {
  const DocBlocks({super.key, required this.blocks, required this.onNavigate});
  final List<DocBlock> blocks;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final block in blocks)
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: switch (block) {
            DocList() => _list(block.items, block.ordered),
            DocTable() => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: const TextStyle(
                  color: Ember.text,
                  fontWeight: FontWeight.w600,
                ),
                dataTextStyle: const TextStyle(
                  color: Ember.muted,
                  fontSize: 13,
                ),
                horizontalMargin: 12,
                columnSpacing: 24,
                border: TableBorder.all(color: Ember.border),
                columns: [
                  for (final label in block.headers)
                    DataColumn(label: Text(label)),
                ],
                rows: [
                  for (final row in block.rows)
                    DataRow(
                      cells: [for (final cell in row) DataCell(Text(cell))],
                    ),
                ],
              ),
            ),
            DocLink() => Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => block.route.startsWith('https://')
                    ? openExternalLink(block.route)
                    : onNavigate(block.route),
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: Text(block.label),
                style: TextButton.styleFrom(foregroundColor: Ember.accent),
              ),
            ),
          },
        ),
    ],
  );

  Widget _list(List<DocListItem> items, bool ordered) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final (index, item) in items.indexed)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  ordered ? '${index + 1}.' : '•',
                  style: const TextStyle(color: Ember.accent, height: 1.8),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      item.text,
                      style: const TextStyle(
                        color: Ember.muted,
                        fontSize: 14,
                        height: 1.8,
                      ),
                    ),
                    if (item.children.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _list(item.children, false),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
    ],
  );
}
