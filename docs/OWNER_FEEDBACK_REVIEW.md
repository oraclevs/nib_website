# Website owner feedback — November 3, 2026

This pass addresses the preview review: water status, repeated starter demos,
and invisible off-state switches. The owner approved publication afterward; see
[the production deployment record](PRODUCTION_DEPLOYMENT_2026-11-03.md).
The verification below records the preview review before publication.

## Changes

- Introduction and Installation have no live demo, preview controls, or
  misleading “Live example” table-of-contents item. Their guide routes remain.
- Start with motion demonstrates a finite, staggered entrance. Your first
  animation demonstrates Save/Undo with a spring-driven bookmark. Migration
  uses the controller exercise (start, stop and immediate set), matching its
  discussion of controller ownership. Minimal and full exports follow those
  examples.
- Material switches in Motion docs and playground controls now use the existing
  NibSwitch. The shared control uses the site's existing logo PNG, a contrasting
  thumb outline in both states, and NibMotion thumb movement. Keyboard input,
  disabled state and reduced motion remain supported. Component playground
  inspectors, the form demo and Switch variants use the same branding.
- The logo is embedded in exported source so full examples need no network
  request or additional image asset declaration. The component's animation
  inspector can still deliberately turn animation off.
- Water is documented as a stable public API. Sampling boundaries, fallback
  status, input geometry and GPU-budget limitations remain. This changes no
  renderer, API signature, default, dependency or package version.

## Package changes

NibMotion PR #6 contains the source-comment, README, current guide and maintainer
wording changes at `115644c`. PR #5's candidate commit remains
`4fed11502295a3d43088eb9783bf5b98463a3355`; only its PR description now points to
the status correction in #6. NibComponents PR #3 makes the matching two-line
README/class-documentation correction at `37c04fe`.

The website still runs against the verified published 0.3.5 implementation.
Its API generator applies three explicit current-documentation opening-line
corrections for NibWaterSurface, NibWaterQuality and NibWaterGlass. It preserves
all generated signatures, members and limitations. Published archive hashes
remain enforced; the archived 0.3.5 comments and existing pub.dev pages cannot
be rewritten by this change.

## Preview

[Open the updated preview](https://nib-website-43ry0qwed-dentonmike888-gmailcoms-projects.vercel.app/docs/motion/getting-started).
Vercel preview access may require the owner account; the task includes a tested
share link valid through November 4. Local access is also available at
http://127.0.0.1:8125/docs/motion/getting-started while the artifact server runs.
Restart it with `python3 tool/serve_artifact.py --port 8125` from this directory.

Preview deployment: `dpl_BBisS8t3XTwvYDDwoLRViCct3LPy`, READY, preview target.
Production was rechecked after the upload and still resolves to
`dpl_6DES9YBHeZkX6LmZC6nUAozcdmWg`. No production alias moved.

## Verification

Evidence is in `docs/evidence/2026-11-03-owner-feedback/`. Early failing runs are
retained rather than presented as passing runs.

- Fatal-info analysis passes on the final website source. Changed Dart files
  were formatted. API generation, content export, published-source hashes and
  documentation validation pass.
- The broad website test run passed 399 tests and found one exported-source
  import issue. That issue was corrected and its compile/mount test rerun
  successfully. The new copy-source handoff test also passes. After the final
  sidebar correction, all 11 focused starter, reference and switch tests pass.
- The three Python documentation-validator regression tests pass. The final
  release web build produced JavaScript and WebAssembly artifacts. Static
  validation passes for all 208 routes.
- All 90 deployed HTTP checks pass, including 35 Motion HTML guides, their
  Markdown counterparts, starter playgrounds, Switch and Skeleton playgrounds,
  artifacts, metadata, redirects and the expected 404.
- Real-browser checks used desktop 1440 × 900 and mobile 390 × 844 viewports.
  Introduction and Installation show reading/install content without a cloned
  preview. Entrance replay and Save/Undo work; the cards fit the phone width.
  Migration Start/Stop/Set produces the expected state changes.
- The accessibility demo supports reduced motion and its completion action.
  The sidebar and Skeleton inspector display the outlined Nib logo when off;
  Skeleton toggles correctly by pointer and Enter. The shared-control tests
  cover rapid reversals, disabled state, thumb contrast and reduced motion.
- The deployed water guide reports `Refractive · layerSampler`; Disturb visibly
  changes the sampled artwork. Pause changes to Resume and disables Disturb.
  No browser console errors were recorded during these checks.

The source snapshot and unified patch preserve a reviewable website change set
because this website directory has no Git repository.

The package documentation change passed fatal-info analysis and all 61 water
tests. Both committed package dry runs reported zero warnings. The Components
change passed local analysis and formatting. Hosted CI passes for all five
NibMotion jobs on `115644c` and the Components analyze/test/archive job on
`37c04fe`. Components runtime tests were not rerun locally because only two
prose lines changed. No package publication occurred.

Package review links: [NibMotion #6](https://github.com/oraclevs/nib_motion/pull/6)
and [NibComponents #3](https://github.com/oraclevs/nib_components/pull/3).

## Owner review

Review Introduction and Installation for a clear reading path. Then replay the
entrance, rapidly alternate Save/Undo, and try the migration controller controls.
On Accessibility, toggle reduced motion and complete the task. In a Components
playground such as Skeleton, check both states of the inspector switches. Check
the Switch guide's image, custom, disabled and loading variants. Open Water and
Water Lab to review the stable wording alongside the actual renderer status.

Promoting the website preview, merging package changes and approving media
remain separate owner decisions. This pass does not approve promotional footage
or claim Safari, Firefox, physical-device or sustained GPU parity.
