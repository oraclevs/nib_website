import '../docs/doc_example_catalog.dart';

/// Compact runnable examples for the component guides in the docs gallery.
String? minimalComponentDocExample(DocExample example) =>
    switch (example.widgetClass) {
      'ComponentsButtonExample' => _wrap(
        fields: 'int count = 0;',
        body: r'''Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Pressed $count times'),
        const SizedBox(height: 12),
        NibButton(
          label: 'Add one',
          onPressed: () => setState(() => count++),
        ),
      ],
    )''',
      ),
      'ComponentsFormExample' => _wrap(
        fields: '''final form = GlobalKey<FormState>();
  String name = '';
  String message = '';''',
        body: r'''Form(
      key: form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NibInput(
            label: 'Your name',
            validator: NibValidators.required('Enter a name'),
            onChanged: (value) => name = value,
          ),
          const SizedBox(height: 12),
          NibButton(
            label: 'Check form',
            onPressed: () {
              if (form.currentState!.validate()) {
                setState(() => message = 'Ready for ${name.trim()}');
              }
            },
          ),
          if (message.isNotEmpty) Text(message),
        ],
      ),
    )''',
      ),
      'ComponentsThemeExample' => _wrap(
        fields: 'bool warm = true;',
        body: r'''Theme(
      data: Theme.of(context).copyWith(extensions: [
        NibTheme.of(context).copyWith(
          primary: warm ? const Color(0xFFFFB51B) : const Color(0xFFCFDEA0),
          primaryForeground: const Color(0xFF241A05),
        ),
      ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NibButton(label: 'Save', onPressed: () {}),
          TextButton(
            onPressed: () => setState(() => warm = !warm),
            child: const Text('Change accent'),
          ),
        ],
      ),
    )''',
      ),
      _ => null,
    };

String _wrap({required String fields, required String body}) =>
    '''// Add nib_components to your Flutter app, then paste into lib/main.dart.
import 'package:flutter/material.dart';
import 'package:nib_components/nib_components.dart';

void main() => runApp(const MaterialApp(home: Scaffold(
  body: Center(child: Padding(
    padding: EdgeInsets.all(24),
    child: SizedBox(width: 320, child: ComponentExample()),
  )),
)));

class ComponentExample extends StatefulWidget {
  const ComponentExample({super.key});
  @override
  State<ComponentExample> createState() => _ComponentExampleState();
}

class _ComponentExampleState extends State<ComponentExample> {
  $fields

  @override
  Widget build(BuildContext context) => $body;
}
''';
