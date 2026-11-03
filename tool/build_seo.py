#!/usr/bin/env python3
"""Assemble Flutter assets and real site content as Vercel Build Output API v3.

Requires Pillow only at build time. No crawler-specific rendering is used.
"""
import argparse
import hashlib
import html
import json
from pathlib import Path
import re
import shutil
from urllib.parse import urlsplit, urlunsplit
import xml.etree.ElementTree as ET
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
E = html.escape


def link(route, label, reading=True):
    if reading and route.startswith('/'):
        u = urlsplit(route)
        route = urlunsplit(('', '', u.path, 'view=text', u.fragment))
    return f'<a href="{E(route, quote=True)}">{E(label)}</a>'


def paras(values):
    return ''.join(f'<p>{E(p)}</p>' for p in values)


def table(headers, rows):
    return '<div class="table-scroll"><table><thead><tr>' + ''.join(f'<th scope="col">{E(str(x))}</th>' for x in headers) + '</tr></thead><tbody>' + ''.join('<tr>' + ''.join(f'<td>{E(str(x))}</td>' for x in row) + '</tr>' for row in rows) + '</tbody></table></div>'


def listing(items, ordered=False):
    tag = 'ol' if ordered else 'ul'
    return f'<{tag}>' + ''.join('<li>' + E(x['text']) + (listing(x['children']) if x.get('children') else '') + '</li>' for x in items) + f'</{tag}>'


def sections(values):
    result = ''
    for s in values:
        result += f'<section id="{E(s["id"])}"><h2>{E(s["heading"])}</h2>' + paras(s['paragraphs'])
        for block in s['blocks']:
            if block['kind'] == 'list':
                result += listing(block['items'], block['ordered'])
            elif block['kind'] == 'table':
                result += table(block['headers'], block['rows'])
            elif block['kind'] == 'link':
                result += '<p>' + link(block['route'], block['label']) + '</p>'
        if s['code']:
            result += '<pre><code class="language-dart">' + E(s['code']) + '</code></pre>'
        if s['api']:
            result += table(['API', 'Type', 'Default', 'Behavior'], [[a['name'], a['type'], a['default'], a['description']] for a in s['api']])
        if s['note']:
            result += '<aside class="callout">' + E(s['note']) + '</aside>'
        result += '</section>'
    return result


def cards(items, route_key='route'):
    return '<div class="grid">' + ''.join('<section class="card"><h3>' + link(x[route_key], x.get('title', x.get('name', 'Nib'))) + '</h3><p>' + E(x.get('summary', x.get('description', ''))) + '</p></section>' for x in items) + '</div>'


def markdown_sections(values):
    out = ''
    for s in values:
        out += '\n## ' + s['heading'] + '\n\n' + '\n\n'.join(s['paragraphs']) + '\n'
        for b in s['blocks']:
            if b['kind'] == 'link':
                out += f'\n[{b["label"]}]({b["route"]})\n'
            elif b['kind'] == 'list':
                def lines(items, indent=0):
                    return '\n'.join('  '*indent + '- ' + i['text'] + ('\n' + lines(i['children'], indent+1) if i['children'] else '') for i in items)
                out += '\n' + lines(b['items']) + '\n'
            else:
                out += '\n' + ' | '.join(b['headers']) + '\n' + '\n'.join(' | '.join(row) for row in b['rows']) + '\n'
        if s['code']:
            fence = '`' * max(3, max((len(m[0])+1 for m in re.finditer(r'`+', s['code'])), default=3))
            out += f'\n{fence}dart\n{s["code"]}\n{fence}\n'
        for a in s['api']:
            out += f'\n- {a["name"]} ({a["type"]}; default {a["default"]}): {a["description"]}\n'
        if s['note']:
            out += '\nNote: ' + s['note'] + '\n'
    return out


