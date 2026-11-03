#!/usr/bin/env python3
"""Local HTTP rehearsal of the exact static output and known route table."""
from http.server import SimpleHTTPRequestHandler,ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit
import argparse,json

parser=argparse.ArgumentParser(); parser.add_argument('--port',type=int,default=8125)
args=parser.parse_args()
root=Path(__file__).resolve().parents[1]/'.vercel/output'
manifest=json.loads((root/'nib-build-manifest.json').read_text())
class Handler(SimpleHTTPRequestHandler):
    def __init__(self,*args,**kw): super().__init__(*args,directory=str(root/'static'),**kw)
    def do_GET(self):
        path=urlsplit(self.path).path
        if path in manifest['aliases']:
            self.send_response(308);self.send_header('Location',manifest['aliases'][path]);self.end_headers();return
        if path in manifest['routes']:
            self.path='/index.html' if path=='/' else path+'.html'
        elif not (root/'static'/path.lstrip('/')).is_file():
            data=(root/'static/404.html').read_bytes();self.send_response(404);self.send_header('Content-Type','text/html');self.end_headers();self.wfile.write(data);return
        super().do_GET()
ThreadingHTTPServer(('127.0.0.1',args.port),Handler).serve_forever()
