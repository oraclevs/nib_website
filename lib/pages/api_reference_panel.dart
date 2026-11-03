import 'dart:convert';

import 'package:flutter/material.dart';

import '../ember_theme.dart';
import '../widgets/dart_code_view.dart';

/// Declared public APIs extracted from package barrels and Dart ASTs.
class ApiReferencePanel extends StatefulWidget {
  const ApiReferencePanel({
    super.key,
    required this.packageId,
    this.symbolNames,
    this.title = 'Public API reference',
  });
  final String packageId;
  final List<String>? symbolNames;
  final String title;
  @override
  State<ApiReferencePanel> createState() => _ApiReferencePanelState();
}

class _ApiReferencePanelState extends State<ApiReferencePanel> {
  Future<Map<String, dynamic>>? _data;
  final _query = TextEditingController();
  String? _selected;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data ??= DefaultAssetBundle.of(context)
        .loadString('assets/reference/public_api.json')
        .then((text) => jsonDecode(text) as Map<String, dynamic>);
  }

  @override
  void didUpdateWidget(covariant ApiReferencePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.packageId != widget.packageId ||
        oldWidget.symbolNames != widget.symbolNames) {
      _selected = null;
      _query.clear();
    }
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, dynamic>>(
    future: _data,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Text(
          snapshot.hasError
              ? 'API reference could not load. Reload this guide to retry.'
              : 'Loading public API reference…',
        );
      }
      final symbols =
          ((snapshot.data!['packages'] as Map)[widget.packageId] as List)
              .cast<Map<String, dynamic>>()
              .where(
                (symbol) =>
                    widget.symbolNames == null ||
                    widget.symbolNames!.contains(symbol['name']),
              )
              .toList();
      final query = _query.text.trim().toLowerCase();
      final matches = symbols
          .where(
            (symbol) =>
                '${symbol['name']} ${(symbol['members'] as List).map((m) => m['name']).join(' ')}'
                    .toLowerCase()
                    .contains(query),
          )
          .toList();
      final selected =
          symbols.where((s) => s['name'] == _selected).firstOrNull ??
          (query.isEmpty
              ? symbols
                    .where(
                      (s) =>
                          s['name'] ==
                          switch (widget.packageId) {
                            'motion' => 'NibMotion',
                            'components' => 'NibButton',
                            _ => 'NibGeneratedSurface',
                          },
                    )
                    .firstOrNull
              : null) ??
          matches.firstOrNull;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              color: Ember.text,
              fontSize: 23,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Browse ${symbols.length} public types and functions. Select a name to read its purpose, constructor parameters, defaults and methods. Inherited Flutter members are not repeated here.',
            style: const TextStyle(
              color: Ember.muted,
              fontSize: 13,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _query,
            onChanged: (_) => setState(() => _selected = null),
            decoration: InputDecoration(
              labelText: 'Find an API or member',
              hintText: switch (widget.packageId) {
                'motion' => 'Try NibMotion, drag or controller',
                'components' => 'Try NibButton, theme or validation',
                _ => 'Try NibRuntime, surface or transport',
              },
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: matches.isEmpty
                ? 90
                : (matches.length * 43.0).clamp(48, 190),
            decoration: BoxDecoration(
              color: Ember.panel,
              border: Border.all(color: Ember.border),
              borderRadius: BorderRadius.circular(6),
            ),
            child: matches.isEmpty
                ? const Center(
                    child: Text('No matching APIs. Try a shorter name.'),
                  )
                : ListView.builder(
                    primary: false,
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      final symbol = matches[index];
                      final active = symbol['name'] == selected?['name'];
                      return Material(
                        color: active ? Ember.soft : Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(
                            () => _selected = symbol['name'] as String,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    symbol['name'] as String,
                                    style: TextStyle(
                                      color: active ? Ember.accent : Ember.text,
                                      fontFamily: Ember.mono,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  symbol['kind'] as String,
                                  style: const TextStyle(
                                    color: Ember.muted,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (selected != null) ...[
            const SizedBox(height: 25),
            SelectableText(
              selected['name'] as String,
              style: const TextStyle(
                color: Ember.accent,
                fontFamily: Ember.mono,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            _comment(
              _documentation(
                selected['name'] as String,
                null,
                selected['documentation'] as String? ?? '',
              ),
            ),
            const SizedBox(height: 12),
            for (final group in const {
              'constructor': 'Constructors',
              'enum value': 'Available values',
              'property': 'Properties',
              'method': 'Methods',
              'function': 'Function signature',
              'getter': 'Getter',
              'setter': 'Setter',
              'definition': 'Definition',
            }.entries)
              if ((selected['members'] as List).any(
                (m) => m['kind'] == group.key,
              )) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 22, bottom: 4),
                  child: Text(
                    group.value,
                    style: const TextStyle(
                      color: Ember.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                for (final member
                    in (selected['members'] as List)
                        .cast<Map<String, dynamic>>()
                        .where((m) => m['kind'] == group.key)) ...[
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: Ember.code,
                      border: Border.all(color: Ember.border),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SingleChildScrollView(
                            primary: false,
                            scrollDirection: Axis.horizontal,
                            child: DartCodeView(
                              code: member['signature'] as String,
                              fontSize: 11,
                            ),
                          ),
                          if ((member['documentation'] as String? ?? '')
                              .isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _comment(
                              _documentation(
                                selected['name'] as String,
                                member['name'] as String,
                                member['documentation'] as String,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
          ],
        ],
      );
    },
  );
  // These source comments currently disagree with the implementation.
  String _documentation(String symbol, String? member, String source) =>
      switch ('$symbol.${member ?? ''}') {
        'NibTextReveal.' => 'Reveals the laid-out child with a directional clip. The implementation uses a timed tween; duration, delay and curve control the reveal.',
        'NibTextReveal.controller' => 'Accepted by the constructor, but not attached by the current implementation. Replay by remounting with a new key. Calling start() on this controller does not replay the reveal.',
        'NibTextConfig.transition' => 'Defaults to a 400 ms tween when null. A supplied spring controls settling. NibText replaces transition.delay with its per-unit stagger delay.',
        _ => source,
      };

  Widget _comment(String text) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    final chunks = text.split('```');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < chunks.length; i++)
          if (chunks[i].trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: i.isOdd
                  ? SingleChildScrollView(
                      primary: false,
                      scrollDirection: Axis.horizontal,
                      child: DartCodeView(
                        code: chunks[i]
                            .replaceFirst(RegExp(r'^\w*\n'), '')
                            .trim(),
                        fontSize: 11,
                      ),
                    )
                  : SelectableText.rich(
                      _inlineDocumentation(chunks[i].trim()),
                      style: const TextStyle(
                        color: Ember.muted,
                        fontSize: 13,
                        height: 1.85,
                      ),
                    ),
            ),
      ],
    );
  }

  TextSpan _inlineDocumentation(String text) {
    final spans = <TextSpan>[];
    final pattern = RegExp(
      r'`([^`]+)`|\[([A-Za-z_][A-Za-z0-9_.<>?]*)\]|\*\*([^*]+)\*\*',
    );
    var cursor = 0;
    for (final match in pattern.allMatches(text)) {
      spans.add(TextSpan(text: text.substring(cursor, match.start)));
      spans.add(
        TextSpan(
          text: match.group(1) ?? match.group(2) ?? match.group(3),
          style: TextStyle(
            color: Ember.text,
            fontFamily: match.group(3) == null ? Ember.mono : null,
            fontWeight: match.group(3) == null ? null : FontWeight.w600,
          ),
        ),
      );
      cursor = match.end;
    }
    spans.add(TextSpan(text: text.substring(cursor)));
    return TextSpan(children: spans);
  }
}
