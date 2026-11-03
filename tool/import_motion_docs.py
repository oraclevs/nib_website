#!/usr/bin/env python3
"""Import the bounded Markdown guide format from an immutable GitHub commit.

No code from the documentation repository is executed. Unknown block syntax,
route drift and unsupported release versions fail the build.
"""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import tempfile
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parents[1]
GENERATED = ROOT / 'lib/content/motion_guides.dart'
LOCK = ROOT / 'tool/motion_docs.lock.json'
PROVENANCE = ROOT / 'assets/reference/motion_docs_source.json'
SHA = re.compile(r'[0-9a-f]{40}')
EDIT_REF = re.compile(r'[A-Za-z0-9][A-Za-z0-9._/-]{0,150}')


def require(condition, message):
    if not condition:
        raise ValueError(message)


def table_cells(line):
    require(line.startswith('|') and line.endswith('|'), 'Malformed table row')
    return [re.sub(r'\\([\\|])', r'\1', v.strip()).replace('<br>', '\n')
            for v in re.split(r'(?<!\\)\|', line[1:-1])]


def parse_list(lines, start, indent=0):
    items, ordered = [], None
    i = start
    while i < len(lines):
        match = re.fullmatch(r'( *)(- |\d+\. )(.+)', lines[i])
        if not match or len(match[1]) < indent:
            break
        require(len(match[1]) == indent, 'List indentation must increase by two spaces')
        this_ordered = match[2] != '- '
        if ordered is None:
            ordered = this_ordered
        require(ordered == this_ordered, 'Mixed list markers')
        item = {'text': match[3], 'children': []}
        i += 1
        if i < len(lines) and lines[i].startswith(' ' * (indent + 2)):
            child, i = parse_list(lines, i, indent + 2)
            require(not child['ordered'], 'Nested ordered lists are unsupported')
            item['children'] = child['items']
        items.append(item)
    return {'kind': 'list', 'ordered': bool(ordered), 'items': items}, i


def parse_markdown(text):
    require(len(text.encode()) < 200_000, 'Guide exceeds the document size limit')
    require(text.startswith('---\n'), 'Missing JSON-compatible frontmatter')
    parts = text.split('\n---\n', 1)
    require(len(parts) == 2, 'Unclosed frontmatter')
    meta = json.loads(parts[0][4:])
    require(set(meta) == {'id', 'evidence'}, 'Unknown frontmatter fields')
    require(re.fullmatch(r'[a-z0-9-]+', meta['id']), 'Invalid guide ID')
    chunks = re.split(r'\n<!-- section: ([a-z0-9-]+) -->\n', '\n' + parts[1].strip())
    intro = chunks[0].strip().split('\n\n')
    require(len(intro) == 2 and intro[0].startswith('# '), 'Expected title and one summary paragraph')
    article = {**meta, 'title': intro[0][2:], 'summary': intro[1], 'sections': []}
    for index in range(1, len(chunks), 2):
        lines = chunks[index + 1].strip().splitlines()
        require(lines and lines[0].startswith('## '), 'Section must start with a level-two heading')
        section = {'id': chunks[index], 'heading': lines[0][3:], 'paragraphs': [],
                   'code': None, 'note': None, 'api': [], 'blocks': []}
        i, api_next, previous_rank = 1, False, 0
        while i < len(lines):
            line = lines[i]
            if not line:
                i += 1
                continue
            require(not line.startswith(('#', '<')) or line == '<!-- api -->', 'Unsupported Markdown block: ' + line[:60])
            rank = (2 if line == '<!-- api -->' or api_next else
                    3 if line.startswith('```') else 4 if line.startswith('> ') else
                    1 if line.startswith(('|', '[')) or re.match(r'(?:- |\d+\. )', line) else 0)
            require(rank >= previous_rank, 'Section block order must be paragraphs, lists/tables/links, API table, code, note')
            previous_rank = rank
            if line == '<!-- api -->':
                require(not section['api'], 'Duplicate API table')
                api_next = True
                i += 1
                require(i < len(lines) and lines[i].startswith('|'), 'API marker must precede a table')
            elif line.startswith('```'):
                require(line in ('```dart', '```bash', '```text'), 'Unsupported code fence language')
                require(section['code'] is None, 'Only one code block per section is supported')
                end = i + 1
                while end < len(lines) and lines[end] != '```':
                    end += 1
                require(end < len(lines), 'Unclosed code fence')
                section['code'] = '\n'.join(lines[i + 1:end])
                i = end + 1
            elif line.startswith('|'):
                headers = table_cells(line)
                require(i + 1 < len(lines) and all(re.fullmatch(r':?-+:?', c) for c in table_cells(lines[i + 1])), 'Missing table separator')
                i += 2
                rows = []
                while i < len(lines) and lines[i].startswith('|'):
                    row = table_cells(lines[i])
                    require(len(row) == len(headers), 'Uneven table width')
                    rows.append(row)
                    i += 1
                if api_next:
                    require(headers == ['Name', 'Type', 'Default', 'Description'], 'Invalid API table headings')
                    section['api'] = [dict(zip(('name', 'type', 'default', 'description'), row)) for row in rows]
                    api_next = False
                else:
                    section['blocks'].append({'kind': 'table', 'headers': headers, 'rows': rows})
            elif line.startswith('> '):
                require(section['note'] is None, 'Duplicate note')
                note = []
                while i < len(lines) and lines[i].startswith('> '):
                    note.append(lines[i][2:])
                    i += 1
                section['note'] = '\n'.join(note)
            elif re.match(r'(?:- |\d+\. )', line):
                block, i = parse_list(lines, i)
                section['blocks'].append(block)
            elif match := re.fullmatch(r'\[([^\]]+)\]\(([^\s)]+)\)', line):
                section['blocks'].append({'kind': 'link', 'label': match[1], 'route': match[2]})
                i += 1
            else:
                require(not line.startswith(('#', '<', '```')), 'Unsupported Markdown block: ' + line[:60])
                paragraph = []
                while i < len(lines) and lines[i]:
                    require(not lines[i].startswith(('#', '<', '|', '```')), 'Blocks must be separated by a blank line')
                    paragraph.append(lines[i])
                    i += 1
                section['paragraphs'].append('\n'.join(paragraph))
        article['sections'].append(section)
    anchors = [s['id'] for s in article['sections']]
    require(anchors and len(anchors) == len(set(anchors)), 'Missing or duplicate heading anchors')
    return article


