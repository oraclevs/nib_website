import '../../components/component_toggle.dart';

import 'package:flutter/material.dart';
import 'package:nib_components/nib_components.dart';

/// NibInput validates inside Flutter Form; the host owns the result.
class ComponentsFormExample extends StatefulWidget {
  const ComponentsFormExample({super.key});

  @override
  State<ComponentsFormExample> createState() => _ComponentsFormExampleState();
}

class _ComponentsFormExampleState extends State<ComponentsFormExample> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  String _name = '';
  String _message = '';
  bool _updates = false;

  @override
  Widget build(BuildContext context) => Form(
    key: _form,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NibInput(
          label: 'Your name',
          maxLength: 40,
          validator: NibValidators.required('Enter a name'),
          onChanged: (value) => _name = value,
        ),
        const SizedBox(height: 10),
        NibSwitch(
          thumbBuilder: nibSwitchThumb,
          trackWidth: 64,
          trackHeight: 36,
          label: 'Include updates',
          value: _updates,
          animated: true,
          onChanged: (value) => setState(() => _updates = value),
        ),
        const SizedBox(height: 12),
        NibButton(
          label: 'Check form',
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            setState(
              () => _message =
                  'Ready for ${_name.trim()}${_updates ? ' with updates' : ''}',
            );
          },
        ),
        if (_message.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(_message),
        ],
      ],
    ),
  );
}
