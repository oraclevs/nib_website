# Documentation source and release checks

The editable website is `WebsiteEmberLiving`, a Flutter application with static
HTML and Markdown generated from the same Dart content models. `WebsiteNib` is
the retired Next.js source. Do not deploy that directory. The Vercel framework
label does not describe the prebuilt artifact.

## Sources of truth

- `lib/content/`: authored learning material. Preserve explanations, website
  controls, navigation and examples when updating package documentation.
- `lib/content/motion_capabilities.dart`: the reviewed public version and the
  separate pending version. Currently 0.3.5 and 0.3.6 respectively.
- `tool/motion_release_contract.json`: SHA-256 hashes of all 113 `lib/` files
  from the verified pub.dev 0.3.5 archive. This prevents a local candidate from
  silently changing what the website demonstrates. The archive hash is recorded.
- `assets/reference/public_api.json`: generated declarations and signatures.
  Regenerate from the resolved sibling sources, then review the diff. Generation
  does not certify every comment; the existing text/reveal corrections in
  `ApiReferencePanel` remain necessary.
- `lib/docs/doc_example_catalog.dart`: real widgets and their exact source assets.
  `allRecipes` creates their playground routes. Minimal exports have their own
  authoring input, formatter and compilation tests.
- `tool/export_site_content_test.dart`: exports content and navigation to JSON.
  `build_seo.py` uses that JSON for HTML, Markdown, metadata and reading resources.

## Updating a release

1. Verify the published archive and compare its code with the reviewed checkout.
   Do not infer publication from a version string, tag or open pull request.
2. Review implementation changes, tests, package docs and website prose separately.
   A package Markdown filename matching a guide ID is not evidence of parity.
3. Update release constants and the source hash contract only after that review.
   Keep a pending release explicitly separate. Update API mappings for new names.
4. Update actual examples and both full and minimal exported Dart where affected.
5. Run the check entry point below. Do not automatically import package Markdown
   over the website's lesson models.
6. Build a preview, verify its routes and interactions, then obtain production
   approval. No script in the check pipeline deploys or publishes anything.

## Reproducible checks

The website requires Dart 3.13.3 or later. This review uses Flutter 3.47.8 /
Dart 3.13.7. NibMotion's own package floor remains Flutter 3.29; the website's
SDK requirement does not raise the library's minimum.

Sibling checkouts must be present under the parent Nib directory:

| Checkout | Reviewed revision |
| --- | --- |
| `MotionNib/motion` | `166891c762f2579e470b6bb25c564b0ac95ad407` (the local `d585ec0` implementation matches its hosted 0.3.5 archive) |
| `ComponetsNib/nib_components` | `e4719a210086d1b37a51d1b62ea9ee85c2ab5cfa` |
| `GenUINib` | `806f29d8aa02d076765866145a304beaab09d26f` (private, unpublished) |

With Flutter and Dart on PATH and Pillow installed in the build Python:

```sh
tool/check_docs.sh
```

On this workstation:

```sh
export PATH=/home/occ/Projects/Nib/.release-sdks/flutter-3.47.8/flutter/bin:$PATH
export SEO_PYTHON=/home/occ/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3
tool/check_docs.sh
python3 tool/serve_artifact.py --port 8125
```

The gate checks analysis, widget interactions, copied consumer examples, complete
snippet compilation, API generation drift, every guide in navigation, internal
links/anchors, public symbol names, example source assets, published source
hashes, the JS/Wasm build, redirect targets, exact sitemap coverage and static
content parity. Contextual build-method fragments still require their lesson's
host; they are not falsely counted as standalone apps.

`.github/workflows/documentation.yml` prepares the same checks for a future
website repository. It checks out the pinned sibling sources and requires a
read-only `NIB_GENUI_READ_TOKEN` for the private GenUI source. **This website
currently has no Git repository or remote: hosted CI is not activated.** The
local entry point is usable now. Connecting a repository and configuring that
secret is an owner decision; no workflow run is claimed here.

## Metadata and publication

`nib_ember_living` is the internal Dart package name used by imports and Flutter's
`version.json`. It identifies this implementation. Public titles, manifest,
icons and metadata use Nib/NibMotion. Renaming the Dart package would add churn
without changing the public brand, so the internal name is retained.

Production canonical URLs stay `https://www.nibmotion.xyz`. Preview responses
carry `noindex, nofollow`. Existing redirects remain. The new gallery is linked
to its review branch with an explicit candidate label. Promotional recordings
are not embedded because final owner approval remains pending.

## Water documentation policy — November 3, 2026

The maintainer confirmed stable public API status for water. The pinned hosted
0.3.5 source still contains three older class-description openings across
Motion and Components. `generate_api_reference.dart` explicitly updates those
openings in the website index. It does not alter signatures, members, renderer
limits or the source hash contract. The matching source documentation changes
are reviewed in Motion PR #6 and Components PR #3; published archives remain
immutable. `starter_guides_test.dart` checks the current water presentation.
