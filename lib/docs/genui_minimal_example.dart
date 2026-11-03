/// The smallest local fixture loop: create a surface, then render native text.
/// Full example retains the form, binding updates, and guarded action handler.
const minimalGenUiExample =
    r'''// Requires the local unpublished nib_genui packages used by this guide.
// Local fixture only. No backend or AI request is made.
import 'package:flutter/material.dart';
import 'package:nib_genui/nib_genui.dart';

void main() => runApp(const MaterialApp(home: Scaffold(
  body: Center(child: NibExample()),
)));

class NibExample extends StatefulWidget {
  const NibExample({super.key});
  @override
  State<NibExample> createState() => _NibExampleState();
}

class _NibExampleState extends State<NibExample> {
  final runtime = NibRuntime(
    catalogs: [NibCatalog.basic()],
    maxMessageBytes: 4096,
    maxNodes: 4,
    maxSurfaces: 1,
    maxDepth: 4,
    maxStringLength: 256,
    maxDataModelBytes: 1024,
    maxProtocolMessages: 8,
  );
  int frame = 0;
  String status = 'Create a surface, then add its text.';
  static const frames = [
    {'version': 'v0.9.1', 'createSurface': {
      'surfaceId': 'demo',
      'catalogId': 'https://a2ui.org/specification/v0_9_1/catalogs/basic/catalog.json',
    }},
    {'version': 'v0.9.1', 'updateComponents': {
      'surfaceId': 'demo',
      'components': [
        {'id': 'root', 'component': 'Text', 'text': 'Native generated UI'},
      ],
    }},
  ];

  @override
  void dispose() { runtime.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(status),
      if (frame > 0) NibGeneratedSurface(runtime: runtime, surfaceId: 'demo'),
      TextButton(
        onPressed: frame == frames.length ? null : () {
          final result = runtime.apply(frames[frame]);
          setState(() {
            if (result.accepted) { frame++; status = 'Frame $frame accepted'; }
            else { status = 'Fixture frame rejected'; }
          });
        },
        child: const Text('Apply next frame'),
      ),
    ],
  );
}
''';
