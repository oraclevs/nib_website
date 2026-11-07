# Nib website

Editable Flutter source for https://www.nibmotion.xyz, with generated static documentation. The approved HTML reference is preserved at `design/reference/Nib_Ember_Living_Prototype.html`; it is not the delivered application.

## Run locally

From this directory:

```sh
/home/occ/DevTools/flutter/bin/flutter pub get
/home/occ/DevTools/flutter/bin/flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8123 --no-dds
```

Keep that terminal open. Press `r` to hot reload after edits. Press `R` for a
hot restart when a stateful widget's structure changes. The preview stays at
`http://127.0.0.1:8123/`.

If this environment cannot establish Flutter's debug WebSocket, build and serve a review copy:

```sh
/home/occ/DevTools/flutter/bin/flutter build web
python3 -m http.server 8123 --directory build/web
```

The website resolves Nib packages from sibling repositories. Its Motion guides and implementation checks still target the published 0.3.5 archive. NibMotion 0.3.6 is also published; update the release contract and verify its archive before treating the guides as 0.3.6 examples. GenUI remains unpublished. Production deployment requires owner approval.

## Checks

```sh
/home/occ/DevTools/flutter/bin/flutter analyze
/home/occ/DevTools/flutter/bin/flutter test
```

Font files are bundled with their licenses in `assets/licenses/`. The temporary review build includes `noindex, nofollow`; remove that restriction only as part of an approved launch and SEO verification.

## Components

Open `/components` for 31 component-family guides and two bottom-navigation
compositions. Input and textarea share one guide. Search accepts public API
names, including `NibSwitch`, `NibTextarea`, and the overlay helpers.

Cards show view-only previews. Open a card to use its real Flutter widget in
`/playground/components/<id>`, adjust settings, and copy the complete configured
example. **Read the guide** opens `/docs/components/<id>` in the shared docs
layout, with its API reference and lifecycle notes.

Website examples enable supported animations initially. The Switch preview
uses an original image thumb and a 320 ms NibMotion transition; its other thumb
variants remain available. The carousel loops through three bundled original
illustrations. Pause and reduced-motion controls remain available. Package
constructor defaults are documented separately and have not been changed.

Page-modal dialogs and sheets are intentional. Anchored menus use the preview's
nearest overlay. Each complete export includes its theme and fixture data;
carousel and switch images require no network request or extra asset setup.

The current source inventory and verification are in
[`docs/NIB_COMPONENTS_COVERAGE.md`](docs/NIB_COMPONENTS_COVERAGE.md) and
[`docs/WEBSITE_CORRECTION_REVIEW.md`](docs/WEBSITE_CORRECTION_REVIEW.md).
Evidence copies under `docs/evidence/` are excluded from application analysis;
the API extractor runs with the separate dependency configuration documented in
[`tool/api_reference/README.md`](tool/api_reference/README.md).

## Motion documentation review

Start at `/packages/motion` or `/docs/motion/introduction`. All 32 original Motion routes remain; water, debugging and migration bring the total to 35. Six capability groups link into task-based learning paths. See [documentation synchronization](docs/DOCS_SYNC.md) for the repeatable checks and [coverage matrix](docs/MOTION_DOCUMENTATION_MATRIX.md) for source and test evidence.

Build and serve the assembled review artifact using `DEPLOYMENT.md`. The current local preview uses `http://127.0.0.1:8125/`.
