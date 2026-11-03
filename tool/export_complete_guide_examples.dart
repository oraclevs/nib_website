import 'dart:io';

import 'package:nib_ember_living/content/site_content.dart';

// Exports complete widget/app listings. In-build fragments need their lesson's host.
void main(List<String> args) {
  final destination = Directory(args.single)..createSync(recursive: true);
  var count = 0;
  for (final article in SiteContent.articles) {
    for (final section in article.sections) {
      final source = section.code;
      if (source == null ||
          !RegExp(r'\bclass \w+ (extends|implements) ').hasMatch(source)) {
        continue;
      }
      final imports = <String>[];
      if (!source.contains('package:flutter/') &&
          RegExp(r'\b(Widget|State|BuildContext)\b').hasMatch(source)) {
        imports.add("import 'package:flutter/material.dart';");
      }
      final package = switch (article.packageId) {
        'motion' => 'nib_motion',
        'components' => 'nib_components',
        _ => 'nib_genui',
      };
      if (!source.contains('package:$package/')) {
        imports.add("import 'package:$package/$package.dart';");
      }
      final name = '${article.packageId}_${article.id}_${section.id}'
          .replaceAll('-', '_');
      File('${destination.path}/$name.dart')
          .writeAsStringSync('${imports.join('\n')}\n$source\n');
      count++;
    }
  }
  stdout.writeln(
    'Exported $count complete widget/app listings. Build-method fragments are excluded.',
  );
}
