import 'site_content.dart';

// Guide examples are still checked against the 0.3.5 archive.
const motionPublishedVersion = '0.3.5';
const motionLatestVersion = '0.3.6';
const motionReleaseNote =
    'These guides were checked against nib_motion $motionPublishedVersion. '
    'Version $motionLatestVersion is published on pub.dev. '
    'Shader rendering needs checks on your target device.';

const motionCapabilities = <DocSection>[
  DocSection(
    id: 'declarative-motion',
    heading: 'Declarative motion',
    paragraphs: [
      'Describe an entrance, a selected state, or a complete keyframe sequence with NibAnim and NibTransition. Named variants let a parent coordinate its children.',
    ],
    blocks: [
      DocLink('Create your first animation', '/docs/motion/first-animation'),
      DocLink(
        'Transitions, variants and stagger',
        '/docs/motion/variants-stagger',
      ),
      DocLink('Compose keyframes', '/docs/motion/keyframes'),
    ],
  ),
  DocSection(
    id: 'physics-and-gestures',
    heading: 'Physics and interactive gestures',
    paragraphs: [
      'Build a draggable card that coasts, meets a boundary, or snaps into place. Springs retarget from the current value and velocity, so another input can arrive before the last movement settles.',
    ],
    blocks: [
      DocLink('Retarget a spring', '/docs/motion/springs'),
      DocLink('Gestures, bounds and snap', '/docs/motion/gestures'),
      DocLink('Inertia and custom simulations', '/docs/motion/physics'),
    ],
  ),
  DocSection(
    id: 'layout-and-presence',
    heading: 'Layout and presence',
    paragraphs: [
      'Reorder a list, expand a card, or let a removed item finish its exit while siblings reflow. Stable identity connects application state to measured layout and retained exits.',
    ],
    blocks: [
      DocLink('Layout and shared identity', '/docs/motion/layout-animations'),
      DocLink('Coordinate reflow and exits', '/docs/motion/layout-presence'),
    ],
  ),
  DocSection(
    id: 'scroll-and-orchestration',
    heading: 'Scroll and orchestration',
    paragraphs: [
      'Map scroll progress to paint, reveal content as it enters a viewport, or coordinate several controllers on one timeline. Use route transitions when the movement belongs to navigation.',
    ],
    blocks: [
      DocLink('Scroll-linked values', '/docs/motion/scroll-motion'),
      DocLink('Seek a timeline', '/docs/motion/timeline'),
      DocLink('Animate navigation', '/docs/motion/routes'),
    ],
  ),
  DocSection(
    id: 'visual-effects',
    heading: 'Visual effects and expressive interfaces',
    paragraphs: [
      'Animate text units, follow a path, reveal a surface, or add glass and decorative water. These effects compose with ordinary Flutter widgets; GPU paths have explicit renderer limits.',
    ],
    blocks: [
      DocLink('Text and typewriter', '/docs/motion/text-motion'),
      DocLink('Paths and stroke drawing', '/docs/motion/path-motion'),
      DocLink('Shaders and glass', '/docs/motion/shaders'),
      DocLink('Water surfaces', '/docs/motion/water'),
    ],
  ),
  DocSection(
    id: 'tools-and-accessibility',
    heading: 'Developer tooling, performance and accessibility',
    paragraphs: [
      'Tune a spring, inspect running values, and replay entrances during development. Profile the actual screen and provide the same useful outcome when reduced motion skips the travel.',
    ],
    blocks: [
      DocLink('Debug and tune springs', '/docs/motion/debugging'),
      DocLink('Measure performance', '/docs/motion/performance'),
      DocLink('Design for reduced motion', '/docs/motion/accessibility'),
    ],
  ),
];
