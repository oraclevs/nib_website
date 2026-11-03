// Generates the website's public API index from Dart syntax trees.
// Run from WebsiteEmberLiving; see tool/api_reference/README.md.
import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/analysis/utilities.dart';

final _nibRoot = Directory(Directory('..').resolveSymbolicLinksSync()).uri;
final _packageLibraries = <String, String>{
  'nib_motion': 'MotionNib/motion/lib',
  'nib_components': 'ComponetsNib/nib_components/lib',
  'nib_genui': 'GenUINib/packages/nib_genui/lib',
  'nib_genui_core': 'GenUINib/packages/nib_genui_core/lib',
  'nib_genui_http': 'GenUINib/packages/nib_genui_http/lib',
};
final _parsed = <String, CompilationUnit>{};
final _content = <String, String>{};
final _visiting = <String>{};

void main(List<String> args) {
  if (args.any((arg) => arg != '--check')) {
    stderr.writeln('Usage: dart tool/generate_api_reference.dart [--check]');
    exitCode = 64;
    return;
  }
  final groups = <String, List<Map<String, Object?>>>{};
  for (final entry in <String, List<String>>{
    'motion': ['MotionNib/motion/lib/nib_motion.dart'],
    'components': ['ComponetsNib/nib_components/lib/nib_components.dart'],
    'genui': [
      'GenUINib/packages/nib_genui/lib/nib_genui.dart',
      'GenUINib/packages/nib_genui_http/lib/nib_genui_http.dart',
    ],
  }.entries) {
    final symbols = <String, Map<String, Object?>>{};
    for (final library in entry.value) {
      for (final symbol in _library(library)) {
        final key = symbol['name'] as String;
        final prior = symbols[key];
        if (prior != null && prior['source'] != symbol['source']) {
          throw StateError(
            'Ambiguous public symbol $key: ${prior['source']} and ${symbol['source']}',
          );
        }
        symbols[key] = symbol;
      }
    }
    groups[entry.key] = symbols.values.toList()
      ..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
  }
  final output =
      const JsonEncoder.withIndent('  ').convert({'packages': groups}) + '\n';
  final target = File('assets/reference/public_api.json');
  if (args.contains('--check')) {
    if (!target.existsSync() || target.readAsStringSync() != output) {
      stderr.writeln(
        'API reference is stale. Regenerate with the command in tool/api_reference/README.md.',
      );
      exitCode = 1;
    } else {
      stdout.writeln(
        'API reference matches public signatures and current documentation policy.',
      );
    }
  } else {
    target.parent.createSync(recursive: true);
    target.writeAsStringSync(output);
    stdout.writeln(
      'Wrote ${target.path}: ${groups.map((k, v) => MapEntry(k, v.length))}',
    );
  }
}

List<Map<String, Object?>> _library(String relative) {
  if (!_visiting.add(relative)) {
    throw StateError('Export cycle at $relative');
  }
  try {
    final unit = _unit(relative);
    final collected = <Map<String, Object?>>[];
    for (final part in unit.directives.whereType<PartDirective>()) {
      final path = _resolve(relative, part.uri.stringValue!);
      collected.addAll(_declarations(path));
    }
    collected.addAll(_declarations(relative));
    for (final export in unit.directives.whereType<ExportDirective>()) {
      final path = _resolve(relative, export.uri.stringValue!);
      Iterable<Map<String, Object?>> exported = _library(path);
      for (final combinator in export.combinators) {
        if (combinator is ShowCombinator) {
          final visible = combinator.shownNames
              .map((name) => name.name)
              .toSet();
          exported = exported.where(
            (symbol) => visible.contains(symbol['name']),
          );
        } else if (combinator is HideCombinator) {
          final hidden = combinator.hiddenNames
              .map((name) => name.name)
              .toSet();
          exported = exported.where(
            (symbol) => !hidden.contains(symbol['name']),
          );
        } else {
          throw StateError('Unhandled export combinator in $relative');
        }
      }
      collected.addAll(exported);
    }
    final unique = <String, Map<String, Object?>>{};
    for (final symbol in collected) {
      unique[symbol['name'] as String] = symbol;
    }
    return unique.values.toList();
  } finally {
    _visiting.remove(relative);
  }
}

