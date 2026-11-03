#!/usr/bin/env python3
"""HTTP smoke checks. Vercel authentication is used only for protected previews."""
import argparse,concurrent.futures,hashlib,json,os,re,subprocess,tempfile
from pathlib import Path
from urllib import request,error

p=argparse.ArgumentParser();p.add_argument('origin');p.add_argument('--preview',action='store_true');args=p.parse_args()
paths=['/','/motion-docs-source.json','/docs/motion/springs','/playground/components/liquid-glass','/robots.txt','/sitemap.xml','/llms.txt','/llms-full.txt','/social/home.png','/main.dart.wasm','/does-not-exist-seo-check','/motion']
manifest=json.loads((Path(__file__).resolve().parents[1]/'.vercel/output/nib-build-manifest.json').read_text())
motion_routes=[route for route in manifest['routes'] if route.startswith('/docs/motion/')]
paths=list(dict.fromkeys(paths+motion_routes+['/text'+route+'.md' for route in motion_routes]+[
    '/packages/motion','/main.dart.js',
    '/playground/guide-motion-water-example',
    '/playground/guide-motion-tuner-example',
    '/playground/guide-motion-shared-layout-example',
    '/playground/guide-motion-entrance-example',
    '/playground/guide-motion-intro-example',
    '/playground/guide-motion-controller-example',
    '/playground/components/switch',
    '/playground/components/skeleton',
]))
class NoRedirect(request.HTTPRedirectHandler):
    def redirect_request(self,*a,**kw): return None
opener=request.build_opener(NoRedirect)

def fetch(path):
    url=args.origin.rstrip('/')+path
    with tempfile.TemporaryDirectory(prefix='nib-http-') as temp:
        header=Path(temp)/'headers';body=Path(temp)/'body'
        flags=['--silent','--show-error','--retry','1','--max-time','45','--dump-header',str(header),'--output',str(body)]
        token_flags=['--token',os.environ['VERCEL_TOKEN']] if os.environ.get('VERCEL_TOKEN') else []
        command=(['vercel','curl',path,'--deployment',args.origin]+token_flags+['--']+flags) if args.preview else ['curl',url]+flags
        run=subprocess.run(command,capture_output=True,text=True)
        if run.returncode: return {'path':path,'error':'HTTP request failed','exit':run.returncode,'passed':False}
        raw=header.read_text();status=int(re.findall(r'HTTP/[^ ]+ (\d+)',raw)[-1]);headers={k.lower():v.strip() for k,v in re.findall(r'^([^:\n]+):([^\n]*)',raw,re.M)};data=body.read_bytes()
    row={'path':path,'status':status,'content_type':headers.get('content-type'),'robots_header':headers.get('x-robots-tag'),'bytes':len(data)}
    expected=404 if path.startswith('/does-not') else 308 if path=='/motion' else 200
    row['passed']=status==expected
    if path in manifest['routes']:
        text=data.decode();canonical=re.search(r'rel="canonical" href="([^"]+)"',text);robots=re.search(r'name="robots" content="([^"]+)"',text)
        row['canonical']=canonical[1] if canonical else None;row['robots']=robots[1] if robots else None
        row['passed'] &= row['canonical']=='https://www.nibmotion.xyz'+path and bool(robots) and (('noindex' in robots[1])==args.preview)
    if path=='/motion':
        row['location']=headers.get('location');row['passed'] &= row['location']=='/examples'
    if path.endswith('.png'): row['passed'] &= data.startswith(b'\x89PNG\r\n\x1a\n')
    if path.endswith('.wasm'): row['passed'] &= data.startswith(b'\0asm') and 'application/wasm' in row['content_type']
    if status == 200:
        static=Path(__file__).resolve().parents[1]/'.vercel/output/static'
        local=static/('index.html' if path=='/' else path.lstrip('/'))
        if not local.is_file(): local=static/(path.lstrip('/')+'.html')
        if local.is_file():
            row['sha256']=hashlib.sha256(data).hexdigest()
            # Vercel adds this review toolbar to preview HTML responses.
            compared=re.sub(rb'<script async data-explicit-opt-in="true" data-deployment-id="dpl_[A-Za-z0-9]+" src="https://vercel.live/_next-live/feedback/feedback.js"></script>', b'', data) if args.preview and local.suffix=='.html' else data
            row['preview_toolbar_injected']=compared!=data
            row['matches_artifact']=hashlib.sha256(compared).hexdigest()==hashlib.sha256(local.read_bytes()).hexdigest()
            row['passed'] &= row['matches_artifact']
    return row
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
    results=list(pool.map(fetch,paths))
print(json.dumps({'origin':args.origin,'preview':args.preview,'checks':results},indent=2))
raise SystemExit(0 if all(x.get('passed') for x in results) else 1)
