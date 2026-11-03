# NibMotion website documentation review — 2026-11-03

Follow-up: [owner feedback changes](OWNER_FEEDBACK_REVIEW.md) supersede the original starter-demo mapping and water designation recorded below.

The existing Flutter website now introduces the full motion model, exposes all
35 Motion guides, and separates published 0.3.5 from the pending 0.3.6 gallery.
The original 32 guide URLs remain. Three focused guides and three real examples
fill the water, tuning and migration gaps. Production has not been deployed.

The [coverage matrix](MOTION_DOCUMENTATION_MATRIX.md) records all 35 guides,
implementation files, relevant package tests, package documentation, live
examples, limitations and recommended follow-up. It distinguishes reference
coverage from interactive coverage and device verification.

## Source and production audit

The editable source is `WebsiteEmberLiving`. `DEPLOYMENT.md`, its linked Vercel
project and the generated route manifest agree. `WebsiteNib` is the retired
Next.js implementation. Vercel's `framework: nextjs` setting is not evidence of
the deployed architecture: this project uploads a prebuilt Flutter JS/Wasm
application plus static HTML, Markdown, assets and routing configuration.

Production inspection identified project `prj_LP8bODFk3QYDXwYYBoHEpsTouQZd`,
`nib-website`, deployment `dpl_6DES9YBHeZkX6LmZC6nUAozcdmWg`, READY, from
October 28. All 32 production Motion Markdown URLs returned HTTP 200. Every
original guide paragraph matched the pre-edit local content export. The audit
compared their actual contents, not their filenames.

The published 0.3.5 archive was checked through pub.dev's package API. Its
SHA-256 is `65a6c7f94cc2ad3d58efc7757a343e082a2826e983dcb4f2cb18356340bf37af`.
All 113 library files match the local resolved Motion implementation byte for
byte. The package docs and tests were inspected separately; their relevant
paths appear in the matrix. This website pass did not rerun the package's
entire standalone test suite. It ran the website and isolated consumer suites.

The 0.3.6 showcase candidate at `ade956142b6a92ee74ef364b5915d1e5f790e00c`
has the same runtime implementation; its library differences are timeline
comments. Its 29-example gallery is linked with an explicit review label.
No package source, release identifier, Git tag or publication changed.

## Before and after

| Area | Production before this pass | Review preview |
| --- | --- | --- |
| First impression | “Motion that follows the interaction.” Three broad feature bullets. | “One motion model. From a press to a whole interface.” Six capability groups, each with a use case and working guide links. |
| Introduction | Immediately starts with a colored box and paint-versus-layout explanation. | Explains shared targets, motion values and drivers first, then keeps that useful first-widget tutorial. |
| Discovery | 32 Motion lessons grouped by broad learning level; water and tuning were hard to find. | 35 lessons grouped by task: Start here, States and timing, Physics and input, Layout and presence, Scroll and orchestration, Text and effects, Tools and reference. |
| Published version | Shader prose names 0.3.3 and says water needs the candidate; several geometry passages use ambiguous candidate wording. | Explicit published 0.3.5 and pending 0.3.6; water is published and now designated stable; renderer limits remain. |
| Public API | Generated Motion index held 139 declarations. | Regenerated index and topics cover all 153 current public declarations, with 14 water/bubble types in the water guide. |
| Practical depth | Existing extensive playground and copy-code system. No focused water, tuner or shared handoff example. | Three additional examples use the existing preview, reset, source and standalone-export machinery. |
| Infrastructure | 201 pages, 86 guides, 74 recipes. | 207 pages, 89 guides, 77 recipes; same public routes, redirects, static reader, metadata and search architecture. |
| Drift protection | Separate authored website and package prose could diverge silently. | Source hash contract, API generation check, content validation, consumer code checks, exact sitemap and redirect checks. |

The six public-facing groups are Declarative motion; Physics and interactive
gestures; Layout and presence; Scroll and orchestration; Visual effects and
expressive interfaces; Developer tooling, performance and accessibility.
NibComponents and the unpublished NibGenUI preview retain separate identities.

## Confirmed findings and corrections

| Severity | Finding | Resolution |
| --- | --- | --- |
| P1 | Shader guide describes 0.3.3 and candidate-only water although the verified 0.3.5 archive exports water. | Corrected both shader passages; added a dedicated water guide with renderer status, sampling boundary, resource ownership, quality budgets and interaction limits. |
| P1 | Generated API index missed current public water declarations. | Regenerated from actual source; mapped every Motion declaration. Also restored the existing exported `NibWaterGlass` Components reference. |
| P2 | Layout, drag and physics passages use candidate wording for published behavior. | Name 0.3.5 explicitly. Final deployed-content inspection caught and corrected a second drag-velocity sentence. |
| P2 | Introductory prose names nonexistent `NibKeyframes`. | Corrected to `NibKeyframe` values; public-name validator catches unresolved names. |
| P2 | Opaque shimmer child can cover the painted sweep. | Use a transparent placeholder and explain the paint order. No runtime imitation or engine workaround. |
| P2 | Custom fragment-shader setup lacked a practical contract. | Added asset/uniform ordering, child-sampling renderer requirement, failure handling and reduced-motion responsibilities. |
| P2 | Complete standalone guide listings were not part of the shared check command. | Added a test that extracts and analyzes all nine complete listings against resolved APIs. Existing exported-app compile/mount tests remain. |
| P2 | External DocLink buttons were sent to the internal router. | HTTPS links now open through the browser with `noopener,noreferrer`; internal links keep the existing routing. |
| P2 | Components `catalog` guide was missing from its learning path. | Added it; navigation coverage no longer exempts that route. |
| P3 | `version.json` uses `nib_ember_living`. | Intentional internal Dart package identity, retained. Public brand, titles and metadata remain Nib/NibMotion. |

