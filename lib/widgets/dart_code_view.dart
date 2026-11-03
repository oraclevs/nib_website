import 'package:flutter/material.dart';

import '../ember_theme.dart';

/// Selectable source with lightweight Dart lexical highlighting.
/// Tokens preserve every source character, including whitespace and comments.
class DartCodeView extends StatelessWidget {
  const DartCodeView({
    super.key,
    required this.code,
    this.fontSize = 12,
    this.lineHeight = 1.9,
    this.selectable = true,
  });

  final String code;
  final double fontSize;
  final double lineHeight;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final span = TextSpan(children: highlightDart(code));
    final style = TextStyle(
      color: const Color(0xFFD5D5BC),
      fontFamily: Ember.mono,
      fontSize: fontSize,
      height: lineHeight,
    );
    return selectable
        ? SelectableText.rich(span, style: style)
        : Text.rich(span, style: style);
  }
}

const _keywords = {
  'abstract',
  'as',
  'assert',
  'async',
  'await',
  'base',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'covariant',
  'default',
  'deferred',
  'do',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'external',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'get',
  'hide',
  'if',
  'implements',
  'import',
  'in',
  'interface',
  'is',
  'late',
  'library',
  'mixin',
  'new',
  'null',
  'of',
  'on',
  'operator',
  'part',
  'required',
  'rethrow',
  'return',
  'sealed',
  'set',
  'show',
  'static',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'typedef',
  'var',
  'void',
  'when',
  'while',
  'with',
  'yield',
};
final _identifier = RegExp(r'[a-zA-Z_$][a-zA-Z0-9_$]*');
final _number = RegExp(r'(?:0[xX][0-9a-fA-F]+|\d+(?:\.\d+)?(?:[eE][+-]?\d+)?)');

List<TextSpan> highlightDart(String source) {
  final spans = <TextSpan>[];
  var i = 0;
  void add(int end, Color? color) {
    spans.add(
      TextSpan(
        text: source.substring(i, end),
        style: color == null ? null : TextStyle(color: color),
      ),
    );
    i = end;
  }

  while (i < source.length) {
    if (source.startsWith('//', i)) {
      final end = source.indexOf('\n', i);
      add(end < 0 ? source.length : end, const Color(0xFFA8AD9A));
      continue;
    }
    if (source.startsWith('/*', i)) {
      var end = i + 2;
      var depth = 1;
      while (end < source.length && depth > 0) {
        if (source.startsWith('/*', end)) {
          depth++;
          end += 2;
        } else if (source.startsWith('*/', end)) {
          depth--;
          end += 2;
        } else {
          end++;
        }
      }
      add(end, const Color(0xFFA8AD9A));
      continue;
    }
    final raw =
        (source[i] == 'r' || source[i] == 'R') &&
        i + 1 < source.length &&
        (source[i + 1] == "'" || source[i + 1] == '"');
    final quoteAt = raw ? i + 1 : i;
    if (source[quoteAt] == "'" || source[quoteAt] == '"') {
      final quote = source[quoteAt];
      final delimiter = source.startsWith(quote * 3, quoteAt)
          ? quote * 3
          : quote;
      var end = quoteAt + delimiter.length;
      while (end < source.length) {
        if (!raw && source[end] == r'\') {
          end = (end + 2).clamp(0, source.length);
        } else if (source.startsWith(delimiter, end)) {
          end += delimiter.length;
          break;
        } else {
          end++;
        }
      }
      add(end, const Color(0xFFCFDEA0));
      continue;
    }
    final number = _number.matchAsPrefix(source, i);
    if (number != null) {
      add(number.end, const Color(0xFFFFCC6D));
      continue;
    }
    final word = _identifier.matchAsPrefix(source, i);
    if (word != null) {
      final value = word.group(0)!;
      add(
        word.end,
        _keywords.contains(value)
            ? const Color(0xFFDDBCF9)
            : RegExp(r'^[A-Z]').hasMatch(value)
            ? const Color(0xFF92D5D0)
            : null,
      );
      continue;
    }
    add(i + 1, null);
  }
  return spans;
}