def create_pages(data):
    pages = []
    def add(route, title, description, category, body, markdown=None, index=True):
        description = ' '.join(description.split())
        if len(description) > 170:
            description = description[:167].rsplit(' ', 1)[0] + '…'
        pages.append(dict(route=route, title=title, description=description, category=category,
                          body=body, markdown=markdown, index=index))
    packages = data['packages']
    add('/', 'Nib — Flutter animation and UI components',
        'Build expressive Flutter interfaces with NibMotion and NibComponents. Explore interactive examples, tune animations, and learn the APIs.', 'ECOSYSTEM',
        '<p class="intro">Make every interaction count.</p>' + paras(['NibMotion animates your Flutter widgets. NibComponents brings controls, forms, overlays and navigation built on that motion. Try the examples, change the settings, and take the Dart code into your app.']) + cards(packages) + '<h2>Start building</h2>' + '<p>' + link('/docs/motion/getting-started', 'Your first Flutter animation') + ' · ' + link('/components', 'Explore the component catalog') + ' · ' + link('/examples', 'Try motion examples') + '</p><aside class="callout">The site includes local candidate features. Check each guide’s release and platform notes. NibGenUI is an unpublished, experimental A2UI subset.</aside>')
    add('/packages', 'The Nib Flutter ecosystem', 'Explore NibMotion, NibComponents and the experimental NibGenUI preview. Find installation instructions, package guides and platform limits.', 'ECOSYSTEM', cards(packages))
    for p in packages:
        guides = [a for a in data['articles'] if a['packageId'] == p['id']]
        body = '<p class="intro">' + E(p['tagline']) + '</p>' + paras([p['description'], p['status']])
        if p['install']:
            body += '<pre><code>' + E(p['install']) + '</code></pre>'
        body += (sections(data['motionCapabilities']) if p['id']=='motion' else listing([{'text': x} for x in p['capabilities']])) + '<aside class="callout">' + E(p['caution']) + '</aside>'
        for level, ids in data['learningPaths'][p['id']].items():
            selected = [a for id in ids for a in guides if a['id'] == id]
            if selected:
                body += f'<h2>{E(level)}</h2>' + cards(selected)
        add(p['route'], p['name'] + ' — Flutter package guide', p['description'], p['name'].upper(), body)
    add('/components', 'Flutter UI components — NibComponents catalog', 'Browse 33 component guides with live Flutter previews: switches, buttons, forms, dialogs, navigation, liquid glass and more. Open the playground to customize.', 'COMPONENTS', '<p class="intro">Real components. Ready to make yours.</p>' + cards(data['components'], 'docsRoute'))
    add('/examples', 'Flutter animation examples — NibMotion', 'Try interactive Flutter animation examples: springs, keyframes, drag gestures, layout, presence and scroll effects. Tune the motion and copy the Dart code.', 'MOTION', cards([r for r in data['recipes'] if r['gallery']]))
    for a in data['articles']:
        body = '<nav class="toc" aria-label="On this page">' + ''.join(link(a['route']+'#'+s['id'], s['heading']) for s in a['sections']) + '</nav>' + sections(a['sections'])
        markdown = markdown_sections(a['sections'])
        if a['packageId'] == 'motion':
            source = data['motionDocsSource']
            edit = f'https://github.com/oraclevs/nib_motion/edit/{source["commit"]}/{a["source"]}'
            provenance = f'nib_motion {source["version"]} · {source["channel"]} · source {source["commit"]}'
            body = '<p>' + E(provenance) + ' · ' + link(edit, 'Edit this page on GitHub') + '</p>' + body
            markdown = provenance + '\n\n[Edit this page on GitHub](' + edit + ')\n\n' + markdown
        add(a['route'], a['title'] + ' — ' + {'motion':'NibMotion','components':'NibComponents','genui':'NibGenUI'}[a['packageId']], a['summary'], 'DOCUMENTATION', body, markdown)
    for g in data['components']:
        body = paras([g['summary']]) + '<p>' + link(g['docsRoute'], 'Read the full component guide and API') + '</p><h2>Public widgets and APIs</h2>' + listing([{'text': s} for s in g['symbols']]) + '<h2>Example Dart code</h2><pre><code class="language-dart">' + E(g['minimalCode']) + '</code></pre><h2>Playground controls</h2>'
        body += table(['Control', 'Type', 'Options or range', 'Help'], [[c['label'], c['kind'], ', '.join(c['choices']) if c['choices'] else (str(c['min'])+'–'+str(c['max']) if c['kind']=='number' else ''), c['help'] or ''] for c in g['controls']])
        body += paras(g['limitations'])
        add(g['route'], g['title'] + ' playground — NibComponents', 'Try ' + g['title'].lower() + ' in Flutter. ' + g['summary'], 'PLAYGROUND', body)
    for r in data['recipes']:
        body = paras([r['summary'],r['purpose']]) + '<h2>Try the interaction</h2>' + paras([r['action']]) + '<p>' + link(r['docsRoute'], 'Read the guide and example code') + '</p>'
        if r['controls']:
            body += '<h2>Controls</h2>' + table(['Setting', 'Group', 'Range', 'Initial'], [[c['label'],c['group'],str(c['min'])+'–'+str(c['max']), c['initial']] for c in r['controls']])
        add(r['route'], r['title'] + ' — Flutter animation playground', r['summary'] + ' ' + r['purpose'], 'PLAYGROUND', body)
    add('/search', 'Search the Nib documentation', 'Find Flutter animation APIs, component guides and working examples in the Nib documentation.', 'SEARCH', '<p>Use the interactive search to find APIs and examples, or browse the package guides below.</p>' + cards(packages), index=False)
    return pages


