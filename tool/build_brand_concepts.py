"""Build local SVG logo studies. These assets are excluded from deployment."""
from pathlib import Path
import html
import subprocess

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'web/brand/concepts-v2'
OUT.mkdir(parents=True, exist_ok=True)
AMBER = '#ffb511'
IVORY = '#f5e9c9'
DARK = '#111210'

def pen(x, y, angle=0, scale=1, color=IVORY):
    # The origin is the tip: each design connects its ink path to this point.
    return f'''<g transform="translate({x} {y}) rotate({angle}) scale({scale})">
    <path d="M-18-108H18V-84H-18Z" fill="{color}"/>
    <path d="M-21-78L-28-58Q-20-27 0 0Q20-27 28-58L21-78Z" fill="{color}"/>
    <path d="M0-48V-2" stroke="{DARK}" stroke-width="3"/>
    <circle cy="-48" r="6" fill="{DARK}"/>
    <path d="M-17-57L-9-37M17-57L9-37" stroke="{DARK}" stroke-width="1.5" fill="none"/>
    </g>'''

def svg(title, desc, body, view='0 0 500 280'):
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="{view}" role="img" aria-labelledby="title desc">
<title id="title">{html.escape(title)}</title><desc id="desc">{html.escape(desc)}</desc>
{body}\n</svg>'''

concepts = [
    ('a', 'The writing I', 'The fountain nib becomes the I. Its tip draws a continuous underline beneath NIB.',
     f'''<g fill="none" stroke="{AMBER}" stroke-width="24" stroke-linecap="round" stroke-linejoin="round">
     <path d="M78 204V90L166 204V90"/>
     <path d="M295 90V204H340C389 204 393 146 342 146H295M295 90H335C379 90 379 146 340 146"/>
     </g>
     <path d="M230 204C225 235 288 232 324 230C394 226 400 250 350 252H92" fill="none" stroke="{AMBER}" stroke-width="5" stroke-linecap="round"/>
     {pen(230,204,scale=1.25)}'''),
    ('b', 'The signature', 'Joined lowercase nib lettering, finished by a fountain pen at the end of the ink stroke.',
     f'''<g fill="none" stroke="{IVORY}" stroke-width="15" stroke-linecap="round" stroke-linejoin="round">
     <path d="M67 192L80 126M71 170C87 128 126 118 128 149C129 164 115 197 140 188"/>
     <path d="M171 133L160 177Q155 203 185 183"/>
     <path d="M211 179C222 143 253 65 235 58C217 52 205 107 205 153C205 195 240 202 260 172C286 131 235 122 212 165"/>
     </g><circle cx="178" cy="104" r="9" fill="{AMBER}"/>
     <path d="M249 187C281 193 308 174 326 150" fill="none" stroke="{AMBER}" stroke-width="7" stroke-linecap="round"/>
     {pen(326,150,angle=34,scale=.91)}
     <path d="M84 225Q177 211 257 217" fill="none" stroke="{AMBER}" stroke-width="3" stroke-linecap="round"/>'''),
    ('c', 'The finishing stroke', 'Bold, forward-leaning NIB lettering flows into a pen-drawn flourish from the B.',
     f'''<g transform="translate(28 8) skewX(-9)" fill="{IVORY}">
     <path d="M64 193V77H92L145 151V77H174V193H146L93 119V193Z"/>
     <path d="M196 77H225V193H196Z"/>
     <path fill-rule="evenodd" d="M247 77H299C351 77 351 132 328 137C361 146 352 193 302 193H247ZM276 100V125H297C316 125 316 100 297 100ZM276 147V170H301C321 170 321 147 301 147Z"/>
     </g>
     <path d="M322 193C362 200 378 229 332 235C276 244 172 214 95 228" fill="none" stroke="{AMBER}" stroke-width="7" stroke-linecap="round"/>
     <path d="M95 228C69 232 70 246 93 245C176 241 286 255 381 221" fill="none" stroke="{AMBER}" stroke-width="3" stroke-linecap="round"/>
     {pen(381,221,angle=27,scale=1.16,color=AMBER)}'''),
    ('d', 'The ink seal', 'A compact NIB monogram enclosed by the same stroke the fountain nib is writing.',
     f'''<path d="M316 222C268 264 173 244 151 191C125 130 161 61 223 47C288 32 348 75 353 136" fill="none" stroke="{AMBER}" stroke-width="6" stroke-linecap="round"/>
     <g fill="none" stroke="{IVORY}" stroke-width="13" stroke-linecap="round" stroke-linejoin="round">
     <path d="M174 174V112L211 174V112"/>
     <path d="M233 112V174"/>
     <path d="M256 112V174H278C307 174 307 143 278 143H256M256 112H277C302 112 302 143 277 143"/>
     </g>
     {pen(316,222,angle=33,scale=.83)}'''),
]

for key, title, desc, body in concepts:
    content = svg(title, desc, body)
    (OUT / f'nib-{key}.svg').write_text(content)
    subprocess.run(['rsvg-convert', '-w', '1000', '-h', '560', '-o', str(OUT / f'nib-{key}.png'), str(OUT / f'nib-{key}.svg')], check=True)

board = f'<rect width="1200" height="1000" fill="{DARK}"/><text x="40" y="51" fill="{AMBER}" font-family="monospace" font-size="13" letter-spacing="3">NIB / FOUR LOGO DIRECTIONS</text><text x="40" y="97" fill="{IVORY}" font-family="Arial,sans-serif" font-size="30" font-weight="700">Three letters. A nib at work.</text>'
for idx, (key, title, desc, body) in enumerate(concepts):
    x = 30 + (idx % 2) * 585
    y = 135 + (idx // 2) * 415
    board += f'<g transform="translate({x} {y})"><rect width="555" height="390" rx="14" fill="#181a14" stroke="#373a30"/><text x="28" y="43" fill="{AMBER}" font-family="Arial,sans-serif" font-size="22" font-weight="700">{key.upper()}</text><text x="65" y="43" fill="{IVORY}" font-family="Arial,sans-serif" font-size="22" font-weight="700">{title}</text><g transform="translate(28 72)">{body}</g></g>'
(OUT/'nib-comparison.svg').write_text(svg('Nib logo alternatives', 'Four NIB and writing nib concepts, labeled A through D.', board, '0 0 1200 1000'))
subprocess.run(['rsvg-convert', '-o', str(OUT/'nib-comparison.png'), str(OUT/'nib-comparison.svg')], check=True)

cards = '' 
for key, title, desc, body in concepts:
    cards += f'''<article id="{key}"><header><span class="letter">{key.upper()}</span><div><h2>{title}</h2><p>{desc}</p></div></header>
    <div class="art"><img src="concepts-v2/nib-{key}.svg" alt="{html.escape(desc)}"></div>
    <div class="nav"><img src="concepts-v2/nib-{key}.svg" alt="{title} at navbar size"><span>ECOSYSTEM</span><div class="navlinks">Motion<span>Docs</span></div></div>
    <footer><span>SVG · Original vector artwork</span><a href="concepts-v2/nib-{key}.svg" target="_blank">Open SVG ↗</a></footer></article>'''
page = '''<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="robots" content="noindex,nofollow"><title>Nib · Four logo directions</title><style>
:root{color-scheme:dark;--ink:#f5e9c9;--amber:#ffb511;--paper:#111210;--line:#373a30;--muted:#bebbaa}*{box-sizing:border-box}body{margin:0;background:var(--paper);color:var(--ink);font:16px/1.55 Arial,sans-serif}main{max-width:1380px;margin:auto;padding:36px 36px 64px}.eyebrow{font:11px monospace;color:var(--amber);letter-spacing:3px}h1{font-size:clamp(30px,4vw,48px);line-height:1.08;letter-spacing:-1.8px;margin:15px 0}main>p{color:var(--muted);max-width:820px;margin:0 0 30px}.grid{display:grid;grid-template-columns:1fr 1fr;gap:24px}article{background:#181a14;border:1px solid var(--line);border-radius:12px;overflow:hidden}header{display:flex;gap:16px;padding:24px 26px 0;min-height:112px}.letter{flex:none;display:grid;place-items:center;width:34px;height:34px;border:1px solid #6d5622;border-radius:6px;font:15px monospace;color:var(--amber)}h2{font-size:21px;letter-spacing:-.4px;margin:0 0 7px}header p{font-size:14px;color:var(--muted);max-width:480px;margin:0}.art{height:245px;display:flex;justify-content:center;align-items:center;background:var(--paper);margin:20px 20px 0;border-radius:7px}.art img{width:90%;height:100%;object-fit:contain}.nav{height:89px;display:flex;align-items:center;gap:12px;border-bottom:1px solid var(--line);margin:0 24px}.nav img{width:126px;height:72px;object-fit:contain}.nav>span{font:9px monospace;letter-spacing:1.8px;color:var(--muted)}.navlinks{display:flex;gap:18px;margin-left:auto;font-size:12px;color:var(--muted)}footer{display:flex;justify-content:space-between;gap:12px;align-items:center;padding:16px 24px;font-size:11px;color:var(--muted)}a{color:var(--amber);text-decoration:none}a:hover{text-decoration:underline}.note{margin-top:24px!important;font-size:13px}button{font:inherit;cursor:pointer;border:1px solid var(--line);color:var(--ink);background:#202319;border-radius:6px;padding:8px 13px}.tools{display:flex;gap:10px;margin-bottom:24px;align-items:center}.tools span{font:11px monospace;color:var(--muted);margin-left:auto}.mono .art img,.mono .nav img{filter:grayscale(1) brightness(1.6)}@media(max-width:820px){main{padding:26px 18px}.grid{grid-template-columns:1fr}.art{height:240px}.navlinks{display:none}}@media(prefers-reduced-motion:reduce){*{scroll-behavior:auto}}
</style></head><body><main><div class="eyebrow">NIB / LOGO STUDIES / ROUND TWO</div><h1>Three letters. A nib at work.</h1><p>Four ways to combine N, I and B with a fountain pen making its mark. Each design uses the website’s amber and ivory, with a small navbar preview underneath.</p><div class="tools"><button id="mono" type="button" aria-pressed="false">Check in monochrome</button><span>LOCAL REVIEW · NOT PUBLISHED</span></div><section class="grid">''' + cards + '''</section><p class="note">Choose a direction, or combine details you like. The live website still uses its current logo.</p></main><script>document.getElementById('mono').addEventListener('click',function(){const on=document.body.classList.toggle('mono');this.setAttribute('aria-pressed',String(on));this.textContent=on?'Return to amber + ivory':'Check in monochrome';});</script></body></html>'''
review = ROOT / 'web/brand/review.html'
old = ROOT / 'web/brand/review-v1.html'
if not old.exists():
    old.write_text(review.read_text())
review.write_text(page)
print('Built four SVG studies, PNG exports and the local review page.')
