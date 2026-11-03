import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

/// The label reports capability; it does not call a fallback a GPU pass.
class MotionShaderExample extends StatefulWidget {
  const MotionShaderExample({super.key});
  @override
  State<MotionShaderExample> createState() => _MotionShaderExampleState();
}

class _MotionShaderExampleState extends State<MotionShaderExample> {
  late final Future<bool> _shader = NibGlass.debugShaderPathAvailable();
  double _blur = 4;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        height: 170,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned(
              left: 10,
              top: 14,
              child: Icon(Icons.circle, color: Color(0xFFFFB51B), size: 100),
            ),
            const Positioned(
              right: 5,
              bottom: 10,
              child: Icon(Icons.circle, color: Color(0xFFCFDEA0), size: 95),
            ),
            NibGlass(
              blurSigma: _blur,
              child: const SizedBox(
                width: 200,
                height: 110,
                child: Center(
                  child: Text(
                    'A surface with depth',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      Slider(
        value: _blur,
        min: 1,
        max: 12,
        label: _blur.toStringAsFixed(1),
        onChanged: (value) => setState(() => _blur = value),
      ),
      Text('Blur sigma: ${_blur.toStringAsFixed(1)}'),
      const SizedBox(height: 8),
      FutureBuilder<bool>(
        future: _shader,
        builder: (context, snapshot) => Text(
          snapshot.data == true ? 'Shader filter available on this renderer.' : 'Frosted blur fallback on this renderer. Edge refraction needs a supported shader filter.',
          textAlign: TextAlign.center,
        ),
      ),
    ],
  );
}
