import 'package:flutter/material.dart';
import 'package:nib_components/nib_components.dart';

/// Change one dark NibTheme token and watch the NibButton use it.
class ComponentsThemeExample extends StatefulWidget {
  const ComponentsThemeExample({super.key});

  @override
  State<ComponentsThemeExample> createState() => _ComponentsThemeExampleState();
}

class _ComponentsThemeExampleState extends State<ComponentsThemeExample> {
  bool _warm = true;
  int _presses = 0;

  @override
  Widget build(BuildContext context) {
    final accent = _warm ? const Color(0xFFFFB51B) : const Color(0xFFCFDEA0);
    final nibTheme = NibTheme.of(context).copyWith(
      primary: accent,
      primaryForeground: const Color(0xFF241A05),
      ring: accent,
    );
    return Theme(
      data: Theme.of(context).copyWith(extensions: [nibTheme]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Dark palette · ${_warm ? 'amber' : 'sage'}'),
          const SizedBox(height: 15),
          NibButton(
            label: 'Pressed $_presses',
            onPressed: () => setState(() => _presses++),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() => _warm = !_warm),
            child: const Text('Change accent token'),
          ),
        ],
      ),
    );
  }
}