## Content and examples delivered

New routes:

- `/docs/motion/water`: sampling policies, honest `onStatus` reporting,
  controller disposal, finite bounds, quality versus total GPU memory, pointer
  ownership, foreground semantics and renderer limits.
- `/docs/motion/debugging`: real `NibSpringTuner`, debugging/registry/performance
  tools, replay and timeline-scrubbing responsibilities.
- `/docs/motion/migration`: map Flutter state and existing animation approaches
  to targets, values, drivers, layout and presence; preserve application logic;
  validate interruption, reduced motion and disposal.

Corrected or expanded: package overview, introduction, installation, keyframes,
gestures, layout animations, layout/presence, physics, drag recipe, shaders,
platform limits, API guidance and troubleshooting. Other useful lessons remain.
No guide was removed or moved. Tutorials, API panels and runnable examples stay
separate rather than duplicating full reference documentation in every lesson.

`MotionWaterExample` renders a real bounded Flutter background, reports the
selected water path, and provides Disturb, Pause/Resume and Reset.
`MotionTunerExample` embeds the package's real spring tuner.
`MotionSharedLayoutExample` detaches and mounts two keyed placements sharing a
layout ID in one scope, with an Expand/Return action. Both full and minimal
source exports were added to the existing catalog and compilation checks.

Promotional recordings remain unembedded pending owner approval.

## Synchronization and validation

[DOCS_SYNC.md](DOCS_SYNC.md) documents the source boundary and reproducible
`tool/check_docs.sh` gate. Website-specific prose is not overwritten with GitHub
Markdown. The release contract checks the version and every hosted library
hash; the generated API check compares source declarations; content validation
checks navigation, links/anchors, public names and example assets. SEO checks
cover redirects, exact sitemap coverage, canonical URLs, metadata, static
content/code parity and preview indexing rules.

The workflow in `.github/workflows/documentation.yml` prepares these checks for
a future website repository, using pinned sibling revisions. This source folder
has no Git repository or remote, so hosted CI is **not active**. It also needs a
read-only token for the private GenUI checkout. No hosted CI run is claimed.

Validation uses Flutter 3.47.8 / Dart 3.13.7, appropriate to the website's Dart
3.13.3 floor. The library's Flutter 3.29 floor is not changed by this choice.
The full test suite, analyzer, API drift check, three validator regression
tests, JS/Wasm build and 207-route static verifier run in the final evidence
log. The full suite includes exported consumer compilation and mounting, narrow
layouts, search/navigation, API panels, source exports and existing Components
and GenUI coverage. Existing assertions were updated for added routes/examples
or the actual default water configuration, not removed to hide failures.

## Actual browser observations

Tested in the Codex Chromium browser at 1440×900 and 390×844. This is browser
verification, not physical-phone or assistive-technology certification.

| Check | Observed result |
| --- | --- |
| Loading and reader | Static guide appears while Flutter starts; interactive view replaces it. Text reader remains available. |
| Desktop overview | Six capability groups, explicit 0.3.5 status and guide actions render in the existing Ember design. |
| Mobile documentation | Compact navigation and contents drawer work; layout and water pages wrap without visible horizontal overflow. |
| Search | Searching “water” finds Water surfaces and related shader/glass guides; selection opens the guide. |
| History and refresh | Water → layout → browser Back/Forward and direct refresh return to the correct guide. |
| Springs | Replay, preset retargeting and reduced-motion controls respond. |
| Dragging | Real pointer drag changes the axes example from `x 0, y 0` to `x 56, y 0`; Center and the keyboard alternative remain usable. |
| Shared layout | Expand/Return works on a narrow viewport and through Enter-key activation; repeated changes return to the compact state. |
| Spring tuner | Switch to physical mode, replay and drag stiffness: displayed configuration changes from 120 to 298.7. |
| Glass | Keyboard adjustment changes blur from 4.0 to 4.5. The preview explicitly reports the frosted fallback. Reduced motion disables the tuning control. |
| Water | Local and final deployed browsers report `Refractive · layerSampler`; Disturb, Pause/Resume and Reset respond. This status is not a GPU-completion or performance measurement. |
| External documentation | The water API button opens the versioned pub.dev `NibWaterSurface` page in a separate tab. |
| Copy code | The UI reports “Copied”; generated payloads pass consumer tests. The in-app browser's virtual clipboard returned no payload, so OS clipboard transfer was not independently confirmed. |
| Console | No application errors in inspected interactions. Skwasm warns that missing cross-origin isolation keeps it single-threaded. |

