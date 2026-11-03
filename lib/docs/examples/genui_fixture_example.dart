import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nib_genui/nib_genui.dart';

enum GenUiLesson { replay, rollback, localEditing, actions }

/// Local fixture replay only. It sends no network or AI requests.
///
/// The three frames match the supported subset fixture in
/// GenUINib/examples/nib_genui_example/assets/demo.jsonl. The host registers
/// one synthetic action and validates its input before showing local feedback.
class GenUiFixtureExample extends StatefulWidget {
  const GenUiFixtureExample({super.key, this.lesson = GenUiLesson.replay});

  final GenUiLesson lesson;

  @override
  State<GenUiFixtureExample> createState() => _GenUiFixtureExampleState();
}

class _GenUiFixtureExampleState extends State<GenUiFixtureExample> {
  static const _frames = <String>[
    r'''{"version":"v0.9.1","createSurface":{"surfaceId":"demo","catalogId":"https://a2ui.org/specification/v0_9_1/catalogs/basic/catalog.json"}}''',
    r'''{"version":"v0.9.1","updateComponents":{"surfaceId":"demo","components":[{"id":"root","component":"Column","children":["greeting","name","submit"]},{"id":"greeting","component":"Text","text":{"path":"/greeting"},"variant":"h2"},{"id":"name","component":"TextField","label":"Your name","value":{"path":"/name"}},{"id":"submit","component":"Button","child":"submit_label","variant":"primary","action":{"event":{"name":"submit","context":{"name":{"path":"/name"}}}}},{"id":"submit_label","component":"Text","text":"Say hello"}]}}''',
    r'''{"version":"v0.9.1","updateDataModel":{"surfaceId":"demo","path":"/","value":{"greeting":"Native generated UI","name":""}}}''',
  ];

