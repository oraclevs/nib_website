import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/widgets/dart_code_view.dart';

void main() {
  test('Dart highlighting preserves source and separates comments, strings, numbers and keywords', () {
    const source =
        "// import is a comment\nconst value = r'raw\\path';\n/* outer /* inner */ end */\nfinal size = 0xFFB51B;\nNibMotion(child: Text('Hello 🌍'));";
    final spans = highlightDart(source);
    expect(spans.map((s) => s.text).join(), source);
    expect(spans.first.text, '// import is a comment');
    expect(
      spans.first.style!.color,
      isNot(spans.firstWhere((s) => s.text == 'const').style!.color),
    );
    expect(
      spans.firstWhere((s) => s.text!.startsWith('/*')).text,
      '/* outer /* inner */ end */',
    );
    expect(
      spans.firstWhere((s) => s.text == '0xFFB51B').style!.color,
      isNotNull,
    );
    expect(
      spans.firstWhere((s) => s.text == 'NibMotion').style!.color,
      isNotNull,
    );
  });

  test('unfinished multiline snippets remain copyable', () {
    for (final source in [
      "final s = '''multi\nline",
      '/* unfinished',
      "'escaped\\' quote'",
    ]) {
      expect(highlightDart(source).map((s) => s.text).join(), source);
    }
  });
}