def dart(value):
    if value is None:
        return 'null'
    return json.dumps(value, ensure_ascii=False).replace('$', r'\$')


def dart_list_item(item):
    return f'DocListItem({dart(item["text"])}, children: [{", ".join(map(dart_list_item, item["children"]))}])'


def dart_block(block):
    if block['kind'] == 'link':
        return f'DocLink({dart(block["label"])}, {dart(block["route"])})'
    if block['kind'] == 'table':
        return f'DocTable(headers: {dart(block["headers"])}, rows: {dart(block["rows"])})'
    return f'DocList([{", ".join(map(dart_list_item, block["items"]))}], ordered: {str(block["ordered"]).lower()})'


def render(articles, source):
    lines = ['// GENERATED by tool/import_motion_docs.py. Edit the linked GitHub Markdown.',
             '// Source: ' + source['commit'], "import 'site_content.dart';", '',
             f'const motionDocsVersion = {dart(source["package_version"])};',
             f'const motionDocsCommit = {dart(source["commit"])};',
             f'const motionDocsChannel = {dart(source["channel"])};',
             f'const motionDocsEditRef = {dart(source["edit_ref"])};',
             'const motionDocsSources = <String, String>{']
    lines += [f'{dart(a["id"])}: {dart(a["source"])},' for a in articles]
    lines += ['};', 'const detailedMotionGuides = <DocArticle>[']
    for article in articles:
        lines += ['DocArticle(', "packageId: 'motion',"]
        for key in ('id', 'title', 'summary', 'evidence'):
            lines.append(f'{key}: {dart(article[key])},')
        lines += [f'relatedRecipeId: {dart(article["recipe"])},', 'sections: [']
        for section in article['sections']:
            lines += ['DocSection(']
            for key in ('id', 'heading', 'paragraphs', 'code', 'note'):
                lines.append(f'{key}: {dart(section[key])},')
            lines += ['api: [']
            for api in section['api']:
                lines.append('DocApiEntry(' + ', '.join(f'{field}: {dart(api[key])}' for field, key in [('name', 'name'), ('type', 'type'), ('defaultValue', 'default'), ('description', 'description')]) + '),')
            lines += ['],', 'blocks: [', *[dart_block(b) + ',' for b in section['blocks']], '],', '),']
        lines += ['],', '),']
    return '\n'.join(lines + ['];', ''])


def git_read(repo, sha, path):
    require(SHA.fullmatch(sha), 'Documentation ref must be a full commit SHA')
    require(not PurePosixPath(path).is_absolute() and '..' not in PurePosixPath(path).parts, 'Unsafe source path')
    return subprocess.check_output(['git', '-C', str(repo), 'show', f'{sha}:{path}']).decode()


