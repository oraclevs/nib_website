# Canonical documentation verification — November 3, 2026

The preview imports canonical source
`e93e14f5fd0aa47a8b900f6738e40bb766bcc6d1` from `oraclevs/nib_motion`.
It displays **nib_motion 0.3.5 · stable · e93e14f**. The package release candidate
remains 0.3.6 and is not published.

Preview: https://nib-website-gpkmdrogh-dentonmike888-gmailcoms-projects.vercel.app
(Vercel authentication required unless using the temporary owner review link.)
Deployment: `dpl_ATiWx2K96LqSZpwSNEYVLWLBB9tY`, target preview.

## Executed checks

- `tool/check_docs.sh`: passed with Flutter 3.47.8 / Dart 3.13.7.
- Flutter analyzer: no issues. All **402 website tests** passed, followed by the
  content-export test. Tests include desktop/mobile provenance, guide search,
  navigation, examples, reduced motion and standalone consumer compilation.
- **11 importer/resolver tests** and **3 documentation contract tests** passed.
- **35 Motion guides / 220 sections** imported. All original content fields
  match the pre-migration model except the deliberate keyboard-testing sentence
  in the first-animation guide. There are **89 total website guides**.
- Generated drift, API index drift, route/source coverage, links/anchors,
  example assets, public API references and all **113 published implementation
  file hashes** passed.
- JS/Wasm release build and static assembly passed: **208 routes**, full
  guide/code parity, redirects, metadata, sitemap, images and artifact hashes.
- **91 deployed HTTP checks** passed, including all Motion guide HTML/Markdown
  routes, provenance, playgrounds, redirects, 404, JS and Wasm. Three initial
  request failures passed targeted retries with exact artifact hashes.
- Actionlint 1.7.12 passed for the delivery workflow. Vercel CLI 59.1.4 returned
  structured JSON; the deploy job now explicitly requests and parses that
  response format.

## Source-to-preview proof

The canonical first-animation guide adds: “Try the same Save and Undo sequence
with a keyboard before tuning the spring.” The normal import command retrieved
that content from GitHub at the pinned SHA; no local source shortcut was used.

[Hosted run 41606100697](https://github.com/oraclevs/nib_website/actions/runs/41606100697)
passed public validation and preparation. Its three generated outputs match
the locally built sources byte for byte. The same checked-in build gate produced
the preview, uploaded with the existing local Vercel login. The new sentence
appears in both Flutter and static HTML and is found by website search.

Hosted private build/deploy jobs were **skipped**, as requested while credentials
remain pending. This proves hosted import parity plus a real local build and
preview deployment. It does not claim a completed credential-backed hosted
build/deploy run. Activation steps are in [DOCS_SYNC.md](DOCS_SYNC.md).

## Browser review

The deployed preview was exercised in the in-app Chromium browser at
**1440 × 1000** and **390 × 844**. Checked the source/version header, edit link,
new prose, search result, mobile layout, source panel, Save/Undo interaction,
keyboard activation, reduced-motion state, guide-to-playground navigation,
back/forward and direct refresh. The narrow source header and edit action fit
without overflow. The temporary viewport override was reset.

Copy controls displayed their success state. The browser tool returned an
empty clipboard read, so clipboard payload verification is not claimed here;
consumer tests validate the exported code. The application emitted no observed
console errors. Skwasm reported its existing single-threaded fallback because
cross-origin isolation is not enabled. Earlier Vercel-login FedCM messages were
outside the application. No extra browser engine or physical phone was tested.

## Review before activation

1. Open `/docs/motion/first-animation`; confirm the new keyboard sentence and
   stable version/source label. Use **Edit this page on GitHub** to reach the
   candidate source branch.
2. Search for “keyboard before tuning”; the first-animation guide should appear.
3. Try Save/Undo, source/copy controls and Open playground at desktop and phone
   widths. Confirm the other Motion, Components and GenUI navigation is intact.
4. Review website PR #1 and the final Motion candidate separately. Install the
   pending environment credentials and run a hosted preview before enabling
   production sync.

Production remains the approved deployment
`dpl_5jiSv3LcwzQbzavB1t5Dy2RTGoaj` at https://www.nibmotion.xyz.
No production promotion, release tag or package publication occurred.
