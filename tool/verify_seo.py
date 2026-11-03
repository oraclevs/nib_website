#!/usr/bin/env python3
"""Check the exact assembled deployment, including source/content parity."""
import hashlib
from html.parser import HTMLParser
import json
from pathlib import Path
from urllib.parse import urlsplit,unquote
import xml.etree.ElementTree as ET

ROOT=Path(__file__).resolve().parents[1]
OUTPUT=ROOT/'.vercel/output'
manifest=json.loads((OUTPUT/'nib-build-manifest.json').read_text())
source=json.loads((ROOT/'build/seo/content.json').read_text())
provenance=json.loads((ROOT/'tool/motion_docs.lock.json').read_text())
static=OUTPUT/'static'

class Page(HTMLParser):
    def __init__(self,text):
        super().__init__(convert_charrefs=True)
        self.metas={}; self.canon=[]; self.links=[]; self.h1=0; self.text=[]; self.schemas=[]; self.in_schema=False
        self.feed(text)
    def handle_starttag(self,tag,attrs):
        a=dict(attrs)
        if tag=='meta': self.metas[a.get('name',a.get('property'))]=a.get('content')
        if tag=='link' and a.get('rel')=='canonical': self.canon.append(a['href'])
        if tag=='a': self.links.append(a.get('href',''))
        if tag=='h1': self.h1+=1
        if tag=='script' and a.get('type')=='application/ld+json': self.in_schema=True
    def handle_endtag(self,tag):
        if tag=='script': self.in_schema=False
    def handle_data(self,text):
        self.text.append(text)
        if self.in_schema: self.schemas.append(json.loads(text))

problems=[]
def check(ok,message):
    if not ok: problems.append(message)

for path,digest in manifest['sha256'].items():
    check(hashlib.sha256((OUTPUT/path).read_bytes()).hexdigest()==digest,'Hash mismatch: '+path)
all_routes=set(manifest['routes'])
for route in manifest['routes']:
    file='index.html' if route=='/' else route.lstrip('/')+'.html'
    parsed=Page((static/file).read_text())
    check(parsed.h1==1,route+': expected one H1')
    check(parsed.canon==[manifest['origin']+route],route+': incorrect canonical')
    check(bool(parsed.metas.get('description')),route+': missing description')
    check(parsed.metas.get('twitter:card')=='summary_large_image',route+': missing social card')
    check(len(parsed.schemas)==1,route+': missing structured data')
    check((static/urlsplit(parsed.metas['og:image']).path.lstrip('/')).is_file(),route+': image missing')
    if manifest['mode']=='preview' or route=='/search':
        check('noindex' in parsed.metas['robots'],route+': must be noindex')
    else:
        check('noindex' not in parsed.metas['robots'],route+': unexpectedly noindex')
    for href in parsed.links:
        u=urlsplit(href)
        if u.scheme or not u.path: continue
        target=unquote(u.path)
        check(target in all_routes or target in manifest['aliases'] or (static/target.lstrip('/')).is_file(),route+': broken link '+href)
    article=next((a for a in source['articles'] if a['route']==route),None)
    if article:
        text=''.join(parsed.text)
        if article['packageId']=='motion':
            check(provenance['commit'] in text,route+': missing documentation SHA')
            check('nib_motion '+provenance['package_version'] in text,route+': missing package version')
            check('https://github.com/oraclevs/nib_motion/edit/'+provenance['edit_ref']+'/'+article['source'] in parsed.links,route+': missing edit link')
        for section in article['sections']:
            for paragraph in section['paragraphs']:
                check(paragraph in text,route+': missing source paragraph')
            if section['code']: check(section['code'] in text,route+': missing source code')
for old,target in manifest['aliases'].items():
    check(old not in all_routes, 'Redirect shadows a current route: '+old)
    check(target in all_routes, 'Redirect target missing or chained: '+old+' -> '+target)
sitemap=ET.parse(static/'sitemap.xml')
urls=[x.text for x in sitemap.iter('{http://www.sitemaps.org/schemas/sitemap/0.9}loc')]
check(set(urls)=={manifest['origin']+r for r in all_routes if r!='/search'},'Sitemap must contain exactly every public route except search')
check(len(urls)==len(set(urls)),'Duplicate sitemap URL')
check(manifest['origin']+'/search' not in urls,'Search must not be in sitemap')
check('/sitemap.xml' in (static/'robots.txt').read_text(),'Missing robots sitemap')
check(not any(p.name.startswith('.env') for p in static.rglob('*')),'Environment file in public output')
check('noindex' in Page((static/'404.html').read_text()).metas['robots'],'404 must be noindex')
check(json.loads((static/'motion-docs-source.json').read_text())==provenance,'Deployed provenance differs from source lock')
if problems:
    raise SystemExit('\n'.join(problems))
print(f'PASSED: {len(all_routes)} routes, full guide/code parity, metadata, links, sitemap, social images, artifact hashes and preview/production robots rules.')
