#!/usr/bin/env python3
"""Validate exported website guides against the reviewed hosted Motion source.

Run export_site_content_test.dart and generate_api_reference.dart --check first.
This checks contracts; it never replaces human-authored guides with package docs.
"""
import hashlib
import json
from pathlib import Path
import re
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parents[1]


def content_errors(data, reference, root=ROOT):
    errors = []
    articles = {a['route']: a for a in data['articles']}
    routes = set(articles) | {r['route'] for r in data['recipes']}
    routes |= {c['route'] for c in data['components']}
    routes |= {'/docs/components/textarea', '/', '/packages', '/examples', '/components', '/search'}
    routes |= {p['route'] for p in data['packages']}
    if len(articles) != len(data['articles']):
        errors.append('Duplicate article route')
    for package, groups in data['learningPaths'].items():
        ids = [i for group in groups.values() for i in group]
        expected = {a['id'] for a in articles.values() if a['packageId'] == package}
        if set(ids) != expected or len(ids) != len(set(ids)):
            errors.append(f'{package}: navigation must contain every guide exactly once')
    public = {s['name'] for s in reference['packages']['motion']}
    mapped = {s for symbols in data['motionApiTopics'].values() for s in symbols}
    if public != mapped:
        errors.append(f'Public API mapping mismatch: missing={sorted(public-mapped)}, unknown={sorted(mapped-public)}')
    for topic in data['motionApiTopics']:
        if '/docs/motion/' + topic not in routes:
            errors.append(f'API topic has no guide: {topic}')
    for a in articles.values():
        ids = [s['id'] for s in a['sections']]
        if len(ids) != len(set(ids)):
            errors.append(f'{a["route"]}: duplicate heading anchors')
        for s in a['sections']:
            for b in s['blocks']:
                if b['kind'] != 'link':
                    continue
                u = urlsplit(b['route'])
                if u.scheme:
                    if u.scheme != 'https':
                        errors.append(f'Non-HTTPS link: {b["route"]}')
                elif u.path not in routes:
                    errors.append(f'Broken internal link: {b["route"]}')
                elif u.fragment and u.path in articles:
                    if u.fragment not in {s['id'] for s in articles[u.path]['sections']}:
                        errors.append(f'Broken heading link: {b["route"]}')
        for e in a.get('examples', []):
            if e['route'] not in routes:
                errors.append(f'Missing playground: {e["route"]}')
            if not (root / e['source']).is_file():
                errors.append(f'Missing example source asset: {e["source"]}')
        if a['packageId'] == 'motion':
            text = json.dumps(a, ensure_ascii=False)
            if re.search(r'0\.3\.[0-4]\b|water APIs require the local candidate|Candidate release velocity', text):
                errors.append(f'Stale Motion release claim: {a["route"]}')
            # Product names are prose, not Dart declarations.
            symbols = set(re.findall(r'\bNib[A-Z][A-Za-z0-9_]+\b', text))
            unknown = symbols - public - {'NibComponents', 'NibGenUI'}
            if unknown:
                errors.append(f'{a["route"]}: unresolved public names {sorted(unknown)}')
    return errors


def main():
    data = json.loads((ROOT / 'build/seo/content.json').read_text())
    reference = json.loads((ROOT / 'assets/reference/public_api.json').read_text())
    contract = json.loads((ROOT / 'tool/motion_release_contract.json').read_text())
    errors = content_errors(data, reference)
    if data['motionVersion'] != contract['version']:
        errors.append('Website version differs from reviewed hosted release')
    source = ROOT.parent / 'MotionNib/motion'
    manifest = (source / 'pubspec.yaml').read_text()
    if not re.search(r'^version: ' + re.escape(contract['version']) + r'\s*$', manifest, re.M):
        errors.append('Resolved Motion checkout is not the reviewed release')
    actual_files = {p.relative_to(source).as_posix() for p in (source / 'lib').rglob('*') if p.is_file()}
    if actual_files != set(contract['files']):
        errors.append('Public implementation file inventory changed; review the release contract')
    for path, expected in contract['files'].items():
        file = source / path
        if not file.is_file() or hashlib.sha256(file.read_bytes()).hexdigest() != expected:
            errors.append(f'Implementation drift from pub.dev archive: {path}')
    if errors:
        raise SystemExit('\n'.join(errors))
    print(f'PASS: {len(data["articles"])} guides; navigation, links, anchors, public names, example assets and hosted Motion {contract["version"]} source hashes.')


if __name__ == '__main__':
    main()
