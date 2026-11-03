import '../../content/site_content.dart';
import '../component_model.dart';
import '../component_settings.dart';

const selectionComponentGuides = <ComponentGuide>[
  ComponentGuide(
    id: "button",
    title: "Button",
    category: "Inputs and selection",
    summary: "A real action, a visible result, and the right busy state.",
    symbols: [
      "NibButton",
      "NibButtonSize",
      "NibButtonSizeMetrics",
      "NibButtonVariant",
    ],
    source:
        "ComponetsNib/nib_components/lib/src/button/; local 0.2.2 candidate",
    demoClass: "ButtonComponentDemo",
    demoFile: "lib/components/examples/selection_family_demos.dart",
    initial: ComponentSettings(
      text: 'Save changes',
      variant: 'primary',
      backdrop: 'md',
      interactive: false,
    ),
    previewHeight: 340,
    controls: [
      ComponentControl(
        "animated",
        "Animate feedback",
        ComponentControlKind.toggle,
      ),
      ComponentControl("disabled", "Disabled", ComponentControlKind.toggle),
      ComponentControl("text", "Label", ComponentControlKind.text),
      ComponentControl(
        "variant",
        "Variant",
        ComponentControlKind.choice,
        choices: ["primary", "secondary", "outline", "ghost", "destructive"],
      ),
      ComponentControl(
        "backdrop",
        "Size",
        ComponentControlKind.choice,
        choices: ["sm", "md", "lg"],
      ),
      ComponentControl("multiple", "Loading", ComponentControlKind.toggle),
      ComponentControl("vertical", "Pill shape", ComponentControlKind.toggle),
      ComponentControl(
        "interactive",
        "Fill available width",
        ComponentControlKind.toggle,
      ),
    ],
    minimalCode: "NibButton(label: 'Save changes', onPressed: () { /* Save local state. */ })",
    sections: [
      DocSection(
        id: "first-action",
        heading: "Connect the action to an outcome",
        paragraphs: [
          "NibButton requires onPressed. A null callback disables activation; disabled: true also blocks it. The preview increments a local counter from the real callback, so a visible press corresponds to an actual action. In an application, return errors near the action and keep the label specific to its outcome.",
        ],
      ),
      DocSection(
        id: "variants",
        heading: "Choose a visual role",
        paragraphs: [
          "NibButtonVariant has primary, secondary, outline, ghost, and destructive. They share the same box geometry for a given size. Use destructive for an action that needs that warning; the enum does not add confirmation or authorization. This preview only counts activations, including its destructive-colored variant.",
        ],
      ),
      DocSection(
        id: "busy",
        heading: "Keep pending work from running twice",
        paragraphs: [
          "loading: true shows a loader and blocks taps while preserving the button footprint. loadingText can describe the pending action; loadingWidget replaces the default indicator. The host must set and clear loading around its own work. This example exposes a manual busy switch and does not simulate a server request.",
        ],
        code: "setState(() => saving = true);\ntry {\n  await saveChanges();\n} finally {\n  if (mounted) setState(() => saving = false);\n}",
      ),
      DocSection(
        id: "content-size",
        heading: "Fit content without changing the action",
        paragraphs: [
          "NibButtonSize.sm, md, and lg use nominal heights 36, 44, and 52. NibButtonSizeMetrics.of(size) supplies height, font size, horizontal padding, icon size, and gap. Explicit height, width, padding, and borderRadius override the defaults. expand fills a bounded width; pill changes the shape. content replaces the normal label/icon layout, so provide its own semantics when necessary.",
        ],
      ),
      DocSection(
        id: "focus-motion",
        heading: "Keyboard and press feedback",
        paragraphs: [
          "Enter and Space activate an enabled focused button. focusNode belongs to the caller when provided; dispose it with your State. semanticLabel gives an icon-only button an accessible name. tooltip is extra help, not a substitute for that name. animated defaults to false; opting in animates the press response through NibMotion. The busy indicator is independent of that press flag.",
        ],
      ),
      DocSection(
        id: "troubleshooting",
        heading: "When a press does nothing",
        paragraphs: [
          "Check onPressed, disabled, and loading in that order. A disabled callback cannot be repaired with an animation flag. If a label clips, remove a fixed width or use expand in a bounded parent. Test custom backgroundColor and foregroundColor together, including disabled, hover, and focus states; color overrides can remove the contrast supplied by NibTheme.",
        ],
      ),
    ],
    limitations: [],
  ),
  ComponentGuide(
    id: "checkbox",
    title: "Checkbox",
    category: "Inputs and selection",
    summary: "Choose one item or express a mixed selection.",
    symbols: ["NibCheckbox"],
    source:
        "ComponetsNib/nib_components/lib/src/checkbox/; local 0.2.2 candidate",
    demoClass: "CheckboxComponentDemo",
    demoFile: "lib/components/examples/selection_family_demos.dart",
    initial: ComponentSettings(text: 'Include release notes', value: 0),
    previewHeight: 340,
    controls: [
      ComponentControl(
        "animated",
        "Animate feedback",
        ComponentControlKind.toggle,
      ),
      ComponentControl("disabled", "Disabled", ComponentControlKind.toggle),
      ComponentControl("text", "Label", ComponentControlKind.text),
      ComponentControl(
        "multiple",
        "Allow mixed state",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "value",
        "State: −1 mixed, 0 off, 1 on",
        ComponentControlKind.number,
        minimum: -1,
        maximum: 1,
      ),
    ],
    minimalCode: "NibCheckbox(value: included, label: 'Include release notes',\n  onChanged: (next) => setState(() => included = next!),\n)",
    sections: [
      DocSection(
        id: "state",
        heading: "Keep the checked value in your State",
        paragraphs: [
          "NibCheckbox is controlled: required value and onChanged describe the current and proposed states. A callback does not mutate value for you. The preview writes the emitted value back to settings. Null onChanged or disabled: true disables interaction.",
        ],
      ),
      DocSection(
        id: "mixed",
        heading: "Use null only for an indeterminate state",
        paragraphs: [
          "tristate defaults to false, which asserts that value is non-null. With tristate: true, taps cycle false → true → null → false. A mixed state is useful for a parent checkbox summarizing a partly selected list. Compute that state from the children; the checkbox does not discover them.",
        ],
        code: "final bool? all = selected.isEmpty\n  ? false\n  : selected.length == items.length ? true : null;\nNibCheckbox(tristate: true, value: all, onChanged: (next) {\n  setState(() => selected = next == true ? items.toSet() : {});\n});",
      ),
      DocSection(
        id: "label-theme",
        heading: "Make the row readable and tappable",
        paragraphs: [
          "label extends the tap target across the row. description supplies a second line. Without a label, give semanticLabel explicitly. size controls the visible box (default 20), while the widget keeps a minimum interaction area. activeColor overrides the checked and mixed fill; null uses NibTheme.primary.",
        ],
      ),
      DocSection(
        id: "feedback",
        heading: "Animate the mark, retain the meaning",
        paragraphs: [
          "animated: true adds a pop to the check or dash; the default false still changes value immediately. transition defaults to a 150 ms timing transition. Semantics include checked and, in tristate mode, mixed. A dash therefore carries meaning beyond color.",
        ],
      ),
      DocSection(
        id: "troubleshooting",
        heading: "Avoid a checkbox that springs back",
        paragraphs: [
          "If the mark returns to its old position, update the value supplied by the parent. If null causes an assertion, enable tristate or map null to a boolean intentionally. Do not coerce a mixed parent to true before deciding whether the next action should select or clear its children.",
        ],
      ),
    ],
    limitations: [],
  ),
  ComponentGuide(
    id: "switch",
    title: "Switch",
    category: "Inputs and selection",
    summary: "Change a setting and show when confirmation is pending.",
    symbols: ["NibSwitch", "NibSwitchThumbBuilder", "NibSwitchThumbState"],
    source:
        "ComponetsNib/nib_components/lib/src/switch/; local 0.2.2 candidate",
    demoClass: "SwitchComponentDemo",
    demoFile: "lib/components/examples/selection_family_demos.dart",
    initial: ComponentSettings(
      text: 'Workspace updates',
      value: 0,
      variant: 'image-thumb',
    ),
    previewHeight: 340,
    controls: [
      ComponentControl(
        "animated",
        "Animate feedback",
        ComponentControlKind.toggle,
      ),
      ComponentControl("disabled", "Disabled", ComponentControlKind.toggle),
      ComponentControl("text", "Label", ComponentControlKind.text),
      ComponentControl(
        "value",
        "Off / on",
        ComponentControlKind.number,
        minimum: 0,
        maximum: 1,
      ),
      ComponentControl("multiple", "Loading", ComponentControlKind.toggle),
      ComponentControl(
        "variant",
        "Thumb",
        ComponentControlKind.choice,
        choices: ["default", "icons", "images", "custom", "image-thumb"],
      ),
    ],
    minimalCode: "NibSwitch(value: enabled, label: 'Workspace updates', animated: true,\n  transition: const NibTransition(\n    duration: Duration(milliseconds: 320), curve: Curves.easeInOutCubic,\n  ),\n  onChanged: (next) => setState(() => enabled = next),\n)",
    sections: [
      DocSection(
        id: "boolean",
        heading: "Use a switch for an on/off setting",
        paragraphs: [
          "NibSwitch requires a boolean value. The onChanged callback receives its proposed inverse. Keep that value in the host; a switch has no separate controller. disabled: true, loading: true, or null onChanged blocks toggling.",
        ],
      ),
      DocSection(
        id: "confirmation",
        heading: "Represent pending confirmation honestly",
        paragraphs: [
          "loading shows a spinner and blocks repeat activation. It does not send a request or change value. For an optimistic setting, update value then restore it on failure. For a confirmed setting, keep the previous value while awaiting the result and only commit on success. Decide which behavior your application needs and explain errors near the setting.",
        ],
      ),
      DocSection(
        id: "thumb",
        heading: "Customize the thumb without replacing the switch",
        paragraphs: [
          "onThumbIcon and offThumbIcon accept any Widget, including Image.asset or Image.memory; they decorate the built-in thumb. The Images variant uses the existing Nib logo PNG embedded in the copied source. It loads without a network or asset declaration. The package does not include an SVG decoder. loading takes precedence over those icons. thumbBuilder replaces shape, color, icon, and spinner entirely. Its NibSwitchThumbState supplies value, enabled, loading, and resolved size; a custom builder must draw its own busy state. The switch still positions and animates it.",
        ],
      ),
      DocSection(
        id: "image-thumb",
        heading: "Use images inside the thumb or replace it entirely",
        paragraphs: [
          "Images keeps the built-in circular thumb and displays the Nib logo in both states. Image-thumb replaces the entire thumb with a contrasting outline, the same logo and a loading ring. Custom uses a rounded square; Icons adds a state badge. All variants keep the brand visible when off. Both variants use NibSwitch animated movement; changing the picture does not create a separate animation engine.",
          "For application assets, declare the PNG paths in pubspec.yaml and pass Image.asset to onThumbIcon and offThumbIcon. An SVG-rendering widget can occupy the same slots if your application provides one; NibSwitch accepts the widget without parsing SVG itself. Keep these decorative images excluded from semantics and label the setting once.",
        ],
        code: "NibSwitch(\n  value: enabled, animated: true, label: 'Workspace updates',\n  transition: const NibTransition(\n    duration: Duration(milliseconds: 320), curve: Curves.easeInOutCubic,\n  ),\n  onThumbIcon: Image.asset('assets/moving.png', excludeFromSemantics: true),\n  offThumbIcon: Image.asset('assets/still.png', excludeFromSemantics: true),\n  onChanged: (next) => setState(() => enabled = next),\n)",
      ),
      DocSection(
        id: "sizing",
        heading: "Keep visible size and interaction size separate",
        paragraphs: [
          "The default track is 44 by 24 logical pixels. trackWidth and trackHeight change that geometry; thumbShape replaces the default circular shape. A label makes the whole row actionable and description provides a second line. Null color overrides retain NibTheme tokens.",
        ],
      ),
      DocSection(
        id: "keyboard",
        heading: "Label the setting and preserve focus",
        paragraphs: [
          "semanticLabel defaults to label. Supply a name for a track without visible text. External focusNode ownership stays with the caller; autofocus defaults to false. The package defaults animated to false; this website opts in. The demo uses a 320 ms easeInOutCubic transition so the glide is visible. Import NibTransition from package:nib_motion/nib_motion.dart for that override. System reduced motion still takes priority; the value changes without decorative travel. Retargeting starts from the current position rather than jumping to the previous endpoint.",
        ],
      ),
      DocSection(
        id: "troubleshooting",
        heading: "An icon disappeared or the setting stays busy",
        paragraphs: [
          "Check whether loading is still true or thumbBuilder overrides the built-in icons. A promise completing does not clear loading automatically. Avoid replacing the switch while waiting; preserving its identity also preserves focus.",
        ],
      ),
    ],
    limitations: [],
  ),
  ComponentGuide(
    id: "radio-group",
    title: "Radio group",
    category: "Inputs and selection",
    summary: "Choose exactly one option with native-style arrow-key selection.",
    symbols: ["NibRadioGroup", "NibRadioOption", "NibRadioOptionBuilder"],
    source: "ComponetsNib/nib_components/lib/src/radio_group/; local 0.2.2 candidate",
    demoClass: "RadioGroupComponentDemo",
    demoFile: "lib/components/examples/selection_family_demos.dart",
    initial: ComponentSettings(text: 'daily', vertical: true),
    previewHeight: 340,
    controls: [
      ComponentControl(
        "animated",
        "Animate feedback",
        ComponentControlKind.toggle,
      ),
      ComponentControl("disabled", "Disabled", ComponentControlKind.toggle),
      ComponentControl(
        "vertical",
        "Vertical layout",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "variant",
        "Option presentation",
        ComponentControlKind.choice,
        choices: ["default", "cards"],
      ),
    ],
    minimalCode: "NibRadioGroup<String>(\n  options: const [NibRadioOption(value: 'daily', label: 'Daily'),\n    NibRadioOption(value: 'weekly', label: 'Weekly')],\n  value: frequency, onChanged: (next) => setState(() => frequency = next),\n)",
    sections: [
      DocSection(
        id: "one-choice",
        heading: "Model one choice with a typed value",
        paragraphs: [
          "options and value are required. value can be null before a choice is made. Each NibRadioOption has a typed value and label; equality selects the matching option. onChanged emits the new value. A radio option already selected does not clear itself when pressed again.",
        ],
      ),
      DocSection(
        id: "options",
        heading: "Describe and disable individual options",
        paragraphs: [
          "NibRadioOption supports description, leading, and disabled. The Instant fixture is disabled while Daily and Weekly remain usable. Group disabled or null onChanged disables every option. Avoid duplicate option values because selection is based on equality.",
        ],
      ),
      DocSection(
        id: "keyboard",
        heading: "Arrows select as they move focus",
        paragraphs: [
          "The group uses one tab stop. Arrow keys move and select among enabled options, wrapping past the ends; Space and Enter select the focused option. This differs from the toggle group, whose arrows move focus without selecting. Give the group a semanticLabel that describes the decision.",
        ],
      ),
      DocSection(
        id: "presentation",
        heading: "Lay out options or replace their content",
        paragraphs: [
          "direction defaults to Axis.vertical. Horizontal groups wrap at narrow widths. spacing defaults to 12 and dotSize to 20. optionBuilder receives context, NibRadioOption, selected, and disabled. Return the row content; the group keeps tap, focus, keyboard, and ripple behavior. The Cards option in this preview exercises that callback.",
        ],
      ),
      DocSection(
        id: "motion",
        heading: "Keep selection independent of animation",
        paragraphs: [
          "animated: true pops the selected dot. The static default retains selection and keyboard behavior. transition can change that feedback. Custom optionBuilder content replaces the default dot and therefore controls its own visual selection state.",
        ],
      ),
      DocSection(
        id: "troubleshooting",
        heading: "Selection is missing or focus skips an option",
        paragraphs: [
          "Ensure value matches an option using the same type and equality semantics. A disabled option is intentionally skipped by keyboard navigation. Update the parent value in onChanged; creating a separate controller is unnecessary because this API has none.",
        ],
      ),
    ],
    limitations: [],
  ),
  ComponentGuide(
    id: "toggle-group",
    title: "Toggle group",
    category: "Inputs and selection",
    summary:
        "Press one style or combine several without inventing a controller.",
    symbols: ["NibToggleGroup", "NibToggleOption"],
    source: "ComponetsNib/nib_components/lib/src/toggle_group/; local 0.2.2 candidate",
    demoClass: "ToggleGroupComponentDemo",
    demoFile: "lib/components/examples/selection_family_demos.dart",
    initial: ComponentSettings(text: '', multiple: false),
    previewHeight: 340,
    controls: [
      ComponentControl(
        "animated",
        "Animate feedback",
        ComponentControlKind.toggle,
      ),
      ComponentControl("disabled", "Disabled", ComponentControlKind.toggle),
      ComponentControl(
        "multiple",
        "Multiple selection",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "vertical",
        "Vertical layout",
        ComponentControlKind.toggle,
      ),
    ],
    minimalCode: "NibToggleGroup<String>(\n  options: const [NibToggleOption(value: 'bold', label: 'Bold'),\n    NibToggleOption(value: 'italic', label: 'Italic')],\n  value: style, onChanged: (next) => setState(() => style = next),\n)",
    sections: [
      DocSection(
        id: "single",
        heading: "Allow a single choice to be cleared",
        paragraphs: [
          "The default constructor requires options and nullable value. Pressing the active segment emits null, so this is useful for optional formatting. A radio group is a better fit when choosing an option should never toggle it off.",
        ],
      ),
      DocSection(
        id: "multiple",
        heading: "Combine values with the named constructor",
        paragraphs: [
          "NibToggleGroup.multiple takes a required Set<T> values and a ValueChanged<Set<T>> callback. Treat the emitted set as the next state. The demo stores its selected styles in a sorted comma-separated settings string so copied configuration matches the preview.",
        ],
        code: "NibToggleGroup<String>.multiple(\n  options: const [NibToggleOption(value: 'bold', label: 'Bold'),\n    NibToggleOption(value: 'italic', label: 'Italic')],\n  values: styles, onChanged: (next) => setState(() => styles = next),\n)",
      ),
      DocSection(
        id: "options",
        heading: "Give each segment a name",
        paragraphs: [
          "NibToggleOption requires value and at least label or icon. An icon-only option also requires semanticLabel. disabled applies to one segment; the group-level disabled flag blocks all. Each segment is a real NibButton and shares NibButtonSize presets.",
        ],
      ),
      DocSection(
        id: "keyboard",
        heading: "Separate focus from activation",
        paragraphs: [
          "There is one tab stop. Arrows move focus, wrap, and skip disabled segments without changing selection. Enter or Space toggles the focused segment. Test this distinction if replacing a radio group with toggle segments.",
        ],
      ),
      DocSection(
        id: "layout",
        heading: "Wrap naturally or share a bounded width",
        paragraphs: [
          "direction defaults to horizontal and wraps narrow content. Vertical mode stacks segments. itemWidth fixes each segment width; fillWidth gives horizontal segments equal shares and requires a finite parent width. spacing defaults to 8. animated pops a newly selected segment and defaults to false.",
        ],
      ),
      DocSection(
        id: "troubleshooting",
        heading: "A selection disappears or a row overflows",
        paragraphs: [
          "An active single segment deliberately toggles back to null. Use a radio group if that behavior is wrong for your task. Avoid fillWidth inside an unbounded horizontal scroll view; give the group a finite width or let its segments wrap.",
        ],
      ),
    ],
    limitations: [],
  ),
  ComponentGuide(
    id: "slider",
    title: "Slider and range",
    category: "Inputs and selection",
    summary: "Scrub a value or adjust a bounded interval.",
    symbols: [
      "NibRangeValues",
      "NibSlider",
      "NibSliderThumbBuilder",
      "NibSliderThumbState",
    ],
    source:
        "ComponetsNib/nib_components/lib/src/slider/; local 0.2.2 candidate",
    demoClass: "SliderComponentDemo",
    demoFile: "lib/components/examples/selection_family_demos.dart",
    initial: ComponentSettings(value: 40, text: '85', searchable: true),
    previewHeight: 390,
    controls: [
      ComponentControl(
        "animated",
        "Animate feedback",
        ComponentControlKind.toggle,
      ),
      ComponentControl("disabled", "Disabled", ComponentControlKind.toggle),
      ComponentControl("multiple", "Range mode", ComponentControlKind.toggle),
      ComponentControl(
        "vertical",
        "Vertical axis",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "searchable",
        "Snap to ten divisions",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "value",
        "Value / lower bound",
        ComponentControlKind.number,
        minimum: 0,
        maximum: 100,
      ),
      ComponentControl("text", "Range upper bound", ComponentControlKind.text),
      ComponentControl(
        "variant",
        "Thumb",
        ComponentControlKind.choice,
        choices: ["default", "custom"],
      ),
    ],
    minimalCode: "NibSlider(value: volume, min: 0, max: 100,\n  onChanged: (next) => setState(() => volume = next),\n)",
    sections: [
      DocSection(
        id: "domain",
        heading: "Choose a domain and commit its value",
        paragraphs: [
          "The default domain is 0 to 1; min must be less than max. This demo uses 0 to 100. value is controlled and onChanged reports pointer or keyboard changes. onChangeStart and onChangeEnd delimit an interaction, so expensive persistence can wait for the end while the preview responds immediately.",
        ],
      ),
      DocSection(
        id: "range",
        heading: "Keep two thumbs ordered",
        paragraphs: [
          "NibSlider.range requires NibRangeValues(start, end). Thumbs clamp against each other and do not cross. NibRangeValues.clamp(min, max) sorts and bounds endpoints; copyWith creates a new pair. The demo writes both emitted endpoints into its configuration.",
        ],
        code: "NibSlider.range(\n  values: NibRangeValues(low, high), min: 0, max: 100,\n  onChanged: (range) => setState(() { low = range.start; high = range.end; }),\n)",
      ),
      DocSection(
        id: "ticks",
        heading: "Choose continuous or stepped movement",
        paragraphs: [
          "divisions: null gives continuous values. A positive division count snaps to divisions + 1 ticks; ten divisions over 0–100 yields eleven stops. showValueLabel displays a bubble during dragging. valueLabelFormatter changes that bubble text without changing the numeric value.",
        ],
      ),
      DocSection(
        id: "axis-thumb",
        heading: "Change the axis or thumb content",
        paragraphs: [
          "Axis.vertical puts the minimum at the bottom and needs a bounded height. The demo reserves 220 logical pixels. thumbBuilder receives NibSliderThumbState with value, dragging, focused, and size. It paints a replacement thumb; the slider still owns position and interaction. trackHeight defaults to 4 and thumbSize to 20.",
        ],
      ),
      DocSection(
        id: "keyboard-motion",
        heading: "Retain keyboard and semantic access",
        paragraphs: [
          "label names each thumb in semantics. A null change callback or disabled: true disables interaction. External focusNode applies to the first thumb and remains caller-owned. animated affects the press pop and value label; dragging and track fill still follow the pointer directly.",
        ],
      ),
      DocSection(
        id: "troubleshooting",
        heading: "The range collapses or the slider has no space",
        paragraphs: [
          "Keep start no greater than end and keep both within the chosen domain. If a vertical slider has zero height, give its parent an explicit extent. If the thumb moves but the value resets, commit the emitted value in the parent. Animation is not a substitute for that state update.",
        ],
      ),
    ],
    limitations: [],
  ),
  ComponentGuide(
    id: "select",
    title: "Select",
    category: "Inputs and selection",
    summary: "Choose from a fixed list, grouped or searchable.",
    symbols: [
      "NibSelect",
      "NibSelectAnimation",
      "NibSelectController",
      "NibSelectGroup",
      "NibSelectNoResultsBuilder",
      "NibSelectOption",
      "resolveNibSelectEnter",
    ],
    source:
        "ComponetsNib/nib_components/lib/src/select/; local 0.2.2 candidate",
    demoClass: "SelectComponentDemo",
    demoFile: "lib/components/examples/selection_family_demos.dart",
    initial: ComponentSettings(
      text: '',
      interactive: true,
      variant: 'flat',
      backdrop: 'fadeScale',
      searchable: false,
    ),
    previewHeight: 340,
    controls: [
      ComponentControl(
        "animated",
        "Animate feedback",
        ComponentControlKind.toggle,
      ),
      ComponentControl("disabled", "Disabled", ComponentControlKind.toggle),
      ComponentControl(
        "multiple",
        "Multiple selection",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "searchable",
        "Search in list",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "variant",
        "Options",
        ComponentControlKind.choice,
        choices: ["flat", "grouped"],
      ),
      ComponentControl(
        "backdrop",
        "Dropdown motion",
        ComponentControlKind.choice,
        choices: ["none", "fade", "slide", "scale", "fadeScale", "slideFade"],
      ),
      ComponentControl(
        "interactive",
        "Accept selection",
        ComponentControlKind.toggle,
      ),
    ],
    minimalCode: "NibSelect<String>(options: const [\n  NibSelectOption(value: 'apple', label: 'Apple'),\n  NibSelectOption(value: 'banana', label: 'Banana'),\n], onChanged: (value) { /* Read the typed choice. */ })",
    sections: [
      DocSection(
        id: "options",
        heading: "Keep labels separate from stored values",
        paragraphs: [
          "Provide exactly one of options or groups. NibSelectOption<T> contains value, label, optional subtitle and icon, and disabled. NibSelectGroup<T> adds a section label and a list of options. Disabled rows remain visible and cannot be chosen. The label is displayed; callbacks return the typed value.",
        ],
      ),
      DocSection(
        id: "ownership",
        heading: "Choose initial state or own a controller",
        paragraphs: [
          "value and values seed only an internally created controller on first build. With controller supplied, that controller is the source of truth and those initial values are ignored. NibSelectController exposes selectedValue, selectedValues, isOpen, selectOnly, toggle, setSelection, clear, open, and close. Dispose only the controller you create; do not replace it during style changes.",
        ],
      ),
      DocSection(
        id: "selection",
        heading: "Handle one or many selections",
        paragraphs: [
          "onChanged is the single-value convenience callback and may emit null when cleared. onSelectionChanged returns the full list in either mode. multiSelect keeps the dropdown open and toggles items. clearable adds a trailing clear affordance. The preview also offers an explicit controller-driven Clear selection button.",
        ],
      ),
      DocSection(
        id: "search",
        heading: "Filter visible rows without changing the data",
        paragraphs: [
          "searchable adds an in-list search field. searchPlaceholder labels it and NibSelectNoResultsBuilder customizes the empty result. The demo uses a local list, so search makes no network request. loading indicates externally pending work; disabled blocks opening and choosing.",
        ],
      ),
      DocSection(
        id: "motion",
        heading: "Choose a preset or supply an entrance pose",
        paragraphs: [
          "animated defaults to false. When enabled, animation accepts none, fade, slide, scale, fadeScale, or slideFade. transition controls timing separately, while enterFrom supplies an explicit NibAnim and overrides the preset. resolveNibSelectEnter(animation, openUp: ...) returns the direction-aware initial pose. staggerOptions separately staggers rows through NibMotionList.",
        ],
      ),
      DocSection(
        id: "overlay-keyboard",
        heading: "Operate the dropdown inside its host",
        paragraphs: [
          "The dropdown uses the nearest Overlay, flips when space is limited, and constrains its height. Arrow keys move among enabled results; Enter chooses and Escape closes. Give semanticLabel to the trigger. maxDropdownHeight defaults to 280; it is a ceiling, not a promise that every local preview has that much room.",
        ],
      ),
      DocSection(
        id: "troubleshooting",
        heading: "An external value did not update the selection",
        paragraphs: [
          "Changing value after mount does not control this widget. Use the same external controller and call selectOnly or setSelection instead. Supplying both groups and options asserts. Empty search results do not mean the underlying list changed; clear the query or inspect the custom matcher.",
        ],
      ),
    ],
    limitations: [],
  ),
  ComponentGuide(
    id: "combobox",
    title: "Combobox",
    category: "Inputs and selection",
    summary: "Search a local list, allow free text, or exercise a bounded async fixture.",
    symbols: [
      "NibCombobox",
      "NibComboboxController",
      "NibComboboxFilter",
      "NibComboboxOption",
      "NibComboboxOptionsLoader",
    ],
    source:
        "ComponetsNib/nib_components/lib/src/combobox/; local 0.2.2 candidate",
    demoClass: "ComboboxComponentDemo",
    demoFile: "lib/components/examples/selection_family_demos.dart",
    initial: ComponentSettings(text: '', variant: 'local', interactive: true),
    previewHeight: 340,
    controls: [
      ComponentControl(
        "animated",
        "Animate feedback",
        ComponentControlKind.toggle,
      ),
      ComponentControl("disabled", "Disabled", ComponentControlKind.toggle),
      ComponentControl(
        "multiple",
        "Multiple selection",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "variant",
        "Search behavior",
        ComponentControlKind.choice,
        choices: ["local", "prefix", "free-text", "async"],
      ),
      ComponentControl(
        "interactive",
        "Accept selection",
        ComponentControlKind.toggle,
      ),
    ],
    minimalCode: "NibCombobox<String>(options: const [\n  NibComboboxOption(value: 'apple', label: 'Apple'),\n  NibComboboxOption(value: 'banana', label: 'Banana'),\n], onChanged: (value) { /* Read the chosen value. */ })",
    sections: [
      DocSection(
        id: "search",
        heading: "Type to find an option",
        paragraphs: [
          "NibCombobox puts the query directly in an editable field. NibComboboxOption<T> separates value from label and can add subtitle, icon, or disabled. The default local filter matches a case-insensitive substring of label or subtitle. The Prefix variant supplies a NibComboboxFilter that accepts only labels starting with the query.",
        ],
      ),
      DocSection(
        id: "state",
        heading: "Own selection separately from the query",
        paragraphs: [
          "NibComboboxController exposes selectedValue, selectedValues, query, and isOpen. selectOnly, toggle, and clear change selection; open and close change the panel state. query is a readout of the field. setQuery is a low-level mirror and does not itself replace the visible editing value. The example keeps one controller through theme or animation changes and disposes it on removal.",
        ],
      ),
      DocSection(
        id: "multiple",
        heading: "Choose chips or submit free text",
        paragraphs: [
          "multiSelect keeps several selected values and displays chips. onSelectionChanged supplies the complete selection. allowFreeText enables onFreeTextSubmitted for text that is not a chosen option; it does not fabricate a typed option value. The demo records that submission as an event without pretending it came from the list.",
        ],
      ),
      DocSection(
        id: "async",
        heading: "Use the async loader contract",
        paragraphs: [
          "NibComboboxOptionsLoader<T> maps the current query to a Future<List<NibComboboxOption<T>>>. debounceDuration defaults to 300 ms. The widget ignores stale results when a newer request wins; your service still owns cancellation, authorization, failures, and resource limits. The Async fixture waits 220 ms and filters an in-memory list. It sends no network traffic.",
        ],
        code: "NibCombobox<String>(\n  asyncOptionsLoader: (query) async => repository.search(query),\n  debounceDuration: const Duration(milliseconds: 300),\n  onChanged: (value) => setState(() => selected = value),\n)",
      ),
      DocSection(
        id: "presentation",
        heading: "Keep the field and dropdown consistent",
        paragraphs: [
          "clearable defaults to true, disabled to false, and maxDropdownHeight to 280. loading presents pending work; it does not invoke the loader. backgroundColor, borderColor, borderWidth, borderRadius, padding, and hintStyle override theme defaults. animated opts into a short dropdown entrance.",
        ],
      ),
      DocSection(
        id: "keyboard",
        heading: "Use the editable field as the focus entry point",
        paragraphs: [
          "Typing filters results, arrows move the highlighted option, Enter activates it or submits permitted free text, and Escape closes and restores the selected label when free text is off. Multi-select Backspace can remove the last chip when the query is empty. Verify your host’s text editing and focus behavior as well as pointer selection.",
        ],
      ),
      DocSection(
        id: "troubleshooting",
        heading: "The list is empty or a query is not visible",
        paragraphs: [
          "Inspect loading, filtering, disabled options, and whether the async fixture has completed. Controller.open() in this candidate does not initialize the visible option list until the field interaction populates it; use the field to open this demo. Do not claim that setQuery is a full text-controller API. A fresh controller on every rebuild loses selection and query state.",
        ],
      ),
    ],
    limitations: [
      "Controller.open() alone does not populate options before the first field interaction in this candidate.",
    ],
  ),
  ComponentGuide(
    id: "date-picker",
    title: "Date picker",
    category: "Inputs and selection",
    summary: "Select a date, a range, or a set of days in a bounded calendar.",
    symbols: [
      "NibCalendarDayBuilder",
      "NibCalendarDayState",
      "NibDateCellShape",
      "NibDatePicker",
      "NibDatePickerController",
      "NibDatePickerDisplayMode",
      "NibDatePickerMode",
      "NibDateRange",
      "NibDisabledDayPredicate",
    ],
    source: "ComponetsNib/nib_components/lib/src/date_picker/; local 0.2.2 candidate",
    demoClass: "DatePickerComponentDemo",
    demoFile: "lib/components/examples/selection_family_demos.dart",
    initial: ComponentSettings(
      text: '',
      variant: 'single',
      backdrop: 'inline',
      searchable: false,
    ),
    previewHeight: 500,
    controls: [
      ComponentControl(
        "animated",
        "Animate feedback",
        ComponentControlKind.toggle,
      ),
      ComponentControl("disabled", "Disabled", ComponentControlKind.toggle),
      ComponentControl(
        "variant",
        "Selection mode",
        ComponentControlKind.choice,
        choices: ["single", "range", "multi"],
      ),
      ComponentControl(
        "backdrop",
        "Display",
        ComponentControlKind.choice,
        choices: ["inline", "popover", "dialog"],
      ),
      ComponentControl(
        "multiple",
        "Disable Sundays",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "vertical",
        "Rounded cells",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "searchable",
        "Custom day labels",
        ComponentControlKind.toggle,
      ),
    ],
    minimalCode: "NibDatePicker(initialMonth: DateTime(2026, 10),\n  onDateChanged: (day) => setState(() => selected = day),\n)",
    sections: [
      DocSection(
        id: "selection",
        heading: "Match the callback to the mode",
        paragraphs: [
          "NibDatePickerMode.single emits DateTime? through onDateChanged. range emits NibDateRange? through onRangeChanged; end remains null until the second pick and isComplete tells you whether both endpoints exist. multi emits the complete date list through onDatesChanged. Values are normalized to calendar days rather than time-of-day appointments.",
        ],
      ),
      DocSection(
        id: "display",
        heading: "Choose inline, popover, or dialog",
        paragraphs: [
          "NibDatePickerDisplayMode.inline is the default. Popover places a trigger and nearest-overlay calendar beside it; dialog centers the calendar in that same nearest overlay. This date-picker dialog is distinct from the root-overlay showNibDialog helper. closeOnSelect defaults to true: single closes after one pick, range after completion, and multi remains open.",
        ],
      ),
      DocSection(
        id: "controller",
        heading: "Read and drive the calendar deliberately",
        paragraphs: [
          "NibDatePickerController owns selectedDate, selectedRange, selectedDates, displayedMonth, and isOpen. Seed it once; the matching controller getter is meaningful for the active mode. setSingle, setRange, setMulti, clear, showMonth, open, and close change those states. setSelectableBounds supplies runtime bounds that take precedence over widget bounds. Dispose the controller you create.",
        ],
      ),
      DocSection(
        id: "bounds",
        heading: "Disable days without inventing availability",
        paragraphs: [
          "minDate, maxDate, and NibDisabledDayPredicate restrict selection. The fixture covers October–December 2026 and optionally disables Sundays. These are sample business rules, not a current availability service. A server must validate an accepted date again if availability can change.",
        ],
      ),
      DocSection(
        id: "cells",
        heading: "Customize cells and keep their interaction",
        paragraphs: [
          "NibDateCellShape offers circle, rounded, square, and pill. NibCalendarDayBuilder receives NibCalendarDayState: date, selected, inRange, isRangeStart, isRangeEnd, today, outOfMonth, and disabled. Return only the cell content; the calendar retains its tap target and 44-pixel sizing. A custom builder supersedes built-in cell appearance.",
        ],
      ),
      DocSection(
        id: "locale-motion",
        heading: "Use the host locale and optional motion",
        paragraphs: [
          "locale: null uses the surrounding MaterialLocalizations; an explicit locale overrides labels where the host supports it. animated defaults to false and opts into calendar transitions and selection feedback. The demo keeps the displayed month stable during unrelated control changes.",
        ],
      ),
      DocSection(
        id: "troubleshooting",
        heading: "A selected value or date range seems wrong",
        paragraphs: [
          "Controller state overrides the initial widget selections. Pick two endpoints before treating a range as complete. Date-only comparison is intentional; do not send local midnight as an absolute instant without your own time-zone contract. A calendar scaled to a narrow preview is not physical-device or screen-reader verification.",
        ],
      ),
    ],
    limitations: [],
  ),
  ComponentGuide(
    id: "otp-input",
    title: "One-time code input",
    category: "Inputs and selection",
    summary:
        "Enter six fixture digits through the keyboard or an on-screen keypad.",
    symbols: [
      "NibOtpCell",
      "NibOtpController",
      "NibOtpInput",
      "NibOtpKey",
      "NibOtpKeyboard",
      "NibOtpKeypad",
      "NibOtpKeypadStyle",
    ],
    source:
        "ComponetsNib/nib_components/lib/src/otp_input/; local 0.2.2 candidate",
    demoClass: "OtpInputComponentDemo",
    demoFile: "lib/components/examples/selection_family_demos.dart",
    initial: ComponentSettings(
      text: '',
      variant: 'system',
      backdrop: 'default',
      interactive: true,
    ),
    previewHeight: 520,
    controls: [
      ComponentControl(
        "animated",
        "Animate feedback",
        ComponentControlKind.toggle,
      ),
      ComponentControl("disabled", "Disabled", ComponentControlKind.toggle),
      ComponentControl(
        "variant",
        "Input method",
        ComponentControlKind.choice,
        choices: ["system", "keypad"],
      ),
      ComponentControl(
        "multiple",
        "Obscure digits",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "interactive",
        "Accept input",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "backdrop",
        "Feedback",
        ComponentControlKind.choice,
        choices: ["default", "error"],
      ),
      ComponentControl("text", "Configured digits", ComponentControlKind.text),
    ],
    minimalCode: "NibOtpInput(length: 6, semanticLabel: 'Verification code',\n  onCompleted: (code) { /* Ask your own server to verify it. */ },\n)",
    sections: [
      DocSection(
        id: "entry",
        heading: "Enter digits with one editing field",
        paragraphs: [
          "NibOtpInput defaults to six cells and NibOtpKeyboard.system. A prefilled or replacement controller is adopted without firing onChanged or onCompleted; later controller changes and user edits do notify. It uses one TextField behind the cells, which accepts typing and pasted codes and requests oneTimeCode autofill. The widget filters digits and bounds the visible value to length. onChanged receives partial input; onCompleted reports a newly complete value.",
        ],
      ),
      DocSection(
        id: "controller",
        heading: "Keep code ownership explicit",
        paragraphs: [
          "NibOtpController exposes value, setValue, and clear. The widget sanitizes programmatic input for its display; validate and normalize configured text before storing it, as the controller itself accepts arbitrary strings. This demo stores only up to six digits. It keeps the controller through style changes and disposes it when removed.",
        ],
      ),
      DocSection(
        id: "keypad",
        heading: "Use the built-in keypad as an input option",
        paragraphs: [
          "NibOtpKeyboard.onScreen uses NibOtpKeypad and NibOtpKey; it does not open the system keyboard. NibOtpKeypadStyle configures key dimensions, spacing, maximum width, and colors. NibOtpCell draws each digit from char, active, theme, obscured, error, and enabled state. These exported building blocks can also form a custom composition, but you then own its value, length rules, and callbacks.",
        ],
      ),
      DocSection(
        id: "completion",
        heading: "Separate entry from verification",
        paragraphs: [
          "A complete six-digit value is not proof of identity. The demo reports completion without contacting a service. Your host must verify the code, handle expiry and retry limits, and clear or preserve input according to the result. loading blocks input and shows pending verification; errorText displays an application error. No local keypad is a security guarantee.",
        ],
      ),
      DocSection(
        id: "customization",
        heading: "Size cells and feedback to the available width",
        paragraphs: [
          "cellWidth defaults to 44, cellHeight to 52, and spacing to 10. The demo narrows six cells to fit its panel and uses a compact keypad. obscureText hides visible digits but does not encrypt or securely store the code. animated opts into cell feedback and defaults to false. autoFocus defaults to false so visiting the guide does not steal focus.",
        ],
      ),
      DocSection(
        id: "confirm",
        heading: "Handle confirmation separately from completion",
        paragraphs: [
          "The on-screen keypad supports onConfirm, a custom confirmButton, and showConfirmButton (true by default). Completion means the code has enough digits; confirmation means the user asked to continue. NibOtpKeypad receives onDigit and onBackspace, plus optional onConfirm. Keep these distinct when composing your own keypad.",
        ],
      ),
      DocSection(
        id: "troubleshooting",
        heading: "A prefilled code differs or completion fires again",
        paragraphs: [
          "The displayed field strips nondigits and truncates to length. Avoid logging real codes in production; this preview only reports the number of entered digits. Completion may fire again after clearing and re-entering a code. Physical SMS autofill, device keyboards, and screen-reader behavior require their own device checks.",
        ],
      ),
    ],
    limitations: [
      "Fixture only: no code verification, authentication, or SMS service.",
      "System autofill and physical screen-reader behavior are not established by widget tests.",
    ],
  ),
];
