import unittest
from unittest.mock import patch
from argparse import Namespace
from urllib.error import HTTPError
from prepare_docs_sync import needs_build, run


class SyncTest(unittest.TestCase):
    def test_unrelated_commit_does_not_redeploy(self):
        source = dict(content_sha256='abc', package_version='0.3.5', channel='stable', runtime_commit='aaa', commit='new')
        self.assertFalse(needs_build(source, {**source, 'commit': 'old'}))
        for key in ('content_sha256', 'package_version', 'channel', 'runtime_commit'):
            self.assertTrue(needs_build(source, {**source, key: 'different'}))

    def test_production_rejects_non_main_before_import(self):
        with patch('prepare_docs_sync.read_json', return_value={'sha': 'a' * 40}), patch('prepare_docs_sync.subprocess.run') as command:
            with self.assertRaisesRegex(ValueError, 'canonical main'):
                run(Namespace(commit='b' * 40, production=True, scheduled=False))
            command.assert_not_called()

    def test_non_sha_input_rejected(self):
        with self.assertRaisesRegex(ValueError, 'full documentation commit'):
            run(Namespace(commit='main; command', production=False, scheduled=False))

    def test_main_without_manifest_waits_for_integration(self):
        missing = HTTPError('https://raw.githubusercontent.com', 404, 'Not Found', None, None)
        self.addCleanup(missing.close)
        with patch('prepare_docs_sync.read_json', side_effect=[{'sha': 'a' * 40}, missing]):
            self.assertEqual(run(Namespace(commit=None, production=False, scheduled=False))['changed'], 'false')
