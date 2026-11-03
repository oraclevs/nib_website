import '../../content/site_content.dart';
import '../component_model.dart';
import '../component_settings.dart';

const glassComponentGuide = ComponentGuide(
  id: 'liquid-glass',
  title: 'Liquid glass',
  category: 'Effects',
  summary: 'Explore clear and depth water, merging drops and shared bubbles over a live Flutter subtree.',
  symbols: [
    'NibWaterGlass',
    'NibWaterSurface',
    'NibWaterController',
    'NibWaterConfig',
    'NibWaterDrop',
    'NibWaterImpulse',
    'NibWaterInteraction',
    'NibWaterPhase',
    'NibWaterRenderPath',
    'NibWaterRenderStatus',
    'NibWaterSampling',
    'NibWaterQuality',
    'NibWaterMaterial',
    'NibBubbleEmitter',
    'NibLiquidGlass',
    'glassLightFromPointer',
    'NibGlass',
  ],
  source: 'nib_components/lib/src/liquid_glass/nib_water_glass.dart; nib_motion/lib/src/water/nib_water_controller.dart; nib_motion/lib/src/water/nib_water_surface.dart',
  demoClass: 'GlassComponentDemo',
  demoFile: 'lib/components/examples/glass_component_demo.dart',
  previewHeight: 690,
  initial: ComponentSettings(
    waterMaterial: 'water',
    variant: 'rounded',
    radius: 24,
    text: 'Keep the backdrop visible.',
  ),
  controls: [
    ComponentControl(
      'waterMaterial',
      'Material',
      ComponentControlKind.choice,
      choices: ['water', 'legacy'],
      help: 'Water Lab is the new review target. Legacy keeps the existing glass available.',
    ),
    ComponentControl(
      'waterScene',
      'Scene',
      ComponentControlKind.choice,
      choices: ['droplets', 'surface', 'component', 'bubbles'],
      visibleWhenKey: 'waterMaterial',
      visibleWhenValue: 'water',
      help: 'All scenes use NibWaterSurface. Bubbles uses one bounded emitter and one shared sample.',
    ),
    ComponentControl(
      'waterInteraction',
      'Pointer mode',
      ComponentControlKind.choice,
      choices: ['drag', 'disturb'],
      visibleWhenKey: 'waterMaterial',
      visibleWhenValue: 'water',
      visibleWhen: {'waterScene': 'droplets'},
      help: 'Drag moves a drop. Disturb adds waves and a movement wake.',
    ),
    ComponentControl(
      'waterBackdrop',
      'Background',
      ComponentControlKind.choice,
      choices: ['grid', 'typography', 'image', 'scrolling'],
      visibleWhenKey: 'waterMaterial',
      visibleWhenValue: 'water',
      help: 'Neutral grid and text reveal refraction. Image is original local vector art; scrolling has a Move background button.',
    ),
    ComponentControl(
      'waterImpulse',
      'Disturbance strength · px',
      ComponentControlKind.number,
      minimum: 0,
      maximum: 12,
      visibleWhenKey: 'waterMaterial',
      visibleWhenValue: 'water',
      help: 'Artistic height amplitude, not physical pressure.',
    ),
    ComponentControl(
      'waterWaveSpeed',
      'Wave speed · px/s',
      ComponentControlKind.number,
      minimum: 40,
      maximum: 400,
      visibleWhenKey: 'waterMaterial',
      visibleWhenValue: 'water',
      help: 'How quickly a disturbance propagates in receiver-local pixels.',
    ),
    ComponentControl(
      'waterDamping',
      'Damping · /s',
      ComponentControlKind.number,
      minimum: .3,
      maximum: 8,
      visibleWhenKey: 'waterMaterial',
      visibleWhenValue: 'water',
      help: 'Higher damping removes waves sooner.',
    ),
    ComponentControl(
      'waterRefraction',
      'Optical strength',
      ComponentControlKind.number,
      minimum: 0,
      maximum: 40,
      visibleWhenKey: 'waterMaterial',
      visibleWhenValue: 'water',
      help: 'Artistic background displacement. Zero removes refraction; this is not a physical refractive index.',
    ),
    ComponentControl(
      'waterHighlight',
      'Surface highlight',
      ComponentControlKind.number,
      minimum: 0,
      maximum: 1,
      visibleWhenKey: 'waterMaterial',
      visibleWhenValue: 'water',
      help: 'Light intensity follows the evolving surface normal.',
    ),
    ComponentControl(
      'waterWavelength',
      'Wavelength · px',
      ComponentControlKind.number,
      minimum: 16,
      maximum: 120,
      advanced: true,
      visibleWhenKey: 'waterMaterial',
      visibleWhenValue: 'water',
      help: 'Distance between wave crests in local logical pixels.',
    ),
    ComponentControl(
      'waterRecovery',
      'Shape recovery · /s',
      ComponentControlKind.number,
      minimum: 2,
      maximum: 30,
      advanced: true,
      visibleWhenKey: 'waterMaterial',
      visibleWhenValue: 'water',
      help: 'Controls how quickly the drop arrangement approaches merge or split targets.',
    ),
    ComponentControl(
      'waterSampling',
      'Sampling policy',
      ComponentControlKind.choice,
      choices: ['live', 'static', 'throttled', 'legacy'],
      visibleWhenKey: 'waterMaterial',
      visibleWhenValue: 'water',
      help: 'Live samples child layers during composition. Static requires explicit invalidation; throttled permits older input. Legacy preserves the old asynchronous path.',
    ),
    ComponentControl(
      'waterOptics',
      'Water optics',
      ComponentControlKind.choice,
      choices: ['clear', 'depth'],
      visibleWhenKey: 'waterMaterial',
      visibleWhenValue: 'water',
      help: 'Clear adds no deliberate blur. Depth adds bounded artistic absorption; it is not volumetric fluid simulation.',
    ),
    ComponentControl(
      'waterQuality',
      'Quality · multiple of DPR',
      ComponentControlKind.number,
      minimum: 0.25,
      maximum: 2,
      advanced: true,
      visibleWhenKey: 'waterMaterial',
      visibleWhenValue: 'water',
      help: 'Device-relative requested scale; bounded to four million pixels, 16 MB input and 4096 pixels per axis. Effective size is shown in Development details.',
    ),
    ComponentControl(
      'waterBlur',
      'Intentional blur · logical px',
      ComponentControlKind.number,
      minimum: 0,
      maximum: 8,
      advanced: true,
      visibleWhenKey: 'waterMaterial',
      visibleWhenValue: 'water',
      help: 'Opt-in source blur, independent of resolution and wave speed. Zero preserves clear content.',
    ),
    ComponentControl(
      'waterCaptureScale',
      'Legacy sampling · pixels/logical px',
      ComponentControlKind.number,
      minimum: .5,
      maximum: 2,
      advanced: true,
      visibleWhenKey: 'waterMaterial',
      visibleWhenValue: 'water',
      help: 'Only the legacy sampling policy uses this absolute scale; its two-million-pixel cap is unchanged.',
    ),
    ComponentControl(
      'backdrop',
      'Backdrop',
      ComponentControlKind.choice,
      visibleWhenKey: 'waterMaterial',
      visibleWhenValue: 'legacy',
      choices: ['grid', 'content'],
      help: 'Changes the local scene behind the glass; the website stays dark.',
    ),
    ComponentControl(
      'variant',
      'Shape',
      ComponentControlKind.choice,
      visibleWhenKey: 'waterMaterial',
      visibleWhenValue: 'legacy',
      choices: ['rounded', 'capsule'],
      help: 'Both shapes use the real borderRadius property.',
    ),
    ComponentControl(
      'text',
      'Note text',
      ComponentControlKind.text,
      visibleWhenKey: 'waterMaterial',
      visibleWhenValue: 'legacy',
      help: 'Foreground content stays independent of the glass filter.',
    ),
    ComponentControl(
      'animated',
      'Animated press',
      ComponentControlKind.toggle,
      visibleWhenKey: 'waterMaterial',
      visibleWhenValue: 'legacy',
      help: 'Enabled in this demo. Uses NibMotion and a 0.98 press scale.',
    ),
    ComponentControl(
      'interactive',
      'Pointer response',
      ComponentControlKind.toggle,
      visibleWhenKey: 'waterMaterial',
      visibleWhenValue: 'legacy',
      help: 'Controls decorative light tracking and press response, not the child button.',
    ),
    ComponentControl(
      'blurSigma',
      'Backdrop blur',
      ComponentControlKind.number,
      visibleWhenKey: 'waterMaterial',
      visibleWhenValue: 'legacy',
      minimum: 0,
      maximum: 20,
      help: 'Gaussian blur on both renderer paths.',
    ),
    ComponentControl(
      'highlight',
      'Rim highlight',
      ComponentControlKind.number,
      visibleWhenKey: 'waterMaterial',
      visibleWhenValue: 'legacy',
      minimum: 0,
      maximum: 1,
      help: 'Lighting intensity. The extra border is controlled separately.',
    ),
    ComponentControl(
      'showBorder',
      'Extra border',
      ComponentControlKind.toggle,
      visibleWhenKey: 'waterMaterial',
      visibleWhenValue: 'legacy',
      help: 'Adds the component outline; the engine rim can remain visible when this is off.',
    ),
    ComponentControl(
      'thickness',
      'Dome thickness',
      ComponentControlKind.number,
      visibleWhenKey: 'waterMaterial',
      visibleWhenValue: 'legacy',
      minimum: 1,
      maximum: 48,
      advanced: true,
      help:
          'Shader path only; logical pixels. This does not change layout size.',
    ),
    ComponentControl(
      'refractiveIndex',
      'Refraction index',
      ComponentControlKind.number,
      visibleWhenKey: 'waterMaterial',
      visibleWhenValue: 'legacy',
      minimum: 1,
      maximum: 1.8,
      advanced: true,
      help: 'Shader path only. 1.0 requests no bending.',
    ),
    ComponentControl(
      'chromaticAberration',
      'Color dispersion',
      ComponentControlKind.number,
      visibleWhenKey: 'waterMaterial',
      visibleWhenValue: 'legacy',
      minimum: 0,
      maximum: .15,
      advanced: true,
      help: 'Shader path only. Zero disables the extra red/blue sampling.',
    ),
    ComponentControl(
      'saturation',
      'Backdrop saturation',
      ComponentControlKind.number,
      visibleWhenKey: 'waterMaterial',
      visibleWhenValue: 'legacy',
      minimum: 0,
      maximum: 2,
      advanced: true,
      help: 'Shader path only. 1.0 leaves backdrop saturation unchanged.',
    ),
  ],
  limitations: [
    'Water Lab uses the stable public water API. The refractive path must be checked in a real browser; fallback rendering does not satisfy visual review.',
    'The model preserves source-region area as a 2D mass proxy. It does not conserve exact silhouette area or solve 3D fluid flow.',
    'Capture is restricted to the designated bounded background. Platform views and content outside that subtree are not supported background inputs.',
    'Android GPU, physical touch and screen-reader validation remain separate checks after maintainer web review.',
  ],
  minimalCode: _minimalWaterCode,
  sections: [
    DocSection(
      id: 'purpose',
      heading: 'Meet the Water Lab',
      paragraphs: [
        'Start with two drops over a neutral grid. Drag one toward the other, or use Merge drops. A connecting neck grows as the bodies approach. Once they join, their body identity remains joined after release. Make a wave disturbs the material; Split moves the regions apart again. Reset water restores the initial arrangement immediately.',
        'The Droplets, Surface and Component scenes use NibWaterGlass from nib_components. It wraps NibWaterSurface from nib_motion. The engine receives an explicit background subtree, samples that subtree into an image, and uses a fragment shader to bend the sampled pixels. Foreground controls remain above the distortion.',
        'This example uses the public water API available since nib_motion 0.3.5 and nib_components 0.2.3. It is a two-dimensional, physically informed visual model. It does not solve three-dimensional fluid flow or measure physical water volume. The legacy glass implementation remains available in the Material selector while the new direction is reviewed.',
      ],
    ),
    DocSection(
      id: 'setup',
      heading: 'Build a small water surface',
      paragraphs: [
        'Import nib_components for NibWaterGlass and nib_motion for its controller, configuration and drop values. Declare both dependencies when you import both packages. The new APIs are in the local working candidate; version labels alone do not establish hosted availability. Use the candidate source and dependency instructions from the Water Lab report until publication is separately approved.',
        'Give the scene a finite size. Coordinates and radii belong to that local box, in logical pixels. Create the controller once, pass it to one material surface, then dispose it when its owner leaves. The widget drives controller.advance through its ticker; do not drive the same controller from another ticker as well.',
        'The small program below runs on its own. The full Copy example action includes the exact Water Lab implementation, selected settings, local artwork and theme. It copies the starting configuration, not the current wave frame or an arbitrary dragged position.',
      ],
      code: _minimalWaterCode,
    ),
    DocSection(
      id: 'model',
      heading: 'Understand what moves',
      paragraphs: [
        'The material contour is an implicit field built from participating drop regions. Nearby fields form a smooth connecting neck. The controller also records body membership, so visual contact has a lasting state rather than a brief bridge painted between two unrelated circles.',
        'Disturbances are bounded radial impulses. Their fronts travel outward at waveSpeed; wavelength sets crest spacing and damping removes amplitude over elapsed seconds. Multiple impulses add together. The shader evaluates the resulting surface and uses its normal for refraction and light. A wave changes the background displacement instead of adding an unrelated ring on top.',
        'Each source region contributes exp(-ln(2) × distance² / radius²), and the visible contour is the 0.5 level. Automatic coalescence requires a connecting neck above 0.52. The controller retains joined body identity after release. A deliberate split keeps automatic rejoining off until another drag begins or merge() is called.',
        'The conserved proxy is the sum of pi × radius² for source regions. It describes two-dimensional source mass. The visible contour can change area during a merge, and the model does not claim exact silhouette-area or three-dimensional volume conservation. Body membership and the proxy can be inspected in Development details.',
      ],
    ),
    DocSection(
      id: 'merging',
      heading: 'Merge without losing the source regions',
      paragraphs: [
        'NibWaterDrop has a stable integer id, a local center and radius, and an optional bodyId. Source regions remain identifiable after joining. They are material-editing handles, not application buttons whose meaning can be combined. A merged material must not imply that two independent application actions have merged.',
        'merge() starts a controlled approach toward a joined arrangement. The phase progresses from separated through merging to merged. split() starts continuous separation and then returns to separated. Split is the deliberate way to break a merged body; releasing a pointer does not automatically split it. reset() instead restores the controller’s original drops.',
        'Try Merge drops, then Split before the approach finishes. The next operation starts from the current arrangement. On a reduced-motion system the resulting state is available without the spatial transition. The preview’s buttons provide the same outcomes for keyboard users who cannot drag.',
      ],
      api: [
        DocApiEntry(
          name: 'merge / split / reset',
          type: 'void Function()',
          defaultValue: 'explicit calls',
          description: 'Request joining, continuous separation, or immediate restoration of the initial arrangement.',
        ),
        DocApiEntry(
          name: 'phase',
          type: 'NibWaterPhase',
          defaultValue: 'separated',
          description: 'Read-only topology state: separated, merging, merged or splitting.',
        ),
        DocApiEntry(
          name: 'massProxy',
          type: 'double',
          defaultValue: 'sum of source pi × radius²',
          description: 'Two-dimensional source-area proxy in px²; not exact rendered contour area or fluid volume.',
        ),
      ],
    ),
    DocSection(
      id: 'interactions',
      heading: 'Choose what the pointer should do',
      paragraphs: [
        'In Drag mode, a pointer takes ownership of a source region and moves the body. In Disturb mode, a tap injects an impulse and movement leaves a wake. These are separate modes so a gesture does not both displace a drop and scratch waves across it. Surface and Component scenes use Disturb; the pointer-mode inspector appears only for Droplets.',
        'The public NibWaterSurface handles local pointer conversion, pointer-up and cancellation. For a custom interaction host, call beginDrag(pointer, localPosition), inspect its boolean result, then call dragTo for the same pointer id. Finish with endDrag; pass cancelled: true when the input is cancelled. cancelInputs releases all current ownership.',
        'A body has one pointer owner at a time. Two separately owned bodies wait until a pointer is released before joining. A normal release preserves the current velocity and target. Cancellation freezes the owned body at its current centers and clears its velocity; it keeps any existing joined identity.',
        'Use disturb(localPosition, strength: value) for an explicit impulse. Strength is an artistic height amplitude in logical pixels, not pressure from hardware. The example’s Make a wave button uses the center of the local scene. Ordinary mouse and touch coordinates are sufficient; this example does not use pressure.',
      ],
      api: [
        DocApiEntry(
          name: 'interaction',
          type: 'NibWaterInteraction',
          defaultValue: 'disturb',
          description:
              'disturb adds impulses; drag moves participating source regions.',
        ),
        DocApiEntry(
          name: 'disturb',
          type: 'void Function(Offset, {double? strength})',
          defaultValue: 'config.impulseStrength',
          description: 'Adds a bounded local disturbance. Coordinates use the receiving surface’s logical pixels.',
        ),
        DocApiEntry(
          name: 'beginDrag / dragTo / endDrag',
          type: 'pointer id + local Offset',
          defaultValue: 'no input ownership',
          description: 'Explicit pointer ownership for a custom host. A pointer may update only its own acquired input.',
        ),
      ],
    ),
    DocSection(
      id: 'parameters',
      heading: 'Tune one property at a time',
      paragraphs: [
        'NibWaterConfig controls the solver and legacy optics. NibWaterMaterial separates clear/depth optics and opt-in blur; NibWaterQuality controls device-relative input resolution. configure(nextConfig) changes parameters while retaining the current drops and active material state. An external controller owns its configuration; the NibWaterGlass config argument initializes only a widget-owned controller. This example configures its external controller when inspector settings change.',
        'Begin with waveSpeed and damping. Higher speed moves fronts farther each second; higher damping removes waves sooner. Adjust wavelength for tighter or broader ripples. recovery changes how quickly shape targets are approached. These rates do not replace simulation time with an easing curve.',
        'Configuration values are checked when a controller accepts them, including in release builds. The full API ranges are speed 0–1000 px/s, damping 0.25–12 /s, strength 0–24 px, wavelength 8–256 px, recovery 1–30 /s, refraction 0–48 and highlight 0–2. The inspector deliberately offers narrower ranges. Non-finite values and values outside the public bounds throw ArgumentError.',
        'Use refraction and highlight last. Refraction is an artistic optical displacement strength; it is not the legacy refractiveIndex property. Highlight is light intensity. Neither is a substitute for meaningful geometry. Use the neutral grid and typography backgrounds to see whether the underlying pixels are actually displaced.',
      ],
      api: [
        DocApiEntry(
          name: 'waveSpeed',
          type: 'double · px/s',
          defaultValue: '180',
          description: 'Radial propagation speed; the inspector offers 40–400.',
        ),
        DocApiEntry(
          name: 'damping',
          type: 'double · /s',
          defaultValue: '2.4',
          description: 'Wave amplitude decay rate; the inspector offers 0.3–8.',
        ),
        DocApiEntry(
          name: 'impulseStrength',
          type: 'double · artistic px',
          defaultValue: '5',
          description:
              'Default wave-height amplitude; the inspector offers 0–12.',
        ),
        DocApiEntry(
          name: 'wavelength',
          type: 'double · px',
          defaultValue: '46',
          description: 'Crest spacing; the inspector offers 16–120.',
        ),
        DocApiEntry(
          name: 'recovery',
          type: 'double · /s',
          defaultValue: '14',
          description: 'Shape-target recovery rate; the inspector offers 2–30.',
        ),
        DocApiEntry(
          name: 'refraction',
          type: 'double · artistic strength',
          defaultValue: '16',
          description: 'Optical displacement strength; the inspector offers 0–40. Zero removes refraction.',
        ),
        DocApiEntry(
          name: 'highlight',
          type: 'double',
          defaultValue: '0.6',
          description: 'Surface light intensity; the inspector offers 0–1.',
        ),
      ],
    ),
    DocSection(
      id: 'background',
      heading: 'Provide the pixels behind the water',
      paragraphs: [
        'background is an explicit Flutter subtree. NibWaterSurface places it in a separate capture boundary. Water is excluded from that boundary, preventing the next frame from sampling the previous water effect. The background remains part of normal Flutter layout; no screen recording, WebView or website-only renderer is involved.',
        'The lab selects live sampling: child layers are sampled during scene composition, including nested repaint boundaries. Static sampling caches input until backgroundChanges or a size/quality change. Throttled sampling caps input refresh at the configured interval (33 ms by default) while waves can keep moving. Legacy preserves the asynchronous snapshot path and may require explicit invalidation for independently composited changes.',
        'The caller owns backgroundChanges. Retain the signal while the material uses it, and dispose an owned controller or notifier in its owner. The water widget subscribes and unsubscribes but does not dispose your signal. Do not assume that every independently composited animation is detected without this connection.',
        'The Grid and Typography choices are deliberately neutral. The Image choice is original local vector artwork painted in the copied Dart source, with no remote service or licensing dependency. Scrolling contains real local content; Move background changes its scroll offset by 100 logical pixels, making capture updates easy to inspect.',
        'Sampling is bounded to the designated scene. It is not a way to refract arbitrary content elsewhere in an application. A blank, uniform background gives the shader little detail to bend. Avoid adding strong tint or blur to conceal missing refraction; first read the active renderer path and test a grid.',
      ],
      api: [
        DocApiEntry(
          name: 'background',
          type: 'Widget',
          defaultValue: 'required',
          description: 'Designated content sampled below the material. Must have finite constraints.',
        ),
        DocApiEntry(
          name: 'backgroundChanges',
          type: 'Listenable?',
          defaultValue: 'null',
          description: 'Caller-owned invalidation signal for independently composited background changes. Ordinary repaint and descendant scrolling are detected automatically. The widget manages its listener, not ownership of the signal.',
        ),
        DocApiEntry(
          name: 'child',
          type: 'Widget?',
          defaultValue: 'null',
          description: 'Sharp foreground above the water. Controls may also live in background; bounded distortion retains their original hit-test and semantic geometry.',
        ),
        DocApiEntry(
          name: 'surface',
          type: 'bool',
          defaultValue: 'false',
          description: 'False renders participating droplets. True fills the bounded scene with the same surface and optics.',
        ),
      ],
    ),
    DocSection(
      id: 'component',
      heading: 'Put a real action above the material',
      paragraphs: [
        'The Component scene uses the same water renderer with surface: true. A NibButton saves a local note in the foreground. Its text, focus and pressed feedback remain separate from the sampled backdrop. This is an application composition, not a new payment service or an interaction inferred from the shape of a droplet.',
        'Use child for sharp foreground content, and keep its contrast stable as the background changes. The preview uses a mostly opaque themed card behind the note so its readability does not depend on the lens. The water around it remains interactive.',
        'NibWaterGlass can create and own a controller when none is passed. Use an external NibWaterController for deliberate merging, splitting, custom initial drops or diagnostic access. The external owner must dispose that controller; the material does not take ownership of it.',
      ],
    ),
    DocSection(
      id: 'state-lifecycle',
      heading: 'Own the controller and respect the clock',
      paragraphs: [
        'Create an external controller in State, retain it through ordinary rebuilds, and dispose it in State.dispose. Switching between drop/surface/component scenes retains state. Entering or leaving the emitter scene creates a fresh controller with explicit ownership. Config changes retain body membership. Emission can stop while existing bubbles finish; reduced motion freezes their current poses.',
        'The renderer uses its ticker and controller activity to advance the model. It honors TickerMode, application lifecycle, its paused argument and the system reduced-motion preference. Resume handling bounds elapsed work instead of integrating an entire period spent in the background.',
        'The controller accepts zero to ten source regions, with unique ids and radii from 8 to 256 logical pixels. It keeps at most twelve live impulses, replacing the oldest when the limit is reached. A wave expires below 0.01 amplitude or after eight active simulation seconds. An advance accepts at most 66ms and divides it into steps of at most 1/120 second; excess wall time is discarded.',
        'The simulation controller accepts elapsed seconds through advance. Use that method directly for deterministic tests or a custom scheduler. Do not call it every frame from a second owner while a NibWaterSurface is already driving it. Simulation time and widget rebuilds are separate: the preview observes discrete phase changes instead of rebuilding the page for every wave.',
      ],
      api: [
        DocApiEntry(
          name: 'animated',
          type: 'bool',
          defaultValue: 'false',
          description: 'NibWaterGlass enables evolving body and wave motion only when true. The Water Lab and runnable water example set true. NibWaterSurface itself has no animated property.',
        ),
        DocApiEntry(
          name: 'captureScale',
          type: 'double',
          defaultValue: '1',
          description: 'Legacy policy only: 0.5–2 absolute pixels per logical pixel, capped at two million pixels. Candidate quality is separately device-relative.',
        ),
        DocApiEntry(
          name: 'paused',
          type: 'bool',
          defaultValue: 'false',
          description: 'Pauses the renderer’s simulation work; outer TickerMode and app lifecycle also apply.',
        ),
        DocApiEntry(
          name: 'reducedMotion',
          type: 'bool',
          defaultValue: 'false',
          description: 'Requests less spatial motion. The system preference takes priority.',
        ),
        DocApiEntry(
          name: 'configure',
          type: 'void Function(NibWaterConfig)',
          defaultValue: 'constructor config',
          description:
              'Updates the controller configuration without recreating it.',
        ),
        DocApiEntry(
          name: 'dispose',
          type: 'void Function()',
          defaultValue: 'called by owner',
          description:
              'Release an external controller when its owning scene leaves.',
        ),
      ],
    ),
    DocSection(
      id: 'fallback',
      heading: 'Read the actual rendering path',
      paragraphs: [
        'Development details shows loading, refractive or fallback from NibWaterRenderStatus. A refractive status reports that the shader and sampled background were bound for this material. It does not certify physical-device rendering, GPU speed, or every browser backend.',
        'The fallback keeps the content usable when the shader or capture path is unavailable. It is not equivalent to the refraction effect and does not pass the Water Lab’s visual review gate. Use the legacy Material choice for a separate comparison; do not label an unchanged legacy effect as the new water renderer.',
        'Capture count and last capture duration describe background sampling. Last solver-step duration describes CPU simulation work. These numbers are not frame time, raster time or display frame rate. Browser/backend evidence and controlled measurements belong in the Water Lab implementation report.',
      ],
      api: [
        DocApiEntry(
          name: 'onStatus',
          type: 'ValueChanged<NibWaterRenderStatus>?',
          defaultValue: 'null',
          description: 'Reports path, captureCount, lastCaptureMicros and a diagnostic message.',
        ),
        DocApiEntry(
          name: 'NibWaterRenderPath',
          type: 'enum',
          defaultValue: 'loading',
          description: 'loading, refractive or fallback. A successful binding is not a GPU performance guarantee.',
        ),
      ],
    ),
    DocSection(
      id: 'accessibility',
      heading: 'Keep the result available without dragging',
      paragraphs: [
        'Merge drops, Split, Make a wave and Reset water are real keyboard-focusable buttons. A person can reach the resulting state without a drag gesture. The decorative backdrop is not a second application control. Component-scene controls keep their ordinary semantics and focus even while the material shape changes.',
        'Less motion requests a static or reduced-spatial result; the system preference always wins. Pause water freezes the simulation separately. Reset water restores initial material state and leaves pause and reduced-motion choices alone. The outer playground’s Pause and Reduce motion controls apply too.',
        'Do not announce every solver frame. The example displays discrete phase changes as text and keeps capture/solver diagnostics inside a collapsible panel. Check focus order, contrast, text scaling and cancellation separately from physical touch and screen-reader testing.',
      ],
    ),
    DocSection(
      id: 'migration',
      heading: 'Keep the legacy path during review',
      paragraphs: [
        'NibWaterGlass is added alongside NibLiquidGlass. Existing NibLiquidGlass consumers and the Liquid Glass route remain valid. Choose Material: legacy to inspect the original blur, rim, rounded/capsule shape and pointer lighting. Its optics use different properties and a different renderer path.',
        'Do not mechanically map refractiveIndex, blurSigma or chromaticAberration onto NibWaterConfig. The new material samples an explicit local background and derives optics from its moving surface. Migrate a bounded scene, verify its pixels and interactions, then compare the result before changing production use.',
        'Web review comes before Android validation. Native GPU appearance, physical touch and assistive-technology results must be recorded independently. Stable API status does not replace renderer, device or accessibility verification for the application using it.',
      ],
    ),
    DocSection(
      id: 'legacy-purpose',
      heading: 'Legacy glass: Start with a backdrop worth seeing',
      paragraphs: [
        'NibLiquidGlass is a container, not a button or a complete screen. Place it above content in a Stack. Its filter samples what has already been painted behind it; its child is painted afterward and stays sharp. A flat background hides most of the effect, so this example provides a grid and a small local notes scene.',
        'Use it for a bounded floating control or a short information panel. Prefer an opaque NibCard when long-form text, contrast or a predictable fill matters more than seeing through the surface. Keep foreground text readable in both the shader and fallback paths.',
        'NibLiquidGlass belongs to nib_components. It wraps NibGlass from nib_motion with pointer-driven lighting, optional press animation and content padding. These are two layers of the same effect, not two separate visual components in this catalog.',
      ],
    ),
    DocSection(
      id: 'legacy-setup',
      heading: 'Legacy glass: Set up a bounded surface',
      paragraphs: [
        'Import package:nib_components/nib_components.dart for NibLiquidGlass and glassLightFromPointer. Import package:nib_motion/nib_motion.dart when you use NibGlass diagnostics or provide a NibTransition yourself. If your app imports nib_motion directly, declare it as a direct dependency as well.',
        'This site runs the local nib_components 0.2.2 candidate with the local nib_motion 0.3.4 candidate. These version labels do not establish that the same candidate is published. The complete exported example includes its tested theme and configuration; resolve the package sources described by the export instructions.',
        'Give the surface finite constraints. The example below fixes its scene and glass dimensions; in a responsive layout, cap the glass width from LayoutBuilder constraints. The shader asset is provided by nib_motion at packages/nib_motion/lib/shaders/liquid_glass.frag. A missing or unsupported shader uses the fallback.',
      ],
      code: _minimalGlassCode,
      note: 'The default is animated: false. The minimal example keeps that default.',
    ),
    DocSection(
      id: 'legacy-interactions',
      heading: 'Legacy glass: Separate pointer lighting from animation',
      paragraphs: [
        'With interactive: true, mouse hover and pointer movement aim the light toward the local pointer position. Pointer down sets the pressed state. Pointer up, cancellation and mouse exit reset the light and pressed state. Setting interactive: false clears an outstanding decorative press, restores the rest light and removes those pointer handlers; it does not disable a button or input inside child.',
        'animated: true wraps the surface in NibMotion and changes its scale between 1.0 and 0.98 while pressed. Without that opt-in, there is no NibMotion wrapper and no press scale. Hover lighting still updates. transition is used only for this optional press animation; its default is a 140ms NibTransition.',
        'Try holding the empty part of the glass, then releasing or cancelling the pointer. The event readout records actual pointer events observed by the example host. NibLiquidGlass itself exposes no onTap, onHover or onPressed callback. Pin note is a separate NibButton with its own real onPressed callback and local pinned state.',
      ],
      api: [
        DocApiEntry(
          name: 'interactive',
          type: 'bool',
          defaultValue: 'true',
          description: 'Enables pointer lighting and press-state tracking. Child interactions are independent.',
        ),
        DocApiEntry(
          name: 'animated',
          type: 'bool',
          defaultValue: 'false',
          description: 'Adds NibMotion for scale feedback; false builds no NibMotion wrapper.',
        ),
        DocApiEntry(
          name: 'transition',
          type: 'NibTransition?',
          defaultValue: 'null',
          description: 'Optional press animation configuration. Null selects a 140ms transition when animated is true.',
        ),
        DocApiEntry(
          name: 'restLightDirection',
          type: 'Offset',
          defaultValue: 'Offset(-0.4, -1)',
          description: 'Direction restored on pointer release, cancellation or exit. It points toward the light.',
        ),
      ],
    ),
    DocSection(
      id: 'surface',
      heading: 'Legacy glass: Tune the surface before the optics',
      paragraphs: [
        'blurSigma is the Gaussian blur amount, not opacity. Start near the default 1 and increase it to make the backdrop less legible. tint is an optional Color painted over the backdrop; its alpha controls the wash. The component defaults to a subtle white tint based on Theme brightness: 0x0AFFFFFF in dark mode and 0x0DFFFFFF in light mode.',
        'highlight sets rim-light intensity. showBorder adds a separate one-pixel white outline around the component content. Turning showBorder off does not turn highlight off and does not remove the engine’s painted rim. Compare those two controls separately.',
        'The demo uses inherited NibTheme colors for the backdrop, foreground and button. The native glass tint and default 24px corner radius are not replaced by NibTheme.primary or radiusDefault. Pass tint or borderRadius explicitly when those defaults do not suit your app.',
      ],
      api: [
        DocApiEntry(
          name: 'blurSigma',
          type: 'double',
          defaultValue: '1',
          description: 'Backdrop blur on the shader and fallback paths. Use finite non-negative values.',
        ),
        DocApiEntry(
          name: 'tint',
          type: 'Color?',
          defaultValue: 'null',
          description: 'Null chooses the brightness-dependent white sheen; a supplied color is used directly.',
        ),
        DocApiEntry(
          name: 'highlight',
          type: 'double',
          defaultValue: '0.5',
          description: 'Rim-light intensity. The documented range is 0..1.',
        ),
        DocApiEntry(
          name: 'showBorder',
          type: 'bool',
          defaultValue: 'true',
          description: 'Adds a separate outline; it does not disable the underlying rim light.',
        ),
      ],
    ),
    DocSection(
      id: 'optics',
      heading: 'Legacy glass: Know which controls need the shader',
      paragraphs: [
        'thickness, refractiveIndex, chromaticAberration and saturation are forwarded to the NibGlass shader. They are not implemented by the frosted fallback. The inspector keeps them available as advanced settings so the same exported configuration can be tried on a supported device; changing them in a fallback preview should not be described as a visual success.',
        'thickness controls the edge band of the shader’s dome model in logical pixels. It does not add padding, change the widget’s layout thickness or make the whole surface uniformly distorted. refractiveIndex: 1.0 requests no bending. chromaticAberration: 0 disables the additional dispersion sampling. saturation: 1.0 preserves the sampled color saturation.',
        'These are visual shader parameters, not a measurement of real material optics. The example bounds controls to useful finite ranges; the component constructor does not enforce those ranges with assertions. Do not pass NaN or infinite values.',
      ],
      api: [
        DocApiEntry(
          name: 'thickness',
          type: 'double',
          defaultValue: '24',
          description: 'Logical-pixel dome edge band. Shader only; NibGlass itself defaults to 20.',
        ),
        DocApiEntry(
          name: 'refractiveIndex',
          type: 'double',
          defaultValue: '1.2',
          description: 'Shader refraction parameter; 1.0 means no bending.',
        ),
        DocApiEntry(
          name: 'chromaticAberration',
          type: 'double',
          defaultValue: '0.03',
          description: 'Shader red/blue dispersion amount; zero disables the extra sampling.',
        ),
        DocApiEntry(
          name: 'saturation',
          type: 'double',
          defaultValue: '1.3',
          description:
              'Shader backdrop saturation factor; 1.0 leaves it unchanged.',
        ),
      ],
    ),
    DocSection(
      id: 'shape',
      heading: 'Legacy glass: Control size, padding and clipping',
      paragraphs: [
        'child is required. width and height are optional outer dimensions, and padding defaults to EdgeInsets.all(20) around the child. A custom clipper overrides borderRadius for clipping. Otherwise the default radius is 24px; keep radii uniform when testing the shader, whose radius uniform currently reads the top-left corner.',
        'The Rounded and Capsule options in this example both use borderRadius. Capsule uses a radius equal to half the 188px glass height. Text and controls still need room inside the curved edges, so the example increases horizontal padding for that shape.',
        'CustomClipper<Path> supports an arbitrary clipped outline, but the current shader does not accept the path as its refraction geometry. Its model remains a rounded rectangle. Test custom shapes in the intended renderer instead of assuming their lensing matches the clip. A custom clipper also removes the component’s rounded border radius from its extra outline.',
      ],
      api: [
        DocApiEntry(
          name: 'child',
          type: 'Widget',
          defaultValue: 'required',
          description:
              'Foreground content painted above the filtered backdrop.',
        ),
        DocApiEntry(
          name: 'width / height',
          type: 'double?',
          defaultValue: 'null / null',
          description: 'Optional dimensions. Finite parent constraints are needed for the shader path.',
        ),
        DocApiEntry(
          name: 'padding',
          type: 'EdgeInsetsGeometry',
          defaultValue: 'EdgeInsets.all(20)',
          description: 'Inset around the child. Supports directional padding.',
        ),
        DocApiEntry(
          name: 'borderRadius',
          type: 'BorderRadius?',
          defaultValue: 'null → 24px',
          description:
              'Rounded clipping and outline shape when clipper is absent.',
        ),
        DocApiEntry(
          name: 'clipper',
          type: 'CustomClipper<Path>?',
          defaultValue: 'null',
          description: 'Overrides clipping shape. Does not provide arbitrary-path refraction geometry to the current shader.',
        ),
      ],
    ),
    DocSection(
      id: 'light-helper',
      heading: 'Legacy glass: Compute a light direction explicitly',
      paragraphs: [
        'glassLightFromPointer(Offset pointer, Size size) returns a unit Offset from the center of size toward a pointer in that box’s local coordinates. Pass localPosition, not a global screen position. It returns Offset(0, -1) for an empty or non-finite size, a centered pointer or a non-finite vector.',
        'NibLiquidGlass already calls this helper for native pointer tracking. Use the helper yourself when building a custom composition directly with NibGlass. It is a pure function: there is no controller, subscription or disposal step.',
      ],
      code: '''final direction = glassLightFromPointer(
  const Offset(180, 60),
  const Size(240, 120),
); // Offset(1, 0): pointer is to the right of the center.''',
      api: [
        DocApiEntry(
          name: 'glassLightFromPointer',
          type: 'Offset Function(Offset pointer, Size size)',
          defaultValue: 'no optional arguments',
          description: 'Returns a finite unit direction; falls back to Offset(0, -1) for degenerate input.',
        ),
      ],
    ),
    DocSection(
      id: 'legacy-fallback',
      heading: 'Legacy glass: Read the renderer result honestly',
      paragraphs: [
        'NibGlass selects its shader path only after the program loads, shader image filters are supported, and layout supplies a finite non-empty size. Otherwise it paints a BackdropFilter blur, tint and directional rim. This browser preview reports the actual capability check instead of calling the fallback equivalent to refraction.',
        'NibGlass.debugShaderPathAvailable() returns Future<bool>. It checks shader-filter support and whether the bundled liquid-glass program can load. It is useful for a diagnostic label; it does not confirm a particular frame’s geometry, GPU cost or physical-device appearance. A true result does not remove the bounded-layout requirement.',
        'Expect the fallback on a browser/backend without shader-image-filter support. Shader loading is asynchronous, so the fallback can also appear temporarily on a supported renderer. Keep content usable through that transition; never make an essential control depend on a refraction effect.',
      ],
      api: [
        DocApiEntry(
          name: 'NibGlass.debugShaderPathAvailable',
          type: 'static Future<bool> Function()',
          defaultValue: 'no arguments',
          description: 'Diagnostic in nib_motion. True requires shader-filter support and successful shader program loading.',
        ),
      ],
      note: 'Widget tests exercise the fallback and native input state. They do not certify physical GPU rendering, touch hardware or screen-reader behavior.',
    ),
    DocSection(
      id: 'legacy-state-lifecycle',
      heading: 'Legacy glass: Keep application state outside the material',
      paragraphs: [
        'NibLiquidGlass owns its transient light and press state. It exposes no controller and no disposal method. NibGlass loads the shared shader asynchronously and checks mounted before rebuilding after completion. Removing the widget releases its widget-owned animation state; keep expensive scenes bounded and mount only the preview the visitor requests.',
        'This example owns one local pinned boolean. Changing blur, shape or backdrop does not remount the glass or reset that note. The external ComponentSettings object is the inspector configuration, not a package controller; onChanged publishes a new settings value to the host. Complete export includes this helper and the same configured values.',
        'The demo’s event readout belongs to the host. Pointer events and the note button callback are real observations, not NibLiquidGlass callback properties. The patterned and content backdrops are local fixtures and make no network requests.',
      ],
    ),
    DocSection(
      id: 'legacy-accessibility',
      heading: 'Legacy glass: Keep content usable without decorative motion',
      paragraphs: [
        'The glass container is decorative and does not become a semantic button. Put real controls inside child, with their own labels, focus and keyboard actions. The example’s Pin note uses NibButton; decorative backdrop text is excluded from semantics so it is not read as a second unrelated document.',
        'The package’s NibMotion path respects its reduced-motion policy. Reduced motion removes the animated transition; press state can still change immediately. Keep the text and button fully usable with animated: false or interactive: false. Inspect contrast over every backdrop because blur and transparency do not guarantee it.',
        'When testing, check pointer down/cancel/release, keyboard activation of the child, text scaling, narrow layouts and disposal during a press. A desktop pointer test is distinct from a physical touch or screen-reader run.',
      ],
    ),
    DocSection(
      id: 'troubleshooting',
      heading: 'Legacy glass: Diagnose an effect that looks flat',
      paragraphs: [
        'No visible change from optics controls: read the renderer status first. Those parameters have no fallback implementation. If blur also seems absent, put a grid or text behind the surface and ensure the glass is painted above it in the same scene.',
        'No press response: animated defaults to false and interactive must be true. Lighting can still move without scale. A child button can work while decorative interaction is off; that is expected. transition has no effect when animated is false.',
        'Unexpected shape or clipping: check finite dimensions, content padding and whether clipper overrides borderRadius. Keep strong foreground contrast and test both renderer paths before relying on the effect in an application.',
      ],
    ),
  ],
);

