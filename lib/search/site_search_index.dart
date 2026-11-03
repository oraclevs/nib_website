import 'package:flutter/foundation.dart';

/// One destination in the site's local search. Content and recipe inventories
/// supply these records; the search UI does not maintain a second copy.
@immutable
class SiteSearchEntry {
  const SiteSearchEntry({
    required this.title,
    required this.summary,
    required this.route,
    required this.kind,
    this.keywords = const [],
  });

  final String title;
  final String summary;
  final String route;
  final SiteSearchKind kind;
  final List<String> keywords;
}

enum SiteSearchKind { package, guide, recipe }

/// Small, deterministic index for the site's bounded content inventory.
/// Every word in the query must match; title matches rank ahead of summaries.
class SiteSearchIndex {
  const SiteSearchIndex(this.entries);

  final List<SiteSearchEntry> entries;

  List<SiteSearchEntry> search(
    String query, {
    SiteSearchKind? kind,
    int? limit,
  }) {
    final terms = _terms(query);
    final matches = <(SiteSearchEntry, int, int)>[];
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      if (kind != null && entry.kind != kind) continue;
      final score = _score(entry, terms);
      if (score < 0) continue;
      matches.add((entry, score, i));
    }
    matches.sort((a, b) {
      final byScore = b.$2.compareTo(a.$2);
      return byScore != 0 ? byScore : a.$3.compareTo(b.$3);
    });
    final result = matches.map((match) => match.$1);
    return limit == null ? result.toList() : result.take(limit).toList();
  }

  static int _score(SiteSearchEntry entry, List<String> terms) {
    if (terms.isEmpty) return 0;
    final title = _normalize(entry.title);
    final summary = _normalize(entry.summary);
    final keywords = _normalize(entry.keywords.join(' '));
    final joined = terms.join(' ');
    var score = title == joined ? 100 : 0;
    if (title.startsWith(joined)) score += 45;
    for (final term in terms) {
      if (title.split(' ').any((word) => word == term)) {
        score += 20;
      } else if (title.contains(term)) {
        score += 12;
      } else if (keywords.contains(term)) {
        score += 5;
      } else if (summary.contains(term)) {
        score += 2;
      } else {
        return -1;
      }
    }
    return score;
  }

  static List<String> _terms(String value) =>
      _normalize(value).split(' ').where((term) => term.isNotEmpty).toList();

  static String _normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
}