String _resolve(String from, String uri) {
  Uri target;
  if (uri.startsWith('package:')) {
    final path = uri.substring('package:'.length);
    final slash = path.indexOf('/');
    if (slash < 0 || !_packageLibraries.containsKey(path.substring(0, slash))) {
      throw StateError('Unexpected exported package URI $uri in $from');
    }
    target = _nibRoot.resolve(
      '${_packageLibraries[path.substring(0, slash)]}/${path.substring(slash + 1)}',
    );
  } else if (uri.startsWith('dart:')) {
    throw StateError('Unexpected SDK re-export $uri in $from');
  } else {
    target = _nibRoot.resolve(from).resolve(uri);
  }
  final absolute = File.fromUri(target).absolute;
  if (!absolute.existsSync())
    throw StateError('Missing exported source: $uri from $from');
  final rootPath = Directory.fromUri(_nibRoot).absolute.path
      .replaceFirst(RegExp(r'/$'), '');
  if (!absolute.path.startsWith('$rootPath/'))
    throw StateError('Export escapes Nib workspace: $uri');
  return absolute.path.substring(rootPath.length + 1);
}

CompilationUnit _unit(String path) => _parsed.putIfAbsent(path, () {
  final source = File.fromUri(_nibRoot.resolve(path)).readAsStringSync();
  _content[path] = source;
  final result = parseString(
    content: source,
    path: path,
    throwIfDiagnostics: false,
  );
  if (result.errors.isNotEmpty) {
    throw StateError('Parse errors in $path: ${result.errors.join(', ')}');
  }
  return result.unit;
});

List<Map<String, Object?>> _declarations(String path) {
  final unit = _unit(path);
  final source = _content[path]!;
  final result = <Map<String, Object?>>[];
  for (final node in unit.declarations) {
    String? name;
    String? kind;
    final members = <Map<String, String>>[];
    if (node is ClassDeclaration) {
      name = node.namePart.typeName.lexeme;
      kind = 'class';
      members.addAll(_members(source, node.body.members, owner: name));
    } else if (node is EnumDeclaration) {
      name = node.namePart.typeName.lexeme;
      kind = 'enum';
      for (final value in node.body.constants) {
        if (!_private(value.name.lexeme)) {
          members.add(
            _member(
              value.name.lexeme,
              _signature(source, value, value.end),
              _documentation(value),
              kind: 'enum value',
            ),
          );
        }
      }
      members.addAll(_members(source, node.body.members, owner: name));
    } else if (node is MixinDeclaration) {
      name = node.name.lexeme;
      kind = 'mixin';
      members.addAll(_members(source, node.body.members));
    } else if (node is ExtensionDeclaration) {
      name = node.name?.lexeme;
      kind = 'extension';
      if (name == null)
        continue; // Anonymous extensions have no importable symbol name.
      members.addAll(_members(source, node.body.members));
    } else if (node is ExtensionTypeDeclaration) {
      name = node.namePart.typeName.lexeme;
      kind = 'extension type';
      members.addAll(_members(source, node.body.members));
    } else if (node is TypeAlias) {
      name = node.name.lexeme;
      kind = 'typedef';
      members.add(
        _member(
          name,
          _signature(source, node, node.end),
          '',
          kind: 'definition',
        ),
      );
    } else if (node is FunctionDeclaration) {
      name = node.name.lexeme;
      kind = node.isGetter
          ? 'getter'
          : node.isSetter
          ? 'setter'
          : 'function';
      final end =
          node.functionExpression.parameters?.end ??
          node.functionExpression.body.offset;
      members.add(_member(name, _signature(source, node, end), '', kind: kind));
    } else if (node is TopLevelVariableDeclaration) {
      for (final field in node.variables.variables) {
        if (_private(field.name.lexeme)) continue;
        result.add(
          _symbol(field.name.lexeme, 'variable', _documentation(node), path, [
            _member(
              field.name.lexeme,
              _variableSignature(source, node, field),
              '',
            ),
          ]),
        );
      }
      continue;
    } else {
      throw StateError(
        'Unhandled public declaration ${node.runtimeType} in $path at ${node.offset}',
      );
    }
    if (_private(name)) continue;
    result.add(_symbol(name, kind, _documentation(node), path, members));
  }
  return result;
}