  late NibRuntime _runtime;
  StreamSubscription<NibActionDecision>? _decisions;
  StreamSubscription<NibNodeChange>? _changes;
  int _session = 0;
  bool _allowed = true;
  int _applied = 0;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _newRuntime();
    _prepareLesson();
  }

  @override
  void didUpdateWidget(covariant GenUiFixtureExample oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lesson != widget.lesson) _reset();
  }

  void _prepareLesson() {
    if (widget.lesson != GenUiLesson.replay) {
      for (final frame in _frames) {
        if (_runtime.applyJson(frame).accepted) _applied++;
      }
    }
  }

  void _reset() {
    _decisions?.cancel();
    _changes?.cancel();
    _runtime.dispose();
    _applied = 0;
    _message = '';
    _allowed = true;
    _newRuntime();
    _prepareLesson();
  }

  void _newRuntime() {
    final session = ++_session;
    _runtime = NibRuntime(
      catalogs: [NibCatalog.basic()],
      actions: {
        'submit': (event) {
          final value = event.context['name'];
          if (value is String && mounted) {
            setState(() => _message = 'Hello, ${value.trim()}');
          }
        },
      },
      actionContextPaths: {
        'submit': {'name': '/name'},
      },
      actionGuards: {
        'submit': (event) {
          final value = event.context['name'];
          return _allowed && value is String && value.trim().isNotEmpty;
        },
      },
      maxMessageBytes: 8192,
      maxNodes: 8,
      maxSurfaces: 1,
      maxDepth: 8,
      maxStringLength: 256,
      maxDataModelBytes: 4096,
      maxProtocolMessages: 32,
    );
    _decisions = _runtime.actionDecisions.listen((decision) {
      if (!mounted || session != _session) return;
      if (!decision.accepted) {
        setState(
          () => _message = decision.code == 'action_validation_failed'
              ? (_allowed ? 'Enter a name first' : 'Host permission denied')
              : 'Action rejected: ${decision.code}',
        );
      }
    });
    _changes = _runtime.nodeChanges.listen((change) {
      if (mounted && session == _session && change.surfaceId == 'demo') {
        setState(() {});
      }
    });
  }

  void _nextFrame() {
    if (_applied == _frames.length) {
      setState(_reset);
      return;
    }
    final message = jsonDecode(_frames[_applied]) as Map<String, dynamic>;
    final result = _runtime.apply(message);
    setState(() {
      if (result.accepted) {
        _applied++;
        _message = '';
      } else {
        _message = 'Fixture frame rejected';
      }
    });
  }

  void _rejectInvalidUpdate() {
    final result = _runtime.apply({
      'version': 'v0.9.1',
      'updateComponents': {
        'surfaceId': 'demo',
        'components': [
          {'id': 'greeting', 'component': 'Text', 'text': 42},
        ],
      },
    });
    setState(
      () => _message = result.accepted
          ? 'Unexpected acceptance; inspect the fixture.'
          : 'Rejected ${result.diagnostics.first.code}. The committed greeting stays.',
    );
  }

  void _writeName({required bool remote}) {
    final result = remote
        ? _runtime.apply({
            'version': 'v0.9.1',
            'updateDataModel': {
              'surfaceId': 'demo',
              'path': '/name',
              'value': 'Grace',
            },
          })
        : _runtime.writeData('demo', '/name', 'Ada');
    setState(
      () => _message = result.accepted
          ? (remote
                ? 'Remote fixture wrote Grace to /name.'
                : 'Local write stored Ada without a network request.')
          : 'Write rejected: ${result.diagnostics.first.code}',
    );
  }

  @override
  void dispose() {
    _session++;
    _decisions?.cancel();
    _changes?.cancel();
    _runtime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('Local fixture replay · no live AI request'),
      const SizedBox(height: 12),
      Text(switch (widget.lesson) {
        GenUiLesson.replay => 'Frame $_applied / ${_frames.length}',
        GenUiLesson.rollback =>
          'Reject a malformed update; keep the last committed surface.',
        GenUiLesson.localEditing => 'Type in the field, then compare a local write and a remote fixture update.',
        GenUiLesson.actions => 'The host checks current permission and a nonempty name on every dispatch.',
      }, textAlign: TextAlign.center),
      const SizedBox(height: 10),
      SizedBox(
        height: 235,
        child: NibGeneratedSurface(runtime: _runtime, surfaceId: 'demo'),
      ),
      if (_message.isNotEmpty) ...[const SizedBox(height: 8), Text(_message)],
      const SizedBox(height: 12),
      if (widget.lesson == GenUiLesson.localEditing) ...[
        Text(
          'Stored /name: ${_runtime.surface('demo')?.dataModel['name'] ?? ''}',
          key: const ValueKey('genui-bound-name'),
        ),
        Wrap(
          spacing: 8,
          children: [
            TextButton(
              onPressed: () => _writeName(remote: false),
              child: const Text('Write Ada locally'),
            ),
            TextButton(
              onPressed: () => _writeName(remote: true),
              child: const Text('Apply remote name'),
            ),
          ],
        ),
      ],
      if (widget.lesson == GenUiLesson.rollback)
        TextButton(
          onPressed: _rejectInvalidUpdate,
          child: const Text('Send invalid Text update'),
        ),
      if (widget.lesson == GenUiLesson.actions) ...[
        CheckboxListTile(
          dense: true,
          title: const Text('Allow local greeting'),
          value: _allowed,
          onChanged: (value) => setState(() => _allowed = value ?? false),
        ),
        Wrap(
          spacing: 8,
          children: [
            TextButton(
              onPressed: () => _runtime.dispatch('demo', 'submit'),
              child: const Text('Dispatch current button'),
            ),
            TextButton(
              onPressed: () => _runtime.dispatch('demo', 'removed'),
              child: const Text('Try stale component'),
            ),
          ],
        ),
      ],
      TextButton(
        onPressed: widget.lesson == GenUiLesson.replay
            ? _nextFrame
            : () => setState(_reset),
        child: Text(
          _applied == _frames.length ? 'Replay fixture' : 'Next frame',
        ),
      ),
    ],
  );
}