For offscreen Flutter sidebar controls, reveal the entry before automation
clicks it; immediate auto-scroll/click can race the semantics geometry. Visible
entries and mobile drawer selection were verified.

## Known limitations and owner decisions

- Existing package issues remain visible in troubleshooting: repeated gradient
  reduced-motion toggles can assert; path pause/play resets the clock; shimmer
  can be covered by an opaque child. No package engine was changed here.
- The native package spring tuner's custom sliders are pointer-driven and do
  not expose normal slider semantics in this browser. Its buttons are labeled;
  the Springs lesson provides keyboard-operable alternatives. Improving the
  package tuner itself is separate work.
- Browser glass used a frosted fallback. No claim of glass shader refraction,
  physical GPU parity, frame-rate performance or full-screen-reader certification
  is made. Safari, Firefox, physical touch and the library’s minimum Flutter 3.29 SDK were not run here.
- Multi-threaded Wasm would need a deliberate cross-origin-isolation review;
  headers were not changed merely to suppress the warning.
- Some specialized APIs have reference and package-test coverage but no dedicated
  website exercise. The matrix identifies typed/computed values, page/sliver
  progress, modal/shared-source routes and custom shader failure paths.
- Approve the docs preview before any production deployment. Approve gallery
  media separately. Connecting a website Git repository and CI secret remains
  an owner decision.

## Review entry points

The local artifact remains available at http://127.0.0.1:8125/packages/motion.
Launch it from this source folder with:

```sh
python3 tool/serve_artifact.py --port 8125
```

Start with the Motion overview, then Introduction, Water, Debugging, Migration,
Layout animations and Shaders. Try mobile navigation, search, reduced motion,
copy actions and the linked playgrounds. Production approval is not implied by
this preview or by passing tests.

The before-edit backup and focused source diff live in
`docs/evidence/2026-11-03-motion-docs/`; no Git history was fabricated.


The review preview is [nib-website-gh9jt9stq](https://nib-website-gh9jt9stq-dentonmike888-gmailcoms-projects.vercel.app/packages/motion). Vercel account access or the temporary review link supplied in the task is required. The temporary link expires on November 4; project protection remains enabled. The source folder has no Git remote, so the review includes a local source diff rather than a fabricated PR.

Skills applied: Humanizer for public prose, UI/UX Pro Max for the design review, the installed browser workflow, verification-before-completion, Caveman and Ponytail. No dedicated Flutter engineering skill was available in the installed skill catalog; implementation follows the actual package APIs and tests.

## Verification record

The complete website suite passed **394 tests**. Minimal exports cover all
77 recipes and compile/mount **64 distinct standalone programs**. Nine complete
guide listings pass static analysis; contextual fragments retain their lesson
host requirements. Three additional validator regression tests pass. The
analyzer reports no issues; 34 changed Dart files pass formatting.

The final HTTP review exercised **85 URLs**: all 35 Motion guides, their 35
Markdown equivalents, the three new playgrounds, the package overview, JS/Wasm
assets, robots/sitemap/LLM resources, a social image, a redirect and a real 404.
84 checks passed in the batch. The social-image request had a transport failure;
a targeted retry returned 200 with a valid PNG signature and the exact local
artifact hash. Vercel injects its review toolbar into the home HTML; comparison
removes only that exact known script before checking artifact parity.

Final preview deployment: `dpl_E3mKF3h9E5gxLDYXbLfVbiJVqLsy`, READY, preview
target, no production alias. Production still resolves to
`dpl_6DES9YBHeZkX6LmZC6nUAozcdmWg`.

Evidence:

- `evidence/2026-11-03-motion-docs/reproducible-checks.log`: final shared check command with an explicit SDK for subprocesses.
- `evidence/2026-11-03-motion-docs/final-format.log`: changed-source formatting.
- `evidence/2026-11-03-motion-docs/final-preview-http.json` and `final-preview-http-retry.json`: deployed response and artifact comparisons.
- `evidence/2026-11-03-motion-docs/final-preview-deploy.log`: deployment result.
- `evidence/2026-11-03-motion-docs/source-changes.patch`: focused source/config/test diff against the pre-edit backup; documentation reports are separate deliverables.
- `evidence/2026-11-03-motion-docs/production-routes.json` and `published-source-verification.json`: production and hosted-source audit.

The browser/app session restarted during an earlier verification attempt,
stopping local processes. Its incomplete log is retained as
`interrupted-checks.log`; it is not used as a passing result. The local server
was restored and the shared check command was restarted.

The restarted `tool/check_docs.sh` finished with exit code 0. The final JS/Wasm build passed, followed by all 207 static-route checks. The fresh build hashes match the deployed verification responses. [Machine-readable totals](evidence/2026-11-03-motion-docs/verification-summary.json) record the completed result.