List<Map<String, String>> _members(
  String source,
  NodeList<ClassMember> declarations, {
  String? owner,
}) {
  final result = <Map<String, String>>[];
  for (final node in declarations) {
    if (node is ConstructorDeclaration) {
      final name = node.name == null
          ? owner ?? 'new'
          : '${owner ?? ''}.${node.name!.lexeme}';
      if (node.name == null || !_private(node.name!.lexeme)) {
        result.add(
          _member(
            name,
            _signature(source, node, node.parameters.end),
            _documentation(node),
            kind: 'constructor',
          ),
        );
      }
    } else if (node is MethodDeclaration) {
      final name = node.name.lexeme;
      if (!_private(name)) {
        final end = node.parameters?.end ?? node.body.offset;
        result.add(
          _member(
            name,
            _signature(source, node, end),
            _documentation(node),
            kind: node.isGetter || node.isSetter ? 'property' : 'method',
          ),
        );
      }
    } else if (node is FieldDeclaration) {
      for (final field in node.fields.variables) {
        if (!_private(field.name.lexeme)) {
          result.add(
            _member(
              field.name.lexeme,
              _variableSignature(source, node, field),
              _documentation(node),
            ),
          );
        }
      }
    } else {
      throw StateError(
        'Unhandled class member ${node.runtimeType} at ${node.offset}',
      );
    }
  }
  return result;
}

String _variableSignature(
  String source,
  AnnotatedNode node,
  VariableDeclaration field,
) {
  final prefix = source.substring(
    node.firstTokenAfterCommentAndMetadata.offset,
    field.name.end,
  );
  // Constants can have long or implementation-specific initializers. The
  // declared name and type are the useful public contract here.
  return prefix.trim();
}

String _signature(String source, AnnotatedNode node, int end) =>
    source.substring(node.firstTokenAfterCommentAndMetadata.offset, end).trim();
bool _private(String value) => value.startsWith('_');

String _documentation(AnnotatedNode node) {
  final comment = node.documentationComment;
  if (comment == null) return '';
  final lines = comment.tokens.expand((token) => token.lexeme.split('\n')).map((
    line,
  ) {
    var value = line.trimLeft();
    if (value.startsWith('///')) {
      value = value.substring(3);
    } else {
      if (value.startsWith('/**')) value = value.substring(3);
      if (value.startsWith('/*')) value = value.substring(2);
      if (value.startsWith('*')) value = value.substring(1);
      if (value.endsWith('*/')) value = value.substring(0, value.length - 2);
    }
    // Remove only the conventional space after the comment marker. Indented
    // Markdown examples inside documentation retain their meaningful spaces.
    if (value.startsWith(' ')) value = value.substring(1);
    return value.trimRight();
  }).toList();
  while (lines.isNotEmpty && lines.first.isEmpty) {
    lines.removeAt(0);
  }
  while (lines.isNotEmpty && lines.last.isEmpty) {
    lines.removeLast();
  }
  return lines.join('\n');
}

Map<String, String> _member(
  String name,
  String signature,
  String documentation, {
  String kind = 'property',
}) => {
  'name': name,
  'kind': kind,
  'signature': signature,
  'documentation': documentation,
};

Map<String, Object?> _symbol(
  String name,
  String kind,
  String documentation,
  String source,
  List<Map<String, String>> members,
) => {
  'name': name,
  'kind': kind,
  'documentation': _currentDocumentation(name, documentation),
  'source': source,
  'members': members,
};

// Maintainer approved stable water on 2026-11-03. Published archive comments
// predate that policy; preserve all signatures, limits and the pinned source hash.
String _currentDocumentation(String name, String documentation) {
  const openings = {
    'NibWaterSurface': ('Experimental optical water', 'Optical water'),
    'NibWaterQuality': (
      'Device-relative sampling quality for the experimental layer sampler.',
      'Device-relative sampling quality for the layer sampler.',
    ),
    'NibWaterGlass': ('Experimental water material', 'Water material'),
  };
  final edit = openings[name];
  return edit == null
      ? documentation
      : documentation.replaceFirst(edit.$1, edit.$2);
}
