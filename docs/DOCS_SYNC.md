# Documentation source and delivery

The website source is [oraclevs/nib_website](https://github.com/oraclevs/nib_website),
in the local `WebsiteEmberLiving` directory. The guide-directory link below pins the reviewed migration; use a page’s edit link for the current authoring branch. It is a Flutter application with
static HTML and Markdown generated from the same content model. `WebsiteNib`
is the retired Next.js source; do not deploy it.

## Edit a Motion guide once

NibMotion owns the technical guides in
[`doc/guides/`](https://github.com/oraclevs/nib_motion/tree/e93e14f5fd0aa47a8b900f6738e40bb766bcc6d1/doc/guides).
Its `doc/website.json` lists all 35 guides, the documentation channel, supported
package version and runtime commit. The website-owned
[`tool/motion_docs_routes.json`](../tool/motion_docs_routes.json) maps these files
to the existing URLs and related recipes. Playground configuration stays in
`lib/docs/doc_example_catalog.dart`.

`tool/import_motion_docs.py` reads Markdown from a full Git SHA, converts it to
`lib/content/motion_guides.dart`, and writes `tool/motion_docs.lock.json` and
`assets/reference/motion_docs_source.json`. Generated Dart is committed for
review; edit the linked Markdown, never the generated guide. The four former
authored Dart guide files have been removed. Components and GenUI content,
navigation, rendering, marketing copy and interactive examples remain website-owned.

The importer accepts the bounded format documented in the package's
`doc/maintainers/documentation-sync.md`: paragraphs, stable heading anchors,
fenced code, notes, lists, tables and links. It does not execute Markdown,
HTML, JSX or code from the documentation repository. Unsupported block syntax,
missing mappings, version mismatches and generated drift fail the build. Sections follow paragraphs, lists/tables/links, API table, code, then note; out-of-order blocks are rejected.

Every Motion page displays its package version, channel and source SHA, with
an **Edit this page on GitHub** link. The editable branch is recorded separately from the immutable source SHA. Preview builds can use `--edit-ref` (or the workflow input) for a candidate branch; production always uses `main`. `/motion-docs-source.json` contains the
full SHA and individual source hashes. Search uses the generated guide bodies.

## Version policy

The stable guides describe published nib_motion **0.3.5**. The package candidate
is **0.3.6**, still unpublished. Documentation corrections for 0.3.5 can retain
that stable target. New APIs require an explicitly reviewed `next` source and
matching consumer contract; production rejects a `next` channel.

`tool/motion_release_contract.json` pins the runtime commit and SHA-256 hashes
of all 113 implementation files from the verified pub.dev 0.3.5 archive. A
version string alone cannot update stable docs. After publication, verify the
new archive, review API and example changes, then update the contract, runtime
checkout pin and package manifest together. Preview and consumer checks must
pass before enabling that version in production.

## One delivery workflow

`.github/workflows/documentation.yml` is the only website delivery workflow.

- Every pull request runs public importer tests and checks generated drift. It
  receives no private dependency or deployment secrets.
- A trusted manual run can import a reviewed full SHA for preview. Never pass an unreviewed pull-request SHA: consumer tests execute selected Dart snippets in the private build workspace, although the importer itself reads only data. An empty
  `source_commit` resolves canonical `main` once and imports that immutable SHA.
- After activation, a twice-hourly schedule compares canonical content hashes
  with the production provenance before building. Unrelated source commits
  do not redeploy. A canonical main without the manifest waits for candidate
  integration. Website main pushes build previews.
- Trusted builds check out pinned package sources, run the complete local gate,
  then upload a verified static artifact. A separate job deploys it with Vercel
  CLI 59.1.4 to the existing `nib-website` project and runs HTTP artifact checks.
- Production requires website `main`, canonical package `main`, stable docs,
  and the owner-enabled `PRODUCTION_SYNC_ENABLED` variable. Manual production
  runs must also select the production input. No workflow writes Git commits,
  creates package releases or triggers another workflow recursively.

### Activation is pending credentials

The owner chose to prepare the workflow and leave credentials pending.
`TRUSTED_BUILD_ENABLED` and `PRODUCTION_SYNC_ENABLED` remain unset. Public CI can
run; hosted private builds and deployments are skipped. Local authenticated
preview deployment is separate evidence, not a claim that hosted deployment ran.

When ready:

1. Review and merge the website PR. Review the final Motion candidate SHA
   separately; the production source must contain the canonical manifest.
2. Add a **read-only deploy key** to the private `oraclevs/nib_genui` repository.
   Save its private key as `NIB_GENUI_DEPLOY_KEY` in nib_website's `trusted-build`
   environment. No cross-repository write token is needed.
3. Save a project-scoped Vercel token as `VERCEL_TOKEN` in the website `preview`
   environment. The existing project is `prj_LP8bODFk3QYDXwYYBoHEpsTouQZd`, team
   `team_uLkGKaENnuPQXup2m6SleSHd`. Automated token creation returned HTTP 403;
   no token is stored in source. Do not paste credentials into an issue or chat.
4. Set repository variable `TRUSTED_BUILD_ENABLED=true`. Run Documentation
   delivery on main with a full source SHA and production unchecked. Inspect
   its build, deployment and HTTP verification jobs.
5. Only after preview approval, install `VERCEL_TOKEN` in the `production`
   environment and set `PRODUCTION_SYNC_ENABLED=true`. This enables scheduled
   stable documentation updates. Unset it to stop automatic production updates.

Environment branch policies allow `main`; the initial preview work also allows
`feat/canonical-motion-docs` in `trusted-build` and `preview`. Remove that
exception after integration. `production` accepts main only. The repository
rules require PR checks without requiring an unavailable second maintainer.

## Reproduce the same import and build locally

Use Flutter 3.47.8 / Dart 3.13.7, Python 3 and Pillow 11.3.0. The website SDK
requirement does not raise the package's Flutter 3.29 minimum. Clone these
sibling sources under one parent directory:

| Directory | Pinned revision |
| --- | --- |
| `WebsiteEmberLiving` | The website revision under review |
| `MotionNib/motion` | `166891c762f2579e470b6bb25c564b0ac95ad407` |
| `ComponetsNib/nib_components` | `e4719a210086d1b37a51d1b62ea9ee85c2ab5cfa` |
| `GenUINib` (private, unpublished) | `806f29d8aa02d076765866145a304beaab09d26f` |

From the website checkout, with Flutter and Dart on PATH:

```sh
python3 tool/prepare_docs_sync.py --commit FULL_40_CHARACTER_SHA
tool/check_docs.sh
python3 tool/serve_artifact.py --port 8125
```

`prepare_docs_sync.py` is the same resolver/import command used by hosted CI.
`--scheduled --production` compares only approved canonical main with deployed
hashes. No deployment happens in this script or `check_docs.sh`.

The gate checks analysis, widget interactions, copied consumer examples,
standalone Dart snippets, API extraction drift, all guide/navigation routes,
links and anchors, public symbols, source assets, published implementation
hashes, JS/Wasm compilation, redirects, sitemap and static content parity.
Contextual build-method fragments still require their lesson's host.

For this workstation, use the SDK in `.release-sdks/flutter-3.47.8/flutter` and
set `SEO_PYTHON` to the installed Python containing Pillow. Follow
[DEPLOYMENT.md](../DEPLOYMENT.md) for preview upload and rollback. New sync work
must not replace the approved November 3 production deployment without approval.

## Water API status

The maintainer confirmed stable public API status for water. The pinned hosted
0.3.5 source still contains three older class-description openings across
Motion and Components. `generate_api_reference.dart` corrects those openings
in the website index while preserving signatures, renderer limits and source
hashes. Source documentation changes are in Motion's candidate and Components
PR #3. Published archives remain immutable.
