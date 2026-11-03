import copy
import json
from pathlib import Path
import unittest

from check_documentation import ROOT, content_errors


class DocumentationContractTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.data = json.loads((ROOT / 'build/seo/content.json').read_text())
        cls.reference = json.loads((ROOT / 'assets/reference/public_api.json').read_text())

    def errors(self, data):
        return '\n'.join(content_errors(data, self.reference))

    def test_broken_link_and_anchor_are_rejected(self):
        data = copy.deepcopy(self.data)
        blocks = data['articles'][0]['sections'][0]['blocks']
        blocks.extend([{'kind': 'link', 'route': '/missing'}, {'kind': 'link', 'route': '/docs/motion/springs#missing'}])
        self.assertIn('Broken internal link', self.errors(data))
        self.assertIn('Broken heading link', self.errors(data))

    def test_missing_route_asset_and_public_name_are_rejected(self):
        data = copy.deepcopy(self.data)
        data['motionApiTopics']['missing'] = ['NibDoesNotExist']
        next(a for a in data['articles'] if a.get('examples'))['examples'][0]['source'] = 'lib/missing.dart'
        self.assertIn('API topic has no guide', self.errors(data))
        self.assertIn('Public API mapping mismatch', self.errors(data))
        self.assertIn('Missing example source asset', self.errors(data))

    def test_stale_version_and_incomplete_navigation_are_rejected(self):
        data = copy.deepcopy(self.data)
        data['articles'][0]['summary'] = 'Published 0.3.3'
        data['learningPaths']['motion']['Start here'].pop()
        self.assertIn('Stale Motion release claim', self.errors(data))
        self.assertIn('navigation must contain every guide', self.errors(data))


if __name__ == '__main__':
    unittest.main()
