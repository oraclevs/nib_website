# Nib website deployment

The production website is the Flutter app in `WebsiteEmberLiving`, replacing the former Next.js app in `WebsiteNib`. Do not redeploy the old directory.

- Public site: https://www.nibmotion.xyz
- Vercel project: `nib-website`
- Project ID: `prj_LP8bODFk3QYDXwYYBoHEpsTouQZd`
- Team ID: `team_uLkGKaENnuPQXup2m6SleSHd`
- Deployment format: static Build Output API v3, built locally with Flutter.
- The existing Vercel framework label may still say Next.js. `--prebuilt` uses the assembled static artifact and does not run a Next.js build.

## Rebuild

Run from this directory. The local Nib dependencies in `pubspec.yaml` must be present. The installed build SDK for the October 28 deployment was Flutter 3.47.3 / Dart 3.13.3. The build script needs Python 3 and Pillow; Pillow is a build tool, not a website dependency.

```bash
flutter pub get
flutter test --no-pub tool/export_site_content_test.dart
flutter test --no-pub test/site_router_test.dart test/site_home_navigation_test.dart test/search
flutter build web --wasm --release --no-pub
python3 tool/build_seo.py --mode preview
python3 tool/verify_seo.py
vercel deploy --prebuilt --yes --scope team_uLkGKaENnuPQXup2m6SleSHd
```

This host's Python with Pillow is `/home/occ/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3`. Use that executable for `build_seo.py` here.

Inspect the preview URL from Vercel. Preview deployments retain Vercel authentication and send `noindex`. `vercel curl` can verify them using the existing CLI login. For local visual testing of the same assembled files:

```bash
python3 tool/serve_artifact.py --port 8125
```

After approval to publish, assemble and verify the production variant:

```bash
python3 tool/build_seo.py --mode production
python3 tool/verify_seo.py
vercel deploy --prebuilt --prod --yes --scope team_uLkGKaENnuPQXup2m6SleSHd
python3 tool/check_deployment.py https://www.nibmotion.xyz
```

Check `.vercel/project.json` matches the project and team above before deploying. Upload only the prebuilt output. Do not upload `.env.local`, source backups, evidence archives or local credentials. The CLI may create an ignored `.env.local` when linking; it is not part of the deployment artifact.

## Content and indexing

`tool/export_site_content_test.dart` exports the actual guide, component and recipe models. `tool/build_seo.py` produces route-specific HTML, canonical URLs, Open Graph/Twitter image metadata, WebSite/WebPage/BreadcrumbList JSON-LD, PNG share cards, branded icons, sitemap, robots.txt and agent reading resources. Run the export whenever documentation changes.

The default interface is still Flutter. “Read page as text” opens the same guide or catalog as accessible HTML. `?view=text` skips engine startup. Search crawlers receive the same response as other visitors. The HTML text and APIs are checked against the source models. Client-side navigation updates the metadata and reading view.

Production indexes public pages and excludes the internal search page. Text exports carry `X-Robots-Tag: noindex, follow`; the main HTML URLs are canonical. The sitemap omits fabricated modification dates. Explicit redirects preserve known old docs, components and motion URLs; unknown routes return HTTP 404.

`llms.txt`, `llms-full.txt`, Markdown guides and `scraper.txt` are reading aids. `scraper.txt` is not a standard crawler directive. Neither these files nor structured data guarantee indexing, rich results or rankings.

## Search Console and domain follow-up

No Search Console connector or ownership credential was available in this session. In the existing Google Search Console property for `https://www.nibmotion.xyz`, submit `https://www.nibmotion.xyz/sitemap.xml` and inspect the home, springs guide and liquid-glass playground URLs. Follow Google's ownership verification if the property does not yet exist. Do not invent verification tokens.

The verified live domain is `www.nibmotion.xyz`. The bare domain had no address record during deployment inspection. The user directed this pass to update the existing Vercel site and domain mapping. No registrar DNS change was made. Add and verify the apex separately if it should redirect to www.

## Rollback

The November 3 production deployment is `dpl_5jiSv3LcwzQbzavB1t5Dy2RTGoaj`.
Its immediately preceding production deployment was
`dpl_6DES9YBHeZkX6LmZC6nUAozcdmWg`. See
[the publication record](docs/PRODUCTION_DEPLOYMENT_2026-11-03.md).

If the maintainer chooses to restore the preceding site:

```bash
vercel rollback dpl_6DES9YBHeZkX6LmZC6nUAozcdmWg --yes --scope team_uLkGKaENnuPQXup2m6SleSHd
```

This is a rollback recipe; it was not executed. Current deployment IDs and artifact hashes are recorded in `docs/evidence/2026-10-28-deploy/` and `docs/DEPLOYMENT_REPORT.md`.
