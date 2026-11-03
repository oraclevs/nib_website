# Public API reference generator

From `WebsiteEmberLiving/`, run:

```sh
cd tool/api_reference
dart pub get
cd ../..
dart --packages=tool/api_reference/.dart_tool/package_config.json tool/generate_api_reference.dart
dart --packages=tool/api_reference/.dart_tool/package_config.json tool/generate_api_reference.dart --check
```

The tool's pinned analyzer dependency is isolated from the website runtime. It
reads the public Dart export graphs of Nib Motion, Components, and GenUI,
including GenUI's core and HTTP libraries. It writes
`assets/reference/public_api.json` in deterministic order. `--check` fails if
the committed reference differs from the current source.

The JSON is a source-derived index of declarations and signatures. It does not
claim that undocumented behavior is supported or substitute for the guides.

The current sandbox mounts the shared pub cache read-only. For an offline
refresh there, set up a writable active-roots directory before `pub get`:

```sh
mkdir -p /tmp/nib-api-pub-cache
ln -sfn /home/occ/.pub-cache/hosted /tmp/nib-api-pub-cache/hosted
cd tool/api_reference
PUB_CACHE=/tmp/nib-api-pub-cache dart pub get --offline
```

The generated file records Nib-root-relative source paths. Anonymous
extensions have no importable symbol name. The only one in these sources is
inside `nib_text.dart`, which the public barrel restricts to `show NibText`.