def social_card(path, title, category):
    image = Image.new('RGB', (1200, 630), '#111210')
    draw = ImageDraw.Draw(image)
    fonts = ROOT/'assets/fonts'
    bold = lambda size: ImageFont.truetype(str(fonts/'LiberationSans-Bold.ttf'), size)
    regular = lambda size: ImageFont.truetype(str(fonts/'LiberationSans-Regular.ttf'), size)
    for x in range(780, 1170, 32):
        for y in range(100, 600, 32):
            draw.ellipse((x,y,x+2,y+2),fill='#3a3d31')
    draw.rounded_rectangle((965,225,1105,365),radius=28,fill='#ffb511')
    draw.rounded_rectangle((900,360,1000,460),radius=24,outline='#d1dfa0',width=3)
    draw.line((64,125,1136,125),fill='#3a3d31',width=2)
    mark=Image.open(ROOT/'assets/brand/nib-mark.png').convert('RGBA')
    mark.thumbnail((145,86),Image.Resampling.LANCZOS)
    image.paste(mark,(64,24),mark)
    draw.text((240,65),category,font=regular(22),fill='#ffb511')
    title = 'Make every interaction count.' if title.startswith('Nib — ') else title.split(' — ')[0]
    words, lines, line = title.split(), [], ''
    for word in words:
        candidate = (line+' '+word).strip()
        if draw.textlength(candidate,font=bold(58)) > 800 and line:
            lines.append(line); line=word
        else: line=candidate
    lines.append(line)
    for n, line in enumerate(lines[:4]):
        draw.text((64,190+n*70),line,font=bold(58),fill='#f5e9c9')
    draw.text((64,532),'Flutter motion. Real components. Working examples.',font=regular(27),fill='#bebbaa')
    draw.text((64,578),'nibmotion.xyz',font=regular(20),fill='#ffb511')
    image.save(path, optimize=True)


