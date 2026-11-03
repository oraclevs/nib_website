#!/usr/bin/env python3
"""Resolve and import canonical docs; scheduled runs skip unchanged content."""
import argparse
import json
import os
from pathlib import Path
import subprocess
from urllib.error import HTTPError
from urllib.request import Request, urlopen

from import_motion_docs import LOCK, ROOT, SHA, require


def read_json(url):
    with urlopen(Request(url, headers={'User-Agent': 'nib-website-docs-sync'}), timeout=30) as response:
        return json.load(response)


def needs_build(source, deployed):
    return any(source.get(key) != deployed.get(key) for key in
               ('content_sha256', 'package_version', 'channel', 'runtime_commit'))


def run(args):
    require(not args.commit or SHA.fullmatch(args.commit), 'Use a full documentation commit SHA')
    main = read_json('https://api.github.com/repos/oraclevs/nib_motion/commits/main')['sha'] if not args.commit or args.production else None
    sha = args.commit or main
    require(not args.production or sha == main, 'Production documentation must come from canonical main')
    try:
        read_json(f'https://raw.githubusercontent.com/oraclevs/nib_motion/{sha}/doc/website.json')
    except HTTPError as error:
        if error.code == 404 and not args.commit:
            print('Canonical main has no website manifest yet; waiting for candidate approval.')
            return {'changed': 'false', 'commit': sha}
        raise
    edit_ref = 'main' if args.production or args.scheduled else args.edit_ref
    subprocess.run(['python3', str(ROOT / 'tool/import_motion_docs.py'), '--commit', sha, '--edit-ref', edit_ref], check=True)
    source = json.loads(LOCK.read_text())
    require(not args.production or source['channel'] == 'stable', 'Production requires stable documentation')
    changed = True
    if args.scheduled:
        try:
            deployed = read_json('https://www.nibmotion.xyz/motion-docs-source.json')
        except HTTPError as error:
            if error.code != 404:
                raise
            deployed = {}
        changed = needs_build(source, deployed)
    result = {'changed': str(changed).lower(), 'commit': sha}
    print(json.dumps(result))
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--commit')
    parser.add_argument('--scheduled', action='store_true')
    parser.add_argument('--edit-ref', default='main')
    parser.add_argument('--production', action='store_true')
    args = parser.parse_args()
    result = run(args)
    if output := os.environ.get('GITHUB_OUTPUT'):
        with Path(output).open('a') as stream:
            stream.writelines(f'{key}={value}\n' for key, value in result.items())
