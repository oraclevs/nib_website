import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ember_theme.dart';
import 'site_search_data.dart';
import 'site_search_index.dart';

Future<String?> showDocsSearchDialog(
  BuildContext context, {
  SiteSearchIndex? index,
}) => showDialog<String>(
  context: context,
  barrierColor: const Color(0xB8080A08),
  barrierLabel: 'Close search',
  builder: (_) => DocsSearchDialog(index: index ?? buildSiteSearchIndex()),
);

class DocsSearchDialog extends StatefulWidget {
  const DocsSearchDialog({super.key, required this.index});

  final SiteSearchIndex index;

  @override
  State<DocsSearchDialog> createState() => _DocsSearchDialogState();
}

class _DocsSearchDialogState extends State<DocsSearchDialog> {
  final TextEditingController _query = TextEditingController();
  final ScrollController _resultsScroll = ScrollController();
  int _selected = 0;

  @override
  void dispose() {
    _query.dispose();
    _resultsScroll.dispose();
    super.dispose();
  }

  List<SiteSearchEntry> get _results => widget.index.search(_query.text);

  void _showSelectedResult() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_resultsScroll.hasClients) return;
      const rowHeight = 64.0;
      final position = _resultsScroll.position;
      final top = 12 + _selected * rowHeight;
      final bottom = top + rowHeight;
      var target = position.pixels;
      if (top < target) {
        target = top;
      } else if (bottom > target + position.viewportDimension) {
        target = bottom - position.viewportDimension;
      }
      _resultsScroll.jumpTo(target.clamp(0.0, position.maxScrollExtent));
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }
    final results = _results;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
        results.isNotEmpty) {
      setState(() => _selected = (_selected + 1) % results.length);
      _showSelectedResult();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp && results.isNotEmpty) {
      setState(
        () => _selected = (_selected - 1 + results.length) % results.length,
      );
      _showSelectedResult();
      return KeyEventResult.handled;
    }
    if ((event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter) &&
        results.isNotEmpty) {
      Navigator.of(context).pop(results[_selected].route);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Dialog(
      backgroundColor: Ember.panel,
      elevation: 28,
      shadowColor: Colors.black,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFF5B624E)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Focus(
          onKeyEvent: _onKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.sizeOf(context).width <= 639 ? 15 : 20,
                  vertical: MediaQuery.sizeOf(context).width <= 639 ? 12 : 16,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 19, color: Ember.accent),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        controller: _query,
                        autofocus: true,
                        onChanged: (_) {
                          setState(() => _selected = 0);
                          _showSelectedResult();
                        },
                        style: const TextStyle(color: Ember.text, fontSize: 14),
                        cursorColor: Ember.accent,
                        decoration: const InputDecoration(
                          hintText: 'Search documentation and recipes…',
                          hintStyle: TextStyle(color: Ember.muted),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Ember.muted,
                        backgroundColor: Ember.raised,
                        minimumSize: const Size(37, 25),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        side: const BorderSide(color: Ember.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text(
                        'ESC',
                        style: TextStyle(fontFamily: Ember.mono, fontSize: 9),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Ember.border),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: results.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 30,
                        ),
                        child: Text(
                          'No matching pages',
                          style: TextStyle(color: Ember.muted, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        controller: _resultsScroll,
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(12),
                        itemExtent: 64,
                        itemCount: results.length,
                        itemBuilder: (context, index) => _DialogResult(
                          entry: results[index],
                          selected: index == _selected,
                          onHover: () => setState(() => _selected = index),
                          onTap: () =>
                              Navigator.of(context).pop(results[index].route),
                        ),
                      ),
              ),
              const Divider(height: 1, color: Ember.border),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '↑ ↓ Navigate · Enter opens · Escape closes',
                    style: TextStyle(
                      color: Ember.muted,
                      fontFamily: Ember.mono,
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogResult extends StatelessWidget {
  const _DialogResult({
    required this.entry,
    required this.selected,
    required this.onHover,
    required this.onTap,
  });

  final SiteSearchEntry entry;
  final bool selected;
  final VoidCallback onHover;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (entry.kind) {
      SiteSearchKind.package => (Icons.widgets_outlined, 'Package'),
      SiteSearchKind.guide => (Icons.menu_book_outlined, 'Guide'),
      SiteSearchKind.recipe => (Icons.auto_awesome_motion, 'Example'),
    };
    return InkWell(
      onTap: onTap,
      onHover: (hovering) {
        if (hovering) onHover();
      },
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? Ember.raised : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Icon(icon, color: Ember.accent, size: 19),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Ember.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: const TextStyle(color: Ember.muted, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