def render(page, origin, production, image_path):
    route = page['route']; canonical = origin + route
    index = production and page['index']
    robots = 'index, follow, max-image-preview:large' if index else 'noindex, follow'
    title = page['title']; desc = page['description']
    graph = [{'@type':'WebSite','@id':origin+'/#website','url':origin+'/','name':'Nib','description':'Flutter animation and UI component guides.'},
             {'@type':'WebPage','@id':canonical+'#webpage','url':canonical,'name':title,'description':desc,'isPartOf':{'@id':origin+'/#website'},'inLanguage':'en'}]
    if route != '/':
        graph.append({'@type':'BreadcrumbList','itemListElement':[{'@type':'ListItem','position':1,'name':'Nib','item':origin+'/'},{'@type':'ListItem','position':2,'name':title,'item':canonical}]})
    schema = json.dumps({'@context':'https://schema.org','@graph':graph},ensure_ascii=False).replace('<','\\u003c')
    meta = ''.join(f'<meta data-page-meta {kind}="{key}" content="{E(value,quote=True)}">\n' for kind,key,value in [
        ('name','description',desc),('name','robots',robots),('property','og:type','website'),('property','og:site_name','Nib'),('property','og:title',title),('property','og:description',desc),('property','og:url',canonical),('property','og:image',origin+image_path),('property','og:image:width','1200'),('property','og:image:height','630'),('property','og:image:alt',title+' — Nib Flutter ecosystem'),('name','twitter:card','summary_large_image'),('name','twitter:title',title),('name','twitter:description',desc),('name','twitter:image',origin+image_path),('name','twitter:image:alt',title+' — Nib Flutter ecosystem')])
    nav = ' '.join(link(path,label) for path,label in [('/','Ecosystem'),('/examples','Motion'),('/docs/motion/introduction','Docs'),('/components','Components'),('/playground/card-flip','Playground')])
    return f'''<!doctype html>
<html lang="en"><head><meta charset="utf-8"><base href="/"><meta name="viewport" content="width=device-width, initial-scale=1"><meta name="theme-color" content="#111210"><meta name="color-scheme" content="dark"><title>{E(title)}</title>
{meta}<link data-page-meta rel="canonical" href="{E(canonical)}"><script data-page-meta type="application/ld+json">{schema}</script>
<link rel="icon" href="/favicon.png"><link rel="apple-touch-icon" href="/icons/Icon-192.png"><link rel="manifest" href="/manifest.json"><link rel="alternate" type="text/plain" href="/llms.txt" title="Nib guides for agents"><link rel="stylesheet" href="/reader.css">
</head><body><div id="flutter-host"></div><details id="page-reader" open><summary>Read page as text</summary><div id="page-content"><header><nav aria-label="Main navigation">{nav}</nav></header><main><p class="eyebrow">NIB / {E(page['category'])}</p><h1>{E(title)}</h1><p class="intro">{E(desc)}</p><a class="action" href="{E(route)}">Open interactive view</a>{page['body']}</main><footer>This text view uses the same guides and catalogs as the Flutter site. <a href="/llms.txt">Agent guide</a> · <a href="/sitemap.xml">Sitemap</a></footer></div></details><noscript><p>The text view is ready. JavaScript is required only for interactive Flutter examples.</p></noscript><script src="/reader.js" defer></script><script src="/flutter_bootstrap.js" async></script></body></html>'''


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--origin', default='https://www.nibmotion.xyz')
    parser.add_argument('--mode', choices=['preview','production'], required=True)
    parser.add_argument('--flutter-build', default='build/web')
    parser.add_argument('--output', default='.vercel/output')
    args = parser.parse_args()
    origin = args.origin.rstrip('/')
    if urlsplit(origin).scheme != 'https' or urlsplit(origin).path:
        parser.error('--origin must be an HTTPS origin without a path')
    production = args.mode == 'production'
    provenance = json.loads((ROOT/'assets/reference/motion_docs_source.json').read_text())
    if production and provenance['channel'] != 'stable':
        raise RuntimeError('Next documentation cannot be deployed as stable production')
    data = json.loads((ROOT/'build/seo/content.json').read_text())
    output = ROOT/args.output
    if output.exists():
        if not (output/'nib-build-manifest.json').exists():
            raise RuntimeError('Refusing to replace an output directory not created by this script')
        shutil.rmtree(output)
    static = output/'static'
    shutil.copytree(ROOT/args.flutter_build, static)
    shutil.copyfile(ROOT/'assets/reference/motion_docs_source.json', static/'motion-docs-source.json')
    # Source maps and compiler internals are not needed in a public deployment.
    for file in static.rglob('*.map'):
        file.unlink()
    for file in ['reader.css','reader.js']:
        shutil.copyfile(ROOT/'tool/seo'/file,static/file)
    # Use the approved NIB wordmark without distorting its aspect ratio.
    brand=Image.open(ROOT/'assets/brand/nib-mark.png').convert('RGBA')
    for size in [32,192,512]:
        icon=Image.new('RGBA',(size,size),'#111210')
        mark=brand.copy()
        mark.thumbnail((round(size*.84),round(size*.84)),Image.Resampling.LANCZOS)
        icon.alpha_composite(mark,((size-mark.width)//2,(size-mark.height)//2))
        if size == 32:
            icon.save(static/'favicon.png')
        else:
            icon.save(static/f'icons/Icon-{size}.png')
            icon.save(static/f'icons/Icon-maskable-{size}.png')
    # Review alternatives are local design material, not production pages.
    for name in ['review.html','review-v1.html','readme-original.png','nib-amber.svg','nib-amber.png','nib-ivory.svg','nib-ivory.png']:
        (static/'brand'/name).unlink(missing_ok=True)
    shutil.rmtree(static/'brand/concepts-v2', ignore_errors=True)
    webmanifest=json.loads((static/'manifest.json').read_text())
    webmanifest.update(name='Nib — Flutter motion and components',short_name='Nib',start_url='/',description='Explore Flutter animations, components, documentation and interactive examples.')
    (static/'manifest.json').write_text(json.dumps(webmanifest,indent=2))
    pages = create_pages(data)
    assert len({p['route'] for p in pages}) == len(pages)
    routes = {p['route'] for p in pages}
    images = static/'social'; images.mkdir(exist_ok=True)
    overrides = {}
    sitemap = ET.Element('urlset', xmlns='http://www.sitemaps.org/schemas/sitemap/0.9')
    agent_index = ['# Nib\n', '> Flutter motion and component documentation, examples and interactive playgrounds.\n',
        'Canonical site: '+origin+'\n',
        'The text view (?view=text) works without the Flutter runtime. Markdown guides are linked below. These are reading aids, not a separate product or a claim of protocol compatibility.\n',
        'NibMotion and NibComponents are published packages. Some examples use local candidate features; keep each guide’s release and platform limitations. NibGenUI remains an unpublished A2UI v0.9.1 subset.\n', '## Pages\n']
    full = []
    for page in pages:
        route = page['route']
        slug = route.strip('/').replace('/','-') or 'home'
        image_path = '/social/'+slug+'.png'
        social_card(static/image_path.lstrip('/'),page['title'],page['category'])
        file = 'index.html' if route == '/' else route.lstrip('/')+'.html'
        dest = static/file; dest.parent.mkdir(parents=True,exist_ok=True)
        dest.write_text(render(page,origin,production,image_path))
        if route != '/':
            overrides[file] = {'path': route.lstrip('/')}
        if page['index']:
            url = ET.SubElement(sitemap,'url'); ET.SubElement(url,'loc').text=origin+route
            agent_index.append(f'- [{page["title"]}]({origin}{route}?view=text): {page["description"]}\n')
        if page['markdown'] is not None:
            mdpath = '/text'+route+'.md'
            md = f'# {page["title"]}\n\n{page["description"]}\n\nCanonical: {origin}{route}\n' + page['markdown']
            dest = static/mdpath.lstrip('/'); dest.parent.mkdir(parents=True,exist_ok=True); dest.write_text(md)
            agent_index.append(f'  - [Markdown]({origin}{mdpath})\n')
            full.append(md)
    (static/'sitemap.xml').write_bytes(ET.tostring(sitemap,encoding='utf-8',xml_declaration=True))
    (static/'llms.txt').write_text('\n'.join(agent_index))
    (static/'llms-full.txt').write_text('\n\n---\n\n'.join(full))
    (static/'robots.txt').write_text('User-agent: *\nAllow: /\n\nSitemap: '+origin+'/sitemap.xml\n')
    (static/'scraper.txt').write_text('Nib public reading resources\n\nThis is an informational file, not a crawler directive standard.\nUse /robots.txt for crawl rules, /sitemap.xml for public URLs, /llms.txt for the guide index, and /llms-full.txt for the combined documentation.\nRespect source examples and release limitations.\n')
    missing = {'route':'/404','title':'Page not found — Nib','description':'That Nib page does not exist. Browse the documentation, motion examples or components to find your next interaction.','category':'NOT FOUND','body':'<p>'+link('/','Return to Nib')+'</p>','index':False}
    (static/'404.html').write_text(render(missing,origin,False,'/social/home.png'))
    aliases = {'/docs':'/docs/motion/introduction','/motion':'/examples','/playground':'/playground/card-flip','/docs/components/textarea':'/docs/components/input','/playground/components/textarea':'/playground/components/input'}
    # Former Next.js motion detail URLs, checked against its live registry.
    old_motion = {
        'fade':'first-animation','exit':'presence','gesture':'gestures',
        'transition':'transitions','layout':'layout-animations','rotate':'presets',
        'scroll':'scroll-motion','stagger':'variants-stagger','in-view':'viewport-motion',
        'spring':'springs','text':'text-motion','shaders':'shaders','presets':'presets',
        'drag':'drag-and-drop','timeline':'timeline','path':'path-motion',
        'parallax':'scroll-motion','debug':'troubleshooting',
    }
    for old,new in old_motion.items():
        aliases['/motion/'+old]='/docs/motion/'+new
    old_docs = {'animate':'first-animation','drag':'drag-and-drop','lists-and-stagger':'motion-lists','motion-controller':'controllers','path':'path-motion','scroll-effects':'scroll-motion','text':'text-motion','variants':'variants-stagger','viewport-and-scroll':'viewport-motion'}
    for article in data['articles']:
        if article['packageId']=='motion':
            aliases['/docs/'+article['id']]=article['route']
    for old,new in old_docs.items():
        aliases['/docs/'+old]='/docs/motion/'+new
    for g in data['components']:
        aliases['/components/'+g['id']]=g['docsRoute']
    assert all(dest in routes for dest in aliases.values())
    headers={'X-Content-Type-Options':'nosniff','Referrer-Policy':'strict-origin-when-cross-origin'}
    if not production:
        headers['X-Robots-Tag']='noindex, nofollow'
    routing=[{'src':'/.*','headers':headers,'continue':True}]
    routing += [{'src':'^'+re.escape(src)+'/?$','status':308,'headers':{'Location':dest}} for src,dest in aliases.items()]
    routing += [{'src':'^/(.+)/$','status':308,'headers':{'Location':'/$1'}}]
    routing += [{'src':'/(?:text/.*|llms(?:-full)?\\.txt|scraper\\.txt)','headers':{'X-Robots-Tag':'noindex, follow'},'continue':True},
                {'handle':'filesystem'}, {'src':'/.*','dest':'/404.html','status':404}]
    (output/'config.json').write_text(json.dumps({'version':3,'routes':routing,'overrides':overrides},indent=2))
    # Stable inventory binds the tested bytes to the deployment.
    hashes={str(p.relative_to(output)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(output.rglob('*')) if p.is_file()}
    manifest={'mode':args.mode,'origin':origin,'pages':len(pages),'guides':len(data['articles']),'components':len(data['components']),'recipes':len(data['recipes']),'routes':sorted(routes),'aliases':aliases,'sha256':hashes}
    (output/'nib-build-manifest.json').write_text(json.dumps(manifest,indent=2))
    (ROOT/'build/seo'/f'{args.mode}-manifest.json').write_text(json.dumps(manifest,indent=2))
    print(f'Assembled {len(pages)} HTML pages; {len(data["articles"])} Markdown guides; {len(hashes)} files; mode={args.mode}')


if __name__ == '__main__':
    main()