def import_source(repo, sha, routes, contract):
    manifest = json.loads(git_read(repo, sha, 'doc/website.json'))
    require(manifest['schema'] == 1 and manifest['package'] == 'nib_motion', 'Unsupported documentation manifest')
    require(manifest['channel'] in ('stable', 'next'), 'Unknown documentation channel')
    require(manifest['package_version'] == contract['version'], 'Documentation version differs from the verified consumer release')
    require(manifest['runtime_commit'] == contract['commit'], 'Runtime commit differs from the verified release')
    expected = {g['id']: g['source'] for g in routes['guides']}
    actual = {g['id']: g['source'] for g in manifest['guides']}
    require(actual == expected and len(actual) == len(manifest['guides']), 'Missing, duplicated or unmapped documentation')
    articles, hashes = [], {}
    hashes['doc/website.json'] = hashlib.sha256(git_read(repo, sha, 'doc/website.json').encode()).hexdigest()
    source_routes = {g['source']: g['route'] for g in routes['guides']}
    for mapping in routes['guides']:
        text = git_read(repo, sha, mapping['source'])
        hashes[mapping['source']] = hashlib.sha256(text.encode()).hexdigest()
        article = parse_markdown(text)
        require(article['id'] == mapping['id'], 'Guide ID differs from route mapping')
        article.update(source=mapping['source'], recipe=mapping['recipe'])
        for section in article['sections']:
            for block in section['blocks']:
                if block['kind'] != 'link':
                    continue
                url = urlsplit(block['route'])
                if url.scheme:
                    require(url.scheme == 'https', 'Links must use HTTPS')
                    if url.netloc == 'www.nibmotion.xyz':
                        block['route'] = url.path + ('#' + url.fragment if url.fragment else '')
                elif not url.path.startswith('/'):
                    path = str(PurePosixPath(mapping['source']).parent / url.path)
                    require(path in source_routes, 'Unmapped Markdown link: ' + path)
                    block['route'] = source_routes[path] + ('#' + url.fragment if url.fragment else '')
        articles.append(article)
    source = {'schema': 1, 'repository': routes['repository'], 'commit': sha,
              'package_version': manifest['package_version'], 'channel': manifest['channel'],
              'runtime_commit': manifest['runtime_commit'], 'files': hashes}
    source['content_sha256'] = hashlib.sha256(json.dumps(hashes, sort_keys=True).encode()).hexdigest()
    return articles, source


def run(args):
    routes = json.loads((ROOT / 'tool/motion_docs_routes.json').read_text())
    lock = json.loads(LOCK.read_text()) if LOCK.exists() else {}
    sha = args.commit or lock.get('commit', '')
    require(SHA.fullmatch(sha), 'Use --commit with an immutable 40-character SHA')
    edit_ref = args.edit_ref or lock.get('edit_ref', 'main')
    require(EDIT_REF.fullmatch(edit_ref) and '..' not in edit_ref and not SHA.fullmatch(edit_ref), 'Edit ref must be an editable branch name')
    contract = json.loads((ROOT / 'tool/motion_release_contract.json').read_text())
    with tempfile.TemporaryDirectory(prefix='nib-docs-') as temporary:
        repo = args.source_repo or temporary
        if not args.source_repo:
            subprocess.run(['git', 'init', '-q', repo], check=True)
            subprocess.run(['git', '-C', repo, 'fetch', '-q', '--depth=1', 'https://github.com/oraclevs/nib_motion.git', sha], check=True)
        articles, provenance = import_source(repo, sha, routes, contract)
        provenance['edit_ref'] = edit_ref
        raw = Path(temporary) / 'motion_guides.dart'
        raw.write_text(render(articles, provenance))
        subprocess.run([args.dart, 'format', str(raw)], check=True, stdout=subprocess.DEVNULL)
        generated = raw.read_text()
    lock_text = json.dumps(provenance, indent=2) + '\n'
    if args.check:
        require(GENERATED.read_text() == generated, 'Generated Motion guides drifted; run the importer')
        require(LOCK.read_text() == lock_text and PROVENANCE.read_text() == lock_text, 'Documentation source lock drifted')
    else:
        GENERATED.write_text(generated)
        LOCK.write_text(lock_text)
        PROVENANCE.write_text(lock_text)
    print(f'{"Verified" if args.check else "Imported"} {len(articles)} canonical guides at {sha}; {provenance["channel"]} {provenance["package_version"]}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--commit')
    parser.add_argument('--source-repo', type=Path)
    parser.add_argument('--dart', default='dart')
    parser.add_argument('--edit-ref', help='Authoring branch; source content remains pinned to the commit')
    parser.add_argument('--check', action='store_true')
    try:
        run(parser.parse_args())
    except (ValueError, KeyError, json.JSONDecodeError, subprocess.CalledProcessError) as error:
        raise SystemExit(str(error)) from error
