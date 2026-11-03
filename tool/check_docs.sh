#!/usr/bin/env bash
# CI entry point. Requires the sibling source checkouts documented in DOCS_SYNC.md.
set -euo pipefail
cd "$(dirname "$0")/.."
export FLUTTER_BIN="$(command -v flutter)"
export FLUTTER_ROOT="$(dirname "$(dirname "$(realpath "$FLUTTER_BIN")")")"
flutter pub get
(cd tool/api_reference && dart pub get)
dart --packages=tool/api_reference/.dart_tool/package_config.json tool/generate_api_reference.dart --check
flutter analyze --fatal-infos
flutter test --no-pub
flutter test --no-pub tool/export_site_content_test.dart
python3 tool/check_documentation.py
python3 -m unittest discover -s tool -p 'check_documentation_test.py'
flutter build web --wasm --release --no-pub
"${SEO_PYTHON:-python3}" tool/build_seo.py --mode preview
python3 tool/verify_seo.py
