import '../../content/site_content.dart';
import '../component_model.dart';
import '../component_settings.dart';

const inputComponentGuide = ComponentGuide(
  id: 'input',
  title: 'Input and textarea',
  category: 'Inputs',
  summary:
      'Edit a value, validate it, and keep the cursor where the user left it.',
  symbols: ['NibInput', 'NibTextarea', 'NibValidator', 'NibValidators'],
  source:
      'ComponetsNib/nib_components/lib/src/input/nib_input.dart; '
      'lib/src/textarea/nib_textarea.dart; lib/src/validation/nib_validators.dart',
  demoClass: 'InputComponentDemo',
  demoFile: 'lib/components/examples/input_component_demo.dart',
  initial: ComponentSettings(
    text: 'Hello, Nib',
    variant: 'single-line',
    value: 80,
  ),
  previewHeight: 430,
  minimalCode: '''import 'package:flutter/material.dart';
import 'package:nib_components/nib_components.dart';

NibInput(
  label: 'Display name',
  placeholder: 'Ada Lovelace',
  clearable: true,
  validator: NibValidators.required('Enter a name.'),
  onChanged: (value) { /* Update application state. */ },
)''',
  controls: [
    ComponentControl(
      'variant',
      'Field type',
      ComponentControlKind.choice,
      choices: ['single-line', 'multiline'],
      help: 'Switches between the public NibInput and NibTextarea widgets.',
    ),
    ComponentControl(
      'text',
      'Current text',
      ComponentControlKind.text,
      help: 'An explicit text edit replaces the field value. Style controls preserve selection.',
    ),
    ComponentControl(
      'value',
      'Maximum characters',
      ComponentControlKind.number,
      minimum: 12,
      maximum: 280,
      help: 'maxLength limits typing. A validator also checks programmatic values.',
    ),
    ComponentControl('disabled', 'Disabled', ComponentControlKind.toggle),
    ComponentControl(
      'animated',
      'Animate helper and error text',
      ComponentControlKind.toggle,
      help: 'Package default is off. This example starts with animation enabled. Uses the package’s NibMotion footer transition.',
    ),
    ComponentControl(
      'radius',
      'Corner radius',
      ComponentControlKind.number,
      minimum: 0,
      maximum: 24,
      advanced: true,
    ),
  ],
  sections: [
    DocSection(
      id: 'choose-a-field',
      heading: 'Choose a field',
      paragraphs: [
        'NibInput is a single-line FormField<String>. Use it for a name, search query, email address, or password. NibTextarea is the multiline member of the family; use it for a message or description that needs line breaks. Both render a native Flutter TextField with Nib theme colors, a label, and a helper or validation message.',
        'The live example changes the actual widget when you choose a field type. It keeps one TextEditingController, so switching to multiline retains the current text. Validate checks the local rule; it does not submit a request. The callback readout records changes from the field.',
      ],
      blocks: [
        DocTable(
          headers: ['Behavior', 'NibInput', 'NibTextarea'],
          rows: [
            ['Lines', 'Exactly one', 'minLines: 3; maxLines: null by default'],
            [
              'Length limit',
              'maxLength: null; no built-in counter',
              'maxLength: null; showCounter: false',
            ],
            [
              'Extra content',
              'prefixIcon, suffixIcon, clearable',
              'Helper/error message and optional counter',
            ],
            [
              'Keyboard setup',
              'keyboardType, textInputAction, onSubmitted, obscureText',
              'Multiline editing; no onSubmitted constructor argument',
            ],
          ],
        ),
      ],
    ),
    DocSection(
      id: 'validation',
      heading: 'Validation and submitted values',
      paragraphs: [
        'Put the field inside Form and call FormState.validate() before accepting its value. A NibValidator receives String? and returns null for success or a message for failure. NibValidators.compose runs checks in order and returns the first error. Format checks such as email accept empty values, so combine them with required() when the field is mandatory.',
        'autovalidateMode defaults to AutovalidateMode.onUserInteraction. Use disabled to wait for an explicit validation attempt, always to check on mount, or onUnfocus to check when the user leaves the field. Calling Form.save() invokes onSaved; call validate() yourself first. Save is not a substitute for validation.',
        'errorText is an explicit error supplied by your application, for example after an asynchronous check. It takes precedence over validator output and replaces helperText. Clear an old application error when it is no longer relevant; the widget cannot decide when a server result has become stale.',
      ],
      code: '''final formKey = GlobalKey<FormState>();

Form(
  key: formKey,
  child: NibInput(
    label: 'Email',
    validator: NibValidators.compose([
      NibValidators.required(),
      NibValidators.email(),
    ]),
    onSaved: (value) { /* Use value after validation succeeds. */ },
  ),
);

// Inside a submit callback:
if (formKey.currentState!.validate()) {
  formKey.currentState!.save();
}''',
      api: [
        DocApiEntry(
          name: 'validator',
          type: 'NibValidator?',
          defaultValue: 'null',
          description: 'String? Function(String?): null means valid; a message means invalid.',
        ),
        DocApiEntry(
          name: 'errorText',
          type: 'String?',
          defaultValue: 'null',
          description:
              'Forces the displayed error and overrides the validator error.',
        ),
        DocApiEntry(
          name: 'autovalidateMode',
          type: 'AutovalidateMode',
          defaultValue: 'onUserInteraction',
          description:
              'Controls automatic checks; Form.validate() checks explicitly.',
        ),
        DocApiEntry(
          name: 'onSaved / onReset',
          type: 'FormFieldSetter<String>? / VoidCallback?',
          defaultValue: 'null',
          description: 'Callbacks from Form.save() and Form.reset(). Reset restores the configured initial text.',
        ),
      ],
    ),
    DocSection(
      id: 'state-and-controllers',
      heading: 'Own text without losing the selection',
      paragraphs: [
        'For an uncontrolled field, supply initialValue once and read edits through onChanged or onSaved. The field creates and disposes its own controller. For programmatic editing or reading the current selection, create a TextEditingController in State, pass it as controller, and dispose it when that State is removed. controller and initialValue are mutually exclusive; passing both asserts.',
        'Keep the controller outside build. Replacing it on every rebuild erases the editing session and can move the cursor or cancel an input-method composition. The example only assigns controller.value when Current text changes. Changes to animation, radius, or disabled state retain the existing controller, selection, and composing range.',
        'An external controller text change updates the field value, validation state, and footer or clear affordance. The local candidate also emits onChanged once for that text change. Moving the selection without changing text does not emit a text callback. This controller synchronization repair belongs to the current local 0.2.2 candidate; do not assume it is in an older hosted version.',
        'Changing from an external controller to an internally owned one retains the previous editing value. Replacing one external controller with another adopts the new controller’s text and selection. The field removes its listeners when it is disposed; it does not dispose a controller or FocusNode you supplied.',
      ],
      code: '''class NameField extends StatefulWidget {
  const NameField({super.key});
  @override
  State<NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<NameField> {
  final name = TextEditingController(text: 'Ada');

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => NibInput(
    controller: name,
    label: 'Name',
    clearable: true,
  );
}''',
      api: [
        DocApiEntry(
          name: 'controller',
          type: 'TextEditingController?',
          defaultValue: 'null',
          description: 'Caller-owned when supplied; otherwise the field creates its own.',
        ),
        DocApiEntry(
          name: 'initialValue',
          type: 'String?',
          defaultValue: 'null',
          description: 'Seeds an internal controller. Cannot be combined with controller.',
        ),
        DocApiEntry(
          name: 'onChanged',
          type: 'ValueChanged<String>?',
          defaultValue: 'null',
          description:
              'Receives changed text. Selection-only changes are ignored.',
        ),
        DocApiEntry(
          name: 'focusNode',
          type: 'FocusNode?',
          defaultValue: 'null',
          description:
              'Caller-owned when supplied. autofocus defaults to false.',
        ),
      ],
    ),
    DocSection(
      id: 'length-and-lines',
      heading: 'Bound text and multiline growth',
      paragraphs: [
        'maxLength limits user input; it does not rewrite text that your application assigns directly to a controller. If external data must obey the same bound, validate it too. This example combines the input limit with NibValidators.maxLength so pasting or assigning an oversized configured value cannot silently pass the local rule.',
        'NibTextarea starts at minLines: 3 and grows without a height ceiling when maxLines is null. Set both limits in a constrained preview: minLines: 3, maxLines: 5 grows to five lines and then scrolls internally. maxLines must be at least minLines. showCounter defaults to false and can display the current count with or without a maximum.',
        'NibInput applies your inputFormatters before its LengthLimitingTextInputFormatter. It does not add a counter, so describe the limit in helperText when it matters. NibTextarea exposes no inputFormatters argument in this revision. The current footer counter uses Dart String.length; complex emoji can occupy more than one code unit. Do not describe that counter as a grapheme count.',
      ],
      code: '''NibTextarea(
  label: 'Message',
  minLines: 3,
  maxLines: 5,
  maxLength: 280,
  showCounter: true,
  helperText: 'Up to 280 characters.',
  validator: NibValidators.required('Enter a message.'),
)''',
    ),
    DocSection(
      id: 'theme-and-motion',
      heading: 'Customize the field and its feedback',
      paragraphs: [
        'Both fields read NibTheme from the inherited ThemeData. The example host installs the Ember extension so text, field fill, borders, disabled fill, errors, and focus rings belong to the same palette. Supply borderRadius, padding, minHeight, or the individual style arguments to override one field. Null values keep the theme or component default.',
        'borderColor overrides the ordinary and error border color, so setting it can remove the red error border. Keep the error message visible and test your override in error and focused states. backgroundColor also overrides the disabled fill. TextStyle overrides are merged with the default style; setting a size does not require copying every theme color.',
        'animated defaults to false and creates no NibMotion for the footer. Set animated: true to fade and move changed helper/error text by four logical pixels. transition accepts a NibTransition; the default timing is 150 milliseconds. The field itself does not slide or grow because this flag is enabled.',
      ],
      api: [
        DocApiEntry(
          name: 'disabled',
          type: 'bool',
          defaultValue: 'false',
          description: 'Disables typing; fills the field with NibTheme.muted unless backgroundColor overrides it.',
        ),
        DocApiEntry(
          name: 'animated / transition',
          type: 'bool / NibTransition?',
          defaultValue: 'false / null',
          description:
              'Opt-in helper/error animation; default duration 150 ms.',
        ),
        DocApiEntry(
          name: 'borderRadius / borderWidth',
          type: 'BorderRadius? / double?',
          defaultValue: 'null / null',
          description:
              'Defaults to NibTheme.radiusDefault and a 1-pixel border.',
        ),
        DocApiEntry(
          name: 'padding',
          type: 'EdgeInsetsGeometry?',
          defaultValue: 'null',
          description: 'Input: horizontal 12, vertical 12. Textarea: horizontal 12, vertical 10.',
        ),
        DocApiEntry(
          name: 'labelSpacing / footerSpacing',
          type: 'double? / double?',
          defaultValue: 'null / null',
          description: 'Each defaults to 6 logical pixels.',
        ),
      ],
    ),
    DocSection(
      id: 'accessibility',
      heading: 'Labels, focus, and feedback',
      paragraphs: [
        'Give the field a persistent label instead of relying only on a placeholder that disappears during editing. Test the resulting semantics tree in your host: a visually adjacent label is not evidence that a screen reader announces it as the editable field’s accessible name. Error text should explain how to recover, and color should not be its only signal.',
        'The native TextField supports keyboard editing and selection. The example provides a labeled Clear field button in addition to NibInput’s compact clear icon; it returns focus to the input. Validate and Clear field are disabled when the field is disabled. The validation result is a live region, and disabling footer animation leaves every instruction and result available.',
        'These examples are checked with Flutter widget tests, including narrow widths and larger text. A real screen-reader and physical-device pass remains separate from those checks.',
      ],
    ),
    DocSection(
      id: 'troubleshooting',
      heading: 'When the field behaves unexpectedly',
      paragraphs: [
        'The cursor jumps after a setting changes: look for a new controller or an unconditional controller.text assignment in build. Keep the controller in State and assign a new TextEditingValue only when you intend to replace the text.',
        'An empty optional email fails: check whether required() was added intentionally. email() alone permits empty input. A validator never appears: verify that you edited the field or called validate() under the selected autovalidateMode. An old error remains despite valid text: inspect errorText, which overrides the validator.',
        'The multiline preview grows beyond its panel: provide maxLines and a scrollable host. A programmatic value exceeds maxLength: input formatters constrain editing, not arbitrary controller assignments; validate external data. The counter differs from a human-perceived character count: the current counter counts UTF-16 code units.',
      ],
    ),
  ],
  limitations: [
    'Local candidate 0.2.2 includes controller synchronization and listener cleanup repairs; hosted older versions may differ.',
    'NibTextarea counter uses String.length (UTF-16 code units), not a grapheme count.',
    'Widget tests do not establish physical-device or screen-reader behavior.',
  ],
);
