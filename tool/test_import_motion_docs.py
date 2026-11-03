import copy
import json
import unittest
from unittest.mock import patch

from import_motion_docs import import_source, parse_markdown, render

GUIDE = '''---
{"id":"water","evidence":"lib/src/water/nib_water_surface.dart"}
---

# Water

A bounded surface.

<!-- section: example -->
## Try it

Keep controls readable.

```dart
const label = '$value';
```

> Sample only the supplied background.

<!-- api -->
| Name | Type | Default | Description |
| --- | --- | --- | --- |
| value | String \\| null | null | A value. |

1. Tap.
  - Observe.
2. Reset.

[Water](water.md#example)
'''


class ImportTest(unittest.TestCase):
    def test_markdown_blocks_preserved(self):
        article = parse_markdown(GUIDE)
        section = article['sections'][0]
        self.assertEqual(section['code'], "const label = '$value';")
        self.assertEqual(section['api'][0]['type'], 'String | null')
        self.assertEqual(section['blocks'][0]['items'][0]['children'][0]['text'], 'Observe.')
        self.assertEqual(section['note'], 'Sample only the supplied background.')

    def test_unsupported_syntax_fails(self):
        with self.assertRaisesRegex(ValueError, 'Unsupported Markdown'):
            parse_markdown(GUIDE + '\n<script>bad()</script>\n')

    def test_unclosed_fence_fails(self):
        with self.assertRaisesRegex(ValueError, 'Unclosed code fence'):
            parse_markdown(GUIDE.replace("\n```\n", '\n', 1))

    def test_duplicate_anchor_fails(self):
        with self.assertRaisesRegex(ValueError, 'duplicate heading'):
            parse_markdown(GUIDE + '\n<!-- section: example -->\n## Again\n\nText.\n')

    def source(self):
        manifest = {'schema': 1, 'package': 'nib_motion', 'package_version': '0.3.5',
                    'channel': 'stable', 'runtime_commit': 'a' * 40,
                    'guides': [{'id': 'water', 'source': 'doc/guides/water.md'}]}
        routes = {'repository': 'oraclevs/nib_motion', 'guides': [
            {'id': 'water', 'source': 'doc/guides/water.md', 'route': '/docs/motion/water', 'recipe': None}]}
        return manifest, routes

    def test_import_version_links_and_hashes(self):
        manifest, routes = self.source()
        files = {'doc/website.json': json.dumps(manifest), 'doc/guides/water.md': GUIDE}
        with patch('import_motion_docs.git_read', side_effect=lambda repo, sha, path: files[path]):
            articles, source = import_source('.', 'b' * 40, routes, {'version': '0.3.5', 'commit': 'a' * 40})
            self.assertEqual(articles[0]['sections'][0]['blocks'][1]['route'], '/docs/motion/water#example')
            self.assertEqual(source['commit'], 'b' * 40)
            self.assertEqual(len(source['files']), 2)
            self.assertIn(r'\$value', render(articles, source))
            with self.assertRaisesRegex(ValueError, 'version differs'):
                import_source('.', 'b' * 40, routes, {'version': '0.3.6', 'commit': 'a' * 40})

    def test_missing_mapping_rejected(self):
        manifest, routes = self.source()
        bad = copy.deepcopy(manifest)
        bad['guides'] = []
        with patch('import_motion_docs.git_read', return_value=json.dumps(bad)):
            with self.assertRaisesRegex(ValueError, 'unmapped'):
                import_source('.', 'b' * 40, routes, {'version': '0.3.5', 'commit': 'a' * 40})
