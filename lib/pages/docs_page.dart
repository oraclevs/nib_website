import 'package:flutter/material.dart';

import 'docs_spring_reference.dart';

/// All documentation routes share the approved reference composition.
class DocsPage extends StatelessWidget {
  const DocsPage({
    super.key,
    required this.packageId,
    required this.sectionId,
    required this.onNavigate,
    this.anchor = '',
  });
  final String packageId;
  final String sectionId;
  final String anchor;
  final ValueChanged<String> onNavigate;
  @override
  Widget build(BuildContext context) => DocsSpringReference(
    packageId: packageId,
    sectionId: sectionId,
    anchor: anchor,
    onNavigate: onNavigate,
  );
}
