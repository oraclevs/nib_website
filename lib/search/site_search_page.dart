import 'package:flutter/material.dart';

import '../ember_theme.dart';
import 'site_search_data.dart';
import 'site_search_index.dart';

/// Route-ready search body. The global site shell owns the header and this
/// page owns scrolling, query state, filtering, and result navigation.
class SiteSearchPage extends StatefulWidget {
  const SiteSearchPage({super.key, required this.onNavigate, this.index});

  final ValueChanged<String> onNavigate;
  final SiteSearchIndex? index;

  @override
  State<SiteSearchPage> createState() => _SiteSearchPageState();
}

class _SiteSearchPageState extends State<SiteSearchPage> {
  final _query = TextEditingController();
  SiteSearchKind? _kind;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final index = widget.index ?? buildSiteSearchIndex();
    final results = index.search(_query.text, kind: _kind);
    final compact = MediaQuery.sizeOf(context).width < 700;
    return Title(
      title: 'Search Nib | Packages, guides and recipes',
      color: Ember.bg,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: EmberWrap(
          child: Padding(
            padding: EdgeInsets.only(top: compact ? 38 : 72, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EmberEyebrow('SEARCH / NIB'),
                const SizedBox(height: 16),
                Text(
                  'Search Nib',
                  style: TextStyle(
                    color: Ember.text,
                    fontSize: compact ? 38 : 60,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                'Find packages, guides, and recipes.',
                  style: TextStyle(color: Ember.muted, fontSize: 16),
                ),
                const SizedBox(height: 28),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: TextField(
                    controller: _query,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(color: Ember.text, fontSize: 16),
                    cursorColor: Ember.accent,
                    decoration: InputDecoration(
                      hintText: 'Try “spring”, “button”, or “A2UI”',
                      hintStyle: const TextStyle(color: Ember.strong),
                      prefixIcon: const Icon(Icons.search, color: Ember.accent),
                      suffixIcon: _query.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              onPressed: () {
                                _query.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close, color: Ember.muted),
                            ),
                      filled: true,
                      fillColor: Ember.panel,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 19,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: const BorderSide(color: Ember.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: const BorderSide(
                          color: Ember.accent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _filter('All', null),
                    _filter('Packages', SiteSearchKind.package),
                    _filter('Guides', SiteSearchKind.guide),
                    _filter('Recipes', SiteSearchKind.recipe),
                  ],
                ),
                const SizedBox(height: 40),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    '${results.length} ${results.length == 1 ? 'result' : 'results'}',
                    style: const TextStyle(
                      color: Ember.muted,
                      fontFamily: Ember.mono,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (results.isEmpty)
                  _emptyState()
                else
                  ...results.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _SearchResult(
                        entry: entry,
                        onTap: () => widget.onNavigate(entry.route),
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

  Widget _filter(String label, SiteSearchKind? kind) {
    final selected = _kind == kind;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _kind = kind),
      backgroundColor: Ember.panel,
      selectedColor: Ember.accent,
      side: BorderSide(color: selected ? Ember.accent : Ember.border),
      labelStyle: TextStyle(
        color: selected ? Ember.onAccent : Ember.muted,
        fontWeight: FontWeight.w700,
      ),
      showCheckmark: false,
    );
  }

  Widget _emptyState() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: Ember.panel,
      border: Border.all(color: Ember.border),
      borderRadius: BorderRadius.circular(9),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'No matches yet.',
          style: TextStyle(
            color: Ember.text,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 7),
        Text(
          'Try a package name, an interaction, or a shorter search.',
          style: TextStyle(color: Ember.muted),
        ),
      ],
    ),
  );
}

class _SearchResult extends StatelessWidget {
  const _SearchResult({required this.entry, required this.onTap});

  final SiteSearchEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kindLabel = switch (entry.kind) {
      SiteSearchKind.package => 'PACKAGE',
      SiteSearchKind.guide => 'GUIDE',
      SiteSearchKind.recipe => 'RECIPE',
    };
    return Material(
      color: Ember.panel,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 20),
          decoration: BoxDecoration(
            border: Border.all(color: Ember.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kindLabel,
                      style: const TextStyle(
                        color: Ember.accent,
                        fontFamily: Ember.mono,
                        fontSize: 10,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      entry.title,
                      style: const TextStyle(
                        color: Ember.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      entry.summary,
                      style: const TextStyle(color: Ember.muted, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_outward, color: Ember.accent, size: 19),
            ],
          ),
        ),
      ),
    );
  }
}
