import 'package:flutter/material.dart';
import 'package:nib_components/nib_components.dart';

/// A real NibButton handles a local counter, loading and disabled state.
class ComponentsButtonExample extends StatefulWidget {
  const ComponentsButtonExample({super.key});

  @override
  State<ComponentsButtonExample> createState() =>
      _ComponentsButtonExampleState();
}

class _ComponentsButtonExampleState extends State<ComponentsButtonExample> {
  int _count = 0;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('Pressed $_count ${_count == 1 ? 'time' : 'times'}'),
      const SizedBox(height: 16),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: [
          NibButton(
            label: 'Add one',
            animated: true,
            onPressed: () => setState(() => _count++),
          ),
          NibButton(
            label: 'Reset',
            variant: NibButtonVariant.outline,
            onPressed: _count == 0 ? null : () => setState(() => _count = 0),
          ),
        ],
      ),
    ],
  );
}