const _minimalGlassCode = '''import 'package:flutter/material.dart';
import 'package:nib_components/nib_components.dart';

class MinimalGlass extends StatelessWidget {
  const MinimalGlass({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = NibTheme.of(context);
    return SizedBox(
      width: 320,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.background, theme.secondary, theme.primary],
                ),
              ),
            ),
          ),
          NibLiquidGlass(
            width: 260,
            height: 140,
            child: Text('Content stays sharp.',
                style: TextStyle(color: theme.foreground)),
          ),
        ],
      ),
    );
  }
}''';

const _minimalWaterCode = """import 'package:flutter/material.dart';
import 'package:nib_components/nib_components.dart';
import 'package:nib_motion/nib_motion.dart';

void main() => runApp(const MaterialApp(home: WaterExample()));

class WaterExample extends StatefulWidget {
  const WaterExample({super.key});
  @override
  State<WaterExample> createState() => _WaterExampleState();
}

class _WaterExampleState extends State<WaterExample> {
  final water = NibWaterController(drops: const [
    NibWaterDrop(id: 1, center: Offset(90, 130), radius: 48),
    NibWaterDrop(id: 2, center: Offset(270, 130), radius: 48),
  ]);

  @override
  void dispose() {
    water.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 360, height: 260, child: NibWaterGlass(
          controller: water,
          surface: true,
          animated: true,
        sampling: NibWaterSampling.live,
          background: const ColoredBox(
            color: Color(0xFFECEBE5),
            child: GridPaper(
              color: Color(0xFF969B96), interval: 20,
              divisions: 1, subdivisions: 1,
              child: Center(child: Text('Look through the water',
                style: TextStyle(color: Color(0xFF202724)))),
            ),
          ),
        )),
        TextButton(
          onPressed: () => water.disturb(const Offset(180, 130)),
          child: const Text('Make a wave'),
        ),
      ],
    ))),
  );
}""";
